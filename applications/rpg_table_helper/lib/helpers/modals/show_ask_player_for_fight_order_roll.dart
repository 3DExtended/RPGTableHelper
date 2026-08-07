// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/initiative_bonus_resolver.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

Future<int?> showAskPlayerForFightOrderRoll(BuildContext context,
    {required String characterName,
    InitiativeBonusHint? initiativeBonusHint,
    GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<int>(
      isDismissible: true,
      expand: true,
      closeProgressThreshold: -50000,
      enableDrag: false,
      context: context,
      backgroundColor: const Color.fromARGB(192, 21, 21, 21),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        return PlayerHasBeenAskedToRollForFightOrderModalContent(
          modalPadding: modalPadding,
          characterName: characterName,
          initiativeBonusHint: initiativeBonusHint,
        );
      });
}

class PlayerHasBeenAskedToRollForFightOrderModalContent extends StatefulWidget {
  const PlayerHasBeenAskedToRollForFightOrderModalContent({
    super.key,
    required this.modalPadding,
    required this.characterName,
    this.initiativeBonusHint,
  });

  final String characterName;
  final double modalPadding;
  final InitiativeBonusHint? initiativeBonusHint;

  @override
  State<PlayerHasBeenAskedToRollForFightOrderModalContent> createState() =>
      _PlayerHasBeenAskedToRollForFightOrderModalContentState();
}

class _PlayerHasBeenAskedToRollForFightOrderModalContentState
    extends State<PlayerHasBeenAskedToRollForFightOrderModalContent> {
  var textEditingController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    final hint = widget.initiativeBonusHint;
    // Cartographer chrome needs a bit more vertical room; other skins keep classic sizes.
    final maxHeight = (hint == null ? 300.0 : 360.0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
            bottom: 20,
            top: 20,
            left: widget.modalPadding,
            right: widget.modalPadding),
        child: Center(
          child: CustomShadowWidget(
            // Constraints must sit *inside* SkinnedModalPanel so frame insets
            // grow the card instead of stealing height from the body.
            child: SkinnedModalPanel(
              child: ConstrainedBox(
                constraints: skinnedModalContentConstraints(
                  context,
                  maxWidth: 550,
                  maxHeight: maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Navbar(
                      backInsteadOfCloseIcon: false,
                      closeFunction: () {
                        navigatorKey.currentState!.pop(null);
                      },
                      menuOpen: null,
                      useTopSafePadding: false,
                      titleWidget: Text(
                        "${S.of(context).initiativeRollForCharacterPrefix} (${widget.characterName})",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: CustomThemeProvider.of(context)
                                        .brightnessNotifier
                                        .value ==
                                    Brightness.light
                                ? CustomThemeProvider.of(context)
                                    .theme
                                    .textColor
                                : CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor,
                            fontSize: 24),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                S.of(context).initiativeRollText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: CustomThemeProvider.of(context)
                                          .theme
                                          .darkTextColor,
                                      fontSize: 16,
                                    ),
                              ),
                              if (hint != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  S.of(context).initiativeBonusHelperSentence(
                                        hint.label,
                                        formatInitiativeBonus(hint.bonus),
                                      ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: CustomThemeProvider.of(context)
                                            .theme
                                            .darkTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextField(
                                labelText:
                                    S.of(context).initiativeRollTextFieldLabel,
                                textEditingController: textEditingController,
                                keyboardType: TextInputType.number,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          30.0, 30, 30, modalFooterBottomPadding(context)),
                      child: Row(
                        children: [
                          const Spacer(),
                          CustomButton(
                            label: S.of(context).send,
                            onPressed: () {
                              // TODO add validation
                              var numberParsed =
                                  int.tryParse(textEditingController.text);
                              if (numberParsed == null) return;

                              navigatorKey.currentState!.pop(numberParsed);
                            },
                          ),
                          const Spacer(),
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
    );
  }
}
