import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_dropdown_menu.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_int_edit_field.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/modal_content_wrapper.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/computed_stat_editor.dart';
import 'package:quest_keeper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/helpers/character_stats/property_purposes.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/helpers/modals/show_select_icon_with_color_modal.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/computed_stat_formula.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:uuid/v7.dart';

/// Edits [predefinedConfiguration], or creates a new property: of the field
/// type [purpose] stands for, or (without one) any field type.
Future<CharacterStatDefinition?> showGetDmConfigurationModal({
  required BuildContext context,
  CharacterStatDefinition? predefinedConfiguration,
  PropertyPurpose? purpose,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
  List<StatWithTab> availableStats = const [],
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
          purpose: predefinedConfiguration == null ? purpose : null,
          availableStats: availableStats,
        );
      });
}

class ShowGetDmConfigurationModalContent extends StatefulWidget {
  const ShowGetDmConfigurationModalContent({
    this.overrideNavigatorKey,
    this.predefinedConfiguration,
    this.purpose,
    this.availableStats = const [],
    super.key,
  });

  final GlobalKey<NavigatorState>? overrideNavigatorKey;
  final CharacterStatDefinition? predefinedConfiguration;

  /// What a new property is for: sets its field type and change frequency,
  /// which then sit folded away below the purpose.
  final PropertyPurpose? purpose;

  /// The campaign's stats (all tabs, unsaved edits included): sources for a
  /// computed value.
  final List<StatWithTab> availableStats;

  @override
  State<ShowGetDmConfigurationModalContent> createState() =>
      _ShowGetDmConfigurationModalContentState();
}

class _ShowGetDmConfigurationModalContentState
    extends State<ShowGetDmConfigurationModalContent> {
  var nameTextEditor = TextEditingController();
  var helperTextEditor = TextEditingController();

  // stored as options with label/description(/summary) in additionalValues
  List<
      (
        String uuid,
        TextEditingController label,
        TextEditingController description,
        TextEditingController summary,
      )> multiselectOptions = [];

  List<({String uuid, TextEditingController label, String? iconName})>
      groupOfLabeledValues = [];

  // companionSelector: icon shown above the selected companions
  String companionSelectorIconName = defaultCompanionSelectorIconName;

  // checkboxTrack: number of boxes and one (optional) label field per box.
  // Holds at least checkboxTrackBoxCount fields; only those are stored.
  int checkboxTrackBoxCount = CheckboxTrackConfig.defaultBoxCount;
  List<TextEditingController> checkboxTrackLabels = [];

  // textList: fixed slots and whether players may add own entries
  List<({String uuid, TextEditingController label})> textListSlots = [];
  bool textListAllowCustomEntries = true;

  // characterNameWithLevelAndAdditionalDetails: show and ask for the level
  bool showLevel = true;

  CharacterStatEditType? selectedEditType = CharacterStatEditType.static;
  CharacterStatValueType? selectedValueType =
      CharacterStatValueType.singleLineText;

  // TODO add "advanced options" to edit those...
  bool isOptionalForCompanionCharacters = false;
  bool isOptionalForAlternateForms = false;
  bool multiselectIsAllowedToBeSelectedMultipleTimes = false;

  // int: computed from other stats instead of typed in by players
  bool isComputed = false;
  ComputedStatFormula computedFormula = const ComputedStatFormula(base: 10);

  @override
  void initState() {
    // The property to edit, or what a new one of the purpose starts with.
    final initial = widget.predefinedConfiguration ??
        (widget.purpose == null
            ? null
            : PropertyPurposeInfo.of(widget.purpose!).newStat());
    Future.delayed(Duration.zero, () {
      if (initial != null) {
        setState(() {
          nameTextEditor =
              TextEditingController(text: initial.name);
          helperTextEditor = TextEditingController(
              text: initial.helperText);

          selectedEditType = initial.editType;
          selectedValueType = initial.valueType;

          isOptionalForAlternateForms =
              initial.isOptionalForAlternateForms ??
                  false;

          isOptionalForCompanionCharacters = initial.isOptionalForCompanionCharacters ??
              false;

          var predefinedFormula =
              ComputedStatFormula.of(initial);
          if (predefinedFormula != null) {
            isComputed = true;
            computedFormula = predefinedFormula;
          }

          // what to do about additionaldetails
          if (selectedValueType == CharacterStatValueType.companionSelector) {
            companionSelectorIconName = configuredCompanionSelectorIconName(
                    initial) ??
                defaultCompanionSelectorIconName;
          } else if (selectedValueType ==
              CharacterStatValueType.checkboxTrack) {
            final config =
                CheckboxTrackConfig.of(initial);
            checkboxTrackBoxCount = config.boxCount;
            checkboxTrackLabels = config.labels
                .map((l) => TextEditingController(text: l))
                .toList();
          } else if (selectedValueType == CharacterStatValueType.textList) {
            final config = TextListConfig.of(initial);
            textListAllowCustomEntries = config.allowCustomEntries;
            textListSlots = config.slots
                .map((s) =>
                    (uuid: s.uuid, label: TextEditingController(text: s.label)))
                .toList();
          } else if (selectedValueType == CharacterStatValueType.multiselect ||
              selectedValueType == CharacterStatValueType.singleSelect) {
            // Decode JSON string to a list of dynamic maps
            // TODO remove migration
            List<dynamic> jsonList = [];
            if (initial.jsonSerializedAdditionalData
                        ?.isNotEmpty ==
                    true &&
                initial.jsonSerializedAdditionalData!
                    .startsWith("[")) {
              jsonList = jsonDecode(initial.jsonSerializedAdditionalData ??
                  "[]");
              multiselectIsAllowedToBeSelectedMultipleTimes = false;
            } else {
              Map<String, dynamic> json = jsonDecode(initial.jsonSerializedAdditionalData ??
                  '{"options:":[], "multiselectIsAllowedToBeSelectedMultipleTimes":false}');

              multiselectIsAllowedToBeSelectedMultipleTimes = json.containsKey(
                      "multiselectIsAllowedToBeSelectedMultipleTimes")
                  ? json["multiselectIsAllowedToBeSelectedMultipleTimes"]
                      as bool
                  : false;

              jsonList = (json["options"] as List<dynamic>?) ?? [];
            }

            for (var item in jsonList) {
              var label = (item as Map<String, dynamic>)["label"];
              var uuid = (item)["uuid"];
              var description = (item)["description"];
              var summary = (item)["summary"];

              multiselectOptions.add((
                uuid,
                TextEditingController(text: label),
                TextEditingController(text: description ?? ''),
                TextEditingController(
                    text: summary is String ? summary : ''),
              ));
            }
          } else if (selectedValueType ==
                  CharacterStatValueType.listOfIntsWithIcons ||
              selectedValueType ==
                  CharacterStatValueType.listOfIntWithCalculatedValues ||
              selectedValueType ==
                  CharacterStatValueType
                      .characterNameWithLevelAndAdditionalDetails) {
            showLevel =
                characterSummaryShowsLevel(initial);
            // Decode JSON string to a list of dynamic maps
            List<dynamic> jsonList = (jsonDecode(
                initial.jsonSerializedAdditionalData ??
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
          final tempResult = _currentDefinition();
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
            if (widget.purpose != null) _purposeHeader(),
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
            if (widget.purpose == null)
              ..._typePickers()
            else
              ThemeConfigurationForApp(
                child: ExpansionTile(
                  key: const ValueKey('propertyTypePickers'),
                  enableFeedback: false,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(S.of(context).propertyPurposeChangeType),
                  textColor:
                      CustomThemeProvider.of(context).theme.darkTextColor,
                  iconColor: CustomThemeProvider.of(context).theme.darkColor,
                  collapsedIconColor:
                      CustomThemeProvider.of(context).theme.darkColor,
                  collapsedTextColor:
                      CustomThemeProvider.of(context).theme.darkTextColor,
                  shape: Border.all(color: Colors.transparent, width: 0),
                  collapsedShape:
                      Border.all(color: Colors.transparent, width: 0),
                  children: _typePickers(),
                ),
              ),
            ...getAdvancedConfigurationOptionWidgets(),
            ...getAdditionalDetailsWidgets(),
            ..._previewWidgets(),
            SizedBox(
                height: EdgeInsets.fromViewPadding(View.of(context).viewInsets,
                        View.of(context).devicePixelRatio)
                    .bottom),
          ],
        ));
  }

  /// The property as configured right now (a new uuid; saving keeps the
  /// uuid of an edited property).
  CharacterStatDefinition _currentDefinition() {
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
              "options": multiselectOptions.map((e) {
                final map = <String, dynamic>{
                  "uuid": e.$1,
                  "label": e.$2.text,
                  "description": e.$3.text,
                };
                final summary = e.$4.text.trim();
                if (summary.isNotEmpty) {
                  map["summary"] = summary;
                }
                return map;
              }).toList(),
              "multiselectIsAllowedToBeSelectedMultipleTimes":
                  multiselectIsAllowedToBeSelectedMultipleTimes,
            });

            tempResult = tempResult.copyWith(
                jsonSerializedAdditionalData: serializedAdditionalData);
          } else if (selectedValueType ==
              CharacterStatValueType.singleSelect) {
            // Same option format as multiselect, without the "multiple
            // times" switch.
            tempResult = tempResult.copyWith(
                jsonSerializedAdditionalData: jsonEncode({
              "options": multiselectOptions.map((e) {
                final map = <String, dynamic>{
                  "uuid": e.$1,
                  "label": e.$2.text,
                  "description": e.$3.text,
                };
                final summary = e.$4.text.trim();
                if (summary.isNotEmpty) {
                  map["summary"] = summary;
                }
                return map;
              }).toList(),
            }));
          } else if (selectedValueType ==
              CharacterStatValueType.checkboxTrack) {
            tempResult = tempResult.copyWith(
                jsonSerializedAdditionalData: CheckboxTrackConfig(
              boxCount: checkboxTrackBoxCount,
              labels: checkboxTrackLabels.map((c) => c.text).toList(),
            ).toAdditionalData());
          } else if (selectedValueType == CharacterStatValueType.textList) {
            tempResult = tempResult.copyWith(
                jsonSerializedAdditionalData: TextListConfig(
              slots: textListSlots
                  .map((s) =>
                      TextListSlot(uuid: s.uuid, label: s.label.text.trim()))
                  .toList(),
              allowCustomEntries: textListAllowCustomEntries,
            ).toAdditionalData());
          } else if (selectedValueType == CharacterStatValueType.unsupported) {
            // A type from a newer app version: keep its data and type name.
            tempResult = tempResult.copyWith(
              jsonSerializedAdditionalData:
                  widget.predefinedConfiguration?.jsonSerializedAdditionalData,
              unsupportedValueTypeName:
                  widget.predefinedConfiguration?.unsupportedValueTypeName,
            );
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
                  .toList()),
              // Only written when off, so existing campaigns stay unchanged.
              if (selectedValueType ==
                      CharacterStatValueType
                          .characterNameWithLevelAndAdditionalDetails &&
                  !showLevel)
                "showLevel": false,
            });

            tempResult = tempResult.copyWith(
                jsonSerializedAdditionalData: serializedAdditionalData);
          } else if (selectedValueType ==
              CharacterStatValueType.companionSelector) {
            tempResult = tempResult.copyWith(
                jsonSerializedAdditionalData:
                    jsonEncode({"iconName": companionSelectorIconName}));
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

          if (selectedValueType == CharacterStatValueType.int && isComputed) {
            tempResult = tempResult.copyWith(
                jsonSerializedAdditionalData:
                    computedFormula.toAdditionalData());
          }

    return tempResult;
  }

  /// The change frequency and the field type.
  List<Widget> _typePickers() => [
            CustomDropdownMenu(
                isExpanded: true,
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
                      throw UnimplementedError();
                  }
                }).toList(),
                label: S.of(context).propertyEditTypeLabel),
            SizedBox(
              height: 15,
            ),
            CustomDropdownMenu(
                isExpanded: true,
                selectedValueTemp: selectedValueType?.name,
                setter: (newValue) {
                  setState(() {
                    if (newValue == null) {
                      selectedValueType = null;
                    } else {
                      selectedValueType = CharacterStatValueType.values
                          .singleWhere((e) => e.name == newValue);
                      // Boxes are ticked during play: a new track starts
                      // as a frequently changed value.
                      if (selectedValueType ==
                              CharacterStatValueType.checkboxTrack &&
                          widget.predefinedConfiguration == null) {
                        selectedEditType = CharacterStatEditType.oneTap;
                      }
                    }
                  });
                },
                // The placeholder for unknown types is never offered, it is
                // only shown for a stat that already has it.
                items: CharacterStatValueType.values
                    .where((e) =>
                        e != CharacterStatValueType.unsupported ||
                        selectedValueType ==
                            CharacterStatValueType.unsupported)
                    .map((e) {
                  switch (e) {
                    case CharacterStatValueType.checkboxTrack:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).statTypeCheckboxTrack),
                      );
                    case CharacterStatValueType.textList:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).statTypeTextList),
                      );
                    case CharacterStatValueType.singleSelect:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(S.of(context).statTypeSingleSelect),
                      );
                    case CharacterStatValueType.unsupported:
                      return DropdownMenuItem<String?>(
                        value: e.name,
                        child: Text(
                            "${S.of(context).statTypeUnsupported} (${widget.predefinedConfiguration?.unsupportedValueTypeName ?? "?"})"),
                      );
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
            if (_valueTypeHelpText(selectedValueType) != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _valueTypeHelpText(selectedValueType)!,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: CustomThemeProvider.of(context)
                              .theme
                              .darkTextColor,
                          fontSize: 14,
                        ),
                  ),
                ),
              ),
      ];

  /// What the property is for, above its name (new properties picked by
  /// purpose).
  Widget _purposeHeader() {
    final info = PropertyPurposeInfo.of(widget.purpose!);
    final theme = CustomThemeProvider.of(context).theme;
    final s = S.of(context);
    return Padding(
      key: const ValueKey('propertyPurposeHeader'),
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomFaIcon(icon: info.icon, size: 20, color: theme.accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title(s),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: theme.darkTextColor,
                        fontSize: 20,
                      ),
                ),
                Text(
                  info.description(s),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: theme.darkTextColor,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Every text field whose input changes the preview.
  Listenable _previewInputs() => Listenable.merge([
        nameTextEditor,
        helperTextEditor,
        for (final option in multiselectOptions) ...[
          option.$2,
          option.$3,
          option.$4,
        ],
        for (final value in groupOfLabeledValues) value.label,
        ...checkboxTrackLabels,
        for (final slot in textListSlots) slot.label,
      ]);

  /// The property as the sheet shows it, with sample values; it follows the
  /// edits above.
  List<Widget> _previewWidgets() {
    if (!propertyHasPreview(selectedValueType)) return const [];
    final theme = CustomThemeProvider.of(context).theme;
    final s = S.of(context);
    return [
      const SizedBox(height: 20),
      HorizontalLine(),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "${s.preview}:",
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: theme.darkTextColor,
                fontSize: 24,
              ),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          s.propertyPreviewHint,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: theme.darkTextColor,
                fontSize: 14,
              ),
        ),
      ),
      const SizedBox(height: 10),
      ListenableBuilder(
        listenable: _previewInputs(),
        builder: (context, _) {
          final definition =
              _currentDefinition().copyWith(statUuid: 'property-preview');
          final sample = propertyPreviewSample(definition);
          if (sample == null) {
            return Text(
              s.propertyPreviewNeedsEntries,
              key: const ValueKey('propertyPreviewEmpty'),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: theme.darkTextColor.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
            );
          }
          return Center(
            child: ConstrainedBox(
              key: const ValueKey('propertyPreview'),
              // About one column of the sheet.
              constraints: const BoxConstraints(maxWidth: 360),
              child: IgnorePointer(
                child: getPlayerVisualizationWidget(
                  context: context,
                  statConfiguration: definition,
                  characterValue: sample,
                  characterName: s.characterNameDefault,
                  onNewStatValue: (_) {},
                  characterToRenderStatFor: null,
                  readOnly: true,
                ),
              ),
            ),
          );
        },
      ),
    ];
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

  List<Widget> getComputedValueWidgets() {
    return [
      const SizedBox(height: 20),
      HorizontalLine(),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: SelectableTile(
              key: const ValueKey("computedValueToggle"),
              onValueChange: () => setState(() => isComputed = !isComputed),
              isSet: isComputed,
              label: S.of(context).computedValue,
            ),
          ),
        ],
      ),
      if (isComputed)
        ComputedStatEditor(
          initialFormula: computedFormula,
          availableStats: widget.availableStats,
          ownStatUuid: widget.predefinedConfiguration?.statUuid,
          onChanged: (formula) => computedFormula = formula,
          // A preset names an unnamed property after itself.
          onPresetApplied: (name) {
            if (nameTextEditor.text.trim().isNotEmpty) return;
            setState(() => nameTextEditor.text = name);
          },
        ),
    ];
  }

  /// Short help below the type picker, for the types that need one.
  String? _valueTypeHelpText(CharacterStatValueType? type) {
    switch (type) {
      case CharacterStatValueType.checkboxTrack:
        return S.of(context).statTypeCheckboxTrackHelp;
      case CharacterStatValueType.textList:
        return S.of(context).statTypeTextListHelp;
      case CharacterStatValueType.singleSelect:
        return S.of(context).statTypeSingleSelectHelp;
      case CharacterStatValueType.unsupported:
        return S.of(context).statTypeUnsupportedHint;
      default:
        return null;
    }
  }

  List<Widget> _sectionStart(String headline, {String? hint}) {
    return [
      const SizedBox(height: 20),
      HorizontalLine(),
      const SizedBox(height: 10),
      Text(
        headline,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: CustomThemeProvider.of(context).theme.darkTextColor,
              fontSize: 20,
            ),
      ),
      if (hint != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            hint,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: CustomThemeProvider.of(context).theme.darkTextColor,
                  fontSize: 13,
                ),
          ),
        ),
      const SizedBox(height: 10),
    ];
  }

  Widget _addElementButton({Key? key, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
      child: CustomButton(
        key: key,
        isSubbutton: true,
        onPressed: onPressed,
        label: S.of(context).additionalElement,
        icon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: CustomFaIcon(
            icon: FontAwesomeIcons.plus,
            size: 16,
            color: CustomThemeProvider.of(context).theme.darkTextColor,
          ),
        ),
      ),
    );
  }

  /// checkboxTrack: number of boxes (1-20) and an optional label per box.
  List<Widget> getCheckboxTrackConfigurationWidgets() {
    while (checkboxTrackLabels.length < checkboxTrackBoxCount) {
      checkboxTrackLabels.add(TextEditingController());
    }
    return [
      ..._sectionStart(S.of(context).checkboxTrackBoxesHeadline),
      Align(
        alignment: Alignment.centerLeft,
        child: CustomIntEditField(
          key: const ValueKey("checkboxTrackBoxCount"),
          label: S.of(context).checkboxTrackBoxCountLabel,
          startValue: checkboxTrackBoxCount,
          minValue: CheckboxTrackConfig.minBoxes,
          maxValue: CheckboxTrackConfig.maxBoxes,
          onValueChange: (newValue) {
            setState(() {
              checkboxTrackBoxCount = newValue.clamp(
                  CheckboxTrackConfig.minBoxes, CheckboxTrackConfig.maxBoxes);
            });
          },
        ),
      ),
      const SizedBox(height: 10),
      Text(
        S.of(context).checkboxTrackLabelsHint,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: CustomThemeProvider.of(context).theme.darkTextColor,
              fontSize: 13,
            ),
      ),
      const SizedBox(height: 5),
      Wrap(
        spacing: 10,
        children: List.generate(
          checkboxTrackBoxCount,
          (index) => SizedBox(
            width: 140,
            child: CustomTextField(
              key: ValueKey("checkboxTrackLabel-$index"),
              labelText: S.of(context).checkboxTrackBoxLabel(index + 1),
              textEditingController: checkboxTrackLabels[index],
              keyboardType: TextInputType.text,
            ),
          ),
        ),
      ),
    ];
  }

  /// textList: optional fixed slots and whether players may add own entries.
  List<Widget> getTextListConfigurationWidgets() {
    return [
      ..._sectionStart(
        S.of(context).textListSlotsHeadline,
        hint: S.of(context).textListSlotsHint,
      ),
      ...textListSlots.asMap().entries.map(
            (tuple) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    key: ValueKey("textListSlot-${tuple.key}"),
                    labelText: S.of(context).textListSlotLabel,
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
                        textListSlots.removeAt(tuple.key);
                      });
                    },
                    icon: CustomFaIcon(
                      icon: FontAwesomeIcons.trashCan,
                      color: CustomThemeProvider.of(context).theme.darkColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
      _addElementButton(
        key: const ValueKey("textListAddSlot"),
        onPressed: () {
          setState(() {
            textListSlots.add(
                (uuid: UuidV7().generate(), label: TextEditingController()));
          });
        },
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: SelectableTile(
              key: const ValueKey("textListAllowCustomEntriesToggle"),
              onValueChange: () => setState(() =>
                  textListAllowCustomEntries = !textListAllowCustomEntries),
              isSet: textListAllowCustomEntries,
              label: S.of(context).textListAllowCustomEntries,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> getAdditionalDetailsWidgets() {
    // TODO add all items which need additionalDetails here
    var typesWithAdditionalConfigurationRequired = [
      CharacterStatValueType.multiselect,
      CharacterStatValueType.listOfIntWithCalculatedValues,
      CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
      CharacterStatValueType.listOfIntsWithIcons,
      CharacterStatValueType.companionSelector,
      CharacterStatValueType.checkboxTrack,
      CharacterStatValueType.textList,
      CharacterStatValueType.singleSelect,
    ];

    if (selectedValueType == null) return [];
    if (selectedValueType == CharacterStatValueType.int) {
      return getComputedValueWidgets();
    }
    if (!typesWithAdditionalConfigurationRequired.contains(selectedValueType)) {
      return [];
    }

    if (selectedValueType == CharacterStatValueType.companionSelector) {
      return [
        SizedBox(
          height: 20,
        ),
        HorizontalLine(),
        SizedBox(
          height: 10,
        ),
        Text(
          S.of(context).companionSelectorIconHeadline,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 20,
              ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            CustomButton(
              isSubbutton: true,
              variant: CustomButtonVariant.Default,
              onPressed: () async {
                final selected = await showSelectIconWithColorModal(
                  context,
                  alreadySelectedIcoName: companionSelectorIconName,
                  alreadySelectedIconColor:
                      CustomThemeProvider.of(context).theme.darkColor,
                  disableColorSelect: true,
                  titleSuffix: " ${S.of(context).forCompanionSelector}",
                );
                if (selected == null || !mounted) return;
                setState(() {
                  companionSelectorIconName = selected.$1;
                });
              },
              icon: Padding(
                padding: const EdgeInsets.all(4.5),
                child: getIconForIdentifier(
                  name: companionSelectorIconName,
                  color: CustomThemeProvider.of(context).theme.darkColor,
                  size: 32,
                ).$2,
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text(
                S.of(context).companionSelectorIconHint,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color:
                          CustomThemeProvider.of(context).theme.darkTextColor,
                    ),
              ),
            ),
          ],
        ),
      ];
    }

    if (selectedValueType == CharacterStatValueType.checkboxTrack) {
      return getCheckboxTrackConfigurationWidgets();
    }

    if (selectedValueType == CharacterStatValueType.textList) {
      return getTextListConfigurationWidgets();
    }

    if (selectedValueType == CharacterStatValueType.multiselect ||
        selectedValueType == CharacterStatValueType.singleSelect) {
      return [
        SizedBox(
          height: 20,
        ),
        HorizontalLine(),
        SizedBox(
          height: 10,
        ),
        Text(
          selectedValueType == CharacterStatValueType.singleSelect
              ? S.of(context).singleSelectOptionsHeadline
              : S.of(context).optionsForMultiselect,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 20,
              ),
        ),
        SizedBox(
          height: 20,
        ),

        // Option name, description, optional summary
        ...multiselectOptions.asMap().entries.map(
              (tuple) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Column(
                  children: [
                    Row(
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
                          flex: 2,
                          child: Column(
                            children: [
                              CustomTextField(
                                labelText: S
                                    .of(context)
                                    .multiselectOptionDescription,
                                textEditingController: tuple.value.$3,
                                keyboardType: TextInputType.multiline,
                              ),
                              CustomTextField(
                                labelText:
                                    S.of(context).multiselectOptionSummary,
                                placeholderText: S
                                    .of(context)
                                    .multiselectOptionSummaryHelper,
                                textEditingController: tuple.value.$4,
                                keyboardType: TextInputType.text,
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
                            onPressed: () {
                              setState(() {
                                multiselectOptions.removeAt(tuple.key);
                              });
                            },
                            icon: CustomFaIcon(
                              icon: FontAwesomeIcons.trashCan,
                              color: CustomThemeProvider.of(context)
                                  .theme
                                  .darkColor,
                            ),
                          ),
                        ),
                      ],
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
                  TextEditingController(),
                  TextEditingController(),
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
        if (selectedValueType ==
            CharacterStatValueType
                .characterNameWithLevelAndAdditionalDetails) ...[
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: SelectableTile(
                  key: const ValueKey("showLevelToggle"),
                  onValueChange: () => setState(() => showLevel = !showLevel),
                  isSet: showLevel,
                  label: S.of(context).showLevelToggle,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              S.of(context).showLevelHint,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: CustomThemeProvider.of(context).theme.darkTextColor,
                    fontSize: 13,
                  ),
            ),
          ),
        ],
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
          // Flexible: long labels wrap on phones instead of overflowing.
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: CustomThemeProvider.of(context).theme.darkTextColor,
                  fontSize: 16),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}

/// Companions and alternate forms only make sense on a real character.
bool propertyHasPreview(CharacterStatValueType? type) => switch (type) {
      null ||
      CharacterStatValueType.companionSelector ||
      CharacterStatValueType.transformIntoAlternateFormBtn ||
      CharacterStatValueType.unsupported =>
        false,
      _ => true,
    };

/// A sample value to preview [definition] with, or null when there is
/// nothing to show yet (a list without entries, or a type without a preview).
RpgCharacterStatValue? propertyPreviewSample(CharacterStatDefinition definition) {
  if (!propertyHasPreview(definition.valueType)) return null;
  switch (definition.valueType) {
    case CharacterStatValueType.multiselect:
    case CharacterStatValueType.singleSelect:
      final options = (jsonDecode(
              definition.jsonSerializedAdditionalData ?? '{}')
          as Map<String, dynamic>)["options"] as List<dynamic>?;
      if (options == null || options.isEmpty) return null;
    case CharacterStatValueType.listOfIntsWithIcons:
    case CharacterStatValueType.listOfIntWithCalculatedValues:
      final values = (jsonDecode(
              definition.jsonSerializedAdditionalData ?? '{}')
          as Map<String, dynamic>)["values"] as List<dynamic>?;
      if (values == null || values.isEmpty) return null;
    default:
      break;
  }
  final config = RpgConfigurationTemplates.empty().copyWith(
    characterStatTabsDefinition: [
      CharacterStatsTabDefinition(
        uuid: 'property-preview-tab',
        tabName: '',
        isOptional: false,
        isDefaultTab: true,
        statsInTab: [definition],
      ),
    ],
  );
  final sample = RpgCharacterConfiguration.getDefaultStats(config, false, null)
      .firstOrNull;
  // The first style, which a new property starts with.
  return sample?.copyWith(variant: 0);
}
