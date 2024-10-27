import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/fill_remaining_space.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/bg.png",
            fit: BoxFit.fill,
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(79, 0, 0, 0),
            child: AnimatedPadding(
              duration: Durations.short3,
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).viewInsets.bottom > 0.0
                    ? 30
                    : MediaQuery.of(context).size.height / 7.0,
                horizontal: MediaQuery.of(context).size.width / 5.0,
              ),
              child: StyledBox(
                overrideInnerDecoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                      "assets/images/bg.png",
                    ),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Container(
                  color: const Color.fromARGB(34, 67, 67, 67),
                  child: SingleChildScrollView(
                      child: FillRemainingSpace(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            "Registrieren", // TODO localize
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          HorizontalLine(),
                          SizedBox(
                            height: 10,
                          ),
                          // REGISTER
                          // Username Textfield
                          CustomTextField(
                            labelText: "Username", // TODO Localize
                            textEditingController:
                                usernameTextEditingController,
                            keyboardType: TextInputType.name,
                          ),

                          // email Textfield
                          CustomTextField(
                            labelText: "Email", // TODO Localize
                            textEditingController: emailTextEditingController,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          // password
                          CustomTextField(
                            labelText: "Password", // TODO Localize
                            textEditingController:
                                passwordTextEditingController,
                            password: true,
                            keyboardType: TextInputType.visiblePassword,
                          ),

                          // register button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: CustomButton(
                                  onPressed: () {
                                    navigatorKey.currentState!.pop();
                                  },
                                  label: "Abbrechen",
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: CustomButton(
                                  onPressed: isRegisterButtonDisabled
                                      ? null
                                      : () async {
                                          // TODO perform register
                                          var service =
                                              DependencyProvider.of(context)
                                                  .getService<
                                                      IAuthenticationService>();

                                          var registerResponse = await service
                                              .registerWithUsernameAndPassword(
                                            username:
                                                usernameTextEditingController
                                                    .text,
                                            password:
                                                passwordTextEditingController
                                                    .text,
                                            email:
                                                emailTextEditingController.text,
                                          );

                                          if (!mounted) return;

                                          await registerResponse
                                              .possiblyHandleError(context);

                                          if (registerResponse
                                                  .result?.resultType ==
                                              SignInResultType
                                                  .loginSucessfull) {
                                            // proceed to campagne or character selection
                                            navigatorKey.currentState!
                                                .pushNamedAndRemoveUntil(
                                                    SelectGameModeScreen.route,
                                                    (r) => false);
                                          } else {
                                            // TODO mark password and username fields as invalid
                                          }
                                        },
                                  label: "Register",
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
