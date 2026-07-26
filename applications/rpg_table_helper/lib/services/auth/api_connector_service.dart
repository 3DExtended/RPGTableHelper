import 'package:chopper/chopper.dart';
import 'package:http/http.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IApiConnectorService {
  final bool isMock;
  IApiConnectorService({required this.isMock});

  Future<Swagger?> getApiConnector({
    bool requiresJwt = true,
  });
  Future<String?> getJwt();
  Future<bool> setJwt(String jwt);
  Future<bool> deleteJwt();

  Future<ChopperClient?> getChopperClient({
    bool requiresJwt = true,
  });

  void clearCache();

  /// Wires a Chopper [Authenticator] (e.g. `JwtRefreshAuthenticator`) into
  /// every [ChopperClient] built by [getChopperClient] from now on.
  ///
  /// Set from `DependencyProvider` after the authenticator's own
  /// dependencies (which need this very service) have been constructed,
  /// rather than through the constructor, to avoid a circular dependency
  /// between [IApiConnectorService] and the session-refresh machinery.
  void configureAuthenticator(Authenticator authenticator);
}

class ApiConnectorService extends IApiConnectorService {
  ApiConnectorService() : super(isMock: false);

  Swagger? _cachedSwaggerClient;
  Authenticator? _authenticator;

  @override
  void configureAuthenticator(Authenticator authenticator) {
    _authenticator = authenticator;
  }

  @override
  Future<String?> getJwt() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('jwt')) {
      var jwt = prefs.getString('jwt');
      return jwt;
    }
    return null;
  }

  @override
  Future<bool> setJwt(String jwt) async {
    clearCache();
    var prefs = await SharedPreferences.getInstance();
    return await prefs.setString('jwt', jwt);
  }

  @override
  Future<ChopperClient?> getChopperClient({
    bool requiresJwt = true,
  }) async {
    var jwt = await getJwt();

    List<Interceptor> interceptorsToUse = [];
    if (jwt != null) {
      var headerContent = 'Bearer $jwt';
      interceptorsToUse
          .add(HeadersInterceptor({'Authorization': headerContent}));
    } else {
      if (requiresJwt) {
        return null;
      }
    }

    final telemetryHttpClient = Client();
    var chopperClient = ChopperClient(
      client: telemetryHttpClient,
      services: [Swagger.create(baseUrl: Uri.parse(apiBaseUrl))],
      converter: $JsonSerializableConverter(),
      interceptors: interceptorsToUse,
      baseUrl: Uri.parse(apiBaseUrl),
      authenticator: _authenticator,
    );

    return chopperClient;
  }

  @override
  Future<Swagger?> getApiConnector({
    bool requiresJwt = true,
  }) async {
    if (_cachedSwaggerClient != null) {
      return _cachedSwaggerClient;
    }
    var chopperClient = await getChopperClient(requiresJwt: requiresJwt);
    if (chopperClient == null) return null;

    var tempClient = Swagger.create(client: chopperClient);

    if (requiresJwt) {
      // only cache if jwt is configured
      _cachedSwaggerClient = tempClient;
    }

    return tempClient;
  }

  @override
  void clearCache() {
    _cachedSwaggerClient = null;
  }

  @override
  Future<bool> deleteJwt() async {
    clearCache();
    var prefs = await SharedPreferences.getInstance();
    return await prefs.remove('jwt');
  }
}

class MockApiConnectorService extends IApiConnectorService {
  MockApiConnectorService({
    this.connectorOverride,
    this.jwtOverride,
    this.jwtSetResultOverride,
    this.jwtRemoveResultOverride,
  }) : super(isMock: true);

  final Swagger? connectorOverride;
  final String? jwtOverride;
  final bool? jwtSetResultOverride;
  final bool? jwtRemoveResultOverride;

  /// The last value passed to [setJwt], for assertions in tests.
  String? lastSetJwt;

  /// The number of times [deleteJwt] was called, for assertions in tests.
  int deleteJwtCallCount = 0;

  /// The last authenticator passed to [configureAuthenticator], for
  /// assertions in tests.
  Authenticator? configuredAuthenticator;

  @override
  void clearCache() {}

  @override
  void configureAuthenticator(Authenticator authenticator) {
    configuredAuthenticator = authenticator;
  }

  @override
  Future<Swagger?> getApiConnector({
    bool requiresJwt = true,
  }) {
    return Future.value(connectorOverride);
  }

  @override
  Future<String?> getJwt() {
    return Future.value(jwtOverride);
  }

  @override
  Future<bool> setJwt(String jwt) async {
    lastSetJwt = jwt;
    return Future.value(jwtSetResultOverride ?? true);
  }

  @override
  Future<bool> deleteJwt() async {
    deleteJwtCallCount++;
    return Future.value(jwtRemoveResultOverride ?? true);
  }

  @override
  Future<ChopperClient?> getChopperClient({bool requiresJwt = true}) {
    return Future.value(null);
  }
}
