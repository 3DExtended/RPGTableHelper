import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/custom_dropdown_menu.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/modal_content_wrapper.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:uuid/v7.dart';

Future<CharacterStatDefinition?> showGetDmConfigurationModal({
  required BuildContext context,
  CharacterStatDefinition? predefinedConfiguration,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  return await customShowCupertinoModalBottomSheet<CharacterStatDefinition>(
      isDismissible: true,
      expand: true,
      closeProgressThreshold: -50000,
      enableDrag: true,
      context: context,
      backgroundColor: const Color.fromARGB(158, 49, 49, 49),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        return ShowGetDmConfigurationModalContent(
          overrideNavigatorKey: overrideNavigatorKey,
          predefinedConfiguration: predefinedConfiguration,
        );
      });
}

class ShowGetDmConfigurationModalContent extends StatefulWidget {
  const ShowGetDmConfigurationModalContent({
    this.overrideNavigatorKey,
    this.predefinedConfiguration,
    super.key,
  });

  final GlobalKey<NavigatorState>? overrideNavigatorKey;
  final CharacterStatDefinition? predefinedConfiguration;

  @override
  State<ShowGetDmConfigurationModalContent> createState() =>
      _ShowGetDmConfigurationModalContentState();
}

class _ShowGetDmConfigurationModalContentState
    extends State<ShowGetDmConfigurationModalContent> {
  var nameTextEditor = TextEditingController();
  var helperTextEditor = TextEditingController();

  CharacterStatEditType? selectedEditType = CharacterStatEditType.static;
  CharacterStatValueType? selectedValueType =
      CharacterStatValueType.singleLineText;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (widget.predefinedConfiguration != null) {
        setState(() {
          nameTextEditor =
              TextEditingController(text: widget.predefinedConfiguration!.name);
          helperTextEditor = TextEditingController(
              text: widget.predefinedConfiguration!.helperText);

          selectedEditType = widget.predefinedConfiguration!.editType;
          selectedValueType = widget.predefinedConfiguration!.valueType;

          // what to do about additionaldetails
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContentWrapper<CharacterStatDefinition>(
        title: "Eigenschaften bearbeiten",
        navigatorKey: widget.overrideNavigatorKey ?? navigatorKey,
        onCancel: () async {},

        // TODO ensure onSave is null if disabled should be disabled...
        onSave: () async {
          var tempResult = CharacterStatDefinition(
            statUuid: UuidV7().generate(),
            name: nameTextEditor.text,
            helperText: helperTextEditor.text,
            valueType: selectedValueType!,
            editType: selectedEditType!,
          );
          if (widget.predefinedConfiguration == null) {
            return tempResult;
          } else {
            return tempResult.copyWith(
                statUuid: widget.predefinedConfiguration!.statUuid);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              labelText: "Name der Eigenschaft",
              textEditingController: nameTextEditor,
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextField(
              labelText: "Hilfstext für die Eigenschaft",
              textEditingController: helperTextEditor,
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 10,
            ),
            // edit type
            CustomDropdownMenu(
                selectedValueTemp: selectedValueType?.name,
                setter: (newValue) {
                  setState(() {
                    if (newValue == null) {
                      selectedValueType = null;
                    } else {
                      selectedValueType = CharacterStatValueType.values
                          .singleWhere((e) => e.name == newValue);
                    }
                  });
                },
                items: CharacterStatValueType.values.map((e) {
                  switch (e) {
                    case CharacterStatValueType.multiLineText:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text("Mehrzeiliger Text"), // TODO localize
                      );
                    case CharacterStatValueType.singleLineText:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text("Einzeiliger Text"), // TODO localize
                      );
                    case CharacterStatValueType.int:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text("Zahl"), // TODO localize
                      );
                    case CharacterStatValueType.intWithMaxValue:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text("Zahl mit maximal Wert"), // TODO localize
                      );
                    case CharacterStatValueType.intCounter:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text("Zähler/Counter"), // TODO localize
                      );
                    case CharacterStatValueType.bool:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text("Ja/Nein"), // TODO localize
                      );
                    case CharacterStatValueType.double:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text("Komma-Zahl"), // TODO localize
                      );
                    case CharacterStatValueType.multiselect:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text("Mehrfach-Auswahl"), // TODO localize
                      );
                    default:
                      throw NotImplementedException();
                  }
                }).toList(),
                label: "Art der Eigenschaft"),
            SizedBox(
              height: 15,
            ),
            // edit type
            CustomDropdownMenu(
                selectedValueTemp: selectedEditType?.name,
                setter: (newValue) {
                  setState(() {
                    if (newValue == null) {
                      selectedEditType = null;
                    } else {
                      selectedEditType = CharacterStatEditType.values
                          .singleWhere((e) => e.name == newValue);
                    }
                  });
                },
                items: CharacterStatEditType.values.map((e) {
                  switch (e) {
                    case CharacterStatEditType.oneTap:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(
                            "Häufig verändert (bspw. jede Session)"), // TODO localize
                      );
                    case CharacterStatEditType.static:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(
                            "Selten verändert (bspw. je Level-Up)"), // TODO localize
                      );
                    default:
                      throw NotImplementedException();
                  }
                }).toList(),
                label: "Veränderungshäufigkeit"),
            SizedBox(
                height: EdgeInsets.fromViewPadding(View.of(context).viewInsets,
                        View.of(context).devicePixelRatio)
                    .bottom),
          ],
        ));
  }
}

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

    default:
      return Container(
        height: 50,
        width: 50,
        color: Colors.red,
      );
  }
}
