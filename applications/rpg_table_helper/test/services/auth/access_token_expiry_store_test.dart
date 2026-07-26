import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/auth/access_token_expiry_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AccessTokenExpiryStore', () {
    test('returns null when nothing was persisted yet', () async {
      var store = AccessTokenExpiryStore();

      var result = await store.getExpiry();

      expect(result, isNull);
    });

    test('round-trips a persisted expiry as UTC', () async {
      var store = AccessTokenExpiryStore();
      var expiry = DateTime.utc(2030, 1, 1, 12);

      await store.setExpiry(expiry);
      var result = await store.getExpiry();

      expect(result, expiry);
    });

    test('clearExpiry removes the persisted value', () async {
      var store = AccessTokenExpiryStore();
      await store.setExpiry(DateTime.utc(2030, 1, 1, 12));

      await store.clearExpiry();
      var result = await store.getExpiry();

      expect(result, isNull);
    });
  });

  group('MockAccessTokenExpiryStore', () {
    test('tracks set/clear call counts', () async {
      var store = MockAccessTokenExpiryStore();

      await store.setExpiry(DateTime.utc(2030, 1, 1));
      expect(store.setExpiryCallCount, 1);
      expect(await store.getExpiry(), DateTime.utc(2030, 1, 1));

      await store.clearExpiry();
      expect(store.clearExpiryCallCount, 1);
      expect(await store.getExpiry(), isNull);
    });
  });
}
