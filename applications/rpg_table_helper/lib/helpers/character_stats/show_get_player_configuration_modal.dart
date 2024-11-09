import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/modal_content_wrapper.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:signalr_netcore/errors.dart';

Future<RpgCharacterStatValue?> showGetPlayerConfigurationModal({
  required BuildContext context,
  required CharacterStatDefinition statConfiguration,
  RpgCharacterStatValue? characterValue,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
  String? characterName,
}) async {
  return await customShowCupertinoModalBottomSheet<RpgCharacterStatValue>(
      isDismissible: true,
      expand: true,
      closeProgressThreshold: -50000,
      enableDrag: false,
      context: context,
      backgroundColor: const Color.fromARGB(158, 49, 49, 49),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        return ShowGetPlayerConfigurationModalContent(
          statConfiguration: statConfiguration,
          characterValue: characterValue,
          overrideNavigatorKey: overrideNavigatorKey,
          characterName: characterName,
        );
      });
}

class ShowGetPlayerConfigurationModalContent extends StatefulWidget {
  const ShowGetPlayerConfigurationModalContent({
    super.key,
    required this.statConfiguration,
    this.characterValue,
    this.overrideNavigatorKey,
    this.characterName,
  });

  final String? characterName;
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

  List<(String label, String description, bool selected, String uuid)>
      multiselectOptions = [];

  late PageController pageController;

  int currentlyVisableVariant = 0;

  Future _goToVariantId(int id) async {
    if (id == currentlyVisableVariant) return;
    setState(() {
      currentlyVisableVariant = id;
      pageController.jumpToPage(id);
    });
  }

  @override
  void initState() {
    if (widget.statConfiguration.valueType ==
        CharacterStatValueType.multiselect) {
      // jsonSerializedAdditionalData is filled with [{label: "", description: ""}]
      List<dynamic> asdf = jsonDecode(widget
              .statConfiguration.jsonSerializedAdditionalData
              ?.replaceAll("},]", "}]")
              .replaceAll('"}]"}]', '"}]') ??
          "[]");

      List<String> selectedValues = [];
      if (widget.characterValue?.serializedValue != null) {
        Map<String, dynamic> tempDecode =
            jsonDecode(widget.characterValue!.serializedValue);
        selectedValues = (tempDecode["values"] as List<dynamic>)
            .map((e) => e as String)
            .toList();
      }

      multiselectOptions = asdf.map(
        (e) {
          return (
            e["label"] as String,
            e["description"] as String,
            selectedValues.contains(e["uuid"] as String),
            e["uuid"] as String,
          );
        },
      ).toList();
    }

    pageController = PageController(
      initialPage: widget.characterValue?.variant ?? 0,
    );
    setState(() {
      currentlyVisableVariant = widget.characterValue?.variant ?? 0;
    });

    if (widget.statConfiguration.valueType ==
            CharacterStatValueType.singleLineText ||
        widget.statConfiguration.valueType ==
            CharacterStatValueType.multiLineText ||
        widget.statConfiguration.valueType == CharacterStatValueType.int ||
        widget.statConfiguration.valueType ==
            CharacterStatValueType.intWithMaxValue ||
        widget.statConfiguration.valueType ==
            CharacterStatValueType.intWithCalculatedValue) {
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
        // for CharacterStatValueType.intWithCalculatedValue
        if (tempDecode.containsKey("otherValue")) {
          textEditController2 =
              TextEditingController(text: tempDecode["otherValue"].toString());
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContentWrapper<RpgCharacterStatValue>(
        title:
            "Eigenschaften konfigurieren${widget.characterName == null ? "" : " (für ${widget.characterName})"}",
        navigatorKey: widget.overrideNavigatorKey ?? navigatorKey,
        onCancel: () async {},
        // TODO onSave should be null if this modal is invalid
        onSave: () {
          return Future.value(getCurrentStatValueOrDefault()
              .copyWith(variant: currentlyVisableVariant));
        },
        child: Column(
          children: [
            Builder(builder: (context) {
              switch (widget.statConfiguration.valueType) {
                case CharacterStatValueType.singleLineText:
                case CharacterStatValueType.multiLineText:
                  // characterValue.serializedValue = {"value": "asdf"}

                  return CustomTextField(
                    newDesign: true,
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
                        newDesign: true,
                        labelText: widget.statConfiguration.name,
                        placeholderText: widget.statConfiguration.helperText,
                        textEditingController: textEditController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  );

                case CharacterStatValueType.multiselect:
                  // characterValue.serializedValue = {"values": ["DEX", "WIS"]}
                  var statTitle = widget.statConfiguration.name;
                  var statDescription = widget.statConfiguration.helperText;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlayerConfigModalNonDefaultTitleAndHelperText(
                          statTitle: statTitle,
                          statDescription: statDescription),
                      ...multiselectOptions
                          .asMap()
                          .entries
                          .sortedBy((e) => e.value.$1)
                          .map((e) => CheckboxListTile.adaptive(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.all(0),
                                splashRadius: 0,
                                dense: true,
                                checkColor:
                                    const Color.fromARGB(255, 57, 245, 88),
                                activeColor: darkColor,
                                visualDensity: VisualDensity(vertical: -2),
                                title: Text(
                                  e.value.$1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                          color: darkTextColor, fontSize: 16),
                                ),
                                subtitle: Text(
                                  e.value.$2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(color: darkTextColor),
                                ),
                                value: e.value.$3,
                                onChanged: (val) {
                                  if (val == null) return;

                                  setState(() {
                                    var deepCopy = [...multiselectOptions];

                                    deepCopy[e.key] = (
                                      e.value.$1,
                                      e.value.$2,
                                      val,
                                      e.value.$4
                                    );

                                    multiselectOptions = deepCopy;
                                  });
                                },
                              )),
                    ],
                  );

                case CharacterStatValueType.intWithMaxValue:
                  var statTitle = widget.statConfiguration.name;
                  var statDescription = widget.statConfiguration.helperText;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlayerConfigModalNonDefaultTitleAndHelperText(
                          statTitle: statTitle,
                          statDescription: statDescription),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              newDesign: true,
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
                              newDesign: true,
                              labelText: "Max Value",
                              placeholderText:
                                  "The maximum value you could get.",
                              textEditingController: textEditController2,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                case CharacterStatValueType.intWithCalculatedValue:
                  var statTitle = widget.statConfiguration.name;
                  var statDescription = widget.statConfiguration.helperText;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlayerConfigModalNonDefaultTitleAndHelperText(
                          statTitle: statTitle,
                          statDescription: statDescription),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              newDesign: true,
                              labelText: "First Value",
                              placeholderText: "The first value.",
                              textEditingController: textEditController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: CustomTextField(
                              newDesign: true,
                              labelText: "Second Value",
                              placeholderText:
                                  "The computed value based on the first value.",
                              textEditingController: textEditController2,
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
                    color: Colors.orange,
                  );
              }
            }),
            SizedBox(
              height: 10,
            ),
            HorizontalLine(
              useDarkColor: true,
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Vorschau:",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: darkTextColor,
                      fontSize: 24,
                    ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PageViewDotIndicator(
                currentItem: currentlyVisableVariant,
                count: numberOfVariantsForValueTypes(
                    widget.statConfiguration.valueType),
                unselectedColor: Colors.black26,
                selectedColor: Colors.blue,
                duration: const Duration(milliseconds: 200),
                boxShape: BoxShape.circle,
                unselectedSize: Size(6, 6),
                size: Size(6, 6),
              ),
            ),
            SizedBox(
              height: 400,
              child: PageView(
                  controller: pageController,
                  children: List.generate(
                    numberOfVariantsForValueTypes(
                        widget.statConfiguration.valueType),
                    (index) {
                      var statValue = getCurrentStatValueOrDefault()
                          .copyWith(variant: index);
                      return Align(
                        key: ValueKey(statValue),
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: darkTextColor),
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.all(10),
                          child: getPlayerVisualizationWidget(
                            useNewDesign: true,
                            context: context,
                            statConfiguration: widget.statConfiguration,
                            characterValue: statValue,
                          ),
                        ),
                      );
                    },
                  ),
                  onPageChanged: (value) {
                    setState(() {
                      currentlyVisableVariant = value;
                    });
                  }),
            ),
          ],
        ));
  }

  RpgCharacterStatValue getCurrentStatValueOrDefault() {
    switch (widget.statConfiguration.valueType) {
      case CharacterStatValueType.multiLineText:
      case CharacterStatValueType.singleLineText:
        var currentOrDefaultTextValue =
            textEditController.text.isEmpty ? "" : textEditController.text;
        return RpgCharacterStatValue(
          variant: 0,
          serializedValue: jsonEncode({"value": currentOrDefaultTextValue}),
          statUuid: widget.statConfiguration.statUuid,
        );
      case CharacterStatValueType.int:
        var currentOrDefaultIntValue =
            int.tryParse(textEditController.text) ?? 0;
        return RpgCharacterStatValue(
          variant: 0,
          serializedValue: jsonEncode({"value": currentOrDefaultIntValue}),
          statUuid: widget.statConfiguration.statUuid,
        );
      case CharacterStatValueType.intWithMaxValue:
        var currentOrDefaultIntValue =
            int.tryParse(textEditController.text) ?? 0;
        var currentOrDefaultMaxIntValue =
            int.tryParse(textEditController2.text) ?? 0;
        return RpgCharacterStatValue(
          variant: 0,
          serializedValue: jsonEncode({
            "value": currentOrDefaultIntValue,
            "maxValue": currentOrDefaultMaxIntValue,
          }),
          statUuid: widget.statConfiguration.statUuid,
        );

      case CharacterStatValueType.intWithCalculatedValue:
        var currentOrDefaultIntValue =
            int.tryParse(textEditController.text) ?? 0;
        var currentOrDefaultOtherIntValue =
            int.tryParse(textEditController2.text) ?? 0;
        return RpgCharacterStatValue(
          variant: 0,
          serializedValue: jsonEncode({
            "value": currentOrDefaultIntValue,
            "otherValue": currentOrDefaultOtherIntValue,
          }),
          statUuid: widget.statConfiguration.statUuid,
        );

      case CharacterStatValueType.multiselect:
        List<String> selectedMultiselectOptionsOrDefault =
            multiselectOptions.where((e) => e.$3).map((e) => e.$4).toList();
        return RpgCharacterStatValue(
          variant: 0,
          serializedValue: jsonEncode({
            "values": selectedMultiselectOptionsOrDefault,
          }),
          statUuid: widget.statConfiguration.statUuid,
        );
      default:
        throw NotImplementedException();
    }
  }
}

class PlayerConfigModalNonDefaultTitleAndHelperText extends StatelessWidget {
  const PlayerConfigModalNonDefaultTitleAndHelperText({
    super.key,
    required this.statTitle,
    required this.statDescription,
  });

  final String statTitle;
  final String statDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statTitle,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: darkTextColor,
                fontSize: 16,
              ),
        ),
        SizedBox(
          height: 0,
        ),
        Text(
          statDescription,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: darkTextColor,
                fontSize: 12,
              ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
