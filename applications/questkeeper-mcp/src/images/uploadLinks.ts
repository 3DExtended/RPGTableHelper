import { randomBytes } from 'node:crypto';
import express, { type Response, type Router } from 'express';
import multer from 'multer';
import { escapeHtml, page } from '../auth/pages.js';
import { UserError } from '../domain/errors.js';
import type { NotesService } from '../domain/notes.js';
import { log } from '../log.js';
import { maxInputBytes, toStorable } from './process.js';

/**
 * One-time upload pages: Claude hands Marie a link, she picks a file on her device, it becomes a private
 * image block of the note. A link works once and for 15 minutes; the token is the only key, so it is never
 * logged.
 */

interface UploadLink {
  documentId: string;
  caption?: string;
  expiresAt: number;
}

const ttlMs = 15 * 60_000;

export class UploadLinks {
  private readonly links = new Map<string, UploadLink>();

  constructor(
    private readonly baseUrl: string,
    private readonly now: () => number = Date.now,
  ) {}

  create(documentId: string, caption?: string): { url: string; expiresAt: Date } {
    this.cleanUp();
    const token = randomBytes(24).toString('base64url');
    const expiresAt = this.now() + ttlMs;
    this.links.set(token, { documentId, caption, expiresAt });
    return { url: `${this.baseUrl}/upload/${token}`, expiresAt: new Date(expiresAt) };
  }

  peek(token: string): UploadLink | undefined {
    this.cleanUp();
    return this.links.get(token);
  }

  consume(token: string): void {
    this.links.delete(token);
  }

  /** Gives a link back after a failed upload, so Marie can try again while it is still valid. */
  restore(token: string, link: UploadLink): void {
    if (link.expiresAt > this.now()) this.links.set(token, link);
  }

  private cleanUp(): void {
    for (const [token, link] of this.links) if (link.expiresAt <= this.now()) this.links.delete(token);
  }
}

function headers(res: Response): void {
  res.set({
    'Content-Security-Policy': "default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; frame-ancestors 'none'; base-uri 'none'",
    'X-Frame-Options': 'DENY',
    'X-Content-Type-Options': 'nosniff',
    'Referrer-Policy': 'no-referrer',
    'Cache-Control': 'no-store',
  });
}

const gone = () =>
  page(
    'Link abgelaufen',
    '<h1>Dieser Link gilt nicht mehr</h1><p>Upload-Links gelten 15 Minuten und nur einmal. Bitte Claude um einen neuen.</p>',
  );

export function createUploadRouter(links: UploadLinks, notes: NotesService): Router {
  const router = express.Router();
  const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: maxInputBytes, files: 1, fields: 5 } });

  router.get('/upload/:token', async (req, res) => {
    headers(res);
    const link = links.peek(req.params.token);
    if (!link) {
      res.status(410).type('html').send(gone());
      return;
    }
    let title = 'deine Notiz';
    try {
      title = `„${(await notes.ownDocument(link.documentId)).title}“`;
    } catch {
      res.status(410).type('html').send(gone());
      return;
    }
    res.type('html').send(
      page(
        'Bild hochladen',
        `<h1>Bild hochladen</h1>
         <p>Das Bild kommt als <strong>privater</strong> Bildblock in ${escapeHtml(title)}.</p>
         <form method="post" enctype="multipart/form-data" action="${escapeHtml(req.params.token)}">
           <label for="bild">Bild (PNG, JPEG, WebP, HEIC …, bis 15 MB)</label>
           <input id="bild" name="bild" type="file" accept="image/*" required>
           <div class="actions"><button class="primary" type="submit">Hochladen</button></div>
         </form>
         <p class="muted">Der Link gilt bis ${escapeHtml(new Date(link.expiresAt).toLocaleTimeString('de-DE', { timeZone: 'Europe/Berlin', hour: '2-digit', minute: '2-digit' }))} Uhr und nur für ein Bild.</p>`,
      ),
    );
  });

  router.post('/upload/:token', (req, res) => {
    headers(res);
    const token = req.params.token;
    const link = links.peek(token);
    if (!link) {
      res.status(410).type('html').send(gone());
      return;
    }
    upload.single('bild')(req, res, async (error: unknown) => {
      const fail = (status: number, message: string) =>
        res
          .status(status)
          .type('html')
          .send(page('Hochladen fehlgeschlagen', `<h1>Das hat nicht geklappt</h1><p class="error">${escapeHtml(message)}</p><p><a href="${escapeHtml(token)}">Noch einmal versuchen</a></p>`));
      if (error) {
        fail(413, 'Die Datei ist zu groß (höchstens 15 MB).');
        return;
      }
      const file = req.file;
      if (!file) {
        fail(400, 'Es wurde keine Datei mitgeschickt.');
        return;
      }
      let consumed = false;
      try {
        // Checked again now: the note must still be Marie's.
        const document = await notes.ownDocument(link.documentId);
        const image = await toStorable(file.buffer, file.originalname.replace(/\.[^.]+$/, ''));
        // Take the link before the slow upload, so a double submit cannot store the image twice.
        links.consume(token);
        consumed = true;
        await notes.write(document, () =>
          notes.qk.createImageBlock(document.id, image, { markdownText: link.caption, visibleTo: [] }),
        );
        log.info('upload.stored', { documentId: document.id, bytes: image.data.length });
        res.type('html').send(
          page(
            'Hochgeladen',
            `<h1>Fertig</h1><p>Das Bild ist jetzt als privater Block in ${escapeHtml(`„${document.title}“`)}. Du kannst dieses Fenster schließen und Claude Bescheid geben.</p>`,
          ),
        );
      } catch (problem) {
        if (consumed) links.restore(token, link);
        const message = problem instanceof UserError ? problem.message : 'Unerwarteter Fehler beim Speichern.';
        log.warn('upload.failed', { errorName: (problem as Error).name });
        fail(400, message);
      }
    });
  });

  return router;
}
