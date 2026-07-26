import 'dart:async';

import 'package:quest_keeper/services/auth/access_token_expiry_store.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/auth/token_refresher.dart';
import 'package:quest_keeper/services/systemclock_service.dart';

/// Coordinates every reason the app might need a fresh access token during
/// an ongoing session: a proactive timer that fires ~5 minutes before the
/// persisted expiry, the app-resume lifecycle hook, the Chopper 401
/// `JwtRefreshAuthenticator`, and the SSE `EventsClient.refreshJwt` hook.
///
/// All of these funnel through [ITokenRefresher.refresh], which is
/// single-flight, so it doesn't matter if several of them fire around the
/// same time (e.g. a 401 arrives right as the proactive timer also fires) —
/// only one `SignIn/refresh` call is made. [refreshOrHandleFailure] is also
/// the single place that clears local tokens and reports session loss on a
/// hard refresh failure, so every caller gets the same "boot to login"
/// behavior for free.
abstract class ISessionRefreshCoordinator {
  final bool isMock;
  const ISessionRefreshCoordinator({required this.isMock});

  /// (Re)schedules the proactive-refresh timer from the persisted access
  /// token expiry. If the token is already expired or within the lead
  /// window, refreshes right away instead of scheduling. No-ops if no
  /// expiry is persisted (no active session). Call after cold-start restore
  /// succeeds, when `SelectGameModeScreen` is shown (covers every login /
  /// register / SSO path, since they all land there), and after every
  /// successful refresh.
  Future<void> startMonitoring();

  /// Cancels the proactive-refresh timer, if any. Call on logout.
  void stopMonitoring();

  /// Call from the app-resume lifecycle hook. Refreshes immediately if the
  /// access token is already expired or within the proactive lead window;
  /// otherwise just makes sure the proactive timer is (re)armed.
  Future<void> onAppResume();

  /// Single entry point for "I need a valid access token right now"
  /// callers (401 authenticator, SSE `refreshJwt`). Delegates to the
  /// single-flight [ITokenRefresher.refresh]. On success returns the fresh
  /// access token. On failure, clears the local JWT, refresh token, and
  /// persisted expiry, and reports session loss via the configured
  /// callback, returning `null`.
  ///
  /// Purely refreshes-or-fails: it does not touch the proactive timer
  /// itself (see [startMonitoring] / the proactive-timer callback for
  /// that), so it's safe to call from anywhere without side effects on
  /// scheduling.
  Future<String?> refreshOrHandleFailure();
}

class SessionRefreshCoordinator extends ISessionRefreshCoordinator {
  SessionRefreshCoordinator({
    required this.tokenRefresher,
    required this.accessTokenExpiryStore,
    required this.systemClockService,
    required this.apiConnectorService,
    required this.secureRefreshTokenStorage,
    required this.onSessionLost,
    this.leadTime = const Duration(minutes: 5),
  }) : super(isMock: false);

  final ITokenRefresher tokenRefresher;
  final IAccessTokenExpiryStore accessTokenExpiryStore;
  final ISystemClockService systemClockService;
  final IApiConnectorService apiConnectorService;
  final ISecureRefreshTokenStorage secureRefreshTokenStorage;

  /// Called when a refresh attempt fails mid-session (tokens have already
  /// been cleared by the time this fires). Typically navigates to
  /// `LoginScreen`.
  final void Function() onSessionLost;

  final Duration leadTime;

  Timer? _timer;

  @override
  Future<void> startMonitoring() async {
    _cancelTimer();

    var expiry = await accessTokenExpiryStore.getExpiry();
    if (expiry == null) return;

    await _armFrom(expiry, allowImmediateRefresh: true);
  }

  @override
  void stopMonitoring() {
    _cancelTimer();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> onAppResume() async {
    var expiry = await accessTokenExpiryStore.getExpiry();
    if (expiry == null) return;

    var dueAt = expiry.subtract(leadTime);
    if (systemClockService.now().isBefore(dueAt)) {
      await startMonitoring();
      return;
    }

    var newAccessToken = await refreshOrHandleFailure();
    if (newAccessToken == null) return;

    // Rearm from whatever expiry the refresh just persisted. Disallow a
    // further immediate refresh here (see [_armFrom]) so a pathological
    // server config (`expiresIn` <= the lead time) can't turn one resume
    // into an unbounded refresh loop; a sane config always yields a
    // positive delay at this point.
    var newExpiry = await accessTokenExpiryStore.getExpiry();
    if (newExpiry != null) {
      _cancelTimer();
      await _armFrom(newExpiry, allowImmediateRefresh: false);
    }
  }

  @override
  Future<String?> refreshOrHandleFailure() async {
    var newAccessToken = await tokenRefresher.refreshAndGetAccessToken();
    if (newAccessToken == null) {
      await _clearSessionAndReportLoss();
      return null;
    }
    return newAccessToken;
  }

  /// Schedules the proactive-refresh timer for [expiry], or — if already
  /// within the lead window and [allowImmediateRefresh] is true — refreshes
  /// right away once and then re-arms from the freshly persisted expiry
  /// with `allowImmediateRefresh: false`.
  ///
  /// That `false` follow-up call is the loop breaker: it can schedule a
  /// real future timer (the common case, since a sane `expiresIn` is always
  /// bigger than [leadTime]) but will never itself trigger another
  /// immediate refresh, capping any single [startMonitoring] /
  /// [onAppResume] call to at most one unscheduled, right-now refresh.
  Future<void> _armFrom(
    DateTime expiry, {
    required bool allowImmediateRefresh,
  }) async {
    var delay = expiry.difference(systemClockService.now()) - leadTime;
    if (!delay.isNegative) {
      _timer = Timer(delay, () {
        unawaited(_onProactiveTimerFired());
      });
      return;
    }

    if (!allowImmediateRefresh) {
      // Give up auto-rearming for now; the next external trigger (app
      // resume, a 401, or the next explicit startMonitoring() call) will
      // retry instead of refreshing in a tight loop.
      return;
    }

    var newAccessToken = await refreshOrHandleFailure();
    if (newAccessToken == null) return; // already cleared + reported.

    var newExpiry = await accessTokenExpiryStore.getExpiry();
    if (newExpiry != null) {
      await _armFrom(newExpiry, allowImmediateRefresh: false);
    }
  }

  Future<void> _onProactiveTimerFired() async {
    var newAccessToken = await refreshOrHandleFailure();
    if (newAccessToken == null) return; // already cleared + reported.

    var newExpiry = await accessTokenExpiryStore.getExpiry();
    if (newExpiry != null) {
      await _armFrom(newExpiry, allowImmediateRefresh: false);
    }
  }

  Future<void> _clearSessionAndReportLoss() async {
    _cancelTimer();
    await apiConnectorService.deleteJwt();
    await secureRefreshTokenStorage.deleteRefreshToken();
    await accessTokenExpiryStore.clearExpiry();
    onSessionLost();
  }
}

class MockSessionRefreshCoordinator extends ISessionRefreshCoordinator {
  MockSessionRefreshCoordinator({this.refreshResultOverride})
      : super(isMock: true);

  final String? refreshResultOverride;

  int startMonitoringCallCount = 0;
  int stopMonitoringCallCount = 0;
  int onAppResumeCallCount = 0;
  int refreshOrHandleFailureCallCount = 0;

  @override
  Future<void> startMonitoring() async {
    startMonitoringCallCount++;
  }

  @override
  void stopMonitoring() {
    stopMonitoringCallCount++;
  }

  @override
  Future<void> onAppResume() async {
    onAppResumeCallCount++;
  }

  @override
  Future<String?> refreshOrHandleFailure() async {
    refreshOrHandleFailureCallCount++;
    return refreshResultOverride;
  }
}
