import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/screens/preauthorized/session_restorer_screen.dart';
import 'package:quest_keeper/screens/select_game_mode_screen.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/auth/session_restorer.dart';
import 'package:quest_keeper/services/auth/token_refresher.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// Minimal route stubs so navigation assertions do not depend on the real
/// `LoginScreen`/`SelectGameModeScreen` widgets (and their Riverpod
/// providers/localization setup).
const _loginStubText = 'login-screen-stub';
const _selectGameModeStubText = 'select-game-mode-stub';

Widget _appUnderTest() {
  return MaterialApp(
    initialRoute: SessionRestorerScreen.route,
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case SessionRestorerScreen.route:
          return MaterialPageRoute(
            builder: (_) => const SessionRestorerScreen(),
            settings: settings,
          );
        case LoginScreen.route:
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text(_loginStubText)),
            settings: settings,
          );
        case SelectGameModeScreen.route:
          return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Text(_selectGameModeStubText)),
            settings: settings,
          );
      }
      return null;
    },
  );
}

void main() {
  group('SessionRestorerScreen', () {
    testWidgets('shows a loading indicator before the restore attempt settles',
        (tester) async {
      // arrange
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<ISessionRestorer>(MockSessionRestorer());

      // act
      await tester.pumpWidget(_appUnderTest());
      await tester.pump();

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('navigates to SelectGameMode when restore succeeds',
        (tester) async {
      // arrange
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<ISessionRestorer>(
          MockSessionRestorer(
            restoreResultOverride: SessionRestoreResult.restored,
          ),
        );

      // act
      await tester.pumpWidget(_appUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.text(_selectGameModeStubText), findsOneWidget);
      expect(find.text(_loginStubText), findsNothing);
    });

    testWidgets(
        'navigates to Login when there is no refresh token to restore from',
        (tester) async {
      // arrange
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<ISessionRestorer>(
          MockSessionRestorer(
            restoreResultOverride: SessionRestoreResult.needsLogin,
          ),
        );

      // act
      await tester.pumpWidget(_appUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.text(_loginStubText), findsOneWidget);
      expect(find.text(_selectGameModeStubText), findsNothing);
    });

    testWidgets(
        'navigates to Login when a refresh token exists but the refresh fails (end-to-end through the real SessionRestorer)',
        (tester) async {
      // arrange: a real SessionRestorer wired to a stored refresh token that
      // fails to exchange (expired/revoked/unreachable API) — distinguishes
      // this path from the "no refresh token at all" case above.
      var secureRefreshTokenStorage = MockSecureRefreshTokenStorage(
        refreshTokenOverride: 'a-dead-refresh-token',
      );
      var tokenRefresher = MockTokenRefresher(refreshResultOverride: false);
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<ISessionRestorer>(SessionRestorer(
          secureRefreshTokenStorage: secureRefreshTokenStorage,
          tokenRefresher: tokenRefresher,
        ));

      // act
      await tester.pumpWidget(_appUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(tokenRefresher.refreshCallCount, 1);
      expect(find.text(_loginStubText), findsOneWidget);
      expect(find.text(_selectGameModeStubText), findsNothing);
    });
  });
}
