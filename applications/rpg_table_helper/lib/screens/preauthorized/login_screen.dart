import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/fill_remaining_space.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/signinbuttons/button_list.dart';
import 'package:rpg_table_helper/components/signinbuttons/button_view.dart';
import 'package:rpg_table_helper/components/signinbuttons/custom_sign_in_with_apple.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/helpers/validation_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/screens/preauthorized/register_screen.dart';
import 'package:rpg_table_helper/services/auth/authentication_service.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const route = 'login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  var usernameTextEditingController = TextEditingController();
  var passwordTextEditingController = TextEditingController();

  var isLoginButtonDisabled = true;

  @override
  void initState() {
    usernameTextEditingController.addListener(_updateStateForFormValidation);
    passwordTextEditingController.addListener(_updateStateForFormValidation);
    super.initState();
  }

  @override
  void dispose() {
    usernameTextEditingController.removeListener(_updateStateForFormValidation);
    passwordTextEditingController.removeListener(_updateStateForFormValidation);

    super.dispose();
  }

  void _updateStateForFormValidation() {
    var newIsStartBtnInvalid = getIsLoginButtonDisabled();

    setState(() {
      isLoginButtonDisabled = newIsStartBtnInvalid;
    });
  }

  bool getIsLoginButtonDisabled() {
    if (usernameTextEditingController.text.isEmpty ||
        usernameTextEditingController.text.length < 3) {
      return true;
    }
    if (passwordTextEditingController.text.isEmpty ||
        passwordTextEditingController.text.length < 3) {
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
                            "Login", // TODO localize
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
                          // LOGIN
                          // Username Textfield
                          CustomTextField(
                            labelText: "Username", // TODO Localize
                            textEditingController:
                                usernameTextEditingController,
                            keyboardType: TextInputType.name,
                          ),

                          // password Textfield
                          CustomTextField(
                            labelText: "Password", // TODO Localize
                            textEditingController:
                                passwordTextEditingController,
                            password: true,
                            keyboardType: TextInputType.visiblePassword,
                          ),
                          // login button
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: CustomButton(
                                onPressed: isLoginButtonDisabled
                                    ? null
                                    : () async {
                                        // TODO perform login
                                        var service =
                                            DependencyProvider.of(context)
                                                .getService<
                                                    IAuthenticationService>();

                                        var signinResponse = await service
                                            .loginWithUsernameAndPassword(
                                                username:
                                                    usernameTextEditingController
                                                        .text,
                                                password:
                                                    passwordTextEditingController
                                                        .text);
                                        if (!mounted) return;

                                        await signinResponse
                                            .possiblyHandleError(context);

                                        if (signinResponse.result == true) {
                                          // TODO proceed to campagne or character selection
                                        } else {
                                          // TODO mark password and username fields as invalid
                                        }
                                      },
                                label: "Login", // TODO localize
                              ),
                            ),
                          ),

                          // Wrap if screen to small:
                          // signin with apple button

                          // signin with apple google

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // apple sign in button
                              Expanded(
                                flex: 4,
                                child: CustomSignInWithAppleButton(
                                  style: CustomSignInWithAppleButtonStyle.white,
                                  text: "Mit Apple anmelden",
                                  height: 55,
                                  onPressed: () async {
                                    AuthorizationCredentialAppleID? credential;
                                    try {
                                      credential = await SignInWithApple
                                          .getAppleIDCredential(
                                        // nonce: DateTime.now().toUtc().microsecondsSinceEpoch.toString(),
                                        scopes: [
                                          AppleIDAuthorizationScopes.email,
                                          AppleIDAuthorizationScopes.fullName,
                                        ],
                                      );
                                    } catch (e) {
                                      return;
                                    }
                                    var service = DependencyProvider.of(context)
                                        .getService<IAuthenticationService>();

                                    var signInResult =
                                        await service.signInWithApple(
                                            identityToken:
                                                credential.identityToken!,
                                            authorizationCode:
                                                credential.authorizationCode);

                                    if (!mounted) return;

                                    await signInResult
                                        .possiblyHandleError(context);

                                    if (signInResult.isSuccessful &&
                                        signInResult.result!.resultType ==
                                            SignInResultType
                                                .loginSucessfullButConfigurationMissing) {
                                      // TODO navigate to complete sign in using sign in provider screen
                                    } else if (signInResult.isSuccessful &&
                                        signInResult.result!.resultType ==
                                            SignInResultType.loginSucessfull) {
                                      // TODO navigate
                                    }
                                  },
                                ),
                              ),

                              Spacer(
                                flex: 1,
                              ),
                              // GOOGLE SIGN IN BUTTON
                              Expanded(
                                flex: 4,
                                child: SignInButton(
                                  Buttons.Google,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7))),
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  text: "Sign in with Google",
                                  onPressed: () async {
                                    // Default definition
                                    GoogleSignIn googleSignIn = GoogleSignIn(
                                      clientId:
                                          '301126660357-ro64929c9et8ome57r0vmk53vrn4754b.apps.googleusercontent.com', // TODO update me
                                      scopes: [
                                        'email',
                                      ],
                                    );

                                    final GoogleSignInAccount? googleAccount =
                                        await googleSignIn.signIn();

                                    if (googleAccount == null) return;

                                    // If you want further information about Google accounts, such as authentication, use this.
                                    final GoogleSignInAuthentication
                                        googleAuthentication =
                                        await googleAccount.authentication;

                                    var service = DependencyProvider.of(context)
                                        .getService<IAuthenticationService>();

                                    var signInResult =
                                        await service.signInWithGoogle(
                                            identityToken:
                                                googleAuthentication.idToken!,
                                            authorizationCode:
                                                googleAuthentication
                                                    .serverAuthCode!);

                                    if (!mounted) return;

                                    await signInResult
                                        .possiblyHandleError(context);

                                    // TODO navigate
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 30,
                          ),
                          HorizontalLine(),
                          SizedBox(
                            height: 30,
                          ),

                          CustomButton(
                              label: "Neuen Account anlegen", // TODO localize
                              onPressed: () {
                                // navigate to register screen
                                navigatorKey.currentState!
                                    .pushNamed(RegisterScreen.route);
                              }),
                          SizedBox(
                            height: 10,
                          ),

                          // SizedBox(
                          //     height: EdgeInsets.fromViewPadding(
                          //             View.of(context).viewInsets,
                          //             View.of(context).devicePixelRatio)
                          //         .bottom),
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
