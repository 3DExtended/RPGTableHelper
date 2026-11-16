import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/constants/legal_links.dart' as legal_links;
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/validation_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/screens/preauthorized/auth_form_widgets.dart';
import 'package:quest_keeper/screens/select_game_mode_screen.dart';
import 'package:quest_keeper/services/auth/authentication_service.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const route = 'register';

  const RegisterScreen({
    super.key,
    this.privacyPolicyUrl = legal_links.privacyPolicyUrl,
  });

  /// Linked in the sentence above the register button; without one a
  /// neutral sentence without link is shown.
  final String? privacyPolicyUrl;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  var usernameTextEditingController = TextEditingController();
  var passwordTextEditingController = TextEditingController();
  var emailTextEditingController = TextEditingController();

  /// Set once the user tapped "register" with incomplete input; from then
  /// on the field errors follow the input live.
  var showFieldErrors = false;
  var isSubmitting = false;

  /// The username the server reported as taken, to show it under the field
  /// until the user changes it.
  String? takenUsername;

  late final TapGestureRecognizer _privacyPolicyRecognizer =
      TapGestureRecognizer()..onTap = _openPrivacyPolicy;

  @override
  void initState() {
    usernameTextEditingController.addListener(_updateStateForFormValidation);
    passwordTextEditingController.addListener(_updateStateForFormValidation);
    emailTextEditingController.addListener(_updateStateForFormValidation);
    super.initState();
  }

  @override
  void dispose() {
    usernameTextEditingController.removeListener(_updateStateForFormValidation);
    passwordTextEditingController.removeListener(_updateStateForFormValidation);
    emailTextEditingController.removeListener(_updateStateForFormValidation);
    _privacyPolicyRecognizer.dispose();

    super.dispose();
  }

  void _updateStateForFormValidation() {
    if (!mounted) return;
    // Rebuild so the password rules and field errors follow the input.
    setState(() {});
  }

  String get _username => usernameTextEditingController.text.trim();
  String get _email => emailTextEditingController.text.trim();
  String get _password => passwordTextEditingController.text;

  bool get _usernameValid => usernameValid(_username);
  bool get _emailValid => emailValid(_email);
  bool get _passwordValid =>
      allPasswordRulesMet(_password) && passwordValid(_password);

  Future<void> _register() async {
    if (isSubmitting) return;
    if (!_usernameValid || !_emailValid || !_passwordValid) {
      setState(() {
        showFieldErrors = true;
      });
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    var service =
        DependencyProvider.of(context).getService<IAuthenticationService>();

    var username = _username;
    var registerResponse = await service.registerWithUsernameAndPassword(
      username: username,
      password: _password,
      email: _email,
    );

    if (!mounted || !context.mounted) return;

    setState(() {
      isSubmitting = false;
    });

    // 409: the username is taken. Say so at the field instead of the
    // generic error page.
    if (!registerResponse.isSuccessful && registerResponse.statusCode == 409) {
      setState(() {
        takenUsername = username;
      });
      return;
    }

    await registerResponse.possiblyHandleError(context);

    if (registerResponse.result?.resultType ==
        SignInResultType.loginSucessfull) {
      // proceed to campagne or character selection
      navigatorKey.currentState!
          .pushNamedAndRemoveUntil(SelectGameModeScreen.route, (r) => false);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    var url = widget.privacyPolicyUrl;
    if (!legal_links.hasLegalLink(url)) return;
    await launchUrl(Uri.parse(url!.trim()),
        mode: LaunchMode.externalApplication);
  }

  Widget _buildPrivacyNotice(BuildContext context) {
    var theme = CustomThemeProvider.of(context).theme;
    var style = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontFamily: 'Ruwudu',
          color: theme.darkTextColor.withValues(alpha: 0.85),
        );

    if (!legal_links.hasLegalLink(widget.privacyPolicyUrl)) {
      return Text(
        S.of(context).registerPrivacyNoticeWithoutLink,
        style: style,
      );
    }

    // Split the translated sentence around the link so translations can
    // place it wherever their grammar needs it.
    const linkMarker = '\u{E000}';
    var parts = S.of(context).registerPrivacyNotice(linkMarker).split(linkMarker);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: S.of(context).privacyPolicyLinkLabel,
            style: style.copyWith(
              color: theme.darkTextColor,
              decoration: TextDecoration.underline,
              decorationColor: theme.darkTextColor,
            ),
            recognizer: _privacyPolicyRecognizer,
          ),
          if (parts.length > 1) TextSpan(text: parts.skip(1).join()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CustomThemeProvider.of(context).theme.bgColor,
      body: Container(
        decoration: BoxDecoration(
          color: CustomThemeProvider.of(context).theme.bgColor,
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: SingleChildScrollView(
              child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      S.of(context).register,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                            color:
                                CustomThemeProvider.of(context).theme.darkColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    // REGISTER
                    // Username Textfield
                    CustomTextField(
                      labelText: S.of(context).username,
                      placeholderText: S.of(context).usernameRuleHint,
                      textEditingController: usernameTextEditingController,
                      keyboardType: TextInputType.name,
                    ),
                    if (showFieldErrors && !_usernameValid)
                      AuthFieldError(
                          message: S.of(context).registerUsernameInvalid)
                    else if (takenUsername != null &&
                        takenUsername == _username)
                      AuthFieldError(
                          message: S.of(context).registerUsernameTaken),

                    // email Textfield
                    CustomTextField(
                      labelText: S.of(context).email,
                      textEditingController: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (showFieldErrors && !_emailValid)
                      AuthFieldError(
                          message: S.of(context).registerEmailInvalid),

                    // password
                    CustomTextField(
                      labelText: S.of(context).password,
                      textEditingController: passwordTextEditingController,
                      password: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    PasswordRulesChecklist(
                      password: _password,
                      highlightUnmet: showFieldErrors,
                    ),
                    if (showFieldErrors && !_passwordValid)
                      AuthFieldError(
                          message: S.of(context).registerPasswordInvalid),
                    SizedBox(
                      height: 24,
                    ),
                    _buildPrivacyNotice(context),
                    SizedBox(
                      height: 24,
                    ),
                    // register button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          variant: CustomButtonVariant.DarkButton,
                          onPressed: () {
                            navigatorKey.currentState!.pop();
                          },
                          label: S.of(context).cancel,
                        ),
                        CustomButton(
                          key: const ValueKey('register-submit'),
                          variant: CustomButtonVariant.AccentButton,
                          // Stays tappable: an incomplete form shows what is
                          // missing instead of a silently disabled button.
                          onPressed: isSubmitting ? null : _register,
                          label: S.of(context).register,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }
}
