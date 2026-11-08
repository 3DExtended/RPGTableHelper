import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import sharp from 'sharp';
import { ConfirmationStore } from '../src/domain/confirmations.js';
import { NotesService } from '../src/domain/notes.js';
import { ImageGenerator } from '../src/images/generate.js';
import { UploadLinks } from '../src/images/uploadLinks.js';
import type { ToolContext } from '../src/mcp/common.js';
import { buildMcpServer } from '../src/mcp/server.js';
import { QuestKeeperClient } from '../src/questkeeper/client.js';
import { FakeQuestKeeper } from './fakeQuestKeeper.js';

export const marieKey = 'qk_marie_test_key_1234567890';

export interface ToolAnswer {
  text: string;
  isError: boolean;
  images: { data: string; mimeType: string }[];
}

export async function pngImage(width = 64, height = 48, color = '#884422'): Promise<Buffer> {
  return sharp({ create: { width, height, channels: 3, background: color } }).png().toBuffer();
}

/** A table: DM Peter, players Marie (Arwen) and Ben (Borin); and an MCP client talking to the tools. */
export async function createHarness(options: { campaignIds?: (fake: FakeQuestKeeper) => string[]; fetchImpl?: typeof fetch } = {}) {
  const fake = new FakeQuestKeeper();
  const marie = fake.addUser('Marie', marieKey);
  const dm = fake.addUser('Peter');
  const ben = fake.addUser('Ben');
  const campaign = fake.addCampaign('Schattenlande', dm, [
    { userId: marie, characters: ['Arwen'] },
    { userId: ben, characters: ['Borin'] },
  ]);
  const apiBase = await fake.start();
  const dataDir = fs.mkdtempSync(path.join(os.tmpdir(), 'qk-mcp-test-'));
  const qk = new QuestKeeperClient(apiBase, marieKey, { maxRetryWaitSeconds: 1 });
  const context: ToolContext = {
    notes: new NotesService(qk, { campaignIds: options.campaignIds?.(fake) ?? [] }),
    confirmations: new ConfirmationStore(),
    uploads: new UploadLinks('https://notizen.test'),
    generator: new ImageGenerator(
      {
        apiKey: options.fetchImpl ? 'sk-test-openai-key' : undefined,
        model: 'gpt-image-test',
        defaultQuality: 'medium',
        maxPerDay: 2,
        baseUrl: 'https://openai.test/v1',
        dataDir,
      },
      options.fetchImpl,
    ),
  };
  const server = buildMcpServer(context);
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const client = new Client({ name: 'test', version: '1.0.0' });
  await Promise.all([server.connect(serverTransport), client.connect(clientTransport)]);

  const call = async (name: string, args: Record<string, unknown> = {}): Promise<ToolAnswer> => {
    const result = (await client.callTool({ name, arguments: args })) as {
      content: { type: string; text?: string; data?: string; mimeType?: string }[];
      isError?: boolean;
    };
    return {
      text: result.content
        .filter((part) => part.type === 'text')
        .map((part) => part.text)
        .join('\n'),
      isError: result.isError === true,
      images: result.content
        .filter((part) => part.type === 'image')
        .map((part) => ({ data: part.data!, mimeType: part.mimeType! })),
    };
  };

  /** The confirmation code in a two-step answer. */
  const codeIn = (answer: ToolAnswer): string => {
    const match = /bestaetigung: "([A-Z0-9]{3}-[A-Z0-9]{3})"/.exec(answer.text);
    if (!match) throw new Error(`no code in: ${answer.text}`);
    return match[1]!;
  };

  const version = (documentId: string) => fake.document(documentId).lastModifiedAt;

  const close = async () => {
    await client.close();
    await server.close();
    await fake.stop();
    fs.rmSync(dataDir, { recursive: true, force: true });
  };

  return { fake, marie, dm, ben, campaign, call, codeIn, version, context, client, dataDir, close };
}

export type Harness = Awaited<ReturnType<typeof createHarness>>;
