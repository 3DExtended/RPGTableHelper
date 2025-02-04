import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/signinbuttons/button_list.dart';
import 'package:rpg_table_helper/components/signinbuttons/button_view.dart';
import 'package:rpg_table_helper/components/signinbuttons/custom_sign_in_with_apple.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/l10n.dart';
import 'package:rpg_table_helper/helpers/validation_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/screens/preauthorized/complete_sso_screen.dart';
import 'package:rpg_table_helper/screens/preauthorized/register_screen.dart';
import 'package:rpg_table_helper/screens/select_game_mode_screen.dart';
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
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
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
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.2),
                        child: Image.asset(
                          "assets/icons/icon_flat.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      // LOGIN
                      // Username Textfield
                      CustomTextField(
                        labelText: S.of(context).username,
                        textEditingController: usernameTextEditingController,
                        keyboardType: TextInputType.name,
                      ),

                      // password Textfield
                      CustomTextField(
                        labelText: S.of(context).password,
                        textEditingController: passwordTextEditingController,
                        password: true,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      // login button
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: CustomButton(
                            boderRadiusOverride: 7,
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                S.of(context).login,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: Colors.white, fontSize: 18),
                              ),
                            ),
                            variant: CustomButtonVariant.AccentButton,
                            onPressed: isLoginButtonDisabled
                                ? null
                                : () async {
                                    // TODO perform login
                                    var service = DependencyProvider.of(context)
                                        .getService<IAuthenticationService>();

                                    var signinResponse = await service
                                        .loginWithUsernameAndPassword(
                                            username:
                                                usernameTextEditingController
                                                    .text,
                                            password:
                                                passwordTextEditingController
                                                    .text);
                                    if (!mounted || !context.mounted) return;

                                    await signinResponse
                                        .possiblyHandleError(context);

                                    if (signinResponse.result == true) {
                                      // proceed to campagne or character selection
                                      navigatorKey.currentState!
                                          .pushNamedAndRemoveUntil(
                                              SelectGameModeScreen.route,
                                              (r) => false);
                                    } else {
                                      // TODO mark password and username fields as invalid
                                    }
                                  },
                          ),
                        ),
                      ),

                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          // apple sign in button
                          SizedBox(
                            width: 300,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: darkColor,
                                ),
                                borderRadius: BorderRadius.circular(
                                  7,
                                ),
                              ),
                              child: CustomSignInWithAppleButton(
                                style: CustomSignInWithAppleButtonStyle.white,
                                text: S.of(context).signInWithApple,
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
                                  if (!mounted || !context.mounted) return;

                                  var service = DependencyProvider.of(context)
                                      .getService<IAuthenticationService>();

                                  var signInResult =
                                      await service.signInWithApple(
                                          identityToken:
                                              credential.identityToken!,
                                          authorizationCode:
                                              credential.authorizationCode);

                                  if (!context.mounted || !mounted) return;

                                  await signInResult
                                      .possiblyHandleError(context);

                                  if (signInResult.isSuccessful &&
                                      signInResult.result!.resultType ==
                                          SignInResultType
                                              .loginSucessfullButConfigurationMissing) {
                                    // navigate to complete sign in using sign in provider screen
                                    navigatorKey.currentState!
                                        .pushNamedAndRemoveUntil(
                                            CompleteSsoScreen.route,
                                            (r) => false,
                                            arguments: signInResult
                                                .result!.additionalDetails!
                                                .replaceAll('redirect', ''));
                                  } else if (signInResult.isSuccessful &&
                                      signInResult.result!.resultType ==
                                          SignInResultType.loginSucessfull) {
                                    navigatorKey.currentState!
                                        .pushNamedAndRemoveUntil(
                                            SelectGameModeScreen.route,
                                            (r) => false);
                                  }
                                },
                              ),
                            ),
                          ),

                          // GOOGLE SIGN IN BUTTON
                          SizedBox(
                            width: 300,
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: darkColor,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    7,
                                  ),
                                ),
                                child: SignInButton(
                                  Buttons.Google,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7))),
                                  padding:
                                      const EdgeInsets.fromLTRB(40, 7, 40, 7),
                                  text: S.of(context).signInWithGoogle,
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

                                    if (!mounted || !context.mounted) return;

                                    var service = DependencyProvider.of(context)
                                        .getService<IAuthenticationService>();

                                    var signInResult =
                                        await service.signInWithGoogle(
                                            identityToken:
                                                googleAuthentication.idToken!,
                                            authorizationCode:
                                                googleAuthentication
                                                    .serverAuthCode!);

                                    if (!mounted || !context.mounted) return;

                                    await signInResult
                                        .possiblyHandleError(context);

                                    if (signInResult.isSuccessful &&
                                        signInResult.result!.resultType ==
                                            SignInResultType.loginSucessfull) {
                                      // proceed to campagne or character selection
                                      navigatorKey.currentState!
                                          .pushNamedAndRemoveUntil(
                                              SelectGameModeScreen.route,
                                              (r) => false);
                                    } else if (signInResult.isSuccessful &&
                                        signInResult.result!.resultType ==
                                            SignInResultType
                                                .loginSucessfullButConfigurationMissing) {
                                      // navigate to complete sign in using sign in provider screen
                                      navigatorKey.currentState!
                                          .pushNamedAndRemoveUntil(
                                              CompleteSsoScreen.route,
                                              (r) => false,
                                              arguments: signInResult
                                                  .result!.additionalDetails!
                                                  .replaceAll('redirect', ''));
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 30,
                      ),
                      HorizontalLine(
                        useDarkColor: true,
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      CustomButton(
                        width: 298,
                        height: 55,
                        boderRadiusOverride: 7,
                        label: S.of(context).createNewAccount,
                        variant: CustomButtonVariant.DarkButton,
                        onPressed: () {
                          // navigate to register screen
                          navigatorKey.currentState!
                              .pushNamed(RegisterScreen.route);
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      // CustomButton(
                      //     label: "Licenses",
                      //     onPressed: () {
                      //       navigatorKey.currentState!.push(MaterialPageRoute(
                      //         builder: (context) => LicensePage(),
                      //       ));
                      //     }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
