import type { QkBlock, QkMember } from '../questkeeper/types.js';
import { UserError } from './errors.js';

/**
 * Who may read a block, besides Marie. Own blocks carry the list (`visibleTo`); a block someone else wrote
 * has no list here, so its readers are unknown and it counts as "shared with an unknown audience".
 */
export type Readers = readonly string[];

export function normalizeReaders(readers: Readers): string[] {
  return [...new Set(readers.map((id) => id.toLowerCase()))].sort();
}

export function sameReaders(a: Readers, b: Readers): boolean {
  const left = normalizeReaders(a);
  const right = normalizeReaders(b);
  return left.length === right.length && left.every((id, index) => id === right[index]);
}

/** True if everyone in `audience` may already read `block` (so showing them its content leaks nothing). */
export function blockIsReadableByAll(block: QkBlock, audience: Readers): boolean {
  if (audience.length === 0) return true;
  if (!block.isOwn || !block.visibleTo) return false;
  const readers = new Set(normalizeReaders(block.visibleTo));
  return audience.every((id) => readers.has(id.toLowerCase()));
}

export function readersOf(block: QkBlock): string[] {
  return block.isOwn && block.visibleTo ? normalizeReaders(block.visibleTo) : [];
}

/** The readers of a merged block: kept if all parts had the same, else nobody (private). */
export function mergedReaders(blocks: QkBlock[]): { readers: string[]; madePrivate: boolean } {
  const first = blocks[0];
  if (!first) return { readers: [], madePrivate: false };
  const all = blocks.map(readersOf);
  const same = all.every((readers) => sameReaders(readers, all[0]!));
  if (same) return { readers: all[0]!, madePrivate: false };
  return { readers: [], madePrivate: true };
}

const dmAliases = ['spielleitung', 'sl', 'dm', 'gm', 'spielleiter', 'spielleiterin', 'dungeon master', 'game master'];
const everyoneAliases = ['alle', 'alle mitspieler', 'alle mitglieder', 'everyone', 'all'];

function fold(text: string): string {
  return text
    .normalize('NFKD')
    .replace(/\p{M}/gu, '')
    .toLowerCase()
    .trim();
}

/** The people of a campaign as Marie talks about them: "Spielleitung" and the players' character names. */
export class Roster {
  readonly me: QkMember | undefined;

  constructor(readonly members: QkMember[]) {
    this.me = members.find((member) => member.isYou);
  }

  /** Everyone except Marie. */
  get others(): QkMember[] {
    return this.members.filter((member) => !member.isYou);
  }

  nameOf(userId: string): string {
    const member = this.members.find((m) => m.userId.toLowerCase() === userId.toLowerCase());
    if (!member) return `ehemaliges Mitglied (${userId.slice(0, 8)})`;
    if (member.isYou) return 'du';
    const characters = member.characters.map((character) => character.name).filter(Boolean);
    if (member.isDm) return characters.length ? `Spielleitung (${characters.join(', ')})` : 'Spielleitung';
    return characters.length ? characters.join(' / ') : `Mitspieler:in ohne Figur (${member.userId.slice(0, 8)})`;
  }

  describe(readers: Readers): string {
    if (readers.length === 0) return 'privat';
    return `geteilt mit ${normalizeReaders(readers).map((id) => this.nameOf(id)).join(', ')}`;
  }

  describeBlock(block: QkBlock): string {
    if (!block.isOwn) return `von ${this.nameOf(block.createdByUserId)} geschrieben, mit dir geteilt (nur lesen)`;
    return this.describe(block.visibleTo ?? []);
  }

  /** Names, character names or user ids to user ids. "alle" means everyone but Marie. */
  resolve(people: string[]): string[] {
    const ids = new Set<string>();
    const unknown: string[] = [];
    for (const raw of people) {
      const name = fold(raw);
      if (!name) continue;
      if (everyoneAliases.includes(name)) {
        for (const member of this.others) ids.add(member.userId.toLowerCase());
        continue;
      }
      const matches = this.others.filter(
        (member) =>
          member.userId.toLowerCase() === name ||
          (member.isDm && dmAliases.includes(name)) ||
          member.characters.some((character) => fold(character.name) === name),
      );
      if (matches.length === 1) ids.add(matches[0]!.userId.toLowerCase());
      else if (matches.length > 1) throw new UserError(`„${raw}“ passt auf mehrere Personen. Nimm die Nutzer-ID.`);
      else unknown.push(raw);
    }
    if (unknown.length > 0) {
      throw new UserError(
        `Unbekannt in dieser Kampagne: ${unknown.map((name) => `„${name}“`).join(', ')}. ` +
          `Möglich sind: ${this.choices().join(', ')} oder „alle“.`,
      );
    }
    return [...ids].sort();
  }

  choices(): string[] {
    return this.others.map((member) => {
      const characters = member.characters.map((character) => character.name).filter(Boolean);
      if (member.isDm) return '„Spielleitung“';
      return characters.length ? characters.map((name) => `„${name}“`).join(' / ') : `„${member.userId}“`;
    });
  }
}
