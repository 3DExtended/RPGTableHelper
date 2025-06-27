import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/list_extensions.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:themed/themed.dart';

Future showAddFurtherEnemiesToFightSequence(
    {required BuildContext context,
    GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  await customShowCupertinoModalBottomSheet<int>(
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

        return AddFurtherEnemiesToFightSequenceModalContent(
          modalPadding: modalPadding,
        );
      });
}

class AddFurtherEnemiesToFightSequenceModalContent
    extends ConsumerStatefulWidget {
  final double modalPadding;
  const AddFurtherEnemiesToFightSequenceModalContent(
      {super.key, required this.modalPadding});

  @override
  ConsumerState<AddFurtherEnemiesToFightSequenceModalContent> createState() =>
      _AddFurtherEnemiesToFightSequenceModalContentState();
}

class _AddFurtherEnemiesToFightSequenceModalContentState
    extends ConsumerState<AddFurtherEnemiesToFightSequenceModalContent> {
  List<(TextEditingController, TextEditingController)> enemiesToAdd = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
            bottom: 20,
            top: 20,
            left: widget.modalPadding,
            right: widget.modalPadding),
        child: Center(
          child: CustomShadowWidget(
              child: Container(
            color: CustomThemeProvider.of(context).theme.bgColor,
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
                    S.of(context).addAdditionalEnemy,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: CustomThemeProvider.of(context)
                                    .brightnessNotifier
                                    .value ==
                                Brightness.light
                            ? CustomThemeProvider.of(context).theme.textColor
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
                          ...enemiesToAdd.asMap().entries.map(
                                (en) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: CustomThemeProvider.of(
                                                              context)
                                                          .brightnessNotifier
                                                          .value ==
                                                      Brightness.light
                                                  ? CustomThemeProvider.of(
                                                          context)
                                                      .theme
                                                      .middleBgColor
                                                  : CustomThemeProvider.of(
                                                          context)
                                                      .theme
                                                      .bgColor
                                                      .lighter(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: CustomTextField(
                                                    labelText:
                                                        S.of(context).enemyName,
                                                    textEditingController:
                                                        en.value.$1,
                                                    keyboardType:
                                                        TextInputType.text),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: CustomTextField(
                                                    labelText: S
                                                        .of(context)
                                                        .rollOfInititive,
                                                    textEditingController:
                                                        en.value.$2,
                                                    keyboardType:
                                                        TextInputType.number),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 50,
                                        width: 70,
                                        clipBehavior: Clip.none,
                                        child: CustomButton(
                                          variant:
                                              CustomButtonVariant.FlatButton,
                                          onPressed: () {
                                            setState(() {
                                              enemiesToAdd.removeAt(en.key);
                                            });
                                          },
                                          icon: CustomFaIcon(
                                            icon: FontAwesomeIcons.trashCan,
                                            size: 24,
                                            color:
                                                CustomThemeProvider.of(context)
                                                    .theme
                                                    .darkColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: CustomButton(
                              label: S.of(context).addAnAdditionalEnemyBtnLabel,
                              onPressed: () {
                                var connectionDetails = ref
                                    .read(connectionDetailsProvider)
                                    .requireValue;
                                var numberOfEnemies = connectionDetails
                                        .fightSequence?.sequence
                                        .where((ele) => ele.$1 == null)
                                        .length ??
                                    0;

                                setState(() {
                                  enemiesToAdd.add((
                                    TextEditingController(
                                        text:
                                            "${S.of(context).enemy} #${numberOfEnemies + 1 + enemiesToAdd.length}"),
                                    TextEditingController()
                                  ));
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                            child: Row(
                              children: [
                                const Spacer(),
                                CustomButton(
                                  label: S.of(context).cancel,
                                  onPressed: () {
                                    navigatorKey.currentState!.pop(null);
                                  },
                                ),
                                const Spacer(),
                                CustomButton(
                                  label: S.of(context).add,
                                  onPressed: () {
                                    // add enemies to connectiondetails
                                    var connectionDetails = ref
                                        .read(connectionDetailsProvider)
                                        .requireValue;

                                    var modifiedSequence = connectionDetails
                                        .fightSequence!.sequence;

                                    modifiedSequence.addAllIntoSortedList(
                                        enemiesToAdd.map((tu) => (
                                              null,
                                              tu.$1.text,
                                              int.parse(tu.$2.text)
                                            )),
                                        (a, b) => b.$3.compareTo(a.$3));

                                    ref
                                        .read(
                                            connectionDetailsProvider.notifier)
                                        .updateConfiguration(
                                            connectionDetails.copyWith(
                                                fightSequence: connectionDetails
                                                    .fightSequence!
                                                    .copyWith(
                                                        sequence:
                                                            modifiedSequence)));

                                    navigatorKey.currentState!.pop(null);
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
              ],
            ),
          )),
        ),
      ),
    );
  }
}
