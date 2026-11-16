import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/screens/preauthorized/welcome_screen.dart';
import 'package:quest_keeper/services/onboarding_intent_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_test_harness.dart';

const _loginStubText = 'login-screen-stub';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<List<RouteSettings>> pumpWelcome(WidgetTester tester) async {
    final pushedRoutes = <RouteSettings>[];
    await pumpAuthScreen(
      tester,
      home: const WelcomeScreen(),
      pushedRoutes: pushedRoutes,
      stubRoutes: {
        LoginScreen.route: (_) => const Scaffold(body: Text(_loginStubText)),
      },
    );
    return pushedRoutes;
  }

  testWidgets('says what the app is and offers both ways in', (tester) async {
    await pumpWelcome(tester);

    expect(find.text('QuestKeeper'), findsOneWidget);
    expect(find.text(S.current.welcomeTagline), findsOneWidget);
    expect(find.text(S.current.welcomeDescription), findsOneWidget);
    expect(find.text(S.current.welcomeLeadButton), findsOneWidget);
    expect(find.text(S.current.welcomeJoinButton), findsOneWidget);
    // Players learn up front that they need the game master's code.
    expect(find.text(S.current.welcomeJoinHint), findsOneWidget);
  });

  testWidgets('"Ich leite eine Runde" stores the intent and opens the login', (
    tester,
  ) async {
    final pushedRoutes = await pumpWelcome(tester);

    await scrollToAndTap(tester, find.byKey(const ValueKey('welcome-lead')));

    expect(find.text(_loginStubText), findsOneWidget);
    expect(pushedRoutes.single.name, LoginScreen.route);
    expect(pushedRoutes.single.arguments, OnboardingIntent.lead);
    expect(await readOnboardingIntent(), OnboardingIntent.lead);
  });

  testWidgets(
    '"Ich trete einer Runde bei" stores the intent and opens the login',
    (tester) async {
      final pushedRoutes = await pumpWelcome(tester);

      await scrollToAndTap(tester, find.byKey(const ValueKey('welcome-join')));

      expect(find.text(_loginStubText), findsOneWidget);
      expect(pushedRoutes.single.name, LoginScreen.route);
      expect(pushedRoutes.single.arguments, OnboardingIntent.join);
      expect(await readOnboardingIntent(), OnboardingIntent.join);
    },
  );
}
