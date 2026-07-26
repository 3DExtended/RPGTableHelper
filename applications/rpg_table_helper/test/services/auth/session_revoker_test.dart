import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/auth/session_revoker.dart';

void main() {
  group('SessionRevoker.logout', () {
    test(
        'posts the stored refresh token to SignIn/logout and clears local jwt + refresh token',
        () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'the-refresh-token',
      );
      Uri? capturedUri;
      String? capturedBody;
      var sessionRevoker = SessionRevoker(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        httpCaller: (uri, body) async {
          capturedUri = uri;
          capturedBody = body;
          return http.Response('', 200);
        },
      );

      // act
      await sessionRevoker.logout();

      // assert
      expect(capturedUri?.path, contains('SignIn/logout'));
      expect(capturedBody, contains('the-refresh-token'));
      expect(apiConnectorService.deleteJwtCallCount, 1);
      expect(secureRefreshTokenStorage.refreshTokenOverride, isNull);
    });

    test('clears local tokens even when there is no stored refresh token',
        () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage();
      var callCount = 0;
      var sessionRevoker = SessionRevoker(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        httpCaller: (uri, body) async {
          callCount++;
          return http.Response('', 200);
        },
      );

      // act
      await sessionRevoker.logout();

      // assert
      expect(callCount, 0);
      expect(apiConnectorService.deleteJwtCallCount, 1);
    });

    test(
        'clears local tokens even when the server call fails (best-effort revoke)',
        () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'some-refresh-token',
      );
      var sessionRevoker = SessionRevoker(
        apiConnectorService: apiConnectorService,
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        httpCaller: (uri, body) async => throw Exception('network down'),
      );

      // act
      await sessionRevoker.logout();

      // assert
      expect(apiConnectorService.deleteJwtCallCount, 1);
      expect(secureRefreshTokenStorage.refreshTokenOverride, isNull);
    });
  });

  group('MockSessionRevoker', () {
    test('tracks call count', () async {
      var mock = MockSessionRevoker();

      await mock.logout();

      expect(mock.logoutCallCount, 1);
    });
  });
}
