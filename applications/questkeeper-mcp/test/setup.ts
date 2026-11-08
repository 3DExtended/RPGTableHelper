import { configureLog } from '../src/log.js';

// Quiet tests; set TEST_LOG=1 to see the server's log lines.
if (!process.env.TEST_LOG) configureLog({ sink: () => undefined });
