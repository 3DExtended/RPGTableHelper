import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/services/auth/jwt_refresh_authenticator.dart';
import 'package:quest_keeper/services/auth/session_refresh_coordinator.dart';

void main() {
  Request buildRequest(String path) => Request(
        'GET',
        Uri.parse(path),
        Uri.parse('https://example.test/'),
        headers: const {'Authorization': 'Bearer old-jwt'},
      );

  group('JwtRefreshAuthenticator.authenticate', () {
    test('returns null when the response is not a 401', () async {
      // arrange
      var coordinator =
          MockSessionRefreshCoordinator(refreshResultOverride: 'new-jwt');
      var authenticator =
          JwtRefreshAuthenticator(sessionRefreshCoordinator: coordinator);
      var request = buildRequest('rpgentity');
      var response = Response(http.Response('', 500), null);

      // act
      var result = await authenticator.authenticate(request, response);

      // assert
      expect(result, isNull);
      expect(coordinator.refreshOrHandleFailureCallCount, 0);
    });

    test(
        'on a 401 refreshes once and retries with the new bearer token',
        () async {
      // arrange
      var coordinator =
          MockSessionRefreshCoordinator(refreshResultOverride: 'new-jwt');
      var authenticator =
          JwtRefreshAuthenticator(sessionRefreshCoordinator: coordinator);
      var request = buildRequest('rpgentity');
      var response = Response(http.Response('', 401), null);

      // act
      var result = await authenticator.authenticate(request, response);

      // assert
      expect(coordinator.refreshOrHandleFailureCallCount, 1);
      expect(result, isNotNull);
      expect(result!.headers['Authorization'], 'Bearer new-jwt');
    });

    test('returns null and does not retry when refresh fails', () async {
      // arrange
      var coordinator =
          MockSessionRefreshCoordinator(refreshResultOverride: null);
      var authenticator =
          JwtRefreshAuthenticator(sessionRefreshCoordinator: coordinator);
      var request = buildRequest('rpgentity');
      var response = Response(http.Response('', 401), null);

      // act
      var result = await authenticator.authenticate(request, response);

      // assert
      expect(coordinator.refreshOrHandleFailureCallCount, 1);
      expect(result, isNull);
    });

    test('skips refresh for SignIn/refresh to avoid loops', () async {
      // arrange
      var coordinator =
          MockSessionRefreshCoordinator(refreshResultOverride: 'new-jwt');
      var authenticator =
          JwtRefreshAuthenticator(sessionRefreshCoordinator: coordinator);
      var request = buildRequest('SignIn/refresh');
      var response = Response(http.Response('', 401), null);

      // act
      var result = await authenticator.authenticate(request, response);

      // assert
      expect(result, isNull);
      expect(coordinator.refreshOrHandleFailureCallCount, 0);
    });

    test('skips refresh for SignIn/logout to avoid loops', () async {
      // arrange
      var coordinator =
          MockSessionRefreshCoordinator(refreshResultOverride: 'new-jwt');
      var authenticator =
          JwtRefreshAuthenticator(sessionRefreshCoordinator: coordinator);
      var request = buildRequest('SignIn/logout');
      var response = Response(http.Response('', 401), null);

      // act
      var result = await authenticator.authenticate(request, response);

      // assert
      expect(result, isNull);
      expect(coordinator.refreshOrHandleFailureCallCount, 0);
    });
  });
}
