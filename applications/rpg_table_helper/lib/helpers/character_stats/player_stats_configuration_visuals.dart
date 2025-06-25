import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_int_edit_field.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/modals/show_create_new_character_transformation_wizard.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/image_generation_service.dart';
import 'package:uuid/v7.dart';

class PlayerStatsConfigurationVisuals extends ConsumerStatefulWidget {
  const PlayerStatsConfigurationVisuals({
    super.key,
    required this.statConfiguration,
    required this.characterName,
    required this.characterToRenderStatFor,
    required this.onNewStatValue,
    this.characterValue,
    this.hideVariantSelection = false,
    this.hideAdditionalSetting = false,
  });
  final void Function(RpgCharacterStatValue) onNewStatValue;

  final bool hideVariantSelection;
  final bool hideAdditionalSetting;
  final String? characterName;
  final RpgCharacterConfiguration? characterToRenderStatFor;
  final CharacterStatDefinition statConfiguration;
  final RpgCharacterStatValue? characterValue;

  @override
  ConsumerState<PlayerStatsConfigurationVisuals> createState() =>
      _PlayerStatsConfigurationVisualsState();
}

class _PlayerStatsConfigurationVisualsState
    extends ConsumerState<PlayerStatsConfigurationVisuals> {
  var textController = TextEditingController();
  var textController2 = TextEditingController();

  List<String> urlsOfGeneratedImages = [];
  List<String> selectedCompanions = [];
  int? selectedGeneratedImageIndex;
  bool isLoading = false;

  bool hideStatFromCharacterScreens = false;
  bool hideLabelOfStat = false;
  bool showTransformationConfiguration = false;

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

  bool isWidgetLoadingComplete = false;
  void onChanged() {
    if (isWidgetLoadingComplete == false) return;
    var newStatValue = getCurrentStatValueOrDefault();
    newStatValue = newStatValue.copyWith(variant: currentlyVisibleVariant);
    widget.onNewStatValue(newStatValue);
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

          var textEditingController = TextEditingController(
              text:
                  matchingValue == null ? "" : matchingValue.value.toString());
          var textEditingController2 = TextEditingController(
              text: matchingValue == null
                  ? ""
                  : matchingValue.otherValue.toString());

          textEditingController.addListener(onChanged);
          textEditingController2.addListener(onChanged);

          return (
            label: e.label,
            valueTextController: textEditingController,
            otherValueTextController: textEditingController2,
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
        CharacterStatValueType.transformIntoAlternateFormBtn) {
      var charConfig = ref.read(rpgCharacterConfigurationProvider).requireValue;
      showTransformationConfiguration =
          charConfig.transformationComponents?.isNotEmpty ?? false;
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

          var textEditingController = TextEditingController(
              text:
                  matchingValue == null ? "" : matchingValue.value.toString());
          textEditingController.addListener(onChanged);

          return (
            label: e.label,
            valueTextController: textEditingController,
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
      onChanged();
    });

    setState(() {
      hideStatFromCharacterScreens =
          widget.characterValue?.hideFromCharacterScreen ?? false;
      hideLabelOfStat = widget.characterValue?.hideLabelOfStat ?? false;
      onChanged();
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
        textController = TextEditingController();
        textController2 = TextEditingController();

        textController.addListener(onChanged);
        textController2.addListener(onChanged);
      } else {
        Map<String, dynamic> tempDecode =
            jsonDecode(widget.characterValue!.serializedValue);
        var parsedValue = tempDecode["value"];
        textController = TextEditingController(text: parsedValue.toString());
        textController.addListener(onChanged);

        // for CharacterStatValueType.intWithMaxValue
        if (tempDecode.containsKey("maxValue")) {
          textController2 =
              TextEditingController(text: tempDecode["maxValue"].toString());
          textController2.addListener(onChanged);
        }
        // for CharacterStatValueType.intWithCalculatedValue
        if (tempDecode.containsKey("otherValue")) {
          textController2 =
              TextEditingController(text: tempDecode["otherValue"].toString());
          textController2.addListener(onChanged);
        }

        // for CharacterStatValueType.singleImage
        // {"imageUrl": "someUrl", "value": "some text"}
        if (tempDecode.containsKey("imageUrl")) {
          urlsOfGeneratedImages = [tempDecode["imageUrl"]];
          selectedGeneratedImageIndex = 0;
        }
      }
    }

    setState(() {
      isWidgetLoadingComplete = true;
    });
  }

  bool get showPreview =>
      (showTransformationConfiguration ||
          widget.statConfiguration.valueType !=
              CharacterStatValueType.transformIntoAlternateFormBtn) &&
      !widget.hideVariantSelection;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            case CharacterStatValueType.transformIntoAlternateFormBtn:
              return getConfigurationWidgetsForTransformIntoAlternateFormBtn();

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

        if (showPreview) getPreviewAndVariantSelector(context),
      ],
    );
  }

  Column getPreviewAndVariantSelector(BuildContext context) {
    return Column(
      children: [
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
            "${S.of(context).preview}:",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: CustomThemeProvider.of(context).theme.darkTextColor,
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
        SizedBox(
          height: 400,
          child: PageView(
              controller: pageController,
              children: List.generate(
                numberOfVariantsForValueTypes(
                    widget.statConfiguration.valueType),
                (index) {
                  var statValue =
                      getCurrentStatValueOrDefault().copyWith(variant: index);
                  return Align(
                    key: ValueKey(statValue),
                    alignment: Alignment.topCenter,
                    child: Container(
                      // decoration: BoxDecoration(
                      //     border: Border.all(color: CustomThemeProvider.of(context).theme.CustomThemeProvider.of(context).theme.darkTextColor),
                      //     borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.all(10),
                      child: getPlayerVisualizationWidget(
                          characterToRenderStatFor:
                              widget.characterToRenderStatFor,
                          onNewStatValue: (newSerializedValue) {
                            // The player should not be allowed to edit their character from the preview and hence we ignore this callback
                          },
                          context: context,
                          statConfiguration: widget.statConfiguration,
                          characterValue: statValue,
                          characterName: widget.characterName ?? "Player Name"),
                    ),
                  );
                },
              ),
              onPageChanged: (value) {
                setState(() {
                  currentlyVisibleVariant = value;
                  onChanged();
                });
              }),
        ),
      ],
    );
  }

  Widget getConfigurationWidgetsForInt() {
    // characterValue.serializedValue = {"value": 17}

    return Column(
      children: [
        CustomTextField(
          labelText: widget.statConfiguration.name,
          placeholderText: widget.statConfiguration.helperText,
          textEditingController: textController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget getConfigurationWidgetsForTextBlock() {
    // characterValue.serializedValue = {"value": "asdf"}

    return CustomTextField(
      labelText: widget.statConfiguration.name,
      placeholderText: widget.statConfiguration.helperText,
      textEditingController: textController,
      keyboardType: widget.statConfiguration.valueType ==
              CharacterStatValueType.multiLineText
          ? TextInputType.multiline
          : TextInputType.text,
    );
  }

  Widget getConfigurationWidgetsForSingleImage(BuildContext context) {
    // characterValue.serializedValue = {"imageUrl": "someUrl", "value": "some text"}
    return Column(
      children: [
        CustomTextField(
          labelText: widget.statConfiguration.name,
          placeholderText: widget.statConfiguration.helperText,
          textEditingController: textController,
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
              lightColor: CustomThemeProvider.of(context).theme.darkColor,
              backgroundColor: CustomThemeProvider.of(context).theme.bgColor,
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
                      ? CustomThemeProvider.of(context).theme.middleBgColor
                      : CustomThemeProvider.of(context).theme.darkColor,
                ),
                onPressed: isShowPreviousGeneratedImageButtonDisabled
                    ? null
                    : () {
                        setState(() {
                          if (selectedGeneratedImageIndex != null) {
                            selectedGeneratedImageIndex =
                                max(selectedGeneratedImageIndex! - 1, 0);
                            onChanged();
                          }
                        });
                      }),
            Spacer(),
            CupertinoButton(
              onPressed: isLoading == true
                  ? null
                  : () async {
                      if (textController.text == "" ||
                          textController.text.length < 5) {
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
                        prompt: textController.text,
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
                          onChanged();
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
                      color: isLoading
                          ? CustomThemeProvider.of(context).theme.middleBgColor
                          : CustomThemeProvider.of(context).theme.accentColor,
                      decoration: TextDecoration.underline,
                      decorationColor: isLoading
                          ? CustomThemeProvider.of(context).theme.middleBgColor
                          : CustomThemeProvider.of(context).theme.accentColor,
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
                      ? CustomThemeProvider.of(context).theme.middleBgColor
                      : CustomThemeProvider.of(context).theme.darkColor,
                ),
                onPressed: isShowNextGeneratedButtonDisabled
                    ? null
                    : () {
                        setState(() {
                          if (selectedGeneratedImageIndex != null) {
                            selectedGeneratedImageIndex = min(
                                selectedGeneratedImageIndex! + 1,
                                urlsOfGeneratedImages.length - 1);
                            onChanged();
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
        textColor: CustomThemeProvider.of(context).theme.darkTextColor,
        iconColor: CustomThemeProvider.of(context).theme.darkColor,
        collapsedIconColor: CustomThemeProvider.of(context).theme.darkColor,
        collapsedTextColor: CustomThemeProvider.of(context).theme.darkTextColor,
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
                      onChanged();
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
                      onChanged();
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
      case CharacterStatValueType.transformIntoAlternateFormBtn:
        return getCurrentStatValueOrDefaultForTransformIntoAlternateFormBtn();
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
      getCurrentStatValueOrDefaultForTransformIntoAlternateFormBtn() {
    return RpgCharacterStatValue(
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      hideLabelOfStat: hideLabelOfStat,
      variant: 0,
      serializedValue: "{}",
      statUuid: widget.statConfiguration.statUuid,
    );
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

    // => RpgCharacterStatValue.serializedValue == {"level": 12, "values":[{"uuid":"5f515750-0456-41e7-a1ee-97acb30c25c0", "value": 12}]}
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

    List<String> selectedMultiselectOptionsOrDefault = multiselectOptions
        .where((e) => (multiselectIsAllowedToBeSelectedMultipleTimes == true)
            ? (e.$5 > 0)
            : (e.$3 == true))
        .map((e) => List.filled(
            multiselectIsAllowedToBeSelectedMultipleTimes ? e.$5 : 1, e.$4))
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
    var currentOrDefaultIntValue = int.tryParse(textController.text) ?? 0;
    var currentOrDefaultOtherIntValue = int.tryParse(textController2.text) ?? 0;
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
    var currentOrDefaultIntValue = int.tryParse(textController.text) ?? 0;
    var currentOrDefaultMaxIntValue = int.tryParse(textController2.text) ?? 0;
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
    var currentOrDefaultIntValue = int.tryParse(textController.text) ?? 0;
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
        textController.text.isEmpty ? "" : textController.text;
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
        textController.text.isEmpty ? "" : textController.text;
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
        _PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: statTitle, statDescription: statDescription),
        ...multiselectOptions.asMap().entries.sortedBy((e) => e.value.$1).map(
              (e) => multiselectIsAllowedToBeSelectedMultipleTimes == false
                  ? CheckboxListTile.adaptive(
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      splashRadius: 0,
                      dense: true,
                      checkColor: const Color.fromARGB(255, 57, 245, 88),
                      activeColor:
                          CustomThemeProvider.of(context).theme.darkColor,
                      visualDensity: VisualDensity(vertical: -2),
                      title: Text(
                        e.value.$1,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor,
                                fontSize: 16),
                      ),
                      subtitle: Text(
                        e.value.$2,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor),
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
                          onChanged();
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
                              onChanged();
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
                                        color: CustomThemeProvider.of(context)
                                            .theme
                                            .darkTextColor,
                                        fontSize: 16),
                              ),
                              Text(
                                e.value.$2,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: CustomThemeProvider.of(context)
                                            .theme
                                            .darkTextColor),
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
        _PlayerConfigModalNonDefaultTitleAndHelperText(
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
                                    color: CustomThemeProvider.of(context)
                                        .theme
                                        .darkTextColor,
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

    if ((statTitle == "") &&
        widget.statConfiguration.valueType ==
            CharacterStatValueType.listOfIntsWithIcons) {
      statTitle = listOfSingleValueOptions
          .asMap()
          .entries
          .sortedBy((e) => e.value.label)
          .map((e) => e.value.label)
          .join(", ");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlayerConfigModalNonDefaultTitleAndHelperText(
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
                                    color: CustomThemeProvider.of(context)
                                        .theme
                                        .darkTextColor,
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
        _PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: statTitle, statDescription: statDescription),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                labelText: S.of(context).currentValue,
                placeholderText: S.of(context).currentValuePlaceholder,
                textEditingController: textController,
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
                textEditingController: textController2,
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
        _PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: statTitle, statDescription: statDescription),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                labelText: S.of(context).firstValue,
                placeholderText: S.of(context).firstValuePlaceholder,
                textEditingController: textController,
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
                textEditingController: textController2,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget getConfigurationWidgetsForTransformIntoAlternateFormBtn() {
    var statTitle = widget.statConfiguration.name;
    var statDescription = widget.statConfiguration.helperText;

    var configuredTransformationComponents = ref
            .watch(rpgCharacterConfigurationProvider)
            .requireValue
            .transformationComponents ??
        [];

    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlayerConfigModalNonDefaultTitleAndHelperText(
              statTitle: statTitle, statDescription: statDescription),

          SizedBox(
            height: 20,
          ),

          CupertinoSlidingSegmentedControl<bool>(
            backgroundColor:
                CustomThemeProvider.of(context).theme.middleBgColor,
            thumbColor: CustomThemeProvider.of(context).theme.darkColor,
            // This represents the currently selected segmented control.
            groupValue: showTransformationConfiguration,
            // Callback that sets the selected segmented control.
            onValueChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  showTransformationConfiguration = value;
                });
              }
            },
            children: <bool, Widget>{
              false: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  S.of(context).no,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontSize: 16,
                      color: showTransformationConfiguration == false
                          ? CustomThemeProvider.of(context).theme.textColor
                          : CustomThemeProvider.of(context)
                              .theme
                              .darkTextColor),
                ),
              ),
              true: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  S.of(context).yes,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontSize: 16,
                      color: showTransformationConfiguration == true
                          ? CustomThemeProvider.of(context).theme.textColor
                          : CustomThemeProvider.of(context)
                              .theme
                              .darkTextColor),
                ),
              ),
            },
          ),

          SizedBox(
            height: 20,
          ),

          if (showTransformationConfiguration)
            ...configuredTransformationComponents.map(
              (e) => Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.transformationName,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  color: CustomThemeProvider.of(context)
                                      .theme
                                      .darkTextColor,
                                  fontSize: 16),
                        ),
                        Text(
                          e.transformationDescription ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  color: CustomThemeProvider.of(context)
                                      .theme
                                      .darkTextColor,
                                  fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 70,
                    clipBehavior: Clip.none,
                    child: CustomButton(
                      variant: CustomButtonVariant.FlatButton,
                      onPressed: () async {
                        // open modal, ask player which stats are updated/changed through this transformation, add those stats to configuration and add to char config
                        TransformationComponent?
                            modifiedTransformationComponent =
                            await showCreateNewCharacterTransformationWizard(
                                context,
                                existingTransformationComponents: e);
                        if (modifiedTransformationComponent == null) return;

                        // use this here: rpgConfig
                        var newestCharacter = ref
                            .read(rpgCharacterConfigurationProvider)
                            .requireValue;
                        var listOfTransformations =
                            (newestCharacter.transformationComponents ?? []);

                        var indexOfElement = listOfTransformations.indexWhere(
                            (element) =>
                                element.transformationUuid ==
                                e.transformationUuid);

                        if (indexOfElement == -1) return;

                        listOfTransformations[indexOfElement] =
                            modifiedTransformationComponent;

                        ref
                            .read(rpgCharacterConfigurationProvider.notifier)
                            .updateConfiguration(newestCharacter
                                .copyWith(transformationComponents: [
                              ...listOfTransformations,
                            ]));

                        setState(() {
                          onChanged();
                        });
                      },
                      icon: CustomFaIcon(
                        icon: FontAwesomeIcons.penToSquare,
                        size: 24,
                        color: CustomThemeProvider.of(context).theme.darkColor,
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 70,
                    clipBehavior: Clip.none,
                    child: CustomButton(
                      variant: CustomButtonVariant.FlatButton,
                      onPressed: () {
                        // update rpg char config
                        var newestCharacter = ref
                            .read(rpgCharacterConfigurationProvider)
                            .requireValue;
                        ref
                            .read(rpgCharacterConfigurationProvider.notifier)
                            .updateConfiguration(newestCharacter.copyWith(
                                transformationComponents: newestCharacter
                                    .transformationComponents
                                    ?.where((element) =>
                                        element.transformationUuid !=
                                        e.transformationUuid)
                                    .toList()));
                        setState(() {
                          onChanged();
                        });
                      },
                      icon: CustomFaIcon(
                        icon: FontAwesomeIcons.trashCan,
                        size: 24,
                        color: CustomThemeProvider.of(context).theme.darkColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (showTransformationConfiguration)
            SizedBox(
              height: 20,
            ),

          // Add new transformation component to character
          if (showTransformationConfiguration)
            CustomButton(
              onPressed: () async {
                // open modal, ask player which stats are updated/changed through this transformation, add those stats to configuration and add to char config
                TransformationComponent? newTransformationComponent =
                    await showCreateNewCharacterTransformationWizard(context,
                        existingTransformationComponents: null);
                if (newTransformationComponent == null) return;

                // use this here: rpgConfig
                var newestCharacter =
                    ref.read(rpgCharacterConfigurationProvider).requireValue;

                ref
                    .read(rpgCharacterConfigurationProvider.notifier)
                    .updateConfiguration(
                        newestCharacter.copyWith(transformationComponents: [
                      ...(newestCharacter.transformationComponents ?? []),
                      newTransformationComponent,
                    ]));
                setState(() {
                  onChanged();
                });
              },
              label: S.of(context).addNewTransformationComponent,
              variant: CustomButtonVariant.AccentButton,
            )
        ],
      ),
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
        _PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: statTitle, statDescription: statDescription),
        ...selectableCompanions
            .asMap()
            .entries
            .sortedBy((e) => e.value.characterName)
            .map(
              (e) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CheckboxListTile.adaptive(
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      splashRadius: 0,
                      dense: true,
                      checkColor: const Color.fromARGB(255, 57, 245, 88),
                      activeColor:
                          CustomThemeProvider.of(context).theme.darkColor,
                      visualDensity: VisualDensity(vertical: -2),
                      title: Text(
                        e.value.characterName,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor,
                                fontSize: 16),
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
                          onChanged();
                        });
                      },
                    ),
                  ),
                  CustomButton(
                      icon: CustomFaIcon(
                        icon: FontAwesomeIcons.trashCan,
                        size: 20,
                        color: CustomThemeProvider.of(context).theme.darkColor,
                      ),
                      variant: CustomButtonVariant.FlatButton,
                      onPressed: () {
                        // make this code delete the current pet
                        var newestCharacter = ref
                            .read(rpgCharacterConfigurationProvider)
                            .requireValue;

                        ref
                            .read(rpgCharacterConfigurationProvider.notifier)
                            .updateConfiguration(
                                newestCharacter.copyWith(companionCharacters: [
                              ...(newestCharacter.companionCharacters ?? [])
                                  .where((element) =>
                                      element.uuid != e.value.uuid),
                            ]));
                        setState(() {
                          onChanged();
                        });
                      })
                ],
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
                    alternateForm: null,
                    isAlternateFormActive: null,
                    characterName:
                        "${S.of(context).petDefaultNamePrefix} #${(newestCharacter.companionCharacters ?? []).length + 1}",
                    uuid: UuidV7().generate(),
                    transformationComponents: null,
                    characterStats: [],
                  )
                ]));
            setState(() {
              onChanged();
            });
          },
          label: S.of(context).newPetBtnLabel,
          variant: CustomButtonVariant.AccentButton,
        )
      ],
    );
  }
}

class _PlayerConfigModalNonDefaultTitleAndHelperText extends StatelessWidget {
  const _PlayerConfigModalNonDefaultTitleAndHelperText({
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
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 16,
              ),
        ),
        SizedBox(
          height: 0,
        ),
        Text(
          statDescription,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
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
