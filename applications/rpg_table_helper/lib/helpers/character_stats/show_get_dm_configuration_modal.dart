import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_dropdown_menu.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/modal_content_wrapper.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/helpers/modals/show_select_icon_with_color_modal.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
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

  List<({String uuid, TextEditingController label, String? iconName})>
      groupOfLabeledValues = [];

  CharacterStatEditType? selectedEditType = CharacterStatEditType.static;
  CharacterStatValueType? selectedValueType =
      CharacterStatValueType.singleLineText;

  // TODO add "advanced options" to edit those...
  bool isOptionalForCompanionCharacters = false;
  bool isOptionalForAlternateForms = false;
  bool multiselectIsAllowedToBeSelectedMultipleTimes = false;

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
            // TODO remove migration
            List<dynamic> jsonList = [];
            if (widget.predefinedConfiguration?.jsonSerializedAdditionalData
                        ?.isNotEmpty ==
                    true &&
                widget.predefinedConfiguration!.jsonSerializedAdditionalData!
                    .startsWith("[")) {
              jsonList = jsonDecode(widget
                      .predefinedConfiguration?.jsonSerializedAdditionalData ??
                  "[]");
              multiselectIsAllowedToBeSelectedMultipleTimes = false;
            } else {
              Map<String, dynamic> json = jsonDecode(widget
                      .predefinedConfiguration?.jsonSerializedAdditionalData ??
                  '{"options:":[], "multiselectIsAllowedToBeSelectedMultipleTimes":false}');

              multiselectIsAllowedToBeSelectedMultipleTimes = json.containsKey(
                      "multiselectIsAllowedToBeSelectedMultipleTimes")
                  ? json["multiselectIsAllowedToBeSelectedMultipleTimes"]
                      as bool
                  : false;

              jsonList = json["options"] as List<dynamic>;
            }

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
          } else if (selectedValueType ==
                  CharacterStatValueType.listOfIntsWithIcons ||
              selectedValueType ==
                  CharacterStatValueType.listOfIntWithCalculatedValues ||
              selectedValueType ==
                  CharacterStatValueType
                      .characterNameWithLevelAndAdditionalDetails) {
            // Decode JSON string to a list of dynamic maps
            List<dynamic> jsonList = (jsonDecode(
                widget.predefinedConfiguration?.jsonSerializedAdditionalData ??
                    '{"values": []}') as Map<String, dynamic>)["values"];

            for (var item in jsonList) {
              var itemAsMap = item as Map<String, dynamic>;
              var label = itemAsMap.containsKey("label")
                  ? itemAsMap["label"] as String
                  : "";
              var iconName = itemAsMap.containsKey("iconName")
                  ? itemAsMap["iconName"] as String
                  : null;
              var uuid = itemAsMap.containsKey("uuid")
                  ? itemAsMap["uuid"] as String
                  : UuidV7().generate();

              groupOfLabeledValues.add((
                uuid: uuid,
                label: TextEditingController(text: label),
                iconName: iconName,
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
        isFullscreen: true,
        title: S.of(context).configureProperties,
        navigatorKey: widget.overrideNavigatorKey ?? navigatorKey,
        onCancel: () async {},

        // TODO ensure onSave is null if disabled should be disabled...
        onSave: () async {
          var tempResult = CharacterStatDefinition(
            statUuid: UuidV7().generate(),
            name: nameTextEditor.text,
            helperText: helperTextEditor.text,
            groupId: null,
            valueType: selectedValueType!,
            editType: selectedEditType!,
            isOptionalForAlternateForms: isOptionalForAlternateForms,
            isOptionalForCompanionCharacters: isOptionalForCompanionCharacters,
          );

          if (selectedValueType == CharacterStatValueType.multiselect) {
            var serializedAdditionalData = jsonEncode({
              "options": multiselectOptions
                  .map((e) => {
                        "uuid": e.$1,
                        "label": e.$2.text,
                        "description": e.$3.text
                      })
                  .toList(),
              "multiselectIsAllowedToBeSelectedMultipleTimes":
                  multiselectIsAllowedToBeSelectedMultipleTimes,
            });

            tempResult = tempResult.copyWith(
                jsonSerializedAdditionalData: serializedAdditionalData);
          } else if (selectedValueType ==
                  CharacterStatValueType.listOfIntWithCalculatedValues ||
              selectedValueType ==
                  CharacterStatValueType
                      .characterNameWithLevelAndAdditionalDetails) {
            var serializedAdditionalData = jsonEncode({
              "values": (groupOfLabeledValues
                  .map((e) => {
                        "uuid": e.uuid,
                        "label": e.label.text,
                      })
                  .toList())
            });

            tempResult = tempResult.copyWith(
                jsonSerializedAdditionalData: serializedAdditionalData);
          } else if (selectedValueType ==
              CharacterStatValueType.listOfIntsWithIcons) {
            var serializedAdditionalData = jsonEncode({
              "values": (groupOfLabeledValues
                  .map((e) => {
                        "uuid": e.uuid,
                        "label": e.label.text,
                        "iconName": e.iconName ?? "shield",
                      })
                  .toList())
            });

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
              labelText: S.of(context).nameOfPropertyLabel,
              textEditingController: nameTextEditor,
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextField(
              labelText: S.of(context).descriptionOfProperty,
              textEditingController: helperTextEditor,
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 10,
            ),
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
                        child: Text(S.of(context).propertyEditTypeOneTap),
                      );
                    case CharacterStatEditType.static:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).propertyEditTypeStatic),
                      );
                    default:
                      throw NotImplementedException();
                  }
                }).toList(),
                label: S.of(context).propertyEditTypeLabel),
            SizedBox(
              height: 15,
            ),
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
                    case CharacterStatValueType.singleImage:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).generatedImage),
                      );

                    case CharacterStatValueType.multiLineText:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).multilineText),
                      );
                    case CharacterStatValueType.singleLineText:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).singleLineText),
                      );
                    case CharacterStatValueType.int:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).integerValue),
                      );
                    case CharacterStatValueType.transformIntoAlternateFormBtn:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).transformIntoAlternateForm),
                      );

                    case CharacterStatValueType.listOfIntsWithIcons:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).listOfIntegersWithIcons),
                      );
                    case CharacterStatValueType.intWithMaxValue:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).integerValueWithMaxValue),
                      );
                    case CharacterStatValueType.listOfIntWithCalculatedValues:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S
                            .of(context)
                            .listOfInterValuesWithCalculatedIntegerValues),
                      );
                    case CharacterStatValueType.intWithCalculatedValue:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child:
                            Text(S.of(context).integerValueWithCalculatedValue),
                      );
                    case CharacterStatValueType
                          .characterNameWithLevelAndAdditionalDetails:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S
                            .of(context)
                            .characterNameWithLevelAndConfigurableDetails),
                      );

                    case CharacterStatValueType.multiselect:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).multiselectOption),
                      );
                    case CharacterStatValueType.companionSelector:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).companionOverview),
                      );
                  }
                }).toList(),
                label: S.of(context).kindOfProperty),
            ...getAdvancedConfigurationOptionWidgets(),
            ...getAdditionalDetailsWidgets(),
            SizedBox(
                height: EdgeInsets.fromViewPadding(View.of(context).viewInsets,
                        View.of(context).devicePixelRatio)
                    .bottom),
          ],
        ));
  }

  List<Widget> getAdvancedConfigurationOptionWidgets() {
    List<Widget> result = [
      SizedBox(
        height: 20,
      ),
    ];

    result.add(
      ThemeConfigurationForApp(
        child: ExpansionTile(
          enableFeedback: false,
          title: Text(S.of(context).additionalSettings),
          textColor: CustomThemeProvider.of(context).theme.darkTextColor,
          iconColor: CustomThemeProvider.of(context).theme.darkColor,
          collapsedIconColor: CustomThemeProvider.of(context).theme.darkColor,
          collapsedTextColor:
              CustomThemeProvider.of(context).theme.darkTextColor,
          shape: Border.all(color: Colors.transparent, width: 0),
          collapsedShape: Border.all(color: Colors.transparent, width: 0),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (selectedValueType == CharacterStatValueType.multiselect)
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SelectableTile(
                        onValueChange: () {
                          setState(() {
                            multiselectIsAllowedToBeSelectedMultipleTimes =
                                !multiselectIsAllowedToBeSelectedMultipleTimes;
                          });
                        },
                        isSet: multiselectIsAllowedToBeSelectedMultipleTimes,
                        label: S
                            .of(context)
                            .multiselectOptionsAreSelectableMultipleTimes),
                  ),
                ],
              ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SelectableTile(
                      onValueChange: () {
                        setState(() {
                          isOptionalForCompanionCharacters =
                              !isOptionalForCompanionCharacters;
                        });
                      },
                      isSet: isOptionalForCompanionCharacters,
                      label: S.of(context).optionalPropertyForCompanions),
                ),
              ],
            ),
            Row(mainAxisSize: MainAxisSize.max, children: [
              Expanded(
                child: SelectableTile(
                    onValueChange: () {
                      setState(() {
                        isOptionalForAlternateForms =
                            !isOptionalForAlternateForms;
                      });
                    },
                    isSet: isOptionalForAlternateForms,
                    label: S.of(context).optionalPropertyForAlternateForms),
              )
            ]),
          ],
        ),
      ),
    );

    return result;
  }

  List<Widget> getAdditionalDetailsWidgets() {
    // TODO add all items which need additionalDetails here
    var typesWithAdditionalConfigurationRequired = [
      CharacterStatValueType.multiselect,
      CharacterStatValueType.listOfIntWithCalculatedValues,
      CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
      CharacterStatValueType.listOfIntsWithIcons,
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
          S.of(context).optionsForMultiselect,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
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
                        labelText: S.of(context).multiselectOptionName,
                        textEditingController: tuple.value.$2,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomTextField(
                        labelText: S.of(context).multiselectOptionDescription,
                        textEditingController: tuple.value.$3,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 70,
                      clipBehavior: Clip.none,
                      child: CustomButton(
                        variant: CustomButtonVariant.FlatButton,
                        onPressed: () {
                          setState(() {
                            multiselectOptions.removeAt(tuple.key);
                          });
                        },
                        icon: CustomFaIcon(
                          icon: FontAwesomeIcons.trashCan,
                          color:
                              CustomThemeProvider.of(context).theme.darkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          child: CustomButton(
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
            label: S.of(context).additionalElement,
            icon: Theme(
                data: ThemeData(
                  fontFamily: "Ruwudu",
                  iconTheme: IconThemeData(
                    color: CustomThemeProvider.of(context).theme.darkTextColor,
                    size: 16,
                  ),
                  textTheme: TextTheme(
                    bodyMedium: TextStyle(
                      color:
                          CustomThemeProvider.of(context).theme.darkTextColor,
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
    } else if (selectedValueType ==
            CharacterStatValueType.listOfIntWithCalculatedValues ||
        selectedValueType ==
            CharacterStatValueType.characterNameWithLevelAndAdditionalDetails ||
        selectedValueType == CharacterStatValueType.listOfIntsWithIcons) {
      return [
        SizedBox(
          height: 20,
        ),
        HorizontalLine(),
        SizedBox(
          height: 10,
        ),
        Text(
          S.of(context).moreValues,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 20,
              ),
        ),
        SizedBox(
          height: 20,
        ),
        ...groupOfLabeledValues.asMap().entries.map(
              (tuple) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedValueType ==
                        CharacterStatValueType.listOfIntsWithIcons)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                        child: CustomButton(
                          isSubbutton: true,
                          variant: CustomButtonVariant.Default,
                          onPressed: () async {
                            // open icon and color selector
                            await showSelectIconWithColorModal(
                              context,
                              alreadySelectedIcoName:
                                  tuple.value.iconName ?? "shield",
                              alreadySelectedIconColor:
                                  CustomThemeProvider.of(context)
                                      .theme
                                      .darkColor,
                              disableColorSelect: true,
                              titleSuffix:
                                  "${S.of(context).forIntegerValueWithName} \"${tuple.value.label.text}\"",
                            ).then((value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                groupOfLabeledValues[tuple.key] = (
                                  uuid: groupOfLabeledValues[tuple.key].uuid,
                                  label: groupOfLabeledValues[tuple.key].label,
                                  iconName: value.$1,
                                );
                              });
                            });
                          },
                          icon: Padding(
                            padding: const EdgeInsets.all(4.5),
                            child: getIconForIdentifier(
                              name: tuple.value.iconName ?? "shield",
                              color: CustomThemeProvider.of(context)
                                  .theme
                                  .darkColor,
                              size: 32,
                            ).$2,
                          ),
                        ),
                      ),
                    Expanded(
                      child: CustomTextField(
                        labelText: S.of(context).propertyNameLabel,
                        textEditingController: tuple.value.label,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 70,
                      clipBehavior: Clip.none,
                      child: CustomButton(
                        variant: CustomButtonVariant.FlatButton,
                        onPressed: () {
                          setState(() {
                            groupOfLabeledValues.removeAt(tuple.key);
                          });
                        },
                        icon: CustomFaIcon(
                          icon: FontAwesomeIcons.trashCan,
                          color:
                              CustomThemeProvider.of(context).theme.darkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          child: CustomButton(
            isSubbutton: true,
            onPressed: () {
              setState(() {
                groupOfLabeledValues.add((
                  uuid: UuidV7().generate(),
                  label: TextEditingController(),
                  iconName: selectedValueType ==
                          CharacterStatValueType.listOfIntsWithIcons
                      ? "shield"
                      : null,
                ));
              });
            },
            label: S.of(context).additionalElement,
            icon: Theme(
                data: ThemeData(
                  fontFamily: "Ruwudu",
                  iconTheme: IconThemeData(
                    color: CustomThemeProvider.of(context).theme.darkTextColor,
                    size: 16,
                  ),
                  textTheme: TextTheme(
                    bodyMedium: TextStyle(
                      color:
                          CustomThemeProvider.of(context).theme.darkTextColor,
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

class SelectableTile extends StatelessWidget {
  const SelectableTile({
    super.key,
    required this.onValueChange,
    required this.isSet,
    required this.label,
  });

  final VoidCallback onValueChange;
  final bool isSet;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.fromLTRB(30, 10, 10, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            isSubbutton: true,
            onPressed: onValueChange,
            icon: Container(
              width: 20,
              height: 20,
              color: isSet
                  ? CustomThemeProvider.of(context).theme.darkColor
                  : Colors.transparent,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 16),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
