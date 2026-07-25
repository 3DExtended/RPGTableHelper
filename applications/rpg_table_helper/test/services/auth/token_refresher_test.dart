import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/auth/token_refresher.dart';

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
      Uri? capturedUri;
      String? capturedBody;
      var tokenRefresher = TokenRefresher(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
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
    });

    test('returns false and does not persist anything on a 401', () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'a-dead-refresh-token',
      );
      var tokenRefresher = TokenRefresher(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
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
        httpCaller: (uri, body) async => throw Exception('network down'),
      );

      // act
      var result = await tokenRefresher.refresh();

      // assert
      expect(result, isFalse);
    });
  });

  group('MockTokenRefresher', () {
    test('tracks call count and returns the configured result', () async {
      var mock = MockTokenRefresher(refreshResultOverride: false);

      var result = await mock.refresh();

      expect(result, isFalse);
      expect(mock.refreshCallCount, 1);
    });
  });
}
