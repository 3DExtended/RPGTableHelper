import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/validation_helpers.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/screens/preauthorized/auth_form_widgets.dart';
import 'package:quest_keeper/screens/preauthorized/register_screen.dart';
import 'package:quest_keeper/services/auth/authentication_service.dart';

import 'auth_test_harness.dart';

bool _ruleShownAsMet(WidgetTester tester, PasswordRule rule) => tester
    .widget<PasswordRuleRow>(find.byKey(ValueKey('passwordRule-${rule.name}')))
    .met;

void main() {
  test(
    'the shown password rules are exactly the rules registration checks',
    () {
      // The server only sees a hash, so passwordValid is the only check there
      // is. The checklist must not promise more or less than it.
      for (var length = 0; length <= 60; length++) {
        final password = 'x' * length;
        expect(
          allPasswordRulesMet(password),
          passwordValid(password),
          reason: 'password of length $length',
        );
      }
    },
  );

  testWidgets('the password rules are listed and ticked off while typing', (
    tester,
  ) async {
    await pumpAuthScreen(tester, home: const RegisterScreen());

    expect(find.text(S.current.passwordRulesTitle), findsOneWidget);
    expect(
      find.text(S.current.passwordRuleMinLength(passwordMinLength)),
      findsOneWidget,
    );
    expect(
      find.text(S.current.passwordRuleMaxLength(passwordMaxLength)),
      findsOneWidget,
    );
    expect(_ruleShownAsMet(tester, PasswordRule.minLength), isFalse);
    expect(_ruleShownAsMet(tester, PasswordRule.maxLength), isTrue);

    final passwordField = textFieldLabelled(S.current.password);
    await tester.enterText(passwordField, 'abc');
    await tester.pump();
    expect(_ruleShownAsMet(tester, PasswordRule.minLength), isFalse);

    await tester.enterText(passwordField, 'abcdefgh');
    await tester.pump();
    expect(_ruleShownAsMet(tester, PasswordRule.minLength), isTrue);
    expect(_ruleShownAsMet(tester, PasswordRule.maxLength), isTrue);

    await tester.enterText(passwordField, 'a' * 42);
    await tester.pump();
    expect(_ruleShownAsMet(tester, PasswordRule.minLength), isTrue);
    expect(_ruleShownAsMet(tester, PasswordRule.maxLength), isFalse);
  });

  testWidgets('the username rule is visible under the field', (tester) async {
    await pumpAuthScreen(tester, home: const RegisterScreen());

    expect(find.text(S.current.usernameRuleHint), findsOneWidget);
  });

  testWidgets(
    'tapping "Registrieren" on an incomplete form says what is missing',
    (tester) async {
      final auth = buildMockAuthenticationService();
      await pumpAuthScreen(
        tester,
        home: const RegisterScreen(),
        authenticationService: auth,
      );

      await tester.enterText(textFieldLabelled(S.current.password), 'abc');
      await scrollToAndTap(
        tester,
        find.byKey(const ValueKey('register-submit')),
      );

      expect(find.text(S.current.registerUsernameInvalid), findsOneWidget);
      expect(find.text(S.current.registerEmailInvalid), findsOneWidget);
      expect(find.text(S.current.registerPasswordInvalid), findsOneWidget);
      expect(auth.registerCalls, isEmpty);

      // The errors follow the input from now on.
      await tester.enterText(textFieldLabelled(S.current.username), 'Frodo');
      await tester.pump();
      expect(find.text(S.current.registerUsernameInvalid), findsNothing);
    },
  );

  testWidgets('a taken username is named at the field', (tester) async {
    final auth = buildMockAuthenticationService(
      registerResult: HRResponse.error<SignInResult>(
        'Could not register new user on server',
        'test',
        statusCode: 409,
      ),
    );
    await pumpAuthScreen(
      tester,
      home: const RegisterScreen(),
      authenticationService: auth,
    );

    await tester.enterText(textFieldLabelled(S.current.username), 'Frodo');
    await tester.enterText(
      textFieldLabelled(S.current.email),
      'frodo@shire.me',
    );
    await tester.enterText(
      textFieldLabelled(S.current.password),
      'mellon-friend',
    );
    await scrollToAndTap(tester, find.byKey(const ValueKey('register-submit')));

    expect(auth.registerCalls.single, (
      username: 'Frodo',
      email: 'frodo@shire.me',
      password: 'mellon-friend',
    ));
    expect(find.text(S.current.registerUsernameTaken), findsOneWidget);
    expect(find.text(S.current.genericErrorModalHeader), findsNothing);
  });

  testWidgets('without a privacy policy URL a neutral sentence is shown', (
    tester,
  ) async {
    // The app has no privacy policy URL yet, so this is the default.
    await pumpAuthScreen(tester, home: const RegisterScreen());

    expect(
      find.text(S.current.registerPrivacyNoticeWithoutLink),
      findsOneWidget,
    );
    expect(find.textContaining(S.current.privacyPolicyLinkLabel), findsNothing);
  });

  testWidgets('with a privacy policy URL the sentence links to it', (
    tester,
  ) async {
    await pumpAuthScreen(
      tester,
      home: const RegisterScreen(
        privacyPolicyUrl: 'https://example.org/datenschutz',
      ),
    );

    expect(
      find.textContaining(S.current.privacyPolicyLinkLabel),
      findsOneWidget,
    );
    expect(find.text(S.current.registerPrivacyNoticeWithoutLink), findsNothing);
  });
}
