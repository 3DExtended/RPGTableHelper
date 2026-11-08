import { QkApiError } from '../questkeeper/client.js';

/** An error whose message is meant for Claude (and Marie). Shown as the tool's answer with isError. */
export class UserError extends Error {
  constructor(
    message: string,
    readonly code = 'user_error',
  ) {
    super(message);
    this.name = 'UserError';
  }
}

export class NotFoundError extends UserError {
  constructor(what: string) {
    super(`${what} nicht gefunden. Dieser Server kennt nur deine eigenen Notizen.`, 'not_found');
  }
}

export class VersionConflictError extends UserError {
  constructor(
    title: string,
    readonly currentVersion?: string,
  ) {
    super(
      `Die Notiz „${title}“ wurde inzwischen geändert${currentVersion ? ` (aktuelle Version: ${currentVersion})` : ''}. ` +
        'Es wurde nichts gespeichert. Lies sie mit notizen_lesen neu und entscheide dann, was du ändern willst.',
      'version_conflict',
    );
  }
}

/** Turns an API error into a German message without note content. */
export function toUserError(error: unknown, context = ''): UserError {
  if (error instanceof UserError) return error;
  if (error instanceof QkApiError) {
    const prefix = context ? `${context}: ` : '';
    switch (error.code) {
      case 'version_conflict':
        return new VersionConflictError(context || 'Notiz', error.currentLastModifiedAt);
      case 'not_found':
        return new UserError(`${prefix}nicht gefunden.`, 'not_found');
      case 'forbidden':
        return new UserError(`${prefix}das ist nicht deine Notiz; ändern geht nicht.`, 'forbidden');
      case 'rate_limited':
        return new UserError(
          `${prefix}Questkeeper bremst gerade (zu viele Änderungen pro Minute). Warte eine Minute und versuche es dann erneut.`,
          'rate_limited',
        );
      case 'unreachable':
        return new UserError(`${prefix}Questkeeper ist gerade nicht erreichbar.`, 'unreachable');
      default:
        if (error.status === 400) {
          const problems = error.problems.length ? ` (${error.problems.join('; ')})` : '';
          return new UserError(`${prefix}Questkeeper hat die Änderung abgelehnt: ${error.message}${problems}`, error.code);
        }
        if (error.status === 401 || error.status === 403) {
          return new UserError(
            `${prefix}Questkeeper lehnt den API-Schlüssel ab (${error.code}). Er braucht die Rechte notes:read, notes:write und campaigns:read.`,
            error.code,
          );
        }
        return new UserError(`${prefix}Questkeeper hat einen Fehler gemeldet (${error.status} ${error.code}).`, error.code);
    }
  }
  return new UserError('Unerwarteter Fehler auf dem Server. Bitte versuche es noch einmal.', 'internal');
}
