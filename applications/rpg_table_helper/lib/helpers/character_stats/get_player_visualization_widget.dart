import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/pentagon_with_label.dart';
import 'package:quest_keeper/components/progress_indicator_for_character_screen.dart';
import 'package:quest_keeper/components/static_grid.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';

int numberOfVariantsForValueTypes(CharacterStatValueType valueType) {
  switch (valueType) {
    case CharacterStatValueType.singleImage:
    case CharacterStatValueType.multiLineText:
    case CharacterStatValueType.singleLineText:
    case CharacterStatValueType.int:
    case CharacterStatValueType.companionSelector:
    case CharacterStatValueType.transformIntoAlternateFormBtn:
    case CharacterStatValueType.listOfIntWithCalculatedValues:
    case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
      return 1;
    case CharacterStatValueType.multiselect:
    case CharacterStatValueType.intWithCalculatedValue:
    case CharacterStatValueType.listOfIntsWithIcons:
      return 2;
    case CharacterStatValueType.intWithMaxValue:
      return 5;
  }
}

Widget getPlayerVisualizationWidget({
  required BuildContext context,
  required CharacterStatDefinition statConfiguration,
  required RpgCharacterStatValue characterValue,
  required String characterName,
  required void Function(String newSerializedValue) onNewStatValue,
  required RpgCharacterConfiguration? characterToRenderStatFor,
}) {
  switch (statConfiguration.valueType) {
    case CharacterStatValueType.multiLineText:
    case CharacterStatValueType.singleLineText:
      return renderTextStat(
          onNewStatValue, statConfiguration, context, characterValue);

    case CharacterStatValueType.singleImage:
      return renderImageStat(
          onNewStatValue, statConfiguration, context, characterValue);

    case CharacterStatValueType.int:
      return renderIntStat(
          onNewStatValue, characterValue, context, statConfiguration);
    case CharacterStatValueType.companionSelector:
      return renderCompanionSelector(onNewStatValue, characterValue, context,
          characterToRenderStatFor, statConfiguration);
    case CharacterStatValueType.transformIntoAlternateFormBtn:
      return renderTransformIntoAlternateFormBtn(onNewStatValue, characterValue,
          context, characterToRenderStatFor, statConfiguration);

    case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
      return renderCharacterNameWithLevelAndAdditionalDetailsStat(
          onNewStatValue,
          characterValue,
          context,
          statConfiguration,
          characterName);

    case CharacterStatValueType.listOfIntWithCalculatedValues:
      return renderListOfIntWithCalculatedValuesStat(onNewStatValue,
          characterValue, context, statConfiguration, characterName);

    case CharacterStatValueType.listOfIntsWithIcons:
      return renderListOfIntsWithIconsStat(onNewStatValue, characterValue,
          context, statConfiguration, characterName);

    case CharacterStatValueType.intWithMaxValue:
      return renderIntWithMaxValueStat(onNewStatValue, characterValue, context,
          statConfiguration, characterName);

    case CharacterStatValueType.intWithCalculatedValue:
      return renderIntWithCalculatedValueStat(onNewStatValue, characterValue,
          context, statConfiguration, characterName);

    case CharacterStatValueType.multiselect:
      return renderMultiselectStat(onNewStatValue, characterValue, context,
          statConfiguration, characterName);
    default:
      return Container(
        height: 50,
        width: 50,
        color: Colors.red,
      );
  }
}

Widget renderCompanionSelector(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    RpgCharacterConfiguration? characterToRenderStatFor,
    CharacterStatDefinition statConfiguration) {
  List<String> selectedCompanionIds =
      (jsonDecode(characterValue.serializedValue)["values"] as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>)["uuid"] as String)
          .toList();

  List<
      ({
        String characterName,
        String uuid,
        String? imageUrl,
        RpgAlternateCharacterConfiguration companionConfig
      })> companionDetailsToRender = [];
  for (var selectedCompanionId in selectedCompanionIds) {
    var companionOfCharacter =
        (characterToRenderStatFor?.companionCharacters ?? [])
            .firstWhereOrNull((c) => c.uuid == selectedCompanionId);
    if (companionOfCharacter == null) continue;

    // TODO search for image (still missing access to rpgconfig here...)
    // TODO use this here: RenderCharactersAsCards.renderCharactersAsCharacterCard(context, charactersToRender, rpgConfig)

    companionDetailsToRender.add((
      characterName: companionOfCharacter.characterName,
      uuid: companionOfCharacter.uuid,
      imageUrl: null,
      companionConfig: companionOfCharacter
    ));
  }
  companionDetailsToRender =
      companionDetailsToRender.sortedBy((k) => k.characterName);

  return Column(
    children: [
      getIconForIdentifier(
        name: "paw",
        color: darkColor,
        size: 50,
      ).$2,
      SizedBox(
        height: 10,
      ),
      Wrap(
        children: [
          ...companionDetailsToRender.map((t) => Padding(
                padding: EdgeInsets.all(5),
                child: CustomButton(
                    label: t.characterName,
                    onPressed: () {
                      // open companion page
                      navigatorKey.currentState!.pushNamed(
                          PlayerPageScreen.route,
                          arguments: PlayerPageScreenRouteSettings(
                            disableEdit: false,
                            showMoney: false,
                            characterConfigurationOverride: t.companionConfig,
                            showInventory: false,
                            showLore: false,
                            showRecipes: false,
                          ));
                    }),
              )),
        ],
      )
    ],
  );
}

Widget renderTransformIntoAlternateFormBtn(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    RpgCharacterConfiguration? characterToRenderStatFor,
    CharacterStatDefinition statConfiguration) {
  // List<String> selectedCompanionIds =
  //     (jsonDecode(characterValue.serializedValue)["values"] as List<dynamic>)
  //         .map((e) => (e as Map<String, dynamic>)["uuid"] as String)
  //         .toList();
//
  // List<
  //     ({
  //       String characterName,
  //       String uuid,
  //       String? imageUrl,
  //       RpgAlternateCharacterConfiguration companionConfig
  //     })> companionDetailsToRender = [];
  // for (var selectedCompanionId in selectedCompanionIds) {
  //   var companionOfCharacter =
  //       (characterToRenderStatFor?.companionCharacters ?? [])
  //           .firstWhereOrNull((c) => c.uuid == selectedCompanionId);
  //   if (companionOfCharacter == null) continue;
  //   // TODO search for image (still missing access to rpgconfig here...)
  //   // TODO use this here: RenderCharactersAsCards.renderCharactersAsCharacterCard(context, charactersToRender, rpgConfig)
  //   companionDetailsToRender.add((
  //     characterName: companionOfCharacter.characterName,
  //     uuid: companionOfCharacter.uuid,
  //     imageUrl: null,
  //     companionConfig: companionOfCharacter
  //   ));
  // }
  // companionDetailsToRender =
  //     companionDetailsToRender.sortedBy((k) => k.characterName);

  return Column(
    children: [
      getIconForIdentifier(
        name: "magic-wand-svgrepo-com",
        color: darkColor,
        size: 50,
      ).$2,
      SizedBox(
        height: 10,
      ),
      Wrap(
        children: [
          Padding(
            padding: EdgeInsets.all(5),
            child: CustomButton(
                label: S.of(context).tranformToAlternateForm,
                onPressed: () {
                  // TODO make me
                  // open modal, select alternate form components and save
                  // now open saved alternate form

                  return;

                  // open companion page
                  navigatorKey.currentState!.pushNamed(PlayerPageScreen.route,
                      arguments: PlayerPageScreenRouteSettings(
                        disableEdit: false,
                        showMoney: false,
                        characterConfigurationOverride:
                            characterToRenderStatFor!.alternateForm!,
                        showInventory: false,
                        showLore: false,
                        showRecipes: false,
                      ));
                }),
          ),
        ],
      )
    ],
  );
}

Widget renderMultiselectStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration,
    String characterName) {
  // statConfiguration.jsonSerializedAdditionalData = {"options:":[{"uuid": "3a7fd649-2d76-4a93-8513-d5a8e8249b40", "label": "", "description": ""}], "multiselectIsAllowedToBeSelectedMultipleTimes":false}
  // characterValue.serializedValue = {"values": ["c4c08d74-effb-4457-9c3a-d60b611f6986"]}
  List<String> parsedValue =
      (jsonDecode(characterValue.serializedValue)["values"] as List<dynamic>)
          .map((e) => e as String)
          .toList();

  var multiselectIsAllowedToBeSelectedMultipleTimes = false;
  List<dynamic> statConfigValues = [];

  // TODO remove migration
  if (statConfiguration.jsonSerializedAdditionalData?.isNotEmpty == true &&
      statConfiguration.jsonSerializedAdditionalData!.startsWith("[")) {
    statConfigValues = jsonDecode(statConfiguration.jsonSerializedAdditionalData
            ?.replaceAll("},]", "}]")
            .replaceAll('"}]"}]', '"}]') ??
        "[]");
  } else {
    Map<String, dynamic> json = jsonDecode(statConfiguration
            .jsonSerializedAdditionalData ??
        '{"options:":[], "multiselectIsAllowedToBeSelectedMultipleTimes":false}');

    multiselectIsAllowedToBeSelectedMultipleTimes =
        json.containsKey("multiselectIsAllowedToBeSelectedMultipleTimes")
            ? json["multiselectIsAllowedToBeSelectedMultipleTimes"] as bool
            : false;

    statConfigValues = json["options"] as List<dynamic>;
  }

  var config = statConfigValues
      .map(
        (e) => (
          e["uuid"] as String,
          e["label"] as String,
          e["description"] as String
        ),
      )
      .toList();

  var isVariantShowingAllOptions = characterValue.variant == 1;

  var valueToConfigMapped = config
      .map((pv) => (parsedValue.where((es) => es == pv.$1).length, pv))
      .where((pv) => isVariantShowingAllOptions || pv.$1 != 0)
      .sortedBy((pv) => pv.$2.$2);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        statConfiguration.name,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: darkTextColor,
              fontSize: 24,
            ),
      ),
      SizedBox(
        height: 10,
      ),
      if (valueToConfigMapped.isEmpty)
        Text(
          S.of(context).nothingSelected,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: const Color.fromARGB(255, 193, 193, 193), fontSize: 16),
        ),
      ...valueToConfigMapped.map(
        (e) => Builder(builder: (context) {
          var isSelected = e.$1 != 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? darkColor : bgColor,
                        border: Border.all(color: darkColor)),
                  ),
                  if (multiselectIsAllowedToBeSelectedMultipleTimes)
                    ...List.filled(
                      max(0, e.$1 - 1),
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: darkColor,
                            border: Border.all(color: darkColor)),
                      ),
                    ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    e.$2.$2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: darkTextColor, fontSize: 16),
                  ),
                ],
              ),
              if (e.$2.$3.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 20),
                  child: Text(
                    e.$2.$3,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: darkTextColor, fontSize: 16),
                  ),
                ),
            ],
          );
        }),
      )
    ],
  );
}

Widget renderIntWithCalculatedValueStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration,
    String characterName) {
  // characterValue.serializedValue = {"value": 12, "otherValue": 2}
  var parsedValue = jsonDecode(characterValue.serializedValue);

  if (characterValue.variant == 1) {
    var value = int.tryParse(parsedValue["value"].toString()) ?? 0;
    var maxValue = int.tryParse(parsedValue["otherValue"].toString()) ?? 1;
    return PentagonWithLabel(
        value: value, otherValue: maxValue, label: statConfiguration.name);
  } else {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${parsedValue["otherValue"]}",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: darkTextColor, fontSize: 20),
        ),
        Text(
          statConfiguration.name,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: darkTextColor, fontSize: 16),
        ),
        Text(
          "${parsedValue["value"]}",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: const Color.fromARGB(255, 135, 127, 118), fontSize: 20),
        ),
      ],
    );
  }
}

Widget renderIntWithMaxValueStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration,
    String characterName) {
  // characterValue.serializedValue = {"value": 1, "maxValue": 17}
  var parsedValue = jsonDecode(characterValue.serializedValue);
  var value = int.tryParse(parsedValue["value"].toString()) ?? 0;
  var maxValue = int.tryParse(parsedValue["maxValue"].toString()) ?? 1;

  onValueChanged(int newValue) {
    parsedValue["value"] = newValue;
    var serializedValue = jsonEncode(parsedValue);
    onNewStatValue(serializedValue);
  }

  switch (characterValue.variant) {
    case 1:
    case 3:
      var fillPercentage =
          value == maxValue ? 1.0 : value.toDouble() / maxValue.toDouble();

      var percentageBasedColor = fillPercentage > 0.5
          ? lightGreen
          : (fillPercentage > 0.15 ? lightYellow : lightRed);

      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ProgressIndicatorForCharacterScreen(
            progressPercentage: fillPercentage,
            value: value,
            maxValue: maxValue,
            title: statConfiguration.name,
            color: characterValue.variant == 1
                ? accentColor
                : percentageBasedColor,
          ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            Row(
              children: [
                Spacer(),
                CustomButton(
                  isSubbutton: true,
                  variant: CustomButtonVariant.DarkButton,
                  onPressed: value <= 0
                      ? null
                      : () {
                          onValueChanged(max(0, value - 1));
                        },
                  icon: CustomFaIcon(
                    icon: FontAwesomeIcons.minus,
                    size: iconSizeInlineButtons,
                    color: textColor,
                  ),
                ),
                Spacer(
                  flex: 6,
                ),
                CustomButton(
                  isSubbutton: true,
                  variant: CustomButtonVariant.DarkButton,
                  onPressed: maxValue == value
                      ? null
                      : () {
                          onValueChanged(min(value + 1, maxValue));
                        },
                  icon: CustomFaIcon(
                    icon: FontAwesomeIcons.plus,
                    size: iconSizeInlineButtons,
                    color: textColor,
                  ),
                ),
                Spacer(),
              ],
            ),
        ],
      );
    case 2:
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: CustomButton(
                isSubbutton: true,
                variant: CustomButtonVariant.DarkButton,
                onPressed: value <= 0
                    ? null
                    : () {
                        onValueChanged(max(0, value - 1));
                      },
                icon: CustomFaIcon(
                  icon: FontAwesomeIcons.minus,
                  size: iconSizeInlineButtons,
                  color: textColor,
                ),
              ),
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 20,
            ),
          PentagonWithLabel(
              value: value,
              otherValue: maxValue,
              label: statConfiguration.name),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 20,
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: CustomButton(
                isSubbutton: true,
                variant: CustomButtonVariant.DarkButton,
                onPressed: maxValue == value
                    ? null
                    : () {
                        onValueChanged(min(value + 1, maxValue));
                      },
                icon: CustomFaIcon(
                  icon: FontAwesomeIcons.plus,
                  size: iconSizeInlineButtons,
                  color: textColor,
                ),
              ),
            ),
        ],
      );
    case 4:
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            CustomButton(
              isSubbutton: true,
              variant: CustomButtonVariant.FlatButton,
              onPressed: value <= 0
                  ? null
                  : () {
                      onValueChanged(max(0, value - 1));
                    },
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.minus,
                size: iconSizeInlineButtons,
                color: darkColor,
              ),
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 10,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  alignment: WrapAlignment.center,
                  children: [
                    ...List.generate(
                      maxValue,
                      (index) => Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < value ? darkColor : bgColor,
                            border: Border.all(color: darkColor)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  statConfiguration.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: darkTextColor, fontSize: 16),
                ),
              ],
            ),
          ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 10,
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            CustomButton(
              isSubbutton: true,
              variant: CustomButtonVariant.FlatButton,
              onPressed: maxValue == value
                  ? null
                  : () {
                      onValueChanged(min(value + 1, maxValue));
                    },
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.plus,
                size: iconSizeInlineButtons,
                color: darkColor,
              ),
            ),
        ],
      );
    default:
      // variant is null or 0
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            CustomButton(
              isSubbutton: true,
              variant: CustomButtonVariant.FlatButton,
              onPressed: value <= 0
                  ? null
                  : () {
                      onValueChanged(max(0, value - 1));
                    },
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.minus,
                size: iconSizeInlineButtons,
                color: darkColor,
              ),
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 20,
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$value / $maxValue",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: darkTextColor, fontSize: 20),
              ),
              Text(
                statConfiguration.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: darkTextColor, fontSize: 16),
              ),
            ],
          ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 20,
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            CustomButton(
              isSubbutton: true,
              variant: CustomButtonVariant.FlatButton,
              onPressed: maxValue == value
                  ? null
                  : () {
                      onValueChanged(min(value + 1, maxValue));
                    },
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.plus,
                size: iconSizeInlineButtons,
                color: darkColor,
              ),
            ),
        ],
      );
  }
}

Widget renderListOfIntsWithIconsStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration,
    String characterName) {
  // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
  // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
  var parsedValue = ((jsonDecode(characterValue.serializedValue)
          as Map<String, dynamic>)["values"] as List<dynamic>)
      .map((t) => t as Map<String, dynamic>)
      .toList();

  var statConfigLabels =
      (jsonDecode(statConfiguration.jsonSerializedAdditionalData!)["values"]
              as List<dynamic>)
          .map((t) => t as Map<String, dynamic>)
          .toList();

  var filledValues = statConfigLabels
      .map(
        (e) {
          var parsedMatchingValue = parsedValue.singleWhereOrNull(
            (element) => element["uuid"] == e["uuid"],
          );

          return (
            label: e["label"] as String,
            iconName: e["iconName"] as String,
            value: parsedMatchingValue?["value"] as int? ?? 0,
          );
        },
      )
      .sortedBy((e) => e.label)
      .toList();

  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    runSpacing: 10,
    children: filledValues
        .map(
          (t) => SizedBox(
            width: characterValue.variant == 0 ? 100 : 80,
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getIconForIdentifier(
                            name: t.iconName, color: darkColor, size: 32)
                        .$2,
                    SizedBox(
                      height: 5,
                    ),
                    if (characterValue.variant == 0)
                      Text(
                        "${t.label}: ${t.value}",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 18,
                              color: darkTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    if (characterValue.variant == 1)
                      Text(
                        "${t.value}",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 18,
                              color: darkTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    if (characterValue.variant == 1)
                      SizedBox(
                        height: 1,
                      ),
                    if (characterValue.variant == 1)
                      Text(
                        t.label,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 12,
                              color: darkTextColor,
                            ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

Widget renderListOfIntWithCalculatedValuesStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration,
    String characterName) {
  // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
  // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
  var parsedValue = ((jsonDecode(characterValue.serializedValue)
          as Map<String, dynamic>)["values"] as List<dynamic>)
      .map((t) => t as Map<String, dynamic>)
      .toList();

  var statConfigLabels =
      (jsonDecode(statConfiguration.jsonSerializedAdditionalData!)["values"]
              as List<dynamic>)
          .map((t) => t as Map<String, dynamic>)
          .toList();

  var filledValues = statConfigLabels
      .map(
        (e) {
          var parsedMatchingValue = parsedValue.singleWhereOrNull(
            (element) => element["uuid"] == e["uuid"],
          );

          return (
            label: e["label"] as String,
            value: parsedMatchingValue?["value"] as int? ?? 0,
            otherValue: parsedMatchingValue?["otherValue"] as int? ?? 0
          );
        },
      )
      .sortedBy((e) => e.label)
      .toList();

  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    runSpacing: 10,
    children: filledValues
        .map(
          (t) => PentagonWithLabel(
              value: t.value, otherValue: t.otherValue, label: t.label),
        )
        .toList(),
  );
}

Widget renderCharacterNameWithLevelAndAdditionalDetailsStat(
  void Function(String newSerializedValue) onNewStatValue,
  RpgCharacterStatValue characterValue,
  BuildContext context,
  CharacterStatDefinition statConfiguration,
  String characterName,
) {
// => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "Volk"}]}
  // => characterValue.serializedValue == {"level": 2,"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": "Zwerg"}]}
  var parsedCharacterValueMap =
      jsonDecode(characterValue.serializedValue) as Map<String, dynamic>;
  var parsedValue = (parsedCharacterValueMap["values"] as List<dynamic>)
      .map((t) => t as Map<String, dynamic>)
      .toList();

  var statConfigLabels =
      (jsonDecode(statConfiguration.jsonSerializedAdditionalData!)["values"]
              as List<dynamic>)
          .map((t) => t as Map<String, dynamic>)
          .toList();

  var characterLevel = parsedCharacterValueMap["level"] is String
      ? int.parse(parsedCharacterValueMap["level"])
      : parsedCharacterValueMap["level"];

  var filledValues = statConfigLabels
      .map(
        (e) {
          var parsedMatchingValue = parsedValue.singleWhereOrNull(
            (element) => element["uuid"] == e["uuid"],
          );

          return (
            label: e["label"] as String,
            value: parsedMatchingValue?["value"].toString() ?? "",
          );
        },
      )
      .sortedBy((e) => e.label)
      .toList();

  return LayoutBuilder(builder: (context, constraints) {
    var maxWidth = min(140.0 + 10 + 200, constraints.maxWidth);

    var firstExpandedFlex = (140 / maxWidth) * 100;
    var secondExpandedFlex = (200 / maxWidth) * 100;

    return SizedBox(
      width: maxWidth,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: firstExpandedFlex.round(),
            child: CustomShadowWidget(
              child: LayoutBuilder(builder: (context, constrin) {
                return Container(
                  width: constrin.maxWidth,
                  height: constrin.maxWidth,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: darkColor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        characterLevel.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: textColor, fontSize: 28),
                      ),
                      Text(
                        S.of(context).levelAbbr,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: textColor, fontSize: 28),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: secondExpandedFlex.round(),
            child: Container(
              height: 150,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StaticGrid(
                      colGap: 10,
                      rowGap: 4,
                      expandedFlexValues: [1, 2],
                      columnCrossAxisAlignment: CrossAxisAlignment.start,
                      columnMainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        S.of(context).characterNameLabel,
                        characterName,
                        ...filledValues
                            .map((t) => ["${t.label}:", t.value])
                            .expand((i) => i)
                      ]
                          .asMap()
                          .entries
                          .map((strKVP) => AutoSizeText(
                                strKVP.value,
                                textAlign: strKVP.key % 2 == 0
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: darkTextColor,
                                        fontSize:
                                            strKVP.key % 2 == 0 ? 16 : 24),
                                maxFontSize: strKVP.key % 2 == 0 ? 16 : 24,
                                maxLines: 1,
                                minFontSize: 10,
                              ))
                          .toList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}

Column renderIntStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration) {
  // characterValue.serializedValue = {"value": 1}
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        jsonDecode(characterValue.serializedValue)["value"].toString(),
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: darkTextColor, fontSize: 20),
      ),
      Text(
        statConfiguration.name,
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: darkTextColor, fontSize: 16),
      ),
    ],
  );
}

Widget renderImageStat(
    void Function(String newSerializedValue) onNewStatValue,
    CharacterStatDefinition statConfiguration,
    BuildContext context,
    RpgCharacterStatValue characterValue) {
  //  {"imageUrl": "someUrl", "value": "some text"}
  var parsedValue = jsonDecode(characterValue.serializedValue);
  var imageUrl = parsedValue["imageUrl"];

  var fullImageUrl = imageUrl == null
      ? "assets/images/charactercard_placeholder.png"
      : (imageUrl!.startsWith("assets")
              ? imageUrl
              : (apiBaseUrl +
                  (imageUrl!.startsWith("/")
                      ? (imageUrl!.length > 1 ? imageUrl!.substring(1) : '')
                      : imageUrl!))) ??
          "assets/images/charactercard_placeholder.png";

  return BorderedImage(
    backgroundColor: bgColor,
    lightColor: darkColor,
    isGreyscale: false,
    isLoading: false,
    noPadding: true,
    imageUrl: fullImageUrl,
  );
}

Column renderTextStat(
    void Function(String newSerializedValue) onNewStatValue,
    CharacterStatDefinition statConfiguration,
    BuildContext context,
    RpgCharacterStatValue characterValue) {
  // characterValue.serializedValue = {"value": "asdf"}
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (characterValue.hideLabelOfStat != true)
        Text(
          statConfiguration.name,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: darkTextColor, fontSize: 20),
        ),
      if (characterValue.hideLabelOfStat != true)
        SizedBox(
          height: 10,
        ),
      CustomMarkdownBody(
        text: jsonDecode(characterValue.serializedValue)["value"].toString(),
      ),
      SizedBox(
        height: 10,
      ),
    ],
  );
}
