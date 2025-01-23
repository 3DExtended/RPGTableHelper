import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/l10n.dart';
import 'package:rpg_table_helper/helpers/validation_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/screens/select_game_mode_screen.dart';
import 'package:rpg_table_helper/services/auth/authentication_service.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const route = 'register';

  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  var usernameTextEditingController = TextEditingController();
  var passwordTextEditingController = TextEditingController();
  var emailTextEditingController = TextEditingController();

  var isRegisterButtonDisabled = true;

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

    super.dispose();
  }

  void _updateStateForFormValidation() {
    var newIsStartBtnInvalid = getIsRegisterButtonDisabled();

    setState(() {
      isRegisterButtonDisabled = newIsStartBtnInvalid;
    });
  }

  bool getIsRegisterButtonDisabled() {
    if (usernameTextEditingController.text.isEmpty ||
        usernameTextEditingController.text.length < 3) {
      return true;
    }
    if (emailTextEditingController.text.isEmpty ||
        emailTextEditingController.text.length < 3) {
      return true;
    }
    if (passwordTextEditingController.text.isEmpty ||
        passwordTextEditingController.text.length < 3) {
      return true;
    }

    if (!emailValid(emailTextEditingController.text)) {
      return true;
    }
    if (!usernameValid(usernameTextEditingController.text)) {
      return true;
    }
    if (!passwordValid(passwordTextEditingController.text)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          color: bgColor,
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
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: darkColor,
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
                      textEditingController: usernameTextEditingController,
                      keyboardType: TextInputType.name,
                    ),

                    // email Textfield
                    CustomTextField(
                      labelText: S.of(context).email,
                      textEditingController: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    // password
                    CustomTextField(
                      labelText: S.of(context).password,
                      textEditingController: passwordTextEditingController,
                      password: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(
                      height: 40,
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
                          variant: CustomButtonVariant.AccentButton,
                          onPressed: isRegisterButtonDisabled
                              ? null
                              : () async {
                                  // TODO perform register
                                  var service = DependencyProvider.of(context)
                                      .getService<IAuthenticationService>();

                                  var registerResponse = await service
                                      .registerWithUsernameAndPassword(
                                    username:
                                        usernameTextEditingController.text,
                                    password:
                                        passwordTextEditingController.text,
                                    email: emailTextEditingController.text,
                                  );

                                  if (!mounted || !context.mounted) return;

                                  await registerResponse
                                      .possiblyHandleError(context);

                                  if (registerResponse.result?.resultType ==
                                      SignInResultType.loginSucessfull) {
                                    // proceed to campagne or character selection
                                    navigatorKey.currentState!
                                        .pushNamedAndRemoveUntil(
                                            SelectGameModeScreen.route,
                                            (r) => false);
                                  } else {
                                    // TODO mark password and username fields as invalid
                                  }
                                },
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
