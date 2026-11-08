/**
 * Runs the whole login against a local server (like the MCP Inspector would) and prints an access token,
 * for the Inspector CLI:  npm run dev:token -- http://localhost:8787
 * Needs a static client id and loopback redirects (both on in `npm run dev:fake`).
 * Password and client id: DEV_PASSWORD (default dev-passwort-123), DEV_CLIENT_ID (default inspector).
 */
import { createHash, randomBytes } from 'node:crypto';

const base = (process.argv[2] ?? 'http://localhost:8787').replace(/\/+$/, '');
const password = process.env.DEV_PASSWORD ?? 'dev-passwort-123';
const clientId = process.env.DEV_CLIENT_ID ?? 'inspector';
const redirectUri = 'http://localhost:6274/oauth/callback';

const verifier = randomBytes(32).toString('base64url');
const authorize = new URL(`${base}/authorize`);
for (const [key, value] of Object.entries({
  response_type: 'code',
  client_id: clientId,
  redirect_uri: redirectUri,
  code_challenge: createHash('sha256').update(verifier).digest('base64url'),
  code_challenge_method: 'S256',
  resource: `${base}/mcp`,
  state: 'dev',
})) {
  authorize.searchParams.set(key, value);
}
const page = await (await fetch(authorize)).text();
const requestId = /name="request_id" value="([^"]+)"/.exec(page)?.[1];
if (!requestId) throw new Error('No login page – is the static client id set and are loopback redirects allowed?');
const login = await fetch(`${base}/authorize`, {
  method: 'POST',
  redirect: 'manual',
  headers: { 'content-type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams({ request_id: requestId, password, totp: process.env.DEV_TOTP ?? '', action: 'allow' }),
});
const code = new URL(login.headers.get('location') ?? 'http://x/').searchParams.get('code');
if (!code) throw new Error(`Login failed (${login.status}).`);
const response = await fetch(`${base}/token`, {
  method: 'POST',
  headers: { 'content-type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams({ grant_type: 'authorization_code', code, redirect_uri: redirectUri, client_id: clientId, code_verifier: verifier }),
});
const tokens = (await response.json()) as { access_token?: string };
if (!tokens.access_token) throw new Error(`Token request failed (${response.status}).`);
process.stdout.write(`${tokens.access_token}\n`);
