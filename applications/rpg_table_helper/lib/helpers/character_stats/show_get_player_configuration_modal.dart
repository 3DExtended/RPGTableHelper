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

  @override
  void initState() {
    if (widget.statConfiguration.valueType ==
            CharacterStatValueType.singleLineText ||
        widget.statConfiguration.valueType ==
            CharacterStatValueType.multiLineText) {
      if (widget.characterValue == null) {
        textEditController = TextEditingController();
      } else {
        var parsedValue =
            (jsonDecode(widget.characterValue!.serializedValue)["value"]);
        textEditController = TextEditingController(text: parsedValue);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContentWrapper(
        title: "Eigenschaften konfigurieren",
        navigatorKey: widget.overrideNavigatorKey ?? navigatorKey,
        onCancel: () async {},
        onSave: () async {
          return null;

          // TODO make me
          // return CharacterStatDefinition();
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
                  // TODO make me
                  // CustomDropdownMenu(selectedValueTemp: selectedValueTemp, setter: setter, items: items, label: label)
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
