import { randomBytes, scrypt as scryptCallback, timingSafeEqual, type ScryptOptions } from 'node:crypto';

function scrypt(password: string, salt: Buffer, keyLength: number, options: ScryptOptions): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    scryptCallback(password, salt, keyLength, options, (error, key) => (error ? reject(error) : resolve(key)));
  });
}

const defaults = { N: 2 ** 17, r: 8, p: 1, keyLength: 32 };

/** A hash in the form scrypt:N:r:p:salt:hash (salt and hash base64url). */
export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16);
  const { N, r, p, keyLength } = defaults;
  const key = await scrypt(password.normalize('NFC'), salt, keyLength, { N, r, p, maxmem: 256 * N * r });
  return ['scrypt', N, r, p, salt.toString('base64url'), key.toString('base64url')].join(':');
}

export async function verifyPassword(password: string, encoded: string): Promise<boolean> {
  const [kind, n, r, p, salt, hash] = encoded.split(':');
  if (kind !== 'scrypt' || !n || !r || !p || !salt || !hash) return false;
  const expected = Buffer.from(hash, 'base64url');
  const N = Number(n);
  const R = Number(r);
  const P = Number(p);
  if (!Number.isInteger(N) || !Number.isInteger(R) || !Number.isInteger(P) || expected.length < 16) return false;
  const actual = await scrypt(password.normalize('NFC'), Buffer.from(salt, 'base64url'), expected.length, {
    N,
    r: R,
    p: P,
    maxmem: 256 * N * R,
  });
  return timingSafeEqual(actual, expected);
}
