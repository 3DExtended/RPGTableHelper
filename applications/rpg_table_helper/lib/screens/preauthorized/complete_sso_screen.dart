import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/validation_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/screens/select_game_mode_screen.dart';
import 'package:rpg_table_helper/services/auth/authentication_service.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

class CompleteSsoScreen extends ConsumerStatefulWidget {
  static const route = 'completesso';

  const CompleteSsoScreen({super.key});

  @override
  ConsumerState<CompleteSsoScreen> createState() => _CompleteSsoScreenState();
}

class _CompleteSsoScreenState extends ConsumerState<CompleteSsoScreen> {
  var usernameTextEditingController = TextEditingController();

  var isLoginButtonDisabled = true;

  @override
  void initState() {
    usernameTextEditingController.addListener(_updateStateForFormValidation);
    super.initState();
  }

  @override
  void dispose() {
    usernameTextEditingController.removeListener(_updateStateForFormValidation);

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
    if (!usernameValid(usernameTextEditingController.text)) {
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
                      "Complete Registration", // TODO localize
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

                    // Username Textfield
                    CustomTextField(
                      newDesign: true,
                      labelText: "Username", // TODO Localize
                      textEditingController: usernameTextEditingController,
                      keyboardType: TextInputType.name,
                    ),

                    SizedBox(
                      height: 40,
                    ),

                    // complete button
                    Center(
                      child: CustomButtonNewdesign(
                        variant: CustomButtonNewdesignVariant.AccentButton,
                        label: "Complete registration", // TODO localize

                        onPressed: isLoginButtonDisabled
                            ? null
                            : () async {
                                // complete signup
                                var service = DependencyProvider.of(context)
                                    .getService<IAuthenticationService>();
                                final currentRouteSettings =
                                    ModalRoute.of(context)!.settings;

                                var apiKey = currentRouteSettings.arguments ==
                                        null
                                    ? '2769ed28-7233-4d4c-ad36-bb95065100df'
                                    : currentRouteSettings.arguments as String;

                                var signinResponse =
                                    await service.completeRegistration(
                                        username:
                                            usernameTextEditingController.text,
                                        apiKey: apiKey);

                                if (!context.mounted) return;
                                await signinResponse
                                    .possiblyHandleError(context);

                                if (signinResponse.result == true) {
                                  // proceed to campagne or character selection
                                  navigatorKey.currentState!
                                      .pushNamedAndRemoveUntil(
                                          SelectGameModeScreen.route,
                                          (r) => false);
                                } else {
                                  // TODO mark username fields as invalid
                                }
                              },
                      ),
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
