import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:rpg_table_helper/components/bordered_image.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_int_edit_field.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/modal_content_wrapper.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/l10n.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:rpg_table_helper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/image_generation_service.dart';
import 'package:uuid/v7.dart';

Future<RpgCharacterStatValue?> showGetPlayerConfigurationModal({
  required BuildContext context,
  required CharacterStatDefinition statConfiguration,
  required String characterName,
  required RpgCharacterConfiguration? characterToRenderStatFor,
  RpgCharacterStatValue? characterValue,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
  bool hideVariantSelection = false,
  bool hideAdditionalSetting = false,
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
          characterToRenderStatFor: characterToRenderStatFor,
          hideVariantSelection: hideVariantSelection,
          hideAdditionalSetting: hideAdditionalSetting,
        );
      });
}

class ShowGetPlayerConfigurationModalContent extends ConsumerStatefulWidget {
  const ShowGetPlayerConfigurationModalContent({
    super.key,
    required this.statConfiguration,
    required this.characterName,
    required this.characterToRenderStatFor,
    this.characterValue,
    this.overrideNavigatorKey,
    this.hideVariantSelection = false,
    this.hideAdditionalSetting = false,
  });

  final bool hideVariantSelection;
  final bool hideAdditionalSetting;
  final String characterName;
  final RpgCharacterConfiguration? characterToRenderStatFor;
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
  List<String> selectedCompanions = [];
  int? selectedGeneratedImageIndex;
  bool isLoading = false;

  bool hideStatFromCharacterScreens = false;
  bool hideLabelOfStat = false;

  List<
      (
        String label,
        String description,
        bool selected,
        String uuid,
        int numberOfSelections
      )> multiselectOptions = [];

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

  int currentlyVisibleVariant = 0;

  @override
  void initState() {
    pageController = PageController(
      initialPage: widget.characterValue?.variant ?? 0,
    );

    Future.delayed(Duration.zero, delayedInitState);
    super.initState();
  }

  void delayedInitState() {
    if (widget.statConfiguration.valueType ==
        CharacterStatValueType.multiselect) {
      // jsonSerializedAdditionalData = {"options:":[{"uuid": "3a7fd649-2d76-4a93-8513-d5a8e8249b40", "label": "", "description": ""}], "multiselectIsAllowedToBeSelectedMultipleTimes":false}

      List<dynamic> statConfigValues = [];

      if (widget.statConfiguration.jsonSerializedAdditionalData?.isNotEmpty ==
              true &&
          widget.statConfiguration.jsonSerializedAdditionalData!
              .startsWith("[")) {
        statConfigValues = jsonDecode(
            widget.statConfiguration.jsonSerializedAdditionalData ?? "[]");
      } else {
        Map<String, dynamic> json = jsonDecode(widget
                .statConfiguration.jsonSerializedAdditionalData ??
            '{"options:":[], "multiselectIsAllowedToBeSelectedMultipleTimes":false}');

        statConfigValues = json["options"] as List<dynamic>;
      }

      List<String> selectedValues = [];
      if (widget.characterValue?.serializedValue != null) {
        Map<String, dynamic> tempDecode =
            jsonDecode(widget.characterValue!.serializedValue);
        selectedValues = (tempDecode["values"] as List<dynamic>)
            .map((e) => e as String)
            .toList();
      }

      multiselectOptions = statConfigValues.map(
        (e) {
          return (
            e["label"] as String,
            e["description"] as String,
            selectedValues.contains(e["uuid"] as String),
            e["uuid"] as String,
            selectedValues.where((s) => s == (e["uuid"] as String)).length,
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
        CharacterStatValueType.companionSelector) {
      List<String> previouslySelectedCompanions = [];
      if (widget.characterValue?.serializedValue != null) {
        // => characterValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
        Map<String, dynamic> tempDecode =
            jsonDecode(widget.characterValue!.serializedValue);

        previouslySelectedCompanions = (tempDecode["values"] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .map(
              (e) => e["uuid"] as String,
            )
            .toList();
      }

      selectedCompanions = previouslySelectedCompanions;
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
        labelDefinitions.add((label: S.of(context).level, uuid: ""));
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

    setState(() {
      currentlyVisibleVariant = min(
          widget.characterValue?.variant ?? 0,
          numberOfVariantsForValueTypes(widget.statConfiguration.valueType) -
              1);
    });

    setState(() {
      hideStatFromCharacterScreens =
          widget.characterValue?.hideFromCharacterScreen ?? false;
      hideLabelOfStat = widget.characterValue?.hideLabelOfStat ?? false;
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
  }

  @override
  Widget build(BuildContext context) {
    return ModalContentWrapper<RpgCharacterStatValue>(
        isFullscreen: true,
        title: S.of(context).configureProperties +
            (widget.characterName.isEmpty
                ? ""
                : S.of(context).configurePropertiesForCharacterNameSuffix(
                    widget.characterName)),
        navigatorKey: widget.overrideNavigatorKey ?? navigatorKey,
        onCancel: () async {},
        // TODO onSave should be null if this modal is invalid
        onSave: () {
          return Future.value(getCurrentStatValueOrDefault()
              .copyWith(variant: currentlyVisibleVariant));
        },
        child: Column(
          children: [
            Builder(builder: (context) {
              switch (widget.statConfiguration.valueType) {
                case CharacterStatValueType.singleImage:
                  return getConfigurationWidgetsForSingleImage(context);

                case CharacterStatValueType.singleLineText:
                case CharacterStatValueType.multiLineText:
                  return getConfigurationWidgetsForTextBlock();

                case CharacterStatValueType.int:
                  return getConfigurationWidgetsForInt();

                case CharacterStatValueType.multiselect:
                  return getConfigurationWidgetsForMultiSelect();

                case CharacterStatValueType.listOfIntWithCalculatedValues:
                  return getConfigurationWidgetsForListOfIntsWithCalculatedValues();

                case CharacterStatValueType
                      .characterNameWithLevelAndAdditionalDetails:
                case CharacterStatValueType.listOfIntsWithIcons:
                  return getConfigurationWidgetsForBunchOfTextValues();

                case CharacterStatValueType.intWithMaxValue:
                  return getConfigurationWidgetsForIntWithMaxValue();

                case CharacterStatValueType.intWithCalculatedValue:
                  return getConfigurationWidgetsForIntWithCalculatedValue();

                case CharacterStatValueType.companionSelector:
                  return getConfigurationWidgetsForCompanionsSelector();

                default:
                  return Container(
                    height: 50,
                    width: 50,
                    color: Colors.orange,
                  );
              }
            }),

            if (!widget.hideAdditionalSetting)
              SizedBox(
                height: 10,
              ),
            if (!widget.hideAdditionalSetting)
              HorizontalLine(
                useDarkColor: true,
              ),

            if (!widget.hideAdditionalSetting)
              SizedBox(
                height: 10,
              ),

            // additional settings
            if (!widget.hideAdditionalSetting) getAdditionalSettingsTile(),

            if (!widget.hideVariantSelection)
              SizedBox(
                height: 10,
              ),
            if (!widget.hideVariantSelection)
              HorizontalLine(
                useDarkColor: true,
              ),
            if (!widget.hideVariantSelection)
              SizedBox(
                height: 10,
              ),
            if (!widget.hideVariantSelection)
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "${S.of(context).preview}:",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: darkTextColor,
                        fontSize: 24,
                      ),
                ),
              ),
            if (!widget.hideVariantSelection)
              SizedBox(
                height: 10,
              ),
            if (!widget.hideVariantSelection)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: PageViewDotIndicator(
                  currentItem: currentlyVisibleVariant,
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
            if (!widget.hideVariantSelection)
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
                                characterToRenderStatFor:
                                    widget.characterToRenderStatFor,
                                onNewStatValue: (newSerializedValue) {},
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
                        currentlyVisibleVariant = value;
                      });
                    }),
              ),
          ],
        ));
  }

  Column getConfigurationWidgetsForInt() {
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
  }

  CustomTextField getConfigurationWidgetsForTextBlock() {
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
  }

  Column getConfigurationWidgetsForSingleImage(BuildContext context) {
    // characterValue.serializedValue = {"imageUrl": "someUrl", "value": "some text"}
    return Column(
      children: [
        CustomTextField(
          labelText: widget.statConfiguration.name,
          placeholderText: widget.statConfiguration.helperText,
          textEditingController: textEditController,
          keyboardType: TextInputType.multiline,
        ),
        SizedBox(
          height: 10,
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
          child: Builder(builder: (context) {
            var imageUrl = urlsOfGeneratedImages.isEmpty
                ? null
                : urlsOfGeneratedImages[selectedGeneratedImageIndex ?? 0];

            var fullImageUrl = imageUrl == null
                ? "assets/images/charactercard_placeholder.png"
                : (imageUrl.startsWith("assets")
                    ? imageUrl
                    : (apiBaseUrl +
                        (imageUrl.startsWith("/")
                            ? (imageUrl.length > 1 ? imageUrl.substring(1) : '')
                            : imageUrl)));

            return BorderedImage(
              lightColor: darkColor,
              backgroundColor: bgColor,
              imageUrl: fullImageUrl,
              isGreyscale: false,
              isLoading: isLoading,
              noPadding: true,
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
            CustomButton(
                variant: CustomButtonVariant.FlatButton,
                icon: CustomFaIcon(
                  icon: FontAwesomeIcons.chevronLeft,
                  color: isShowPreviousGeneratedImageButtonDisabled
                      ? middleBgColor
                      : darkColor,
                ),
                onPressed: isShowPreviousGeneratedImageButtonDisabled
                    ? null
                    : () {
                        setState(() {
                          if (selectedGeneratedImageIndex != null) {
                            selectedGeneratedImageIndex =
                                max(selectedGeneratedImageIndex! - 1, 0);
                          }
                        });
                      }),
            Spacer(),
            CupertinoButton(
              onPressed: isLoading == true
                  ? null
                  : () async {
                      if (textEditController.text == "" ||
                          textEditController.text.length < 5) {
                        return;
                      }

                      var connectionDetails =
                          ref.read(connectionDetailsProvider).requireValue;
                      var campagneId = connectionDetails.campagneId;
                      if (campagneId == null) return;

                      setState(() {
                        isLoading = true;
                      });

                      var service = DependencyProvider.of(context)
                          .getService<IImageGenerationService>();

                      var generationResult =
                          await service.createNewImageAndGetUrl(
                        prompt: textEditController.text,
                        campagneId: CampagneIdentifier($value: campagneId),
                      );

                      if (!context.mounted || !mounted) return;
                      await generationResult.possiblyHandleError(context);
                      if (!context.mounted || !mounted) return;

                      if (generationResult.isSuccessful &&
                          generationResult.result != null) {
                        setState(() {
                          urlsOfGeneratedImages.add(generationResult.result!);
                          selectedGeneratedImageIndex =
                              urlsOfGeneratedImages.length - 1;
                        });
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
              minSize: 0,
              padding: EdgeInsets.zero,
              child: Text(
                S.of(context).newImageBtnLabel,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: isLoading ? middleBgColor : accentColor,
                      decoration: TextDecoration.underline,
                      decorationColor: isLoading ? middleBgColor : accentColor,
                      fontSize: 16,
                    ),
              ),
            ),
            Spacer(),
            CustomButton(
                variant: CustomButtonVariant.FlatButton,
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
                          if (selectedGeneratedImageIndex != null) {
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
  }

  ThemeConfigurationForApp getAdditionalSettingsTile() {
    return ThemeConfigurationForApp(
      child: ExpansionTile(
        enableFeedback: false,
        title: Text(S.of(context).additionalSettings),
        textColor: darkTextColor,
        iconColor: darkColor,
        collapsedIconColor: darkColor,
        collapsedTextColor: darkTextColor,
        shape: Border.all(color: Colors.transparent, width: 0),
        collapsedShape: Border.all(color: Colors.transparent, width: 0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SelectableTile(
                  onValueChange: () {
                    setState(() {
                      hideStatFromCharacterScreens =
                          !hideStatFromCharacterScreens;
                    });
                  },
                  isSet: hideStatFromCharacterScreens,
                  label: S.of(context).hidePropertyForCharacter,
                ),
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
                      hideLabelOfStat = !hideLabelOfStat;
                    });
                  },
                  isSet: hideLabelOfStat,
                  label: S.of(context).hideHeading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
        return getCurrentStatValueOrDefaultForTextType();
      case CharacterStatValueType.companionSelector:
        return getCurrentStatValueOrDefaultForCompanionSelectorType();
      case CharacterStatValueType.singleImage:
        return getCurrentStatValueOrDefaultForSingleImageType();
      case CharacterStatValueType.int:
        return getCurrentStatValueOrDefaultForIntType();
      case CharacterStatValueType.intWithMaxValue:
        return getCurrentStatValueOrDefaultForIntWithMaxValueType();
      case CharacterStatValueType.intWithCalculatedValue:
        return getCurrentStatValueOrDefaultForIntWithCalculatedValueType();
      case CharacterStatValueType.multiselect:
        return getCurrentStatValueOrDefaultForMultiselectType();
      case CharacterStatValueType.listOfIntsWithIcons:
        return getCurrentStatValueOrDefaultForListOfIntsWithIconsType();
      case CharacterStatValueType.listOfIntWithCalculatedValues:
        return getCurrentStatValueOrDefaultForListOfIntsWithCalculatedValueType();
      case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
        return getCurrentStatValueOrDefaultForCharacterNameWithLevelType();
    }
  }

  RpgCharacterStatValue
      getCurrentStatValueOrDefaultForCharacterNameWithLevelType() {
    List<Map<String, dynamic>> filledValuesForlistOfSingleValueOptions =
        listOfSingleValueOptions
            .where((t) => t.uuid.isNotEmpty)
            .map((e) => {
                  "uuid": e.uuid,
                  "value": e.valueTextController.text,
                })
            .toList();
    // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}

    var foundLevel = listOfSingleValueOptions
        .firstWhereOrNull((t) => t.uuid.isEmpty)
        ?.valueTextController
        .text;

    return RpgCharacterStatValue(
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      hideLabelOfStat: hideLabelOfStat,
      variant: 0,
      serializedValue: jsonEncode({
        "level": (foundLevel != null ? int.tryParse(foundLevel) : null) ?? 0,
        "values": filledValuesForlistOfSingleValueOptions,
      }),
      statUuid: widget.statConfiguration.statUuid,
    );
  }

  RpgCharacterStatValue
      getCurrentStatValueOrDefaultForListOfIntsWithCalculatedValueType() {
    List<Map<String, dynamic>> filledValuesForlistOfIntWithCalculatedValues =
        listOfIntWithOtherValueOptions
            .map((e) => {
                  "uuid": e.uuid,
                  "value": int.tryParse(e.valueTextController.text) ?? 0,
                  "otherValue":
                      int.tryParse(e.otherValueTextController.text) ?? 0,
                })
            .toList();
    // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
    return RpgCharacterStatValue(
      hideLabelOfStat: hideLabelOfStat,
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      variant: 0,
      serializedValue: jsonEncode({
        "values": filledValuesForlistOfIntWithCalculatedValues,
      }),
      statUuid: widget.statConfiguration.statUuid,
    );
  }

  RpgCharacterStatValue
      getCurrentStatValueOrDefaultForListOfIntsWithIconsType() {
    List<Map<String, dynamic>> filledValuesForlistOfSingleValueOptions =
        listOfSingleValueOptions
            .where((t) => t.uuid.isNotEmpty)
            .map((e) => {
                  "uuid": e.uuid,
                  "value": int.tryParse(e.valueTextController.text) ?? 0,
                })
            .toList();
    // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12,}]}

    return RpgCharacterStatValue(
      hideLabelOfStat: hideLabelOfStat,
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      variant: 0,
      serializedValue: jsonEncode({
        "values": filledValuesForlistOfSingleValueOptions,
      }),
      statUuid: widget.statConfiguration.statUuid,
    );
  }

  RpgCharacterStatValue getCurrentStatValueOrDefaultForMultiselectType() {
    List<String> selectedMultiselectOptionsOrDefault = multiselectOptions
        .where((e) => e.$5 > 0)
        .map((e) => List.filled(e.$5, e.$4))
        .expand((i) => i)
        .toList();
    return RpgCharacterStatValue(
      hideLabelOfStat: hideLabelOfStat,
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      variant: 0,
      serializedValue: jsonEncode({
        "values": selectedMultiselectOptionsOrDefault,
      }),
      statUuid: widget.statConfiguration.statUuid,
    );
  }

  RpgCharacterStatValue
      getCurrentStatValueOrDefaultForIntWithCalculatedValueType() {
    var currentOrDefaultIntValue = int.tryParse(textEditController.text) ?? 0;
    var currentOrDefaultOtherIntValue =
        int.tryParse(textEditController2.text) ?? 0;
    return RpgCharacterStatValue(
      hideLabelOfStat: hideLabelOfStat,
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      variant: 0,
      serializedValue: jsonEncode({
        "value": currentOrDefaultIntValue,
        "otherValue": currentOrDefaultOtherIntValue,
      }),
      statUuid: widget.statConfiguration.statUuid,
    );
  }

  RpgCharacterStatValue getCurrentStatValueOrDefaultForIntWithMaxValueType() {
    var currentOrDefaultIntValue = int.tryParse(textEditController.text) ?? 0;
    var currentOrDefaultMaxIntValue =
        int.tryParse(textEditController2.text) ?? 0;
    return RpgCharacterStatValue(
      hideLabelOfStat: hideLabelOfStat,
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      variant: 0,
      serializedValue: jsonEncode({
        "value": currentOrDefaultIntValue,
        "maxValue": currentOrDefaultMaxIntValue,
      }),
      statUuid: widget.statConfiguration.statUuid,
    );
  }

  RpgCharacterStatValue getCurrentStatValueOrDefaultForIntType() {
    var currentOrDefaultIntValue = int.tryParse(textEditController.text) ?? 0;
    return RpgCharacterStatValue(
      hideLabelOfStat: hideLabelOfStat,
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      variant: 0,
      serializedValue: jsonEncode({"value": currentOrDefaultIntValue}),
      statUuid: widget.statConfiguration.statUuid,
    );
  }

  RpgCharacterStatValue getCurrentStatValueOrDefaultForSingleImageType() {
    var currentOrDefaultTextValue =
        textEditController.text.isEmpty ? "" : textEditController.text;
    return RpgCharacterStatValue(
      hideLabelOfStat: hideLabelOfStat,
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      variant: 0,
      serializedValue: jsonEncode({
        "value": currentOrDefaultTextValue,
        "imageUrl":
            urlsOfGeneratedImages.isEmpty || selectedGeneratedImageIndex == null
                ? "assets/images/charactercard_placeholder.png"
                : urlsOfGeneratedImages[selectedGeneratedImageIndex ?? 0]
      }),
      statUuid: widget.statConfiguration.statUuid,
    );
  }

  RpgCharacterStatValue getCurrentStatValueOrDefaultForCompanionSelectorType() {
    return RpgCharacterStatValue(
      hideLabelOfStat: hideLabelOfStat,
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      variant: 0,
      serializedValue: jsonEncode({
        "values": selectedCompanions.map((st) => {"uuid": st}).toList()
      }),
      statUuid: widget.statConfiguration.statUuid,
    );
  }

  RpgCharacterStatValue getCurrentStatValueOrDefaultForTextType() {
    var currentOrDefaultTextValue =
        textEditController.text.isEmpty ? "" : textEditController.text;
    return RpgCharacterStatValue(
      hideLabelOfStat: hideLabelOfStat,
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      variant: 0,
      serializedValue: jsonEncode({"value": currentOrDefaultTextValue}),
      statUuid: widget.statConfiguration.statUuid,
    );
  }

  Widget getConfigurationWidgetsForMultiSelect() {
    // characterValue.serializedValue = {"values": ["DEX", "WIS"]}
    var statTitle = widget.statConfiguration.name;
    var statDescription = widget.statConfiguration.helperText;

    var multiselectIsAllowedToBeSelectedMultipleTimes = widget
                    .statConfiguration.jsonSerializedAdditionalData ==
                null ||
            widget.statConfiguration.jsonSerializedAdditionalData
                    ?.startsWith("[") ==
                true
        ? false
        : ((jsonDecode(widget.statConfiguration.jsonSerializedAdditionalData!)
                    as Map<String, dynamic>)[
                "multiselectIsAllowedToBeSelectedMultipleTimes"] ??
            false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: statTitle, statDescription: statDescription),
        ...multiselectOptions.asMap().entries.sortedBy((e) => e.value.$1).map(
              (e) => multiselectIsAllowedToBeSelectedMultipleTimes == false
                  ? CheckboxListTile.adaptive(
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      splashRadius: 0,
                      dense: true,
                      checkColor: const Color.fromARGB(255, 57, 245, 88),
                      activeColor: darkColor,
                      visualDensity: VisualDensity(vertical: -2),
                      title: Text(
                        e.value.$1,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: darkTextColor, fontSize: 16),
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
                            e.value.$4,
                            e.value.$5
                          );

                          multiselectOptions = deepCopy;
                        });
                      },
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomIntEditField(
                          minValue: 0,
                          maxValue: 10,
                          onValueChange: (newValue) {
                            setState(() {
                              var deepCopy = [...multiselectOptions];

                              deepCopy[e.key] = (
                                e.value.$1,
                                e.value.$2,
                                newValue > 0,
                                e.value.$4,
                                newValue,
                              );

                              multiselectOptions = deepCopy;
                            });
                          },
                          label: S.of(context).count,
                          startValue: e.value.$5,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                e.value.$1,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: darkTextColor, fontSize: 16),
                              ),
                              Text(
                                e.value.$2,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(color: darkTextColor),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
            ),
      ],
    );
  }

  Widget getConfigurationWidgetsForListOfIntsWithCalculatedValues() {
    // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
    // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
    var statTitle = widget.statConfiguration.name;
    var statDescription = widget.statConfiguration.helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: statTitle, statDescription: statDescription),
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
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          "${e.value.label}:",
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
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
                        labelText: S.of(context).firstValue,
                        textEditingController: e.value.valueTextController,
                        placeholderText: S.of(context).firstValuePlaceholder,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: CustomTextField(
                        labelText: S.of(context).secondValue,
                        textEditingController: e.value.otherValueTextController,
                        keyboardType: TextInputType.number,
                        placeholderText: S.of(context).secondValuePlaceholder,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                )),
      ],
    );
  }

  Widget getConfigurationWidgetsForBunchOfTextValues() {
    // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12}]}
    // => statConfiguration.jsonSerializedAdditionalData! == {"level": 0, "values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
    var statTitle = widget.statConfiguration.name;
    var statDescription = widget.statConfiguration.helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: statTitle, statDescription: statDescription),
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
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          "${e.value.label}:",
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
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
                        textEditingController: e.value.valueTextController,
                        placeholderText: S
                            .of(context)
                            .valueOfPropertyWithName(e.value.label),
                        keyboardType: widget.statConfiguration.valueType ==
                                CharacterStatValueType.listOfIntsWithIcons
                            ? TextInputType.number
                            : TextInputType.text,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                )),
      ],
    );
  }

  Widget getConfigurationWidgetsForIntWithMaxValue() {
    var statTitle = widget.statConfiguration.name;
    var statDescription = widget.statConfiguration.helperText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: statTitle, statDescription: statDescription),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                labelText: S.of(context).currentValue,
                placeholderText: S.of(context).currentValuePlaceholder,
                textEditingController: textEditController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: CustomTextField(
                labelText: S.of(context).maxValue,
                placeholderText: S.of(context).maxValuePlaceholder,
                textEditingController: textEditController2,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget getConfigurationWidgetsForIntWithCalculatedValue() {
    var statTitle = widget.statConfiguration.name;
    var statDescription = widget.statConfiguration.helperText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: statTitle, statDescription: statDescription),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                labelText: S.of(context).firstValue,
                placeholderText: S.of(context).firstValuePlaceholder,
                textEditingController: textEditController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: CustomTextField(
                labelText: S.of(context).calculatedValue,
                placeholderText: S.of(context).calculatedValuePlaceholder,
                textEditingController: textEditController2,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget getConfigurationWidgetsForCompanionsSelector() {
    var statTitle = widget.statConfiguration.name;
    var statDescription = widget.statConfiguration.helperText;

    var selectableCompanions = ref
            .watch(rpgCharacterConfigurationProvider)
            .requireValue
            .companionCharacters ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: statTitle, statDescription: statDescription),
        ...selectableCompanions
            .asMap()
            .entries
            .sortedBy((e) => e.value.characterName)
            .map(
              (e) => CheckboxListTile.adaptive(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                splashRadius: 0,
                dense: true,
                checkColor: const Color.fromARGB(255, 57, 245, 88),
                activeColor: darkColor,
                visualDensity: VisualDensity(vertical: -2),
                title: Text(
                  e.value.characterName,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: darkTextColor, fontSize: 16),
                ),
                value: selectedCompanions.contains(e.value.uuid),
                onChanged: (newValue) {
                  if (newValue == null) return;
                  setState(() {
                    var deepCopy = [...selectedCompanions];

                    if (newValue == true) {
                      // add to selected companions
                      deepCopy.add(e.value.uuid);
                    } else {
                      deepCopy.remove(e.value.uuid);
                    }

                    selectedCompanions = deepCopy;
                  });
                },
              ),
            ),
        SizedBox(
          height: 20,
        ),

        // Add new companion to list!
        CustomButton(
          onPressed: () {
            // TODO open modal, ask player for new companion name and add to rpgCharacterConfig

            var newestCharacter =
                ref.read(rpgCharacterConfigurationProvider).requireValue;

            ref
                .read(rpgCharacterConfigurationProvider.notifier)
                .updateConfiguration(
                    newestCharacter.copyWith(companionCharacters: [
                  ...(newestCharacter.companionCharacters ?? []),
                  RpgAlternateCharacterConfiguration(
                    characterName:
                        "${S.of(context).petDefaultNamePrefix} #${(newestCharacter.companionCharacters ?? []).length + 1}",
                    uuid: UuidV7().generate(),
                    characterStats: [],
                  )
                ]));
          },
          label: S.of(context).newPetBtnLabel,
          variant: CustomButtonVariant.AccentButton,
        )
      ],
    );
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
