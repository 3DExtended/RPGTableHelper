import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the long-lived opaque refresh token issued by password login.
///
/// The access JWT stays in SharedPreferences (see [IApiConnectorService]),
/// while the refresh token lives here, in the platform secure storage.
abstract class ISecureRefreshTokenStorage {
  final bool isMock;
  const ISecureRefreshTokenStorage({required this.isMock});

  Future<String?> getRefreshToken();
  Future<bool> setRefreshToken(String refreshToken);
  Future<bool> deleteRefreshToken();
}

class SecureRefreshTokenStorage extends ISecureRefreshTokenStorage {
  const SecureRefreshTokenStorage() : super(isMock: false);

  static const _refreshTokenKey = 'refreshToken';
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<bool> setRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    return true;
  }

  @override
  Future<bool> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
    return true;
  }
}

class MockSecureRefreshTokenStorage extends ISecureRefreshTokenStorage {
  MockSecureRefreshTokenStorage({
    this.refreshTokenOverride,
    this.setResultOverride,
    this.removeResultOverride,
  }) : super(isMock: true);

  String? refreshTokenOverride;
  final bool? setResultOverride;
  final bool? removeResultOverride;

  @override
  Future<String?> getRefreshToken() async => refreshTokenOverride;

  @override
  Future<bool> setRefreshToken(String refreshToken) async {
    refreshTokenOverride = refreshToken;
    return setResultOverride ?? true;
  }

  @override
  Future<bool> deleteRefreshToken() async {
    refreshTokenOverride = null;
    return removeResultOverride ?? true;
  }
}
