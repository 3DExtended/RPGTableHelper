import { QkApiError, type QuestKeeperClient } from '../questkeeper/client.js';
import type { QkCampaign, QkDocument, QkMe } from '../questkeeper/types.js';
import { NotFoundError, UserError, VersionConflictError, toUserError } from './errors.js';
import { fold } from './search.js';
import { Roster } from './visibility.js';

/**
 * Marie's view of Questkeeper: only campaigns she may use here and only documents she wrote herself.
 * Every call loads documents fresh from the API, so ownership and versions are checked on every action,
 * not only when listing. Campaigns and members are cached for a minute.
 */
export class NotesService {
  private meCache?: { value: QkMe; until: number };
  private campaignCache?: { value: QkCampaign[]; until: number };
  private readonly rosterCache = new Map<string, { value: Roster; until: number }>();

  constructor(
    readonly qk: QuestKeeperClient,
    private readonly options: { campaignIds: string[] },
    private readonly now: () => number = Date.now,
  ) {}

  async me(): Promise<QkMe> {
    if (this.meCache && this.meCache.until > this.now()) return this.meCache.value;
    const value = await this.call(() => this.qk.me());
    this.meCache = { value, until: this.now() + 10 * 60_000 };
    return value;
  }

  async campaigns(): Promise<QkCampaign[]> {
    if (this.campaignCache && this.campaignCache.until > this.now()) return this.campaignCache.value;
    const allowed = new Set(this.options.campaignIds.map((id) => id.toLowerCase()));
    const all = await this.call(() => this.qk.campaigns());
    const value = all
      .filter((campaign) => campaign.id && (allowed.size === 0 || allowed.has(campaign.id.toLowerCase())))
      .sort((a, b) => a.name.localeCompare(b.name, 'de'));
    this.campaignCache = { value, until: this.now() + 60_000 };
    return value;
  }

  /** A campaign by id or name; without input the only one there is. */
  async campaign(input?: string): Promise<QkCampaign> {
    const campaigns = await this.campaigns();
    if (campaigns.length === 0) throw new UserError('Für diesen Zugang ist keine Kampagne freigegeben.');
    if (!input?.trim()) {
      if (campaigns.length === 1) return campaigns[0]!;
      throw new UserError(
        `Du bist in mehreren Kampagnen. Gib „kampagne“ an: ${campaigns.map((c) => `„${c.name}“`).join(', ')}.`,
      );
    }
    const wanted = fold(input.trim());
    const exact = campaigns.filter((c) => c.id.toLowerCase() === wanted || fold(c.name) === wanted);
    const found = exact.length ? exact : campaigns.filter((c) => fold(c.name).includes(wanted));
    if (found.length === 1) return found[0]!;
    if (found.length > 1) {
      throw new UserError(`„${input}“ passt auf mehrere Kampagnen: ${found.map((c) => `„${c.name}“`).join(', ')}.`);
    }
    throw new UserError(`Kampagne „${input}“ nicht gefunden. Möglich: ${campaigns.map((c) => `„${c.name}“`).join(', ')}.`);
  }

  async campaignById(campaignId: string): Promise<QkCampaign> {
    const campaign = (await this.campaigns()).find((c) => c.id.toLowerCase() === campaignId.toLowerCase());
    if (!campaign) throw new NotFoundError('Kampagne');
    return campaign;
  }

  async roster(campaignId: string): Promise<Roster> {
    const cached = this.rosterCache.get(campaignId);
    if (cached && cached.until > this.now()) return cached.value;
    const members = await this.call(() => this.qk.members(campaignId));
    const value = new Roster(members);
    this.rosterCache.set(campaignId, { value, until: this.now() + 60_000 });
    return value;
  }

  /** Marie's documents of a campaign, with their blocks. */
  async ownDocuments(campaignId: string): Promise<QkDocument[]> {
    await this.campaignById(campaignId);
    const documents = await this.call(() => this.qk.documents(campaignId));
    return documents.filter((document) => document.isOwn);
  }

  /** One of Marie's documents; anything else (someone else's, other campaign, deleted) is "not found". */
  async ownDocument(documentId: string): Promise<QkDocument> {
    let document: QkDocument;
    try {
      document = await this.qk.document(documentId);
    } catch (error) {
      if (error instanceof QkApiError && (error.status === 404 || error.status === 403)) {
        throw new NotFoundError(`Notiz ${documentId}`);
      }
      throw toUserError(error);
    }
    if (!document.isOwn) throw new NotFoundError(`Notiz ${documentId}`);
    const allowed = (await this.campaigns()).some((c) => c.id.toLowerCase() === document.campaignId.toLowerCase());
    if (!allowed) throw new NotFoundError(`Notiz ${documentId}`);
    return document;
  }

  async ownDocumentsByIds(documentIds: string[]): Promise<QkDocument[]> {
    const unique = [...new Set(documentIds.map((id) => id.toLowerCase()))];
    const documents: QkDocument[] = [];
    for (const id of unique) documents.push(await this.ownDocument(id));
    return documents;
  }

  /** Runs an API call and turns its errors into messages for Claude. */
  async call<T>(action: () => Promise<T>, context = ''): Promise<T> {
    try {
      return await action();
    } catch (error) {
      throw toUserError(error, context);
    }
  }

  /** Runs a write that names the document's version; a 409 becomes a clear conflict message. */
  async write<T>(document: QkDocument, action: () => Promise<T>): Promise<T> {
    try {
      return await action();
    } catch (error) {
      if (error instanceof QkApiError && error.code === 'version_conflict') {
        throw new VersionConflictError(document.title, error.currentLastModifiedAt);
      }
      throw toUserError(error, `„${document.title}“`);
    }
  }
}

/** Versions are the API's lastModifiedAt strings; equal if they name the same millisecond. */
export function sameVersion(a: string, b: string): boolean {
  if (a.trim() === b.trim()) return true;
  const left = Date.parse(a);
  const right = Date.parse(b);
  return Number.isFinite(left) && Number.isFinite(right) && Math.abs(left - right) < 1;
}

export function assertVersion(document: QkDocument, version: string | undefined): void {
  if (version === undefined) return;
  if (!sameVersion(document.lastModifiedAt, version)) {
    throw new VersionConflictError(document.title, document.lastModifiedAt);
  }
}
