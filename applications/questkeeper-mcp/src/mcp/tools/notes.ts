import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { UserError, toUserError } from '../../domain/errors.js';
import { assertVersion } from '../../domain/notes.js';
import { readersOf } from '../../domain/visibility.js';
import { QkApiError } from '../../questkeeper/client.js';
import type { QkBlock } from '../../questkeeper/types.js';
import { detectImageKind, toStorable } from '../../images/process.js';
import { addTool, confirmationHint, confirmStep, plural, schemas, type ToolContext } from '../common.js';
import { documentStats, sharedCount } from '../format.js';

const batchSize = 100;

export function registerNoteTools(server: McpServer, context: ToolContext): void {
  const { notes } = context;

  addTool(
    server,
    'notiz_anlegen',
    {
      title: 'Notiz anlegen',
      description:
        'Legt eine neue Notiz in einer Gruppe an, optional gleich mit Textblöcken (Markdown, je Eintrag ein Block). ' +
        'Alle neuen Blöcke sind privat. Auch für ein großes, selbst geschriebenes Gesamtdokument geeignet.',
      inputSchema: {
        titel: schemas.title,
        gruppe: schemas.groupName.describe('Gruppe (Ordner); eine neue Gruppe entsteht damit automatisch.'),
        bloecke: z.array(schemas.markdown).max(300).optional().describe('Textblöcke in Markdown, in dieser Reihenfolge.'),
        kampagne: schemas.campaign,
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false },
    },
    async ({ titel, gruppe, bloecke, kampagne }) => {
      const campaign = await notes.campaign(kampagne);
      const document = await notes.call(() => notes.qk.createDocument(campaign.id, { title: titel, groupName: gruppe }));
      const texts = bloecke ?? [];
      for (let start = 0; start < texts.length; start += batchSize) {
        const chunk = texts.slice(start, start + batchSize).map((markdownText) => ({ markdownText, visibleTo: [] }));
        try {
          await notes.qk.createTextBlocks(document.id, chunk);
        } catch (error) {
          throw new UserError(
            `Die Notiz „${titel}“ (id ${document.id}) ist angelegt, aber nur ${start} von ${texts.length} Blöcken wurden gespeichert: ` +
              toUserError(error).message,
          );
        }
      }
      const saved = await notes.ownDocument(document.id);
      return {
        text:
          `Notiz „${saved.title}“ in Gruppe „${saved.groupName}“ angelegt (id ${saved.id}, Version ${saved.lastModifiedAt}). ` +
          `${plural(texts.length, 'privater Block', 'private Blöcke')}.`,
        log: { campaignId: campaign.id, documentId: saved.id, blocks: texts.length },
      };
    },
  );

  addTool(
    server,
    'notiz_umbenennen',
    {
      title: 'Notiz umbenennen',
      description: 'Gibt einer von Maries Notizen einen neuen Titel. Gruppe und Blöcke bleiben, wie sie sind.',
      inputSchema: { dokumentId: schemas.documentId, neuerTitel: schemas.title, version: schemas.version },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    },
    async ({ dokumentId, neuerTitel, version }) => {
      const document = await notes.ownDocument(dokumentId);
      assertVersion(document, version);
      const saved = await notes.write(document, () =>
        notes.qk.updateDocument(document.id, {
          title: neuerTitel,
          groupName: document.groupName,
          expectedLastModifiedAt: version,
        }),
      );
      return {
        text: `„${document.title}“ heißt jetzt „${saved.title}“. Neue Version: ${saved.lastModifiedAt}.`,
        log: { documentId: document.id },
      };
    },
  );

  addTool(
    server,
    'notizen_loeschen',
    {
      title: 'Notizen löschen',
      description:
        'Löscht eine oder mehrere von Maries Notizen samt ihrer Blöcke. Zwei Schritte: Der erste Aufruf (ohne bestaetigung) ' +
        'zeigt nur, was gelöscht würde, und gibt einen Code. Erst wenn Marie ausdrücklich zustimmt, mit dem Code erneut aufrufen. ' +
        'Hat sich eine Notiz dazwischen geändert, bleibt sie stehen.',
      inputSchema: {
        dokumentIds: z.array(schemas.documentId).min(1).max(50),
        bestaetigung: schemas.confirmation,
      },
      annotations: { readOnlyHint: false, destructiveHint: true, idempotentHint: false, openWorldHint: false },
    },
    async ({ dokumentIds, bestaetigung }) => {
      const documents = await notes.ownDocumentsByIds(dokumentIds);
      const request = { ids: documents.map((document) => document.id).sort() };
      const versions = Object.fromEntries(documents.map((document) => [document.id, document.lastModifiedAt]));
      const step = confirmStep(context, 'notizen_loeschen', request, bestaetigung, versions);

      if (!step.confirmed) {
        const lines = [`Das würde ${plural(documents.length, 'Notiz', 'Notizen')} endgültig löschen:`];
        for (const document of documents) {
          lines.push(`- „${document.title}“ (Gruppe „${document.groupName}“): ${documentStats(document)}`);
          if (sharedCount(document) > 0) {
            lines.push(`  Achtung: ${sharedCount(document)} Blöcke sind geteilt; auch die Leser verlieren sie.`);
          }
        }
        return {
          text: lines.join('\n') + confirmationHint(step.code, 'Soll das wirklich gelöscht werden?'),
          log: { documentIds: request.ids, outcome: 'preview' },
        };
      }

      const deleted: string[] = [];
      const kept: string[] = [];
      for (const document of documents) {
        try {
          await notes.qk.deleteDocument(document.id, step.data[document.id]);
          deleted.push(`„${document.title}“`);
        } catch (error) {
          const reason =
            error instanceof QkApiError && error.code === 'version_conflict'
              ? 'inzwischen geändert, daher nicht gelöscht'
              : toUserError(error).message;
          kept.push(`„${document.title}“ (${reason})`);
        }
      }
      const text = [
        deleted.length ? `Gelöscht: ${deleted.join(', ')}.` : 'Nichts gelöscht.',
        kept.length ? `Nicht gelöscht: ${kept.join('; ')}.` : '',
      ]
        .filter(Boolean)
        .join('\n');
      return { text, log: { documentIds: request.ids, count: deleted.length } };
    },
  );

  addTool(
    server,
    'gesamtdokument_erstellen',
    {
      title: 'Gesamtdokument erstellen',
      description:
        'Fasst mehrere von Maries Notizen zu einer neuen Notiz zusammen: Text- und Bildblöcke werden in Reihenfolge kopiert, ' +
        'optional mit einer Überschrift je Quelle und einer Einleitung. Die Quellen bleiben unverändert. Alle Kopien sind privat, ' +
        'außer mit freigabenUebernehmen: dann bekommt jede Kopie genau die Freigabe ihres Originals (Überschriften und Einleitung bleiben privat). ' +
        'Für ein selbst geschriebenes Gesamtdokument stattdessen notiz_anlegen nutzen.',
      inputSchema: {
        titel: schemas.title,
        gruppe: schemas.groupName,
        quellDokumentIds: z.array(schemas.documentId).min(1).max(30).describe('Die Notizen, in dieser Reihenfolge.'),
        zwischenueberschriften: z.boolean().default(true).describe('Vor jeder Quelle eine Überschrift mit ihrem Titel.'),
        freigabenUebernehmen: z
          .boolean()
          .default(false)
          .describe('Jede Kopie bekommt die Freigabe ihres Originals. Nur wenn Marie das ausdrücklich will.'),
        einleitung: schemas.markdown.optional().describe('Optionaler Text am Anfang (privat).'),
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false },
    },
    async ({ titel, gruppe, quellDokumentIds, zwischenueberschriften, freigabenUebernehmen, einleitung }) => {
      const sources = await notes.ownDocumentsByIds(quellDokumentIds);
      const campaignId = sources[0]!.campaignId;
      if (sources.some((source) => source.campaignId !== campaignId)) {
        throw new UserError('Alle Quellen müssen aus derselben Kampagne sein.');
      }
      type Item = { kind: 'text'; text: string; readers: string[] } | { kind: 'image'; block: QkBlock; readers: string[] };
      const items: Item[] = [];
      const copyReaders = (block: QkBlock) => (freigabenUebernehmen ? readersOf(block) : []);
      if (einleitung?.trim()) items.push({ kind: 'text', text: einleitung, readers: [] });
      for (const source of sources) {
        if (zwischenueberschriften) items.push({ kind: 'text', text: `## ${source.title}`, readers: [] });
        for (const block of source.blocks) {
          if (block.type === 'image') items.push({ kind: 'image', block, readers: copyReaders(block) });
          else items.push({ kind: 'text', text: block.markdownText ?? '', readers: copyReaders(block) });
        }
      }

      const created = await notes.call(() => notes.qk.createDocument(campaignId, { title: titel, groupName: gruppe }));
      const order: string[] = [];
      const problems: string[] = [];
      let shared = 0;
      let index = 0;
      try {
        while (index < items.length) {
          const item = items[index]!;
          if (item.kind === 'text') {
            const run: { markdownText: string; visibleTo: string[] }[] = [];
            while (index < items.length && items[index]!.kind === 'text' && run.length < batchSize) {
              const next = items[index] as Extract<Item, { kind: 'text' }>;
              run.push({ markdownText: next.text, visibleTo: next.readers });
              index++;
            }
            const blocks = await notes.qk.createTextBlocks(created.id, run);
            order.push(...blocks.map((block) => block.id));
            shared += run.filter((entry) => entry.visibleTo.length > 0).length;
            continue;
          }
          index++;
          try {
            const image = await copyImage(context, item.block);
            const block = await notes.qk.createImageBlock(created.id, image, {
              markdownText: item.block.markdownText ?? undefined,
              visibleTo: item.readers,
            });
            order.push(block.id);
            if (item.readers.length) shared++;
          } catch (error) {
            problems.push(`Bild ${item.block.id}: ${toUserError(error).message}`);
          }
        }
        if (order.length > 1) await notes.qk.arrangeBlocks(created.id, order);
      } catch (error) {
        throw new UserError(
          `Die Notiz „${titel}“ (id ${created.id}) ist angelegt, aber nur ${order.length} von ${items.length} Blöcken wurden kopiert: ` +
            toUserError(error).message,
        );
      }
      const saved = await notes.ownDocument(created.id);
      const lines = [
        `Gesamtdokument „${saved.title}“ in Gruppe „${saved.groupName}“ angelegt (id ${saved.id}, Version ${saved.lastModifiedAt}).`,
        `${plural(order.length, 'Block', 'Blöcke')} aus ${plural(sources.length, 'Notiz', 'Notizen')} kopiert; die Quellen sind unverändert.`,
        freigabenUebernehmen
          ? `${plural(shared, 'Kopie hat', 'Kopien haben')} die Freigabe ihres Originals übernommen; alles andere ist privat.`
          : 'Alle Blöcke sind privat.',
      ];
      if (problems.length) lines.push(`Nicht kopiert: ${problems.join('; ')}`);
      return { text: lines.join('\n'), log: { documentId: saved.id, documents: sources.length, blocks: order.length } };
    },
  );
}

/** An image of a block, ready to store again (Questkeeper images are PNG or JPEG already). */
async function copyImage(context: ToolContext, block: QkBlock) {
  if (!block.imageUrl) throw new UserError('Der Bildblock hat kein Bild.');
  const { data } = await context.notes.qk.fetchImage(block.imageUrl);
  const kind = detectImageKind(data);
  if ((kind === 'png' || kind === 'jpeg') && data.length <= 10 * 1024 * 1024) {
    return { data, mimeType: kind === 'png' ? ('image/png' as const) : ('image/jpeg' as const), fileName: `bild.${kind === 'png' ? 'png' : 'jpg'}` };
  }
  return toStorable(data);
}
