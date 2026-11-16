import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/signinbuttons/button_view.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/screens/preauthorized/forgot_password_screen.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/services/onboarding_intent_store.dart';

import 'auth_test_harness.dart';

const _forgotPasswordStubText = 'forgot-password-stub';

/// Opens the login screen the way the welcome screen does: as a pushed route
/// carrying the picked [OnboardingIntent].
Widget _hostPushingLogin(OnboardingIntent intent) {
  return Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
              settings: RouteSettings(
                name: LoginScreen.route,
                arguments: intent,
              ),
            ),
          ),
          child: const Text('open login'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('the button says "Anmelden" and the Google button is hidden', (
    tester,
  ) async {
    await pumpAuthScreen(tester, home: const LoginScreen());

    expect(kGoogleSignInEnabled, isFalse);
    expect(S.current.login, 'Anmelden');
    expect(find.text('Anmelden'), findsOneWidget);
    expect(find.byType(SignInButton), findsNothing);
    expect(find.text(S.current.signInWithGoogle), findsNothing);
    // Apple sign-in stays.
    expect(find.text(S.current.signInWithApple), findsOneWidget);
    expect(find.text(S.current.forgotPasswordLink), findsOneWidget);
    // Reached straight from the app start there is nothing to go back to.
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('coming from "join" it says that the code comes next', (
    tester,
  ) async {
    await pumpAuthScreen(
      tester,
      home: _hostPushingLogin(OnboardingIntent.join),
    );
    await tester.tap(find.text('open login'));
    await tester.pumpAndSettle();

    expect(find.text(S.current.loginIntroJoin), findsOneWidget);
    expect(find.text(S.current.loginIntroLead), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('coming from "lead" it says that the campaign comes next', (
    tester,
  ) async {
    await pumpAuthScreen(
      tester,
      home: _hostPushingLogin(OnboardingIntent.lead),
    );
    await tester.tap(find.text('open login'));
    await tester.pumpAndSettle();

    expect(find.text(S.current.loginIntroLead), findsOneWidget);
    expect(find.text(S.current.loginIntroJoin), findsNothing);
  });

  testWidgets('empty fields say what is missing instead of doing nothing', (
    tester,
  ) async {
    final auth = buildMockAuthenticationService();
    await pumpAuthScreen(
      tester,
      home: const LoginScreen(),
      authenticationService: auth,
    );

    await scrollToAndTap(tester, find.byKey(const ValueKey('login-submit')));

    expect(find.text(S.current.loginMissingInput), findsOneWidget);
    expect(auth.loginCalls, isEmpty);
  });

  testWidgets('a wrong password shows a friendly message, not the error page', (
    tester,
  ) async {
    final auth = buildMockAuthenticationService(
      loginResult: HRResponse.error<bool>(
        'Could not login with username and password.',
        'test',
        statusCode: 401,
      ),
    );
    await pumpAuthScreen(
      tester,
      home: const LoginScreen(),
      authenticationService: auth,
    );

    await tester.enterText(textFieldLabelled(S.current.username), 'Frodo ');
    await tester.enterText(textFieldLabelled(S.current.password), 'wrong');
    await scrollToAndTap(tester, find.byKey(const ValueKey('login-submit')));

    expect(auth.loginCalls.single, (username: 'Frodo', password: 'wrong'));
    expect(find.text(S.current.loginWrongCredentials), findsOneWidget);
    expect(find.text(S.current.genericErrorModalHeader), findsNothing);
  });

  testWidgets('"Passwort vergessen?" opens the reset with the typed username', (
    tester,
  ) async {
    final pushedRoutes = <RouteSettings>[];
    await pumpAuthScreen(
      tester,
      home: const LoginScreen(),
      pushedRoutes: pushedRoutes,
      stubRoutes: {
        ForgotPasswordScreen.route: (_) =>
            const Scaffold(body: Text(_forgotPasswordStubText)),
      },
    );

    await tester.enterText(textFieldLabelled(S.current.username), 'Frodo');
    await scrollToAndTap(
      tester,
      find.byKey(const ValueKey('login-forgot-password')),
    );

    expect(find.text(_forgotPasswordStubText), findsOneWidget);
    expect(pushedRoutes.single.name, ForgotPasswordScreen.route);
    expect(pushedRoutes.single.arguments, 'Frodo');
  });
}
