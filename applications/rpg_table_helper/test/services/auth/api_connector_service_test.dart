import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoopAuthenticator extends Authenticator {
  @override
  Future<Request?> authenticate(Request request, Response response,
      [Request? originalRequest]) async {
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiConnectorService.configureAuthenticator', () {
    test('wires the configured authenticator into getChopperClient',
        () async {
      // arrange
      var apiConnectorService = ApiConnectorService();
      await apiConnectorService.setJwt('a-jwt');
      var authenticator = _NoopAuthenticator();

      // act
      apiConnectorService.configureAuthenticator(authenticator);
      var chopperClient = await apiConnectorService.getChopperClient();

      // assert
      expect(chopperClient, isNotNull);
      expect(chopperClient!.authenticator, same(authenticator));
    });

    test('getChopperClient works without a configured authenticator',
        () async {
      // arrange
      var apiConnectorService = ApiConnectorService();
      await apiConnectorService.setJwt('a-jwt');

      // act
      var chopperClient = await apiConnectorService.getChopperClient();

      // assert
      expect(chopperClient, isNotNull);
      expect(chopperClient!.authenticator, isNull);
    });
  });

  group('MockApiConnectorService.configureAuthenticator', () {
    test('records the configured authenticator', () {
      var mock = MockApiConnectorService();
      var authenticator = _NoopAuthenticator();

      mock.configureAuthenticator(authenticator);

      expect(mock.configuredAuthenticator, same(authenticator));
    });
  });
}
