import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/newdesign/bordered_image.dart';
import 'package:rpg_table_helper/components/newdesign/progress_indicator_for_character_screen.dart';
import 'package:rpg_table_helper/components/static_grid.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/icons_helper.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:shadow_widget/shadow_widget.dart';

int numberOfVariantsForValueTypes(CharacterStatValueType valueType) {
  switch (valueType) {
    case CharacterStatValueType.singleImage:
    case CharacterStatValueType.multiLineText:
    case CharacterStatValueType.singleLineText:
    case CharacterStatValueType.int:
    case CharacterStatValueType.listOfIntWithCalculatedValues:
    case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
      return 1;
    case CharacterStatValueType.multiselect:
    case CharacterStatValueType.intWithCalculatedValue:
    case CharacterStatValueType.listOfIntsWithIcons:
      return 2;
    case CharacterStatValueType.intWithMaxValue:
      return 3;
  }
}

Widget getPlayerVisualizationWidget({
  required BuildContext context,
  required CharacterStatDefinition statConfiguration,
  required RpgCharacterStatValue characterValue,
  required String characterName,
  bool useNewDesign = false,
}) {
  switch (statConfiguration.valueType) {
    case CharacterStatValueType.multiLineText:
    case CharacterStatValueType.singleLineText:
      // characterValue.serializedValue = {"value": "asdf"}
      var parsedValue = jsonDecode(characterValue.serializedValue);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statConfiguration.name,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: useNewDesign == true ? darkTextColor : Colors.white,
                fontSize: 20),
          ),
          SizedBox(
            height: 10,
          ),
          CustomMarkdownBody(
            isNewDesign: useNewDesign,
            text: parsedValue["value"].toString(),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );

    case CharacterStatValueType.singleImage:
      //  {"imageUrl": "someUrl", "value": "some text"}
      var parsedValue = jsonDecode(characterValue.serializedValue);
      var imageUrl = parsedValue["imageUrl"];

      var fullImageUrl = imageUrl == null
          ? "assets/images/charactercard_placeholder.png"
          : (imageUrl!.startsWith("assets")
                  ? imageUrl
                  : (apiBaseUrl +
                      (imageUrl!.startsWith("/")
                          ? imageUrl!.substring(1)
                          : imageUrl!))) ??
              "assets/images/charactercard_placeholder.png";

      return BorderedImage(
        backgroundColor: bgColor,
        lightColor: darkColor,
        greyscale: false,
        isLoadingNewImage: false,
        withoutPadding: true,
        imageUrl: fullImageUrl,
      );

    case CharacterStatValueType.int:
      // characterValue.serializedValue = {"value": 1}
      var parsedValue = jsonDecode(characterValue.serializedValue);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            parsedValue["value"].toString(),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: useNewDesign == true ? darkTextColor : Colors.white,
                fontSize: 20),
          ),
          SizedBox(
            height: 0,
          ),
          Text(
            statConfiguration.name,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: useNewDesign == true ? darkTextColor : Colors.white,
                fontSize: 16),
          ),
        ],
      );
    case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
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

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShadowWidget(
            offset: Offset(-4, 4),
            blurRadius: 5,
            child: Container(
              height: 150,
              width: 150,
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
                        .copyWith(color: textColor, fontSize: 32),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "LVL", // TODO localize?
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: textColor, fontSize: 32),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            height: 150,
            width: 200,
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
                      "Name:",
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
                                      fontSize: strKVP.key % 2 == 0 ? 16 : 24),
                              maxFontSize: strKVP.key % 2 == 0 ? 16 : 24,
                              maxLines: 1,
                              minFontSize: 10,
                            ))
                        .toList()),
              ],
            ),
          ),
        ],
      );

    case CharacterStatValueType.listOfIntWithCalculatedValues:
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

    case CharacterStatValueType.listOfIntsWithIcons:
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
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 18,
                                      color: darkTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        if (characterValue.variant == 1)
                          Text(
                            "${t.value}",
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
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
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
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

    case CharacterStatValueType.intWithMaxValue:
      // characterValue.serializedValue = {"value": 1, "maxValue": 17}
      var parsedValue = jsonDecode(characterValue.serializedValue);

      if (characterValue.variant == 1) {
        var value = int.tryParse(parsedValue["value"].toString()) ?? 0;
        var maxValue = int.tryParse(parsedValue["maxValue"].toString()) ?? 1;
        return ProgressIndicatorForCharacterScreen(
          padding: 60.0,
          progressPercentage:
              value == maxValue ? 1.0 : value.toDouble() / maxValue.toDouble(),
          value: value,
          maxValue: maxValue,
          title: statConfiguration.name,
        );
      } else if (characterValue.variant == 2) {
        var value = int.tryParse(parsedValue["value"].toString()) ?? 0;
        var maxValue = int.tryParse(parsedValue["maxValue"].toString()) ?? 1;
        return PentagonWithLabel(
            value: value, otherValue: maxValue, label: statConfiguration.name);
      } else {
        // variant is null or 0
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${parsedValue["value"]} / ${parsedValue["maxValue"]}",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: useNewDesign == true ? darkTextColor : Colors.white,
                  fontSize: 20),
            ),
            SizedBox(
              height: 0,
            ),
            Text(
              statConfiguration.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: useNewDesign == true ? darkTextColor : Colors.white,
                  fontSize: 16),
            ),
          ],
        );
      }

    case CharacterStatValueType.intWithCalculatedValue:
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
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: useNewDesign == true ? darkTextColor : Colors.white,
                  fontSize: 20),
            ),
            Text(
              statConfiguration.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: useNewDesign == true ? darkTextColor : Colors.white,
                  fontSize: 16),
            ),
            Text(
              "${parsedValue["value"]}",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: useNewDesign == true
                      ? const Color.fromARGB(255, 135, 127, 118)
                      : const Color.fromARGB(255, 134, 134, 134),
                  fontSize: 20),
            ),
          ],
        );
      }

    case CharacterStatValueType.multiselect:
      // statConfiguration.jsonSerializedAdditionalData = [{"uuid":"c4c08d74-effb-4457-9c3a-d60b611f6986","label": "asdf", "description": "asdf"}]
      // characterValue.serializedValue = {"values": ["c4c08d74-effb-4457-9c3a-d60b611f6986"]}
      List<String> parsedValue =
          (jsonDecode(characterValue.serializedValue)["values"]
                  as List<dynamic>)
              .map((e) => e as String)
              .toList();

      List<dynamic> statConfigValues = jsonDecode(statConfiguration
              .jsonSerializedAdditionalData
              ?.replaceAll("},]", "}]")
              .replaceAll('"}]"}]', '"}]') ??
          "[]");

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
          .map((pv) => (parsedValue.firstWhereOrNull((es) => es == pv.$1), pv))
          .where((pv) => isVariantShowingAllOptions || pv.$1 != null)
          .sortedBy((pv) => pv.$2.$2);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statConfiguration.name,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: useNewDesign == true ? darkTextColor : Colors.white,
                  fontSize: 24,
                ),
          ),
          SizedBox(
            height: 10,
          ),
          if (valueToConfigMapped.isEmpty)
            Text(
              "- Nichts ausgewählt -",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: const Color.fromARGB(255, 193, 193, 193),
                  fontSize: 16),
            ),
          ...valueToConfigMapped.map(
            (e) => Builder(builder: (context) {
              var isSelected = e.$1 != null;
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
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        e.$2.$2,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: useNewDesign == true
                                ? darkTextColor
                                : Colors.white,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  if (e.$2.$3.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0, bottom: 20),
                      child: Text(
                        e.$2.$3,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: useNewDesign == true
                                ? darkTextColor
                                : Colors.white,
                            fontSize: 16),
                      ),
                    ),
                ],
              );
            }),
          )
        ],
      );

    default:
      return Container(
        height: 50,
        width: 50,
        color: Colors.red,
      );
  }
}

class PentagonWithLabel extends StatelessWidget {
  const PentagonWithLabel({
    super.key,
    required this.value,
    required this.otherValue,
    required this.label,
  });

  final int value;
  final int otherValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          ShadowWidget(
            offset: Offset(-4, 4),
            blurRadius: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pentagon Shape
                ClipPath(
                  clipper: PentagonClipper(),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: darkColor,
                  ),
                ),
                // Text inside the pentagon
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      otherValue.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          AutoSizeText(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(fontSize: 14, color: darkTextColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            maxFontSize: 14,
            minFontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class PentagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    path.moveTo(width * 0.5, 0); // Top point
    path.lineTo(width, height * 0.4); // Top-right corner
    path.lineTo(width * 0.8, height); // Bottom-right corner
    path.lineTo(width * 0.2, height); // Bottom-left corner
    path.lineTo(0, height * 0.4); // Top-left corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
