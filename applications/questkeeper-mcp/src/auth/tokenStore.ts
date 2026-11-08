import { createHash, randomBytes } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

/**
 * Access and refresh tokens, kept as SHA-256 hashes in DATA_DIR/auth-store.json.
 *
 * One login starts a "family": its refresh token is replaced on every use, and if an old one comes back
 * (someone copied it) the whole family is revoked. `npm run cli -- abmelden` writes DATA_DIR/abgemeldet-vor;
 * every family that started before that moment is invalid at once, also while the server runs.
 */

interface Family {
  clientId: string;
  scope: string;
  createdAt: number;
  refreshHash: string;
  refreshExpiresAt: number;
  usedRefreshHashes: string[];
}

interface AccessEntry {
  familyId: string;
  expiresAt: number;
}

interface StoreFile {
  version: 1;
  families: Record<string, Family>;
  access: Record<string, AccessEntry>;
}

export interface IssuedTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  scope: string;
  familyId: string;
}

export const REVOKED_BEFORE_FILE = 'abgemeldet-vor';

export function sha256(value: string): string {
  return createHash('sha256').update(value).digest('base64url');
}

function newToken(prefix: string): string {
  return `${prefix}_${randomBytes(32).toString('base64url')}`;
}

export class TokenStore {
  private readonly file: string;
  private readonly revokedFile: string;
  private data: StoreFile = { version: 1, families: {}, access: {} };
  private revokedBefore = 0;
  private revokedMtime = -1;

  constructor(
    dataDir: string,
    private readonly options: { accessTtlSeconds: number; refreshTtlDays: number },
    private readonly now: () => number = Date.now,
  ) {
    fs.mkdirSync(dataDir, { recursive: true });
    this.file = path.join(dataDir, 'auth-store.json');
    this.revokedFile = path.join(dataDir, REVOKED_BEFORE_FILE);
    if (fs.existsSync(this.file)) {
      const parsed = JSON.parse(fs.readFileSync(this.file, 'utf8')) as StoreFile;
      if (parsed.version === 1) this.data = parsed;
    }
  }

  issue(clientId: string, scope: string): IssuedTokens {
    const familyId = randomBytes(12).toString('base64url');
    const refreshToken = newToken('qkr');
    this.data.families[familyId] = {
      clientId,
      scope,
      createdAt: this.now(),
      refreshHash: sha256(refreshToken),
      refreshExpiresAt: this.now() + this.options.refreshTtlDays * 86_400_000,
      usedRefreshHashes: [],
    };
    return this.issueAccess(familyId, refreshToken);
  }

  /** A new token pair for a valid refresh token; null (and the family revoked if it was reused) otherwise. */
  refresh(refreshToken: string, clientId: string): IssuedTokens | null {
    this.loadRevocation();
    const hash = sha256(refreshToken);
    for (const [familyId, family] of Object.entries(this.data.families)) {
      if (family.usedRefreshHashes.includes(hash)) {
        this.revokeFamily(familyId);
        return null;
      }
      if (family.refreshHash !== hash) continue;
      if (family.clientId !== clientId || !this.isFamilyActive(family)) return null;
      const next = newToken('qkr');
      family.usedRefreshHashes = [...family.usedRefreshHashes.slice(-19), hash];
      family.refreshHash = sha256(next);
      family.refreshExpiresAt = this.now() + this.options.refreshTtlDays * 86_400_000;
      for (const [accessHash, entry] of Object.entries(this.data.access)) {
        if (entry.familyId === familyId) delete this.data.access[accessHash];
      }
      return this.issueAccess(familyId, next);
    }
    return null;
  }

  validateAccess(accessToken: string): { familyId: string; clientId: string } | null {
    this.loadRevocation();
    const entry = this.data.access[sha256(accessToken)];
    if (!entry || entry.expiresAt <= this.now()) return null;
    const family = this.data.families[entry.familyId];
    if (!family || !this.isFamilyActive(family)) return null;
    return { familyId: entry.familyId, clientId: family.clientId };
  }

  revokeFamily(familyId: string): void {
    delete this.data.families[familyId];
    for (const [hash, entry] of Object.entries(this.data.access)) {
      if (entry.familyId === familyId) delete this.data.access[hash];
    }
    this.save();
  }

  activeFamilies(): number {
    this.loadRevocation();
    return Object.values(this.data.families).filter((family) => this.isFamilyActive(family)).length;
  }

  private issueAccess(familyId: string, refreshToken: string): IssuedTokens {
    const accessToken = newToken('qka');
    this.data.access[sha256(accessToken)] = {
      familyId,
      expiresAt: this.now() + this.options.accessTtlSeconds * 1000,
    };
    this.prune();
    this.save();
    const family = this.data.families[familyId]!;
    return { accessToken, refreshToken, expiresIn: this.options.accessTtlSeconds, scope: family.scope, familyId };
  }

  private isFamilyActive(family: Family): boolean {
    return family.refreshExpiresAt > this.now() && family.createdAt >= this.revokedBefore;
  }

  private loadRevocation(): void {
    let mtime: number;
    try {
      mtime = fs.statSync(this.revokedFile).mtimeMs;
    } catch {
      return;
    }
    if (mtime === this.revokedMtime) return;
    this.revokedMtime = mtime;
    const value = Number(fs.readFileSync(this.revokedFile, 'utf8').trim());
    if (Number.isFinite(value)) this.revokedBefore = value;
  }

  private prune(): void {
    for (const [hash, entry] of Object.entries(this.data.access)) {
      if (entry.expiresAt <= this.now() || !this.data.families[entry.familyId]) delete this.data.access[hash];
    }
    for (const [familyId, family] of Object.entries(this.data.families)) {
      if (!this.isFamilyActive(family)) delete this.data.families[familyId];
    }
  }

  private save(): void {
    const temporary = `${this.file}.${process.pid}.tmp`;
    fs.writeFileSync(temporary, JSON.stringify(this.data), { mode: 0o600 });
    fs.renameSync(temporary, this.file);
  }
}

/** For `npm run cli -- abmelden`: every login before now stops working. */
export function revokeAllLogins(dataDir: string, now: number = Date.now()): void {
  fs.mkdirSync(dataDir, { recursive: true });
  fs.writeFileSync(path.join(dataDir, REVOKED_BEFORE_FILE), `${now}\n`, { mode: 0o600 });
}
