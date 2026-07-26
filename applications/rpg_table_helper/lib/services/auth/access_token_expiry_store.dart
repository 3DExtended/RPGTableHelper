import 'package:shared_preferences/shared_preferences.dart';

/// Persists the absolute UTC expiry of the current access JWT (computed from
/// the auth response's `expiresIn` seconds), so [SessionRefreshCoordinator]
/// can schedule a proactive refresh and app-resume can decide whether the
/// cached access token is still usable without needing a fresh
/// `expiresIn` from the server.
abstract class IAccessTokenExpiryStore {
  final bool isMock;
  const IAccessTokenExpiryStore({required this.isMock});

  Future<void> setExpiry(DateTime expiry);
  Future<DateTime?> getExpiry();
  Future<void> clearExpiry();
}

class AccessTokenExpiryStore extends IAccessTokenExpiryStore {
  const AccessTokenExpiryStore() : super(isMock: false);

  static const _expiryKey = 'accessTokenExpiryMillisSinceEpochUtc';

  @override
  Future<void> setExpiry(DateTime expiry) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_expiryKey, expiry.toUtc().millisecondsSinceEpoch);
  }

  @override
  Future<DateTime?> getExpiry() async {
    var prefs = await SharedPreferences.getInstance();
    var millis = prefs.getInt(_expiryKey);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  @override
  Future<void> clearExpiry() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expiryKey);
  }
}

class MockAccessTokenExpiryStore extends IAccessTokenExpiryStore {
  MockAccessTokenExpiryStore({this.expiryOverride}) : super(isMock: true);

  DateTime? expiryOverride;

  int setExpiryCallCount = 0;
  int clearExpiryCallCount = 0;

  @override
  Future<void> setExpiry(DateTime expiry) async {
    setExpiryCallCount++;
    expiryOverride = expiry;
  }

  @override
  Future<DateTime?> getExpiry() async => expiryOverride;

  @override
  Future<void> clearExpiry() async {
    clearExpiryCallCount++;
    expiryOverride = null;
  }
}
