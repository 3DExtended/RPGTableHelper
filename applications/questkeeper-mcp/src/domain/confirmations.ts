import { createHash, randomInt } from 'node:crypto';

/**
 * Two-step actions (deleting, widening a share, dissolving a group): the first call describes what would
 * happen and returns a code; only a second call with the same request and that code does it. Codes live
 * 10 minutes, work once and only for the exact request they were made for.
 */

const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const ttlMs = 10 * 60_000;

interface Entry {
  action: string;
  requestHash: string;
  data: unknown;
  expiresAt: number;
}

export function requestHash(request: unknown): string {
  return createHash('sha256').update(stableJson(request)).digest('base64url');
}

function stableJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(',')}]`;
  if (value && typeof value === 'object') {
    const entries = Object.entries(value as Record<string, unknown>)
      .filter(([, entry]) => entry !== undefined)
      .sort(([a], [b]) => a.localeCompare(b));
    return `{${entries.map(([key, entry]) => `${JSON.stringify(key)}:${stableJson(entry)}`).join(',')}}`;
  }
  return JSON.stringify(value);
}

export class ConfirmationStore {
  private readonly entries = new Map<string, Entry>();

  constructor(private readonly now: () => number = Date.now) {}

  /** A new code for this action and request. `data` is handed back on confirmation (e.g. the versions seen). */
  create(action: string, request: unknown, data: unknown): string {
    this.cleanUp();
    let code = '';
    do {
      code = Array.from({ length: 6 }, () => alphabet[randomInt(alphabet.length)]).join('');
      code = `${code.slice(0, 3)}-${code.slice(3)}`;
    } while (this.entries.has(code));
    this.entries.set(code, { action, requestHash: requestHash(request), data, expiresAt: this.now() + ttlMs });
    return code;
  }

  /**
   * The data of a matching code, which is then used up; or why it does not match. A code for another request
   * stays valid for its own request.
   */
  take<T>(action: string, request: unknown, code: string): { ok: true; data: T } | { ok: false; reason: string } {
    this.cleanUp();
    const key = code.trim().toUpperCase();
    const entry = this.entries.get(key);
    if (!entry) {
      return { ok: false, reason: 'Der Bestätigungscode ist unbekannt, abgelaufen oder schon benutzt.' };
    }
    if (entry.action !== action || entry.requestHash !== requestHash(request)) {
      return { ok: false, reason: 'Der Bestätigungscode gehört zu einer anderen Anfrage.' };
    }
    this.entries.delete(key);
    return { ok: true, data: entry.data as T };
  }

  private cleanUp(): void {
    for (const [code, entry] of this.entries) if (entry.expiresAt <= this.now()) this.entries.delete(code);
  }
}
