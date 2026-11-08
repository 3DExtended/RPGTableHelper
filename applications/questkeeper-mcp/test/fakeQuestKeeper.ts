import { randomUUID } from 'node:crypto';
import type { AddressInfo } from 'node:net';
import type { Server } from 'node:http';
import express, { type Response } from 'express';
import multer from 'multer';

/**
 * An in-memory stand-in for the Questkeeper player API (docs/external-api), with the rules that matter
 * here: who may read and change what, versions (lastModifiedAt, 409 version_conflict) and block order.
 */

export interface FakeBlock {
  id: string;
  documentId: string;
  type: 'text' | 'image';
  markdownText: string | null;
  image?: { data: Buffer; mimeType: string; file: string };
  createdByUserId: string;
  visibleTo: string[];
  createdAt: string;
  lastModifiedAt: string;
  sortIndex: number | null;
  sequence: number;
}

export interface FakeDocument {
  id: string;
  campaignId: string;
  title: string;
  groupName: string;
  createdByUserId: string;
  createdAt: string;
  lastModifiedAt: string;
  deleted: boolean;
}

export interface FakeMember {
  userId: string;
  isDm: boolean;
  characters: { id: string; name: string }[];
}

export interface FakeCampaign {
  id: string;
  name: string;
  dmUserId: string;
  members: FakeMember[];
}

export class FakeQuestKeeper {
  readonly users = new Map<string, string>();
  readonly campaigns: FakeCampaign[] = [];
  readonly documents: FakeDocument[] = [];
  readonly blocks: FakeBlock[] = [];
  readonly keys = new Map<string, string>();
  readonly requests: { method: string; path: string }[] = [];
  private tick = 0;
  private sequence = 0;
  private server?: Server;
  private pending429 = 0;
  baseUrl = '';

  /** .NET-style timestamps with 7 fractional digits, strictly increasing. */
  now(): string {
    this.tick += 1;
    const base = Date.UTC(2026, 10, 7, 10, 0, 0) + this.tick * 1000;
    const iso = new Date(base).toISOString().replace('Z', '');
    return `${iso}${String(this.tick % 10_000).padStart(4, '0')}+00:00`;
  }

  addUser(name: string, apiKey?: string): string {
    const id = randomUUID();
    this.users.set(id, name);
    if (apiKey) this.keys.set(apiKey, id);
    return id;
  }

  addCampaign(name: string, dmUserId: string, players: { userId: string; characters: string[] }[]): FakeCampaign {
    const campaign: FakeCampaign = {
      id: randomUUID(),
      name,
      dmUserId,
      members: [
        { userId: dmUserId, isDm: true, characters: [] },
        ...players.map((player) => ({
          userId: player.userId,
          isDm: false,
          characters: player.characters.map((character) => ({ id: randomUUID(), name: character })),
        })),
      ],
    };
    this.campaigns.push(campaign);
    return campaign;
  }

  addDocument(campaignId: string, ownerId: string, title: string, groupName = 'Orte'): FakeDocument {
    const at = this.now();
    const document: FakeDocument = {
      id: randomUUID(),
      campaignId,
      title,
      groupName,
      createdByUserId: ownerId,
      createdAt: at,
      lastModifiedAt: at,
      deleted: false,
    };
    this.documents.push(document);
    return document;
  }

  addText(documentId: string, authorId: string, text: string, visibleTo: string[] = []): FakeBlock {
    return this.insertBlock({ documentId, authorId, type: 'text', text, visibleTo });
  }

  addImage(documentId: string, authorId: string, data: Buffer, mimeType: string, caption: string | null, visibleTo: string[] = []): FakeBlock {
    return this.insertBlock({ documentId, authorId, type: 'image', text: caption, visibleTo, image: { data, mimeType } });
  }

  document(id: string): FakeDocument {
    const document = this.documents.find((candidate) => candidate.id === id);
    if (!document) throw new Error(`no document ${id}`);
    return document;
  }

  block(id: string): FakeBlock {
    const block = this.blocks.find((candidate) => candidate.id === id);
    if (!block) throw new Error(`no block ${id}`);
    return block;
  }

  blocksOf(documentId: string): FakeBlock[] {
    return this.blocks
      .filter((block) => block.documentId === documentId)
      .sort((a, b) => (a.sortIndex ?? -1) - (b.sortIndex ?? -1) || a.sequence - b.sequence);
  }

  /** The next request gets 429 with this Retry-After. */
  rateLimitNext(times = 1): void {
    this.pending429 = times;
  }

  async start(): Promise<string> {
    const app = this.app();
    await new Promise<void>((resolve) => {
      this.server = app.listen(0, '127.0.0.1', () => resolve());
    });
    const { port } = this.server!.address() as AddressInfo;
    this.baseUrl = `http://127.0.0.1:${port}`;
    return `${this.baseUrl}/api/external/v1`;
  }

  async stop(): Promise<void> {
    await new Promise<void>((resolve) => this.server?.close(() => resolve()));
  }

  private insertBlock(input: {
    documentId: string;
    authorId: string;
    type: 'text' | 'image';
    text: string | null;
    visibleTo: string[];
    image?: { data: Buffer; mimeType: string };
  }): FakeBlock {
    const at = this.now();
    const siblings = this.blocks.filter((block) => block.documentId === input.documentId);
    const indexed = siblings.filter((block) => block.sortIndex !== null);
    const id = randomUUID();
    const block: FakeBlock = {
      id,
      documentId: input.documentId,
      type: input.type,
      markdownText: input.text,
      image: input.image ? { ...input.image, file: `${id}.${input.image.mimeType === 'image/png' ? 'png' : 'jpg'}` } : undefined,
      createdByUserId: input.authorId,
      visibleTo: [...input.visibleTo],
      createdAt: at,
      lastModifiedAt: at,
      sortIndex: indexed.length ? Math.max(...indexed.map((b) => b.sortIndex!)) + 1 : null,
      sequence: ++this.sequence,
    };
    this.blocks.push(block);
    this.document(input.documentId).lastModifiedAt = at;
    return block;
  }

  private app() {
    const app = express();
    const upload = multer({ storage: multer.memoryStorage() });
    app.use(express.json({ limit: '10mb' }));

    app.get('/images/:file', (req, res) => {
      const block = this.blocks.find((candidate) => candidate.image?.file === req.params.file);
      if (!block?.image) return void res.status(404).end();
      res.type(block.image.mimeType).send(block.image.data);
    });

    const api = express.Router();
    api.use((req, res, next) => {
      this.requests.push({ method: req.method, path: req.path });
      if (this.pending429 > 0) {
        this.pending429--;
        res.status(429).set('Retry-After', '0').json({ error: 'rate_limited', message: 'slow down', retryAfterSeconds: 0 });
        return;
      }
      const user = this.keys.get(String(req.headers['x-api-key'] ?? ''));
      if (!user) return void res.status(401).json({ error: 'unauthorized', message: 'bad key' });
      res.locals.user = user;
      next();
    });

    const me = (res: Response) => res.locals.user as string;
    const fail = (res: Response, status: number, error: string, message: string, extra: Record<string, unknown> = {}) =>
      res.status(status).json({ error, message, ...extra });
    const memberOf = (campaignId: string, userId: string) =>
      this.campaigns.find((c) => c.id === campaignId && c.members.some((m) => m.userId === userId));
    const readable = (block: FakeBlock, userId: string) => block.createdByUserId === userId || block.visibleTo.includes(userId);
    const blockDto = (block: FakeBlock, userId: string) => ({
      id: block.id,
      type: block.type,
      markdownText: block.markdownText,
      imageUrl: block.image ? `${this.baseUrl}/images/${block.image.file}` : null,
      createdByUserId: block.createdByUserId,
      isOwn: block.createdByUserId === userId,
      visibleTo: block.createdByUserId === userId ? [...block.visibleTo] : null,
      createdAt: block.createdAt,
      lastModifiedAt: block.lastModifiedAt,
    });
    const documentDto = (document: FakeDocument, userId: string) => ({
      id: document.id,
      campaignId: document.campaignId,
      title: document.title,
      groupName: document.groupName,
      createdByUserId: document.createdByUserId,
      isOwn: document.createdByUserId === userId,
      createdAt: document.createdAt,
      lastModifiedAt: document.lastModifiedAt,
      blocks: this.blocksOf(document.id)
        .filter((block) => readable(block, userId))
        .map((block) => blockDto(block, userId)),
    });
    const visibleDocument = (id: string, userId: string) => {
      const document = this.documents.find((candidate) => candidate.id === id && !candidate.deleted);
      if (!document || !memberOf(document.campaignId, userId)) return undefined;
      if (document.createdByUserId !== userId && !this.blocksOf(id).some((block) => readable(block, userId))) return undefined;
      return document;
    };
    const conflict = (res: Response, document: FakeDocument, expected: unknown) => {
      if (expected === undefined || expected === null || expected === '') return false;
      if (Math.abs(Date.parse(String(expected)) - Date.parse(document.lastModifiedAt)) < 1) return false;
      fail(res, 409, 'version_conflict', 'The document changed since you read it.', {
        currentLastModifiedAt: document.lastModifiedAt,
      });
      return true;
    };
    const writableDocument = (res: Response, id: string) => {
      const document = visibleDocument(id, me(res));
      if (!document) return void fail(res, 404, 'not_found', 'Document not found.');
      if (document.createdByUserId !== me(res)) return void fail(res, 403, 'forbidden', 'Not your document.');
      return document;
    };
    const checkReaders = (res: Response, campaignId: string, readers: unknown, field = 'visibleTo') => {
      if (!Array.isArray(readers)) return void fail(res, 400, 'invalid_request', `${field} is required.`);
      const members = new Set(this.campaigns.find((c) => c.id === campaignId)!.members.map((m) => m.userId));
      const bad = readers.filter((id) => !members.has(String(id)));
      if (bad.length) return void fail(res, 400, 'invalid_request', 'Not in the campaign.', { problems: [`${field}: ${bad.join(', ')}`] });
      return readers.map(String);
    };
    const touch = (...ids: string[]) => {
      const at = this.now();
      for (const id of new Set(ids)) this.document(id).lastModifiedAt = at;
      return at;
    };

    api.get('/me', (_req, res) => {
      res.json({ userId: me(res), username: this.users.get(me(res)), apiKey: { prefix: 'qk_test', scopes: ['notes:read', 'notes:write', 'campaigns:read'] } });
    });

    api.get('/campaigns', (_req, res) => {
      res.json(
        this.campaigns
          .filter((campaign) => memberOf(campaign.id, me(res)))
          .map((campaign) => ({
            id: { value: campaign.id },
            campagneName: campaign.name,
            dmUserId: { value: campaign.dmUserId },
            joinCode: 'SECRET',
            rpgConfiguration: '{"big":true}',
          })),
      );
    });

    api.get('/campaigns/:id/members', (req, res) => {
      const campaign = memberOf(req.params.id, me(res));
      if (!campaign) return void fail(res, 404, 'not_found', 'Campaign not found.');
      res.json(campaign.members.map((member) => ({ ...member, isYou: member.userId === me(res) })));
    });

    api.get('/campaigns/:id/documents', (req, res) => {
      if (!memberOf(req.params.id, me(res))) return void fail(res, 404, 'not_found', 'Campaign not found.');
      res.json(
        this.documents
          .filter((document) => document.campaignId === req.params.id && visibleDocument(document.id, me(res)))
          .map((document) => documentDto(document, me(res))),
      );
    });

    api.post('/campaigns/:id/documents', (req, res) => {
      if (!memberOf(req.params.id, me(res))) return void fail(res, 404, 'not_found', 'Campaign not found.');
      const document = this.addDocument(req.params.id, me(res), req.body.title, req.body.groupName);
      res.status(201).json(documentDto(document, me(res)));
    });

    api.post('/campaigns/:id/documents/move', (req, res) => {
      if (!memberOf(req.params.id, me(res))) return void fail(res, 404, 'not_found', 'Campaign not found.');
      const groupName = String(req.body.groupName ?? '').trim();
      if (!groupName) return void fail(res, 400, 'invalid_request', 'groupName is required.');
      const documents: FakeDocument[] = [];
      for (const id of req.body.documentIds as string[]) {
        const document = writableDocument(res, id);
        if (!document) return;
        if (document.campaignId !== req.params.id) return void fail(res, 400, 'invalid_request', 'Another campaign.');
        documents.push(document);
      }
      const at = this.now();
      for (const document of documents) {
        document.groupName = groupName;
        document.lastModifiedAt = at;
      }
      res.json(documents.map((document) => documentDto(document, me(res))));
    });

    api.get('/documents/:id', (req, res) => {
      const document = visibleDocument(req.params.id, me(res));
      if (!document) return void fail(res, 404, 'not_found', 'Document not found.');
      res.json(documentDto(document, me(res)));
    });

    api.put('/documents/:id', (req, res) => {
      const document = writableDocument(res, req.params.id);
      if (!document || conflict(res, document, req.body.expectedLastModifiedAt)) return;
      document.title = req.body.title;
      document.groupName = req.body.groupName;
      touch(document.id);
      res.json(documentDto(document, me(res)));
    });

    api.delete('/documents/:id', (req, res) => {
      const document = writableDocument(res, req.params.id);
      if (!document || conflict(res, document, req.query.expectedLastModifiedAt)) return;
      document.deleted = true;
      for (const block of this.blocksOf(document.id)) this.blocks.splice(this.blocks.indexOf(block), 1);
      res.status(204).end();
    });

    api.post('/documents/:id/blocks/batch', (req, res) => {
      const document = writableDocument(res, req.params.id);
      if (!document || conflict(res, document, req.body.expectedLastModifiedAt)) return;
      const entries = req.body.blocks as { markdownText: string; visibleTo: unknown }[];
      if (!Array.isArray(entries) || entries.length < 1 || entries.length > 100) {
        return void fail(res, 400, 'invalid_request', '1 to 100 blocks.');
      }
      const readers: string[][] = [];
      for (const [index, entry] of entries.entries()) {
        const resolved = checkReaders(res, document.campaignId, entry.visibleTo, `blocks[${index}].visibleTo`);
        if (!resolved) return;
        readers.push(resolved);
      }
      const created = entries.map((entry, index) =>
        this.insertBlock({ documentId: document.id, authorId: me(res), type: 'text', text: entry.markdownText, visibleTo: readers[index]! }),
      );
      res.status(201).json(created.map((block) => blockDto(block, me(res))));
    });

    api.post('/documents/:id/image-blocks', upload.single('image'), (req, res) => {
      const document = writableDocument(res, String(req.params.id));
      if (!document) return;
      let parsed: unknown;
      try {
        parsed = JSON.parse(String(req.body.visibleTo));
      } catch {
        return void fail(res, 400, 'invalid_request', 'visibleTo must be a JSON array.');
      }
      const readers = checkReaders(res, document.campaignId, parsed);
      if (!readers) return;
      const file = req.file;
      if (!file || !['image/png', 'image/jpeg'].includes(file.mimetype) || file.size > 10 * 1024 * 1024) {
        return void fail(res, 400, 'invalid_request', 'PNG or JPEG up to 10 MB.');
      }
      const block = this.insertBlock({
        documentId: document.id,
        authorId: me(res),
        type: 'image',
        text: req.body.markdownText ?? null,
        visibleTo: readers,
        image: { data: file.buffer, mimeType: file.mimetype },
      });
      res.status(201).json(blockDto(block, me(res)));
    });

    const writableBlock = (res: Response, id: string) => {
      const block = this.blocks.find((candidate) => candidate.id === id);
      if (!block || !readable(block, me(res)) || !visibleDocument(block.documentId, me(res))) {
        return void fail(res, 404, 'not_found', 'Block not found.');
      }
      if (block.createdByUserId !== me(res)) return void fail(res, 403, 'forbidden', 'Not your block.');
      return block;
    };

    api.put('/blocks/:id', (req, res) => {
      const block = writableBlock(res, req.params.id);
      if (!block) return;
      if (block.type !== 'text') return void fail(res, 400, 'unsupported_block_type', 'Use image-blocks.');
      const document = this.document(block.documentId);
      if (conflict(res, document, req.body.expectedLastModifiedAt)) return;
      const readers = checkReaders(res, document.campaignId, req.body.visibleTo);
      if (!readers) return;
      block.markdownText = req.body.markdownText;
      block.visibleTo = readers;
      block.lastModifiedAt = touch(document.id);
      res.json(blockDto(block, me(res)));
    });

    api.put('/image-blocks/:id', (req, res) => {
      const block = writableBlock(res, req.params.id);
      if (!block) return;
      if (block.type !== 'image') return void fail(res, 400, 'unsupported_block_type', 'Use blocks.');
      const document = this.document(block.documentId);
      if (conflict(res, document, req.body.expectedLastModifiedAt)) return;
      const readers = checkReaders(res, document.campaignId, req.body.visibleTo);
      if (!readers) return;
      block.markdownText = req.body.markdownText ?? null;
      block.visibleTo = readers;
      block.lastModifiedAt = touch(document.id);
      res.json(blockDto(block, me(res)));
    });

    api.delete('/blocks/:id', (req, res) => {
      const block = writableBlock(res, req.params.id);
      if (!block) return;
      const document = this.document(block.documentId);
      if (conflict(res, document, req.query.expectedLastModifiedAt)) return;
      this.blocks.splice(this.blocks.indexOf(block), 1);
      touch(document.id);
      res.status(204).end();
    });

    api.put('/documents/:id/block-order', (req, res) => {
      const document = writableDocument(res, req.params.id);
      if (!document || conflict(res, document, req.body.expectedLastModifiedAt)) return;
      const ids = (req.body.blockIds as string[]) ?? [];
      if (new Set(ids).size !== ids.length) return void fail(res, 400, 'invalid_request', 'Duplicates.');
      const current = this.blocksOf(document.id);
      const missing = current.filter((block) => readable(block, me(res)) && !ids.includes(block.id));
      if (missing.length) return void fail(res, 400, 'invalid_request', 'Every readable block must be listed.');
      const touched = new Set([document.id]);
      const listed: FakeBlock[] = [];
      for (const id of ids) {
        const block = this.blocks.find((candidate) => candidate.id === id);
        if (!block) return void fail(res, 400, 'invalid_request', `Unknown block ${id}.`);
        if (block.documentId !== document.id) {
          const source = this.document(block.documentId);
          if (block.createdByUserId !== me(res) || source.createdByUserId !== me(res) || source.deleted) {
            return void fail(res, 400, 'invalid_request', 'Only your blocks from your documents.');
          }
          if (source.campaignId !== document.campaignId) return void fail(res, 400, 'invalid_request', 'Another campaign.');
          touched.add(source.id);
        }
        listed.push(block);
      }
      const hidden = current.filter((block) => !readable(block, me(res)));
      [...listed, ...hidden].forEach((block, index) => {
        block.documentId = document.id;
        block.sortIndex = index;
      });
      touch(...touched);
      res.json(documentDto(document, me(res)));
    });

    app.use('/api/external/v1', api);
    return app;
  }
}
