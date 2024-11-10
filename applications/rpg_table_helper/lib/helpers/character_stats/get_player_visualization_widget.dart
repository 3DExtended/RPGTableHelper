import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/newdesign/bordered_image.dart';
import 'package:rpg_table_helper/components/newdesign/progress_indicator_for_character_screen.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:shadow_widget/shadow_widget.dart';

int numberOfVariantsForValueTypes(CharacterStatValueType valueType) {
  switch (valueType) {
    case CharacterStatValueType.singleImage:
    case CharacterStatValueType.multiLineText:
    case CharacterStatValueType.singleLineText:
    case CharacterStatValueType.int:
    case CharacterStatValueType.intWithCalculatedValue:
    case CharacterStatValueType.multiselect:
    case CharacterStatValueType.listOfIntWithCalculatedValues:
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

      var filledValues = statConfigLabels.map(
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
      ).toList();

      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: filledValues
            .map(
              (t) => SizedBox(
                width: 120,
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
                              width: 100,
                              height: 100,
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
                                t.value.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                t.otherValue.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontSize: 16,
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
                    Text(
                      t.label,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(fontSize: 16, color: darkTextColor),
                      textAlign: TextAlign.center,
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
        return Builder(builder: (context) {
          var value = int.tryParse(parsedValue["value"].toString()) ?? 0;
          var maxValue = int.tryParse(parsedValue["maxValue"].toString()) ?? 1;

          return ProgressIndicatorForCharacterScreen(
            padding: 20.0,
            progressPercentage: value == maxValue
                ? 1.0
                : value.toDouble() / maxValue.toDouble(),
            value: value,
            maxValue: maxValue,
            title: statConfiguration.name,
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
