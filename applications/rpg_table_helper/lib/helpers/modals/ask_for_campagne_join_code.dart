// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/helpers/validation_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

Future<String?> askForCampagneJoinCode(BuildContext context,
    {GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<String>(
      backgroundColor: const Color.fromARGB(192, 21, 21, 21),
      isDismissible: false,
      expand: false,
      closeProgressThreshold: -50000,
      enableDrag: false,
      context: context,
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        return AskForCampagneJoinCodeModalContent(modalPadding: modalPadding);
      });
}

class AskForCampagneJoinCodeModalContent extends StatefulWidget {
  const AskForCampagneJoinCodeModalContent({
    super.key,
    required this.modalPadding,
  });

  final double modalPadding;

  @override
  State<AskForCampagneJoinCodeModalContent> createState() =>
      _AskForCampagneJoinCodeModalContentState();
}

class _AskForCampagneJoinCodeModalContentState
    extends State<AskForCampagneJoinCodeModalContent> {
  var joinCodeTextEditor = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var modalPadding = 80.0;
    if (MediaQuery.of(context).size.width < 800) {
      modalPadding = 20.0;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.fromLTRB(modalPadding, 20, modalPadding, 20),
        child: Center(
          child: CustomShadowWidget(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800.0,
              ),
              child: Container(
                color: CustomThemeProvider.of(context).theme.bgColor,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Navbar(
                        backInsteadOfCloseIcon: false,
                        closeFunction: () {
                          navigatorKey.currentState!.pop(null);
                        },
                        menuOpen: null,
                        useTopSafePadding: false,
                        titleWidget: Text(
                          S.of(context).addCharacterToCampagneModalTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: CustomThemeProvider.of(context)
                                      .theme
                                      .textColor,
                                  fontSize: 24),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomMarkdownBody(
                                text: S
                                    .of(context)
                                    .assignCharacterToCampagneModalContent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                keyboardType: TextInputType.text,
                                labelText: S.of(context).joinCode,
                                textEditingController: joinCodeTextEditor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 20),
                        child: Row(
                          children: [
                            CustomButton(
                              variant: CustomButtonVariant.DarkButton,
                              label: S.of(context).cancel,
                              onPressed: () {
                                navigatorKey.currentState!.pop(null);
                              },
                            ),
                            const Spacer(),
                            CustomButton(
                              variant: CustomButtonVariant.AccentButton,
                              label: S.of(context).save,
                              onPressed: () {
                                // TODO activate only when join code matches format
                                if (joinCodeValid(joinCodeTextEditor.text)) {
                                  navigatorKey.currentState!
                                      .pop(joinCodeTextEditor.text);
                                } else {}
                              },
                            ),
                          ],
                        ),
                      ),
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
