import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { UserError, toUserError } from '../../domain/errors.js';
import { fetchRemoteImage, type Resolver } from '../../images/fetchRemote.js';
import { toPreview, toStorable } from '../../images/process.js';
import type { QkDocument } from '../../questkeeper/types.js';
import { addTool, findBlock, plural, schemas, uniqueIds, type ToolContext } from '../common.js';
import { excerpt } from '../format.js';

const previewBudget = 120_000;
const maxBase64Bytes = 3 * 1024 * 1024;

export function registerImageTools(server: McpServer, context: ToolContext, options: { resolver?: Resolver } = {}): void {
  const { notes } = context;

  const store = async (document: QkDocument, data: Buffer, name: string, caption?: string) => {
    const image = await toStorable(data, name);
    const block = await notes.write(document, () =>
      notes.qk.createImageBlock(document.id, image, { markdownText: caption, visibleTo: [] }),
    );
    const preview = await toPreview(image.data, { maxEdge: 512, maxBase64Chars: 60_000 });
    return { block, image, preview };
  };

  addTool(
    server,
    'bilder_auflisten',
    {
      title: 'Bilder auflisten',
      description: 'Listet die Bildblöcke einer von Maries Notizen mit Block-ID, Bildunterschrift und Freigabe.',
      inputSchema: { dokumentId: schemas.documentId },
      annotations: { readOnlyHint: true, openWorldHint: false },
    },
    async ({ dokumentId }) => {
      const document = await notes.ownDocument(dokumentId);
      const roster = await notes.roster(document.campaignId);
      const images = document.blocks
        .map((block, index) => ({ block, index }))
        .filter(({ block }) => block.type === 'image');
      if (images.length === 0) return { text: `„${document.title}“ hat keine Bilder.` };
      const lines = [`${plural(images.length, 'Bild', 'Bilder')} in „${document.title}“ (ansehen mit bild_ansehen):`];
      for (const { block, index } of images) {
        lines.push(`- Block ${index + 1}, id ${block.id}: ${excerpt(block)} · ${roster.describeBlock(block)}`);
      }
      return { text: lines.join('\n'), log: { documentId: document.id, images: images.length } };
    },
  );

  addTool(
    server,
    'bild_ansehen',
    {
      title: 'Bild ansehen',
      description:
        'Lädt Bilder einer von Maries Notizen und zeigt sie dir als Bild (verkleinert). Ohne blockIds alle Bilder der Notiz (höchstens 6).',
      inputSchema: {
        dokumentId: schemas.documentId,
        blockIds: z.array(schemas.blockId).max(6).optional(),
        maxKante: z.number().int().min(256).max(1568).default(1024).describe('Längste Seite in Pixeln.'),
      },
      annotations: { readOnlyHint: true, openWorldHint: false },
    },
    async ({ dokumentId, blockIds, maxKante }) => {
      const document = await notes.ownDocument(dokumentId);
      const roster = await notes.roster(document.campaignId);
      const allImages = document.blocks.filter((block) => block.type === 'image');
      const chosen = blockIds?.length
        ? uniqueIds(blockIds).map((id) => {
            const block = findBlock(document, id);
            if (block.type !== 'image') throw new UserError(`Block ${id} ist kein Bild.`);
            return block;
          })
        : allImages.slice(0, 6);
      if (chosen.length === 0) return { text: `„${document.title}“ hat keine Bilder.` };
      const budget = Math.floor(previewBudget / chosen.length);
      const lines: string[] = [];
      const images: { base64: string; mimeType: string }[] = [];
      for (const [position, block] of chosen.entries()) {
        try {
          if (!block.imageUrl) throw new UserError('Der Block hat kein Bild.');
          const { data } = await notes.call(() => notes.qk.fetchImage(block.imageUrl!));
          const preview = await toPreview(data, { maxEdge: maxKante, maxBase64Chars: budget });
          images.push({ base64: preview.base64, mimeType: preview.mimeType });
          lines.push(
            `Bild ${images.length}: Block ${block.id} · ${excerpt(block)} · ${roster.describeBlock(block)} · Vorschau ${preview.width}×${preview.height}`,
          );
        } catch (error) {
          lines.push(`Block ${block.id} (${position + 1}.): nicht ladbar – ${toUserError(error).message}`);
        }
      }
      if (!blockIds?.length && allImages.length > 6) lines.push(`… und ${allImages.length - 6} weitere; gezielt mit blockIds ansehen.`);
      return { text: lines.join('\n'), images, log: { documentId: document.id, images: images.length } };
    },
  );

  addTool(
    server,
    'bild_hochladen',
    {
      title: 'Bild hochladen',
      description:
        'Hängt ein Bild als privaten Bildblock an eine von Maries Notizen: von einem öffentlichen https-Link oder als Base64 ' +
        '(nur kleine Bilder bis 3 MB). Für Bilder von Maries Gerät stattdessen bild_upload_link. Wird zu PNG/JPEG umgewandelt, ' +
        'Metadaten (z. B. GPS) werden entfernt.',
      inputSchema: {
        dokumentId: schemas.documentId,
        url: z.string().url().max(2000).optional(),
        base64: z.string().max(4_500_000).optional(),
        dateiname: z.string().max(100).optional(),
        bildunterschrift: z.string().max(5000).optional(),
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: true },
    },
    async ({ dokumentId, url, base64, dateiname, bildunterschrift }) => {
      if (Boolean(url) === Boolean(base64)) throw new UserError('Gib entweder url oder base64 an.');
      const document = await notes.ownDocument(dokumentId);
      let data: Buffer;
      if (url) {
        data = await fetchRemoteImage(url, { resolver: options.resolver });
      } else {
        const clean = base64!.replace(/^data:[^,]*,/, '').replace(/\s+/g, '');
        data = Buffer.from(clean, 'base64');
        if (data.length > maxBase64Bytes) throw new UserError('Base64 nur für kleine Bilder (bis 3 MB); sonst bild_upload_link.');
      }
      const name = dateiname?.replace(/\.[^.]+$/, '') ?? 'bild';
      const { block, image, preview } = await store(document, data, name, bildunterschrift);
      const saved = await notes.ownDocument(document.id);
      return {
        text:
          `Bild als privater Block ${block.id} in „${saved.title}“ gespeichert (${image.width}×${image.height}, ${image.mimeType}). ` +
          `Neue Version: ${saved.lastModifiedAt}.`,
        images: [{ base64: preview.base64, mimeType: preview.mimeType }],
        log: { documentId: saved.id, blockId: block.id, bytes: image.data.length },
      };
    },
  );

  addTool(
    server,
    'bild_upload_link',
    {
      title: 'Upload-Link für ein Bild',
      description:
        'Erzeugt einen Link, über den Marie ein Bild von ihrem Gerät hochladen kann. Es landet als privater Bildblock in der Notiz. ' +
        'Der Link gilt 15 Minuten und für ein Bild. Gib ihn Marie weiter.',
      inputSchema: { dokumentId: schemas.documentId, bildunterschrift: z.string().max(5000).optional() },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false },
    },
    async ({ dokumentId, bildunterschrift }) => {
      const document = await notes.ownDocument(dokumentId);
      const link = context.uploads.create(document.id, bildunterschrift);
      const until = link.expiresAt.toLocaleTimeString('de-DE', { timeZone: 'Europe/Berlin', hour: '2-digit', minute: '2-digit' });
      return {
        text:
          `Upload-Link für „${document.title}“: ${link.url}\n` +
          `Gilt bis ${until} Uhr und für ein Bild. Danach mit bilder_auflisten nachsehen.`,
        log: { documentId: document.id },
      };
    },
  );

  addTool(
    server,
    'bild_generieren',
    {
      title: 'Bild generieren',
      description:
        'Erzeugt mit einem Bildgenerator (OpenAI) ein Bild aus einer Beschreibung und speichert es als privaten Bildblock in einer von ' +
        'Maries Notizen. Du bekommst eine Vorschau. Kostet Geld und hat ein Tageslimit; nur auf Maries Wunsch benutzen.',
      inputSchema: {
        dokumentId: schemas.documentId,
        beschreibung: z.string().trim().min(3).max(4000).describe('Was das Bild zeigen soll, ausführlich.'),
        format: z.enum(['quadratisch', 'hochformat', 'querformat']).default('quadratisch'),
        qualitaet: z.enum(['niedrig', 'mittel', 'hoch']).optional(),
        bildunterschrift: z.string().max(5000).optional(),
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: true },
    },
    async ({ dokumentId, beschreibung, format, qualitaet, bildunterschrift }) => {
      if (!context.generator.enabled) throw new UserError('Bildgenerierung ist auf diesem Server nicht eingerichtet.');
      const document = await notes.ownDocument(dokumentId);
      const data = await context.generator.generate(beschreibung, format, qualitaet);
      const { block, preview } = await store(document, data, 'generiert', bildunterschrift);
      const saved = await notes.ownDocument(document.id);
      return {
        text:
          `Bild erzeugt und als privater Block ${block.id} in „${saved.title}“ gespeichert. ` +
          `Heute noch ${context.generator.remainingToday()} Bilder möglich. Neue Version: ${saved.lastModifiedAt}.`,
        images: [{ base64: preview.base64, mimeType: preview.mimeType }],
        log: { documentId: saved.id, blockId: block.id },
      };
    },
  );
}
