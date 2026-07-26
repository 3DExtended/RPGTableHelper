import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/auth/access_token_expiry_store.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/authentication_service.dart';
import 'package:quest_keeper/services/auth/encryption_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/systemclock_service.dart';

void main() {
  group('AuthenticationService.persistTokenPair', () {
    test(
        'stores the access token via setJwt and the refresh token in secure storage',
        () async {
      // arrange
      var apiConnectorService = MockApiConnectorService();
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage();
      var authenticationService = AuthenticationService(
        apiConnectorService: apiConnectorService,
        encryptionService: MockEncryptionService(),
        secureRefreshTokenStorage: secureRefreshTokenStorage,
        accessTokenExpiryStore: MockAccessTokenExpiryStore(),
        systemClockService: MockSystemClockService(),
      );

      // act
      await authenticationService.persistTokenPair(
        '{"accessToken":"the-access-token","refreshToken":"the-refresh-token","expiresIn":21600}',
      );

      // assert
      expect(apiConnectorService.lastSetJwt, 'the-access-token');
      expect(
        secureRefreshTokenStorage.refreshTokenOverride,
        'the-refresh-token',
      );
    });

    test('persists the absolute access-token expiry from expiresIn seconds',
        () async {
      // arrange
      var accessTokenExpiryStore = MockAccessTokenExpiryStore();
      var systemClockService =
          MockSystemClockService(nowOverride: DateTime.utc(2030, 1, 1, 12));
      var authenticationService = AuthenticationService(
        apiConnectorService: MockApiConnectorService(),
        encryptionService: MockEncryptionService(),
        secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
        accessTokenExpiryStore: accessTokenExpiryStore,
        systemClockService: systemClockService,
      );

      // act
      await authenticationService.persistTokenPair(
        '{"accessToken":"the-access-token","refreshToken":"the-refresh-token","expiresIn":900}',
      );

      // assert
      expect(
        accessTokenExpiryStore.expiryOverride,
        DateTime.utc(2030, 1, 1, 12).add(const Duration(seconds: 900)),
      );
    });
  });
}
