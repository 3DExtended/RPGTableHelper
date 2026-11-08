/**
 * Who may ask for a login: a Client ID Metadata Document (an https client_id on an allowed host, e.g. Claude)
 * or the optional fixed STATIC_CLIENT_ID. A redirect URI must be listed by the client and allowed here.
 */

export interface ClientInfo {
  clientId: string;
  name: string;
  redirectUris: string[];
  kind: 'metadata-document' | 'static';
}

export interface ClientPolicy {
  allowedClientIdHosts: string[];
  allowedRedirectUris: string[];
  allowLoopbackRedirects: boolean;
  staticClientId?: string;
}

export class ClientError extends Error {}

type FetchLike = typeof fetch;

const cacheMs = 10 * 60_000;
const maxDocumentBytes = 64 * 1024;

export class ClientRegistry {
  private readonly cache = new Map<string, { info: ClientInfo; until: number }>();

  constructor(
    private readonly policy: ClientPolicy,
    private readonly fetchImpl: FetchLike = fetch,
    private readonly now: () => number = Date.now,
  ) {}

  async resolve(clientId: string): Promise<ClientInfo> {
    if (this.policy.staticClientId && clientId === this.policy.staticClientId) {
      return { clientId, name: 'Eigener OAuth-Client', redirectUris: [], kind: 'static' };
    }
    let url: URL;
    try {
      url = new URL(clientId);
    } catch {
      throw new ClientError('Unbekannter Client.');
    }
    if (url.protocol !== 'https:' || url.hash || url.username || url.password || url.pathname === '/') {
      throw new ClientError('Die Client-ID ist keine gültige Metadaten-Adresse.');
    }
    if (!this.policy.allowedClientIdHosts.includes(url.hostname.toLowerCase())) {
      throw new ClientError(`Clients von ${url.hostname} sind hier nicht zugelassen.`);
    }
    const cached = this.cache.get(clientId);
    if (cached && cached.until > this.now()) return cached.info;
    const info = await this.fetchDocument(clientId);
    this.cache.set(clientId, { info, until: this.now() + cacheMs });
    return info;
  }

  /** True if the client may send the user back to this address. */
  isRedirectAllowed(client: ClientInfo, redirectUri: string): boolean {
    if (client.kind === 'metadata-document' && !client.redirectUris.some((uri) => sameRedirect(uri, redirectUri))) {
      return false;
    }
    if (this.policy.allowedRedirectUris.includes(redirectUri)) return true;
    return this.policy.allowLoopbackRedirects && isLoopbackRedirect(redirectUri);
  }

  private async fetchDocument(clientId: string): Promise<ClientInfo> {
    let response: Response;
    try {
      response = await this.fetchImpl(clientId, {
        headers: { accept: 'application/json' },
        redirect: 'error',
        signal: AbortSignal.timeout(5000),
      });
    } catch {
      throw new ClientError('Die Metadaten des Clients sind nicht erreichbar.');
    }
    if (!response.ok) throw new ClientError('Die Metadaten des Clients sind nicht erreichbar.');
    const body = await readLimited(response, maxDocumentBytes);
    let document: unknown;
    try {
      document = JSON.parse(body);
    } catch {
      throw new ClientError('Die Metadaten des Clients sind kein JSON.');
    }
    if (typeof document !== 'object' || document === null) throw new ClientError('Ungültige Client-Metadaten.');
    const record = document as Record<string, unknown>;
    if (record.client_id !== clientId) throw new ClientError('Die Client-Metadaten passen nicht zur Client-ID.');
    const redirectUris = record.redirect_uris;
    if (!Array.isArray(redirectUris) || !redirectUris.every((uri) => typeof uri === 'string')) {
      throw new ClientError('Die Client-Metadaten nennen keine Rücksprungadressen.');
    }
    const method = record.token_endpoint_auth_method;
    if (method !== undefined && method !== 'none') {
      throw new ClientError('Nur öffentliche Clients (ohne Client-Geheimnis) sind zugelassen.');
    }
    const name = typeof record.client_name === 'string' ? record.client_name.slice(0, 80) : new URL(clientId).hostname;
    return { clientId, name, redirectUris: redirectUris as string[], kind: 'metadata-document' };
  }
}

async function readLimited(response: Response, limit: number): Promise<string> {
  const reader = response.body?.getReader();
  if (!reader) return '';
  const chunks: Uint8Array[] = [];
  let total = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.byteLength;
    if (total > limit) {
      await reader.cancel();
      throw new ClientError('Die Client-Metadaten sind zu groß.');
    }
    chunks.push(value);
  }
  return Buffer.concat(chunks).toString('utf8');
}

export function isLoopbackRedirect(uri: string): boolean {
  try {
    const url = new URL(uri);
    return url.protocol === 'http:' && ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname);
  } catch {
    return false;
  }
}

/** Equal, or both loopback addresses that differ only in the port (RFC 8252 7.3). */
export function sameRedirect(registered: string, requested: string): boolean {
  if (registered === requested) return true;
  if (!isLoopbackRedirect(registered) || !isLoopbackRedirect(requested)) return false;
  const a = new URL(registered);
  const b = new URL(requested);
  return a.hostname === b.hostname && a.pathname === b.pathname && a.search === b.search;
}
