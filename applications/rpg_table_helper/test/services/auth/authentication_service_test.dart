import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/authentication_service.dart';
import 'package:quest_keeper/services/auth/encryption_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';

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
  });
}
