import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { UserError } from '../../domain/errors.js';
import type { NotesService } from '../../domain/notes.js';
import { fold } from '../../domain/search.js';
import type { QkCampaign, QkDocument } from '../../questkeeper/types.js';
import { addTool, confirmationHint, confirmStep, plural, schemas, type ToolContext } from '../common.js';

export const defaultGroup = 'Sonstiges';
const moveChunk = 200;

async function move(notes: NotesService, campaignId: string, documents: QkDocument[], groupName: string): Promise<void> {
  const ids = documents.map((document) => document.id);
  for (let start = 0; start < ids.length; start += moveChunk) {
    await notes.call(() => notes.qk.moveDocuments(campaignId, ids.slice(start, start + moveChunk), groupName));
  }
}

/** Marie's documents of a group: exact name first, else the one group whose name matches ignoring case and accents. */
async function documentsOfGroup(
  notes: NotesService,
  campaign: QkCampaign,
  name: string,
): Promise<{ group: string; documents: QkDocument[]; all: QkDocument[] }> {
  const all = await notes.ownDocuments(campaign.id);
  const groups = [...new Set(all.map((document) => document.groupName))];
  const group = groups.find((candidate) => candidate === name) ?? groups.find((candidate) => fold(candidate) === fold(name));
  if (!group) {
    throw new UserError(
      `Keine Gruppe „${name}“ in „${campaign.name}“. Vorhanden: ${groups.map((candidate) => `„${candidate}“`).join(', ') || 'keine'}.`,
    );
  }
  return { group, documents: all.filter((document) => document.groupName === group), all };
}

export function registerGroupTools(server: McpServer, context: ToolContext): void {
  const { notes } = context;

  addTool(
    server,
    'gruppe_anlegen',
    {
      title: 'Gruppe anlegen',
      description:
        'Legt eine Gruppe (Ordner) an. Eine Gruppe besteht in Questkeeper aus ihren Notizen; deshalb entweder Notizen hineinverschieben ' +
        '(dokumentIds) oder eine erste, leere Notiz darin anlegen (ersteNotizTitel).',
      inputSchema: {
        name: schemas.groupName,
        dokumentIds: z.array(schemas.documentId).max(200).optional().describe('Notizen, die in die neue Gruppe kommen.'),
        ersteNotizTitel: schemas.title.optional().describe('Titel einer neuen, leeren Notiz in der Gruppe.'),
        kampagne: schemas.campaign,
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false },
    },
    async ({ name, dokumentIds, ersteNotizTitel, kampagne }) => {
      if (!dokumentIds?.length && !ersteNotizTitel) {
        throw new UserError('Gib dokumentIds (Notizen zum Hineinverschieben) oder ersteNotizTitel (neue Notiz) an.');
      }
      const campaign = await notes.campaign(kampagne);
      const existing = await notes.ownDocuments(campaign.id);
      const exists = existing.some((document) => document.groupName === name);
      const lines = [exists ? `Die Gruppe „${name}“ gab es schon.` : `Gruppe „${name}“ angelegt.`];
      if (dokumentIds?.length) {
        const documents = await notes.ownDocumentsByIds(dokumentIds);
        if (documents.some((document) => document.campaignId !== campaign.id)) {
          throw new UserError(`Alle Notizen müssen aus „${campaign.name}“ sein.`);
        }
        await move(notes, campaign.id, documents, name);
        lines.push(`${plural(documents.length, 'Notiz', 'Notizen')} hineinverschoben: ${documents.map((d) => `„${d.title}“`).join(', ')}.`);
      }
      if (ersteNotizTitel) {
        const created = await notes.call(() => notes.qk.createDocument(campaign.id, { title: ersteNotizTitel, groupName: name }));
        lines.push(`Neue Notiz „${created.title}“ (id ${created.id}, Version ${created.lastModifiedAt}).`);
      }
      return { text: lines.join('\n'), log: { campaignId: campaign.id, documents: dokumentIds?.length ?? 0 } };
    },
  );

  addTool(
    server,
    'gruppe_umbenennen',
    {
      title: 'Gruppe umbenennen',
      description:
        'Benennt eine von Maries Gruppen um, indem alle ihre Notizen den neuen Gruppennamen bekommen. Gibt es den neuen Namen schon, ' +
        'landen die Notizen in dieser Gruppe.',
      inputSchema: { alterName: schemas.groupName, neuerName: schemas.groupName, kampagne: schemas.campaign },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    },
    async ({ alterName, neuerName, kampagne }) => {
      const campaign = await notes.campaign(kampagne);
      const { group, documents, all } = await documentsOfGroup(notes, campaign, alterName);
      if (group === neuerName) return { text: `Die Gruppe heißt schon „${neuerName}“.` };
      const merging = all.some((document) => document.groupName === neuerName);
      await move(notes, campaign.id, documents, neuerName);
      return {
        text:
          `Gruppe „${group}“ heißt jetzt „${neuerName}“ (${plural(documents.length, 'Notiz', 'Notizen')}).` +
          (merging ? ` Die Gruppe „${neuerName}“ gab es schon; die Notizen liegen jetzt zusammen.` : ''),
        log: { campaignId: campaign.id, documents: documents.length },
      };
    },
  );

  addTool(
    server,
    'gruppe_loeschen',
    {
      title: 'Gruppe löschen',
      description:
        `Löscht eine Gruppe, aber nie ihre Notizen: Die kommen in eine andere Gruppe (Standard „${defaultGroup}“). ` +
        'Zwei Schritte: Der erste Aufruf (ohne bestaetigung) zeigt, was passiert, und gibt einen Code. Erst wenn Marie ' +
        'ausdrücklich zustimmt, mit dem Code erneut aufrufen.',
      inputSchema: {
        name: schemas.groupName,
        zielGruppe: schemas.groupName.default(defaultGroup).describe('Wohin die Notizen kommen.'),
        kampagne: schemas.campaign,
        bestaetigung: schemas.confirmation,
      },
      annotations: { readOnlyHint: false, destructiveHint: true, idempotentHint: false, openWorldHint: false },
    },
    async ({ name, zielGruppe, kampagne, bestaetigung }) => {
      const campaign = await notes.campaign(kampagne);
      const { group, documents } = await documentsOfGroup(notes, campaign, name);
      if (group === zielGruppe) throw new UserError('Zielgruppe und Gruppe sind dieselbe.');
      const request = { campaignId: campaign.id, group, zielGruppe, ids: documents.map((document) => document.id).sort() };
      const step = confirmStep(context, 'gruppe_loeschen', request, bestaetigung, null);
      if (!step.confirmed) {
        return {
          text:
            `Die Gruppe „${group}“ würde verschwinden. Ihre ${plural(documents.length, 'Notiz', 'Notizen')} ` +
            `(${documents.map((document) => `„${document.title}“`).join(', ')}) kämen nach „${zielGruppe}“; gelöscht wird nichts davon.` +
            confirmationHint(step.code, 'Soll die Gruppe aufgelöst werden?'),
          log: { campaignId: campaign.id, documents: documents.length, outcome: 'preview' },
        };
      }
      await move(notes, campaign.id, documents, zielGruppe);
      return {
        text: `Gruppe „${group}“ aufgelöst; ${plural(documents.length, 'Notiz liegt', 'Notizen liegen')} jetzt in „${zielGruppe}“.`,
        log: { campaignId: campaign.id, documents: documents.length },
      };
    },
  );

  addTool(
    server,
    'notizen_verschieben',
    {
      title: 'Notizen verschieben',
      description: 'Verschiebt eine oder mehrere von Maries Notizen in eine Gruppe (auch eine neue). Inhalt und Freigaben bleiben unverändert.',
      inputSchema: {
        dokumentIds: z.array(schemas.documentId).min(1).max(200),
        zielGruppe: schemas.groupName,
      },
      annotations: { readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    },
    async ({ dokumentIds, zielGruppe }) => {
      const documents = await notes.ownDocumentsByIds(dokumentIds);
      const campaignId = documents[0]!.campaignId;
      if (documents.some((document) => document.campaignId !== campaignId)) {
        throw new UserError('Gruppen gibt es je Kampagne; verschiebe Notizen verschiedener Kampagnen einzeln.');
      }
      await move(notes, campaignId, documents, zielGruppe);
      return {
        text: `${plural(documents.length, 'Notiz', 'Notizen')} nach „${zielGruppe}“ verschoben: ${documents.map((d) => `„${d.title}“`).join(', ')}.`,
        log: { campaignId, documents: documents.length },
      };
    },
  );
}
