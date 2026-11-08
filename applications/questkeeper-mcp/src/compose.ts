import { ClientRegistry } from './auth/clients.js';
import { LoginThrottle } from './auth/rateLimit.js';
import { TokenStore } from './auth/tokenStore.js';
import { TotpVerifier } from './auth/totp.js';
import type { AppDependencies } from './app.js';
import type { Config } from './config.js';
import { ConfirmationStore } from './domain/confirmations.js';
import { NotesService } from './domain/notes.js';
import { ImageGenerator } from './images/generate.js';
import { UploadLinks } from './images/uploadLinks.js';
import { QuestKeeperClient } from './questkeeper/client.js';

/** Builds everything the app needs from the configuration. */
export function composeDependencies(config: Config, overrides: { fetchImpl?: typeof fetch } = {}): AppDependencies {
  const qk = new QuestKeeperClient(config.QK_API_BASE_URL, config.QK_API_KEY, {
    imageOrigins: config.QK_IMAGE_ORIGINS,
    fetchImpl: overrides.fetchImpl,
  });
  return {
    issuer: config.issuer,
    mcpUrl: config.mcpUrl,
    passwordHash: config.LOGIN_PASSWORD_HASH,
    totp: config.LOGIN_TOTP_SECRET ? new TotpVerifier(config.LOGIN_TOTP_SECRET) : undefined,
    tokens: new TokenStore(config.dataDir, {
      accessTtlSeconds: config.ACCESS_TOKEN_TTL_SECONDS,
      refreshTtlDays: config.REFRESH_TOKEN_TTL_DAYS,
    }),
    clients: new ClientRegistry(
      {
        allowedClientIdHosts: config.ALLOWED_CLIENT_ID_HOSTS.map((host) => host.toLowerCase()),
        allowedRedirectUris: config.ALLOWED_REDIRECT_URIS,
        allowLoopbackRedirects: config.ALLOW_LOOPBACK_REDIRECTS,
        staticClientId: config.STATIC_CLIENT_ID,
      },
      overrides.fetchImpl,
    ),
    throttle: new LoginThrottle(),
    tools: {
      notes: new NotesService(qk, { campaignIds: config.QK_CAMPAIGN_IDS }),
      confirmations: new ConfirmationStore(),
      uploads: new UploadLinks(config.PUBLIC_BASE_URL),
      generator: new ImageGenerator(
        {
          apiKey: config.OPENAI_API_KEY,
          model: config.OPENAI_IMAGE_MODEL,
          defaultQuality: config.OPENAI_IMAGE_QUALITY,
          maxPerDay: config.OPENAI_MAX_IMAGES_PER_DAY,
          baseUrl: config.OPENAI_BASE_URL,
          dataDir: config.dataDir,
        },
        overrides.fetchImpl,
      ),
    },
  };
}
