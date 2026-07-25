import 'package:flutter/material.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/screens/select_game_mode_screen.dart';
import 'package:quest_keeper/services/auth/session_restorer.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

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

    Navigator.of(context).pushReplacementNamed(
      result == SessionRestoreResult.restored
          ? SelectGameModeScreen.route
          : LoginScreen.route,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
