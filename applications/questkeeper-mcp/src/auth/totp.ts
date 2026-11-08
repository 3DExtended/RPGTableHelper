import { createHmac, randomBytes, timingSafeEqual } from 'node:crypto';

const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

export function base32Encode(bytes: Buffer): string {
  let bits = 0;
  let value = 0;
  let output = '';
  for (const byte of bytes) {
    value = (value << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      output += alphabet[(value >>> (bits - 5)) & 31];
      bits -= 5;
    }
  }
  if (bits > 0) output += alphabet[(value << (5 - bits)) & 31];
  return output;
}

export function base32Decode(text: string): Buffer {
  const clean = text.replace(/=+$/, '').replace(/\s+/g, '').toUpperCase();
  let bits = 0;
  let value = 0;
  const bytes: number[] = [];
  for (const char of clean) {
    const index = alphabet.indexOf(char);
    if (index < 0) throw new Error('not base32');
    value = (value << 5) | index;
    bits += 5;
    if (bits >= 8) {
      bytes.push((value >>> (bits - 8)) & 255);
      bits -= 8;
    }
  }
  return Buffer.from(bytes);
}

export function newTotpSecret(): string {
  return base32Encode(randomBytes(20));
}

export function totpCode(secret: string, counter: number): string {
  const message = Buffer.alloc(8);
  message.writeBigUInt64BE(BigInt(counter));
  const digest = createHmac('sha1', base32Decode(secret)).update(message).digest();
  const offset = digest[digest.length - 1]! & 15;
  const binary = (digest.readUInt32BE(offset) & 0x7fffffff) % 1_000_000;
  return binary.toString().padStart(6, '0');
}

/**
 * Checks a 6-digit code against the current 30 s step and one step either side. A code that matched once
 * (its step or an earlier one) is refused, so an overheard code cannot be used again.
 */
export class TotpVerifier {
  private lastUsedCounter = -1;

  constructor(
    private readonly secret: string,
    private readonly now: () => number = Date.now,
  ) {}

  verify(code: string): boolean {
    const digits = code.replace(/\s+/g, '');
    if (!/^\d{6}$/.test(digits)) return false;
    const current = Math.floor(this.now() / 30_000);
    for (const counter of [current - 1, current, current + 1]) {
      if (counter <= this.lastUsedCounter) continue;
      const expected = Buffer.from(totpCode(this.secret, counter));
      if (timingSafeEqual(expected, Buffer.from(digits))) {
        this.lastUsedCounter = counter;
        return true;
      }
    }
    return false;
  }
}
