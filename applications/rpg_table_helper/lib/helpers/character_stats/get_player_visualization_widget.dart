import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

Widget getPlayerVisualizationWidget({
  required BuildContext context,
  required CharacterStatDefinition statConfiguration,
  required RpgCharacterStatValue characterValue,
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
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.white, fontSize: 24),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            parsedValue["value"],
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.white, fontSize: 16),
          ),
        ],
      );

    case CharacterStatValueType.multiselect:
      // statConfiguration.jsonSerializedAdditionalData = [{"label": "asdf", "description": "asdf"}]
      // characterValue.serializedValue = {"values": ["asdf"]}
      List<String> parsedValue =
          (jsonDecode(characterValue.serializedValue)["values"]
                  as List<dynamic>)
              .map((e) => e as String)
              .toList();

      List<dynamic> asdf =
          jsonDecode(statConfiguration.jsonSerializedAdditionalData ?? "[]");

      var config = asdf
          .map(
            (e) => (e["label"] as String, e["description"] as String),
          )
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statConfiguration.name,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.white, fontSize: 24),
          ),
          SizedBox(
            height: 10,
          ),
          ...parsedValue.map(
            (e) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "- $e",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.white, fontSize: 16),
                ),
                Builder(builder: (context) {
                  var descriptionTuple =
                      config.firstWhereOrNull((es) => es.$1 == e);
                  if (descriptionTuple == null) return Container();
                  return Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      descriptionTuple.$2,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.white, fontSize: 16),
                    ),
                  );
                }),
              ],
            ),
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
