import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/l10n.dart';
import 'package:rpg_table_helper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:uuid/v7.dart';

class RpgConfigurationWizardStep2CharacterConfigurationsPreset
    extends WizardStepBase {
  const RpgConfigurationWizardStep2CharacterConfigurationsPreset({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
    required super.setWizardTitle,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep2CharacterConfigurationsPreset>
      createState() =>
          _RpgConfigurationWizardStep2CharacterConfigurationsPresetState();
}

class StatOrGroupIndicator {
  final CharacterStatDefinition? stat;
  final String? groupHandleId;

  StatOrGroupIndicator({required this.stat, required this.groupHandleId});
}

class _RpgConfigurationWizardStep2CharacterConfigurationsPresetState
    extends ConsumerState<
        RpgConfigurationWizardStep2CharacterConfigurationsPreset> {
  bool hasDataLoaded = false;
  List<
      (
        String uuid,
        TextEditingController tabName,
        bool isOptional,
        bool isDefaultTab,
      )> tabsToEdit = [];

  Map<String, List<StatOrGroupIndicator>> statsUnderTab = {};

  bool isFormValid = true;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      widget.setWizardTitle("Character Stats");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      setState(() {
        if (hasDataLoaded) return;
        hasDataLoaded = true;

        var loadedTabs = (data.characterStatTabsDefinition ??
            RpgConfigurationModel.getBaseConfiguration()
                .characterStatTabsDefinition!);

        for (var tab in loadedTabs) {
          tabsToEdit.add((
            tab.uuid,
            TextEditingController(text: tab.tabName),
            tab.isOptional,
            tab.isDefaultTab
          ));

          var lastGroupIndicator = tab.statsInTab.firstOrNull?.groupId;

          for (var stat in tab.statsInTab) {
            if (stat.groupId != lastGroupIndicator) {
              statsUnderTab.putIfAbsent(tab.uuid, () => []).add(
                  StatOrGroupIndicator(
                      stat: null, groupHandleId: UuidV7().generate()));
              lastGroupIndicator = stat.groupId;
            }

            statsUnderTab
                .putIfAbsent(tab.uuid, () => [])
                .add(StatOrGroupIndicator(stat: stat, groupHandleId: null));
          }
        }
      });
    });

    var stepHelperText = S.of(context).rpgConfigurationDmWizardStep2Tutorial;

    return TwoPartWizardStepBody(
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepHelperText: stepHelperText,
      onNextBtnPressed: !isFormValid
          ? null
          : () {
              saveChanges();
              widget.onNextBtnPressed();
            },
      onPreviousBtnPressed: () {
        saveChanges();

        widget.onPreviousBtnPressed();
      },
      sideBarFlex: 1,
      contentFlex: 2,
      contentChildren: [
        ...tabsToEdit.asMap().entries.map((tab) {
          return Column(
            children: [
              // Tab title textfield
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      labelText: "Tab Title",
                      textEditingController: tab.value.$2,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 50,
                    width: 40,
                    clipBehavior: Clip.none,
                    child: CustomButton(
                      isSubbutton: true,
                      variant: CustomButtonVariant.FlatButton,
                      onPressed: () {
                        setState(() {
                          tabsToEdit.removeAt(tab.key);
                        });
                      },
                      icon: const CustomFaIcon(
                          size: 16,
                          color: darkColor,
                          icon: FontAwesomeIcons.trashCan),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).defaultTab,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: darkTextColor),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      CustomButton(
                        isSubbutton: true,
                        onPressed: () {
                          setState(() {
                            var newTabsToEdit = [...tabsToEdit];
                            for (var i = 0; i < newTabsToEdit.length; i++) {
                              newTabsToEdit[i] = (
                                newTabsToEdit[i].$1,
                                newTabsToEdit[i].$2,
                                newTabsToEdit[i].$3,
                                i == tab.key
                              );
                            }
                            tabsToEdit = newTabsToEdit;
                          });
                        },
                        icon: Container(
                          width: 20,
                          height: 20,
                          color: tab.value.$4 ? darkColor : Colors.transparent,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),

              // stats beneath
              ReorderableListView(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    var item = statsUnderTab[tab.value.$1]!.removeAt(oldIndex);
                    statsUnderTab[tab.value.$1]!.insert(newIndex, item);
                  });
                },
                proxyDecorator:
                    (Widget child, int index, Animation<double> animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      final double animValue =
                          Curves.easeInOut.transform(animation.value);
                      final double elevation = lerpDouble(0, 6, animValue)!;
                      return Material(
                        elevation: elevation,
                        color: Colors.transparent,
                        shadowColor: Colors.black.withOpacity(0.3),
                        child: child,
                      );
                    },
                    child: child,
                  );
                },
                children: (statsUnderTab[tab.value.$1] ?? [])
                    .asMap()
                    .entries
                    .map(
                      (e) => e.value.groupHandleId != null
                          ? Padding(
                              key: ValueKey(e.value),
                              padding:
                                  const EdgeInsets.only(left: 3, right: 95),
                              child: Row(
                                children: [
                                  CustomFaIcon(
                                    icon: FontAwesomeIcons.gripVertical,
                                    color: Color.lerp(
                                        middleBgColor, darkColor, 0.5),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 12, 0, 12),
                                      child: Column(
                                        children: [
                                          HorizontalLine(
                                            useDarkColor: true,
                                          ),
                                          Center(
                                            child: Text(S.of(context).newGroup),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              color: bgColor,
                              key: ValueKey(e.value),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CustomFaIcon(
                                    icon: FontAwesomeIcons.gripVertical,
                                    color: Color.lerp(
                                        middleBgColor, darkColor, 0.5),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 5, 0, 5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: darkColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: CustomMarkdownBody(
                                                  text:
                                                      "### ${e.value.stat!.name} (${e.value.stat!.valueType.toCustomString(context)})",
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  // Edit Button
                                  Container(
                                    height: 50,
                                    width: 40,
                                    clipBehavior: Clip.none,
                                    child: CustomButton(
                                      variant: CustomButtonVariant.FlatButton,
                                      isSubbutton: true,
                                      onPressed: () async {
                                        await showGetDmConfigurationModal(
                                                context: context,
                                                predefinedConfiguration:
                                                    e.value.stat)
                                            .then((value) {
                                          if (value == null) {
                                            return;
                                          }
                                          setState(() {
                                            statsUnderTab[tab.value.$1]![
                                                    e.key] =
                                                StatOrGroupIndicator(
                                                    stat: value,
                                                    groupHandleId: null);
                                          });
                                        });
                                      },
                                      icon: const CustomFaIcon(
                                          size: 16,
                                          color: darkColor,
                                          icon: FontAwesomeIcons.penToSquare),
                                    ),
                                  ),
                                  Container(
                                    height: 50,
                                    width: 40,
                                    clipBehavior: Clip.none,
                                    child: CustomButton(
                                      isSubbutton: true,
                                      variant: CustomButtonVariant.FlatButton,
                                      onPressed: () {
                                        setState(() {
                                          statsUnderTab[tab.value.$1]!
                                              .removeAt(e.key);
                                        });
                                      },
                                      icon: const CustomFaIcon(
                                          size: 16,
                                          color: darkColor,
                                          icon: FontAwesomeIcons.trashCan),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    )
                    .toList(),
              ),

              // add new stat beneath
              Padding(
                padding: const EdgeInsets.fromLTRB(34, 20, 0, 20),
                child: Row(
                  children: [
                    CustomButton(
                      isSubbutton: true,
                      onPressed: () async {
                        setState(() {
                          statsUnderTab.putIfAbsent(tab.value.$1, () => []).add(
                              StatOrGroupIndicator(
                                  groupHandleId: UuidV7().generate(),
                                  stat: null));
                        });
                      },
                      label: S.of(context).newGroupBtnLabel,
                      icon: Theme(
                          data: ThemeData(
                            iconTheme: const IconThemeData(
                              color: darkTextColor,
                              size: 16,
                            ),
                            textTheme: const TextTheme(
                              bodyMedium: TextStyle(
                                color: darkTextColor,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Container(
                                width: 16,
                                height: 16,
                                alignment: AlignmentDirectional.center,
                                child: const FaIcon(FontAwesomeIcons.plus)),
                          )),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    CustomButton(
                      isSubbutton: true,
                      onPressed: () async {
                        // open new modal for dm config
                        // if it returns non null add the stat
                        await showGetDmConfigurationModal(context: context)
                            .then((value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            statsUnderTab
                                .putIfAbsent(tab.value.$1, () => [])
                                .add(StatOrGroupIndicator(
                                  stat: value,
                                  groupHandleId: null,
                                ));
                          });
                        });
                      },
                      label: S.of(context).newPropertyBtnLabel,
                      icon: Theme(
                          data: ThemeData(
                            iconTheme: const IconThemeData(
                              color: darkTextColor,
                              size: 16,
                            ),
                            textTheme: const TextTheme(
                              bodyMedium: TextStyle(
                                color: darkTextColor,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Container(
                                width: 16,
                                height: 16,
                                alignment: AlignmentDirectional.center,
                                child: const FaIcon(FontAwesomeIcons.plus)),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),

        // add new tab button
        CustomButton(
          variant: CustomButtonVariant.Default,
          onPressed: () {
            addNewTab();
          },
          label: S.of(context).newTabBtnLabel,
          icon: Theme(
              data: ThemeData(
                iconTheme: const IconThemeData(
                  color: darkColor,
                  size: 16,
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(
                    color: darkColor,
                  ),
                ),
              ),
              child: Container(
                  width: 24,
                  height: 24,
                  alignment: AlignmentDirectional.center,
                  child: const FaIcon(FontAwesomeIcons.plus))),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void addNewTab() {
    setState(() {
      var newId = UuidV7().generate();

      tabsToEdit.add((
        newId,
        TextEditingController(),
        false, // isOptional
        tabsToEdit.isEmpty, // isDefaultTab
      ));

      statsUnderTab[newId] = [];
    });
  }

  void saveChanges() {
    var constructedTabs = tabsToEdit.map((tuple) {
      List<CharacterStatDefinition> correctyGroupedStats = [];

      int groupCountInTab = 0;

      for (var groupStat
          in (statsUnderTab[tuple.$1] ?? List<StatOrGroupIndicator>.empty())) {
        if (groupStat.groupHandleId != null) {
          groupCountInTab++;
        } else {
          correctyGroupedStats
              .add(groupStat.stat!.copyWith(groupId: groupCountInTab));
        }
      }

      return CharacterStatsTabDefinition(
        isOptional: tuple.$3,
        isDefaultTab: tuple.$4,
        tabName: tuple.$2.text,
        uuid: tuple.$1,
        statsInTab: correctyGroupedStats,
      );
    }).toList();

    ref
        .read(rpgConfigurationProvider.notifier)
        .updateCharacterScreenStatsTabs(constructedTabs);
  }
}

extension on CharacterStatValueType {
  toCustomString(BuildContext context) {
    switch (this) {
      case CharacterStatValueType.int:
        return S.of(context).integerValue;
      case CharacterStatValueType.transformIntoAlternateFormBtn:
        return S.of(context).transformIntoAlternateForm;
      case CharacterStatValueType.listOfIntsWithIcons:
        return S.of(context).listOfIntegersWithIcons;
      case CharacterStatValueType.intWithMaxValue:
        return S.of(context).integerValueWithMaxValue;
      case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
        return S.of(context).characterNameWithLevelAndConfigurableDetails;
      case CharacterStatValueType.listOfIntWithCalculatedValues:
        return S.of(context).listOfInterValuesWithCalculatedIntegerValues;

      case CharacterStatValueType.intWithCalculatedValue:
        return S.of(context).integerValueWithCalculatedValue;
      case CharacterStatValueType.multiLineText:
        return S.of(context).multilineText;
      case CharacterStatValueType.singleImage:
        return S.of(context).generatedImage;
      case CharacterStatValueType.singleLineText:
        return S.of(context).singleLineText;
      case CharacterStatValueType.multiselect:
        return S.of(context).multiselectOption;
      case CharacterStatValueType.companionSelector:
        return S.of(context).companionOverview;
    }
  }
}
