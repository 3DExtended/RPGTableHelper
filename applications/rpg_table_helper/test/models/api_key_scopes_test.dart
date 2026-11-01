import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/models/api_key_scopes.dart';

void main() {
  group('ApiKeyScopes.normalize', () {
    test('drops unknown scopes and sorts into backend order', () {
      expect(
        ApiKeyScopes.normalize(
            ['events', 'admin:all', 'notes:read', 'campaigns:read']),
        ['campaigns:read', 'notes:read', 'events'],
      );
    });
  });

  group('ApiKeyPreset.forScopes', () {
    test('recognises the read-only preset regardless of order', () {
      expect(
        ApiKeyPreset.forScopes(
            ['notes:read', 'characters:read', 'campaigns:read']),
        ApiKeyPreset.readOnly,
      );
    });

    test('recognises the companion preset', () {
      expect(
          ApiKeyPreset.forScopes(ApiKeyScopes.all), ApiKeyPreset.companionApp);
    });

    test('anything else is custom', () {
      expect(ApiKeyPreset.forScopes(['notes:read']), ApiKeyPreset.custom);
      expect(ApiKeyPreset.forScopes(const []), ApiKeyPreset.custom);
    });

    test('the companion preset covers every scope the backend knows', () {
      expect(ApiKeyPreset.companionApp.scopes, ApiKeyScopes.all);
    });
  });

  group('ApiKeyLifetime', () {
    final now = DateTime.utc(2026, 11, 1, 12);

    test('unlimited has no expiry', () {
      expect(ApiKeyLifetime.unlimited.expiresAtFrom(now), isNull);
    });

    test('limited lifetimes add their duration', () {
      expect(ApiKeyLifetime.days30.expiresAtFrom(now),
          DateTime.utc(2026, 12, 1, 12));
      expect(ApiKeyLifetime.year1.expiresAtFrom(now),
          DateTime.utc(2027, 11, 1, 12));
    });
  });
}
