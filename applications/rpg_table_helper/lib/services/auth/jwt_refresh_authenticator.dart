import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:quest_keeper/services/auth/session_refresh_coordinator.dart';

/// Chopper [Authenticator] that reacts to a 401 response by refreshing the
/// access token once (via [ISessionRefreshCoordinator], which delegates to
/// the single-flight [ITokenRefresher]) and retrying the failed request
/// with the new `Authorization: Bearer` header.
///
/// Skips `SignIn/refresh` and `SignIn/logout` themselves to avoid
/// refresh/auth loops: a 401 there means the refresh token itself is dead,
/// which is already surfaced elsewhere (`SessionRestorer`,
/// `SessionRevoker`) rather than through this authenticator.
///
/// On a failed refresh, [ISessionRefreshCoordinator.refreshOrHandleFailure]
/// already clears local tokens and reports session loss (navigates to
/// `LoginScreen`); this authenticator just needs to give up on the retry by
/// returning `null`.
class JwtRefreshAuthenticator extends Authenticator {
  JwtRefreshAuthenticator({required this.sessionRefreshCoordinator});

  final ISessionRefreshCoordinator sessionRefreshCoordinator;

  static const _excludedPathFragments = <String>[
    'signin/refresh',
    'signin/logout',
  ];

  @override
  FutureOr<Request?> authenticate(
    Request request,
    Response response, [
    Request? originalRequest,
  ]) async {
    if (response.statusCode != 401) {
      return null;
    }

    var path = (originalRequest ?? request).url.path.toLowerCase();
    if (_excludedPathFragments.any((fragment) => path.contains(fragment))) {
      return null;
    }

    var newAccessToken =
        await sessionRefreshCoordinator.refreshOrHandleFailure();
    if (newAccessToken == null) {
      return null;
    }

    return request.copyWith(headers: {
      ...request.headers,
      'Authorization': 'Bearer $newAccessToken',
    });
  }
}
