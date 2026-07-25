import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/auth/session_restorer.dart';
import 'package:quest_keeper/services/auth/token_refresher.dart';

void main() {
  group('SessionRestorer.restore', () {
    test(
        'returns needsLogin and never calls refresh when no refresh token is stored',
        () async {
      // arrange
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage();
      var tokenRefresher = MockTokenRefresher();
      var sessionRestorer = SessionRestorer(
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        tokenRefresher: tokenRefresher,
      );

      // act
      var result = await sessionRestorer.restore();

      // assert
      expect(result, SessionRestoreResult.needsLogin);
      expect(tokenRefresher.refreshCallCount, 0);
    });

    test('returns restored when a refresh token is stored and refresh succeeds',
        () async {
      // arrange
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'a-stored-refresh-token',
      );
      var tokenRefresher = MockTokenRefresher(refreshResultOverride: true);
      var sessionRestorer = SessionRestorer(
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        tokenRefresher: tokenRefresher,
      );

      // act
      var result = await sessionRestorer.restore();

      // assert
      expect(result, SessionRestoreResult.restored);
      expect(tokenRefresher.refreshCallCount, 1);
    });

    test(
        'returns needsLogin when a refresh token is stored but refresh fails (expired/revoked/unreachable)',
        () async {
      // arrange
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'a-dead-refresh-token',
      );
      var tokenRefresher = MockTokenRefresher(refreshResultOverride: false);
      var sessionRestorer = SessionRestorer(
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        tokenRefresher: tokenRefresher,
      );

      // act
      var result = await sessionRestorer.restore();

      // assert
      expect(result, SessionRestoreResult.needsLogin);
      expect(tokenRefresher.refreshCallCount, 1);
    });
  });

  group('MockSessionRestorer', () {
    test('tracks call count and returns the configured result', () async {
      var mock = MockSessionRestorer(
        restoreResultOverride: SessionRestoreResult.restored,
      );

      var result = await mock.restore();

      expect(result, SessionRestoreResult.restored);
      expect(mock.restoreCallCount, 1);
    });

    test('defaults to needsLogin when no override is configured', () async {
      var mock = MockSessionRestorer();

      var result = await mock.restore();

      expect(result, SessionRestoreResult.needsLogin);
    });
  });
}
