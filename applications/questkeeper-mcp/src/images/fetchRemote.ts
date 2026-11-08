import dns from 'node:dns/promises';
import https from 'node:https';
import net from 'node:net';
import { UserError } from '../domain/errors.js';
import { maxInputBytes } from './process.js';

/**
 * Loads an image from a public https link. Guards against server-side request forgery: the host must
 * resolve to public addresses only, the connection goes to exactly the address that was checked (no DNS
 * rebinding), every redirect is checked again, and size and time are capped.
 */

const blocked = new net.BlockList();
for (const [address, prefix] of [
  ['0.0.0.0', 8],
  ['10.0.0.0', 8],
  ['100.64.0.0', 10],
  ['127.0.0.0', 8],
  ['169.254.0.0', 16],
  ['172.16.0.0', 12],
  ['192.0.0.0', 24],
  ['192.0.2.0', 24],
  ['192.88.99.0', 24],
  ['192.168.0.0', 16],
  ['198.18.0.0', 15],
  ['198.51.100.0', 24],
  ['203.0.113.0', 24],
  ['224.0.0.0', 4],
  ['240.0.0.0', 4],
] as const) {
  blocked.addSubnet(address, prefix, 'ipv4');
}
for (const [address, prefix] of [
  ['::', 128],
  ['::1', 128],
  ['64:ff9b::', 96],
  ['64:ff9b:1::', 48],
  ['100::', 64],
  ['2001::', 32],
  ['2001:db8::', 32],
  ['2002::', 16],
  ['fc00::', 7],
  ['fe80::', 10],
  ['fec0::', 10],
  ['ff00::', 8],
] as const) {
  blocked.addSubnet(address, prefix, 'ipv6');
}

/** ::ffff:7f00:1 or ::ffff:127.0.0.1 -> 127.0.0.1 */
function mappedIpv4(address: string): string | undefined {
  const match = /^::ffff:(?:0:)?(.+)$/i.exec(address);
  if (!match) return undefined;
  const rest = match[1]!;
  if (net.isIPv4(rest)) return rest;
  const parts = rest.split(':');
  if (parts.length !== 2 || !parts.every((part) => /^[0-9a-f]{1,4}$/i.test(part))) return undefined;
  const [high, low] = parts.map((part) => parseInt(part, 16)) as [number, number];
  return [high >> 8, high & 255, low >> 8, low & 255].join('.');
}

export function isPublicAddress(address: string): boolean {
  const family = net.isIP(address);
  // BlockList also applies IPv6 rules to IPv4 (as ::ffff:a.b.c.d), so mapped addresses are checked as IPv4.
  if (family === 4) return !blocked.check(address, 'ipv4');
  if (family === 6) {
    const mapped = mappedIpv4(address);
    if (mapped) return !blocked.check(mapped, 'ipv4');
    return !blocked.check(address, 'ipv6');
  }
  return false;
}

export type Resolver = (hostname: string) => Promise<{ address: string; family: number }[]>;

const defaultResolver: Resolver = (hostname) => dns.lookup(hostname, { all: true, verbatim: true });

export async function fetchRemoteImage(
  link: string,
  options: { resolver?: Resolver; timeoutMs?: number; maxRedirects?: number } = {},
): Promise<Buffer> {
  const resolver = options.resolver ?? defaultResolver;
  const deadline = Date.now() + (options.timeoutMs ?? 20_000);
  let current = link;
  for (let hop = 0; hop <= (options.maxRedirects ?? 3); hop++) {
    let url: URL;
    try {
      url = new URL(current);
    } catch {
      throw new UserError('Das ist kein gültiger Link.');
    }
    if (url.protocol !== 'https:') throw new UserError('Nur https-Links werden geladen.');
    if (url.username || url.password) throw new UserError('Links mit Zugangsdaten werden nicht geladen.');
    const host = url.hostname.replace(/^\[|\]$/g, '');
    const addresses = net.isIP(host) ? [{ address: host, family: net.isIP(host) }] : await resolver(host).catch(() => []);
    if (addresses.length === 0) throw new UserError('Der Server des Links ist unbekannt.');
    if (!addresses.every((entry) => isPublicAddress(entry.address))) {
      throw new UserError('Der Link zeigt auf eine interne Adresse; so etwas lädt der Server nicht.');
    }
    const target = addresses[0]!;
    const result = await get(url, target, Math.max(1000, deadline - Date.now()));
    if (result.redirect) {
      current = new URL(result.redirect, url).toString();
      continue;
    }
    return result.body!;
  }
  throw new UserError('Der Link leitet zu oft weiter.');
}

function get(
  url: URL,
  target: { address: string; family: number },
  timeoutMs: number,
): Promise<{ redirect?: string; body?: Buffer }> {
  return new Promise((resolve, reject) => {
    const request = https.get(
      url,
      {
        headers: { 'User-Agent': 'questkeeper-mcp/1.0', Accept: 'image/*' },
        // Always the address that was checked. Node asks for a list when it tries several addresses.
        lookup: ((_hostname: string, lookupOptions: { all?: boolean }, callback: (...args: unknown[]) => void) => {
          if (lookupOptions?.all) callback(null, [{ address: target.address, family: target.family }]);
          else callback(null, target.address, target.family);
        }) as unknown as net.LookupFunction,
        timeout: timeoutMs,
      },
      (response) => {
        const status = response.statusCode ?? 0;
        if ([301, 302, 303, 307, 308].includes(status) && response.headers.location) {
          response.resume();
          resolve({ redirect: response.headers.location });
          return;
        }
        if (status < 200 || status >= 300) {
          response.resume();
          reject(new UserError(`Der Link antwortet mit ${status}.`));
          return;
        }
        const declared = Number(response.headers['content-length'] ?? 0);
        if (declared > maxInputBytes) {
          response.destroy();
          reject(new UserError('Das Bild ist größer als 15 MB.'));
          return;
        }
        const chunks: Buffer[] = [];
        let total = 0;
        response.on('data', (chunk: Buffer) => {
          total += chunk.length;
          if (total > maxInputBytes) {
            response.destroy();
            reject(new UserError('Das Bild ist größer als 15 MB.'));
            return;
          }
          chunks.push(chunk);
        });
        response.on('end', () => resolve({ body: Buffer.concat(chunks) }));
        response.on('error', () => reject(new UserError('Das Bild ließ sich nicht vollständig laden.')));
      },
    );
    request.on('timeout', () => request.destroy(new Error('timeout')));
    request.on('error', (error) =>
      reject(error instanceof UserError ? error : new UserError('Der Link ließ sich nicht laden.')),
    );
  });
}
