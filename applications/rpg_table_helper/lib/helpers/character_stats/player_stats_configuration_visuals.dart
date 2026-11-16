import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_int_edit_field.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/stat_types/checkbox_track_view.dart';
import 'package:quest_keeper/components/stat_types/option_card.dart';
import 'package:quest_keeper/components/stat_types/unsupported_stat_view.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_stats/character_portrait.dart';
import 'package:quest_keeper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:quest_keeper/helpers/character_stats/stat_style_names.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/modals/show_create_new_character_transformation_wizard.dart';
import 'package:quest_keeper/helpers/number_input.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/backend_capabilities_service.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/image_generation_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/snack_bar_service.dart';
import 'package:themed/themed.dart';
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
    this.collapsiblePreview = false,
    this.onValidityChanged,
  });
  final void Function(RpgCharacterStatValue) onNewStatValue;

  /// Called with false while a number field holds input that is not a valid
  /// whole number (or the level is not a valid level), and with true once all
  /// inputs are valid again. Hosts block saving while it is false, so text is
  /// never stored as 0.
  final void Function(bool isValid)? onValidityChanged;

  /// Shows the preview and variant selector folded in an expandable tile
  /// (used by the per-tab form, where many fields share one page).
  final bool collapsiblePreview;

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

  /// Whether the connected backend supports uploading a device image for a
  /// character portrait. Defaults to the baseline (the upload endpoint predates
  /// the capabilities endpoint, so it is guaranteed even on older backends);
  /// refined once [IBackendCapabilitiesService] has loaded.
  bool supportsCharacterImageUpload =
      kBaselineBackendCapabilities.contains(BackendCapability.characterImageUpload);

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

  // checkboxTrack: 0-based indices of the ticked boxes
  Set<int> checkboxTrackChecked = {};

  // textList: one field per fixed slot (by slot uuid) and the player's own
  // entries in order
  Map<String, TextEditingController> textListSlotControllers = {};
  List<({String uuid, TextEditingController controller})> textListOwnEntries =
      [];

  // singleSelect: uuid of the chosen option
  String? singleSelectSelectedUuid;

  late PageController pageController;

  int currentlyVisibleVariant = 0;

  /// Throwaway value the player is "test-driving" in the interactive preview
  /// (e.g. tapping the health bar's +/- buttons). Null means the preview shows
  /// the configured value from [getCurrentStatValueOrDefault]. This is never
  /// persisted: preview interactions update this field only and deliberately
  /// bypass [widget.onNewStatValue], so a test tap can never leak into the
  /// saved character value. It is cleared whenever the config form changes so
  /// stale test state cannot mask the real configuration.
  String? _previewTestSerializedValue;

  @override
  void initState() {
    pageController = PageController(
      initialPage: widget.characterValue?.variant ?? 0,
    );

    Future.delayed(Duration.zero, delayedInitState);
    Future.delayed(Duration.zero, _loadBackendCapabilities);
    super.initState();
  }

  Future<void> _loadBackendCapabilities() async {
    if (!mounted) return;

    // Only the image-bearing stat types render the upload control, so there is
    // nothing to gate for the others.
    final valueType = widget.statConfiguration.valueType;
    if (valueType != CharacterStatValueType.singleImage &&
        valueType !=
            CharacterStatValueType.characterNameWithLevelAndAdditionalDetails) {
      return;
    }

    try {
      final service = DependencyProvider.of(context)
          .getService<IBackendCapabilitiesService>();
      final capabilities = await service.ensureCapabilitiesLoaded();
      if (!mounted) return;
      setState(() {
        supportsCharacterImageUpload =
            capabilities.contains(BackendCapability.characterImageUpload);
      });
    } catch (_) {
      // DependencyProvider may be unavailable in some harnesses; keep the
      // baseline default (upload supported) rather than crashing.
    }
  }

  bool isWidgetLoadingComplete = false;
  void onChanged() {
    if (isWidgetLoadingComplete == false) return;
    var newStatValue = getCurrentStatValueOrDefault();
    newStatValue = newStatValue.copyWith(variant: currentlyVisibleVariant);
    widget.onNewStatValue(newStatValue);
    _reportValidity();
  }

  /// Last valid level, so an invalid entry never turns into level 0.
  int? _lastValidLevel;

  bool? _lastReportedValidity;
  void _reportValidity() {
    final isValid = areAllInputsValid;
    if (_lastReportedValidity == isValid) return;
    _lastReportedValidity = isValid;
    widget.onValidityChanged?.call(isValid);
  }

  /// The level entry of a characterNameWithLevelAndAdditionalDetails stat
  /// (stored under the empty uuid next to the configurable detail values).
  TextEditingController? get _levelController => listOfSingleValueOptions
      .firstWhereOrNull((t) => t.uuid.isEmpty)
      ?.valueTextController;

  /// False while a number field holds text that is not a whole number, or
  /// the level is not a whole number of 0 or more.
  bool get areAllInputsValid {
    switch (widget.statConfiguration.valueType) {
      case CharacterStatValueType.int:
      case CharacterStatValueType.intWithMaxValue:
      case CharacterStatValueType.intWithCalculatedValue:
        return isEmptyOrSignedInt(textController.text) &&
            isEmptyOrSignedInt(textController2.text);
      case CharacterStatValueType.listOfIntWithCalculatedValues:
        return listOfIntWithOtherValueOptions.every((e) =>
            isEmptyOrSignedInt(e.valueTextController.text) &&
            isEmptyOrSignedInt(e.otherValueTextController.text));
      case CharacterStatValueType.listOfIntsWithIcons:
        return listOfSingleValueOptions
            .every((e) => isEmptyOrSignedInt(e.valueTextController.text));
      case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
        final level = _levelController;
        return level == null || parseCharacterLevel(level.text) != null;
      default:
        return true;
    }
  }

  /// A whole-number input with a signed keyboard (so -1 can be typed) and an
  /// inline error while the text is not a whole number.
  Widget _intTextField({
    required String labelText,
    required TextEditingController controller,
    String? placeholderText,
    bool isLevel = false,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final String? errorText;
        if (isLevel) {
          errorText = parseCharacterLevel(value.text) == null
              ? S.of(context).invalidLevelInput
              : null;
        } else {
          errorText = isEmptyOrSignedInt(value.text)
              ? null
              : S.of(context).invalidWholeNumberInput;
        }
        return CustomTextField(
          labelText: labelText,
          placeholderText: placeholderText,
          textEditingController: controller,
          keyboardType: signedIntKeyboardType,
          errorText: errorText,
        );
      },
    );
  }

  /// Drops any throwaway preview test state when the configured value changes,
  /// so the interactive preview reflects the new baseline rather than a stale
  /// tap. Attached to the value-bearing fields; a no-op unless the sandbox is
  /// currently dirty. Distinct from a variant swipe, which must keep the
  /// tested value (the value is shared across variants).
  void clearPreviewSandboxOnConfigEdit() {
    if (!isWidgetLoadingComplete) return;
    if (_previewTestSerializedValue == null) return;
    setState(() {
      _previewTestSerializedValue = null;
    });
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
        CharacterStatValueType.checkboxTrack) {
      // => characterValue.serializedValue == {"checked": [0, 2]}
      final boxCount =
          CheckboxTrackConfig.of(widget.statConfiguration).boxCount;
      checkboxTrackChecked =
          checkedBoxesOf(widget.characterValue?.serializedValue)
              .where((i) => i >= 0 && i < boxCount)
              .toSet();
    }

    if (widget.statConfiguration.valueType ==
        CharacterStatValueType.textList) {
      // => characterValue.serializedValue == {"values": [{"uuid": "...", "value": "..."}]}
      final config = TextListConfig.of(widget.statConfiguration);
      final entries =
          textListEntriesOf(widget.characterValue?.serializedValue);
      final slotUuids = config.slots.map((s) => s.uuid).toSet();
      textListSlotControllers = {
        for (final slot in config.slots)
          slot.uuid: TextEditingController(
              text: entries
                      .firstWhereOrNull((e) => e.uuid == slot.uuid)
                      ?.value ??
                  "")
            ..addListener(onChanged)
            ..addListener(clearPreviewSandboxOnConfigEdit),
      };
      textListOwnEntries = config.allowCustomEntries
          ? entries
              .where((e) => !slotUuids.contains(e.uuid))
              .map((e) => (
                    uuid: e.uuid,
                    controller: TextEditingController(text: e.value)
                      ..addListener(onChanged)
                      ..addListener(clearPreviewSandboxOnConfigEdit),
                  ))
              .toList()
          : [];
    }

    if (widget.statConfiguration.valueType ==
        CharacterStatValueType.singleSelect) {
      // => characterValue.serializedValue == {"value": "<option uuid>"}
      final selected =
          selectedOptionUuidOf(widget.characterValue?.serializedValue);
      singleSelectSelectedUuid =
          selectOptionsOf(widget.statConfiguration).any((o) => o.uuid == selected)
              ? selected
              : null;
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

      // No level field while the DM switched the level off; the stored level
      // is kept (see _lastValidLevel below).
      if (widget.statConfiguration.valueType ==
              CharacterStatValueType
                  .characterNameWithLevelAndAdditionalDetails &&
          characterSummaryShowsLevel(widget.statConfiguration)) {
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
            value: tempDecode["level"]?.toString() ?? "1"
          ));
          // Keeps the stored level while no level field is shown.
          _lastValidLevel = parseCharacterLevel(tempDecode["level"]?.toString());

          // Optional portrait fields (same shape idea as singleImage)
          // {"imageUrl": "...", "imagePrompt": "..."}
          final imageUrl = tempDecode["imageUrl"] as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            urlsOfGeneratedImages = [imageUrl];
            selectedGeneratedImageIndex = 0;
          }
          textController = TextEditingController(
              text: (tempDecode["imagePrompt"] as String?) ?? "");
          textController.addListener(onChanged);
        }
      } else if (widget.statConfiguration.valueType ==
          CharacterStatValueType.characterNameWithLevelAndAdditionalDetails) {
        textController = TextEditingController();
        textController.addListener(onChanged);
      }
      listOfSingleValueOptions = labelDefinitions.map(
        (e) {
          var matchingValue = filledListOfValues.firstWhereOrNull(
            (element) => element.uuid == e.uuid,
          );

          // A new character starts at level 1 (visible in the field) instead
          // of an empty level that would be stored as 0.
          final isLevelEntry = widget.statConfiguration.valueType ==
                  CharacterStatValueType
                      .characterNameWithLevelAndAdditionalDetails &&
              e.uuid.isEmpty;
          var textEditingController = TextEditingController(
              text: matchingValue == null
                  ? (isLevelEntry ? "1" : "")
                  : matchingValue.value.toString());
          if (isLevelEntry) {
            _lastValidLevel = parseCharacterLevel(textEditingController.text);
          }
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

      // Editing the configured value(s) invalidates any in-progress preview
      // test, so drop the throwaway sandbox when these fields change.
      textController.addListener(clearPreviewSandboxOnConfigEdit);
      textController2.addListener(clearPreviewSandboxOnConfigEdit);
    }

    setState(() {
      isWidgetLoadingComplete = true;
    });

    // Seed the baseline value now that loading is complete. Without this,
    // newestStatValue in the enclosing modal stays null for a stat the user
    // opens but does not touch (e.g. the singleImage portrait, which players
    // routinely skip). Save would then return null, and the first-time stat
    // wizard treats null as "cancelled" and aborts configuring every
    // remaining stat. Seeding makes Save reflect the real (default/empty)
    // form state, so null is reserved for the explicit Cancel/close buttons.
    onChanged();
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

            case CharacterStatValueType.checkboxTrack:
              return getConfigurationWidgetsForCheckboxTrack();

            case CharacterStatValueType.textList:
              return getConfigurationWidgetsForTextList();

            case CharacterStatValueType.singleSelect:
              return getConfigurationWidgetsForSingleSelect();

            case CharacterStatValueType.unsupported:
              return UnsupportedStatView(
                  title: widget.statConfiguration.name);

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

        if (showPreview && !widget.collapsiblePreview)
          getPreviewAndVariantSelector(context),
        if (showPreview && widget.collapsiblePreview)
          ThemeConfigurationForApp(
            child: ExpansionTile(
              enableFeedback: false,
              tilePadding: EdgeInsets.zero,
              title: Text(S.of(context).previewAndVariantTileTitle),
              textColor: CustomThemeProvider.of(context).theme.darkTextColor,
              iconColor: CustomThemeProvider.of(context).theme.darkColor,
              collapsedIconColor:
                  CustomThemeProvider.of(context).theme.darkColor,
              collapsedTextColor:
                  CustomThemeProvider.of(context).theme.darkTextColor,
              shape: Border.all(color: Colors.transparent, width: 0),
              collapsedShape: Border.all(color: Colors.transparent, width: 0),
              children: [getPreviewAndVariantSelector(context)],
            ),
          ),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                "${S.of(context).preview}:",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: CustomThemeProvider.of(context).theme.darkTextColor,
                      fontSize: 24,
                    ),
              ),
            ),
            if (_previewTestSerializedValue != null)
              CustomButton(
                isSubbutton: true,
                variant: CustomButtonVariant.FlatButton,
                label: S.of(context).previewTestReset,
                onPressed: () {
                  setState(() {
                    _previewTestSerializedValue = null;
                  });
                },
                icon: CustomFaIcon(
                  icon: FontAwesomeIcons.arrowRotateLeft,
                  color: CustomThemeProvider.of(context).theme.darkColor,
                ),
              ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            S.of(context).previewTestHint,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: CustomThemeProvider.of(context).theme.darkTextColor,
                  fontSize: 14,
                ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        _buildStylePicker(context),
        SizedBox(
          height: 400,
          child: PageView(
              controller: pageController,
              children: List.generate(
                numberOfVariantsForValueTypes(
                    widget.statConfiguration.valueType),
                (index) {
                  var baseValue = getCurrentStatValueOrDefault();
                  var testValue = _previewTestSerializedValue;
                  var statValue = (testValue != null
                          ? baseValue.copyWith(serializedValue: testValue)
                          : baseValue)
                      .copyWith(variant: index);
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
                            // Sandbox only: let the player test the widget's
                            // interactions (e.g. the health bar's +/- buttons)
                            // by capturing the result in throwaway test state.
                            // This deliberately does NOT call
                            // widget.onNewStatValue, so a test tap never edits
                            // or leaks into the saved character value.
                            setState(() {
                              _previewTestSerializedValue = newSerializedValue;
                            });
                          },
                          context: context,
                          statConfiguration: widget.statConfiguration,
                          characterValue: statValue,
                          characterName: widget.characterName ??
                              S.of(context).characterNameDefault),
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

  /// Name and position of the visible style, with buttons to the previous
  /// and next one (the preview below can also be swiped). Nothing for a
  /// type with a single style.
  Widget _buildStylePicker(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final count =
        numberOfVariantsForValueTypes(widget.statConfiguration.valueType);
    if (count < 2) return const SizedBox(height: 10);

    final names = statStyleNames(s, widget.statConfiguration.valueType);
    final index = currentlyVisibleVariant.clamp(0, count - 1);
    void goTo(int page) => pageController.animateToPage(page,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

    Widget arrow(String key, FaIconData icon, String tooltip, int? target) =>
        IconButton(
          key: ValueKey(key),
          tooltip: tooltip,
          onPressed: target == null ? null : () => goTo(target),
          icon: CustomFaIcon(
            icon: icon,
            size: 18,
            color: target == null
                ? theme.darkTextColor.withValues(alpha: 0.3)
                : theme.darkColor,
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          arrow('statStylePrevious', FontAwesomeIcons.chevronLeft,
              s.statStylePrevious, index > 0 ? index - 1 : null),
          Expanded(
            child: Column(
              children: [
                Text(
                  index < names.length ? names[index] : '',
                  key: const ValueKey('statStyleName'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: theme.darkTextColor,
                        fontSize: 16,
                      ),
                ),
                Text(
                  s.statStylePosition(index + 1, count),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: theme.darkTextColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 4),
                PageViewDotIndicator(
                  currentItem: index,
                  count: count,
                  unselectedColor: theme.middleBgColor,
                  selectedColor: theme.accentColor,
                  duration: const Duration(milliseconds: 200),
                  boxShape: BoxShape.circle,
                  unselectedSize: const Size(6, 6),
                  size: const Size(6, 6),
                ),
              ],
            ),
          ),
          arrow('statStyleNext', FontAwesomeIcons.chevronRight,
              s.statStyleNext, index < count - 1 ? index + 1 : null),
        ],
      ),
    );
  }

  Widget getConfigurationWidgetsForInt() {
    // characterValue.serializedValue = {"value": 17}

    return Column(
      children: [
        _intTextField(
          labelText: widget.statConfiguration.name,
          placeholderText: widget.statConfiguration.helperText,
          controller: textController,
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
        getGeneratedImagePickerControls(context),
      ],
    );
  }

  /// Shared generate / browse UI used by singleImage and identity portrait.
  Widget getGeneratedImagePickerControls(BuildContext context) {
    return Column(
      children: [
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
                    : apiImageUrl(imageUrl));

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
            _buildImageActionButton(
              context,
              label: S.of(context).newImageBtnLabel,
              onPressed: isLoading == true ? null : () => _generateImage(context),
            ),
            if (supportsCharacterImageUpload) ...[
              SizedBox(width: 20),
              _buildImageActionButton(
                context,
                label: S.of(context).uploadImageBtnLabel,
                onPressed:
                    isLoading == true ? null : () => _pickAndUploadImage(context),
              ),
            ],
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
          ],
        ),
      ],
    );
  }

  /// A flat, underlined text action (matches the original "New image" button)
  /// used for both the generate and upload portrait actions.
  Widget _buildImageActionButton(
    BuildContext context, {
    required String label,
    required Future<void> Function()? onPressed,
  }) {
    final disabled = onPressed == null;
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      minimumSize: Size(0, 0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: disabled
                  ? CustomThemeProvider.of(context).theme.middleBgColor
                  : CustomThemeProvider.of(context).theme.accentColor,
              decoration: TextDecoration.underline,
              decorationColor: disabled
                  ? CustomThemeProvider.of(context).theme.middleBgColor
                  : CustomThemeProvider.of(context).theme.accentColor,
              fontSize: 16,
            ),
      ),
    );
  }

  /// Generates a portrait via the AI image service and appends it to the
  /// browsable list of images.
  Future<void> _generateImage(BuildContext context) async {
    if (textController.text == "" || textController.text.length < 5) {
      return;
    }

    var connectionDetails = ref.read(connectionDetailsProvider).requireValue;
    var campagneId = connectionDetails.campagneId;
    if (campagneId == null) return;

    setState(() {
      isLoading = true;
    });

    var service =
        DependencyProvider.of(context).getService<IImageGenerationService>();

    var generationResult = await service.createNewImageAndGetUrl(
      prompt: textController.text,
      campagneId: CampagneIdentifier(value: campagneId),
    );

    if (!context.mounted || !mounted) return;
    await generationResult.possiblyHandleError(context);
    if (!context.mounted || !mounted) return;

    if (generationResult.isSuccessful && generationResult.result != null) {
      setState(() {
        urlsOfGeneratedImages.add(generationResult.result!);
        selectedGeneratedImageIndex = urlsOfGeneratedImages.length - 1;
        onChanged();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  /// Lets the player pick an image from their device and uploads it to the
  /// campagne image storage, then appends the returned url to the browsable
  /// list of portrait images. Mirrors the lore-screen upload flow.
  Future<void> _pickAndUploadImage(BuildContext context) async {
    var connectionDetails = ref.read(connectionDetailsProvider).requireValue;
    var campagneId = connectionDetails.campagneId;
    if (campagneId == null) return;

    final ImagePicker picker = ImagePicker();
    try {
      var pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4196 * 2,
        maxHeight: 4196 * 2,
        requestFullMetadata: false,
      );
      if (pickedFile == null) return;

      setState(() {
        isLoading = true;
      });

      final mimeType = lookupMimeType(pickedFile.path);
      if (mimeType == null || !(mimeType.startsWith('image/'))) {
        if (!context.mounted || !mounted) return;
        DependencyProvider.of(context).getService<ISnackBarService>().showSnackBar(
              uniqueId:
                  "invalidImageFileSelected-c1f0a3d2-6b7e-4c9a-8d2f-9e0b1a2c3d4e",
              snack: SnackBar(
                content: Text(S.of(context).invalidImageFileSelected),
              ),
            );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final fileName = pickedFile.path.split('/').last;
      final multipartFile = await MultipartFile.fromPath(
        'image',
        pickedFile.path,
        contentType: MediaType.parse(mimeType),
        filename: fileName,
      );

      if (!context.mounted || !mounted) return;
      var service =
          DependencyProvider.of(context).getService<IRpgEntityService>();
      var response = await service.uploadImageToCampagneStorage(
        campagneId: CampagneIdentifier(value: campagneId),
        image: multipartFile,
      );

      if (!context.mounted || !mounted) return;
      await response.possiblyHandleError(context);
      if (!context.mounted || !mounted) return;

      if (response.isSuccessful && response.result != null) {
        setState(() {
          urlsOfGeneratedImages.add(response.result!);
          selectedGeneratedImageIndex = urlsOfGeneratedImages.length - 1;
          onChanged();
        });
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
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
      case CharacterStatValueType.checkboxTrack:
        return _statValueWith(serializeCheckedBoxes(checkboxTrackChecked));
      case CharacterStatValueType.textList:
        return _statValueWith(serializeTextListEntries([
          ...textListSlotControllers.entries.map((e) =>
              TextListEntry(uuid: e.key, value: e.value.text.trim())),
          // An own entry left empty is not stored.
          ...textListOwnEntries
              .where((e) => e.controller.text.trim().isNotEmpty)
              .map((e) => TextListEntry(
                  uuid: e.uuid, value: e.controller.text.trim())),
        ]));
      case CharacterStatValueType.singleSelect:
        return _statValueWith(serializeSingleSelect(singleSelectSelectedUuid));
      case CharacterStatValueType.unsupported:
        // Nothing to edit: keep whatever a newer app version stored.
        return _statValueWith(widget.characterValue?.serializedValue ?? "{}");
    }
  }

  RpgCharacterStatValue _statValueWith(String serializedValue) {
    return RpgCharacterStatValue(
      hideLabelOfStat: hideLabelOfStat,
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      variant: 0,
      serializedValue: serializedValue,
      statUuid: widget.statConfiguration.statUuid,
    );
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

    // Never store text as level 0: an invalid entry keeps the last valid
    // level (hosts block saving while the field shows its error).
    final parsedLevel = parseCharacterLevel(foundLevel);
    if (parsedLevel != null) _lastValidLevel = parsedLevel;

    return RpgCharacterStatValue(
      hideFromCharacterScreen: hideStatFromCharacterScreens,
      hideLabelOfStat: hideLabelOfStat,
      variant: 0,
      serializedValue: jsonEncode({
        "level": parsedLevel ?? _lastValidLevel ?? 1,
        "values": filledValuesForlistOfSingleValueOptions,
        "imagePrompt": textController.text,
        "imageUrl":
            urlsOfGeneratedImages.isEmpty || selectedGeneratedImageIndex == null
                ? null
                : urlsOfGeneratedImages[selectedGeneratedImageIndex ?? 0],
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
                  "value": parseSignedInt(e.valueTextController.text) ?? 0,
                  "otherValue":
                      parseSignedInt(e.otherValueTextController.text) ?? 0,
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
                  "value": parseSignedInt(e.valueTextController.text) ?? 0,
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
    var currentOrDefaultIntValue = parseSignedInt(textController.text) ?? 0;
    var currentOrDefaultOtherIntValue =
        parseSignedInt(textController2.text) ?? 0;
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
    var currentOrDefaultIntValue = parseSignedInt(textController.text) ?? 0;
    var currentOrDefaultMaxIntValue = parseSignedInt(textController2.text) ?? 0;
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
    var currentOrDefaultIntValue = parseSignedInt(textController.text) ?? 0;
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
        if (multiselectIsAllowedToBeSelectedMultipleTimes == false)
          OptionCardGrid(
            cards: [
              for (final e in multiselectOptions
                  .asMap()
                  .entries
                  .sortedBy((e) => e.value.$1))
                OptionCard(
                  optionUuid: e.value.$4,
                  label: e.value.$1,
                  description: e.value.$2,
                  isSelected: e.value.$3,
                  multiple: true,
                  onTap: () {
                    setState(() {
                      var deepCopy = [...multiselectOptions];
                      deepCopy[e.key] = (
                        e.value.$1,
                        e.value.$2,
                        !e.value.$3,
                        e.value.$4,
                        e.value.$5
                      );
                      multiselectOptions = deepCopy;
                      onChanged();
                    });
                  },
                ),
            ],
          ),
        if (multiselectIsAllowedToBeSelectedMultipleTimes != false)
        ...multiselectOptions.asMap().entries.sortedBy((e) => e.value.$1).map(
              (e) => Row(
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

  /// Below this width a value label and its input fields no longer fit side
  /// by side: labels broke mid-word ("Geschickl|ichkeit") and field labels
  /// were cut ("Erste…"). Narrow layouts put the label on its own line.
  static const double _sideBySideMinWidth = 520;

  Widget _valueLabel(String text) => Text(
        text,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: CustomThemeProvider.of(context).theme.darkTextColor,
              fontSize: 16,
            ),
      );

  Widget getConfigurationWidgetsForListOfIntsWithCalculatedValues() {
    // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
    // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
    var statTitle = widget.statConfiguration.name;
    var statDescription = widget.statConfiguration.helperText;

    return LayoutBuilder(builder: (context, constraints) {
      final sideBySide = constraints.maxWidth >= _sideBySideMinWidth;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlayerConfigModalNonDefaultTitleAndHelperText(
              statTitle: statTitle, statDescription: statDescription),
          ...listOfIntWithOtherValueOptions
              .asMap()
              .entries
              .sortedBy((e) => e.value.label)
              .map((e) {
            final fields = <Widget>[
              Expanded(
                child: _intTextField(
                  labelText: S.of(context).firstValue,
                  controller: e.value.valueTextController,
                  placeholderText: S.of(context).firstValuePlaceholder,
                ),
              ),
              SizedBox(width: sideBySide ? 20 : 10),
              Expanded(
                child: _intTextField(
                  labelText: S.of(context).secondValue,
                  controller: e.value.otherValueTextController,
                  placeholderText: S.of(context).secondValuePlaceholder,
                ),
              ),
            ];

            if (!sideBySide) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _valueLabel("${e.value.label}:"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: fields,
                    ),
                  ],
                ),
              );
            }

            return Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: _valueLabel("${e.value.label}:"),
                  ),
                ),
                SizedBox(width: 20),
                ...fields,
                SizedBox(width: 20),
              ],
            );
          }),
        ],
      );
    });
  }

  Widget getConfigurationWidgetsForBunchOfTextValues() {
    // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12}]}
    // => statConfiguration.jsonSerializedAdditionalData! == {"level": 0, "values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
    var statTitle = widget.statConfiguration.name;
    var statDescription = widget.statConfiguration.helperText;
    final isNameWithLevel = widget.statConfiguration.valueType ==
        CharacterStatValueType.characterNameWithLevelAndAdditionalDetails;

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

    return LayoutBuilder(builder: (context, constraints) {
      final sideBySide = constraints.maxWidth >= _sideBySideMinWidth;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlayerConfigModalNonDefaultTitleAndHelperText(
              statTitle: statTitle, statDescription: statDescription),
          ...listOfSingleValueOptions
              .asMap()
              .entries
              .sortedBy((e) => e.value.label)
              .map((e) {
            final isLevel = isNameWithLevel && e.value.uuid.isEmpty;
            final placeholder =
                S.of(context).valueOfPropertyWithName(e.value.label);
            final Widget field = isLevel ||
                    widget.statConfiguration.valueType ==
                        CharacterStatValueType.listOfIntsWithIcons
                ? _intTextField(
                    labelText: e.value.label,
                    controller: e.value.valueTextController,
                    placeholderText: placeholder,
                    isLevel: isLevel,
                  )
                : CustomTextField(
                    labelText: e.value.label,
                    textEditingController: e.value.valueTextController,
                    placeholderText: placeholder,
                    keyboardType: TextInputType.text,
                  );

            // Narrow: the field's own label names the value; a second label
            // column would squeeze both (and cut the helper text).
            if (!sideBySide) return field;

            return Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: _valueLabel("${e.value.label}:"),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(child: field),
                SizedBox(width: 20),
              ],
            );
          }),
          // The portrait only when the sheet has no image property of its
          // own: one image picker per character.
          if (isNameWithLevel &&
              !sheetHasImageProperty(
                  ref.watch(rpgConfigurationProvider).value)) ...[
            SizedBox(height: 16),
            CustomTextField(
              labelText: S.of(context).characterPortraitImagePrompt,
              placeholderText:
                  S.of(context).characterPortraitImagePromptPlaceholder,
              textEditingController: textController,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 10),
            getGeneratedImagePickerControls(context),
          ],
        ],
      );
    });
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _intTextField(
                labelText: S.of(context).currentValue,
                placeholderText: S.of(context).currentValuePlaceholder,
                controller: textController,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: _intTextField(
                labelText: S.of(context).maxValue,
                placeholderText: S.of(context).maxValuePlaceholder,
                controller: textController2,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _intTextField(
                labelText: S.of(context).firstValue,
                placeholderText: S.of(context).firstValuePlaceholder,
                controller: textController,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: _intTextField(
                labelText: S.of(context).calculatedValue,
                placeholderText: S.of(context).calculatedValuePlaceholder,
                controller: textController2,
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
                CustomThemeProvider.of(context).brightnessNotifier.value ==
                        Brightness.light
                    ? CustomThemeProvider.of(context).theme.middleBgColor
                    : CustomThemeProvider.of(context)
                        .theme
                        .middleBgColor
                        .darker(0.4),
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

  Widget getConfigurationWidgetsForCheckboxTrack() {
    // characterValue.serializedValue = {"checked": [0, 2]}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: widget.statConfiguration.name,
            statDescription: widget.statConfiguration.helperText),
        CheckboxTrackView(
          title: widget.statConfiguration.name,
          hideTitle: true,
          config: CheckboxTrackConfig.of(widget.statConfiguration),
          checked: checkboxTrackChecked,
          onToggle: (index) {
            setState(() {
              final updated = {...checkboxTrackChecked};
              if (!updated.remove(index)) updated.add(index);
              checkboxTrackChecked = updated;
              onChanged();
            });
            clearPreviewSandboxOnConfigEdit();
          },
        ),
        Text(
          S.of(context).checkboxTrackTapHint,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  Widget getConfigurationWidgetsForTextList() {
    // characterValue.serializedValue = {"values": [{"uuid": "...", "value": "..."}]}
    final config = TextListConfig.of(widget.statConfiguration);
    final darkColor = CustomThemeProvider.of(context).theme.darkColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: widget.statConfiguration.name,
            statDescription: widget.statConfiguration.helperText),
        for (final slot in config.slots)
          if (textListSlotControllers[slot.uuid] != null)
            CustomTextField(
              key: ValueKey('text-list-slot-field-${slot.uuid}'),
              labelText: slot.label.trim().isEmpty
                  ? widget.statConfiguration.name
                  : slot.label,
              textEditingController: textListSlotControllers[slot.uuid]!,
              keyboardType: TextInputType.text,
            ),
        if (config.allowCustomEntries) ...[
          for (final entry in textListOwnEntries)
            Row(
              key: ValueKey('text-list-own-entry-${entry.uuid}'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: S.of(context).textListOwnEntryLabel,
                    textEditingController: entry.controller,
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: CustomButton(
                    key: ValueKey('text-list-own-entry-delete-${entry.uuid}'),
                    variant: CustomButtonVariant.FlatButton,
                    onPressed: () {
                      setState(() {
                        textListOwnEntries = textListOwnEntries
                            .where((e) => e.uuid != entry.uuid)
                            .toList();
                        onChanged();
                      });
                      clearPreviewSandboxOnConfigEdit();
                    },
                    icon: CustomFaIcon(
                      icon: FontAwesomeIcons.trashCan,
                      color: darkColor,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 5),
          CustomButton(
            key: const ValueKey('text-list-add-own-entry'),
            isSubbutton: true,
            onPressed: () {
              setState(() {
                textListOwnEntries = [
                  ...textListOwnEntries,
                  (
                    uuid: UuidV7().generate(),
                    controller: TextEditingController()
                      ..addListener(onChanged)
                      ..addListener(clearPreviewSandboxOnConfigEdit),
                  ),
                ];
              });
            },
            label: S.of(context).textListAddEntry,
            icon: CustomFaIcon(
              icon: FontAwesomeIcons.plus,
              size: 14,
              color: CustomThemeProvider.of(context).theme.darkTextColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget getConfigurationWidgetsForSingleSelect() {
    // characterValue.serializedValue = {"value": "<option uuid>"}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlayerConfigModalNonDefaultTitleAndHelperText(
            statTitle: widget.statConfiguration.name,
            statDescription: widget.statConfiguration.helperText),
        // In the DM's order: options of one choice are often ranked.
        OptionCardGrid(
          cards: [
            for (final option in selectOptionsOf(widget.statConfiguration))
              OptionCard(
                optionUuid: option.uuid,
                label: option.label,
                description: option.description,
                isSelected: option.uuid == singleSelectSelectedUuid,
                multiple: false,
                onTap: () {
                  setState(() {
                    singleSelectSelectedUuid = option.uuid;
                    onChanged();
                  });
                  clearPreviewSandboxOnConfigEdit();
                },
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
                      activeColor: CustomThemeProvider.of(context)
                                  .brightnessNotifier
                                  .value ==
                              Brightness.light
                          ? CustomThemeProvider.of(context).theme.darkColor
                          : Colors.transparent,
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
