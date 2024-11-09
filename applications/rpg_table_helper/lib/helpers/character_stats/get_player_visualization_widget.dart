import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:shadow_widget/shadow_widget.dart';

int numberOfVariantsForValueTypes(CharacterStatValueType valueType) {
  switch (valueType) {
    case CharacterStatValueType.multiLineText:
    case CharacterStatValueType.singleLineText:
    case CharacterStatValueType.int:
    case CharacterStatValueType.intWithCalculatedValue:
    case CharacterStatValueType.multiselect:
      return 1;
    case CharacterStatValueType.intWithMaxValue:
      return 2;
  }
}

Widget getPlayerVisualizationWidget({
  required BuildContext context,
  required CharacterStatDefinition statConfiguration,
  required RpgCharacterStatValue characterValue,
  bool useNewDesign = false,
}) {
  // TODO make me
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
    case CharacterStatValueType.intWithMaxValue:
      // characterValue.serializedValue = {"value": 1, "maxValue": 17}
      var parsedValue = jsonDecode(characterValue.serializedValue);

      if (characterValue.variant == 1) {
        return LayoutBuilder(builder: (context, constraints) {
          var value = int.tryParse(parsedValue["value"].toString()) ?? 0;
          var maxValue = int.tryParse(parsedValue["maxValue"].toString()) ?? 1;
          var progressPercentage = value.toDouble() / maxValue.toDouble();

          var padding = 20.0;
          var width =
              max(350, min(constraints.maxWidth, constraints.maxHeight)) -
                  2.0 * padding;
          var strokeWidth = width * .1;

          var containerWidth = width - 2.5 * strokeWidth;
          var fontSize = containerWidth * 0.2;

          return Container(
            child: ShadowWidget(
              offset: Offset(-4, 4),
              blurRadius: 5,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Circle
                    Container(
                      width: width, // Adjust the size as needed
                      height: width,
                      decoration: BoxDecoration(
                        color: darkColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Circular Progress Indicator for HP
                    SizedBox(
                      width: containerWidth,
                      height: containerWidth,
                      child: CircularProgressIndicator(
                        value: progressPercentage,
                        strokeWidth: strokeWidth,
                        color: accentColor,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    // HP Text (e.g., "9/14")
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$value/$maxValue',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(
                          height: strokeWidth * 0.5,
                        ),
                        Text(
                          'HP',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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

    case CharacterStatValueType.multiselect:
      // statConfiguration.jsonSerializedAdditionalData = [{"uuid":"c4c08d74-effb-4457-9c3a-d60b611f6986","label": "asdf", "description": "asdf"}]
      // characterValue.serializedValue = {"values": ["c4c08d74-effb-4457-9c3a-d60b611f6986"]}
      List<String> parsedValue =
          (jsonDecode(characterValue.serializedValue)["values"]
                  as List<dynamic>)
              .map((e) => e as String)
              .toList();

      List<dynamic> asdf = jsonDecode(statConfiguration
              .jsonSerializedAdditionalData
              ?.replaceAll("},]", "}]")
              .replaceAll('"}]"}]', '"}]') ??
          "[]");

      var config = asdf
          .map(
            (e) => (
              e["uuid"] as String,
              e["label"] as String,
              e["description"] as String
            ),
          )
          .toList();

      var valueToConfigMapped = parsedValue
          .map((pv) => (pv, config.firstWhereOrNull((es) => es.$1 == pv)))
          .where((pv) => pv.$2 != null)
          .sortedBy((pv) => pv.$2!.$2);

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
          if (valueToConfigMapped.isEmpty)
            Text(
              "- Nichts ausgewählt -",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: const Color.fromARGB(255, 193, 193, 193),
                  fontSize: 16),
            ),
          ...valueToConfigMapped.map(
            (e) => Builder(builder: (context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "- ${e.$2!.$2}",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color:
                            useNewDesign == true ? darkTextColor : Colors.white,
                        fontSize: 16),
                  ),
                  if (e.$2!.$3.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 20),
                      child: Text(
                        e.$2!.$3,
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
