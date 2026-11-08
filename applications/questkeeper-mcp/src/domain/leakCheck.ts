import type { QkBlock, QkDocument } from '../questkeeper/types.js';
import { blockIsReadableByAll, type Readers } from './visibility.js';

/**
 * A safety net against accidental shares: does a text that some people will read contain passages copied
 * word for word from a block those people may not read? It finds verbatim copies (a run of 8 words, or a
 * whole short block of 4 to 7 words), not paraphrases. The rules that really keep shares apart are
 * structural: blocks keep their readers, new blocks are private, mixed merges become private.
 */

const runLength = 8;
const shortBlockMinimum = 4;

function words(text: string): string[] {
  return text
    .normalize('NFKD')
    .replace(/\p{M}/gu, '')
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, ' ')
    .trim()
    .split(' ')
    .filter(Boolean);
}

function shingles(tokens: string[], size: number): Set<string> {
  const result = new Set<string>();
  for (let index = 0; index + size <= tokens.length; index++) result.add(tokens.slice(index, index + size).join(' '));
  return result;
}

/** True if `text` contains a verbatim passage of `source`. */
export function containsPassageOf(text: string, source: string): boolean {
  const sourceWords = words(source);
  if (sourceWords.length < shortBlockMinimum) return false;
  const size = Math.min(runLength, sourceWords.length);
  const sourceRuns = shingles(sourceWords, size);
  for (const run of shingles(words(text), size)) if (sourceRuns.has(run)) return true;
  return false;
}

export interface LeakFinding {
  block: QkBlock;
  document: QkDocument;
}

/**
 * Blocks (from `documents`) that `audience` may not read and whose text shows up in `text`. Blocks named in
 * `ignore` (the block being changed, declared sources) are skipped.
 */
export function findLeaks(
  text: string,
  audience: Readers,
  documents: QkDocument[],
  ignore: Iterable<string> = [],
): LeakFinding[] {
  if (audience.length === 0 || !text.trim()) return [];
  const skip = new Set([...ignore].map((id) => id.toLowerCase()));
  const findings: LeakFinding[] = [];
  for (const document of documents) {
    for (const block of document.blocks) {
      if (skip.has(block.id.toLowerCase()) || !block.markdownText) continue;
      if (blockIsReadableByAll(block, audience)) continue;
      if (containsPassageOf(text, block.markdownText)) findings.push({ block, document });
    }
  }
  return findings;
}
