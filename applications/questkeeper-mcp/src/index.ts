import { createApp } from './app.js';
import { composeDependencies } from './compose.js';
import { loadConfig } from './config.js';
import { configureLog, log } from './log.js';

let config;
try {
  config = loadConfig();
} catch (error) {
  process.stderr.write(`${(error as Error).message}\n`);
  process.exit(1);
}
configureLog({ level: config.LOG_LEVEL });

const dependencies = composeDependencies(config);
const app = createApp(dependencies);
const server = app.listen(config.PORT, config.HOST, () => {
  log.info('server.started', { port: config.PORT, issuer: config.issuer });
  if (!config.OPENAI_API_KEY) log.info('server.image_generation_disabled');
});
// Image generation can take a while; keep sockets open longer than the tool limit.
server.requestTimeout = 300_000;
server.headersTimeout = 60_000;

const shutdown = (signal: string) => {
  log.info('server.stopping', { reason: signal });
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(0), 10_000).unref();
};
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
