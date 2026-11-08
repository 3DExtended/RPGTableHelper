import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';
import express, { type Express, type NextFunction, type Request, type Response } from 'express';
import { requireBearer } from './auth/bearer.js';
import type { ClientRegistry } from './auth/clients.js';
import { authorizationServerMetadata, createOAuthRouter, protectedResourceMetadata } from './auth/oauthServer.js';
import { escapeHtml, page } from './auth/pages.js';
import type { LoginThrottle } from './auth/rateLimit.js';
import type { TokenStore } from './auth/tokenStore.js';
import type { TotpVerifier } from './auth/totp.js';
import type { Resolver } from './images/fetchRemote.js';
import { createUploadRouter } from './images/uploadLinks.js';
import { log, loggablePath } from './log.js';
import type { ToolContext } from './mcp/common.js';
import { buildMcpServer } from './mcp/server.js';

export interface AppDependencies {
  issuer: string;
  mcpUrl: string;
  passwordHash: string;
  totp?: TotpVerifier;
  tokens: TokenStore;
  clients: ClientRegistry;
  throttle: LoginThrottle;
  tools: ToolContext;
  resolver?: Resolver;
}

function cors(req: Request, res: Response, next: NextFunction): void {
  res.set({
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Authorization, Content-Type, Accept, Mcp-Protocol-Version, Mcp-Session-Id, Last-Event-ID',
    'Access-Control-Expose-Headers': 'WWW-Authenticate, Mcp-Session-Id, Mcp-Protocol-Version',
    'Access-Control-Max-Age': '600',
  });
  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }
  next();
}

export function createApp(deps: AppDependencies): Express {
  const app = express();
  app.disable('x-powered-by');
  app.set('trust proxy', false);

  app.use((req, res, next) => {
    const started = Date.now();
    res.on('finish', () => {
      if (req.path === '/healthz') return;
      log.info('http', {
        method: req.method,
        path: loggablePath(req.originalUrl),
        httpStatus: res.statusCode,
        ms: Date.now() - started,
      });
    });
    next();
  });

  app.get('/healthz', (_req, res) => {
    res.json({ ok: true });
  });

  const resourceMetadata = protectedResourceMetadata({ issuer: deps.issuer, mcpUrl: deps.mcpUrl });
  const resourceMetadataUrl = `${deps.issuer}/.well-known/oauth-protected-resource/mcp`;
  app.use('/.well-known', cors);
  app.get(['/.well-known/oauth-protected-resource', '/.well-known/oauth-protected-resource/mcp'], (_req, res) => {
    res.json(resourceMetadata);
  });
  app.get('/.well-known/oauth-authorization-server', (_req, res) => {
    res.json(authorizationServerMetadata(deps.issuer));
  });

  app.use('/token', cors);
  app.use(
    createOAuthRouter({
      issuer: deps.issuer,
      mcpUrl: deps.mcpUrl,
      passwordHash: deps.passwordHash,
      totp: deps.totp,
      clients: deps.clients,
      tokens: deps.tokens,
      throttle: deps.throttle,
    }),
  );
  app.use(createUploadRouter(deps.tools.uploads, deps.tools.notes));

  app.use('/mcp', cors, requireBearer(deps.tokens, resourceMetadataUrl));
  app.post('/mcp', express.json({ limit: '6mb' }), async (req, res) => {
    // Stateless: a fresh server and transport per request, nothing kept between requests.
    const server = buildMcpServer(deps.tools, { resolver: deps.resolver });
    const transport = new StreamableHTTPServerTransport({ sessionIdGenerator: undefined, enableJsonResponse: true });
    res.on('close', () => {
      void transport.close();
      void server.close();
    });
    try {
      await server.connect(transport);
      await transport.handleRequest(req, res, req.body);
    } catch (error) {
      log.error('mcp.request_failed', { errorName: (error as Error).name });
      if (!res.headersSent) {
        res.status(500).json({ jsonrpc: '2.0', error: { code: -32603, message: 'Internal server error' }, id: null });
      }
    }
  });
  app.all('/mcp', (_req, res) => {
    res
      .status(405)
      .set('Allow', 'POST')
      .json({ jsonrpc: '2.0', error: { code: -32000, message: 'Method not allowed: this server is stateless, use POST.' }, id: null });
  });

  app.get('/', (_req, res) => {
    res.set('Content-Security-Policy', "default-src 'none'; style-src 'unsafe-inline'");
    res.type('html').send(
      page(
        'Questkeeper-Notizen',
        `<h1>Questkeeper-Notizen</h1><p>MCP-Server für Claude. In Claude unter Einstellungen → Konnektoren als eigenen Konnektor mit dieser Adresse hinzufügen:</p><p><code>${escapeHtml(deps.mcpUrl)}</code></p>`,
      ),
    );
  });

  app.use((_req, res) => {
    res.status(404).json({ error: 'not_found' });
  });

  app.use((error: Error & { type?: string; status?: number }, _req: Request, res: Response, _next: NextFunction) => {
    if (error.type === 'entity.parse.failed') {
      res.status(400).json({ jsonrpc: '2.0', error: { code: -32700, message: 'Parse error' }, id: null });
      return;
    }
    if (error.type === 'entity.too.large') {
      res.status(413).json({ error: 'too_large' });
      return;
    }
    log.error('http.error', { errorName: error.name });
    if (!res.headersSent) res.status(500).json({ error: 'internal_error' });
  });

  return app;
}
