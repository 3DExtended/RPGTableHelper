import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/services/auth/access_token_expiry_store.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/authentication_service.dart';
import 'package:quest_keeper/services/auth/encryption_service.dart';
import 'package:quest_keeper/services/auth/rsa_key_helper.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/systemclock_service.dart';

const _challenge = {'id': 'c0ffee', 'pp': 'pepper', 'ri': 42};

/// A fake backend for the sign-in endpoints. It hands out [_challenge]
/// encrypted for the app's key, records every request and answers the
/// login, reset request and reset with the given status codes.
class _FakeSignInBackend {
  _FakeSignInBackend(
    this.appKeyPair, {
    this.loginStatus = 200,
    this.requestResetStatus = 200,
    this.resetStatus = 200,
  });

  final AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> appKeyPair;
  final int loginStatus;
  final int requestResetStatus;
  final int resetStatus;
  final requests = <http.Request>[];

  Map<String, dynamic> bodyOf(String path) =>
      jsonDecode(requests.lastWhere((r) => r.url.path == path).body)
          as Map<String, dynamic>;

  Swagger client() => Swagger.create(
    httpClient: MockClient(_handle),
    baseUrl: Uri.parse('http://localhost/'),
  );

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final path = request.url.path;
    if (path.startsWith('/SignIn/getloginchallengeforusername/')) {
      return _text(
        RsaKeyHelper.encrypt(jsonEncode(_challenge), appKeyPair.publicKey),
        200,
      );
    }
    switch (path) {
      case '/SignIn/login':
        return loginStatus == 200
            ? http.Response(
                jsonEncode({
                  'accessToken': 'access',
                  'refreshToken': 'refresh',
                  'expiresIn': 900,
                }),
                200,
                headers: {'content-type': 'application/json'},
              )
            : _text('', loginStatus);
      case '/SignIn/requestresetpassword':
        return _text(
          requestResetStatus == 200
              ? 'Email sent'
              : 'Could not create password reset mail or token!',
          requestResetStatus,
        );
      case '/SignIn/resetpassword':
        return _text(
          resetStatus == 200
              ? 'New password set'
              : 'Could not set new password!',
          resetStatus,
        );
    }
    return _text('Not Found', 404);
  }

  static http.Response _text(String body, int status) => http.Response(
    body,
    status,
    headers: {'content-type': 'text/plain; charset=utf-8'},
  );
}

void main() {
  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> appKeyPair;

  setUpAll(() {
    appKeyPair = RsaKeyHelper.getRsaKeyPair(RsaKeyHelper.getSecureRandom());
  });

  AuthenticationService serviceFor(_FakeSignInBackend backend) =>
      AuthenticationService(
        apiConnectorService: MockApiConnectorService(
          connectorOverride: backend.client(),
        ),
        encryptionService: MockEncryptionService(keyPairOverride: appKeyPair),
        secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
        accessTokenExpiryStore: MockAccessTokenExpiryStore(),
        systemClockService: MockSystemClockService(),
      );

  test(
    'resetPassword sends the user secret that login sends for that password',
    () async {
      final backend = _FakeSignInBackend(appKeyPair);
      final service = serviceFor(backend);

      final reset = await service.resetPassword(
        username: 'Frodo',
        email: 'frodo@shire.me',
        resetCode: '123-456',
        newPassword: 'mellon-friend',
      );
      expect(reset.isSuccessful, isTrue);
      expect(reset.result, isTrue);

      final resetBody = backend.bodyOf('/SignIn/resetpassword');
      expect(resetBody['username'], 'Frodo');
      expect(resetBody['email'], 'frodo@shire.me');
      expect(resetBody['resetCode'], '123-456');
      // Never the plain password: the secret derived from the user's challenge.
      expect(resetBody['newHashedPassword'], isNot('mellon-friend'));
      expect(
        resetBody['newHashedPassword'],
        MockEncryptionService().calculateUserSecretForEncryptionChallenge(
          _challenge,
          'mellon-friend',
        ),
      );
      expect(
        backend.requests.first.url.path,
        '/SignIn/getloginchallengeforusername/Frodo',
      );

      final login = await service.loginWithUsernameAndPassword(
        username: 'Frodo',
        password: 'mellon-friend',
      );
      expect(login.isSuccessful, isTrue);
      expect(
        backend.bodyOf('/SignIn/login')['userSecretByEncryptionChallenge'],
        resetBody['newHashedPassword'],
      );
    },
  );

  test(
    'resetPassword keeps the status code of a rejected reset code',
    () async {
      final backend = _FakeSignInBackend(appKeyPair, resetStatus: 400);

      final reset = await serviceFor(backend).resetPassword(
        username: 'Frodo',
        email: 'frodo@shire.me',
        resetCode: '999-999',
        newPassword: 'mellon-friend',
      );

      expect(reset.isSuccessful, isFalse);
      expect(reset.statusCode, 400);
    },
  );

  test('requestPasswordReset posts username and email', () async {
    final backend = _FakeSignInBackend(appKeyPair);

    final result = await serviceFor(backend)
        .requestPasswordReset(username: 'Frodo', email: 'frodo@shire.me');

    expect(result.isSuccessful, isTrue);
    expect(backend.bodyOf('/SignIn/requestresetpassword'), {
      'email': 'frodo@shire.me',
      'username': 'Frodo',
    });
  });

  test(
    'requestPasswordReset keeps the status code when the server refuses',
    () async {
      final backend = _FakeSignInBackend(appKeyPair, requestResetStatus: 400);

      final result = await serviceFor(backend)
          .requestPasswordReset(username: 'Frodo', email: 'wrong@shire.me');

      expect(result.isSuccessful, isFalse);
      expect(result.statusCode, 400);
    },
  );

  test('a wrong password is a failed login, not a successful one', () async {
    final backend = _FakeSignInBackend(appKeyPair, loginStatus: 401);

    final login = await serviceFor(backend)
        .loginWithUsernameAndPassword(username: 'Frodo', password: 'wrong');

    expect(login.isSuccessful, isFalse);
    expect(login.result, isNull);
    expect(login.statusCode, 401);
  });
}
