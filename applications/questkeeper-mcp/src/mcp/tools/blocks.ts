import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { UserError, toUserError } from '../../domain/errors.js';
import { findLeaks, type LeakFinding } from '../../domain/leakCheck.js';
import { assertVersion } from '../../domain/notes.js';
import { blockIsReadableByAll, mergedReaders, readersOf, type Roster } from '../../domain/visibility.js';
import type { QkBlock, QkDocument } from '../../questkeeper/types.js';
import {
  addTool,
  confirmationHint,
  confirmStep,
  insertInto,
  ownBlock,
  plural,
  positionSchema,
  schemas,
  uniqueIds,
  type ToolContext,
} from '../common.js';
import { blockKind, excerpt } from '../format.js';

function leakMessage(findings: LeakFinding[], roster: Roster, audience: string[]): string {
  const where = findings
    .slice(0, 5)
    .map(({ block, document }) => `Block ${block.id} in „${document.title}“ (${roster.describeBlock(block)})`)
    .join('; ');
  return (
    `Nichts gespeichert: Der Text enthält wörtliche Passagen aus ${where}. ` +
    `Den Block hier lesen aber ${roster.describe(audience).replace(/^geteilt mit /, '')}, und die dürfen jene Inhalte nicht sehen. ` +
    'Formuliere ohne diese Passagen, oder nenne die Blöcke in verwendeteQuellbloecke – dann wird der Block privat.'
  );
}

function locate(documents: QkDocument[], blockId: string): { block: QkBlock; document: QkDocument } | undefined {
  for (const document of documents) {
    const block = document.blocks.find((candidate) => candidate.id.toLowerCase() === blockId.toLowerCase());
    if (block) return { block, document };
  }
  return undefined;
}

export function registerBlockTools(server: McpServer, context: ToolContext): void {
  const { notes } = context;

  /** The document after a change, for the new version in the answer. */
  const reread = (documentId: string) => notes.ownDocument(documentId);

  addTool(
    server,
    'bloecke_hinzufuegen',
    {
      title: 'Blöcke hinzufügen',
      description:
        'Fügt einer von Maries Notizen neue Textblöcke (Markdown) hinzu, am Ende oder nach einem bestimmten Block. ' +
        'Neue Blöcke sind immer privat; freigeben geht nur mit freigabe_aendern.',
      inputSchema: {
        dokumentId: schemas.documentId,
        bloecke: z.array(schemas.markdown).min(1).max(100).describe('Die neuen Blöcke, in dieser Reihenfolge.'),
        nachBlockId: positionSchema,
        version: schemas.version.optional(),
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false },
    },
    async ({ dokumentId, bloecke, nachBlockId, version }) => {
      const document = await notes.ownDocument(dokumentId);
      assertVersion(document, version);
      if (nachBlockId && nachBlockId.toLowerCase() !== 'anfang') ownOrReadable(document, nachBlockId);
      const created = await notes.write(document, () =>
        notes.qk.createTextBlocks(
          document.id,
          bloecke.map((markdownText) => ({ markdownText, visibleTo: [] })),
          version ?? document.lastModifiedAt,
        ),
      );
      const createdIds = created.map((block) => block.id);
      if (nachBlockId) {
        const fresh = await reread(document.id);
        const order = insertInto(
          fresh.blocks.map((block) => block.id),
          createdIds,
          nachBlockId,
        );
        await notes.write(fresh, () => notes.qk.arrangeBlocks(fresh.id, order, fresh.lastModifiedAt));
      }
      const saved = await reread(document.id);
      return {
        text:
          `${plural(created.length, 'privater Block', 'private Blöcke')} zu „${saved.title}“ hinzugefügt ` +
          `(IDs ${createdIds.join(', ')}). Neue Version: ${saved.lastModifiedAt}.`,
        log: { documentId: saved.id, blocks: created.length },
      };
    },
  );

  addTool(
    server,
    'block_bearbeiten',
    {
      title: 'Block bearbeiten',
      description:
        'Ersetzt den Text eines Textblocks (bei Bildblöcken die Bildunterschrift). Die Freigabe bleibt, wie sie ist. ' +
        'Übernimmst du dabei Inhalte aus anderen Blöcken, nenne sie in verwendeteQuellbloecke: Darf nicht jeder Leser ' +
        'dieses Blocks auch die Quellen lesen, wird der Block privat (das wird gemeldet). Wörtlich übernommene, ' +
        'nicht genannte Passagen aus Blöcken, die die Leser nicht sehen dürfen, werden abgelehnt.',
      inputSchema: {
        dokumentId: schemas.documentId,
        blockId: schemas.blockId,
        neuerText: schemas.markdown,
        version: schemas.version,
        verwendeteQuellbloecke: z
          .array(schemas.blockId)
          .max(50)
          .optional()
          .describe('IDs der Blöcke, aus denen Inhalte übernommen wurden.'),
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    },
    async ({ dokumentId, blockId, neuerText, version, verwendeteQuellbloecke }) => {
      const document = await notes.ownDocument(dokumentId);
      assertVersion(document, version);
      const block = ownBlock(document, blockId);
      const roster = await notes.roster(document.campaignId);
      const readers = readersOf(block);
      let nextReaders = readers;
      const reasons: string[] = [];

      if (readers.length > 0 || verwendeteQuellbloecke?.length) {
        const campaignDocuments = await notes.ownDocuments(document.campaignId);
        const sources = (verwendeteQuellbloecke ?? []).map((id) => {
          const found = locate(campaignDocuments, id);
          if (!found) throw new UserError(`Quellblock ${id} ist in keiner von Maries Notizen dieser Kampagne.`);
          return found;
        });
        const uncovered = sources.filter(({ block: source }) => !blockIsReadableByAll(source, readers));
        if (uncovered.length > 0) {
          nextReaders = [];
          for (const { block: source, document: sourceDocument } of uncovered) {
            reasons.push(`Block ${source.id} in „${sourceDocument.title}“ (${roster.describeBlock(source)})`);
          }
        } else if (readers.length > 0) {
          const leaks = findLeaks(neuerText, readers, campaignDocuments, [block.id, ...sources.map((s) => s.block.id)]);
          if (leaks.length > 0) throw new UserError(leakMessage(leaks, roster, readers));
        }
      }

      await notes.write(document, () =>
        block.type === 'image'
          ? notes.qk.updateImageBlock(block.id, { markdownText: neuerText, visibleTo: nextReaders, expectedLastModifiedAt: version })
          : notes.qk.updateTextBlock(block.id, { markdownText: neuerText, visibleTo: nextReaders, expectedLastModifiedAt: version }),
      );
      const saved = await reread(document.id);
      const lines = [`${blockKind(block) === 'Bild' ? 'Bildunterschrift' : 'Block'} ${block.id} in „${saved.title}“ geändert.`];
      if (reasons.length > 0 && readers.length > 0) {
        lines.push(
          `Der Block ist jetzt privat (vorher ${roster.describe(readers)}), weil Inhalte aus ${reasons.join(', ')} eingeflossen sind, ` +
            'die nicht alle bisherigen Leser sehen dürfen. Wieder freigeben geht nur mit freigabe_aendern, wenn Marie das will.',
        );
      } else {
        lines.push(`Freigabe unverändert: ${roster.describe(nextReaders)}.`);
        if (nextReaders.length > 0) lines.push('Der neue Text ist für diese Leser sichtbar.');
      }
      lines.push(`Neue Version: ${saved.lastModifiedAt}.`);
      return { text: lines.join('\n'), log: { documentId: saved.id, blockId: block.id, outcome: reasons.length ? 'made_private' : 'kept' } };
    },
  );

  addTool(
    server,
    'block_aufteilen',
    {
      title: 'Block aufteilen',
      description:
        'Teilt einen Textblock in mehrere aufeinanderfolgende Blöcke. Jeder Teil bekommt genau die Freigabe des ursprünglichen Blocks. ' +
        'Der erste Teil ersetzt den Block (gleiche ID), die weiteren folgen direkt danach.',
      inputSchema: {
        dokumentId: schemas.documentId,
        blockId: schemas.blockId,
        teile: z.array(schemas.markdown).min(2).max(50).describe('Die Teile in Reihenfolge, zusammen der Inhalt des Blocks.'),
        version: schemas.version,
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false },
    },
    async ({ dokumentId, blockId, teile, version }) => {
      const document = await notes.ownDocument(dokumentId);
      assertVersion(document, version);
      const block = ownBlock(document, blockId);
      if (block.type !== 'text') throw new UserError('Nur Textblöcke lassen sich aufteilen.');
      const roster = await notes.roster(document.campaignId);
      const readers = readersOf(block);
      if (readers.length > 0) {
        const campaignDocuments = await notes.ownDocuments(document.campaignId);
        for (const part of teile) {
          const leaks = findLeaks(part, readers, campaignDocuments, [block.id]);
          if (leaks.length > 0) throw new UserError(leakMessage(leaks, roster, readers));
        }
      }
      // New parts first, then the order, the original last: a failure on the way never loses text.
      const created = await notes.write(document, () =>
        notes.qk.createTextBlocks(
          document.id,
          teile.slice(1).map((markdownText) => ({ markdownText, visibleTo: readers })),
          version,
        ),
      );
      const fresh = await reread(document.id);
      const order = insertInto(
        fresh.blocks.map((candidate) => candidate.id),
        created.map((part) => part.id),
        block.id,
      );
      const arranged = await notes.write(fresh, () => notes.qk.arrangeBlocks(fresh.id, order, fresh.lastModifiedAt));
      await notes.write(arranged, () =>
        notes.qk.updateTextBlock(block.id, {
          markdownText: teile[0]!,
          visibleTo: readers,
          expectedLastModifiedAt: arranged.lastModifiedAt,
        }),
      );
      const saved = await reread(document.id);
      return {
        text:
          `Block ${block.id} in ${teile.length} Teile aufgeteilt (neue IDs ${created.map((part) => part.id).join(', ')}). ` +
          `Alle Teile: ${roster.describe(readers)}. Neue Version: ${saved.lastModifiedAt}.`,
        log: { documentId: saved.id, blockId: block.id, blocks: teile.length },
      };
    },
  );

  addTool(
    server,
    'bloecke_verschmelzen',
    {
      title: 'Blöcke verschmelzen',
      description:
        'Verschmilzt mehrere Textblöcke einer Notiz zu einem (an der Stelle des ersten genannten). Ohne neuerText werden die Texte ' +
        'in der genannten Reihenfolge aneinandergehängt. Haben alle dieselbe Freigabe, bleibt sie; sonst wird der neue Block ' +
        'privat, und das wird gemeldet.',
      inputSchema: {
        dokumentId: schemas.documentId,
        blockIds: z.array(schemas.blockId).min(2).max(50).describe('Die Blöcke, in der Reihenfolge ihres Texts.'),
        version: schemas.version,
        neuerText: schemas.markdown.optional().describe('Optional: der verschmolzene Text, umformuliert.'),
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false },
    },
    async ({ dokumentId, blockIds, version, neuerText }) => {
      const document = await notes.ownDocument(dokumentId);
      assertVersion(document, version);
      const blocks = uniqueIds(blockIds).map((id) => ownBlock(document, id));
      if (blocks.some((block) => block.type !== 'text')) throw new UserError('Nur Textblöcke lassen sich verschmelzen.');
      const roster = await notes.roster(document.campaignId);
      const { readers, madePrivate } = mergedReaders(blocks);
      const text = neuerText ?? blocks.map((block) => block.markdownText ?? '').join('\n\n');
      if (neuerText && readers.length > 0) {
        const campaignDocuments = await notes.ownDocuments(document.campaignId);
        const leaks = findLeaks(neuerText, readers, campaignDocuments, blocks.map((block) => block.id));
        if (leaks.length > 0) throw new UserError(leakMessage(leaks, roster, readers));
      }
      const [first, ...rest] = blocks;
      // Merged text and its readers in one write, so the text is never visible to the wrong people.
      await notes.write(document, () =>
        notes.qk.updateTextBlock(first!.id, { markdownText: text, visibleTo: readers, expectedLastModifiedAt: version }),
      );
      const leftOver: string[] = [];
      for (const block of rest) {
        try {
          await notes.qk.deleteBlock(block.id);
        } catch (error) {
          leftOver.push(`${block.id} (${toUserError(error).message})`);
        }
      }
      const saved = await reread(document.id);
      const lines = [`${blocks.length} Blöcke zu Block ${first!.id} verschmolzen.`];
      if (madePrivate) {
        lines.push(
          'Die Blöcke hatten unterschiedliche Freigaben, deshalb ist der neue Block privat:',
          ...blocks.map((block) => `- ${block.id}: ${roster.describeBlock(block)}`),
          'Freigeben geht nur mit freigabe_aendern, wenn Marie das will.',
        );
      } else {
        lines.push(`Freigabe: ${roster.describe(readers)} (wie bei allen Teilen).`);
      }
      if (leftOver.length) lines.push(`Diese Blöcke ließen sich nicht entfernen und stehen noch da: ${leftOver.join('; ')}`);
      lines.push(`Neue Version: ${saved.lastModifiedAt}.`);
      return { text: lines.join('\n'), log: { documentId: saved.id, blocks: blocks.length, outcome: madePrivate ? 'made_private' : 'kept' } };
    },
  );

  addTool(
    server,
    'bloecke_anordnen',
    {
      title: 'Blöcke anordnen',
      description:
        'Bringt die Blöcke einer Notiz in eine neue Reihenfolge. Nenne alle Blöcke der Notiz genau einmal. Freigaben bleiben unverändert.',
      inputSchema: {
        dokumentId: schemas.documentId,
        reihenfolge: z.array(schemas.blockId).min(1).max(1000).describe('Alle Block-IDs der Notiz in der neuen Reihenfolge.'),
        version: schemas.version,
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    },
    async ({ dokumentId, reihenfolge, version }) => {
      const document = await notes.ownDocument(dokumentId);
      assertVersion(document, version);
      const order = uniqueIds(reihenfolge);
      const present = new Set(document.blocks.map((block) => block.id.toLowerCase()));
      const foreign = order.filter((id) => !present.has(id));
      if (foreign.length) {
        throw new UserError(`Nicht in dieser Notiz: ${foreign.join(', ')}. Blöcke aus anderen Notizen holt bloecke_verschieben.`);
      }
      const missing = document.blocks.filter((block) => !order.includes(block.id.toLowerCase()));
      if (missing.length) {
        throw new UserError(`Es fehlen Blöcke: ${missing.map((block) => `${block.id} ${excerpt(block, 40)}`).join(', ')}. Nenne alle.`);
      }
      const saved = await notes.write(document, () => notes.qk.arrangeBlocks(document.id, order, version));
      return {
        text: `Reihenfolge von „${saved.title}“ geändert. Freigaben unverändert. Neue Version: ${saved.lastModifiedAt}.`,
        log: { documentId: saved.id, blocks: order.length },
      };
    },
  );

  addTool(
    server,
    'bloecke_verschieben',
    {
      title: 'Blöcke verschieben',
      description:
        'Verschiebt Text- und Bildblöcke aus Maries Notizen (derselben Kampagne) in eine Zielnotiz, ans Ende oder nach einem Block. ' +
        'Jeder Block behält ID, Inhalt, Bild und genau seine Freigabe. Die Quellnotizen bleiben bestehen, auch wenn sie leer werden.',
      inputSchema: {
        blockIds: z.array(schemas.blockId).min(1).max(200).describe('Die Blöcke, in der Reihenfolge, in der sie im Ziel stehen sollen.'),
        zielDokumentId: schemas.documentId,
        version: schemas.version.describe('Version der Zielnotiz.'),
        nachBlockId: positionSchema,
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    },
    async ({ blockIds, zielDokumentId, version, nachBlockId }) => {
      const target = await notes.ownDocument(zielDokumentId);
      assertVersion(target, version);
      const roster = await notes.roster(target.campaignId);
      const campaignDocuments = await notes.ownDocuments(target.campaignId);
      const moving = uniqueIds(blockIds).map((id) => {
        const found = locate(campaignDocuments, id);
        if (!found) throw new UserError(`Block ${id} ist in keiner von Maries Notizen dieser Kampagne.`);
        if (!found.block.isOwn) {
          throw new UserError(`Block ${id} in „${found.document.title}“ hat jemand anderes geschrieben; er bleibt, wo er ist.`);
        }
        return found;
      });
      const order = insertInto(
        target.blocks.map((block) => block.id),
        moving.map(({ block }) => block.id),
        nachBlockId,
      );
      const saved = await notes.write(target, () => notes.qk.arrangeBlocks(target.id, order, version));
      const sourceIds = [...new Set(moving.map(({ document }) => document.id))].filter((id) => id !== target.id);
      const lines = [
        `${plural(moving.length, 'Block', 'Blöcke')} nach „${saved.title}“ verschoben; jeder behält seine Freigabe:`,
        ...moving.map(({ block, document }) => `- ${block.id} (${blockKind(block)}, ${roster.describeBlock(block)}) aus „${document.title}“`),
        `Neue Version der Zielnotiz: ${saved.lastModifiedAt}.`,
      ];
      const emptied: string[] = [];
      for (const id of sourceIds) {
        const source = await reread(id);
        if (source.blocks.length === 0) emptied.push(`„${source.title}“ (id ${source.id})`);
      }
      if (emptied.length) {
        lines.push(`Jetzt leer: ${emptied.join(', ')}. Löschen nur auf Maries Wunsch mit notizen_loeschen (mit Bestätigung).`);
      }
      return { text: lines.join('\n'), log: { documentId: saved.id, blocks: moving.length, documents: sourceIds.length } };
    },
  );

  addTool(
    server,
    'block_loeschen',
    {
      title: 'Blöcke löschen',
      description:
        'Löscht Blöcke aus einer von Maries Notizen. Zwei Schritte: Der erste Aufruf (ohne bestaetigung) zeigt, was gelöscht würde, ' +
        'und gibt einen Code. Erst wenn Marie ausdrücklich zustimmt, mit dem Code erneut aufrufen.',
      inputSchema: {
        dokumentId: schemas.documentId,
        blockIds: z.array(schemas.blockId).min(1).max(100),
        version: schemas.version,
        bestaetigung: schemas.confirmation,
      },
      annotations: { readOnlyHint: false, destructiveHint: true, idempotentHint: false, openWorldHint: false },
    },
    async ({ dokumentId, blockIds, version, bestaetigung }) => {
      const document = await notes.ownDocument(dokumentId);
      assertVersion(document, version);
      const blocks = uniqueIds(blockIds).map((id) => ownBlock(document, id));
      const roster = await notes.roster(document.campaignId);
      const request = { dokumentId: document.id, blockIds: blocks.map((block) => block.id).sort(), version };
      const step = confirmStep(context, 'block_loeschen', request, bestaetigung, null);
      if (!step.confirmed) {
        const lines = [`Das würde ${plural(blocks.length, 'Block', 'Blöcke')} aus „${document.title}“ endgültig löschen:`];
        for (const block of blocks) lines.push(`- ${block.id} (${blockKind(block)}, ${roster.describeBlock(block)}): ${excerpt(block)}`);
        return {
          text: lines.join('\n') + confirmationHint(step.code, 'Sollen diese Blöcke wirklich gelöscht werden?'),
          log: { documentId: document.id, blocks: blocks.length, outcome: 'preview' },
        };
      }
      const failed: string[] = [];
      let first = true;
      for (const block of blocks) {
        try {
          await notes.qk.deleteBlock(block.id, first ? version : undefined);
        } catch (error) {
          if (first) throw toUserError(error, `„${document.title}“`);
          failed.push(`${block.id} (${toUserError(error).message})`);
        }
        first = false;
      }
      const saved = await reread(document.id);
      const lines = [`${plural(blocks.length - failed.length, 'Block', 'Blöcke')} aus „${saved.title}“ gelöscht.`];
      if (failed.length) lines.push(`Nicht gelöscht: ${failed.join('; ')}`);
      lines.push(`Neue Version: ${saved.lastModifiedAt}.`);
      return { text: lines.join('\n'), log: { documentId: saved.id, blocks: blocks.length - failed.length } };
    },
  );

  addTool(
    server,
    'notizen_zusammenfuehren',
    {
      title: 'Notizen zusammenführen',
      description:
        'Holt alle Blöcke (Text und Bilder) aus Quellnotizen ans Ende einer Zielnotiz, optional mit einer privaten Überschrift je Quelle. ' +
        'Jeder Block behält genau seine Freigabe. Die Quellnotizen werden NICHT gelöscht; leere Quellen werden gemeldet und können ' +
        'danach nur nach Maries ausdrücklicher Zustimmung mit notizen_loeschen entfernt werden.',
      inputSchema: {
        zielDokumentId: schemas.documentId,
        version: schemas.version.describe('Version der Zielnotiz.'),
        quellDokumentIds: z.array(schemas.documentId).min(1).max(20),
        zwischenueberschriften: z.boolean().default(false).describe('Vor den Blöcken jeder Quelle eine private Überschrift mit ihrem Titel.'),
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false },
    },
    async ({ zielDokumentId, version, quellDokumentIds, zwischenueberschriften }) => {
      const target = await notes.ownDocument(zielDokumentId);
      assertVersion(target, version);
      const sources = await notes.ownDocumentsByIds(quellDokumentIds);
      if (sources.some((source) => source.id === target.id)) throw new UserError('Die Zielnotiz kann nicht zugleich Quelle sein.');
      if (sources.some((source) => source.campaignId !== target.campaignId)) {
        throw new UserError('Alle Notizen müssen aus derselben Kampagne sein.');
      }
      const withBlocks = sources.filter((source) => source.blocks.some((block) => block.isOwn));
      let current = target;
      const headings = new Map<string, string>();
      if (zwischenueberschriften && withBlocks.length) {
        const created = await notes.write(target, () =>
          notes.qk.createTextBlocks(
            target.id,
            withBlocks.map((source) => ({ markdownText: `## ${source.title}`, visibleTo: [] })),
            version,
          ),
        );
        withBlocks.forEach((source, index) => headings.set(source.id, created[index]!.id));
        current = await reread(target.id);
      }
      const headingIds = new Set(headings.values());
      const order = current.blocks.map((block) => block.id).filter((id) => !headingIds.has(id));
      let moved = 0;
      let shared = 0;
      for (const source of withBlocks) {
        const heading = headings.get(source.id);
        if (heading) order.push(heading);
        for (const block of source.blocks.filter((candidate) => candidate.isOwn)) {
          order.push(block.id);
          moved++;
          if (readersOf(block).length) shared++;
        }
      }
      const saved = await notes.write(current, () =>
        notes.qk.arrangeBlocks(current.id, order, headings.size ? current.lastModifiedAt : version),
      );
      const lines = [
        `${plural(moved, 'Block', 'Blöcke')} aus ${plural(withBlocks.length, 'Notiz', 'Notizen')} nach „${saved.title}“ geholt. ` +
          `Jeder Block behält seine Freigabe (${shared} geteilt, ${moved - shared} privat).`,
      ];
      if (headings.size) lines.push(`${plural(headings.size, 'private Überschrift', 'private Überschriften')} eingefügt.`);
      const emptied: string[] = [];
      const remaining: string[] = [];
      for (const source of sources) {
        const after = await reread(source.id);
        if (after.blocks.length === 0) emptied.push(`„${after.title}“ (id ${after.id})`);
        else remaining.push(`„${after.title}“: ${plural(after.blocks.length, 'Block', 'Blöcke')} von anderen bleiben dort`);
      }
      if (emptied.length) {
        lines.push(
          `Jetzt leer und noch vorhanden: ${emptied.join(', ')}. Nichts wurde gelöscht. ` +
            'Frag Marie, ob sie gelöscht werden sollen; wenn ja, mit notizen_loeschen (zwei Schritte).',
        );
      }
      if (remaining.length) lines.push(...remaining);
      lines.push(`Neue Version der Zielnotiz: ${saved.lastModifiedAt}.`);
      return { text: lines.join('\n'), log: { documentId: saved.id, documents: sources.length, blocks: moved } };
    },
  );
}

/** A block the position can refer to: any block of the document. */
function ownOrReadable(document: QkDocument, blockId: string): void {
  if (!document.blocks.some((block) => block.id.toLowerCase() === blockId.toLowerCase())) {
    throw new UserError(`Block ${blockId} (nachBlockId) ist nicht in „${document.title}“.`);
  }
}

