/**
 * The MCP server against an in-memory Questkeeper with sample notes, for trying it out with the MCP Inspector
 * without a backend or real data:   npm run dev:fake
 *
 * Login: password "dev-passwort-123", client id "inspector" (or the Inspector's own metadata), loopback
 * redirects allowed. Nothing is stored outside a temporary folder.
 */
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createApp } from '../src/app.js';
import { composeDependencies } from '../src/compose.js';
import { hashPassword } from '../src/auth/password.js';
import { loadConfig } from '../src/config.js';
import { FakeQuestKeeper } from '../test/fakeQuestKeeper.js';

const port = Number(process.env.PORT ?? 8787);
const password = 'dev-passwort-123';
const apiKey = 'qk_dev_marie_key_0000000000';

const fake = new FakeQuestKeeper();
const marie = fake.addUser('Marie', apiKey);
const dm = fake.addUser('Peter');
const ben = fake.addUser('Ben');
const campaign = fake.addCampaign('Schattenlande', dm, [
  { userId: marie, characters: ['Arwen'] },
  { userId: ben, characters: ['Borin'] },
]);
const harbour = fake.addDocument(campaign.id, marie, 'Hafenstadt Velmar', 'Orte');
fake.addText(harbour.id, marie, '# Velmar\nEine Hafenstadt im Nebel. #Hafen #Handel', [dm, ben]);
fake.addText(harbour.id, marie, 'Nur für die Spielleitung: Arwen kennt den Hafenmeister von früher.', [dm]);
fake.addText(harbour.id, marie, 'Privat: Der Leuchtturm ist ein Portal in die Schattenwelt.');
const tower = fake.addDocument(campaign.id, marie, 'Der Leuchtturm', 'Orte');
fake.addText(tower.id, marie, 'Alt, schief, und nachts leuchtet er grün. #Portal');
const people = fake.addDocument(campaign.id, marie, 'Hafenmeister Oskar', 'Leute');
fake.addText(people.id, marie, 'Mürrisch, bestechlich, liebt Katzen.', [dm, ben]);
const handout = fake.addDocument(campaign.id, dm, 'Handout der SL', 'SL');
fake.addText(handout.id, dm, 'Dieses Dokument gehört der SL und taucht im MCP-Server nicht auf.', [marie]);

const apiBase = await fake.start();
const dataDir = fs.mkdtempSync(path.join(os.tmpdir(), 'qk-mcp-dev-'));
const config = loadConfig({
  ...process.env,
  PORT: String(port),
  PUBLIC_BASE_URL: process.env.PUBLIC_BASE_URL ?? `http://localhost:${port}`,
  DATA_DIR: dataDir,
  LOGIN_PASSWORD_HASH: await hashPassword(password),
  QK_API_BASE_URL: apiBase,
  QK_API_KEY: apiKey,
  ALLOW_LOOPBACK_REDIRECTS: 'true',
  STATIC_CLIENT_ID: 'inspector',
  ALLOWED_CLIENT_ID_HOSTS: process.env.ALLOWED_CLIENT_ID_HOSTS ?? 'claude.ai',
});
const app = createApp(composeDependencies(config));
app.listen(port, '127.0.0.1', () => {
  process.stdout.write(
    [
      '',
      `MCP-Server mit Beispieldaten: ${config.mcpUrl}`,
      `Passwort: ${password}   Client-ID (statisch): inspector`,
      'Inspector:  npx @modelcontextprotocol/inspector   -> Transport "Streamable HTTP", URL oben, "Open Auth Settings" -> Quick OAuth Flow',
      `Daten (temporär): ${dataDir}`,
      '',
    ].join('\n'),
  );
});
