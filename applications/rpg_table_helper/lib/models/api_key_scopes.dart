import 'package:quest_keeper/l10n/app_localizations.dart';

/// The permissions an API key can be granted. Mirrors `ApiKeyScopes` in the backend.
class ApiKeyScopes {
  static const campaignsRead = 'campaigns:read';
  static const charactersRead = 'characters:read';
  static const charactersWrite = 'characters:write';
  static const notesRead = 'notes:read';
  static const notesWrite = 'notes:write';
  static const fightsPlay = 'fights:play';
  static const events = 'events';

  /// All scopes in the order the backend returns them.
  static const all = [
    campaignsRead,
    charactersRead,
    charactersWrite,
    notesRead,
    notesWrite,
    fightsPlay,
    events,
  ];

  /// What keys could do before scopes existed.
  static const readOnly = [campaignsRead, charactersRead, notesRead];

  /// Everything a third-party player app needs to replace the player screen.
  static const companionApp = all;

  /// Returns [scopes] restricted to known scopes, in canonical order.
  static List<String> normalize(Iterable<String> scopes) =>
      all.where(scopes.contains).toList();

  static String label(AppLocalizations l10n, String scope) {
    switch (scope) {
      case campaignsRead:
        return l10n.apiKeyScopeCampaignsRead;
      case charactersRead:
        return l10n.apiKeyScopeCharactersRead;
      case charactersWrite:
        return l10n.apiKeyScopeCharactersWrite;
      case notesRead:
        return l10n.apiKeyScopeNotesRead;
      case notesWrite:
        return l10n.apiKeyScopeNotesWrite;
      case fightsPlay:
        return l10n.apiKeyScopeFightsPlay;
      case events:
        return l10n.apiKeyScopeEvents;
      default:
        return scope;
    }
  }
}

enum ApiKeyPreset {
  readOnly,
  companionApp,
  custom;

  /// The preset whose scopes match [scopes] exactly, or [custom].
  static ApiKeyPreset forScopes(Iterable<String> scopes) {
    var normalized = ApiKeyScopes.normalize(scopes);
    if (_sameScopes(normalized, ApiKeyScopes.companionApp)) {
      return ApiKeyPreset.companionApp;
    }
    if (_sameScopes(normalized, ApiKeyScopes.readOnly)) {
      return ApiKeyPreset.readOnly;
    }
    return ApiKeyPreset.custom;
  }

  /// The scopes of this preset; empty for [custom].
  List<String> get scopes {
    switch (this) {
      case ApiKeyPreset.readOnly:
        return ApiKeyScopes.readOnly;
      case ApiKeyPreset.companionApp:
        return ApiKeyScopes.companionApp;
      case ApiKeyPreset.custom:
        return const [];
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case ApiKeyPreset.readOnly:
        return l10n.apiKeyPresetReadOnly;
      case ApiKeyPreset.companionApp:
        return l10n.apiKeyPresetCompanion;
      case ApiKeyPreset.custom:
        return l10n.apiKeyPresetCustom;
    }
  }

  static bool _sameScopes(List<String> a, List<String> b) =>
      a.length == b.length && a.every(b.contains);
}

/// How long a new key stays valid.
enum ApiKeyLifetime {
  unlimited(null),
  days30(Duration(days: 30)),
  days90(Duration(days: 90)),
  year1(Duration(days: 365));

  const ApiKeyLifetime(this.duration);

  final Duration? duration;

  DateTime? expiresAtFrom(DateTime now) =>
      duration == null ? null : now.add(duration!);

  String label(AppLocalizations l10n) {
    switch (this) {
      case ApiKeyLifetime.unlimited:
        return l10n.apiKeyExpiryNever;
      case ApiKeyLifetime.days30:
        return l10n.apiKeyExpiry30Days;
      case ApiKeyLifetime.days90:
        return l10n.apiKeyExpiry90Days;
      case ApiKeyLifetime.year1:
        return l10n.apiKeyExpiry1Year;
    }
  }
}
