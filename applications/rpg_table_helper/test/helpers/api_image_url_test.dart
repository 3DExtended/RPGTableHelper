import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/helpers/character_stats/get_player_visualization_widget.dart';

void main() {
  group('apiImageUrl', () {
    test('joins a server-relative path with the api base url', () {
      expect(
        apiImageUrl('/public/getimage/abc/key?metadataid=abc'),
        '${apiBaseUrl}public/getimage/abc/key?metadataid=abc',
      );
      expect(
        apiImageUrl('public/getimage/abc'),
        '${apiBaseUrl}public/getimage/abc',
      );
    });

    test('keeps full links as they are', () {
      const url =
          'https://questkeeper-prod.peter-esser.de/public/getimage/abc/key?metadataid=abc';
      expect(apiImageUrl(url), url);
      expect(
        apiImageUrl('http://127.0.0.1:5012/public/getimage/abc'),
        'http://127.0.0.1:5012/public/getimage/abc',
      );
    });
  });

  group('resolveStatImageUrl', () {
    test('keeps placeholder and asset handling', () {
      expect(
        resolveStatImageUrl(null),
        'assets/images/charactercard_placeholder.png',
      );
      expect(
        resolveStatImageUrl(''),
        'assets/images/charactercard_placeholder.png',
      );
      expect(resolveStatImageUrl('assets/images/x.png'), 'assets/images/x.png');
    });

    test('accepts relative paths and full links', () {
      expect(
        resolveStatImageUrl('/public/getimage/abc'),
        '${apiBaseUrl}public/getimage/abc',
      );
      expect(
        resolveStatImageUrl('https://example.com/a.png'),
        'https://example.com/a.png',
      );
    });
  });
}
