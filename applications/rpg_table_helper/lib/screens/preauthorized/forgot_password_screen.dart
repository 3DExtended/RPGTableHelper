import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/validation_helpers.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/screens/preauthorized/auth_form_widgets.dart';
import 'package:quest_keeper/services/auth/authentication_service.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

enum _ResetStep { request, reset, done }

/// Lets a user with a password account set a new password:
/// username and email, then the code from the email plus a new password.
///
/// Pops with the username once the password is changed, so the login screen
/// can fill it in.
class ForgotPasswordScreen extends StatefulWidget {
  static const route = 'forgot-password';

  const ForgotPasswordScreen({super.key, this.initialUsername});

  /// Prefills the username, e.g. with what was typed on the login screen.
  final String? initialUsername;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final usernameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final resetCodeTextEditingController = TextEditingController();
  final newPasswordTextEditingController = TextEditingController();

  var step = _ResetStep.request;
  var isSubmitting = false;

  /// Set once the user tried to continue with incomplete input; from then on
  /// the field errors follow the input live.
  var showFieldErrors = false;

  /// Friendly message for a request the server turned down.
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    usernameTextEditingController.text = widget.initialUsername?.trim() ?? '';
    for (final controller in _controllers) {
      controller.addListener(_onInputChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onInputChanged);
      controller.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> get _controllers => [
    usernameTextEditingController,
    emailTextEditingController,
    resetCodeTextEditingController,
    newPasswordTextEditingController,
  ];

  void _onInputChanged() {
    if (!mounted) return;
    setState(() {});
  }

  String get _username => usernameTextEditingController.text.trim();
  String get _email => emailTextEditingController.text.trim();
  String get _resetCode => resetCodeTextEditingController.text.trim();
  String get _newPassword => newPasswordTextEditingController.text;

  bool get _newPasswordValid =>
      allPasswordRulesMet(_newPassword) && passwordValid(_newPassword);

  String _messageForFailure(HRResponseBase response, String rejectedMessage) {
    // No status code means the server did not answer at all.
    return response.statusCode == null
        ? S.of(context).authNoConnection
        : rejectedMessage;
  }

  Future<void> _requestCode() async {
    if (isSubmitting) return;
    if (!usernameValid(_username) || !emailValid(_email)) {
      setState(() => showFieldErrors = true);
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    final service = DependencyProvider.of(context)
        .getService<IAuthenticationService>();
    HRResponse<bool> result;
    try {
      result = await service.requestPasswordReset(
        username: _username,
        email: _email,
      );
    } catch (_) {
      result = HRResponse.error(
        'Could not request a password reset code.',
        'f1c3e5a7-9b2d-4f6e-8a0c-3e5d7f9b1a2c',
        statusCode: 0,
      );
    }
    if (!mounted) return;

    setState(() {
      isSubmitting = false;
      if (result.isSuccessful) {
        step = _ResetStep.reset;
        showFieldErrors = false;
        resetCodeTextEditingController.clear();
        newPasswordTextEditingController.clear();
      } else {
        errorMessage = _messageForFailure(
          result,
          S.of(context).forgotPasswordRequestFailed,
        );
      }
    });
  }

  Future<void> _resetPassword() async {
    if (isSubmitting) return;
    if (!resetCodeValid(_resetCode) || !_newPasswordValid) {
      setState(() => showFieldErrors = true);
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    final service = DependencyProvider.of(context)
        .getService<IAuthenticationService>();
    HRResponse<bool> result;
    try {
      result = await service.resetPassword(
        username: _username,
        email: _email,
        resetCode: _resetCode,
        newPassword: _newPassword,
      );
    } catch (_) {
      result = HRResponse.error(
        'Could not reset the password.',
        '2d4f6a8c-0e1b-4c3d-9f5a-7b9d1e3f5a7c',
        statusCode: 0,
      );
    }
    if (!mounted) return;

    setState(() {
      isSubmitting = false;
      if (result.isSuccessful) {
        step = _ResetStep.done;
        showFieldErrors = false;
        newPasswordTextEditingController.clear();
      } else {
        errorMessage = _messageForFailure(
          result,
          S.of(context).forgotPasswordResetFailed,
        );
      }
    });
  }

  void _backToRequestStep() {
    setState(() {
      step = _ResetStep.request;
      showFieldErrors = false;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: BackButton(color: theme.darkTextColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      S.of(context).forgotPasswordTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            color: theme.darkColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ..._buildStep(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStep(BuildContext context) {
    switch (step) {
      case _ResetStep.request:
        return _buildRequestStep(context);
      case _ResetStep.reset:
        return _buildResetStep(context);
      case _ResetStep.done:
        return _buildDoneStep(context);
    }
  }

  List<Widget> _buildRequestStep(BuildContext context) {
    return [
      _IntroText(text: S.of(context).forgotPasswordRequestIntro),
      const SizedBox(height: 16),
      CustomTextField(
        labelText: S.of(context).username,
        textEditingController: usernameTextEditingController,
        keyboardType: TextInputType.name,
        // Usernames are typed as they are.
        textCapitalization: TextCapitalization.none,
      ),
      if (showFieldErrors && !usernameValid(_username))
        AuthFieldError(message: S.of(context).registerUsernameInvalid),
      CustomTextField(
        labelText: S.of(context).email,
        textEditingController: emailTextEditingController,
        keyboardType: TextInputType.emailAddress,
      ),
      if (showFieldErrors && !emailValid(_email))
        AuthFieldError(message: S.of(context).registerEmailInvalid),
      if (errorMessage != null)
        AuthMessageBox(message: errorMessage!, isError: true),
      const SizedBox(height: 20),
      _PrimaryAction(
        isSubmitting: isSubmitting,
        label: S.of(context).forgotPasswordRequestButton,
        onPressed: _requestCode,
      ),
    ];
  }

  List<Widget> _buildResetStep(BuildContext context) {
    return [
      AuthMessageBox(message: S.of(context).forgotPasswordCodeSent(_email)),
      const SizedBox(height: 8),
      CustomTextField(
        labelText: S.of(context).resetCodeLabel,
        placeholderText: S.of(context).resetCodeHint,
        textEditingController: resetCodeTextEditingController,
        keyboardType: TextInputType.number,
      ),
      if (showFieldErrors && !resetCodeValid(_resetCode))
        AuthFieldError(message: S.of(context).resetCodeInvalid),
      CustomTextField(
        labelText: S.of(context).newPasswordLabel,
        textEditingController: newPasswordTextEditingController,
        password: true,
        keyboardType: TextInputType.visiblePassword,
      ),
      PasswordRulesChecklist(
        password: _newPassword,
        highlightUnmet: showFieldErrors,
      ),
      if (errorMessage != null)
        AuthMessageBox(message: errorMessage!, isError: true),
      const SizedBox(height: 20),
      _PrimaryAction(
        isSubmitting: isSubmitting,
        label: S.of(context).forgotPasswordSaveButton,
        onPressed: _resetPassword,
      ),
      const SizedBox(height: 12),
      Center(
        child: CustomButton(
          variant: CustomButtonVariant.FlatButton,
          label: S.of(context).forgotPasswordRequestNewCode,
          onPressed: isSubmitting ? null : _backToRequestStep,
        ),
      ),
    ];
  }

  List<Widget> _buildDoneStep(BuildContext context) {
    return [
      AuthMessageBox(message: S.of(context).forgotPasswordSuccess),
      const SizedBox(height: 20),
      _PrimaryAction(
        isSubmitting: false,
        label: S.of(context).forgotPasswordBackToLogin,
        onPressed: () => Navigator.of(context).pop(_username),
      ),
    ];
  }
}

class _IntroText extends StatelessWidget {
  const _IntroText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontFamily: 'Ruwudu',
        color: CustomThemeProvider.of(context).theme.darkTextColor,
      ),
    );
  }
}

/// The main button of a step, or a spinner while the request runs.
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.isSubmitting,
    required this.label,
    required this.onPressed,
  });

  final bool isSubmitting;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isSubmitting) {
      return const Center(child: CustomLoadingSpinner());
    }
    return Center(
      child: CustomButton(
        width: 298,
        height: 55,
        boderRadiusOverride: 7,
        variant: CustomButtonVariant.AccentButton,
        label: label,
        onPressed: onPressed,
      ),
    );
  }
}
