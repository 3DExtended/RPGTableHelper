import path from 'node:path';
import { z } from 'zod';

const list = (fallback: string[] = []) =>
  z
    .string()
    .optional()
    .transform((value) =>
      value === undefined
        ? fallback
        : value
            .split(',')
            .map((entry) => entry.trim())
            .filter((entry) => entry.length > 0),
    );

const flag = (fallback: boolean) =>
  z
    .enum(['true', 'false', '1', '0', 'yes', 'no'])
    .optional()
    .transform((value) => (value === undefined ? fallback : ['true', '1', 'yes'].includes(value)));

const positiveInt = (fallback: number) => z.coerce.number().int().positive().default(fallback);

const schema = z.object({
  PORT: positiveInt(8787),
  HOST: z.string().default('0.0.0.0'),
  /** The public address Claude reaches the server under, without a trailing slash, e.g. https://notizen.example.de */
  PUBLIC_BASE_URL: z
    .url()
    .transform((value) => value.replace(/\/+$/, '')),
  DATA_DIR: z.string().default('./data'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),

  /** scrypt:N:r:p:salt:hash, made with `npm run cli -- passwort-hash` */
  LOGIN_PASSWORD_HASH: z.string().regex(/^scrypt:\d+:\d+:\d+:[A-Za-z0-9_-]+:[A-Za-z0-9_-]+$/, {
    message: 'LOGIN_PASSWORD_HASH must be made with `npm run cli -- passwort-hash`',
  }),
  /** Base32 secret for a second factor (TOTP), made with `npm run cli -- totp-geheimnis`. */
  LOGIN_TOTP_SECRET: z
    .string()
    .regex(/^[A-Z2-7]{16,}=*$/i)
    .optional(),
  /** Hosts whose https URLs may be used as client_id (Client ID Metadata Documents). */
  ALLOWED_CLIENT_ID_HOSTS: list(['claude.ai']),
  /** Redirect URIs a client may send the user back to (besides loopback ones, see below). */
  ALLOWED_REDIRECT_URIS: list(['https://claude.ai/api/mcp/auth_callback', 'https://claude.com/api/mcp/auth_callback']),
  /** Allow http://localhost:<any port> and http://127.0.0.1:<any port> redirects (Claude Code, MCP Inspector). */
  ALLOW_LOOPBACK_REDIRECTS: flag(false),
  /** Optional fixed client id for "Use your own OAuth client" in Claude, or the MCP Inspector. */
  STATIC_CLIENT_ID: z.string().min(8).optional(),
  ACCESS_TOKEN_TTL_SECONDS: positiveInt(60 * 60),
  REFRESH_TOKEN_TTL_DAYS: positiveInt(60),

  QK_API_BASE_URL: z
    .url()
    .default('https://questkeeper-prod.peter-esser.de/api/external/v1')
    .transform((value) => value.replace(/\/+$/, '')),
  QK_API_KEY: z.string().min(10),
  /** Optional: only these campaigns (ids). Empty means every campaign Marie is part of. */
  QK_CAMPAIGN_IDS: list(),
  /** Further origins image links of the API may point to (the API's own origin is always allowed). */
  QK_IMAGE_ORIGINS: list(),

  OPENAI_API_KEY: z.string().min(10).optional(),
  OPENAI_IMAGE_MODEL: z.string().default('gpt-image-2.5-flare'),
  OPENAI_IMAGE_QUALITY: z.enum(['low', 'medium', 'high', 'auto']).default('medium'),
  OPENAI_MAX_IMAGES_PER_DAY: positiveInt(20),
  OPENAI_BASE_URL: z
    .url()
    .default('https://api.openai.com/v1')
    .transform((value) => value.replace(/\/+$/, '')),
});

export type Config = z.output<typeof schema> & {
  mcpUrl: string;
  issuer: string;
  dataDir: string;
};

export function loadConfig(env: NodeJS.ProcessEnv = process.env): Config {
  const parsed = schema.safeParse(env);
  if (!parsed.success) {
    // Names only: values may be secrets.
    const problems = parsed.error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`);
    throw new Error(`Invalid configuration:\n  ${problems.join('\n  ')}`);
  }
  const config = parsed.data;
  return {
    ...config,
    issuer: config.PUBLIC_BASE_URL,
    mcpUrl: `${config.PUBLIC_BASE_URL}/mcp`,
    dataDir: path.resolve(config.DATA_DIR),
  };
}
