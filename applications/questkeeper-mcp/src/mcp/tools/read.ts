import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { UserError } from '../../domain/errors.js';
import { fold, searchDocuments, tagsOfDocument } from '../../domain/search.js';
import { addTool, schemas, type ToolContext } from '../common.js';
import { documentLine, renderBlock, renderDocumentHead } from '../format.js';

const readBudget = 120_000;

export function registerReadTools(server: McpServer, context: ToolContext): void {
  const { notes } = context;

  addTool(
    server,
    'kampagnen_auflisten',
    {
      title: 'Kampagnen auflisten',
      description:
        'Listet Maries Kampagnen mit den Leuten am Tisch. Die Namen (z. B. „Spielleitung“ oder Figurennamen) brauchst du für freigabe_aendern.',
      inputSchema: {},
      annotations: { readOnlyHint: true, openWorldHint: false },
    },
    async () => {
      const campaigns = await notes.campaigns();
      if (campaigns.length === 0) return { text: 'Für diesen Zugang ist keine Kampagne freigegeben.' };
      const lines: string[] = ['Maries Kampagnen:'];
      for (const campaign of campaigns) {
        const roster = await notes.roster(campaign.id);
        const me = roster.me;
        const role = me?.isDm
          ? 'Marie ist hier Spielleitung'
          : me?.characters.length
            ? `Marie spielt ${me.characters.map((character) => character.name).join(', ')}`
            : 'Marie ist Mitglied';
        lines.push(`- „${campaign.name}“ (id ${campaign.id}) – ${role}`);
        lines.push(`  Für Freigaben: ${roster.choices().join(', ') || 'niemand sonst'}`);
      }
      return { text: lines.join('\n'), log: { count: campaigns.length } };
    },
  );

  addTool(
    server,
    'gruppen_auflisten',
    {
      title: 'Gruppen auflisten',
      description: 'Listet die Gruppen (Ordner) von Maries Notizen in einer Kampagne, mit den Notizen darin.',
      inputSchema: { kampagne: schemas.campaign },
      annotations: { readOnlyHint: true, openWorldHint: false },
    },
    async ({ kampagne }) => {
      const campaign = await notes.campaign(kampagne);
      const documents = await notes.ownDocuments(campaign.id);
      const groups = new Map<string, string[]>();
      for (const document of documents) {
        const titles = groups.get(document.groupName) ?? [];
        titles.push(document.title);
        groups.set(document.groupName, titles);
      }
      if (groups.size === 0) return { text: `In „${campaign.name}“ hat Marie noch keine Notizen.` };
      const lines = [`Gruppen in „${campaign.name}“ (nur Maries Notizen):`];
      for (const [group, titles] of [...groups].sort(([a], [b]) => a.localeCompare(b, 'de'))) {
        titles.sort((a, b) => a.localeCompare(b, 'de'));
        lines.push(`- „${group}“ (${titles.length}): ${titles.map((title) => `„${title}“`).join(', ')}`);
      }
      return { text: lines.join('\n'), log: { campaignId: campaign.id, count: groups.size } };
    },
  );

  addTool(
    server,
    'notizen_auflisten',
    {
      title: 'Notizen auflisten',
      description:
        'Listet Maries Notizen einer Kampagne (optional nur einer Gruppe) mit ID, Gruppe, Version und wie viele Blöcke geteilt sind.',
      inputSchema: {
        kampagne: schemas.campaign,
        gruppe: z.string().max(200).optional().describe('Nur Notizen dieser Gruppe.'),
      },
      annotations: { readOnlyHint: true, openWorldHint: false },
    },
    async ({ kampagne, gruppe }) => {
      const campaign = await notes.campaign(kampagne);
      let documents = await notes.ownDocuments(campaign.id);
      if (gruppe) documents = documents.filter((document) => fold(document.groupName) === fold(gruppe));
      if (documents.length === 0) {
        return { text: gruppe ? `Keine Notizen in der Gruppe „${gruppe}“.` : `In „${campaign.name}“ hat Marie noch keine Notizen.` };
      }
      documents.sort(
        (a, b) => a.groupName.localeCompare(b.groupName, 'de') || a.title.localeCompare(b.title, 'de'),
      );
      return {
        text: [`${documents.length} Notizen in „${campaign.name}“:`, ...documents.map(documentLine)].join('\n'),
        log: { campaignId: campaign.id, count: documents.length },
      };
    },
  );

  addTool(
    server,
    'notizen_durchsuchen',
    {
      title: 'Notizen durchsuchen',
      description:
        'Durchsucht Maries Notizen einer Kampagne: Volltext (alle Wörter müssen vorkommen, "in Anführungszeichen" als Phrase), ' +
        'Tags (#hashtags im Text) und Gruppen. Groß-/Kleinschreibung und Akzente sind egal. Zeigt Fundstellen mit Block-ID und Freigabe.',
      inputSchema: {
        suche: z.string().max(500).optional().describe('Suchtext.'),
        tags: z.array(z.string().max(100)).max(20).optional().describe('Tags, mit oder ohne #. Alle müssen vorkommen.'),
        gruppen: z.array(z.string().max(200)).max(20).optional().describe('Nur in diesen Gruppen.'),
        kampagne: schemas.campaign,
      },
      annotations: { readOnlyHint: true, openWorldHint: false },
    },
    async ({ suche, tags, gruppen, kampagne }) => {
      if (!suche?.trim() && !tags?.length && !gruppen?.length) {
        throw new UserError('Gib einen Suchtext, Tags oder Gruppen an.');
      }
      const campaign = await notes.campaign(kampagne);
      const documents = await notes.ownDocuments(campaign.id);
      const roster = await notes.roster(campaign.id);
      const hits = searchDocuments(documents, { text: suche, tags, groups: gruppen });
      if (hits.length === 0) return { text: 'Nichts gefunden.', log: { campaignId: campaign.id, count: 0 } };
      const lines = [`${hits.length} Notizen gefunden${hits.length > 30 ? ' (die 30 besten)' : ''}:`];
      for (const hit of hits.slice(0, 30)) {
        lines.push('', documentLine(hit.document));
        const tagsHere = tagsOfDocument(hit.document);
        if (tagsHere.length) lines.push(`  Tags: ${tagsHere.map((tag) => `#${tag}`).join(' ')}`);
        if (hit.titleMatches) lines.push('  Treffer im Titel');
        for (const { block, index, snippet } of hit.blocks.slice(0, 3)) {
          lines.push(`  Block ${index + 1} (id ${block.id}, ${roster.describeBlock(block)}): ${snippet}`);
        }
        if (hit.blocks.length > 3) lines.push(`  … und ${hit.blocks.length - 3} weitere Fundstellen`);
      }
      return { text: lines.join('\n'), log: { campaignId: campaign.id, count: hits.length } };
    },
  );

  addTool(
    server,
    'notizen_lesen',
    {
      title: 'Notizen lesen',
      description:
        'Liest eine oder mehrere von Maries Notizen vollständig: alle Blöcke in Reihenfolge, je mit Block-ID und Freigabestatus ' +
        '(privat oder mit wem geteilt), plus die Version, die du für Änderungen brauchst. Sehr lange Antworten werden gekürzt; ' +
        'dann einzeln mit abBlock weiterlesen.',
      inputSchema: {
        dokumentIds: z.array(schemas.documentId).min(1).max(20).describe('Eine oder mehrere Notiz-IDs.'),
        abBlock: z
          .number()
          .int()
          .min(1)
          .optional()
          .describe('Nur bei einer einzelnen Notiz: ab diesem Block (1 = erster) weiterlesen.'),
      },
      annotations: { readOnlyHint: true, openWorldHint: false },
    },
    async ({ dokumentIds, abBlock }) => {
      if (abBlock && dokumentIds.length > 1) throw new UserError('abBlock geht nur zusammen mit einer einzelnen Notiz.');
      const documents = await notes.ownDocumentsByIds(dokumentIds);
      const parts: string[] = [];
      let used = 0;
      const skipped: string[] = [];
      for (const document of documents) {
        const campaign = await notes.campaignById(document.campaignId);
        const roster = await notes.roster(document.campaignId);
        const head = renderDocumentHead(document, campaign.name);
        if (used + head.length > readBudget) {
          skipped.push(`„${document.title}“ (${document.id})`);
          continue;
        }
        const section = [head];
        used += head.length;
        const start = (abBlock ?? 1) - 1;
        for (let index = start; index < document.blocks.length; index++) {
          const rendered = renderBlock(document.blocks[index]!, index, roster);
          if (used + rendered.length > readBudget) {
            section.push(
              `\n… gekürzt: Blöcke ${index + 1}–${document.blocks.length} fehlen. Weiter mit notizen_lesen (nur diese Notiz) und abBlock: ${index + 1}.`,
            );
            used = readBudget;
            break;
          }
          section.push('', rendered);
          used += rendered.length;
        }
        parts.push(section.join('\n'));
      }
      if (skipped.length) parts.push(`\nNicht mehr enthalten (zu lang für eine Antwort), bitte einzeln lesen: ${skipped.join(', ')}`);
      return {
        text: parts.join('\n\n────────\n\n'),
        log: { documentIds: documents.map((document) => document.id), count: documents.length },
      };
    },
  );
}
