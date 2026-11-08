import { describe, expect, it } from 'vitest';
import { isLoopbackRedirect, sameRedirect } from '../src/auth/clients.js';
import { hashPassword, verifyPassword } from '../src/auth/password.js';
import { LoginThrottle } from '../src/auth/rateLimit.js';
import { TotpVerifier, base32Encode, totpCode } from '../src/auth/totp.js';
import { loadConfig } from '../src/config.js';
import { ConfirmationStore } from '../src/domain/confirmations.js';
import { containsPassageOf } from '../src/domain/leakCheck.js';
import { sameVersion } from '../src/domain/notes.js';
import { searchTerms, tagsIn } from '../src/domain/search.js';
import { Roster, mergedReaders } from '../src/domain/visibility.js';
import { fetchRemoteImage, isPublicAddress } from '../src/images/fetchRemote.js';
import { detectImageKind } from '../src/images/process.js';
import { loggablePath } from '../src/log.js';
import { insertInto } from '../src/mcp/common.js';
import type { QkBlock } from '../src/questkeeper/types.js';
import { pngImage } from './harness.js';

describe('TOTP', () => {
  const secret = base32Encode(Buffer.from('12345678901234567890'));

  it('matches the RFC 6238 test vectors', () => {
    expect(totpCode(secret, Math.floor(59 / 30))).toBe('287082');
    expect(totpCode(secret, Math.floor(1111111109 / 30))).toBe('081804');
  });

  it('accepts one step either side, but each code only once', () => {
    let now = 1111111109 * 1000;
    const verifier = new TotpVerifier(secret, () => now);
    expect(verifier.verify('081804')).toBe(true);
    expect(verifier.verify('081804')).toBe(false);
    now += 30_000;
    expect(verifier.verify(totpCode(secret, Math.floor(now / 30_000) + 1))).toBe(true);
    expect(verifier.verify('12345')).toBe(false);
  });
});

describe('password', () => {
  it('verifies only the right password', async () => {
    const hash = await hashPassword('ein gutes Passwort');
    expect(hash).toMatch(/^scrypt:131072:8:1:/);
    expect(await verifyPassword('ein gutes Passwort', hash)).toBe(true);
    expect(await verifyPassword('ein gutes passwort', hash)).toBe(false);
    expect(await verifyPassword('x', 'scrypt:broken')).toBe(false);
  });
});

describe('login throttle', () => {
  it('locks one address after five failures and everyone after twenty', () => {
    let now = 0;
    const throttle = new LoginThrottle(undefined, () => now);
    for (let index = 0; index < 5; index++) throttle.recordFailure('1.1.1.1');
    expect(throttle.isLocked('1.1.1.1')).toBe(true);
    expect(throttle.isLocked('2.2.2.2')).toBe(false);
    now += 16 * 60_000;
    expect(throttle.isLocked('1.1.1.1')).toBe(false);
    for (let index = 0; index < 20; index++) throttle.recordFailure(`10.0.0.${index}`);
    expect(throttle.isLocked('3.3.3.3')).toBe(true);
  });
});

describe('redirects', () => {
  it('matches loopback redirects regardless of port, nothing else', () => {
    expect(sameRedirect('http://localhost/callback', 'http://localhost:6274/callback')).toBe(true);
    expect(sameRedirect('http://127.0.0.1:1/cb', 'http://127.0.0.1:2/cb')).toBe(true);
    expect(sameRedirect('http://localhost/callback', 'http://localhost:1/other')).toBe(false);
    expect(sameRedirect('https://claude.ai/a', 'https://claude.ai/b')).toBe(false);
    expect(isLoopbackRedirect('http://evil.localhost.example/cb')).toBe(false);
  });
});

describe('leak check', () => {
  it('finds runs of eight words and whole short blocks, ignoring case and punctuation', () => {
    const secret = 'Der Graf ist in Wahrheit der verschollene Bruder der Königin.';
    expect(containsPassageOf('Gerücht: der graf ist in wahrheit der verschollene bruder!', secret)).toBe(true);
    expect(containsPassageOf('Der Graf ist alt.', secret)).toBe(false);
    expect(containsPassageOf('Wir wissen: Orlok ist der Verräter.', 'Orlok ist der Verräter')).toBe(true);
    expect(containsPassageOf('Orlok', 'Orlok')).toBe(false);
  });
});

describe('readers', () => {
  const block = (visibleTo: string[] | null, isOwn = true) => ({ visibleTo, isOwn }) as unknown as QkBlock;

  it('keeps equal readers and makes mixed ones private', () => {
    expect(mergedReaders([block(['b', 'a']), block(['a', 'b'])])).toEqual({ readers: ['a', 'b'], madePrivate: false });
    expect(mergedReaders([block(['a']), block([])])).toEqual({ readers: [], madePrivate: true });
    expect(mergedReaders([block([]), block([])])).toEqual({ readers: [], madePrivate: false });
  });

  it('turns names into user ids', () => {
    const roster = new Roster([
      { userId: 'me', isDm: false, isYou: true, characters: [{ id: '1', name: 'Arwen' }] },
      { userId: 'dm', isDm: true, isYou: false, characters: [] },
      { userId: 'ben', isDm: false, isYou: false, characters: [{ id: '2', name: 'Borin Eisenfaust' }] },
    ]);
    expect(roster.resolve(['Spielleitung', 'borin eisenfaust'])).toEqual(['ben', 'dm']);
    expect(roster.resolve(['alle'])).toEqual(['ben', 'dm']);
    expect(() => roster.resolve(['Arwen'])).toThrow();
    expect(roster.describe(['dm', 'ben'])).toBe('geteilt mit Borin Eisenfaust, Spielleitung');
    expect(roster.describe([])).toBe('privat');
  });
});

describe('search helpers', () => {
  it('reads hashtags and quoted phrases', () => {
    expect(tagsIn('Ein #Drache im #Hort-Süd, nicht a#b oder &#39;')).toEqual(['drache', 'hort-sud']);
    expect(searchTerms('Turm "alte Brücke" Ä')).toEqual(['turm', 'alte brucke', 'a']);
  });
});

describe('order', () => {
  it('inserts at the start, after a block or at the end, moving blocks already there', () => {
    expect(insertInto(['a', 'b', 'c'], ['x'], 'b')).toEqual(['a', 'b', 'x', 'c']);
    expect(insertInto(['a', 'b', 'c'], ['x'], 'anfang')).toEqual(['x', 'a', 'b', 'c']);
    expect(insertInto(['a', 'b', 'c'], ['a'])).toEqual(['b', 'c', 'a']);
    expect(() => insertInto(['a', 'b'], ['a'], 'a')).toThrow();
  });
});

describe('confirmations', () => {
  it('work once, for the same request, for ten minutes', () => {
    let now = 0;
    const store = new ConfirmationStore(() => now);
    const code = store.create('x', { ids: ['1'] }, 42);
    expect(store.take('x', { ids: ['2'] }, code).ok).toBe(false);
    expect(store.take('y', { ids: ['1'] }, code).ok).toBe(false);
    expect(store.take('x', { ids: ['1'] }, code.toLowerCase())).toEqual({ ok: true, data: 42 });
    expect(store.take('x', { ids: ['1'] }, code).ok).toBe(false);
    const late = store.create('x', {}, null);
    now += 11 * 60_000;
    expect(store.take('x', {}, late).ok).toBe(false);
  });
});

describe('versions', () => {
  it('compare the API strings to the millisecond', () => {
    expect(sameVersion('2026-11-07T10:00:01.0000001+00:00', '2026-11-07T10:00:01.0000001+00:00')).toBe(true);
    expect(sameVersion('2026-11-07T10:00:01.0000001+00:00', '2026-11-07T11:00:01.000+01:00')).toBe(true);
    expect(sameVersion('2026-11-07T10:00:01.000+00:00', '2026-11-07T10:00:01.002+00:00')).toBe(false);
  });
});

describe('addresses', () => {
  it('lets only public addresses through', () => {
    for (const address of ['127.0.0.1', '10.0.0.8', '172.20.1.1', '192.168.1.10', '169.254.169.254', '100.64.0.1', '::1', 'fd00::1', 'fe80::1', '::ffff:127.0.0.1', '0.0.0.0']) {
      expect(isPublicAddress(address), address).toBe(false);
    }
    for (const address of ['1.1.1.1', '93.184.216.34', '2606:4700:4700::1111']) expect(isPublicAddress(address), address).toBe(true);
    expect(isPublicAddress('::ffff:7f00:1')).toBe(false);
  });

  it('refuses links whose host resolves to an internal address, even one of several', async () => {
    await expect(
      fetchRemoteImage('https://intern.example/x.png', { resolver: async () => [{ address: '10.0.0.5', family: 4 }] }),
    ).rejects.toThrow(/interne Adresse/);
    await expect(
      fetchRemoteImage('https://mixed.example/x.png', {
        resolver: async () => [
          { address: '1.1.1.1', family: 4 },
          { address: '127.0.0.1', family: 4 },
        ],
      }),
    ).rejects.toThrow(/interne Adresse/);
  });
});

describe('images', () => {
  it('recognises formats by their bytes, not their name', async () => {
    expect(detectImageKind(await pngImage())).toBe('png');
    expect(detectImageKind(Buffer.from('<svg xmlns="http://www.w3.org/2000/svg"></svg>'))).toBeNull();
  });
});

describe('log paths', () => {
  it('hide upload tokens and query strings', () => {
    expect(loggablePath('/upload/abcDEF123?x=1')).toBe('/upload/:token');
    expect(loggablePath('/authorize?code_challenge=abc&state=x')).toBe('/authorize');
  });
});

describe('config', () => {
  it('names wrong settings without printing their values', () => {
    expect(() =>
      loadConfig({ PUBLIC_BASE_URL: 'https://x.example', LOGIN_PASSWORD_HASH: 'hunter2-plain', QK_API_KEY: 'k' } as NodeJS.ProcessEnv),
    ).toThrow(/LOGIN_PASSWORD_HASH/);
    try {
      loadConfig({ PUBLIC_BASE_URL: 'https://x.example', LOGIN_PASSWORD_HASH: 'hunter2-plain', QK_API_KEY: 'k' } as NodeJS.ProcessEnv);
    } catch (error) {
      expect((error as Error).message).not.toContain('hunter2');
    }
  });

  it('derives the MCP address from the public one', () => {
    const config = loadConfig({
      PUBLIC_BASE_URL: 'https://notizen.example.de/',
      LOGIN_PASSWORD_HASH: 'scrypt:16384:8:1:c2FsdA:aGFzaA',
      QK_API_KEY: 'qk_1234567890',
    } as NodeJS.ProcessEnv);
    expect(config.mcpUrl).toBe('https://notizen.example.de/mcp');
    expect(config.ALLOW_LOOPBACK_REDIRECTS).toBe(false);
    expect(config.ALLOWED_CLIENT_ID_HOSTS).toEqual(['claude.ai']);
  });
});
