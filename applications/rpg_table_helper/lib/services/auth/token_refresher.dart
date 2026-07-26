import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/services/auth/access_token_expiry_store.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/systemclock_service.dart';

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
  ///
  /// Single-flight: concurrent callers observe the exact same in-flight
  /// refresh call instead of each triggering their own `SignIn/refresh`
  /// request.
  Future<bool> refresh();

  /// Convenience wrapper around [refresh] for callers (401 authenticator,
  /// SSE `refreshJwt`, [SessionRefreshCoordinator]) that just need "give me
  /// a usable access token or tell me it failed". Returns the fresh access
  /// token on success, `null` on failure.
  Future<String?> refreshAndGetAccessToken();
}

class TokenRefresher extends ITokenRefresher {
  TokenRefresher({
    required this.apiConnectorService,
    required this.secureRefreshTokenStorage,
    required this.accessTokenExpiryStore,
    required this.systemClockService,
    String? baseUrl,
    RefreshHttpCaller? httpCaller,
  })  : _baseUrl = baseUrl,
        _httpCaller = httpCaller ?? _defaultHttpCaller,
        super(isMock: false);

  final IApiConnectorService apiConnectorService;
  final ISecureRefreshTokenStorage secureRefreshTokenStorage;
  final IAccessTokenExpiryStore accessTokenExpiryStore;
  final ISystemClockService systemClockService;
  final String? _baseUrl;
  final RefreshHttpCaller _httpCaller;

  /// Guards concurrent [refresh] callers: the first caller starts the
  /// request and stores its Future here; every other caller that arrives
  /// while it's still in flight just awaits the same Future instead of
  /// issuing its own `SignIn/refresh` call.
  Future<bool>? _inFlightRefresh;

  @override
  Future<bool> refresh() {
    return _inFlightRefresh ??= _performRefresh().whenComplete(() {
      _inFlightRefresh = null;
    });
  }

  @override
  Future<String?> refreshAndGetAccessToken() async {
    var succeeded = await refresh();
    if (!succeeded) return null;
    return apiConnectorService.getJwt();
  }

  Future<bool> _performRefresh() async {
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
    await _persistExpiryIfPresent(tokenPair);
    apiConnectorService.clearCache();

    return true;
  }

  Future<void> _persistExpiryIfPresent(Map<String, dynamic> tokenPair) async {
    var expiresIn = tokenPair['expiresIn'];
    if (expiresIn is! num) return;

    await accessTokenExpiryStore.setExpiry(
      systemClockService.now().add(Duration(seconds: expiresIn.toInt())),
    );
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
  MockTokenRefresher({this.refreshResultOverride, this.accessTokenOverride})
      : super(isMock: true);

  final bool? refreshResultOverride;
  final String? accessTokenOverride;
  int refreshCallCount = 0;
  int refreshAndGetAccessTokenCallCount = 0;

  @override
  Future<bool> refresh() async {
    refreshCallCount++;
    return refreshResultOverride ?? true;
  }

  @override
  Future<String?> refreshAndGetAccessToken() async {
    refreshAndGetAccessTokenCallCount++;
    var succeeded = await refresh();
    if (!succeeded) return null;
    return accessTokenOverride ?? 'mock-access-token';
  }
}
