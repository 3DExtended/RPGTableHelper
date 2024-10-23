import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/fill_remaining_space.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/helpers/validation_helpers.dart';
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
                            "Complete Registration", // TODO localize
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
                          // Username Textfield
                          CustomTextField(
                            labelText: "Username", // TODO Localize
                            textEditingController:
                                usernameTextEditingController,
                            keyboardType: TextInputType.name,
                          ),

                          // login button
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: CustomButton(
                                label: "Complete registration", // TODO localize

                                onPressed: isLoginButtonDisabled
                                    ? null
                                    : () async {
                                        // complete signup
                                        var service =
                                            DependencyProvider.of(context)
                                                .getService<
                                                    IAuthenticationService>();
                                        final currentRouteSettings =
                                            ModalRoute.of(context)!.settings;

                                        var apiKey = currentRouteSettings
                                                    .arguments ==
                                                null
                                            ? '2769ed28-7233-4d4c-ad36-bb95065100df'
                                            : currentRouteSettings.arguments
                                                as String;

                                        var signinResponse =
                                            await service.completeRegistration(
                                                username:
                                                    usernameTextEditingController
                                                        .text,
                                                apiKey: apiKey);
                                        if (!mounted) return;

                                        await signinResponse
                                            .possiblyHandleError(context);

                                        if (signinResponse.result == true) {
                                          // TODO proceed to campagne or character selection
                                        } else {
                                          // TODO mark username fields as invalid
                                        }
                                      },
                              ),
                            ),
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
