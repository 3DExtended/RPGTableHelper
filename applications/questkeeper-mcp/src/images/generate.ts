import fs from 'node:fs';
import path from 'node:path';
import { UserError } from '../domain/errors.js';
import { log } from '../log.js';

export type ImageFormat = 'quadratisch' | 'hochformat' | 'querformat';
export type ImageQuality = 'niedrig' | 'mittel' | 'hoch';

const sizes: Record<ImageFormat, string> = {
  quadratisch: '1024x1024',
  hochformat: '1024x1536',
  querformat: '1536x1024',
};
const qualities: Record<ImageQuality, string> = { niedrig: 'low', mittel: 'medium', hoch: 'high' };

type FetchLike = typeof fetch;

/**
 * Image generation with OpenAI's Images API. The key stays on the server; a daily cap (counted in
 * DATA_DIR/bildgenerierung.json) keeps costs bounded. Prompts are never logged.
 */
export class ImageGenerator {
  private readonly counterFile: string;

  constructor(
    private readonly options: {
      apiKey?: string;
      model: string;
      defaultQuality: 'low' | 'medium' | 'high' | 'auto';
      maxPerDay: number;
      baseUrl: string;
      dataDir: string;
    },
    private readonly fetchImpl: FetchLike = fetch,
    private readonly now: () => Date = () => new Date(),
  ) {
    this.counterFile = path.join(options.dataDir, 'bildgenerierung.json');
  }

  get enabled(): boolean {
    return Boolean(this.options.apiKey);
  }

  remainingToday(): number {
    return Math.max(0, this.options.maxPerDay - this.readCounter().count);
  }

  async generate(prompt: string, format: ImageFormat, quality?: ImageQuality): Promise<Buffer> {
    if (!this.options.apiKey) {
      throw new UserError('Bildgenerierung ist auf diesem Server nicht eingerichtet (OPENAI_API_KEY fehlt).');
    }
    const counter = this.readCounter();
    if (counter.count >= this.options.maxPerDay) {
      throw new UserError(`Das Tageslimit von ${this.options.maxPerDay} erzeugten Bildern ist erreicht. Morgen geht es wieder.`);
    }
    // Reserve before calling, so two calls at once cannot both pass the limit; refunded on failure.
    this.writeCounter({ day: counter.day, count: counter.count + 1 });
    const started = Date.now();
    try {
      const response = await this.fetchImpl(`${this.options.baseUrl}/images/generations`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${this.options.apiKey}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: this.options.model,
          prompt,
          n: 1,
          size: sizes[format],
          quality: quality ? qualities[quality] : this.options.defaultQuality,
        }),
        signal: AbortSignal.timeout(180_000),
      });
      const text = await response.text();
      if (!response.ok) {
        let code = `http_${response.status}`;
        try {
          const body = JSON.parse(text) as { error?: { code?: string; type?: string } };
          code = body.error?.code ?? body.error?.type ?? code;
        } catch {
          // not JSON
        }
        log.warn('image.generation_failed', { httpStatus: response.status, code, ms: Date.now() - started });
        throw new UserError(describeOpenAiError(response.status, code));
      }
      const body = JSON.parse(text) as { data?: { b64_json?: string }[] };
      const base64 = body.data?.[0]?.b64_json;
      if (!base64) throw new UserError('OpenAI hat kein Bild zurückgegeben.');
      log.info('image.generated', { ms: Date.now() - started });
      return Buffer.from(base64, 'base64');
    } catch (error) {
      const now = this.readCounter();
      this.writeCounter({ day: now.day, count: Math.max(0, now.count - 1) });
      if (error instanceof UserError) throw error;
      log.warn('image.generation_failed', { errorName: (error as Error).name, ms: Date.now() - started });
      throw new UserError('Die Bildgenerierung hat nicht geantwortet. Versuche es noch einmal.');
    }
  }

  private today(): string {
    return this.now().toISOString().slice(0, 10);
  }

  private readCounter(): { day: string; count: number } {
    try {
      const value = JSON.parse(fs.readFileSync(this.counterFile, 'utf8')) as { day: string; count: number };
      if (value.day === this.today()) return value;
    } catch {
      // first use or broken file
    }
    return { day: this.today(), count: 0 };
  }

  private writeCounter(value: { day: string; count: number }): void {
    fs.mkdirSync(path.dirname(this.counterFile), { recursive: true });
    fs.writeFileSync(this.counterFile, JSON.stringify(value));
  }
}

function describeOpenAiError(status: number, code: string): string {
  if (code === 'moderation_blocked' || code === 'content_policy_violation') {
    return 'OpenAI hat die Bildbeschreibung abgelehnt (Inhaltsrichtlinie). Formuliere sie anders.';
  }
  if (code === 'insufficient_quota' || code === 'billing_hard_limit_reached') {
    return 'Das OpenAI-Guthaben bzw. Ausgabelimit ist aufgebraucht.';
  }
  if (status === 429) return 'OpenAI bremst gerade. Versuche es in einer Minute noch einmal.';
  if (status === 401) return 'OpenAI lehnt den API-Schlüssel des Servers ab.';
  if (status === 404 || code === 'model_not_found') return 'Das eingestellte Bildmodell gibt es bei OpenAI nicht (OPENAI_IMAGE_MODEL).';
  if (status === 400) return `OpenAI hat die Anfrage abgelehnt (${code}).`;
  return `OpenAI hat einen Fehler gemeldet (${status}).`;
}
