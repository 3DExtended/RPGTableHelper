import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { createHarness, pngImage, type Harness } from './harness.js';

/**
 * The share rules: every block keeps exactly its readers when it is moved, merged into another note or
 * reordered; splitting passes the readers on; merging blocks with different readers gives a private block;
 * new blocks are private; only freigabe_aendern widens a share, and only after confirmation.
 */

let h: Harness;
beforeEach(async () => {
  h = await createHarness();
});
afterEach(async () => {
  await h.close();
});

function readersOf(blockId: string): string[] {
  return [...h.fake.block(blockId).visibleTo].sort();
}

describe('moving blocks', () => {
  it('keeps id, content, image and exactly the readers of every block', async () => {
    const source = h.fake.addDocument(h.campaign.id, h.marie, 'Hafenstadt');
    const target = h.fake.addDocument(h.campaign.id, h.marie, 'Küste');
    const privateBlock = h.fake.addText(source.id, h.marie, 'Geheimer Plan: der Leuchtturm ist ein Portal.');
    const forDm = h.fake.addText(source.id, h.marie, 'Für die Spielleitung: Arwen kennt den Hafenmeister.', [h.dm]);
    const image = h.fake.addImage(source.id, h.marie, await pngImage(), 'image/png', 'Karte', [h.ben, h.dm]);
    const imageBytes = Buffer.from(h.fake.block(image.id).image!.data);

    const answer = await h.call('bloecke_verschieben', {
      blockIds: [forDm.id, image.id, privateBlock.id],
      zielDokumentId: target.id,
      version: h.version(target.id),
    });

    expect(answer.isError).toBe(false);
    expect(h.fake.blocksOf(target.id).map((block) => block.id)).toEqual([forDm.id, image.id, privateBlock.id]);
    expect(readersOf(privateBlock.id)).toEqual([]);
    expect(readersOf(forDm.id)).toEqual([h.dm]);
    expect(readersOf(image.id)).toEqual([h.ben, h.dm].sort());
    expect(h.fake.block(forDm.id).markdownText).toBe('Für die Spielleitung: Arwen kennt den Hafenmeister.');
    expect(h.fake.block(image.id).image!.data.equals(imageBytes)).toBe(true);
    expect(answer.text).toContain('jeder behält seine Freigabe');
    expect(answer.text).toContain('Jetzt leer: „Hafenstadt“');
    expect(h.fake.document(source.id).deleted).toBe(false);
  });

  it('refuses blocks someone else wrote and moves nothing', async () => {
    const mine = h.fake.addDocument(h.campaign.id, h.marie, 'Meins');
    const target = h.fake.addDocument(h.campaign.id, h.marie, 'Ziel');
    const theirs = h.fake.addDocument(h.campaign.id, h.dm, 'Handout');
    const mineBlock = h.fake.addText(mine.id, h.marie, 'eigener Text');
    const handout = h.fake.addText(theirs.id, h.dm, 'Ein Handout für Arwen', [h.marie]);

    const answer = await h.call('bloecke_verschieben', {
      blockIds: [mineBlock.id, handout.id],
      zielDokumentId: target.id,
      version: h.version(target.id),
    });

    expect(answer.isError).toBe(true);
    expect(h.fake.block(mineBlock.id).documentId).toBe(mine.id);
    expect(h.fake.block(handout.id).documentId).toBe(theirs.id);
  });

  it('can put moved blocks after a given block', async () => {
    const source = h.fake.addDocument(h.campaign.id, h.marie, 'Quelle');
    const target = h.fake.addDocument(h.campaign.id, h.marie, 'Ziel');
    const first = h.fake.addText(target.id, h.marie, 'eins');
    const last = h.fake.addText(target.id, h.marie, 'drei');
    const moved = h.fake.addText(source.id, h.marie, 'zwei', [h.ben]);

    await h.call('bloecke_verschieben', {
      blockIds: [moved.id],
      zielDokumentId: target.id,
      version: h.version(target.id),
      nachBlockId: first.id,
    });

    expect(h.fake.blocksOf(target.id).map((block) => block.markdownText)).toEqual(['eins', 'zwei', 'drei']);
    expect(readersOf(moved.id)).toEqual([h.ben]);
    expect(last.id).toBeDefined();
  });
});

describe('merging notes', () => {
  it('moves every block with its readers, deletes no source and says which sources are empty', async () => {
    const target = h.fake.addDocument(h.campaign.id, h.marie, 'Gesamt');
    const town = h.fake.addDocument(h.campaign.id, h.marie, 'Stadt');
    const forest = h.fake.addDocument(h.campaign.id, h.marie, 'Wald');
    const a = h.fake.addText(town.id, h.marie, 'Stadt privat');
    const b = h.fake.addText(town.id, h.marie, 'Stadt für alle', [h.dm, h.ben]);
    const c = h.fake.addImage(forest.id, h.marie, await pngImage(), 'image/png', 'Wald', [h.dm]);
    const d = h.fake.addText(forest.id, h.marie, 'Wald privat');

    const answer = await h.call('notizen_zusammenfuehren', {
      zielDokumentId: target.id,
      version: h.version(target.id),
      quellDokumentIds: [town.id, forest.id],
      zwischenueberschriften: true,
    });

    expect(answer.isError).toBe(false);
    const blocks = h.fake.blocksOf(target.id);
    expect(blocks.map((block) => block.markdownText)).toEqual(['## Stadt', 'Stadt privat', 'Stadt für alle', '## Wald', 'Wald', 'Wald privat']);
    expect(readersOf(a.id)).toEqual([]);
    expect(readersOf(b.id)).toEqual([h.dm, h.ben].sort());
    expect(readersOf(c.id)).toEqual([h.dm]);
    expect(readersOf(d.id)).toEqual([]);
    const headings = blocks.filter((block) => block.markdownText?.startsWith('## '));
    expect(headings.every((block) => block.visibleTo.length === 0)).toBe(true);
    expect(h.fake.document(town.id).deleted).toBe(false);
    expect(h.fake.document(forest.id).deleted).toBe(false);
    expect(answer.text).toContain('Nichts wurde gelöscht');
    expect(answer.text).toContain('notizen_loeschen');
  });

  it('leaves blocks of other people in the source', async () => {
    const target = h.fake.addDocument(h.campaign.id, h.marie, 'Gesamt');
    const source = h.fake.addDocument(h.campaign.id, h.marie, 'Quelle');
    const mine = h.fake.addText(source.id, h.marie, 'meins');
    const comment = h.fake.addText(source.id, h.dm, 'Kommentar der SL', [h.marie]);

    const answer = await h.call('notizen_zusammenfuehren', {
      zielDokumentId: target.id,
      version: h.version(target.id),
      quellDokumentIds: [source.id],
    });

    expect(answer.isError).toBe(false);
    expect(h.fake.block(mine.id).documentId).toBe(target.id);
    expect(h.fake.block(comment.id).documentId).toBe(source.id);
    expect(answer.text).toContain('von anderen bleiben dort');
  });
});

describe('merging blocks', () => {
  it('keeps the readers when all blocks have the same', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const one = h.fake.addText(note.id, h.marie, 'Teil eins', [h.dm]);
    const two = h.fake.addText(note.id, h.marie, 'Teil zwei', [h.dm]);

    const answer = await h.call('bloecke_verschmelzen', { dokumentId: note.id, blockIds: [one.id, two.id], version: h.version(note.id) });

    expect(answer.isError).toBe(false);
    const blocks = h.fake.blocksOf(note.id);
    expect(blocks).toHaveLength(1);
    expect(blocks[0]!.markdownText).toBe('Teil eins\n\nTeil zwei');
    expect(blocks[0]!.visibleTo).toEqual([h.dm]);
  });

  it('makes the merged block private when the readers differ, and says so', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const shared = h.fake.addText(note.id, h.marie, 'Das wissen alle', [h.dm, h.ben]);
    const secret = h.fake.addText(note.id, h.marie, 'Das weiß nur Marie');

    const answer = await h.call('bloecke_verschmelzen', { dokumentId: note.id, blockIds: [shared.id, secret.id], version: h.version(note.id) });

    expect(answer.isError).toBe(false);
    const blocks = h.fake.blocksOf(note.id);
    expect(blocks).toHaveLength(1);
    expect(blocks[0]!.visibleTo).toEqual([]);
    expect(blocks[0]!.markdownText).toContain('Das weiß nur Marie');
    expect(answer.text).toContain('unterschiedliche Freigaben');
    expect(answer.text).toContain('privat');
  });

  it('also treats a subset of readers as a different status', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const both = h.fake.addText(note.id, h.marie, 'eins', [h.dm, h.ben]);
    const dmOnly = h.fake.addText(note.id, h.marie, 'zwei', [h.dm]);

    await h.call('bloecke_verschmelzen', { dokumentId: note.id, blockIds: [both.id, dmOnly.id], version: h.version(note.id) });

    expect(h.fake.blocksOf(note.id)[0]!.visibleTo).toEqual([]);
  });
});

describe('splitting a block', () => {
  it('gives every part the readers of the original, in place', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const before = h.fake.addText(note.id, h.marie, 'davor');
    const long = h.fake.addText(note.id, h.marie, 'A und B und C', [h.dm]);
    const after = h.fake.addText(note.id, h.marie, 'danach', [h.ben]);

    const answer = await h.call('block_aufteilen', {
      dokumentId: note.id,
      blockId: long.id,
      teile: ['A', 'B', 'C'],
      version: h.version(note.id),
    });

    expect(answer.isError).toBe(false);
    const blocks = h.fake.blocksOf(note.id);
    expect(blocks.map((block) => block.markdownText)).toEqual(['davor', 'A', 'B', 'C', 'danach']);
    expect(blocks[1]!.id).toBe(long.id);
    for (const part of blocks.slice(1, 4)) expect(part.visibleTo).toEqual([h.dm]);
    expect(readersOf(before.id)).toEqual([]);
    expect(readersOf(after.id)).toEqual([h.ben]);
  });
});

describe('editing a block', () => {
  it('keeps its readers', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const block = h.fake.addText(note.id, h.marie, 'alt', [h.dm]);

    const answer = await h.call('block_bearbeiten', { dokumentId: note.id, blockId: block.id, neuerText: 'neu', version: h.version(note.id) });

    expect(answer.isError).toBe(false);
    expect(h.fake.block(block.id).markdownText).toBe('neu');
    expect(readersOf(block.id)).toEqual([h.dm]);
    expect(answer.text).toContain('sichtbar');
  });

  it('turns the block private when content of a block its readers may not see was used', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const shared = h.fake.addText(note.id, h.marie, 'Die Stadt hat drei Tore.', [h.dm, h.ben]);
    const other = h.fake.addDocument(h.campaign.id, h.marie, 'Geheimnisse');
    const secret = h.fake.addText(other.id, h.marie, 'Das Nordtor ist verflucht.');

    const answer = await h.call('block_bearbeiten', {
      dokumentId: note.id,
      blockId: shared.id,
      neuerText: 'Die Stadt hat drei Tore; eines davon ist verflucht.',
      version: h.version(note.id),
      verwendeteQuellbloecke: [secret.id],
    });

    expect(answer.isError).toBe(false);
    expect(readersOf(shared.id)).toEqual([]);
    expect(answer.text).toContain('jetzt privat');
    expect(answer.text).toContain(secret.id);
  });

  it('keeps the readers when every source is readable by them', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const target = h.fake.addText(note.id, h.marie, 'Für die SL', [h.dm]);
    const wider = h.fake.addText(note.id, h.marie, 'Für alle', [h.dm, h.ben]);

    await h.call('block_bearbeiten', {
      dokumentId: note.id,
      blockId: target.id,
      neuerText: 'Für die SL, und für alle',
      version: h.version(note.id),
      verwendeteQuellbloecke: [wider.id],
    });

    expect(readersOf(target.id)).toEqual([h.dm]);
  });

  it('refuses to copy a private passage into a shared block without saying so', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const shared = h.fake.addText(note.id, h.marie, 'Öffentliche Beschreibung der Stadt.', [h.dm, h.ben]);
    const other = h.fake.addDocument(h.campaign.id, h.marie, 'Geheim');
    h.fake.addText(other.id, h.marie, 'Der Bürgermeister ist in Wahrheit ein Vampir aus dem Osten und trinkt nachts Blut.');
    const versionBefore = h.version(note.id);

    const answer = await h.call('block_bearbeiten', {
      dokumentId: note.id,
      blockId: shared.id,
      neuerText: 'Öffentliche Beschreibung. Der Bürgermeister ist in Wahrheit ein Vampir aus dem Osten und trinkt nachts Blut.',
      version: versionBefore,
    });

    expect(answer.isError).toBe(true);
    expect(answer.text).toContain('wörtliche Passagen');
    expect(h.fake.block(shared.id).markdownText).toBe('Öffentliche Beschreibung der Stadt.');
    expect(h.version(note.id)).toBe(versionBefore);
  });

  it('may copy a private passage into a private block', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const target = h.fake.addText(note.id, h.marie, 'privat');
    h.fake.addText(note.id, h.marie, 'Der Bürgermeister ist in Wahrheit ein Vampir aus dem Osten.', [h.dm]);

    const answer = await h.call('block_bearbeiten', {
      dokumentId: note.id,
      blockId: target.id,
      neuerText: 'Der Bürgermeister ist in Wahrheit ein Vampir aus dem Osten.',
      version: h.version(note.id),
    });

    expect(answer.isError).toBe(false);
    expect(readersOf(target.id)).toEqual([]);
  });
});

describe('new blocks', () => {
  it('are private, also with a note created in one go', async () => {
    const created = await h.call('notiz_anlegen', { titel: 'Neu', gruppe: 'Lore', bloecke: ['eins', 'zwei'] });
    expect(created.isError).toBe(false);
    const document = h.fake.documents.find((candidate) => candidate.title === 'Neu')!;
    const blocks = h.fake.blocksOf(document.id);
    expect(blocks.map((block) => block.markdownText)).toEqual(['eins', 'zwei']);
    expect(blocks.every((block) => block.visibleTo.length === 0)).toBe(true);

    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const first = h.fake.addText(note.id, h.marie, 'eins', [h.dm]);
    h.fake.addText(note.id, h.marie, 'drei', [h.dm]);
    await h.call('bloecke_hinzufuegen', { dokumentId: note.id, bloecke: ['zwei'], nachBlockId: first.id });
    const added = h.fake.blocksOf(note.id);
    expect(added.map((block) => block.markdownText)).toEqual(['eins', 'zwei', 'drei']);
    expect(added[1]!.visibleTo).toEqual([]);
  });
});

describe('compiling an overall document', () => {
  it('copies everything as private by default and leaves the sources alone', async () => {
    const town = h.fake.addDocument(h.campaign.id, h.marie, 'Stadt');
    const shared = h.fake.addText(town.id, h.marie, 'Für alle', [h.dm, h.ben]);
    h.fake.addImage(town.id, h.marie, await pngImage(), 'image/png', 'Plan', [h.dm]);

    const answer = await h.call('gesamtdokument_erstellen', { titel: 'Kompendium', gruppe: 'Lore', quellDokumentIds: [town.id] });

    expect(answer.isError).toBe(false);
    const compendium = h.fake.documents.find((document) => document.title === 'Kompendium')!;
    const blocks = h.fake.blocksOf(compendium.id);
    expect(blocks.map((block) => block.type)).toEqual(['text', 'text', 'image']);
    expect(blocks.every((block) => block.visibleTo.length === 0)).toBe(true);
    expect(readersOf(shared.id)).toEqual([h.dm, h.ben].sort());
    expect(h.fake.blocksOf(town.id)).toHaveLength(2);
  });

  it('copies exactly the readers of each block when asked to', async () => {
    const town = h.fake.addDocument(h.campaign.id, h.marie, 'Stadt');
    h.fake.addText(town.id, h.marie, 'Für alle', [h.dm, h.ben]);
    h.fake.addText(town.id, h.marie, 'Privat');
    h.fake.addImage(town.id, h.marie, await pngImage(), 'image/png', 'Plan', [h.dm]);

    await h.call('gesamtdokument_erstellen', {
      titel: 'Kompendium',
      gruppe: 'Lore',
      quellDokumentIds: [town.id],
      freigabenUebernehmen: true,
      einleitung: 'Einleitung',
    });

    const compendium = h.fake.documents.find((document) => document.title === 'Kompendium')!;
    const blocks = h.fake.blocksOf(compendium.id);
    expect(blocks.map((block) => block.markdownText)).toEqual(['Einleitung', '## Stadt', 'Für alle', 'Privat', 'Plan']);
    expect(blocks.map((block) => [...block.visibleTo].sort())).toEqual([[], [], [h.dm, h.ben].sort(), [], [h.dm]]);
  });
});

describe('changing a share', () => {
  it('widens only after confirmation, with the code for exactly that change', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const block = h.fake.addText(note.id, h.marie, 'bald für Borin');
    const other = h.fake.addText(note.id, h.marie, 'bleibt privat');

    const preview = await h.call('freigabe_aendern', {
      dokumentId: note.id,
      blockIds: [block.id],
      modus: 'hinzufuegen',
      personen: ['Borin'],
      version: h.version(note.id),
    });
    expect(preview.isError).toBe(false);
    expect(preview.text).toContain('privat → geteilt mit Borin');
    expect(readersOf(block.id)).toEqual([]);

    const code = h.codeIn(preview);
    const wrongRequest = await h.call('freigabe_aendern', {
      dokumentId: note.id,
      blockIds: [other.id],
      modus: 'hinzufuegen',
      personen: ['Borin'],
      version: h.version(note.id),
      bestaetigung: code,
    });
    expect(wrongRequest.isError).toBe(true);
    expect(readersOf(other.id)).toEqual([]);

    const done = await h.call('freigabe_aendern', {
      dokumentId: note.id,
      blockIds: [block.id],
      modus: 'hinzufuegen',
      personen: ['Borin'],
      version: h.version(note.id),
      bestaetigung: code,
    });
    expect(done.isError).toBe(false);
    expect(readersOf(block.id)).toEqual([h.ben]);

    const reused = await h.call('freigabe_aendern', {
      dokumentId: note.id,
      blockIds: [block.id],
      modus: 'setzen',
      personen: ['alle'],
      version: h.version(note.id),
      bestaetigung: code,
    });
    expect(reused.isError).toBe(true);
    expect(readersOf(block.id)).toEqual([h.ben]);
  });

  it('narrows at once', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const block = h.fake.addImage(note.id, h.marie, await pngImage(), 'image/png', 'Karte', [h.dm, h.ben]);

    const answer = await h.call('freigabe_aendern', {
      dokumentId: note.id,
      blockIds: [block.id],
      modus: 'entfernen',
      personen: ['Spielleitung'],
      version: h.version(note.id),
    });

    expect(answer.isError).toBe(false);
    expect(readersOf(block.id)).toEqual([h.ben]);
    expect(h.fake.block(block.id).markdownText).toBe('Karte');
  });

  it('warns in the preview when the text quotes something the new readers may not see', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    h.fake.addText(note.id, h.marie, 'Die Königin plant einen Verrat am Rat der Sieben Türme.');
    const block = h.fake.addText(note.id, h.marie, 'Notiz: Die Königin plant einen Verrat am Rat der Sieben Türme.');

    const preview = await h.call('freigabe_aendern', {
      dokumentId: note.id,
      blockIds: [block.id],
      modus: 'setzen',
      personen: ['Spielleitung'],
      version: h.version(note.id),
    });

    expect(preview.text).toContain('Achtung: enthält Passagen');
  });

  it('rejects unknown people', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const block = h.fake.addText(note.id, h.marie, 'x');
    const answer = await h.call('freigabe_aendern', {
      dokumentId: note.id,
      blockIds: [block.id],
      modus: 'hinzufuegen',
      personen: ['Gandalf'],
      version: h.version(note.id),
    });
    expect(answer.isError).toBe(true);
    expect(answer.text).toContain('Borin');
  });
});

describe('reordering', () => {
  it('changes only the order', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const a = h.fake.addText(note.id, h.marie, 'a', [h.dm]);
    const b = h.fake.addText(note.id, h.marie, 'b');

    await h.call('bloecke_anordnen', { dokumentId: note.id, reihenfolge: [b.id, a.id], version: h.version(note.id) });

    expect(h.fake.blocksOf(note.id).map((block) => block.id)).toEqual([b.id, a.id]);
    expect(readersOf(a.id)).toEqual([h.dm]);
    expect(readersOf(b.id)).toEqual([]);
  });
});
