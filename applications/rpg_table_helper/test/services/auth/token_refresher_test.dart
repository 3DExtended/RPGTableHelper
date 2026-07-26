import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/services/auth/access_token_expiry_store.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/auth/token_refresher.dart';
import 'package:quest_keeper/services/systemclock_service.dart';

void main() {
  group('TokenRefresher.refresh', () {
    test('returns false and makes no call when no refresh token is stored',
        () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage();
      var callCount = 0;
      var tokenRefresher = TokenRefresher(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(),
        systemClockService: MockSystemClockService(),
        httpCaller: (uri, body) async {
          callCount++;
          return http.Response('', 200);
        },
      );

      // act
      var result = await tokenRefresher.refresh();

      // assert
      expect(result, isFalse);
      expect(callCount, 0);
    });

    test(
        'posts the stored refresh token and persists the new pair on success',
        () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'the-old-refresh-token',
      );
      var accessTokenExpiryStore = MockAccessTokenExpiryStore();
      var systemClockService =
          MockSystemClockService(nowOverride: DateTime.utc(2030, 1, 1, 12));
      Uri? capturedUri;
      String? capturedBody;
      var tokenRefresher = TokenRefresher(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        accessTokenExpiryStore: accessTokenExpiryStore,
        systemClockService: systemClockService,
        httpCaller: (uri, body) async {
          capturedUri = uri;
          capturedBody = body;
          return http.Response(
            '{"accessToken":"the-new-access-token","refreshToken":"the-new-refresh-token","expiresIn":21600}',
            200,
          );
        },
      );

      // act
      var result = await tokenRefresher.refresh();

      // assert
      expect(result, isTrue);
      expect(capturedUri?.path, contains('SignIn/refresh'));
      expect(capturedBody, contains('the-old-refresh-token'));
      expect(apiConnectorService.lastSetJwt, 'the-new-access-token');
      expect(
        secureRefreshTokenStorage.refreshTokenOverride,
        'the-new-refresh-token',
      );
      expect(
        accessTokenExpiryStore.expiryOverride,
        DateTime.utc(2030, 1, 1, 12).add(const Duration(seconds: 21600)),
      );
    });

    test('returns false and does not persist anything on a 401', () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'a-dead-refresh-token',
      );
      var accessTokenExpiryStore = MockAccessTokenExpiryStore();
      var tokenRefresher = TokenRefresher(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        accessTokenExpiryStore: accessTokenExpiryStore,
        systemClockService: MockSystemClockService(),
        httpCaller: (uri, body) async => http.Response('', 401),
      );

      // act
      var result = await tokenRefresher.refresh();

      // assert
      expect(result, isFalse);
      expect(apiConnectorService.lastSetJwt, isNull);
      expect(
        secureRefreshTokenStorage.refreshTokenOverride,
        'a-dead-refresh-token',
      );
      expect(accessTokenExpiryStore.expiryOverride, isNull);
    });

    test('returns false when the http call throws', () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'some-refresh-token',
      );
      var tokenRefresher = TokenRefresher(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(),
        systemClockService: MockSystemClockService(),
        httpCaller: (uri, body) async => throw Exception('network down'),
      );

      // act
      var result = await tokenRefresher.refresh();

      // assert
      expect(result, isFalse);
    });

    test(
        'single-flight: two concurrent refresh() calls share one in-flight '
        'request and both resolve to the same result', () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'the-old-refresh-token',
      );
      var httpCallCount = 0;
      final completer = Completer<http.Response>();
      var tokenRefresher = TokenRefresher(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(),
        systemClockService: MockSystemClockService(),
        httpCaller: (uri, body) async {
          httpCallCount++;
          return completer.future;
        },
      );

      // act: fire two overlapping refresh calls before the http response
      // resolves.
      var firstCall = tokenRefresher.refresh();
      var secondCall = tokenRefresher.refresh();

      completer.complete(http.Response(
        '{"accessToken":"the-new-access-token","refreshToken":"the-new-refresh-token","expiresIn":21600}',
        200,
      ));

      var results = await Future.wait([firstCall, secondCall]);

      // assert
      expect(httpCallCount, 1);
      expect(results, [true, true]);
    });

    test(
        'single-flight: a refresh() call after the in-flight one completes '
        'triggers a fresh http call', () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'the-old-refresh-token',
      );
      var httpCallCount = 0;
      var tokenRefresher = TokenRefresher(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(),
        systemClockService: MockSystemClockService(),
        httpCaller: (uri, body) async {
          httpCallCount++;
          return http.Response(
            '{"accessToken":"token-$httpCallCount","refreshToken":"refresh-$httpCallCount","expiresIn":21600}',
            200,
          );
        },
      );

      // act
      await tokenRefresher.refresh();
      await tokenRefresher.refresh();

      // assert
      expect(httpCallCount, 2);
    });
  });

  group('TokenRefresher.refreshAndGetAccessToken', () {
    test('returns the fresh access token on success', () async {
      // arrange: MockApiConnectorService.setJwt/getJwt are intentionally
      // decoupled (so other tests can assert what was *set* independently
      // of what *get* returns), so seed jwtOverride with the value the
      // fake server response will hand back via setJwt, mirroring how the
      // real ApiConnectorService persists-then-reads through
      // SharedPreferences.
      var apiConnectorService =
          MockApiConnectorService(jwtOverride: 'the-new-access-token');
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'the-old-refresh-token',
      );
      var tokenRefresher = TokenRefresher(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(),
        systemClockService: MockSystemClockService(),
        httpCaller: (uri, body) async => http.Response(
          '{"accessToken":"the-new-access-token","refreshToken":"the-new-refresh-token","expiresIn":21600}',
          200,
        ),
      );

      // act
      var result = await tokenRefresher.refreshAndGetAccessToken();

      // assert
      expect(result, 'the-new-access-token');
      expect(apiConnectorService.lastSetJwt, 'the-new-access-token');
    });

    test('returns null when the refresh fails', () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'a-dead-refresh-token',
      );
      var tokenRefresher = TokenRefresher(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(),
        systemClockService: MockSystemClockService(),
        httpCaller: (uri, body) async => http.Response('', 401),
      );

      // act
      var result = await tokenRefresher.refreshAndGetAccessToken();

      // assert
      expect(result, isNull);
    });
  });

  group('MockTokenRefresher', () {
    test('tracks call count and returns the configured result', () async {
      var mock = MockTokenRefresher(refreshResultOverride: false);

      var result = await mock.refresh();

      expect(result, isFalse);
      expect(mock.refreshCallCount, 1);
    });

    test('refreshAndGetAccessToken returns the configured access token', () async {
      var mock = MockTokenRefresher(accessTokenOverride: 'a-token');

      var result = await mock.refreshAndGetAccessToken();

      expect(result, 'a-token');
      expect(mock.refreshAndGetAccessTokenCallCount, 1);
    });

    test('refreshAndGetAccessToken returns null when refresh fails', () async {
      var mock = MockTokenRefresher(refreshResultOverride: false);

      var result = await mock.refreshAndGetAccessToken();

      expect(result, isNull);
    });
  });
}
