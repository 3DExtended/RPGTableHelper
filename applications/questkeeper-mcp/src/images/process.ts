import sharp, { type Metadata } from 'sharp';
import { UserError } from '../domain/errors.js';

/** Questkeeper takes PNG or JPEG up to 10 MB. */
export const maxStoredBytes = 10 * 1024 * 1024;
/** What we accept from a link, an upload or base64 before converting. */
export const maxInputBytes = 15 * 1024 * 1024;
const maxInputPixels = 100_000_000;

export type ImageKind = 'png' | 'jpeg' | 'gif' | 'webp' | 'heif' | 'tiff';

/** The format by its first bytes; null for anything that is no image we convert (also SVG, on purpose). */
export function detectImageKind(data: Buffer): ImageKind | null {
  if (data.length < 12) return null;
  if (data[0] === 0x89 && data.subarray(1, 4).toString('latin1') === 'PNG') return 'png';
  if (data[0] === 0xff && data[1] === 0xd8 && data[2] === 0xff) return 'jpeg';
  if (data.subarray(0, 4).toString('latin1') === 'GIF8') return 'gif';
  if (data.subarray(0, 4).toString('latin1') === 'RIFF' && data.subarray(8, 12).toString('latin1') === 'WEBP') return 'webp';
  if (data.subarray(4, 8).toString('latin1') === 'ftyp') {
    const brand = data.subarray(8, 12).toString('latin1');
    if (['avif', 'avis', 'heic', 'heix', 'mif1', 'msf1'].includes(brand)) return 'heif';
  }
  const tiff = data.subarray(0, 4).toString('hex');
  if (tiff === '49492a00' || tiff === '4d4d002a') return 'tiff';
  return null;
}

export interface StorableImage {
  data: Buffer;
  mimeType: 'image/png' | 'image/jpeg';
  fileName: string;
  width: number;
  height: number;
}

/**
 * Makes an image storable in Questkeeper: PNG stays PNG, everything else becomes JPEG (or PNG if it has
 * transparency). Always re-encoded, so camera metadata like GPS positions is dropped; turned upright;
 * at most 4096 px on the long side and 10 MB.
 */
export async function toStorable(data: Buffer, baseName = 'bild'): Promise<StorableImage> {
  if (data.length > maxInputBytes) throw new UserError('Das Bild ist größer als 15 MB.');
  const kind = detectImageKind(data);
  if (!kind) throw new UserError('Das ist kein unterstütztes Bild (PNG, JPEG, WebP, GIF, AVIF/HEIF oder TIFF).');
  let metadata: Metadata;
  try {
    metadata = await sharp(data, { limitInputPixels: maxInputPixels }).metadata();
  } catch {
    throw new UserError('Das Bild lässt sich nicht lesen.');
  }
  const keepPng = kind === 'png' || (kind !== 'jpeg' && metadata.hasAlpha === true);
  const safeName = baseName.replace(/[^\p{L}\p{N}_-]+/gu, '-').slice(0, 60) || 'bild';

  for (const [edge, quality] of [
    [4096, 90],
    [3072, 82],
    [2048, 78],
  ] as const) {
    const pipeline = sharp(data, { limitInputPixels: maxInputPixels, animated: false })
      .rotate()
      .resize({ width: edge, height: edge, fit: 'inside', withoutEnlargement: true });
    const output = keepPng
      ? await pipeline.png({ compressionLevel: 9 }).toBuffer({ resolveWithObject: true })
      : await pipeline.flatten({ background: '#ffffff' }).jpeg({ quality, mozjpeg: true }).toBuffer({ resolveWithObject: true });
    if (output.data.length <= maxStoredBytes) {
      return {
        data: output.data,
        mimeType: keepPng ? 'image/png' : 'image/jpeg',
        fileName: `${safeName}.${keepPng ? 'png' : 'jpg'}`,
        width: output.info.width,
        height: output.info.height,
      };
    }
  }
  throw new UserError('Das Bild ist auch verkleinert noch größer als 10 MB.');
}

/**
 * A preview Claude can look at: JPEG, at most `maxEdge` px, and as base64 at most `maxBase64Chars` long
 * (tool answers are limited in size).
 */
export async function toPreview(
  data: Buffer,
  options: { maxEdge?: number; maxBase64Chars?: number } = {},
): Promise<{ base64: string; mimeType: 'image/jpeg'; width: number; height: number }> {
  const maxEdge = options.maxEdge ?? 1024;
  const budget = options.maxBase64Chars ?? 120_000;
  const steps: [number, number][] = [
    [maxEdge, 78],
    [maxEdge, 62],
    [Math.round(maxEdge * 0.75), 60],
    [Math.round(maxEdge * 0.55), 55],
    [Math.round(maxEdge * 0.4), 50],
    [256, 45],
  ];
  let last: { base64: string; width: number; height: number } | undefined;
  for (const [edge, quality] of steps) {
    const output = await sharp(data, { limitInputPixels: maxInputPixels, animated: false })
      .rotate()
      .resize({ width: edge, height: edge, fit: 'inside', withoutEnlargement: true })
      .flatten({ background: '#ffffff' })
      .jpeg({ quality, mozjpeg: true })
      .toBuffer({ resolveWithObject: true });
    last = { base64: output.data.toString('base64'), width: output.info.width, height: output.info.height };
    if (last.base64.length <= budget) break;
  }
  return { ...last!, mimeType: 'image/jpeg' };
}
