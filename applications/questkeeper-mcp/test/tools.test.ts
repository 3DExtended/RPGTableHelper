import sharp from 'sharp';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { configureLog } from '../src/log.js';
import { createHarness, pngImage, type Harness } from './harness.js';

let h: Harness;
beforeEach(async () => {
  h = await createHarness();
});
afterEach(async () => {
  await h.close();
});

describe('versions', () => {
  it('changes nothing when the note changed since it was read, and names the current version', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const block = h.fake.addText(note.id, h.marie, 'alt');
    const seen = h.version(note.id);
    h.fake.addText(note.id, h.marie, 'in der App ergänzt');

    const answer = await h.call('block_bearbeiten', { dokumentId: note.id, blockId: block.id, neuerText: 'neu', version: seen });

    expect(answer.isError).toBe(true);
    expect(answer.text).toContain('inzwischen geändert');
    expect(answer.text).toContain(h.version(note.id));
    expect(h.fake.block(block.id).markdownText).toBe('alt');
  });

  it('passes the version to Questkeeper, which refuses a change made in between', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Alt');
    const seen = h.version(note.id);
    const answer = await h.call('notiz_umbenennen', { dokumentId: note.id, neuerTitel: 'Neu', version: seen });
    expect(answer.isError).toBe(false);
    expect(h.fake.document(note.id).title).toBe('Neu');

    const again = await h.call('notiz_umbenennen', { dokumentId: note.id, neuerTitel: 'Noch neuer', version: seen });
    expect(again.isError).toBe(true);
    expect(h.fake.document(note.id).title).toBe('Neu');
  });

  it('reads versions out of notizen_lesen', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    h.fake.addText(note.id, h.marie, 'Hallo', [h.dm]);
    const answer = await h.call('notizen_lesen', { dokumentIds: [note.id] });
    expect(answer.text).toContain(`Version: ${h.version(note.id)}`);
    expect(answer.text).toContain('geteilt mit Spielleitung');
    expect(answer.text).toContain('Hallo');
  });
});

describe('only Marie’s own notes', () => {
  it('hides other people’s notes, even shared ones', async () => {
    const mine = h.fake.addDocument(h.campaign.id, h.marie, 'Meine Notiz');
    const theirs = h.fake.addDocument(h.campaign.id, h.dm, 'Notiz der SL');
    h.fake.addText(theirs.id, h.dm, 'für Arwen', [h.marie]);

    const list = await h.call('notizen_auflisten');
    expect(list.text).toContain('Meine Notiz');
    expect(list.text).not.toContain('Notiz der SL');

    const read = await h.call('notizen_lesen', { dokumentIds: [theirs.id] });
    expect(read.isError).toBe(true);
    expect(read.text).toContain('nicht gefunden');

    const rename = await h.call('notiz_umbenennen', { dokumentId: theirs.id, neuerTitel: 'x', version: h.version(theirs.id) });
    expect(rename.isError).toBe(true);
    expect(mine.id).toBeDefined();
  });

  it('checks ownership again on every write, not only when listing', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Meins');
    const block = h.fake.addText(note.id, h.marie, 'Text');
    const version = h.version(note.id);
    // The note changes hands between listing and writing.
    h.fake.document(note.id).createdByUserId = h.ben;

    const answer = await h.call('block_bearbeiten', { dokumentId: note.id, blockId: block.id, neuerText: 'x', version });
    expect(answer.isError).toBe(true);
    expect(h.fake.block(block.id).markdownText).toBe('Text');
  });

  it('keeps to the campaigns allowed by QK_CAMPAIGN_IDS', async () => {
    await h.close();
    h = await createHarness({ campaignIds: (fake) => [fake.campaigns[0]!.id] });
    const other = h.fake.addCampaign('Andere Runde', h.ben, [{ userId: h.marie, characters: ['Mira'] }]);
    const outside = h.fake.addDocument(other.id, h.marie, 'Außerhalb');

    const campaigns = await h.call('kampagnen_auflisten');
    expect(campaigns.text).toContain('Schattenlande');
    expect(campaigns.text).not.toContain('Andere Runde');
    const read = await h.call('notizen_lesen', { dokumentIds: [outside.id] });
    expect(read.isError).toBe(true);
  });

  it('asks for the campaign when Marie is in several', async () => {
    const second = h.fake.addCampaign('Zweite Runde', h.ben, [{ userId: h.marie, characters: ['Mira'] }]);
    h.fake.addDocument(second.id, h.marie, 'Zweite');

    const ambiguous = await h.call('notizen_auflisten');
    expect(ambiguous.isError).toBe(true);
    expect(ambiguous.text).toContain('Zweite Runde');

    const chosen = await h.call('notizen_auflisten', { kampagne: 'zweite' });
    expect(chosen.text).toContain('„Zweite“');
  });
});

describe('deleting', () => {
  it('deletes notes only with the code from the first step', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Weg damit');
    h.fake.addText(note.id, h.marie, 'x', [h.dm]);

    const preview = await h.call('notizen_loeschen', { dokumentIds: [note.id] });
    expect(preview.text).toContain('Weg damit');
    expect(preview.text).toContain('geteilt');
    expect(h.fake.document(note.id).deleted).toBe(false);

    const wrong = await h.call('notizen_loeschen', { dokumentIds: [note.id], bestaetigung: 'AAA-AAA' });
    expect(wrong.isError).toBe(true);
    expect(h.fake.document(note.id).deleted).toBe(false);

    const done = await h.call('notizen_loeschen', { dokumentIds: [note.id], bestaetigung: h.codeIn(preview) });
    expect(done.isError).toBe(false);
    expect(h.fake.document(note.id).deleted).toBe(true);
  });

  it('keeps a note that changed between preview and confirmation', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Bleibt');
    const preview = await h.call('notizen_loeschen', { dokumentIds: [note.id] });
    h.fake.addText(note.id, h.marie, 'gerade in der App geschrieben');

    const answer = await h.call('notizen_loeschen', { dokumentIds: [note.id], bestaetigung: h.codeIn(preview) });

    expect(answer.text).toContain('Nicht gelöscht');
    expect(h.fake.document(note.id).deleted).toBe(false);
  });

  it('deletes blocks only after confirmation', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    const block = h.fake.addText(note.id, h.marie, 'Absatz');
    const keep = h.fake.addText(note.id, h.marie, 'bleibt');
    const version = h.version(note.id);

    const preview = await h.call('block_loeschen', { dokumentId: note.id, blockIds: [block.id], version });
    expect(h.fake.blocksOf(note.id)).toHaveLength(2);
    await h.call('block_loeschen', { dokumentId: note.id, blockIds: [block.id], version, bestaetigung: h.codeIn(preview) });
    expect(h.fake.blocksOf(note.id).map((b) => b.id)).toEqual([keep.id]);
  });
});

describe('groups', () => {
  it('lists, creates, renames and moves', async () => {
    const town = h.fake.addDocument(h.campaign.id, h.marie, 'Stadt', 'Orte');
    const forest = h.fake.addDocument(h.campaign.id, h.marie, 'Wald', 'Orte');
    const person = h.fake.addDocument(h.campaign.id, h.marie, 'Hafenmeister', 'Leute');
    h.fake.addDocument(h.campaign.id, h.dm, 'SL-Notiz', 'SL-Gruppe');

    const groups = await h.call('gruppen_auflisten');
    expect(groups.text).toContain('„Orte“ (2)');
    expect(groups.text).toContain('„Leute“ (1)');
    expect(groups.text).not.toContain('SL-Gruppe');

    await h.call('gruppe_umbenennen', { alterName: 'orte', neuerName: 'Schauplätze' });
    expect(h.fake.document(town.id).groupName).toBe('Schauplätze');
    expect(h.fake.document(forest.id).groupName).toBe('Schauplätze');

    await h.call('notizen_verschieben', { dokumentIds: [person.id, forest.id], zielGruppe: 'Gemischt' });
    expect(h.fake.document(person.id).groupName).toBe('Gemischt');

    const created = await h.call('gruppe_anlegen', { name: 'Fraktionen', ersteNotizTitel: 'Diebesgilde' });
    expect(created.isError).toBe(false);
    expect(h.fake.documents.find((document) => document.title === 'Diebesgilde')?.groupName).toBe('Fraktionen');
  });

  it('deletes a group only after confirmation and never its notes', async () => {
    const town = h.fake.addDocument(h.campaign.id, h.marie, 'Stadt', 'Orte');
    h.fake.addText(town.id, h.marie, 'Inhalt');

    const preview = await h.call('gruppe_loeschen', { name: 'Orte' });
    expect(preview.text).toContain('gelöscht wird nichts');
    expect(h.fake.document(town.id).groupName).toBe('Orte');

    await h.call('gruppe_loeschen', { name: 'Orte', bestaetigung: h.codeIn(preview) });
    expect(h.fake.document(town.id).groupName).toBe('Sonstiges');
    expect(h.fake.document(town.id).deleted).toBe(false);
    expect(h.fake.blocksOf(town.id)).toHaveLength(1);
  });
});

describe('search', () => {
  it('finds by words, phrases, tags and group, ignoring case and accents', async () => {
    const castle = h.fake.addDocument(h.campaign.id, h.marie, 'Château Noir', 'Orte');
    h.fake.addText(castle.id, h.marie, 'Ein düsteres Schloss am See. #Vampire #Adel', [h.dm]);
    const inn = h.fake.addDocument(h.campaign.id, h.marie, 'Gasthaus', 'Orte');
    h.fake.addText(inn.id, h.marie, 'Hier trifft man den alten Schmied. #Handel');
    const people = h.fake.addDocument(h.campaign.id, h.marie, 'Schmied Otto', 'Leute');
    h.fake.addText(people.id, h.marie, 'Der alte Schmied kennt das Schloss.');

    const byWords = await h.call('notizen_durchsuchen', { suche: 'chateau' });
    expect(byWords.text).toContain('Château Noir');
    expect(byWords.text).toContain('Treffer im Titel');

    const byTag = await h.call('notizen_durchsuchen', { tags: ['#vampire'] });
    expect(byTag.text).toContain('Château Noir');
    expect(byTag.text).toContain('geteilt mit Spielleitung');
    expect(byTag.text).not.toContain('Gasthaus');

    const byPhrase = await h.call('notizen_durchsuchen', { suche: '"alten Schmied"' });
    expect(byPhrase.text).toContain('Gasthaus');
    expect(byPhrase.text).not.toContain('Schmied Otto');

    const byGroup = await h.call('notizen_durchsuchen', { suche: 'schmied', gruppen: ['Leute'] });
    expect(byGroup.text).toContain('Schmied Otto');
    expect(byGroup.text).not.toContain('Gasthaus');
  });
});

describe('reading several notes', () => {
  it('reads them in one go and cuts long answers with a pointer to read on', async () => {
    const a = h.fake.addDocument(h.campaign.id, h.marie, 'Erste');
    const b = h.fake.addDocument(h.campaign.id, h.marie, 'Zweite');
    h.fake.addText(a.id, h.marie, 'kurz');
    for (let index = 0; index < 30; index++) h.fake.addText(b.id, h.marie, `${index} ${'x'.repeat(5000)}`);

    const both = await h.call('notizen_lesen', { dokumentIds: [a.id, b.id] });
    expect(both.text).toContain('# Erste');
    expect(both.text).toContain('# Zweite');
    expect(both.text).toContain('abBlock');
    expect(both.text.length).toBeLessThan(130_000);

    const rest = await h.call('notizen_lesen', { dokumentIds: [b.id], abBlock: 25 });
    expect(rest.text).toContain('⟦Block 25');
  });
});

describe('images', () => {
  it('shows images as image content', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Karten');
    h.fake.addImage(note.id, h.marie, await pngImage(2400, 1600), 'image/png', 'Weltkarte', [h.dm]);

    const list = await h.call('bilder_auflisten', { dokumentId: note.id });
    expect(list.text).toContain('Weltkarte');

    const view = await h.call('bild_ansehen', { dokumentId: note.id });
    expect(view.isError).toBe(false);
    expect(view.images).toHaveLength(1);
    expect(view.images[0]!.mimeType).toBe('image/jpeg');
    const meta = await sharp(Buffer.from(view.images[0]!.data, 'base64')).metadata();
    expect(Math.max(meta.width!, meta.height!)).toBeLessThanOrEqual(1024);
  });

  it('uploads a small base64 image as a private block, without metadata', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Bilder');
    const withExif = await sharp({ create: { width: 40, height: 30, channels: 3, background: '#336699' } })
      .jpeg()
      .withMetadata({ exif: { IFD0: { Copyright: 'GPS-Test' } } })
      .toBuffer();

    const answer = await h.call('bild_hochladen', { dokumentId: note.id, base64: withExif.toString('base64'), bildunterschrift: 'Skizze' });

    expect(answer.isError).toBe(false);
    expect(answer.images).toHaveLength(1);
    const [block] = h.fake.blocksOf(note.id);
    expect(block!.type).toBe('image');
    expect(block!.visibleTo).toEqual([]);
    expect(block!.markdownText).toBe('Skizze');
    const stored = await sharp(block!.image!.data).metadata();
    expect(stored.exif).toBeUndefined();
  });

  it('does not load links to internal addresses', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Bilder');
    for (const url of ['https://127.0.0.1/x.png', 'https://[::1]/x.png', 'https://10.1.2.3/x.png', 'http://example.com/x.png']) {
      const answer = await h.call('bild_hochladen', { dokumentId: note.id, url });
      expect(answer.isError, url).toBe(true);
    }
    expect(h.fake.blocksOf(note.id)).toHaveLength(0);
  });

  it('hands out a one-time upload link', async () => {
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Bilder');
    const answer = await h.call('bild_upload_link', { dokumentId: note.id });
    expect(answer.text).toMatch(/https:\/\/notizen\.test\/upload\/[A-Za-z0-9_-]{20,}/);
  });

  it('generates an image into a private block and keeps to the daily cap', async () => {
    await h.close();
    const png = await pngImage(1024, 1024, '#225588');
    const calls: { body: Record<string, unknown>; auth: string | null }[] = [];
    const fetchImpl = (async (url: string | URL | Request, init?: RequestInit) => {
      if (String(url).startsWith('https://openai.test/')) {
        calls.push({ body: JSON.parse(String(init?.body)), auth: new Headers(init?.headers).get('authorization') });
        return new Response(JSON.stringify({ data: [{ b64_json: png.toString('base64') }] }), { status: 200 });
      }
      return fetch(url, init);
    }) as typeof fetch;
    h = await createHarness({ fetchImpl });
    const note = h.fake.addDocument(h.campaign.id, h.marie, 'Bilder');

    const first = await h.call('bild_generieren', { dokumentId: note.id, beschreibung: 'Ein Leuchtturm im Sturm', format: 'querformat' });
    expect(first.isError).toBe(false);
    expect(first.images).toHaveLength(1);
    expect(calls[0]!.body).toMatchObject({ model: 'gpt-image-test', size: '1536x1024', prompt: 'Ein Leuchtturm im Sturm' });
    expect(calls[0]!.auth).toBe('Bearer sk-test-openai-key');
    expect(h.fake.blocksOf(note.id)[0]!.visibleTo).toEqual([]);

    await h.call('bild_generieren', { dokumentId: note.id, beschreibung: 'Zweites Bild' });
    const third = await h.call('bild_generieren', { dokumentId: note.id, beschreibung: 'Drittes Bild' });
    expect(third.isError).toBe(true);
    expect(third.text).toContain('Tageslimit');
    expect(calls).toHaveLength(2);
  });
});

describe('logging', () => {
  it('never writes note content, titles or captions', async () => {
    const lines: string[] = [];
    configureLog({ sink: (line) => lines.push(line) });
    try {
      const note = h.fake.addDocument(h.campaign.id, h.marie, 'Titel-Geheimnis-42');
      const block = h.fake.addText(note.id, h.marie, 'Inhalt-Geheimnis-42', [h.dm]);
      await h.call('notizen_lesen', { dokumentIds: [note.id] });
      await h.call('notizen_durchsuchen', { suche: 'Geheimnis-42' });
      await h.call('block_bearbeiten', { dokumentId: note.id, blockId: block.id, neuerText: 'Neu-Geheimnis-42', version: h.version(note.id) });
      await h.call('bloecke_hinzufuegen', { dokumentId: note.id, bloecke: ['Mehr-Geheimnis-42'] });
      await h.call('block_bearbeiten', { dokumentId: note.id, blockId: block.id, neuerText: 'Fehler-Geheimnis-42', version: '2000-01-01T00:00:00+00:00' });
    } finally {
      configureLog({ sink: () => undefined });
    }
    expect(lines.length).toBeGreaterThan(3);
    for (const line of lines) {
      expect(line).not.toContain('Geheimnis-42');
      expect(line).not.toContain('qk_marie');
    }
  });
});

describe('Questkeeper rate limit', () => {
  it('waits and retries once on 429', async () => {
    h.fake.addDocument(h.campaign.id, h.marie, 'Notiz');
    h.fake.rateLimitNext(1);
    const answer = await h.call('notizen_auflisten');
    expect(answer.isError).toBe(false);
    expect(answer.text).toContain('Notiz');
  });
});
