import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_stats/multiselect_option_list_text.dart';

void main() {
  group('resolveMultiselectListText', () {
    test('prefers non-empty summary over description', () {
      expect(
        resolveMultiselectListText(
          summary: '  Short summary.  ',
          description: 'Long description that would otherwise be blurred.',
        ),
        'Short summary.',
      );
    });

    test('falls back when summary is null or blank', () {
      const description =
          'Zaubertrick der Verwandlung\nZeitaufwand: 1 Aktion\nYou whisper a message.';
      expect(
        resolveMultiselectListText(summary: null, description: description),
        'You whisper a message.',
      );
      expect(
        resolveMultiselectListText(summary: '   ', description: description),
        'You whisper a message.',
      );
    });
  });

  group('shortBlurbFromDescription', () {
    test('skips metadata lines and returns first content sentence', () {
      expect(
        shortBlurbFromDescription(
          'Hervorrufung des 1. Grades\n'
          'Zeitaufwand: 1 Aktion\n'
          'Reichweite: 18 m\n'
          'Komponenten: V, G\n'
          'Wirkungsdauer: unmittelbar\n'
          'Du streckst die Hände aus und Feuer schießt hervor.',
        ),
        'Du streckst die Hände aus und Feuer schießt hervor.',
      );
    });

    test('truncates long sentences with ellipsis', () {
      final long = 'A' * 100;
      final blurb = shortBlurbFromDescription(long);
      expect(blurb.length, 88);
      expect(blurb.endsWith('…'), isTrue);
    });

    test('returns empty string when only metadata remains', () {
      expect(
        shortBlurbFromDescription(
          'Zaubertrick\nZeitaufwand: 1 Aktion\nReichweite: 36 m',
        ),
        '',
      );
    });
  });
}
