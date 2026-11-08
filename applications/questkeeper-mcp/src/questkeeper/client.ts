import { log } from '../log.js';
import type { QkBlock, QkCampaign, QkDocument, QkErrorBody, QkMe, QkMember } from './types.js';

type FetchLike = typeof fetch;

/** An error answer of the Questkeeper API. `code` is its machine-readable error, e.g. version_conflict. */
export class QkApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
    readonly problems: string[] = [],
    readonly currentLastModifiedAt?: string,
  ) {
    super(message);
    this.name = 'QkApiError';
  }
}

interface RequestOptions {
  json?: unknown;
  form?: FormData;
  query?: Record<string, string | undefined>;
}

const maxImageBytes = 20 * 1024 * 1024;

function idValue(value: unknown): string {
  if (typeof value === 'string') return value;
  if (value && typeof value === 'object' && 'value' in value) return String((value as { value: unknown }).value);
  return '';
}

export class QuestKeeperClient {
  private readonly imageOrigins: Set<string>;

  constructor(
    private readonly baseUrl: string,
    private readonly apiKey: string,
    options: { imageOrigins?: string[]; fetchImpl?: FetchLike; maxRetryWaitSeconds?: number } = {},
  ) {
    this.fetchImpl = options.fetchImpl ?? fetch;
    this.maxRetryWaitSeconds = options.maxRetryWaitSeconds ?? 30;
    this.imageOrigins = new Set([new URL(baseUrl).origin, ...(options.imageOrigins ?? []).map((o) => new URL(o).origin)]);
  }

  private readonly fetchImpl: FetchLike;
  private readonly maxRetryWaitSeconds: number;

  me(): Promise<QkMe> {
    return this.request('GET', '/me');
  }

  async campaigns(): Promise<QkCampaign[]> {
    const raw = await this.request<Record<string, unknown>[]>('GET', '/campaigns');
    return raw.map((campaign) => ({
      id: idValue(campaign.id),
      name: String(campaign.campagneName ?? campaign.name ?? ''),
      dmUserId: idValue(campaign.dmUserId) || undefined,
    }));
  }

  members(campaignId: string): Promise<QkMember[]> {
    return this.request('GET', `/campaigns/${encodeURIComponent(campaignId)}/members`);
  }

  documents(campaignId: string): Promise<QkDocument[]> {
    return this.request('GET', `/campaigns/${encodeURIComponent(campaignId)}/documents`);
  }

  document(documentId: string): Promise<QkDocument> {
    return this.request('GET', `/documents/${encodeURIComponent(documentId)}`);
  }

  createDocument(campaignId: string, body: { title: string; groupName: string }): Promise<QkDocument> {
    return this.request('POST', `/campaigns/${encodeURIComponent(campaignId)}/documents`, { json: body });
  }

  updateDocument(
    documentId: string,
    body: { title: string; groupName: string; expectedLastModifiedAt?: string },
  ): Promise<QkDocument> {
    return this.request('PUT', `/documents/${encodeURIComponent(documentId)}`, { json: body });
  }

  deleteDocument(documentId: string, expectedLastModifiedAt?: string): Promise<void> {
    return this.request('DELETE', `/documents/${encodeURIComponent(documentId)}`, {
      query: { expectedLastModifiedAt },
    });
  }

  createTextBlocks(
    documentId: string,
    blocks: { markdownText: string; visibleTo: string[] }[],
    expectedLastModifiedAt?: string,
  ): Promise<QkBlock[]> {
    return this.request('POST', `/documents/${encodeURIComponent(documentId)}/blocks/batch`, {
      json: { blocks, expectedLastModifiedAt },
    });
  }

  updateTextBlock(
    blockId: string,
    body: { markdownText: string; visibleTo: string[]; expectedLastModifiedAt?: string },
  ): Promise<QkBlock> {
    return this.request('PUT', `/blocks/${encodeURIComponent(blockId)}`, { json: body });
  }

  createImageBlock(
    documentId: string,
    image: { data: Buffer; mimeType: 'image/png' | 'image/jpeg'; fileName: string },
    body: { markdownText?: string; visibleTo: string[] },
  ): Promise<QkBlock> {
    const form = new FormData();
    form.set('image', new Blob([new Uint8Array(image.data)], { type: image.mimeType }), image.fileName);
    form.set('visibleTo', JSON.stringify(body.visibleTo));
    if (body.markdownText) form.set('markdownText', body.markdownText);
    return this.request('POST', `/documents/${encodeURIComponent(documentId)}/image-blocks`, { form });
  }

  updateImageBlock(
    blockId: string,
    body: { markdownText?: string | null; visibleTo: string[]; expectedLastModifiedAt?: string },
  ): Promise<QkBlock> {
    return this.request('PUT', `/image-blocks/${encodeURIComponent(blockId)}`, { json: body });
  }

  deleteBlock(blockId: string, expectedLastModifiedAt?: string): Promise<void> {
    return this.request('DELETE', `/blocks/${encodeURIComponent(blockId)}`, { query: { expectedLastModifiedAt } });
  }

  arrangeBlocks(documentId: string, blockIds: string[], expectedLastModifiedAt?: string): Promise<QkDocument> {
    return this.request('PUT', `/documents/${encodeURIComponent(documentId)}/block-order`, {
      json: { blockIds, expectedLastModifiedAt },
    });
  }

  moveDocuments(campaignId: string, documentIds: string[], groupName: string): Promise<QkDocument[]> {
    return this.request('POST', `/campaigns/${encodeURIComponent(campaignId)}/documents/move`, {
      json: { documentIds, groupName },
    });
  }

  /** Loads an image of a block. Only from the API's own origin (or QK_IMAGE_ORIGINS), never with the API key. */
  async fetchImage(url: string): Promise<{ data: Buffer; contentType: string }> {
    let parsed: URL;
    try {
      parsed = new URL(url);
    } catch {
      throw new QkApiError(400, 'bad_image_url', 'Das Bild hat keine gültige Adresse.');
    }
    if (!this.imageOrigins.has(parsed.origin)) {
      throw new QkApiError(400, 'bad_image_url', 'Das Bild liegt nicht auf dem Questkeeper-Server.');
    }
    const response = await this.fetchImpl(parsed, { redirect: 'error', signal: AbortSignal.timeout(30_000) });
    if (!response.ok) throw new QkApiError(response.status, 'image_unavailable', 'Das Bild ist nicht abrufbar.');
    const length = Number(response.headers.get('content-length') ?? 0);
    if (length > maxImageBytes) throw new QkApiError(413, 'image_too_large', 'Das Bild ist zu groß.');
    const data = Buffer.from(await response.arrayBuffer());
    if (data.length > maxImageBytes) throw new QkApiError(413, 'image_too_large', 'Das Bild ist zu groß.');
    return { data, contentType: response.headers.get('content-type') ?? '' };
  }

  private async request<T>(method: string, path: string, options: RequestOptions = {}): Promise<T> {
    const url = new URL(`${this.baseUrl}${path}`);
    for (const [key, value] of Object.entries(options.query ?? {})) {
      if (value !== undefined) url.searchParams.set(key, value);
    }
    const headers: Record<string, string> = { 'X-Api-Key': this.apiKey, Accept: 'application/json' };
    let body: string | FormData | undefined;
    if (options.json !== undefined) {
      headers['Content-Type'] = 'application/json';
      body = JSON.stringify(options.json);
    } else if (options.form) {
      body = options.form;
    }

    for (let attempt = 1; ; attempt++) {
      const started = Date.now();
      let response: Response;
      try {
        response = await this.fetchImpl(url, { method, headers, body, signal: AbortSignal.timeout(30_000) });
      } catch (error) {
        log.warn('qk.request_failed', { method, path: pathTemplate(path), errorName: (error as Error).name });
        throw new QkApiError(503, 'unreachable', 'Questkeeper ist gerade nicht erreichbar.');
      }
      log.debug('qk.request', { method, path: pathTemplate(path), httpStatus: response.status, ms: Date.now() - started });

      if (response.status === 429 && attempt <= 2) {
        const retryAfter = Number(response.headers.get('retry-after') ?? '5');
        if (Number.isFinite(retryAfter) && retryAfter <= this.maxRetryWaitSeconds) {
          log.info('qk.rate_limited', { retryAfter, attempt });
          await new Promise((resolve) => setTimeout(resolve, Math.max(retryAfter, 0) * 1000));
          continue;
        }
      }
      if (response.status === 204) return undefined as T;
      const text = await response.text();
      if (response.ok) return (text ? JSON.parse(text) : undefined) as T;

      let error: QkErrorBody = {};
      try {
        error = JSON.parse(text) as QkErrorBody;
      } catch {
        // not JSON
      }
      log.info('qk.error', { method, path: pathTemplate(path), httpStatus: response.status, code: error.error });
      throw new QkApiError(
        response.status,
        error.error ?? `http_${response.status}`,
        error.message ?? `Questkeeper answered ${response.status}.`,
        error.problems ?? [],
        error.currentLastModifiedAt,
      );
    }
  }
}

/** /documents/<id>/blocks -> /documents/:id/blocks, for logs. */
function pathTemplate(path: string): string {
  return path.replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi, ':id');
}
