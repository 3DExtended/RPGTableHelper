import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';

typedef RevokeHttpCaller = Future<http.Response> Function(
    Uri uri, String jsonBody);

/// Logs this device out: best-effort revokes the server-side `AuthSession`
/// tied to the stored refresh token (`POST /SignIn/logout`), then always
/// clears the local access JWT and refresh token regardless of whether the
/// server call succeeded — a device that can't reach the API must still be
/// able to log out locally.
abstract class ISessionRevoker {
  final bool isMock;
  const ISessionRevoker({required this.isMock});

  Future<void> logout();
}

class SessionRevoker extends ISessionRevoker {
  SessionRevoker({
    required this.apiConnectorService,
    required this.secureRefreshTokenStorage,
    String? baseUrl,
    RevokeHttpCaller? httpCaller,
  })  : _baseUrl = baseUrl,
        _httpCaller = httpCaller ?? _defaultHttpCaller,
        super(isMock: false);

  final IApiConnectorService apiConnectorService;
  final ISecureRefreshTokenStorage secureRefreshTokenStorage;
  final String? _baseUrl;
  final RevokeHttpCaller _httpCaller;

  @override
  Future<void> logout() async {
    var refreshToken = await secureRefreshTokenStorage.getRefreshToken();

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _httpCaller(
          Uri.parse('${_resolvedBaseUrl()}SignIn/logout'),
          jsonEncode({'refreshToken': refreshToken}),
        );
      } catch (_) {
        // best-effort: local logout must still succeed if the API is
        // unreachable or the request otherwise fails.
      }
    }

    await apiConnectorService.deleteJwt();
    await secureRefreshTokenStorage.deleteRefreshToken();
    apiConnectorService.clearCache();
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

class MockSessionRevoker extends ISessionRevoker {
  MockSessionRevoker() : super(isMock: true);

  int logoutCallCount = 0;

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }
}
