import type { QkBlock, QkDocument } from '../questkeeper/types.js';

/** Lower case, without accents, so "Château" finds "chateau". Umlauts fold too (ä -> a). */
export function fold(text: string): string {
  return text
    .normalize('NFKD')
    .replace(/\p{M}/gu, '')
    .toLowerCase();
}

const hashtag = /(?:^|[^\p{L}\p{N}_&/])#([\p{L}\p{N}_][\p{L}\p{N}_-]*)/gu;

/** Hashtags in a text, without "#", folded. "#Drachen-Hort" -> "drachen-hort". */
export function tagsIn(text: string | null | undefined): string[] {
  if (!text) return [];
  const tags = new Set<string>();
  for (const match of text.matchAll(hashtag)) if (match[1]) tags.add(fold(match[1]));
  return [...tags];
}

export function tagsOfDocument(document: QkDocument): string[] {
  const tags = new Set(tagsIn(document.title));
  for (const block of document.blocks) for (const tag of tagsIn(block.markdownText)) tags.add(tag);
  return [...tags].sort();
}

/** Words and "quoted phrases" of a search. */
export function searchTerms(query: string): string[] {
  const terms: string[] = [];
  for (const match of query.matchAll(/"([^"]+)"|(\S+)/g)) {
    const term = fold((match[1] ?? match[2] ?? '').trim());
    if (term) terms.push(term);
  }
  return terms;
}

export interface SearchHit {
  document: QkDocument;
  score: number;
  titleMatches: boolean;
  blocks: { block: QkBlock; index: number; snippet: string }[];
}

export interface SearchCriteria {
  text?: string;
  tags?: string[];
  groups?: string[];
}

function snippet(text: string, terms: string[], width = 180): string {
  const flat = text.replace(/\s+/g, ' ').trim();
  const folded = fold(flat);
  let at = -1;
  for (const term of terms) {
    const index = folded.indexOf(term);
    if (index >= 0 && (at < 0 || index < at)) at = index;
  }
  if (at < 0) return flat.length > width ? `${flat.slice(0, width)}…` : flat;
  const start = Math.max(0, at - Math.floor(width / 3));
  const end = Math.min(flat.length, start + width);
  return `${start > 0 ? '…' : ''}${flat.slice(start, end)}${end < flat.length ? '…' : ''}`;
}

/**
 * Documents that match every criterion: all words of `text` (in the title or any block), all `tags` (as
 * hashtags anywhere in the document) and one of `groups`. Best matches first.
 */
export function searchDocuments(documents: QkDocument[], criteria: SearchCriteria): SearchHit[] {
  const terms = criteria.text ? searchTerms(criteria.text) : [];
  const tags = (criteria.tags ?? []).map((tag) => fold(tag.replace(/^#/, '').trim())).filter(Boolean);
  const groups = (criteria.groups ?? []).map((group) => fold(group.trim())).filter(Boolean);
  const hits: SearchHit[] = [];

  for (const document of documents) {
    if (groups.length && !groups.includes(fold(document.groupName))) continue;
    if (tags.length) {
      const documentTags = new Set(tagsOfDocument(document));
      if (!tags.every((tag) => documentTags.has(tag))) continue;
    }
    const title = fold(document.title);
    const blockTexts = document.blocks.map((block) => fold(block.markdownText ?? ''));
    const everything = [title, ...blockTexts].join('\n');
    if (!terms.every((term) => everything.includes(term))) continue;

    const matchingBlocks = document.blocks
      .map((block, index) => ({ block, index }))
      .filter(({ index }) => {
        const text = blockTexts[index] ?? '';
        const termHit = terms.length > 0 && terms.some((term) => text.includes(term));
        const tagHit = tags.length > 0 && tagsIn(document.blocks[index]?.markdownText).some((tag) => tags.includes(tag));
        return termHit || tagHit;
      })
      .map(({ block, index }) => ({
        block,
        index,
        snippet: snippet(block.markdownText ?? '', [...terms, ...tags.map((tag) => `#${tag}`)]),
      }));

    const titleMatches = terms.some((term) => title.includes(term));
    let score = titleMatches ? 10 : 0;
    for (const term of terms) score += everything.split(term).length - 1;
    score += matchingBlocks.length;
    hits.push({ document, score, titleMatches, blocks: matchingBlocks });
  }

  return hits.sort((a, b) => b.score - a.score || a.document.title.localeCompare(b.document.title, 'de'));
}
