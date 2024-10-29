import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/modal_content_wrapper.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

Future<RpgCharacterStatValue?> showGetPlayerConfigurationModal({
  required BuildContext context,
  required CharacterStatDefinition statConfiguration,
  RpgCharacterStatValue? characterValue,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  return await customShowCupertinoModalBottomSheet<RpgCharacterStatValue>(
      isDismissible: true,
      expand: true,
      closeProgressThreshold: -50000,
      enableDrag: true,
      context: context,
      backgroundColor: const Color.fromARGB(158, 49, 49, 49),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        return ShowGetPlayerConfigurationModalContent(
          statConfiguration: statConfiguration,
          characterValue: characterValue,
          overrideNavigatorKey: overrideNavigatorKey,
        );
      });
}

class ShowGetPlayerConfigurationModalContent extends StatefulWidget {
  const ShowGetPlayerConfigurationModalContent({
    super.key,
    required this.statConfiguration,
    this.characterValue,
    this.overrideNavigatorKey,
  });

  final CharacterStatDefinition statConfiguration;
  final RpgCharacterStatValue? characterValue;
  final GlobalKey<NavigatorState>? overrideNavigatorKey;

  @override
  State<ShowGetPlayerConfigurationModalContent> createState() =>
      _ShowGetPlayerConfigurationModalContentState();
}

class _ShowGetPlayerConfigurationModalContentState
    extends State<ShowGetPlayerConfigurationModalContent> {
  var textEditController = TextEditingController();
  var textEditController2 = TextEditingController();

  @override
  void initState() {
    if (widget.statConfiguration.valueType ==
            CharacterStatValueType.singleLineText ||
        widget.statConfiguration.valueType ==
            CharacterStatValueType.multiLineText ||
        widget.statConfiguration.valueType == CharacterStatValueType.int ||
        widget.statConfiguration.valueType ==
            CharacterStatValueType.intWithMaxValue) {
      if (widget.characterValue == null) {
        textEditController = TextEditingController();
        textEditController2 = TextEditingController();
      } else {
        Map<String, dynamic> tempDecode =
            jsonDecode(widget.characterValue!.serializedValue);
        var parsedValue = tempDecode["value"];
        textEditController =
            TextEditingController(text: parsedValue.toString());

        // for CharacterStatValueType.intWithMaxValue
        if (tempDecode.containsKey("maxValue")) {
          textEditController2 =
              TextEditingController(text: tempDecode["maxValue"].toString());
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContentWrapper<RpgCharacterStatValue>(
        title: "Eigenschaften konfigurieren",
        navigatorKey: widget.overrideNavigatorKey ?? navigatorKey,
        onCancel: () async {},

        // TODO onSave should be null if this modal is invalid
        onSave: () async {
          switch (widget.statConfiguration.valueType) {
            case CharacterStatValueType.multiLineText:
            case CharacterStatValueType.singleLineText:
              return RpgCharacterStatValue(
                serializedValue: jsonEncode({"value": textEditController.text}),
                statUuid: widget.statConfiguration.statUuid,
              );
            case CharacterStatValueType.int:
              return RpgCharacterStatValue(
                serializedValue:
                    jsonEncode({"value": int.parse(textEditController.text)}),
                statUuid: widget.statConfiguration.statUuid,
              );
            case CharacterStatValueType.intWithMaxValue:
              return RpgCharacterStatValue(
                serializedValue: jsonEncode({
                  "value": int.parse(textEditController.text),
                  "maxValue": int.parse(textEditController2.text)
                }),
                statUuid: widget.statConfiguration.statUuid,
              );
            default:
          }
          return null;
        },
        child: Builder(builder: (context) {
          switch (widget.statConfiguration.valueType) {
            case CharacterStatValueType.singleLineText:
            case CharacterStatValueType.multiLineText:
              // characterValue.serializedValue = {"value": "asdf"}

              return CustomTextField(
                labelText: widget.statConfiguration.name,
                placeholderText: widget.statConfiguration.helperText,
                textEditingController: textEditController,
                keyboardType: widget.statConfiguration.valueType ==
                        CharacterStatValueType.multiLineText
                    ? TextInputType.multiline
                    : TextInputType.text,
              );
            case CharacterStatValueType.int:
              // characterValue.serializedValue = {"value": 17}

              return Column(
                children: [
                  CustomTextField(
                    labelText: widget.statConfiguration.name,
                    placeholderText: widget.statConfiguration.helperText,
                    textEditingController: textEditController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              );

            case CharacterStatValueType.intWithMaxValue:
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.statConfiguration.name,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  Text(
                    widget.statConfiguration.helperText,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          labelText: "Current Value",
                          placeholderText: "The current value.",
                          textEditingController: textEditController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: CustomTextField(
                          labelText: "Max Value",
                          placeholderText: "The maximum value you could get.",
                          textEditingController: textEditController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              );

            default:
              return Container(
                height: 50,
                width: 50,
                color: Colors.red,
              );
          }
        }));
  }
}
