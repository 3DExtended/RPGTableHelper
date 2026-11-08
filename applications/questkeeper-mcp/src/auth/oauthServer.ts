import { createHash, randomBytes, timingSafeEqual } from 'node:crypto';
import express, { type Request, type Response, type Router } from 'express';
import { log } from '../log.js';
import { ClientError, type ClientInfo, type ClientRegistry } from './clients.js';
import { errorPage, loginPage } from './pages.js';
import { verifyPassword } from './password.js';
import type { LoginThrottle } from './rateLimit.js';
import { sha256, type TokenStore } from './tokenStore.js';
import type { TotpVerifier } from './totp.js';

export const SCOPE = 'notizen';
const supportedScopes = [SCOPE, 'offline_access'];

export interface OAuthOptions {
  issuer: string;
  mcpUrl: string;
  passwordHash: string;
  totp?: TotpVerifier;
  clients: ClientRegistry;
  tokens: TokenStore;
  throttle: LoginThrottle;
  now?: () => number;
}

interface PendingRequest {
  client: ClientInfo;
  redirectUri: string;
  state?: string;
  codeChallenge: string;
  scope: string;
  createdAt: number;
}

interface IssuedCode {
  clientId: string;
  redirectUri: string;
  codeChallenge: string;
  scope: string;
  expiresAt: number;
  used: boolean;
  familyId?: string;
}

const pendingTtlMs = 10 * 60_000;
const codeTtlMs = 5 * 60_000;
const maxPending = 50;

export function protectedResourceMetadata(options: { issuer: string; mcpUrl: string }) {
  return {
    resource: options.mcpUrl,
    authorization_servers: [options.issuer],
    scopes_supported: supportedScopes,
    bearer_methods_supported: ['header'],
    resource_name: 'QuestKeeper-Notizen',
  };
}

export function authorizationServerMetadata(issuer: string) {
  return {
    issuer,
    authorization_endpoint: `${issuer}/authorize`,
    token_endpoint: `${issuer}/token`,
    response_types_supported: ['code'],
    response_modes_supported: ['query'],
    grant_types_supported: ['authorization_code', 'refresh_token'],
    token_endpoint_auth_methods_supported: ['none'],
    code_challenge_methods_supported: ['S256'],
    scopes_supported: supportedScopes,
    client_id_metadata_document_supported: true,
    authorization_response_iss_parameter_supported: true,
  };
}

/** The client's address as seen by Cloudflare (the tunnel is the only way in), else the socket's. */
export function clientAddress(req: Request): string {
  const header = req.headers['cf-connecting-ip'];
  const value = Array.isArray(header) ? header[0] : header;
  return value?.trim() || req.socket.remoteAddress || 'unknown';
}

function pageHeaders(res: Response, formTarget?: string): void {
  const formAction = ["'self'", formTarget].filter(Boolean).join(' ');
  res.set({
    'Content-Security-Policy': `default-src 'none'; style-src 'unsafe-inline'; form-action ${formAction}; frame-ancestors 'none'; base-uri 'none'`,
    'X-Frame-Options': 'DENY',
    'X-Content-Type-Options': 'nosniff',
    'Referrer-Policy': 'no-referrer',
    'Cache-Control': 'no-store',
  });
}

function single(value: unknown): string | undefined {
  if (typeof value === 'string') return value;
  if (Array.isArray(value) && typeof value[0] === 'string') return value[0];
  return undefined;
}

export function createOAuthRouter(options: OAuthOptions): Router {
  const now = options.now ?? Date.now;
  const pending = new Map<string, PendingRequest>();
  const codes = new Map<string, IssuedCode>();
  // Password checks use scrypt (128 MiB each); one at a time keeps a burst of attempts from eating the memory.
  let passwordQueue: Promise<unknown> = Promise.resolve();
  const checkPassword = (password: string) => {
    const result = passwordQueue.then(() => verifyPassword(password, options.passwordHash));
    passwordQueue = result.catch(() => undefined);
    return result;
  };

  const router = express.Router();

  const cleanUp = () => {
    for (const [id, request] of pending) if (now() - request.createdAt > pendingTtlMs) pending.delete(id);
    for (const [hash, code] of codes) if (code.expiresAt < now() - codeTtlMs) codes.delete(hash);
  };

  const redirectWith = (res: Response, redirectUri: string, params: Record<string, string | undefined>) => {
    const target = new URL(redirectUri);
    for (const [key, value] of Object.entries(params)) if (value !== undefined) target.searchParams.set(key, value);
    target.searchParams.set('iss', options.issuer);
    res.redirect(303, target.toString());
  };

  router.get('/authorize', async (req, res) => {
    cleanUp();
    const clientId = single(req.query.client_id);
    const redirectUri = single(req.query.redirect_uri);
    pageHeaders(res);
    if (!clientId || !redirectUri) {
      res.status(400).type('html').send(errorPage('Die Anfrage nennt keinen Client oder keine Rücksprungadresse.'));
      return;
    }
    let client: ClientInfo;
    try {
      client = await options.clients.resolve(clientId);
    } catch (error) {
      const message = error instanceof ClientError ? error.message : 'Der Client ist unbekannt.';
      log.warn('oauth.client_rejected', { reason: 'client' });
      res.status(400).type('html').send(errorPage(message));
      return;
    }
    if (!options.clients.isRedirectAllowed(client, redirectUri)) {
      log.warn('oauth.client_rejected', { reason: 'redirect_uri' });
      res.status(400).type('html').send(errorPage('Diese Rücksprungadresse ist nicht zugelassen.'));
      return;
    }

    const state = single(req.query.state);
    const fail = (error: string, description: string) =>
      redirectWith(res, redirectUri, { error, error_description: description, state });

    if (single(req.query.response_type) !== 'code') return fail('unsupported_response_type', 'Only "code" is supported.');
    const codeChallenge = single(req.query.code_challenge);
    if (!codeChallenge || single(req.query.code_challenge_method) !== 'S256' || !/^[A-Za-z0-9_-]{43,128}$/.test(codeChallenge)) {
      return fail('invalid_request', 'PKCE with S256 is required.');
    }
    const resource = single(req.query.resource);
    if (resource !== undefined && resource.replace(/\/+$/, '') !== options.mcpUrl) {
      return fail('invalid_target', 'Unknown resource.');
    }
    const requestedScopes = (single(req.query.scope) ?? SCOPE).split(/\s+/).filter(Boolean);
    const scope = [SCOPE, ...(requestedScopes.includes('offline_access') ? ['offline_access'] : [])].join(' ');

    if (pending.size >= maxPending) {
      const oldest = pending.keys().next().value;
      if (oldest !== undefined) pending.delete(oldest);
    }
    const requestId = randomBytes(24).toString('base64url');
    pending.set(requestId, { client, redirectUri, state, codeChallenge, scope, createdAt: now() });
    pageHeaders(res, new URL(redirectUri).origin);
    res.type('html').send(
      loginPage({
        requestId,
        clientName: client.name,
        redirectHost: new URL(redirectUri).host,
        askTotp: options.totp !== undefined,
      }),
    );
  });

  router.post('/authorize', express.urlencoded({ extended: false, limit: '8kb' }), async (req, res) => {
    cleanUp();
    const body = (req.body ?? {}) as Record<string, unknown>;
    const requestId = single(body.request_id) ?? '';
    const request = pending.get(requestId);
    pageHeaders(res);
    if (!request) {
      res.status(400).type('html').send(errorPage('Die Anmeldung ist abgelaufen.'));
      return;
    }
    const redirectOrigin = new URL(request.redirectUri).origin;
    pageHeaders(res, redirectOrigin);

    if (single(body.action) === 'deny') {
      pending.delete(requestId);
      redirectWith(res, request.redirectUri, { error: 'access_denied', state: request.state });
      return;
    }

    const address = clientAddress(req);
    const again = (status: number, error: string) =>
      res.status(status).type('html').send(
        loginPage({
          requestId,
          clientName: request.client.name,
          redirectHost: new URL(request.redirectUri).host,
          askTotp: options.totp !== undefined,
          error,
        }),
      );

    if (options.throttle.isLocked(address)) {
      log.warn('oauth.login_locked', { ip: address });
      again(429, 'Zu viele Fehlversuche. Bitte versuche es später noch einmal.');
      return;
    }
    const password = single(body.password) ?? '';
    const passwordOk = password.length > 0 && password.length <= 1024 && (await checkPassword(password));
    const totpOk = options.totp ? options.totp.verify(single(body.totp) ?? '') : true;
    if (!passwordOk || !totpOk) {
      options.throttle.recordFailure(address);
      log.warn('oauth.login_failed', { ip: address, reason: passwordOk ? 'totp' : 'password' });
      again(401, 'Das hat nicht gepasst.');
      return;
    }
    options.throttle.recordSuccess(address);
    pending.delete(requestId);

    const code = randomBytes(32).toString('base64url');
    codes.set(sha256(code), {
      clientId: request.client.clientId,
      redirectUri: request.redirectUri,
      codeChallenge: request.codeChallenge,
      scope: request.scope,
      expiresAt: now() + codeTtlMs,
      used: false,
    });
    log.info('oauth.login', { client: request.client.kind });
    redirectWith(res, request.redirectUri, { code, state: request.state });
  });

  router.post(
    '/token',
    express.urlencoded({ extended: false, limit: '16kb' }),
    express.json({ limit: '16kb' }),
    (req, res) => {
      res.set({ 'Cache-Control': 'no-store', Pragma: 'no-cache' });
      const body = (req.body ?? {}) as Record<string, unknown>;
      const fail = (status: number, error: string, description: string) => {
        log.warn('oauth.token_rejected', { reason: error });
        res.status(status).json({ error, error_description: description });
      };
      const grantType = single(body.grant_type);
      const clientId = single(body.client_id);
      if (!clientId) return fail(401, 'invalid_client', 'client_id is required.');
      const resource = single(body.resource);
      if (resource !== undefined && resource.replace(/\/+$/, '') !== options.mcpUrl) {
        return fail(400, 'invalid_target', 'Unknown resource.');
      }

      if (grantType === 'authorization_code') {
        cleanUp();
        const code = single(body.code) ?? '';
        const entry = codes.get(sha256(code));
        if (!entry || entry.expiresAt < now()) return fail(400, 'invalid_grant', 'The code is invalid or expired.');
        if (entry.used) {
          if (entry.familyId) options.tokens.revokeFamily(entry.familyId);
          return fail(400, 'invalid_grant', 'The code was already used.');
        }
        if (entry.clientId !== clientId) return fail(400, 'invalid_grant', 'The code belongs to another client.');
        if (single(body.redirect_uri) !== entry.redirectUri) return fail(400, 'invalid_grant', 'redirect_uri does not match.');
        const verifier = single(body.code_verifier) ?? '';
        if (!/^[A-Za-z0-9._~-]{43,128}$/.test(verifier)) return fail(400, 'invalid_grant', 'code_verifier is invalid.');
        const challenge = createHash('sha256').update(verifier).digest('base64url');
        const a = Buffer.from(challenge);
        const b = Buffer.from(entry.codeChallenge);
        if (a.length !== b.length || !timingSafeEqual(a, b)) return fail(400, 'invalid_grant', 'PKCE check failed.');
        entry.used = true;
        const issued = options.tokens.issue(clientId, entry.scope);
        entry.familyId = issued.familyId;
        log.info('oauth.token_issued', { reason: 'authorization_code' });
        res.json({
          access_token: issued.accessToken,
          token_type: 'Bearer',
          expires_in: issued.expiresIn,
          refresh_token: issued.refreshToken,
          scope: issued.scope,
        });
        return;
      }

      if (grantType === 'refresh_token') {
        const refreshToken = single(body.refresh_token) ?? '';
        const issued = refreshToken ? options.tokens.refresh(refreshToken, clientId) : null;
        if (!issued) return fail(400, 'invalid_grant', 'The refresh token is invalid, expired or revoked.');
        log.info('oauth.token_issued', { reason: 'refresh_token' });
        res.json({
          access_token: issued.accessToken,
          token_type: 'Bearer',
          expires_in: issued.expiresIn,
          refresh_token: issued.refreshToken,
          scope: issued.scope,
        });
        return;
      }

      fail(400, 'unsupported_grant_type', 'Only authorization_code and refresh_token are supported.');
    },
  );

  return router;
}
