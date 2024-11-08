// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/components/newdesign/navbar_new_design.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:shadow_widget/shadow_widget.dart';

Future<int?> showAskPlayerForFightOrderRoll(BuildContext context,
    {required String characterName,
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
        );
      });
}

class PlayerHasBeenAskedToRollForFightOrderModalContent extends StatefulWidget {
  const PlayerHasBeenAskedToRollForFightOrderModalContent({
    super.key,
    required this.modalPadding,
    required this.characterName,
  });

  final String characterName;
  final double modalPadding;

  @override
  State<PlayerHasBeenAskedToRollForFightOrderModalContent> createState() =>
      _PlayerHasBeenAskedToRollForFightOrderModalContentState();
}

class _PlayerHasBeenAskedToRollForFightOrderModalContentState
    extends State<PlayerHasBeenAskedToRollForFightOrderModalContent> {
  int alreadySeenItems = 0;

  var textEditingController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
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
          child: ShadowWidget(
            offset: Offset(-4, 4),
            blurRadius: 5,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 550, maxHeight: 300),
              child: Container(
                color: bgColor,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    NavbarNewDesign(
                      backInsteadOfCloseIcon: false,
                      closeFunction: () {
                        navigatorKey.currentState!.pop(null);
                      },
                      menuOpen: null,
                      useTopSafePadding: false,
                      titleWidget: Text(
                        "Kampf Reihenfolge Wurf (${widget.characterName})", // TODO localize/ switch text between add and edit
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: textColor, fontSize: 24),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                "Ein Kampf startet: Würfel deinen Platz in der Reihenfolge!",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: darkTextColor,
                                      fontSize: 16,
                                    ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomTextField(
                                newDesign: true,
                                labelText: "Kampf Wurf",
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
                      padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                      child: Row(
                        children: [
                          const Spacer(),
                          CustomButtonNewdesign(
                            label: "Abbrechen", // TODO localize
                            onPressed: () {
                              navigatorKey.currentState!.pop(null);
                            },
                          ),
                          const Spacer(),
                          CustomButtonNewdesign(
                            label: "Absenden", // TODO localize
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
