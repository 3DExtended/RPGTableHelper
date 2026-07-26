import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/screens/select_game_mode_screen.dart';
import 'package:quest_keeper/services/auth/session_refresh_coordinator.dart';
import 'package:quest_keeper/services/auth/session_restorer.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/snack_bar_service.dart';

/// Cold-start gate shown before the user ever sees `LoginScreen` or
/// `SelectGameModeScreen`.
///
/// Briefly shows a loading indicator while [ISessionRestorer] checks for a
/// stored refresh token and, if present, exchanges it for a fresh token
/// pair. Lands on [SelectGameModeScreen] only on a successful restore;
/// everything else (no refresh token — e.g. an upgrade from an older,
/// JWT-only install — an expired/revoked refresh token, or an unreachable
/// API) falls back to [LoginScreen]. The cached access JWT alone is never
/// trusted to enter the app.
class SessionRestorerScreen extends StatefulWidget {
  static const route = 'session-restorer';

  const SessionRestorerScreen({super.key});

  @override
  State<SessionRestorerScreen> createState() => _SessionRestorerScreenState();
}

class _SessionRestorerScreenState extends State<SessionRestorerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreAndNavigate());
  }

  Future<void> _restoreAndNavigate() async {
    var sessionRestorer = DependencyProvider.getIt!.get<ISessionRestorer>();
    var result = await sessionRestorer.restore();

    if (!mounted) return;

    if (result == SessionRestoreResult.sessionExpired) {
      _showSessionExpiredMessageIfPossible();
    }

    if (result == SessionRestoreResult.restored) {
      // auth-04: arm the proactive-refresh timer as soon as the session is
      // active again, so a long-lived cold start doesn't wait for a 401 to
      // notice the access token needs refreshing.
      _startSessionMonitoringIfPossible();
    }

    Navigator.of(context).pushReplacementNamed(
      result == SessionRestoreResult.restored
          ? SelectGameModeScreen.route
          : LoginScreen.route,
    );
  }

  /// Best-effort, same reasoning as [_showSessionExpiredMessageIfPossible]:
  /// some widget tests register only [ISessionRestorer] directly on a raw
  /// `GetIt` instance rather than going through the full
  /// `DependencyProvider`.
  void _startSessionMonitoringIfPossible() {
    var getIt = DependencyProvider.getIt;
    if (getIt == null || !getIt.isRegistered<ISessionRefreshCoordinator>()) {
      return;
    }
    unawaited(getIt.get<ISessionRefreshCoordinator>().startMonitoring());
  }

  /// Best-effort: some widget tests don't register [ISnackBarService], and
  /// the message is a nice-to-have, not something worth failing navigation
  /// over.
  void _showSessionExpiredMessageIfPossible() {
    var getIt = DependencyProvider.getIt;
    if (getIt == null || !getIt.isRegistered<ISnackBarService>()) return;

    getIt.get<ISnackBarService>().showSnackBar(
          snack: SnackBar(content: Text(AppLocalizations.of(context)!.sessionExpiredMessage)),
          uniqueId: 'session-expired',
        );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
