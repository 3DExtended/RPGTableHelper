import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import type { CallToolResult, ToolAnnotations } from '@modelcontextprotocol/sdk/types.js';
import { z } from 'zod';
import type { ConfirmationStore } from '../domain/confirmations.js';
import { NotFoundError, UserError } from '../domain/errors.js';
import type { NotesService } from '../domain/notes.js';
import type { ImageGenerator } from '../images/generate.js';
import type { UploadLinks } from '../images/uploadLinks.js';
import { log, type LogFields } from '../log.js';
import type { QkBlock, QkDocument } from '../questkeeper/types.js';

export interface ToolContext {
  notes: NotesService;
  confirmations: ConfirmationStore;
  uploads: UploadLinks;
  generator: ImageGenerator;
}

export interface ToolResult {
  text: string;
  images?: { base64: string; mimeType: string }[];
  /** Ids and counts for the log; never content. */
  log?: LogFields;
}

const guid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export const schemas = {
  documentId: z.string().regex(guid, 'keine gültige ID').describe('ID der Notiz (aus notizen_auflisten oder notizen_lesen).'),
  blockId: z.string().regex(guid, 'keine gültige ID').describe('ID eines Blocks (aus notizen_lesen).'),
  version: z
    .string()
    .min(10)
    .max(64)
    .describe(
      'Version der Notiz, wie notizen_lesen sie zeigt („Version: …“). Hat sich die Notiz seitdem geändert, wird nichts gespeichert.',
    ),
  campaign: z
    .string()
    .max(200)
    .optional()
    .describe('Name oder ID der Kampagne. Nur nötig, wenn Marie in mehreren Kampagnen ist.'),
  confirmation: z
    .string()
    .max(20)
    .optional()
    .describe(
      'Bestätigungscode aus dem ersten Aufruf. Erst angeben, nachdem Marie ausdrücklich zugestimmt hat; beim ersten Aufruf weglassen.',
    ),
  markdown: z.string().max(100_000),
  groupName: z.string().trim().min(1).max(200),
  title: z.string().trim().min(1).max(300),
};

export const ids = (description: string, max: number, min = 1) =>
  z.array(schemas.blockId).min(min).max(max).describe(description);

/** Registers a tool with logging and error handling. Errors become an answer with isError and a German message. */
export function addTool<Shape extends z.ZodRawShape>(
  server: McpServer,
  name: string,
  config: { title: string; description: string; inputSchema: Shape; annotations: ToolAnnotations },
  run: (args: z.output<z.ZodObject<Shape>>) => Promise<ToolResult>,
): void {
  const handler = async (args: z.output<z.ZodObject<Shape>>): Promise<CallToolResult> => {
    const started = Date.now();
    try {
      const result = await run(args);
      log.info('tool', { tool: name, status: 'ok', ms: Date.now() - started, ...result.log });
      const content: CallToolResult['content'] = [{ type: 'text', text: result.text }];
      for (const image of result.images ?? []) content.push({ type: 'image', data: image.base64, mimeType: image.mimeType });
      return { content };
    } catch (error) {
      const userError = error instanceof UserError;
      log[userError ? 'info' : 'error']('tool', {
        tool: name,
        status: userError ? 'refused' : 'failed',
        code: userError ? (error as UserError).code : undefined,
        errorName: (error as Error)?.name,
        ms: Date.now() - started,
      });
      const text = userError
        ? (error as UserError).message
        : 'Unerwarteter Fehler auf dem Server. Es wurde eventuell nur ein Teil gespeichert; lies die Notiz neu.';
      return { isError: true, content: [{ type: 'text', text }] };
    }
  };
  server.registerTool(
    name,
    { title: config.title, description: config.description, inputSchema: config.inputSchema, annotations: config.annotations },
    handler as never,
  );
}

export function findBlock(document: QkDocument, blockId: string): QkBlock {
  const block = document.blocks.find((candidate) => candidate.id.toLowerCase() === blockId.toLowerCase());
  if (!block) throw new NotFoundError(`Block ${blockId} in „${document.title}“`);
  return block;
}

export function ownBlock(document: QkDocument, blockId: string): QkBlock {
  const block = findBlock(document, blockId);
  if (!block.isOwn) {
    throw new UserError(`Block ${blockId} hat jemand anderes geschrieben; du kannst ihn lesen, aber nicht ändern.`);
  }
  return block;
}

export function uniqueIds(values: string[]): string[] {
  const seen = new Set<string>();
  const result: string[] = [];
  for (const value of values) {
    const id = value.toLowerCase();
    if (seen.has(id)) throw new UserError(`Die ID ${value} steht doppelt in der Liste.`);
    seen.add(id);
    result.push(id);
  }
  return result;
}

/** `order` with `inserted` placed after `afterId` ("anfang" = at the start, undefined = at the end). */
export function insertInto(order: string[], inserted: string[], afterId?: string): string[] {
  const moving = new Set(inserted.map((id) => id.toLowerCase()));
  const rest = order.filter((id) => !moving.has(id.toLowerCase()));
  if (!afterId) return [...rest, ...inserted];
  if (afterId.toLowerCase() === 'anfang') return [...inserted, ...rest];
  const at = rest.findIndex((id) => id.toLowerCase() === afterId.toLowerCase());
  if (at < 0) throw new UserError(`Block ${afterId} (nachBlockId) ist nicht in der Zielnotiz oder wird selbst verschoben.`);
  return [...rest.slice(0, at + 1), ...inserted, ...rest.slice(at + 1)];
}

export const positionSchema = z
  .string()
  .max(40)
  .optional()
  .describe('Wohin: ID des Blocks, nach dem eingefügt wird, oder „anfang“. Weglassen = ans Ende.');

export function plural(count: number, one: string, many: string): string {
  return `${count} ${count === 1 ? one : many}`;
}

/** The two-step pattern: without a code describe and hand out a code, with a matching code go ahead. */
export function confirmStep<T>(
  context: ToolContext,
  action: string,
  request: unknown,
  code: string | undefined,
  data: T,
): { confirmed: true; data: T } | { confirmed: false; code: string } {
  if (!code) return { confirmed: false, code: context.confirmations.create(action, request, data) };
  const taken = context.confirmations.take<T>(action, request, code);
  if (!taken.ok) throw new UserError(`${taken.reason} Rufe das Werkzeug ohne bestaetigung auf, um einen neuen Code zu bekommen.`);
  return { confirmed: true, data: taken.data };
}

export function confirmationHint(code: string, question: string): string {
  return (
    `\n\nNoch ist nichts passiert. ${question} Frag Marie ausdrücklich und warte auf ihr Ja. ` +
    `Erst dann dasselbe Werkzeug mit denselben Angaben und bestaetigung: "${code}" erneut aufrufen (gilt 10 Minuten).`
  );
}
