import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/screens/preauthorized/forgot_password_screen.dart';
import 'package:quest_keeper/services/auth/authentication_service.dart';

import 'auth_test_harness.dart';

/// Opens the reset screen like the login screen does and keeps what it pops
/// with (the username after a successful reset).
class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  Object? poppedWith = 'not popped';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const ForgotPasswordScreen(initialUsername: 'Frodo'),
              ),
            );
            setState(() => poppedWith = result);
          },
          child: Text('popped: $poppedWith'),
        ),
      ),
    );
  }
}

Future<void> _openResetScreen(
  WidgetTester tester,
  IAuthenticationService auth,
) async {
  await pumpAuthScreen(
    tester,
    home: const _Host(),
    authenticationService: auth,
  );
  await tester.tap(find.text('popped: not popped'));
  await tester.pumpAndSettle();
}

Future<void> _requestCode(WidgetTester tester) async {
  await tester.enterText(
    textFieldLabelled(S.current.email),
    ' frodo@shire.me ',
  );
  await scrollToAndTap(
    tester,
    find.text(S.current.forgotPasswordRequestButton),
  );
}

Future<void> _submitNewPassword(WidgetTester tester) async {
  await tester.enterText(
    textFieldLabelled(S.current.resetCodeLabel),
    '123-456',
  );
  await tester.enterText(
    textFieldLabelled(S.current.newPasswordLabel),
    'mellon-friend',
  );
  await scrollToAndTap(tester, find.text(S.current.forgotPasswordSaveButton));
}

void main() {
  testWidgets('code, new password, success, back to the login with username', (
    tester,
  ) async {
    final auth = buildMockAuthenticationService();
    await _openResetScreen(tester, auth);

    expect(find.text(S.current.forgotPasswordTitle), findsOneWidget);
    await _requestCode(tester);

    expect(auth.requestPasswordResetCalls.single, (
      username: 'Frodo',
      email: 'frodo@shire.me',
    ));
    expect(
      find.text(S.current.forgotPasswordCodeSent('frodo@shire.me')),
      findsOneWidget,
    );
    // The new password gets the same visible rules as at registration.
    expect(find.text(S.current.passwordRulesTitle), findsOneWidget);

    await _submitNewPassword(tester);

    expect(auth.resetPasswordCalls.single, (
      username: 'Frodo',
      email: 'frodo@shire.me',
      resetCode: '123-456',
      newPassword: 'mellon-friend',
    ));
    expect(find.text(S.current.forgotPasswordSuccess), findsOneWidget);

    await scrollToAndTap(
      tester,
      find.text(S.current.forgotPasswordBackToLogin),
    );

    expect(find.text('popped: Frodo'), findsOneWidget);
  });

  testWidgets('incomplete input is named and nothing is sent', (tester) async {
    final auth = buildMockAuthenticationService();
    await _openResetScreen(tester, auth);

    await scrollToAndTap(
      tester,
      find.text(S.current.forgotPasswordRequestButton),
    );

    expect(find.text(S.current.registerEmailInvalid), findsOneWidget);
    expect(auth.requestPasswordResetCalls, isEmpty);
  });

  testWidgets('a short new password is not sent', (tester) async {
    final auth = buildMockAuthenticationService();
    await _openResetScreen(tester, auth);
    await _requestCode(tester);

    await tester.enterText(
      textFieldLabelled(S.current.resetCodeLabel),
      '123-456',
    );
    await tester.enterText(
      textFieldLabelled(S.current.newPasswordLabel),
      'short',
    );
    await scrollToAndTap(tester, find.text(S.current.forgotPasswordSaveButton));

    expect(auth.resetPasswordCalls, isEmpty);
    expect(find.text(S.current.forgotPasswordSuccess), findsNothing);
  });

  testWidgets('a rejected code request gets a friendly message', (
    tester,
  ) async {
    final auth = buildMockAuthenticationService(
      requestPasswordResetResult: HRResponse.error<bool>(
        'Could not request a password reset code.',
        'test',
        statusCode: 400,
      ),
    );
    await _openResetScreen(tester, auth);

    await _requestCode(tester);

    expect(find.text(S.current.forgotPasswordRequestFailed), findsOneWidget);
    expect(find.text(S.current.genericErrorModalHeader), findsNothing);
    // Still on the first step, so the user can correct the input.
    expect(find.text(S.current.forgotPasswordRequestButton), findsOneWidget);
  });

  testWidgets('a wrong or expired code gets a friendly message', (
    tester,
  ) async {
    final auth = buildMockAuthenticationService(
      resetPasswordResult: HRResponse.error<bool>(
        'Could not reset the password.',
        'test',
        statusCode: 400,
      ),
    );
    await _openResetScreen(tester, auth);
    await _requestCode(tester);

    await _submitNewPassword(tester);

    expect(find.text(S.current.forgotPasswordResetFailed), findsOneWidget);
    expect(find.text(S.current.genericErrorModalHeader), findsNothing);
    expect(find.text(S.current.forgotPasswordSuccess), findsNothing);
    expect(find.text(S.current.forgotPasswordRequestNewCode), findsOneWidget);
  });

  testWidgets('an unreachable server is told apart from a rejected request', (
    tester,
  ) async {
    final auth = buildMockAuthenticationService(
      requestPasswordResetResult: HRResponse.error<bool>(
        'Could not load apiConnectorClient',
        'test',
      ),
    );
    await _openResetScreen(tester, auth);

    await _requestCode(tester);

    expect(find.text(S.current.authNoConnection), findsOneWidget);
  });
}
