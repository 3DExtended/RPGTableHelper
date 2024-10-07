import 'package:chopper/chopper.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.swagger.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IApiConnectorService {
  final bool isMock;
  IApiConnectorService({required this.isMock});

  Future<Swagger?> getApiConnector(
    BuildContext? context, {
    bool requiresJwt = true,
  });
  Future<String?> getJwt();
  Future<bool> setJwt(String jwt);
  Future<bool> deleteJwt();

  void clearCache();
}

class ApiConnectorService extends IApiConnectorService {
  ApiConnectorService() : super(isMock: false);

  Swagger? _cachedSwaggerClient;

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
  Future<Swagger?> getApiConnector(
    BuildContext? context, {
    bool requiresJwt = true,
  }) async {
    if (_cachedSwaggerClient != null) {
      return _cachedSwaggerClient;
    }

    var jwt = await getJwt();

    List<Interceptor> interceptorsToUse = [];
    if (jwt != null) {
      var headerContent = 'Bearer $jwt';
      interceptorsToUse
          .add(HeadersInterceptor({'Authorization': headerContent}));
    } else {
      if (requiresJwt && (context == null || !context.mounted)) {
        return null;
      }
    }

    final telemetryHttpClient = Client();

    var tempClient = Swagger.create(
        client: ChopperClient(
            client: telemetryHttpClient,
            services: [Swagger.create(baseUrl: Uri.parse(apiBaseUrl))],
            converter: $JsonSerializableConverter(),
            interceptors: interceptorsToUse,
            baseUrl: Uri.parse(apiBaseUrl)));

    if (requiresJwt) {
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

  @override
  void clearCache() {}

  @override
  Future<Swagger?> getApiConnector(
    BuildContext? context, {
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
    return Future.value(jwtSetResultOverride ?? true);
  }

  @override
  Future<bool> deleteJwt() async {
    return Future.value(jwtRemoveResultOverride ?? true);
  }
}
