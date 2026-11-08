import { createHash, randomBytes } from 'node:crypto';
import fs from 'node:fs';
import { createServer } from 'node:http';
import type { AddressInfo } from 'node:net';
import os from 'node:os';
import path from 'node:path';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StreamableHTTPClientTransport } from '@modelcontextprotocol/sdk/client/streamableHttp.js';
import { afterEach, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { ClientRegistry } from '../src/auth/clients.js';
import { hashPassword } from '../src/auth/password.js';
import { LoginThrottle } from '../src/auth/rateLimit.js';
import { TokenStore, revokeAllLogins } from '../src/auth/tokenStore.js';
import { TotpVerifier, newTotpSecret, totpCode } from '../src/auth/totp.js';
import { ConfirmationStore } from '../src/domain/confirmations.js';
import { NotesService } from '../src/domain/notes.js';
import { ImageGenerator } from '../src/images/generate.js';
import { UploadLinks } from '../src/images/uploadLinks.js';
import { QuestKeeperClient } from '../src/questkeeper/client.js';
import { FakeQuestKeeper } from './fakeQuestKeeper.js';
import { marieKey, pngImage } from './harness.js';

const password = 'richtig-langes-passwort';
const staticClientId = 'questkeeper-inspector';
const loopback = 'http://localhost:6274/oauth/callback';
const claudeClientId = 'https://claude.ai/oauth/mcp-oauth-client-metadata';
const claudeCallback = 'https://claude.ai/api/mcp/auth_callback';

let passwordHash: string;
beforeAll(async () => {
  passwordHash = await hashPassword(password);
});

interface Running {
  base: string;
  fake: FakeQuestKeeper;
  marie: string;
  campaignId: string;
  dataDir: string;
  uploads: UploadLinks;
  close: () => Promise<void>;
}

async function start(options: { totpSecret?: string } = {}): Promise<Running> {
  const fake = new FakeQuestKeeper();
  const marie = fake.addUser('Marie', marieKey);
  const dm = fake.addUser('Peter');
  const campaign = fake.addCampaign('Schattenlande', dm, [{ userId: marie, characters: ['Arwen'] }]);
  const apiBase = await fake.start();
  const dataDir = fs.mkdtempSync(path.join(os.tmpdir(), 'qk-mcp-http-'));
  const server = createServer();
  await new Promise<void>((resolve) => server.listen(0, '127.0.0.1', () => resolve()));
  const base = `http://127.0.0.1:${(server.address() as AddressInfo).port}`;
  const cimdFetch = (async (url: string | URL | Request) => {
    if (String(url) === claudeClientId) {
      return new Response(
        JSON.stringify({ client_id: claudeClientId, client_name: 'Claude', redirect_uris: [claudeCallback], token_endpoint_auth_method: 'none' }),
        { status: 200, headers: { 'content-type': 'application/json' } },
      );
    }
    return new Response('nope', { status: 404 });
  }) as typeof fetch;

  const uploads = new UploadLinks(base);
  const app = createApp({
    issuer: base,
    mcpUrl: `${base}/mcp`,
    passwordHash,
    totp: options.totpSecret ? new TotpVerifier(options.totpSecret) : undefined,
    tokens: new TokenStore(dataDir, { accessTtlSeconds: 3600, refreshTtlDays: 60 }),
    clients: new ClientRegistry(
      {
        allowedClientIdHosts: ['claude.ai'],
        allowedRedirectUris: [claudeCallback],
        allowLoopbackRedirects: true,
        staticClientId,
      },
      cimdFetch,
    ),
    throttle: new LoginThrottle(),
    tools: {
      notes: new NotesService(new QuestKeeperClient(apiBase, marieKey), { campaignIds: [] }),
      confirmations: new ConfirmationStore(),
      uploads,
      generator: new ImageGenerator({ model: 'x', defaultQuality: 'medium', maxPerDay: 1, baseUrl: 'https://openai.test', dataDir }),
    },
  });
  server.on('request', app);
  return {
    base,
    fake,
    marie,
    campaignId: campaign.id,
    dataDir,
    uploads,
    close: async () => {
      await new Promise<void>((resolve) => server.close(() => resolve()));
      await fake.stop();
      fs.rmSync(dataDir, { recursive: true, force: true });
    },
  };
}

function pkce() {
  const verifier = randomBytes(32).toString('base64url');
  return { verifier, challenge: createHash('sha256').update(verifier).digest('base64url') };
}

async function openLogin(r: Running, params: Record<string, string>) {
  const url = new URL(`${r.base}/authorize`);
  for (const [key, value] of Object.entries(params)) url.searchParams.set(key, value);
  const response = await fetch(url, { redirect: 'manual' });
  const html = await response.text();
  const requestId = /name="request_id" value="([^"]+)"/.exec(html)?.[1];
  return { response, html, requestId };
}

async function submitLogin(r: Running, requestId: string, fields: Record<string, string>) {
  return fetch(`${r.base}/authorize`, {
    method: 'POST',
    redirect: 'manual',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ request_id: requestId, action: 'allow', ...fields }),
  });
}

async function token(r: Running, fields: Record<string, string>) {
  const response = await fetch(`${r.base}/token`, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams(fields),
  });
  return { status: response.status, body: (await response.json()) as Record<string, string> };
}

/** The whole login with the static client and a loopback redirect; returns the tokens. */
async function signIn(r: Running, extra: Record<string, string> = {}) {
  const { verifier, challenge } = pkce();
  const { requestId } = await openLogin(r, {
    response_type: 'code',
    client_id: staticClientId,
    redirect_uri: loopback,
    code_challenge: challenge,
    code_challenge_method: 'S256',
    state: 'state-123',
    resource: `${r.base}/mcp`,
    scope: 'notizen offline_access',
  });
  const login = await submitLogin(r, requestId!, { password, ...extra });
  const location = new URL(login.headers.get('location')!);
  const code = location.searchParams.get('code')!;
  const tokens = await token(r, {
    grant_type: 'authorization_code',
    code,
    redirect_uri: loopback,
    client_id: staticClientId,
    code_verifier: verifier,
    resource: `${r.base}/mcp`,
  });
  return { login, location, code, verifier, tokens };
}

async function mcpClient(r: Running, accessToken: string) {
  const transport = new StreamableHTTPClientTransport(new URL(`${r.base}/mcp`), {
    requestInit: { headers: { Authorization: `Bearer ${accessToken}` } },
  });
  const client = new Client({ name: 'http-test', version: '1.0.0' });
  await client.connect(transport);
  return client;
}

let r: Running;
beforeEach(async () => {
  r = await start();
});
afterEach(async () => {
  await r.close();
});

describe('discovery', () => {
  it('describes the resource and the authorization server the way Claude expects', async () => {
    for (const suffix of ['', '/mcp']) {
      const resource = (await (await fetch(`${r.base}/.well-known/oauth-protected-resource${suffix}`)).json()) as Record<string, unknown>;
      expect(resource.resource).toBe(`${r.base}/mcp`);
      expect(resource.authorization_servers).toEqual([r.base]);
    }
    const server = (await (await fetch(`${r.base}/.well-known/oauth-authorization-server`)).json()) as Record<string, unknown>;
    expect(server).toMatchObject({
      issuer: r.base,
      client_id_metadata_document_supported: true,
      token_endpoint_auth_methods_supported: ['none'],
      code_challenge_methods_supported: ['S256'],
    });
    expect(server).not.toHaveProperty('registration_endpoint');
  });

  it('answers /mcp without a token with 401 and the resource metadata address', async () => {
    const response = await fetch(`${r.base}/mcp`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: '{}' });
    expect(response.status).toBe(401);
    expect(response.headers.get('www-authenticate')).toBe(
      `Bearer resource_metadata="${r.base}/.well-known/oauth-protected-resource/mcp"`,
    );
    const bad = await fetch(`${r.base}/mcp`, { method: 'POST', headers: { authorization: 'Bearer qka_wrong' } });
    expect(bad.status).toBe(401);
    expect(bad.headers.get('www-authenticate')).toContain('error="invalid_token"');
  });
});

describe('login', () => {
  it('signs in with password and PKCE, and the token opens the MCP endpoint', async () => {
    const { login, location, tokens } = await signIn(r);
    expect(login.status).toBe(303);
    expect(location.origin + location.pathname).toBe(loopback);
    expect(location.searchParams.get('state')).toBe('state-123');
    expect(location.searchParams.get('iss')).toBe(r.base);
    expect(tokens.status).toBe(200);
    expect(tokens.body.token_type).toBe('Bearer');
    expect(tokens.body.refresh_token).toMatch(/^qkr_/);

    const client = await mcpClient(r, tokens.body.access_token!);
    const { tools } = await client.listTools();
    const names = tools.map((tool) => tool.name);
    expect(names).toEqual(expect.arrayContaining(['notizen_lesen', 'freigabe_aendern', 'bild_ansehen', 'gruppe_loeschen']));
    expect(tools.find((tool) => tool.name === 'notizen_loeschen')?.annotations?.destructiveHint).toBe(true);
    expect(client.getInstructions()).toContain('Neue Blöcke sind immer privat');
    await client.close();
  });

  it('refuses a wrong password, and locks an address after five tries', async () => {
    const { challenge } = pkce();
    const params = {
      response_type: 'code',
      client_id: staticClientId,
      redirect_uri: loopback,
      code_challenge: challenge,
      code_challenge_method: 'S256',
    };
    const { requestId, response } = await openLogin(r, params);
    expect(response.headers.get('content-security-policy')).toContain("frame-ancestors 'none'");
    for (let attempt = 0; attempt < 5; attempt++) {
      const wrong = await submitLogin(r, requestId!, { password: 'falsch' });
      expect(wrong.status).toBe(401);
    }
    const locked = await submitLogin(r, requestId!, { password });
    expect(locked.status).toBe(429);
    expect(locked.headers.get('location')).toBeNull();
  });

  it('uses a code once and only with the right verifier', async () => {
    const { code, verifier } = await signIn(r);
    const again = await token(r, { grant_type: 'authorization_code', code, redirect_uri: loopback, client_id: staticClientId, code_verifier: verifier });
    expect(again.status).toBe(400);
    expect(again.body.error).toBe('invalid_grant');

    const { challenge } = pkce();
    const { requestId } = await openLogin(r, {
      response_type: 'code',
      client_id: staticClientId,
      redirect_uri: loopback,
      code_challenge: challenge,
      code_challenge_method: 'S256',
    });
    const login = await submitLogin(r, requestId!, { password });
    const fresh = new URL(login.headers.get('location')!).searchParams.get('code')!;
    const wrongVerifier = await token(r, {
      grant_type: 'authorization_code',
      code: fresh,
      redirect_uri: loopback,
      client_id: staticClientId,
      code_verifier: pkce().verifier,
    });
    expect(wrongVerifier.body.error).toBe('invalid_grant');
  });

  it('rotates refresh tokens and revokes the login when an old one comes back', async () => {
    const { tokens } = await signIn(r);
    const first = tokens.body;
    const second = await token(r, { grant_type: 'refresh_token', refresh_token: first.refresh_token!, client_id: staticClientId });
    expect(second.status).toBe(200);
    expect(second.body.refresh_token).not.toBe(first.refresh_token);

    const replay = await token(r, { grant_type: 'refresh_token', refresh_token: first.refresh_token!, client_id: staticClientId });
    expect(replay.body.error).toBe('invalid_grant');
    const afterReplay = await fetch(`${r.base}/mcp`, { method: 'POST', headers: { authorization: `Bearer ${second.body.access_token}` } });
    expect(afterReplay.status).toBe(401);
  });

  it('ends every login at once with `abmelden`', async () => {
    const { tokens } = await signIn(r);
    revokeAllLogins(r.dataDir, Date.now() + 1);
    const response = await fetch(`${r.base}/mcp`, { method: 'POST', headers: { authorization: `Bearer ${tokens.body.access_token}` } });
    expect(response.status).toBe(401);
    const refresh = await token(r, { grant_type: 'refresh_token', refresh_token: tokens.body.refresh_token!, client_id: staticClientId });
    expect(refresh.body.error).toBe('invalid_grant');
  });

  it('refuses a resource other than this server', async () => {
    const { challenge } = pkce();
    const { response } = await openLogin(r, {
      response_type: 'code',
      client_id: staticClientId,
      redirect_uri: loopback,
      code_challenge: challenge,
      code_challenge_method: 'S256',
      resource: 'https://other.example/mcp',
    });
    expect(response.status).toBe(303);
    expect(new URL(response.headers.get('location')!).searchParams.get('error')).toBe('invalid_target');
  });
});

describe('clients', () => {
  it('accepts Claude by its metadata document and shows its name and redirect host', async () => {
    const { challenge } = pkce();
    const { response, html } = await openLogin(r, {
      response_type: 'code',
      client_id: claudeClientId,
      redirect_uri: claudeCallback,
      code_challenge: challenge,
      code_challenge_method: 'S256',
    });
    expect(response.status).toBe(200);
    expect(html).toContain('<strong>Claude</strong>');
    expect(html).toContain('claude.ai');
    expect(response.headers.get('content-security-policy')).toContain('form-action \'self\' https://claude.ai');
  });

  it('never redirects to an address the client did not register', async () => {
    const { challenge } = pkce();
    for (const [clientId, redirect] of [
      [claudeClientId, 'https://evil.example/callback'],
      ['https://evil.example/client.json', 'https://evil.example/callback'],
      ['some-unknown-client', loopback],
    ] as const) {
      const { response } = await openLogin(r, {
        response_type: 'code',
        client_id: clientId,
        redirect_uri: redirect,
        code_challenge: challenge,
        code_challenge_method: 'S256',
      });
      expect(response.status, `${clientId} -> ${redirect}`).toBe(400);
      expect(response.headers.get('location')).toBeNull();
    }
  });
});

describe('second factor', () => {
  it('needs the current code when a TOTP secret is set', async () => {
    await r.close();
    const secret = newTotpSecret();
    r = await start({ totpSecret: secret });
    const { challenge } = pkce();
    const params = { response_type: 'code', client_id: staticClientId, redirect_uri: loopback, code_challenge: challenge, code_challenge_method: 'S256' };
    const { requestId, html } = await openLogin(r, params);
    expect(html).toContain('name="totp"');
    const withoutCode = await submitLogin(r, requestId!, { password, totp: '000000' });
    expect(withoutCode.status).toBe(401);
    const withCode = await submitLogin(r, requestId!, { password, totp: totpCode(secret, Math.floor(Date.now() / 30_000)) });
    expect(withCode.status).toBe(303);
  });
});

describe('upload page', () => {
  it('stores one picture as a private block and then stops working', async () => {
    const note = r.fake.addDocument(r.campaignId, r.marie, 'Bilder');
    const link = r.uploads.create(note.id, 'Vom Handy');
    const page = await fetch(link.url);
    expect(page.status).toBe(200);
    expect(await page.text()).toContain('privater');

    const form = new FormData();
    form.set('bild', new Blob([new Uint8Array(await pngImage())], { type: 'image/png' }), 'foto.png');
    const upload = await fetch(link.url, { method: 'POST', body: form });
    expect(upload.status).toBe(200);
    const [block] = r.fake.blocksOf(note.id);
    expect(block!.type).toBe('image');
    expect(block!.visibleTo).toEqual([]);
    expect(block!.markdownText).toBe('Vom Handy');

    const again = await fetch(link.url, { method: 'POST', body: form });
    expect(again.status).toBe(410);
  });
});

