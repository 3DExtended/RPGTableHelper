/**
 * JSON-lines logging that never carries note content.
 *
 * Only the field names below get through; everything else is dropped. Values must be ids, counts, names of
 * tools or error codes - never titles, text, captions, prompts, image data, tokens or keys.
 */
const allowedFields = new Set([
  'tool',
  'status',
  'ms',
  'method',
  'path',
  'httpStatus',
  'campaignId',
  'documentId',
  'documentIds',
  'blockId',
  'blockIds',
  'count',
  'documents',
  'blocks',
  'images',
  'bytes',
  'code',
  'reason',
  'outcome',
  'client',
  'ip',
  'attempt',
  'retryAfter',
  'errorName',
  'port',
  'issuer',
]);

type Level = 'debug' | 'info' | 'warn' | 'error';
const order: Record<Level, number> = { debug: 10, info: 20, warn: 30, error: 40 };

export type LogFields = Record<string, string | number | boolean | string[] | undefined | null>;
export type LogSink = (line: string) => void;

let threshold: Level = 'info';
let sink: LogSink = (line) => process.stdout.write(`${line}\n`);

export function configureLog(options: { level?: Level; sink?: LogSink }): void {
  if (options.level) threshold = options.level;
  if (options.sink) sink = options.sink;
}

function write(level: Level, event: string, fields: LogFields = {}): void {
  if (order[level] < order[threshold]) return;
  const entry: Record<string, unknown> = { ts: new Date().toISOString(), level, event };
  for (const [key, value] of Object.entries(fields)) {
    if (value === undefined || !allowedFields.has(key)) continue;
    entry[key] = Array.isArray(value) ? value.slice(0, 50) : value;
  }
  sink(JSON.stringify(entry));
}

export const log = {
  debug: (event: string, fields?: LogFields) => write('debug', event, fields),
  info: (event: string, fields?: LogFields) => write('info', event, fields),
  warn: (event: string, fields?: LogFields) => write('warn', event, fields),
  error: (event: string, fields?: LogFields) => write('error', event, fields),
};

/** The path of a request as it may be logged: no query string, no upload tokens. */
export function loggablePath(url: string): string {
  const pathOnly = url.split('?')[0] ?? '';
  return pathOnly.replace(/^\/upload\/[^/]+/, '/upload/:token');
}
