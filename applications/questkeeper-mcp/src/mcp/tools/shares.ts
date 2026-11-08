import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { UserError, toUserError } from '../../domain/errors.js';
import { findLeaks } from '../../domain/leakCheck.js';
import { assertVersion } from '../../domain/notes.js';
import { normalizeReaders, readersOf, sameReaders } from '../../domain/visibility.js';
import { addTool, confirmationHint, confirmStep, ownBlock, plural, schemas, uniqueIds, type ToolContext } from '../common.js';
import { blockKind, excerpt } from '../format.js';

export function registerShareTools(server: McpServer, context: ToolContext): void {
  const { notes } = context;

  addTool(
    server,
    'freigabe_aendern',
    {
      title: 'Freigabe ändern',
      description:
        'Das einzige Werkzeug, das ändert, wer Blöcke lesen darf. Nur benutzen, wenn Marie das ausdrücklich will. ' +
        'Personen: „Spielleitung“, Figurennamen, Nutzer-IDs oder „alle“ (siehe kampagnen_auflisten). ' +
        'Modus „setzen“ ersetzt die Leser (leere Liste = privat), „hinzufuegen“ und „entfernen“ ändern sie. ' +
        'Einschränken passiert sofort. Erweitern geht in zwei Schritten: Der erste Aufruf zeigt die Änderung und gibt einen Code; ' +
        'erst nach Maries ausdrücklichem Ja mit dem Code erneut aufrufen.',
      inputSchema: {
        dokumentId: schemas.documentId,
        blockIds: z.array(schemas.blockId).max(200).optional().describe('Die Blöcke; oder alleBloecke.'),
        alleBloecke: z.boolean().optional().describe('Alle eigenen Blöcke der Notiz.'),
        modus: z.enum(['setzen', 'hinzufuegen', 'entfernen']),
        personen: z.array(z.string().max(200)).max(50).describe('Wer (siehe oben). Bei „setzen“ ist [] privat.'),
        version: schemas.version,
        bestaetigung: schemas.confirmation,
      },
      annotations: { readOnlyHint: false, destructiveHint: true, idempotentHint: true, openWorldHint: false },
    },
    async ({ dokumentId, blockIds, alleBloecke, modus, personen, version, bestaetigung }) => {
      if (Boolean(alleBloecke) === Boolean(blockIds?.length)) throw new UserError('Gib entweder blockIds oder alleBloecke an.');
      if (modus !== 'setzen' && personen.length === 0) throw new UserError('Nenne mindestens eine Person.');
      const document = await notes.ownDocument(dokumentId);
      assertVersion(document, version);
      const roster = await notes.roster(document.campaignId);
      const people = roster.resolve(personen);
      const blocks = alleBloecke
        ? document.blocks.filter((block) => block.isOwn)
        : uniqueIds(blockIds ?? []).map((id) => ownBlock(document, id));

      const changes = blocks
        .map((block) => {
          const before = readersOf(block);
          const after =
            modus === 'setzen'
              ? normalizeReaders(people)
              : modus === 'hinzufuegen'
                ? normalizeReaders([...before, ...people])
                : before.filter((id) => !people.includes(id));
          const gained = after.filter((id) => !before.includes(id));
          return { block, before, after, gained };
        })
        .filter((change) => !sameReaders(change.before, change.after));
      if (changes.length === 0) return { text: 'Keine Änderung nötig: Die Blöcke haben schon diese Freigabe.' };

      const widening = changes.some((change) => change.gained.length > 0);
      const request = {
        dokumentId: document.id,
        changes: changes.map((change) => ({ id: change.block.id, after: change.after })),
        version,
      };
      if (widening) {
        const step = confirmStep(context, 'freigabe_aendern', request, bestaetigung, null);
        if (!step.confirmed) {
          const campaignDocuments = await notes.ownDocuments(document.campaignId);
          const lines = [`Geplante Freigabe-Änderung in „${document.title}“:`];
          for (const change of changes) {
            lines.push(
              `- ${change.block.id} (${blockKind(change.block)}) ${excerpt(change.block, 50)}: ` +
                `${roster.describe(change.before)} → ${roster.describe(change.after)}`,
            );
            if (change.gained.length > 0 && change.block.markdownText) {
              const leaks = findLeaks(change.block.markdownText, change.gained, campaignDocuments, [change.block.id]);
              for (const { block, document: other } of leaks.slice(0, 3)) {
                lines.push(
                  `  Achtung: enthält Passagen aus Block ${block.id} in „${other.title}“ (${roster.describeBlock(block)}), ` +
                    'die die neuen Leser sonst nicht sehen.',
                );
              }
            }
          }
          return {
            text: lines.join('\n') + confirmationHint(step.code, 'Soll das so freigegeben werden?'),
            log: { documentId: document.id, blocks: changes.length, outcome: 'preview' },
          };
        }
      }

      const done: string[] = [];
      const failed: string[] = [];
      let first = true;
      for (const change of changes) {
        try {
          const expectedLastModifiedAt = first ? version : undefined;
          if (change.block.type === 'image') {
            await notes.qk.updateImageBlock(change.block.id, {
              markdownText: change.block.markdownText ?? null,
              visibleTo: change.after,
              expectedLastModifiedAt,
            });
          } else {
            await notes.qk.updateTextBlock(change.block.id, {
              markdownText: change.block.markdownText ?? '',
              visibleTo: change.after,
              expectedLastModifiedAt,
            });
          }
          done.push(`- ${change.block.id}: ${roster.describe(change.after)}`);
        } catch (error) {
          if (first) throw toUserError(error, `„${document.title}“`);
          failed.push(`${change.block.id} (${toUserError(error).message})`);
        }
        first = false;
      }
      const saved = await notes.ownDocument(document.id);
      const lines = [`Freigabe von ${plural(done.length, 'Block', 'Blöcken')} in „${saved.title}“ geändert:`, ...done];
      if (failed.length) lines.push(`Nicht geändert: ${failed.join('; ')}`);
      lines.push(`Neue Version: ${saved.lastModifiedAt}.`);
      return { text: lines.join('\n'), log: { documentId: saved.id, blocks: done.length, outcome: widening ? 'widened' : 'narrowed' } };
    },
  );
}
