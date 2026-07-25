import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';

typedef RefreshHttpCaller = Future<http.Response> Function(
    Uri uri, String jsonBody);

/// Reads the stored refresh token, exchanges it for a new access + refresh
/// token pair via `POST /SignIn/refresh`, and persists the new pair on
/// success. This is the single entry point later auto-refresh wiring
/// (proactive timer, 401 retry, cold-start restore) will call into.
abstract class ITokenRefresher {
  final bool isMock;
  const ITokenRefresher({required this.isMock});

  /// Returns true if the refresh succeeded (and the new pair was persisted),
  /// false if there was no refresh token to use, the server rejected it, or
  /// the request failed.
  Future<bool> refresh();
}

class TokenRefresher extends ITokenRefresher {
  TokenRefresher({
    required this.apiConnectorService,
    required this.secureRefreshTokenStorage,
    String? baseUrl,
    RefreshHttpCaller? httpCaller,
  })  : _baseUrl = baseUrl,
        _httpCaller = httpCaller ?? _defaultHttpCaller,
        super(isMock: false);

  final IApiConnectorService apiConnectorService;
  final ISecureRefreshTokenStorage secureRefreshTokenStorage;
  final String? _baseUrl;
  final RefreshHttpCaller _httpCaller;

  @override
  Future<bool> refresh() async {
    var refreshToken = await secureRefreshTokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    http.Response response;
    try {
      response = await _httpCaller(
        Uri.parse('${_resolvedBaseUrl()}SignIn/refresh'),
        jsonEncode({'refreshToken': refreshToken}),
      );
    } catch (_) {
      return false;
    }

    if (response.statusCode != 200) {
      return false;
    }

    Map<String, dynamic> tokenPair;
    try {
      tokenPair = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return false;
    }

    var accessToken = tokenPair['accessToken'] as String?;
    var newRefreshToken = tokenPair['refreshToken'] as String?;
    if (accessToken == null || newRefreshToken == null) {
      return false;
    }

    await apiConnectorService.setJwt(accessToken);
    await secureRefreshTokenStorage.setRefreshToken(newRefreshToken);
    apiConnectorService.clearCache();

    return true;
  }

  String _resolvedBaseUrl() {
    final b = _baseUrl ?? apiBaseUrl;
    return b.endsWith('/') ? b : '$b/';
  }

  static Future<http.Response> _defaultHttpCaller(Uri uri, String jsonBody) {
    return http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );
  }
}

class MockTokenRefresher extends ITokenRefresher {
  MockTokenRefresher({this.refreshResultOverride}) : super(isMock: true);

  final bool? refreshResultOverride;
  int refreshCallCount = 0;

  @override
  Future<bool> refresh() async {
    refreshCallCount++;
    return refreshResultOverride ?? true;
  }
}
