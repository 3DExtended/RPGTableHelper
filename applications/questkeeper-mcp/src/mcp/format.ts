import type { QkBlock, QkDocument } from '../questkeeper/types.js';
import { readersOf, type Roster } from '../domain/visibility.js';

export function germanTime(iso: string): string {
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return iso;
  return date.toLocaleString('de-DE', {
    timeZone: 'Europe/Berlin',
    dateStyle: 'medium',
    timeStyle: 'short',
  });
}

export function blockKind(block: QkBlock): string {
  return block.type === 'image' ? 'Bild' : 'Text';
}

export function sharedCount(document: QkDocument): number {
  return document.blocks.filter((block) => block.isOwn && readersOf(block).length > 0).length;
}

export function documentStats(document: QkDocument): string {
  const blocks = document.blocks.length;
  const shared = sharedCount(document);
  const images = document.blocks.filter((block) => block.type === 'image').length;
  const foreign = document.blocks.filter((block) => !block.isOwn).length;
  const parts = [`${blocks} ${blocks === 1 ? 'Block' : 'Blöcke'}`];
  if (images) parts.push(`${images} ${images === 1 ? 'Bild' : 'Bilder'}`);
  parts.push(shared ? `${shared} geteilt` : 'alle privat');
  if (foreign) parts.push(`${foreign} von anderen`);
  return parts.join(', ');
}

/** One line per document, for lists. */
export function documentLine(document: QkDocument): string {
  return `- „${document.title}“ · Gruppe „${document.groupName}“ · ${documentStats(document)} · Version ${document.lastModifiedAt} · id ${document.id}`;
}

export function blockHeader(block: QkBlock, index: number, roster: Roster): string {
  return `⟦Block ${index + 1} | ${blockKind(block)} | ${roster.describeBlock(block)} | id ${block.id}⟧`;
}

export function renderBlock(block: QkBlock, index: number, roster: Roster): string {
  const header = blockHeader(block, index, roster);
  if (block.type === 'image') {
    const caption = block.markdownText?.trim() ? `Bildunterschrift: ${block.markdownText.trim()}` : 'ohne Bildunterschrift';
    return `${header}\n[Bild – ansehen mit bild_ansehen] ${caption}`;
  }
  return `${header}\n${block.markdownText ?? ''}`;
}

export function renderDocumentHead(document: QkDocument, campaignName: string): string {
  return [
    `# ${document.title}`,
    `Notiz-ID: ${document.id}`,
    `Kampagne: ${campaignName} · Gruppe: ${document.groupName}`,
    `Version: ${document.lastModifiedAt} (geändert ${germanTime(document.lastModifiedAt)})`,
    `Inhalt: ${documentStats(document)}`,
  ].join('\n');
}

/** A short, single-line excerpt of a block, e.g. for confirmations. */
export function excerpt(block: QkBlock, length = 70): string {
  const text = (block.markdownText ?? '').replace(/\s+/g, ' ').trim();
  if (!text) return block.type === 'image' ? '(Bild ohne Unterschrift)' : '(leer)';
  return text.length > length ? `„${text.slice(0, length)}…“` : `„${text}“`;
}
