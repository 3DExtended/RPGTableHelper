import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/auth/token_refresher.dart';

enum SessionRestoreResult {
  restored,

  /// No refresh token was ever stored on this device (fresh install, or an
  /// upgrade from an older JWT-only install). `LoginScreen` should not show
  /// a session-expired message for this case.
  needsLogin,

  /// A refresh token was stored but the server rejected it (expired,
  /// revoked, or logged out elsewhere). `LoginScreen` may show a
  /// session-expired message for this case.
  sessionExpired,
}

/// Cold-start gate deciding whether the app can skip `LoginScreen` and land
/// straight on `SelectGameModeScreen`.
///
/// Presence of a refresh token alone is not enough: it must still exchange
/// for a fresh token pair via [ITokenRefresher]. A missing refresh token
/// (upgrade from an older, JWT-only install), a rejected/expired/revoked
/// refresh token, or an unreachable API all fall back to [needsLogin] — the
/// app never enters on a cached access JWT alone (see PRD "Cold start /
/// upgrade").
abstract class ISessionRestorer {
  final bool isMock;
  const ISessionRestorer({required this.isMock});

  Future<SessionRestoreResult> restore();
}

class SessionRestorer extends ISessionRestorer {
  SessionRestorer({
    required this.secureRefreshTokenStorage,
    required this.tokenRefresher,
  }) : super(isMock: false);

  final ISecureRefreshTokenStorage secureRefreshTokenStorage;
  final ITokenRefresher tokenRefresher;

  @override
  Future<SessionRestoreResult> restore() async {
    var refreshToken = await secureRefreshTokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return SessionRestoreResult.needsLogin;
    }

    var refreshed = await tokenRefresher.refresh();
    return refreshed
        ? SessionRestoreResult.restored
        : SessionRestoreResult.sessionExpired;
  }
}

class MockSessionRestorer extends ISessionRestorer {
  MockSessionRestorer({this.restoreResultOverride}) : super(isMock: true);

  final SessionRestoreResult? restoreResultOverride;
  int restoreCallCount = 0;

  @override
  Future<SessionRestoreResult> restore() async {
    restoreCallCount++;
    return restoreResultOverride ?? SessionRestoreResult.needsLogin;
  }
}
