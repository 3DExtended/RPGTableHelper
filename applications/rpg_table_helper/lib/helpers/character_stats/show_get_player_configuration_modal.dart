import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/modal_content_wrapper.dart';
import 'package:rpg_table_helper/components/newdesign/bordered_image.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/image_generation_service.dart';

Future<RpgCharacterStatValue?> showGetPlayerConfigurationModal({
  required BuildContext context,
  required CharacterStatDefinition statConfiguration,
  required String characterName,
  RpgCharacterStatValue? characterValue,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
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

class ShowGetPlayerConfigurationModalContent extends ConsumerStatefulWidget {
  const ShowGetPlayerConfigurationModalContent({
    super.key,
    required this.statConfiguration,
    required this.characterName,
    this.characterValue,
    this.overrideNavigatorKey,
  });

  final String characterName;
  final CharacterStatDefinition statConfiguration;
  final RpgCharacterStatValue? characterValue;
  final GlobalKey<NavigatorState>? overrideNavigatorKey;

  @override
  ConsumerState<ShowGetPlayerConfigurationModalContent> createState() =>
      _ShowGetPlayerConfigurationModalContentState();
}

class _ShowGetPlayerConfigurationModalContentState
    extends ConsumerState<ShowGetPlayerConfigurationModalContent> {
  var textEditController = TextEditingController();
  var textEditController2 = TextEditingController();

  List<String> urlsOfGeneratedImages = [];
  int? selectedGeneratedImageIndex;
  bool isLoadingNewImage = false;

  List<(String label, String description, bool selected, String uuid)>
      multiselectOptions = [];

  List<
      ({
        String label,
        TextEditingController valueTextController,
        TextEditingController otherValueTextController,
        String uuid
      })> listOfIntWithOtherValueOptions = [];

  List<({String label, TextEditingController valueTextController, String uuid})>
      listOfSingleValueOptions = [];

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

    if (widget.statConfiguration.valueType ==
        CharacterStatValueType.listOfIntWithCalculatedValues) {
      // jsonSerializedAdditionalData is filled with {"values":[{"label": "", "uuid": ""}]}
      var labelDefinitions = ((jsonDecode(
              widget.statConfiguration.jsonSerializedAdditionalData ??
                  '{"values":[]')["values"]) as List<dynamic>)
          .map((e) => (
                label: e["label"] as String,
                uuid: e["uuid"] as String,
              ));

      List<({String uuid, int value, int otherValue})>
          filledListOfIntsWithOtherValues = [];
      if (widget.characterValue?.serializedValue != null) {
        // => characterValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
        Map<String, dynamic> tempDecode =
            jsonDecode(widget.characterValue!.serializedValue);

        filledListOfIntsWithOtherValues =
            (tempDecode["values"] as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .map((e) => (
                      uuid: e["uuid"] as String,
                      value: e["value"] as int,
                      otherValue: e["otherValue"] as int
                    ))
                .toList();
      }
      listOfIntWithOtherValueOptions = labelDefinitions.map(
        (e) {
          var matchingValue = filledListOfIntsWithOtherValues.firstWhereOrNull(
            (element) => element.uuid == e.uuid,
          );

          return (
            label: e.label,
            valueTextController: TextEditingController(
                text: matchingValue == null
                    ? ""
                    : matchingValue.value.toString()),
            otherValueTextController: TextEditingController(
                text: matchingValue == null
                    ? ""
                    : matchingValue.otherValue.toString()),
            uuid: e.uuid,
          );
        },
      ).toList();
    }

    if (widget.statConfiguration.valueType ==
            CharacterStatValueType.characterNameWithLevelAndAdditionalDetails ||
        widget.statConfiguration.valueType ==
            CharacterStatValueType.listOfIntsWithIcons) {
      // jsonSerializedAdditionalData is filled with {"values":[{"label": "", "uuid": ""}]}
      var labelDefinitions = ((jsonDecode(
              widget.statConfiguration.jsonSerializedAdditionalData ??
                  '{"values":[]')["values"]) as List<dynamic>)
          .map((e) => (
                label: e["label"] as String,
                uuid: e["uuid"] as String,
              ))
          .toList();

      if (widget.statConfiguration.valueType ==
          CharacterStatValueType.characterNameWithLevelAndAdditionalDetails) {
        labelDefinitions.add((label: "Level", uuid: ""));
      }

      List<({String uuid, String value})> filledListOfValues = [];
      if (widget.characterValue?.serializedValue != null) {
        // => characterValue.serializedValue == {"level": 0, "values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": "12"}]}
        Map<String, dynamic> tempDecode =
            jsonDecode(widget.characterValue!.serializedValue);

        filledListOfValues = (tempDecode["values"] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .map((e) => (
                  uuid: e["uuid"] as String,
                  value: e["value"].toString(),
                ))
            .toList();

        if (widget.statConfiguration.valueType ==
            CharacterStatValueType.characterNameWithLevelAndAdditionalDetails) {
          filledListOfValues.add((
            uuid: "",
            value: (tempDecode["level"] as int?)?.toString() ?? "0"
          ));
        }
      }
      listOfSingleValueOptions = labelDefinitions.map(
        (e) {
          var matchingValue = filledListOfValues.firstWhereOrNull(
            (element) => element.uuid == e.uuid,
          );

          return (
            label: e.label,
            valueTextController: TextEditingController(
                text: matchingValue == null
                    ? ""
                    : matchingValue.value.toString()),
            uuid: e.uuid,
          );
        },
      ).toList();
    }

    pageController = PageController(
      initialPage: widget.characterValue?.variant ?? 0,
    );
    setState(() {
      currentlyVisableVariant = min(
          widget.characterValue?.variant ?? 0,
          numberOfVariantsForValueTypes(widget.statConfiguration.valueType) -
              1);
    });

    if (widget.statConfiguration.valueType ==
            CharacterStatValueType.singleLineText ||
        widget.statConfiguration.valueType ==
            CharacterStatValueType.multiLineText ||
        widget.statConfiguration.valueType ==
            CharacterStatValueType.singleImage ||
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

        // for CharacterStatValueType.singleImage
        // {"imageUrl": "someUrl", "value": "some text"}
        if (tempDecode.containsKey("imageUrl")) {
          urlsOfGeneratedImages = [tempDecode["imageUrl"]];
          selectedGeneratedImageIndex = 0;
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
                case CharacterStatValueType.singleImage:
                  // characterValue.serializedValue = {"imageUrl": "someUrl", "value": "some text"}

                  return Column(
                    children: [
                      CustomTextField(
                        newDesign: true,
                        labelText: widget.statConfiguration.name,
                        placeholderText: widget.statConfiguration.helperText,
                        textEditingController: textEditController,
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ConstrainedBox(
                        constraints:
                            BoxConstraints(maxHeight: 300, maxWidth: 300),
                        child: Builder(builder: (context) {
                          var imageUrl = urlsOfGeneratedImages.isEmpty
                              ? null
                              : urlsOfGeneratedImages[
                                  selectedGeneratedImageIndex ?? 0];

                          var fullImageUrl = imageUrl == null
                              ? "assets/images/charactercard_placeholder.png"
                              : (imageUrl.startsWith("assets")
                                      ? imageUrl
                                      : (apiBaseUrl +
                                          (imageUrl.startsWith("/")
                                              ? imageUrl.substring(1)
                                              : imageUrl))) ??
                                  "assets/images/charactercard_placeholder.png";

                          return BorderedImage(
                            lightColor: darkColor,
                            backgroundColor: bgColor,
                            imageUrl: fullImageUrl,
                            greyscale: false,
                            isLoadingNewImage: isLoadingNewImage,
                            withoutPadding: true,
                          );
                        }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Spacer(),
                          Spacer(),
                          CustomButtonNewdesign(
                              variant: CustomButtonNewdesignVariant.FlatButton,
                              icon: CustomFaIcon(
                                icon: FontAwesomeIcons.chevronLeft,
                                color:
                                    isShowPreviousGeneratedImageButtonDisabled
                                        ? middleBgColor
                                        : darkColor,
                              ),
                              onPressed:
                                  isShowPreviousGeneratedImageButtonDisabled
                                      ? null
                                      : () {
                                          setState(() {
                                            if (selectedGeneratedImageIndex !=
                                                null) {
                                              selectedGeneratedImageIndex = max(
                                                  selectedGeneratedImageIndex! -
                                                      1,
                                                  0);
                                            }
                                          });
                                        }),
                          Spacer(),
                          CupertinoButton(
                            onPressed: isLoadingNewImage == true
                                ? null
                                : () async {
                                    if (textEditController.text == "" ||
                                        textEditController.text.length < 5) {
                                      return;
                                    }

                                    var connectionDetails = ref
                                        .read(connectionDetailsProvider)
                                        .requireValue;
                                    var campagneId =
                                        connectionDetails.campagneId;
                                    if (campagneId == null) return;

                                    setState(() {
                                      isLoadingNewImage = true;
                                    });

                                    var service = DependencyProvider.of(context)
                                        .getService<IImageGenerationService>();

                                    var generationResult =
                                        await service.createNewImageAndGetUrl(
                                      prompt: textEditController.text,
                                      campagneId: CampagneIdentifier(
                                          $value: campagneId),
                                    );

                                    if (!context.mounted) return;
                                    await generationResult
                                        .possiblyHandleError(context);
                                    if (!context.mounted) return;

                                    if (generationResult.isSuccessful &&
                                        generationResult.result != null) {
                                      setState(() {
                                        urlsOfGeneratedImages
                                            .add(generationResult.result!);
                                        selectedGeneratedImageIndex =
                                            urlsOfGeneratedImages.length - 1;
                                      });
                                    }
                                    setState(() {
                                      isLoadingNewImage = false;
                                    });
                                  },
                            minSize: 0,
                            padding: EdgeInsets.all(0),
                            child: Text(
                              "Neues Bild",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: isLoadingNewImage
                                        ? middleBgColor
                                        : accentColor,
                                    decoration: TextDecoration.underline,
                                    decorationColor: isLoadingNewImage
                                        ? middleBgColor
                                        : accentColor,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                          Spacer(),
                          CustomButtonNewdesign(
                              variant: CustomButtonNewdesignVariant.FlatButton,
                              icon: CustomFaIcon(
                                icon: FontAwesomeIcons.chevronRight,
                                color: isShowNextGeneratedButtonDisabled
                                    ? middleBgColor
                                    : darkColor,
                              ),
                              onPressed: isShowNextGeneratedButtonDisabled
                                  ? null
                                  : () {
                                      setState(() {
                                        if (selectedGeneratedImageIndex !=
                                            null) {
                                          selectedGeneratedImageIndex = min(
                                              selectedGeneratedImageIndex! + 1,
                                              urlsOfGeneratedImages.length - 1);
                                        }
                                      });
                                    }),
                          Spacer(),
                          Spacer(),
                        ],
                      ),
                    ],
                  );

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

                case CharacterStatValueType.listOfIntWithCalculatedValues:
                  // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
                  // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
                  var statTitle = widget.statConfiguration.name;
                  var statDescription = widget.statConfiguration.helperText;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlayerConfigModalNonDefaultTitleAndHelperText(
                          statTitle: statTitle,
                          statDescription: statDescription),
                      ...listOfIntWithOtherValueOptions
                          .asMap()
                          .entries
                          .sortedBy((e) => e.value.label)
                          .map((e) => Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                        "${e.value.label}:",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(
                                              color: darkTextColor,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: CustomTextField(
                                      labelText: "Erster Wert",
                                      textEditingController:
                                          e.value.valueTextController,
                                      placeholderText:
                                          "Der erste Wert für ${e.value.label}",
                                      keyboardType: TextInputType.number,
                                      newDesign: true,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: CustomTextField(
                                      labelText: "Zweiter Wert",
                                      textEditingController:
                                          e.value.otherValueTextController,
                                      keyboardType: TextInputType.number,
                                      placeholderText:
                                          "Der zweite Wert für ${e.value.label}",
                                      newDesign: true,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              )),
                    ],
                  );

                case CharacterStatValueType
                      .characterNameWithLevelAndAdditionalDetails:
                case CharacterStatValueType.listOfIntsWithIcons:
                  // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12}]}
                  // => statConfiguration.jsonSerializedAdditionalData! == {"level": 0, "values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
                  var statTitle = widget.statConfiguration.name;
                  var statDescription = widget.statConfiguration.helperText;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlayerConfigModalNonDefaultTitleAndHelperText(
                          statTitle: statTitle,
                          statDescription: statDescription),
                      ...listOfSingleValueOptions
                          .asMap()
                          .entries
                          .sortedBy((e) => e.value.label)
                          .map((e) => Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                        "${e.value.label}:",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(
                                              color: darkTextColor,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: CustomTextField(
                                      labelText: e.value.label,
                                      textEditingController:
                                          e.value.valueTextController,
                                      placeholderText:
                                          "Der Wert von ${e.value.label}",
                                      keyboardType:
                                          widget.statConfiguration.valueType ==
                                                  CharacterStatValueType
                                                      .listOfIntsWithIcons
                                              ? TextInputType.number
                                              : TextInputType.text,
                                      newDesign: true,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
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
                              labelText: "Erster Wert",
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
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
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
                        alignment: Alignment.topCenter,
                        child: Container(
                          // decoration: BoxDecoration(
                          //     border: Border.all(color: darkTextColor),
                          //     borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.all(10),
                          child: getPlayerVisualizationWidget(
                              useNewDesign: true,
                              context: context,
                              statConfiguration: widget.statConfiguration,
                              characterValue: statValue,
                              characterName: widget.characterName),
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

  bool get isShowPreviousGeneratedImageButtonDisabled {
    return selectedGeneratedImageIndex == null ||
        selectedGeneratedImageIndex == 0;
  }

  bool get isShowNextGeneratedButtonDisabled {
    return selectedGeneratedImageIndex == null ||
        selectedGeneratedImageIndex! >= urlsOfGeneratedImages.length - 1;
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
      case CharacterStatValueType.singleImage:
        var currentOrDefaultTextValue =
            textEditController.text.isEmpty ? "" : textEditController.text;
        return RpgCharacterStatValue(
          variant: 0,
          serializedValue: jsonEncode({
            "value": currentOrDefaultTextValue,
            "imageUrl": urlsOfGeneratedImages.isEmpty ||
                    selectedGeneratedImageIndex == null
                ? "assets/images/charactercard_placeholder.png"
                : urlsOfGeneratedImages[selectedGeneratedImageIndex ?? 0]
          }),
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

      case CharacterStatValueType.listOfIntsWithIcons:
        // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12,}]}

        List<Map<String, dynamic>> filledValuesForlistOfSingleValueOptions =
            listOfSingleValueOptions
                .where((t) => t.uuid.isNotEmpty)
                .map((e) => {
                      "uuid": e.uuid,
                      "value": int.tryParse(e.valueTextController.text) ?? 0,
                    })
                .toList();

        return RpgCharacterStatValue(
          variant: 0,
          serializedValue: jsonEncode({
            "values": filledValuesForlistOfSingleValueOptions,
          }),
          statUuid: widget.statConfiguration.statUuid,
        );

      case CharacterStatValueType.listOfIntWithCalculatedValues:
        // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}

        List<Map<String, dynamic>>
            filledValuesForlistOfIntWithCalculatedValues =
            listOfIntWithOtherValueOptions
                .map((e) => {
                      "uuid": e.uuid,
                      "value": int.tryParse(e.valueTextController.text) ?? 0,
                      "otherValue":
                          int.tryParse(e.otherValueTextController.text) ?? 0,
                    })
                .toList();
        return RpgCharacterStatValue(
          variant: 0,
          serializedValue: jsonEncode({
            "values": filledValuesForlistOfIntWithCalculatedValues,
          }),
          statUuid: widget.statConfiguration.statUuid,
        );

      case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
        // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}

        List<Map<String, dynamic>> filledValuesForlistOfSingleValueOptions =
            listOfSingleValueOptions
                .where((t) => t.uuid.isNotEmpty)
                .map((e) => {
                      "uuid": e.uuid,
                      "value": e.valueTextController.text,
                    })
                .toList();

        var foundLevel = listOfSingleValueOptions
            .firstWhereOrNull((t) => t.uuid.isEmpty)
            ?.valueTextController
            .text;

        return RpgCharacterStatValue(
          variant: 0,
          serializedValue: jsonEncode({
            "level":
                (foundLevel != null ? int.tryParse(foundLevel) : null) ?? 0,
            "values": filledValuesForlistOfSingleValueOptions,
          }),
          statUuid: widget.statConfiguration.statUuid,
        );
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
