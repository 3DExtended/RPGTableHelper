// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/iterable_extension.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:uuid/v7.dart';

Future<RpgAlternateCharacterConfiguration?>
    showSelectTransformationComponentsForTransformation(
  BuildContext context, {
  GlobalKey<NavigatorState>? overrideNavigatorKey,
  required RpgCharacterConfiguration rpgCharConfig,
  required RpgConfigurationModel rpgConfig,
}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<
          RpgAlternateCharacterConfiguration>(
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

        return _SelectTransformationComponentsForTransformationModalContent(
          modalPadding: modalPadding,
          rpgCharConfig: rpgCharConfig,
          rpgConfig: rpgConfig,
        );
      });
}

class _SelectTransformationComponentsForTransformationModalContent
    extends ConsumerStatefulWidget {
  const _SelectTransformationComponentsForTransformationModalContent({
    required this.modalPadding,
    required this.rpgConfig,
    required this.rpgCharConfig,
  });

  final double modalPadding;
  final RpgConfigurationModel rpgConfig;
  final RpgCharacterConfiguration rpgCharConfig;

  @override
  ConsumerState<_SelectTransformationComponentsForTransformationModalContent>
      createState() =>
          _SelectTransformationComponentsForTransformationModalContentState();
}

class _SelectTransformationComponentsForTransformationModalContentState
    extends ConsumerState<
        _SelectTransformationComponentsForTransformationModalContent> {
  final List<({String transformationUuid})> _selectedTransformationUuid = [];

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
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800, maxHeight: 500),
              child: Container(
                color: bgColor,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    getNavbar(context),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                "Wähle die Komponenten/Verwandlungen aus, die du für die Verwandlung verwenden möchtest.", // TODO localize
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
                              if (widget.rpgCharConfig.transformationComponents
                                      ?.isNotEmpty !=
                                  true)
                                Text(
                                    "Keine Komponenten/Verwandlungen vorhanden. Bitte gehe zurück und konfiguriere die Verwandlungen in den Charakter Einstellungen", // TODO localize
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: darkTextColor,
                                          fontSize: 16,
                                        )),
                              if (widget.rpgCharConfig.transformationComponents
                                      ?.isNotEmpty ==
                                  true)
                                ...widget.rpgCharConfig.transformationComponents
                                        ?.map(
                                      (e) => CheckboxListTile.adaptive(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        splashRadius: 0,
                                        dense: true,
                                        checkColor: const Color.fromARGB(
                                            255, 57, 245, 88),
                                        activeColor: darkColor,
                                        visualDensity:
                                            VisualDensity(vertical: -2),
                                        title: Text(
                                          e.transformationName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                  color: darkTextColor,
                                                  fontSize: 16),
                                        ),
                                        subtitle: e.transformationDescription
                                                    ?.isNotEmpty ==
                                                true
                                            ? Text(
                                                e.transformationDescription ??
                                                    "",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium!
                                                    .copyWith(
                                                        color: darkTextColor,
                                                        fontSize: 12),
                                              )
                                            : null,
                                        value: _selectedTransformationUuid.any(
                                            (element) =>
                                                element.transformationUuid ==
                                                e.transformationUuid),
                                        onChanged: (val) {
                                          if (_selectedTransformationUuid.any(
                                              (element) =>
                                                  element.transformationUuid ==
                                                  e.transformationUuid)) {
                                            setState(() {
                                              _selectedTransformationUuid
                                                  .removeWhere((element) =>
                                                      element
                                                          .transformationUuid ==
                                                      e.transformationUuid);
                                            });
                                          } else {
                                            setState(() {
                                              _selectedTransformationUuid.add((
                                                transformationUuid:
                                                    e.transformationUuid
                                              ));
                                            });
                                          }
                                        },
                                      ),
                                    ) ??
                                    [],

                              // TODO add additional settings (like "show non overwritten stats")
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                      child: Row(
                        children: [
                          const Spacer(flex: 1),
                          CustomButton(
                            label: S.of(context).cancel,
                            onPressed: () {
                              navigatorKey.currentState!.pop(null);
                            },
                          ),
                          Spacer(
                            flex: 3,
                          ),
                          CustomButton(
                            variant: CustomButtonVariant.AccentButton,
                            label: S.of(context).tranformToAlternateForm,
                            onPressed: widget
                                            .rpgCharConfig
                                            .transformationComponents
                                            ?.isNotEmpty ==
                                        true &&
                                    _selectedTransformationUuid.isNotEmpty
                                ? () {
                                    if (widget.rpgConfig
                                            .characterStatTabsDefinition ==
                                        null) return;

                                    var statsForTransformations =
                                        _selectedTransformationUuid
                                            .map((e) => widget.rpgCharConfig
                                                .transformationComponents
                                                ?.firstWhere((element) =>
                                                    element
                                                        .transformationUuid ==
                                                    e.transformationUuid)
                                                .transformationStats)
                                            .expand((element) => element!)
                                            .toList();

                                    // caluclate the merge of stats by their id
                                    var groupedByStatId =
                                        statsForTransformations.groupFoldBy<
                                                String,
                                                List<RpgCharacterStatValue>>(
                                            (element) => element.statUuid,
                                            (a, b) =>
                                                a == null ? [b] : [...a, b]);

                                    var groupedByStatIdWithStatDefs =
                                        groupedByStatId.entries.map((entry) {
                                      var statDef = widget.rpgConfig
                                          .characterStatTabsDefinition!
                                          .expand((e) => e.statsInTab)
                                          .firstWhere((element) =>
                                              element.statUuid == entry.key);
                                      return (
                                        key: entry.key,
                                        statDef: statDef,
                                        values: entry.value,
                                      );
                                    }).toList();

                                    print(groupedByStatIdWithStatDefs);
                                    List<RpgCharacterStatValue> mergedStats =
                                        [];
                                    for (var entry
                                        in groupedByStatIdWithStatDefs) {
                                      var currentStatToMerge =
                                          entry.values.first;

                                      var statDef = entry.statDef;
                                      var otherValuesToMerge =
                                          entry.values.skip(1).toList();

                                      for (var value in otherValuesToMerge) {
                                        currentStatToMerge =
                                            mergeStatIntoOtherStat(
                                                currentStatToMerge,
                                                value,
                                                statDef);
                                      }

                                      mergedStats.add(currentStatToMerge);
                                    }

                                    // find missing stats on main character and add them to stats list (maybe marking them as "copy")
                                    var missingStats = widget
                                        .rpgCharConfig.characterStats
                                        .where((element) => !mergedStats.any(
                                            (e) =>
                                                e.statUuid == element.statUuid))
                                        .map((e) => e.copyWith(
                                            statUuid: e.statUuid,
                                            serializedValue: e.serializedValue,
                                            isCopy: true))
                                        .toList();

                                    mergedStats.addAll(missingStats);

                                    // save transformation
                                    navigatorKey.currentState!.pop(
                                      // create a new RpgAlternateCharacterConfiguration from those stats
                                      RpgAlternateCharacterConfiguration(
                                        uuid: UuidV7().generate(),
                                        characterName: widget.rpgCharConfig
                                            .characterName, // TODO this should be configurable through the user while choosing the transformations
                                        characterStats: mergedStats,
                                        transformationComponents: null,
                                        alternateForm: null,
                                        isAlternateFormActive: null,
                                      ),
                                    );
                                  }
                                : null,
                          ),
                          const Spacer(flex: 1),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  RpgCharacterStatValue mergeStatIntoOtherStat(
      RpgCharacterStatValue currentStatToMerge,
      RpgCharacterStatValue value,
      CharacterStatDefinition statDef) {
    var currentStatValueToMergeInto =
        jsonDecode(currentStatToMerge.serializedValue);
    var valueToMerge = jsonDecode(value.serializedValue);

    switch (statDef.valueType) {
      // {"value": "asdf"}
      case CharacterStatValueType.multiLineText:
        currentStatValueToMergeInto["value"] =
            currentStatValueToMergeInto["value"] + "\n" + valueToMerge["value"];

      // {"value": "asdf"}
      case CharacterStatValueType.singleLineText:
        currentStatValueToMergeInto["value"] =
            currentStatValueToMergeInto["value"] + ", " + valueToMerge["value"];

        break;

      // {"value": 17}
      case CharacterStatValueType.int:
        currentStatValueToMergeInto["value"] =
            int.parse(currentStatValueToMergeInto["value"].toString()) +
                int.parse(valueToMerge["value"].toString());

        break;

      // {"value": 12, "otherValue": 2}
      case CharacterStatValueType.intWithCalculatedValue:
        currentStatValueToMergeInto["value"] =
            int.parse(currentStatValueToMergeInto["value"].toString()) +
                int.parse(valueToMerge["value"].toString());

        currentStatValueToMergeInto["otherValue"] =
            int.parse(currentStatValueToMergeInto["otherValue"].toString()) +
                int.parse(valueToMerge["otherValue"].toString());

        break;

      // {"value": 12, "maxValue": 17}
      case CharacterStatValueType.intWithMaxValue:
        currentStatValueToMergeInto["value"] =
            int.parse(currentStatValueToMergeInto["value"].toString()) +
                int.parse(valueToMerge["value"].toString());

        currentStatValueToMergeInto["maxValue"] =
            int.parse(currentStatValueToMergeInto["maxValue"].toString()) +
                int.parse(valueToMerge["maxValue"].toString());

        break;

      // {"values":[{"uuid":"theCorrespondingUuidOfTheCompanionCharacter"}]}
      case CharacterStatValueType.companionSelector:
        currentStatValueToMergeInto["values"] = [
          ...currentStatValueToMergeInto["values"],
          ...valueToMerge["values"]
        ]
            .distinct<String>(
                by: (e) => (e as Map<String, dynamic>)["uuid"] as String)
            .toList();
        break;

      // {"level": 12, "values":[{"uuid":"5f515750-0456-41e7-a1ee-97acb30c25c0", "value": "asdf"}]}
      case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
        currentStatValueToMergeInto["level"] =
            int.parse(currentStatValueToMergeInto["level"].toString()) +
                int.parse(valueToMerge["level"]);

        // merge "values" array by matching uuids and joining the values
        var valuesToMerge = valueToMerge["values"];
        for (var valueToMerge in valuesToMerge) {
          var matchingValue = currentStatValueToMergeInto["values"]
              .firstWhereOrNull(
                  (element) => element["uuid"] == valueToMerge["uuid"]);
          if (matchingValue != null) {
            matchingValue["value"] =
                matchingValue["value"] + ", " + valueToMerge["value"];
          } else {
            currentStatValueToMergeInto["values"].add(valueToMerge);
          }
        }
        break;

      // {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12,}]}
      case CharacterStatValueType.listOfIntsWithIcons:
        // merge "values" array by matching uuids and joining the values
        var valuesToMerge = valueToMerge["values"];
        for (var valueToMerge in valuesToMerge) {
          var matchingValue =
              (currentStatValueToMergeInto["values"] as List<dynamic>)
                  .map((e) => e as Map<String, dynamic>)
                  .firstWhereOrNull(
                      (element) => element["uuid"] == valueToMerge["uuid"]);
          if (matchingValue != null) {
            matchingValue["value"] =
                int.parse(matchingValue["value"].toString()) +
                    int.parse(valueToMerge["value"].toString());
          } else {
            currentStatValueToMergeInto["values"].add(valueToMerge);
          }
        }
        break;

      // {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
      case CharacterStatValueType.listOfIntWithCalculatedValues:
        // merge "values" array by matching uuids and adding value and othervalue respectively
        var valuesToMerge = valueToMerge["values"];
        for (var valueToMerge in valuesToMerge) {
          var matchingValue = currentStatValueToMergeInto["values"]
              .firstWhereOrNull(
                  (element) => element["uuid"] == valueToMerge["uuid"]);
          if (matchingValue != null) {
            matchingValue["value"] =
                int.parse(matchingValue["value"].toString()) +
                    int.parse(valueToMerge["value"].toString());

            matchingValue["otherValue"] =
                int.parse(matchingValue["otherValue"].toString()) +
                    int.parse(valueToMerge["otherValue"].toString());
          } else {
            currentStatValueToMergeInto["values"].add(valueToMerge);
          }
        }
        break;

      // {"values": ["3a7fd649-2d76-4a93-8513-d5a8e8249b40", "3a7fd649-2d76-4a93-8513-d5a8e8249b42"]}
      case CharacterStatValueType.multiselect:
        currentStatValueToMergeInto["values"] = [
          ...currentStatValueToMergeInto["values"],
          ...valueToMerge["values"]
        ];
        break;

      case CharacterStatValueType.singleImage:
        // TODO maybe show an info message to the user (or create a new image by merging the two images)
        // currently, we dont merge images and just keep the first one
        break;

      // never merge...
      case CharacterStatValueType.transformIntoAlternateFormBtn:
        break;
    }

    currentStatToMerge = currentStatToMerge.copyWith(
        serializedValue: jsonEncode(currentStatValueToMergeInto));
    return currentStatToMerge;
  }

  Navbar getNavbar(BuildContext context) {
    return Navbar(
      backInsteadOfCloseIcon: false,
      closeFunction: () {
        navigatorKey.currentState!.pop(null);
      },
      menuOpen: null,
      useTopSafePadding: false,
      titleWidget: Text(
        "Verwandlung auswählen", // TODO localize
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: textColor, fontSize: 24),
      ),
    );
  }
}
