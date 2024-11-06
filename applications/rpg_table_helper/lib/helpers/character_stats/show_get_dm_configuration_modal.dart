import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_dropdown_menu.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/modal_content_wrapper.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/main.dart';
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
      enableDrag: false,
      context: context,
      backgroundColor: const Color.fromARGB(192, 21, 21, 21),
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

  // stored as [{"label": "asdf", "description": "asdf"}] in additionalValues
  List<
      (
        String uuid,
        TextEditingController label,
        TextEditingController description
      )> multiselectOptions = [];

  CharacterStatEditType? selectedEditType = CharacterStatEditType.static;
  CharacterStatValueType? selectedValueType =
      CharacterStatValueType.singleLineText;

  // TODO add "advanced options" to edit those...
  bool isOptionalForCompanionCharacters = false;
  bool isOptionalForAlternateForms = false;

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

          isOptionalForAlternateForms =
              widget.predefinedConfiguration!.isOptionalForAlternateForms ??
                  false;

          isOptionalForCompanionCharacters = widget
                  .predefinedConfiguration!.isOptionalForCompanionCharacters ??
              false;

          // what to do about additionaldetails
          if (selectedValueType == CharacterStatValueType.multiselect) {
            // Decode JSON string to a list of dynamic maps
            List<dynamic> jsonList = jsonDecode(
                widget.predefinedConfiguration?.jsonSerializedAdditionalData ??
                    "[]");

            for (var item in jsonList) {
              var label = (item as Map<String, dynamic>)["label"];
              var uuid = (item)["uuid"];
              var description = (item)["description"];

              multiselectOptions.add((
                uuid,
                TextEditingController(text: label),
                TextEditingController(text: description)
              ));
            }
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContentWrapper<CharacterStatDefinition>(
        title: "Eigenschaft bearbeiten",
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
            isOptionalForAlternateForms: isOptionalForAlternateForms,
            isOptionalForCompanionCharacters: isOptionalForCompanionCharacters,
          );

          if (selectedValueType == CharacterStatValueType.multiselect) {
            var serializedAdditionalData = jsonEncode(multiselectOptions
                .map((e) => {
                      "uuid": e.$1,
                      "label": e.$2.text,
                      "description": e.$3.text
                    })
                .toList());

            tempResult = tempResult.copyWith(
                jsonSerializedAdditionalData: serializedAdditionalData);
          }

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
              newDesign: true,
              labelText: "Name der Eigenschaft",
              textEditingController: nameTextEditor,
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextField(
              newDesign: true,
              labelText: "Hilfstext für die Eigenschaft",
              textEditingController: helperTextEditor,
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 10,
            ),
            CustomDropdownMenu(
                newDesign: true,
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
              height: 15,
            ),
            CustomDropdownMenu(
                newDesign: true,
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
                        child: Text("Zahlen-Wert"), // TODO localize
                      );
                    case CharacterStatValueType.intWithMaxValue:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(
                            "Zahlen-Wert mit maximal Wert"), // TODO localize
                      );
                    case CharacterStatValueType.intWithCalculatedValue:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(
                            "Zahlen-Wert mit zusätzlicher Zahl"), // TODO localize
                      );
                    // case CharacterStatValueType.intCounter:
                    //   return DropdownMenuItem<String?>(
                    //     value: e.name,
                    //     child: Text("Zähler/Counter"), // TODO localize
                    //   );
                    // case CharacterStatValueType.bool:
                    //   return DropdownMenuItem<String?>(
                    //     value: e.name,
                    //     child: Text("Ja/Nein"), // TODO localize
                    //   );
                    // case CharacterStatValueType.double:
                    //   return DropdownMenuItem<String?>(
                    //     value: e.name,
                    //     child: Text("Komma-Zahl"), // TODO localize
                    //   );
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
            ...getAdditionalDetailsWidgets(),
            SizedBox(
                height: EdgeInsets.fromViewPadding(View.of(context).viewInsets,
                        View.of(context).devicePixelRatio)
                    .bottom),
          ],
        ));
  }

  List<Widget> getAdditionalDetailsWidgets() {
    // TODO add all items which need additionalDetails here
    var typesWithAdditionalConfigurationRequired = [
      CharacterStatValueType.multiselect,
    ];

    if (selectedValueType == null) return [];
    if (!typesWithAdditionalConfigurationRequired.contains(selectedValueType)) {
      return [];
    }

    if (selectedValueType == CharacterStatValueType.multiselect) {
      return [
        SizedBox(
          height: 20,
        ),
        HorizontalLine(),
        SizedBox(
          height: 10,
        ),
        Text(
          "Optionen für Mehrfach-Auswahl",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: darkTextColor,
                fontSize: 20,
              ),
        ),
        SizedBox(
          height: 20,
        ),

        // we should have tuples of "option label" and "option description"
        ...multiselectOptions.asMap().entries.map(
              (tuple) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        newDesign: true,
                        labelText: "Name:",
                        textEditingController: tuple.value.$2,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomTextField(
                        newDesign: true,
                        labelText: "Beschreibung:",
                        textEditingController: tuple.value.$3,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 70,
                      clipBehavior: Clip.none,
                      child: CustomButtonNewdesign(
                        variant: CustomButtonNewdesignVariant.FlatButton,
                        onPressed: () {
                          setState(() {
                            multiselectOptions.removeAt(tuple.key);
                          });
                        },
                        icon: const CustomFaIcon(
                          icon: FontAwesomeIcons.trashCan,
                          color: darkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          child: CustomButtonNewdesign(
            isSubbutton: true,
            onPressed: () {
              setState(() {
                multiselectOptions.add((
                  UuidV7().generate(),
                  TextEditingController(),
                  TextEditingController()
                ));
              });
            },
            label: "Neues Element",
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
        ),
      ];
    }

    return [];
  }
}
