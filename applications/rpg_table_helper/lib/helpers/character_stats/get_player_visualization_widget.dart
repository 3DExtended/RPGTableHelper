import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/pentagon_with_label.dart';
import 'package:quest_keeper/components/progress_indicator_for_character_screen.dart';
import 'package:quest_keeper/components/static_grid.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/stat_visualization_variant_widgets.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_level_seal.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/night_cartographer_ornaments.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/helpers/modals/show_reactivate_previous_transformation_modal.dart';
import 'package:quest_keeper/helpers/modals/show_select_transformation_components_for_transformation.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Resolves a stored image path (asset or API-relative) to a loadable URL.
String resolveStatImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return "assets/images/charactercard_placeholder.png";
  }
  if (imageUrl.startsWith("assets")) {
    return imageUrl;
  }
  return apiBaseUrl +
      (imageUrl.startsWith("/")
          ? (imageUrl.length > 1 ? imageUrl.substring(1) : '')
          : imageUrl);
}

int numberOfVariantsForValueTypes(CharacterStatValueType valueType) {
  switch (valueType) {
    case CharacterStatValueType.singleLineText:
    case CharacterStatValueType.singleImage:
      return 1;
    case CharacterStatValueType.companionSelector:
    case CharacterStatValueType.transformIntoAlternateFormBtn:
    case CharacterStatValueType.int:
      return 2;
    case CharacterStatValueType.multiLineText:
      return 3;
    case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
    case CharacterStatValueType.intWithCalculatedValue:
    case CharacterStatValueType.listOfIntWithCalculatedValues:
    case CharacterStatValueType.multiselect:
      return 4;
    case CharacterStatValueType.listOfIntsWithIcons:
      return 5;
    case CharacterStatValueType.intWithMaxValue:
      return 9;
  }
}

Widget getPlayerVisualizationWidget({
  required BuildContext context,
  required CharacterStatDefinition statConfiguration,
  required RpgCharacterStatValue characterValue,
  required String characterName,
  required void Function(String newSerializedValue) onNewStatValue,
  required RpgCharacterConfiguration? characterToRenderStatFor,
}) {
  switch (statConfiguration.valueType) {
    case CharacterStatValueType.multiLineText:
    case CharacterStatValueType.singleLineText:
      return renderTextStat(
          onNewStatValue, statConfiguration, context, characterValue);

    case CharacterStatValueType.singleImage:
      return renderImageStat(onNewStatValue, statConfiguration, context,
          characterValue, characterName);

    case CharacterStatValueType.int:
      return renderIntStat(
          onNewStatValue, characterValue, context, statConfiguration);
    case CharacterStatValueType.companionSelector:
      return renderCompanionSelector(onNewStatValue, characterValue, context,
          characterToRenderStatFor, statConfiguration);
    case CharacterStatValueType.transformIntoAlternateFormBtn:
      return renderTransformIntoAlternateFormBtn(onNewStatValue, characterValue,
          context, characterToRenderStatFor, statConfiguration);

    case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
      return renderCharacterNameWithLevelAndAdditionalDetailsStat(
          onNewStatValue,
          characterValue,
          context,
          statConfiguration,
          characterName);

    case CharacterStatValueType.listOfIntWithCalculatedValues:
      return renderListOfIntWithCalculatedValuesStat(onNewStatValue,
          characterValue, context, statConfiguration, characterName);

    case CharacterStatValueType.listOfIntsWithIcons:
      return renderListOfIntsWithIconsStat(onNewStatValue, characterValue,
          context, statConfiguration, characterName);

    case CharacterStatValueType.intWithMaxValue:
      return renderIntWithMaxValueStat(onNewStatValue, characterValue, context,
          statConfiguration, characterName);

    case CharacterStatValueType.intWithCalculatedValue:
      return renderIntWithCalculatedValueStat(onNewStatValue, characterValue,
          context, statConfiguration, characterName);

    case CharacterStatValueType.multiselect:
      return renderMultiselectStat(onNewStatValue, characterValue, context,
          statConfiguration, characterName);
  }
}

Widget renderCompanionSelector(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    RpgCharacterConfiguration? characterToRenderStatFor,
    CharacterStatDefinition statConfiguration) {
  List<String> selectedCompanionIds =
      (jsonDecode(characterValue.serializedValue)["values"] as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>)["uuid"] as String)
          .toList();

  if (selectedCompanionIds.isEmpty) {
    return Container();
  }

  List<
      ({
        String characterName,
        String uuid,
        String? imageUrl,
        RpgAlternateCharacterConfiguration companionConfig
      })> companionDetailsToRender = [];

  for (var selectedCompanionId in selectedCompanionIds) {
    var companionOfCharacter =
        (characterToRenderStatFor?.companionCharacters ?? [])
            .firstWhereOrNull((c) => c.uuid == selectedCompanionId);
    if (companionOfCharacter == null) continue;

    // TODO search for image (still missing access to rpgconfig here...)
    // TODO use this here: RenderCharactersAsCards.renderCharactersAsCharacterCard(context, charactersToRender, rpgConfig)

    companionDetailsToRender.add((
      characterName: companionOfCharacter.characterName,
      uuid: companionOfCharacter.uuid,
      imageUrl: null,
      companionConfig: companionOfCharacter
    ));
  }
  companionDetailsToRender =
      companionDetailsToRender.sortedBy((k) => k.characterName);

  if (companionDetailsToRender.isEmpty) {
    return Container();
  }

  void openCompanion(RpgAlternateCharacterConfiguration companionConfig) {
    navigatorKey.currentState!.pushNamed(
      PlayerPageScreen.route,
      arguments: PlayerPageScreenRouteSettings(
        disableEdit: false,
        showMoney: false,
        characterConfigurationOverride: companionConfig,
        showInventory: false,
        showLore: false,
        showRecipes: false,
      ),
    );
  }

  if (characterValue.variant == 1) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: companionDetailsToRender
          .map(
            (t) => CompanionMiniCard(
              name: t.characterName,
              onTap: () => openCompanion(t.companionConfig),
            ),
          )
          .toList(),
    );
  }

  return Column(
    children: [
      getIconForIdentifier(
        name: "paw",
        color: CustomThemeProvider.of(context).theme.darkColor,
        size: 50,
      ).$2,
      SizedBox(
        height: 10,
      ),
      Wrap(
        children: [
          ...companionDetailsToRender.map((t) => Padding(
                padding: EdgeInsets.all(5),
                child: CustomButton(
                    label: t.characterName,
                    onPressed: () => openCompanion(t.companionConfig)),
              )),
        ],
      )
    ],
  );
}

Widget renderTransformIntoAlternateFormBtn(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    RpgCharacterConfiguration? characterToRenderStatFor,
    CharacterStatDefinition statConfiguration) {
  if (characterToRenderStatFor == null ||
      characterToRenderStatFor.transformationComponents == null ||
      characterToRenderStatFor.transformationComponents!.isEmpty) {
    return Container();
  }

  final transformButton = Padding(
    padding: EdgeInsets.all(5),
    child: CustomButtonTransformToAlternateForm(
      characterToRenderStatFor: characterToRenderStatFor,
    ),
  );

  if (characterValue.variant == 1) {
    return ActiveFormBanner(transformButton: transformButton);
  }

  return Column(
    children: [
      getIconForIdentifier(
        name: "magic-wand-svgrepo-com",
        color: CustomThemeProvider.of(context).theme.darkColor,
        size: 50,
      ).$2,
      SizedBox(
        height: 10,
      ),
      Wrap(
        children: [transformButton],
      )
    ],
  );
}

class CustomButtonTransformToAlternateForm extends ConsumerStatefulWidget {
  const CustomButtonTransformToAlternateForm({
    super.key,
    this.characterToRenderStatFor,
  });
  final RpgCharacterConfiguration? characterToRenderStatFor;

  @override
  ConsumerState<CustomButtonTransformToAlternateForm> createState() =>
      _CustomButtonTransformToAlternateFormState();
}

class _CustomButtonTransformToAlternateFormState
    extends ConsumerState<CustomButtonTransformToAlternateForm> {
  @override
  Widget build(BuildContext context) {
    return CustomButton(
        label: S.of(context).tranformToAlternateForm,
        onPressed: () async {
          // open modal, select alternate form components and save
          // now open saved alternate form

          // if there is only one alternate form, just switch to it
          var rpgConfig = ref.read(rpgConfigurationProvider).requireValue;
          var rpgCharConfig =
              ref.read(rpgCharacterConfigurationProvider).requireValue;

          RpgCharacterConfigurationBase? newestVersionCharacterToRenderStatFor =
              rpgCharConfig.companionCharacters?.firstWhereOrNull(
                  (c) => c.uuid == widget.characterToRenderStatFor?.uuid);

          if (newestVersionCharacterToRenderStatFor == null &&
              rpgCharConfig.uuid == widget.characterToRenderStatFor?.uuid) {
            newestVersionCharacterToRenderStatFor = rpgCharConfig;
          }
          if (newestVersionCharacterToRenderStatFor == null &&
              rpgCharConfig.alternateForm != null &&
              rpgCharConfig.alternateForm!.uuid ==
                  widget.characterToRenderStatFor?.uuid) {
            newestVersionCharacterToRenderStatFor =
                rpgCharConfig.alternateForm!;
          }

          newestVersionCharacterToRenderStatFor ??=
              widget.characterToRenderStatFor;

          if (widget.characterToRenderStatFor?.transformationComponents
                  ?.isNotEmpty ==
              true) {
            RpgAlternateCharacterConfiguration? transformationToSwitchTo;
            if (newestVersionCharacterToRenderStatFor!.alternateForm != null) {
              // if there is already a alternate for stored, ask the user if they want to switch to it instead of creating a new one
              var showPreviousAlternateForm =
                  await showReactivatePreviousTransformationModal(context);
              if (showPreviousAlternateForm == null) return;

              if (showPreviousAlternateForm == true) {
                transformationToSwitchTo =
                    widget.characterToRenderStatFor!.alternateForm;
              }
            }

            transformationToSwitchTo ??=
                await showSelectTransformationComponentsForTransformation(
                    context,
                    rpgCharConfig: widget.characterToRenderStatFor!,
                    rpgConfig: rpgConfig);

            if (transformationToSwitchTo == null) return;

            var charConfigToUpdate =
                ref.read(rpgCharacterConfigurationProvider).requireValue;

            ref
                .read(rpgCharacterConfigurationProvider.notifier)
                .updateConfiguration(
                  charConfigToUpdate.copyWith(
                    isAlternateFormActive: true,
                    alternateForm: transformationToSwitchTo,
                  ),
                );

            // open companion page
            navigatorKey.currentState!
                .pushNamed(PlayerPageScreen.route,
                    arguments: PlayerPageScreenRouteSettings(
                      disableEdit: false,
                      showMoney: false,
                      characterConfigurationOverride: transformationToSwitchTo,
                      showInventory: false,
                      showLore: false,
                      showRecipes: false,
                    ))
                .then((onValue) {
              charConfigToUpdate =
                  ref.read(rpgCharacterConfigurationProvider).requireValue;
              ref
                  .read(rpgCharacterConfigurationProvider.notifier)
                  .updateConfiguration(
                    charConfigToUpdate.copyWith(
                      isAlternateFormActive: false,
                    ),
                  );
            });
          }
        });
  }
}

Widget renderMultiselectStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration,
    String characterName) {
  // statConfiguration.jsonSerializedAdditionalData = {"options:":[{"uuid": "3a7fd649-2d76-4a93-8513-d5a8e8249b40", "label": "", "description": ""}], "multiselectIsAllowedToBeSelectedMultipleTimes":false}
  // characterValue.serializedValue = {"values": ["c4c08d74-effb-4457-9c3a-d60b611f6986"]}
  List<String> parsedValue =
      (jsonDecode(characterValue.serializedValue)["values"] as List<dynamic>)
          .map((e) => e as String)
          .toList();

  var multiselectIsAllowedToBeSelectedMultipleTimes = false;
  List<dynamic> statConfigValues = [];

  // TODO remove migration
  if (statConfiguration.jsonSerializedAdditionalData?.isNotEmpty == true &&
      statConfiguration.jsonSerializedAdditionalData!.startsWith("[")) {
    statConfigValues = jsonDecode(statConfiguration.jsonSerializedAdditionalData
            ?.replaceAll("},]", "}]")
            .replaceAll('"}]"}]', '"}]') ??
        "[]");
  } else {
    Map<String, dynamic> json = jsonDecode(statConfiguration
            .jsonSerializedAdditionalData ??
        '{"options:":[], "multiselectIsAllowedToBeSelectedMultipleTimes":false}');

    multiselectIsAllowedToBeSelectedMultipleTimes =
        json.containsKey("multiselectIsAllowedToBeSelectedMultipleTimes")
            ? json["multiselectIsAllowedToBeSelectedMultipleTimes"] as bool
            : false;

    statConfigValues = json["options"] as List<dynamic>;
  }

  var config = statConfigValues
      .map(
        (e) => (
          e["uuid"] as String,
          e["label"] as String,
          e["description"] as String
        ),
      )
      .toList();

  // Variant 0: selected only. Variant 1+: show all options (different layouts).
  final showAllOptions =
      characterValue.variant != null && characterValue.variant! >= 1;

  var valueToConfigMapped = config
      .map((pv) => (parsedValue.where((es) => es == pv.$1).length, pv))
      .where((pv) => showAllOptions || pv.$1 != 0)
      .sortedBy((pv) => pv.$2.$2);

  final mappedItems = valueToConfigMapped
      .map(
        (e) => (
          label: e.$2.$2,
          description: e.$2.$3,
          count: e.$1,
        ),
      )
      .toList();

  switch (characterValue.variant) {
    case 2:
      return MultiselectChips(
        title: statConfiguration.name,
        items: mappedItems,
      );
    case 3:
      return MultiselectTileGrid(
        title: statConfiguration.name,
        items: mappedItems,
      );
  }

  final ledger = isDecoratedSheetSkinActive(context);
  if (ledger &&
      statConfiguration.name.toLowerCase().contains('zauber')) {
    // Preserve selection order (mock Spells layout), not alpha sort.
    final byUuid = {
      for (final e in valueToConfigMapped) e.$2.$1: e,
    };
    final ordered = <(int, (String, String, String))>[];
    for (final id in parsedValue) {
      final hit = byUuid[id];
      if (hit != null && !ordered.any((o) => o.$2.$1 == id)) {
        ordered.add(hit);
      }
    }
    for (final e in valueToConfigMapped) {
      if (!ordered.any((o) => o.$2.$1 == e.$2.$1)) {
        ordered.add(e);
      }
    }
    return _LedgerSpellMultiselect(
      title: statConfiguration.name,
      items: ordered
          .map((e) => (
                selected: e.$1 != 0,
                label: e.$2.$2,
                description: e.$2.$3,
              ))
          .toList(),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        statConfiguration.name,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: CustomThemeProvider.of(context).theme.darkTextColor,
              fontSize: 24,
            ),
      ),
      const SizedBox(height: 10),
      if (valueToConfigMapped.isEmpty)
        Text(
          S.of(context).nothingSelected,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: const Color.fromARGB(255, 193, 193, 193), fontSize: 16),
        ),
      ...valueToConfigMapped.map(
        (e) => Builder(builder: (context) {
            var isSelected = e.$1 != 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? CustomThemeProvider.of(context).theme.darkColor
                              : CustomThemeProvider.of(context).theme.bgColor,
                          border: Border.all(
                              color: CustomThemeProvider.of(context)
                                  .theme
                                  .darkColor)),
                    ),
                    if (multiselectIsAllowedToBeSelectedMultipleTimes)
                      ...List.filled(
                        max(0, e.$1 - 1),
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CustomThemeProvider.of(context)
                                  .theme
                                  .darkColor,
                              border: Border.all(
                                  color: CustomThemeProvider.of(context)
                                      .theme
                                      .darkColor)),
                        ),
                      ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      e.$2.$2,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: CustomThemeProvider.of(context)
                              .theme
                              .darkTextColor,
                          fontSize: 16),
                    ),
                  ],
                ),
                if (e.$2.$3.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 25, top: 2, bottom: 6),
                    child: Text(
                      e.$2.$3,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: CustomThemeProvider.of(context)
                                .theme
                                .darkTextColor
                                .withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            );
          }),
      ),
    ],
  );
}

/// Ledger spell list: section header + checked rows with short blurbs (mock Spells).
class _LedgerSpellMultiselect extends StatelessWidget {
  final String title;
  final List<({bool selected, String label, String description})> items;

  const _LedgerSpellMultiselect({
    required this.title,
    required this.items,
  });

  static String _shortBlurb(String description) {
    final lines = description
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.startsWith('zeitaufwand') ||
          lower.startsWith('reichweite') ||
          lower.startsWith('komponenten') ||
          lower.startsWith('wirkungsdauer') ||
          lower.contains('grades') ||
          lower.contains('zaubertrick') ||
          lower.contains('(ritual)')) {
        continue;
      }
      final sentence = line.split('.').first.trim();
      if (sentence.isEmpty) continue;
      if (sentence.length > 90) {
        return '${sentence.substring(0, 87)}…';
      }
      return '$sentence.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final ink = CustomThemeProvider.of(context).theme.darkTextColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: ink,
                    fontSize: 22,
                    fontFamily: 'Ruwudu',
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                color: ink.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(
            S.of(context).nothingSelected,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: ink.withValues(alpha: 0.45),
                  fontSize: 15,
                  fontFamily: 'Ruwudu',
                ),
          ),
        ...items.map((item) {
          final blurb = _shortBlurb(item.description);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: ink,
                        fontSize: 17,
                        fontFamily: 'Ruwudu',
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (blurb.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    blurb,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: ink.withValues(alpha: 0.78),
                          fontSize: 14,
                          fontFamily: 'Ruwudu',
                          height: 1.3,
                        ),
                  ),
                ],
              ],
            ),
          );
        }),
        CustomPaint(
          painter: _LedgerStarRulePainter(ink: ink),
          child: const SizedBox(width: double.infinity, height: 18),
        ),
      ],
    );
  }
}

Widget renderIntWithCalculatedValueStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration,
    String characterName) {
  // characterValue.serializedValue = {"value": 12, "otherValue": 2}
  var parsedValue = jsonDecode(characterValue.serializedValue);
  var value = int.tryParse(parsedValue["value"].toString()) ?? 0;
  var otherValue = int.tryParse(parsedValue["otherValue"].toString()) ?? 0;

  switch (characterValue.variant) {
    case 1:
      return PentagonWithLabel(
          value: value, otherValue: otherValue, label: statConfiguration.name);
    case 2:
      return ModifierFirstBlock(
        score: value,
        modifier: otherValue,
        label: statConfiguration.name,
      );
    case 3:
      return ClassicAbilityBlock(
        score: value,
        modifier: otherValue,
        label: statConfiguration.name,
      );
    default:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$otherValue",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 20),
          ),
          Text(
            statConfiguration.name,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 16),
          ),
          Text(
            "$value",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: const Color.fromARGB(255, 135, 127, 118), fontSize: 20),
          ),
        ],
      );
  }
}

Widget renderIntWithMaxValueStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration,
    String characterName) {
  // characterValue.serializedValue = {"value": 1, "maxValue": 17}
  var parsedValue = jsonDecode(characterValue.serializedValue);
  var value = int.tryParse(parsedValue["value"].toString()) ?? 0;
  var maxValue = int.tryParse(parsedValue["maxValue"].toString()) ?? 1;

  onValueChanged(int newValue) {
    parsedValue["value"] = newValue;
    var serializedValue = jsonEncode(parsedValue);
    onNewStatValue(serializedValue);
  }

  switch (characterValue.variant) {
    case 1:
    case 3:
      var fillPercentage =
          value == maxValue ? 1.0 : value.toDouble() / maxValue.toDouble();

      var percentageBasedColor = fillPercentage > 0.5
          ? CustomThemeProvider.of(context).theme.lightGreen
          : (fillPercentage > 0.15
              ? CustomThemeProvider.of(context).theme.lightYellow
              : CustomThemeProvider.of(context).theme.lightRed);

      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ProgressIndicatorForCharacterScreen(
            progressPercentage: fillPercentage,
            value: value,
            maxValue: maxValue,
            title: statConfiguration.name,
            color: characterValue.variant == 1
                ? CustomThemeProvider.of(context).theme.accentColor
                : percentageBasedColor,
          ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            Row(
              children: [
                Spacer(),
                _ledgerOrClassicStatButton(
                  context: context,
                  onPressed: value <= 0
                      ? null
                      : () {
                          onValueChanged(max(0, value - 1));
                        },
                  icon: FontAwesomeIcons.minus,
                ),
                Spacer(
                  flex: 6,
                ),
                _ledgerOrClassicStatButton(
                  context: context,
                  onPressed: maxValue == value
                      ? null
                      : () {
                          onValueChanged(min(value + 1, maxValue));
                        },
                  icon: FontAwesomeIcons.plus,
                ),
                Spacer(),
              ],
            ),
        ],
      );
    case 2:
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: CustomButton(
                isSubbutton: true,
                variant: CustomButtonVariant.DarkButton,
                onPressed: value <= 0
                    ? null
                    : () {
                        onValueChanged(max(0, value - 1));
                      },
                icon: CustomFaIcon(
                  icon: FontAwesomeIcons.minus,
                  size: iconSizeInlineButtons,
                  color: CustomThemeProvider.of(context).theme.textColor,
                ),
              ),
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 20,
            ),
          PentagonWithLabel(
              value: value,
              otherValue: maxValue,
              label: statConfiguration.name),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 20,
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: CustomButton(
                isSubbutton: true,
                variant: CustomButtonVariant.DarkButton,
                onPressed: maxValue == value
                    ? null
                    : () {
                        onValueChanged(min(value + 1, maxValue));
                      },
                icon: CustomFaIcon(
                  icon: FontAwesomeIcons.plus,
                  size: iconSizeInlineButtons,
                  color: CustomThemeProvider.of(context).theme.textColor,
                ),
              ),
            ),
        ],
      );
    case 4:
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            CustomButton(
              isSubbutton: true,
              variant: CustomButtonVariant.FlatButton,
              onPressed: value <= 0
                  ? null
                  : () {
                      onValueChanged(max(0, value - 1));
                    },
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.minus,
                size: iconSizeInlineButtons,
                color: CustomThemeProvider.of(context).theme.darkColor,
              ),
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 10,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  alignment: WrapAlignment.center,
                  children: [
                    ...List.generate(
                      maxValue,
                      (index) => Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < value
                                ? CustomThemeProvider.of(context)
                                    .theme
                                    .darkColor
                                : CustomThemeProvider.of(context).theme.bgColor,
                            border: Border.all(
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkColor)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  statConfiguration.name,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color:
                          CustomThemeProvider.of(context).theme.darkTextColor,
                      fontSize: 16),
                ),
              ],
            ),
          ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 10,
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            CustomButton(
              isSubbutton: true,
              variant: CustomButtonVariant.FlatButton,
              onPressed: maxValue == value
                  ? null
                  : () {
                      onValueChanged(min(value + 1, maxValue));
                    },
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.plus,
                size: iconSizeInlineButtons,
                color: CustomThemeProvider.of(context).theme.darkColor,
              ),
            ),
        ],
      );
    case 5:
    case 6:
    case 7:
    case 8:
      Widget core;
      switch (characterValue.variant) {
        case 5:
          core = HeartReservoir(
              value: value, maxValue: maxValue, label: statConfiguration.name);
          break;
        case 6:
          core = GemReservoir(
              value: value, maxValue: maxValue, label: statConfiguration.name);
          break;
        case 7:
          core = SegmentedResourceTrack(
              value: value, maxValue: maxValue, label: statConfiguration.name);
          break;
        default:
          // was V-HP-9 compact chip; wound rings (old 8) removed
          core = CompactCombatChip(
              value: value, maxValue: maxValue, label: statConfiguration.name);
      }
      if (statConfiguration.editType == CharacterStatEditType.oneTap) {
        return statVizPlusMinusRow(
          context: context,
          value: value,
          maxValue: maxValue,
          onValueChanged: onValueChanged,
          child: core,
        );
      }
      return core;
    default:
      // variant is null or 0
      if (isDecoratedSheetSkinActive(context) &&
          statConfiguration.name.toLowerCase().contains('zauberpunkt')) {
        final ink = CustomThemeProvider.of(context).theme.darkTextColor;
        final nightCartographer = isNightCartographerActive(context);
        final sealTextColor = nightCartographer
            ? const Color(0xFFF0E6D4)
            : const Color(0xFFF5E6D3);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (nightCartographer)
                    const CartographerCompassRings(
                      size: 96,
                      color: Color(0xffD4AF77),
                    )
                  else
                    Image.asset(
                      ArcaneLedgerAssets.waxSeal,
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  Text(
                    '$value/$maxValue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: sealTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      height: 1.0,
                      fontFamily: 'Ruwudu',
                      shadows: const [
                        Shadow(
                          color: Color(0x88000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statConfiguration.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: ink,
                    fontSize: 20,
                    fontFamily: 'Ruwudu',
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              'Verfügbare ${statConfiguration.name}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: ink.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontFamily: 'Ruwudu',
                  ),
            ),
          ],
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            CustomButton(
              isSubbutton: true,
              variant: CustomButtonVariant.FlatButton,
              onPressed: value <= 0
                  ? null
                  : () {
                      onValueChanged(max(0, value - 1));
                    },
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.minus,
                size: iconSizeInlineButtons,
                color: CustomThemeProvider.of(context).theme.darkColor,
              ),
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 20,
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$value / $maxValue",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: CustomThemeProvider.of(context).theme.darkTextColor,
                    fontSize: 20),
              ),
              Text(
                statConfiguration.name,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: CustomThemeProvider.of(context).theme.darkTextColor,
                    fontSize: 16),
              ),
            ],
          ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            SizedBox(
              width: 20,
            ),
          if (statConfiguration.editType == CharacterStatEditType.oneTap)
            CustomButton(
              isSubbutton: true,
              variant: CustomButtonVariant.FlatButton,
              onPressed: maxValue == value
                  ? null
                  : () {
                      onValueChanged(min(value + 1, maxValue));
                    },
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.plus,
                size: iconSizeInlineButtons,
                color: CustomThemeProvider.of(context).theme.darkColor,
              ),
            ),
        ],
      );
  }
}

Widget _ledgerOrClassicStatButton({
  required BuildContext context,
  required VoidCallback? onPressed,
  required IconData icon,
}) {
  final ink = CustomThemeProvider.of(context).theme.darkColor;
  if (isDecoratedSheetSkinActive(context)) {
    return CupertinoButton(
      onPressed: onPressed,
      minSize: 0,
      padding: EdgeInsets.zero,
      child: Opacity(
        opacity: onPressed == null ? 0.35 : 1,
        child: CustomPaint(
          painter: _LedgerInkSquarePainter(ink: ink),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: CustomFaIcon(
                icon: icon,
                size: iconSizeInlineButtons,
                color: ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
  return CustomButton(
    isSubbutton: true,
    variant: CustomButtonVariant.DarkButton,
    onPressed: onPressed,
    icon: CustomFaIcon(
      icon: icon,
      size: iconSizeInlineButtons,
      color: CustomThemeProvider.of(context).theme.textColor,
    ),
  );
}

class _LedgerInkSquarePainter extends CustomPainter {
  final Color ink;

  _LedgerInkSquarePainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = ink.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final inner = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(2),
    );
    canvas.drawRRect(r, outer);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
        const Radius.circular(1.5),
      ),
      inner,
    );
  }

  @override
  bool shouldRepaint(covariant _LedgerInkSquarePainter oldDelegate) =>
      oldDelegate.ink != ink;
}

Widget renderListOfIntsWithIconsStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration,
    String characterName) {
  // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
  // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
  var parsedValue = ((jsonDecode(characterValue.serializedValue)
          as Map<String, dynamic>)["values"] as List<dynamic>)
      .map((t) => t as Map<String, dynamic>)
      .toList();

  var statConfigLabels =
      (jsonDecode(statConfiguration.jsonSerializedAdditionalData!)["values"]
              as List<dynamic>)
          .map((t) => t as Map<String, dynamic>)
          .toList();

  var filledValues = statConfigLabels
      .map(
        (e) {
          var parsedMatchingValue = parsedValue.singleWhereOrNull(
            (element) => element["uuid"] == e["uuid"],
          );

          return (
            label: e["label"] as String,
            iconName: e["iconName"] as String,
            value: parsedMatchingValue?["value"] as int? ?? 0,
          );
        },
      )
      .toList();
  if (!isDecoratedSheetSkinActive(context)) {
    filledValues = filledValues.sortedBy((e) => e.label).toList();
  }

  switch (characterValue.variant) {
    case 2:
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: filledValues
            .map(
              (t) => IconMedallion(
                iconName: t.iconName,
                label: t.label,
                value: t.value,
              ),
            )
            .toList(),
      );
    case 3:
      return IconStatRibbon(items: filledValues);
    case 4:
      return IconPrimaryHeroRow(items: filledValues);
  }

  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    runSpacing: 10,
    children: filledValues
        .map(
          (t) {
            if (isDecoratedSheetSkinActive(context)) {
              final ink = CustomThemeProvider.of(context).theme.darkColor;
              return SizedBox(
                width: 76,
                child: Column(
                  children: [
                    CustomPaint(
                      painter: _LedgerInkIconRingPainter(ink: ink),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: getIconForIdentifier(
                          name: t.iconName,
                          color: ink,
                          size: 26,
                        ).$2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.value}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 18,
                            color: CustomThemeProvider.of(context)
                                .theme
                                .darkTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      t.label,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 11,
                            color: CustomThemeProvider.of(context)
                                .theme
                                .darkTextColor,
                          ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox(
              width: characterValue.variant == 0 ? 100 : 80,
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getIconForIdentifier(
                              name: t.iconName,
                              color:
                                  CustomThemeProvider.of(context).theme.darkColor,
                              size: 32)
                          .$2,
                      SizedBox(
                        height: 5,
                      ),
                      if (characterValue.variant == 0)
                        Text(
                          "${t.label}: ${t.value}",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      if (characterValue.variant == 1)
                        Text(
                          "${t.value}",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      if (characterValue.variant == 1)
                        SizedBox(
                          height: 1,
                        ),
                      if (characterValue.variant == 1)
                        Text(
                          t.label,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 12,
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        )
        .toList(),
  );
}

class _LedgerInkIconRingPainter extends CustomPainter {
  final Color ink;

  _LedgerInkIconRingPainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = min(size.width, size.height) / 2 - 1;
    final outer = Paint()
      ..color = ink.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final inner = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawCircle(c, r, outer);
    canvas.drawCircle(c, r - 3.5, inner);
  }

  @override
  bool shouldRepaint(covariant _LedgerInkIconRingPainter oldDelegate) =>
      oldDelegate.ink != ink;
}

Widget renderListOfIntWithCalculatedValuesStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration,
    String characterName) {
  // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
  // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
  var parsedValue = ((jsonDecode(characterValue.serializedValue)
          as Map<String, dynamic>)["values"] as List<dynamic>)
      .map((t) => t as Map<String, dynamic>)
      .toList();

  var statConfigLabels =
      (jsonDecode(statConfiguration.jsonSerializedAdditionalData!)["values"]
              as List<dynamic>)
          .map((t) => t as Map<String, dynamic>)
          .toList();

  var filledValues = statConfigLabels
      .map(
        (e) {
          var parsedMatchingValue = parsedValue.singleWhereOrNull(
            (element) => element["uuid"] == e["uuid"],
          );

          return (
            label: e["label"] as String,
            value: parsedMatchingValue?["value"] as int? ?? 0,
            otherValue: parsedMatchingValue?["otherValue"] as int? ?? 0
          );
        },
      )
      .sortedBy((e) => e.label)
      .toList();

  switch (characterValue.variant) {
    case 1:
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: filledValues
            .map(
              (t) => ModifierFirstBlock(
                score: t.value,
                modifier: t.otherValue,
                label: t.label,
              ),
            )
            .toList(),
      );
    case 2:
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: filledValues
            .map(
              (t) => HexAbilityTile(
                score: t.value,
                modifier: t.otherValue,
                label: t.label,
              ),
            )
            .toList(),
      );
    case 3:
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: filledValues
            .map(
              (t) => ClassicAbilityBlock(
                score: t.value,
                modifier: t.otherValue,
                label: t.label,
              ),
            )
            .toList(),
      );
    default:
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: filledValues
            .map(
              (t) => PentagonWithLabel(
                  value: t.value, otherValue: t.otherValue, label: t.label),
            )
            .toList(),
      );
  }
}

Widget renderCharacterNameWithLevelAndAdditionalDetailsStat(
  void Function(String newSerializedValue) onNewStatValue,
  RpgCharacterStatValue characterValue,
  BuildContext context,
  CharacterStatDefinition statConfiguration,
  String characterName,
) {
// => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "Volk"}]}
  // => characterValue.serializedValue == {"level": 2,"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": "Zwerg"}]}
  var parsedCharacterValueMap =
      jsonDecode(characterValue.serializedValue) as Map<String, dynamic>;
  var parsedValue = (parsedCharacterValueMap["values"] as List<dynamic>)
      .map((t) => t as Map<String, dynamic>)
      .toList();

  var statConfigLabels =
      (jsonDecode(statConfiguration.jsonSerializedAdditionalData!)["values"]
              as List<dynamic>)
          .map((t) => t as Map<String, dynamic>)
          .toList();

  var characterLevel = parsedCharacterValueMap["level"] is String
      ? int.parse(parsedCharacterValueMap["level"])
      : parsedCharacterValueMap["level"];

  var filledValues = statConfigLabels
      .map(
        (e) {
          var parsedMatchingValue = parsedValue.singleWhereOrNull(
            (element) => element["uuid"] == e["uuid"],
          );

          return (
            label: e["label"] as String,
            value: parsedMatchingValue?["value"].toString() ?? "",
          );
        },
      )
      .sortedBy((e) => e.label)
      .toList();

  // Optional portrait: {"imageUrl": "...", "imagePrompt": "...", "level": ..., "values": [...]}
  final storedImageUrl = parsedCharacterValueMap["imageUrl"] as String?;
  final resolvedPortraitUrl = (storedImageUrl == null || storedImageUrl.isEmpty)
      ? null
      : resolveStatImageUrl(storedImageUrl);

  return LayoutBuilder(builder: (context, constraints) {
    final details = filledValues
        .map((t) => (label: t.label, value: t.value))
        .toList();

    switch (characterValue.variant) {
      case 1:
        return IdentityBanner(
          characterName: characterName,
          level: characterLevel is int
              ? characterLevel
              : int.tryParse('$characterLevel') ?? 0,
          details: details,
          levelAbbr: S.of(context).levelAbbr,
        );
      case 2:
        return IdentityPortraitCard(
          characterName: characterName,
          level: characterLevel is int
              ? characterLevel
              : int.tryParse('$characterLevel') ?? 0,
          details: details,
          levelAbbr: S.of(context).levelAbbr,
          imageUrl: resolvedPortraitUrl,
        );
      case 3:
        return IdentityMinimalLine(
          characterName: characterName,
          level: characterLevel is int
              ? characterLevel
              : int.tryParse('$characterLevel') ?? 0,
          details: details,
          levelAbbr: S.of(context).levelAbbr,
        );
    }

    var maxWidth = min(140.0 + 10 + 200, constraints.maxWidth);

    var firstExpandedFlex = (140 / maxWidth) * 100;
    var secondExpandedFlex = (200 / maxWidth) * 100;
    final levelInt = characterLevel is int
        ? characterLevel
        : int.tryParse('$characterLevel') ?? 0;

    return SizedBox(
      width: maxWidth,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: firstExpandedFlex.round(),
            child: Builder(builder: (context) {
              final sealChild = LayoutBuilder(builder: (context, constrin) {
                final side = constrin.maxWidth;
                if (isNightCartographerActive(context)) {
                  return CartographerLevelBadge(
                    level: levelInt,
                    levelAbbr: S.of(context).levelAbbr,
                    size: side,
                  );
                }
                if (isArcaneLedgerActive(context)) {
                  return SizedBox(
                    width: side,
                    height: side,
                    child: CharacterSheetLevelSeal(
                      level: levelInt,
                      levelAbbr: S.of(context).levelAbbr,
                      size: side,
                    ),
                  );
                }
                return Container(
                  width: side,
                  height: side,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomThemeProvider.of(context).theme.darkColor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        characterLevel.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .textColor,
                                fontSize: 28),
                      ),
                      Text(
                        S.of(context).levelAbbr,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .textColor,
                                fontSize: 28),
                      ),
                    ],
                  ),
                );
              });
              // Rectangular ShadowWidget casts a white/grey box on parchment.
              if (isDecoratedSheetSkinActive(context)) return sealChild;
              return CustomShadowWidget(child: sealChild);
            }),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: secondExpandedFlex.round(),
            child: Container(
              height: 150,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StaticGrid(
                      colGap: 10,
                      rowGap: 4,
                      expandedFlexValues: [1, 2],
                      columnCrossAxisAlignment: CrossAxisAlignment.start,
                      columnMainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        S.of(context).characterNameLabel,
                        characterName,
                        ...filledValues
                            .map((t) => ["${t.label}:", t.value])
                            .expand((i) => i)
                      ]
                          .asMap()
                          .entries
                          .map((strKVP) => AutoSizeText(
                                strKVP.value,
                                textAlign: strKVP.key % 2 == 0
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: CustomThemeProvider.of(context)
                                            .theme
                                            .darkTextColor,
                                        fontSize:
                                            strKVP.key % 2 == 0 ? 16 : 24),
                                maxFontSize: strKVP.key % 2 == 0 ? 16 : 24,
                                maxLines: 1,
                                minFontSize: 10,
                              ))
                          .toList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}

Column renderIntStat(
    void Function(String newSerializedValue) onNewStatValue,
    RpgCharacterStatValue characterValue,
    BuildContext context,
    CharacterStatDefinition statConfiguration) {
  // characterValue.serializedValue = {"value": 1}
  final valueStr =
      jsonDecode(characterValue.serializedValue)["value"].toString();
  if (characterValue.variant == 1) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LargeNumeralTile(value: valueStr, label: statConfiguration.name),
      ],
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        valueStr,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: CustomThemeProvider.of(context).theme.darkTextColor,
            fontSize: 20),
      ),
      Text(
        statConfiguration.name,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: CustomThemeProvider.of(context).theme.darkTextColor,
            fontSize: 16),
      ),
    ],
  );
}

Widget renderImageStat(
    void Function(String newSerializedValue) onNewStatValue,
    CharacterStatDefinition statConfiguration,
    BuildContext context,
    RpgCharacterStatValue characterValue,
    String characterName) {
  //  {"imageUrl": "someUrl", "value": "some text"}
  var parsedValue = jsonDecode(characterValue.serializedValue);
  var imageUrl = parsedValue["imageUrl"];
  final quote = parsedValue["value"]?.toString();
  final ledger = isDecoratedSheetSkinActive(context);
  final showQuote = ledger && quote != null && quote.trim().isNotEmpty;

  final image = BorderedImage(
    backgroundColor: CustomThemeProvider.of(context).theme.bgColor,
    lightColor: CustomThemeProvider.of(context).theme.darkColor,
    isGreyscale: false,
    isLoading: false,
    noPadding: true,
    imageUrl: resolveStatImageUrl(imageUrl as String?),
  );

  if (!showQuote) return image;

  final ink = CustomThemeProvider.of(context).theme.darkColor;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomPaint(
        painter: _LedgerStarRulePainter(ink: ink),
        child: const SizedBox(width: double.infinity, height: 18),
      ),
      image,
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          '„$quote“',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        '— $characterName',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: CustomThemeProvider.of(context).theme.darkTextColor,
              fontSize: 12,
            ),
      ),
      const SizedBox(height: 8),
      CustomPaint(
        painter: _LedgerStarRulePainter(ink: ink),
        child: const SizedBox(width: double.infinity, height: 18),
      ),
    ],
  );
}

class _LedgerStarRulePainter extends CustomPainter {
  final Color ink;

  _LedgerStarRulePainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    final midY = size.height / 2;
    canvas.drawLine(Offset(8, midY), Offset(size.width / 2 - 14, midY), paint);
    canvas.drawLine(
        Offset(size.width / 2 + 14, midY), Offset(size.width - 8, midY), paint);
    final star = Paint()
      ..color = ink.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final c = Offset(size.width / 2, midY);
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -pi / 2 + i * pi / 4;
      final radius = i.isEven ? 5.0 : 2.0;
      final p = Offset(c.dx + cos(angle) * radius, c.dy + sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, star);
  }

  @override
  bool shouldRepaint(covariant _LedgerStarRulePainter oldDelegate) =>
      oldDelegate.ink != ink;
}

Widget renderTextStat(
    void Function(String newSerializedValue) onNewStatValue,
    CharacterStatDefinition statConfiguration,
    BuildContext context,
    RpgCharacterStatValue characterValue) {
  // characterValue.serializedValue = {"value": "asdf"}
  final body =
      jsonDecode(characterValue.serializedValue)["value"].toString();
  final hideTitle = characterValue.hideLabelOfStat == true;

  if (isDecoratedSheetSkinActive(context)) {
    final ink = CustomThemeProvider.of(context).theme.darkTextColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hideTitle) ...[
            Text(
              statConfiguration.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: ink,
                    fontSize: 20,
                    fontFamily: 'Ruwudu',
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.only(top: 4, bottom: 10),
              color: ink.withValues(alpha: 0.55),
            ),
          ],
          CustomMarkdownBody(text: body),
          const SizedBox(height: 10),
          CustomPaint(
            painter: _LedgerStarRulePainter(ink: ink),
            child: const SizedBox(width: double.infinity, height: 18),
          ),
        ],
      ),
    );
  }

  switch (characterValue.variant) {
    case 1:
      return CollapsibleLorePanel(
        title: statConfiguration.name,
        body: body,
        hideTitle: hideTitle,
      );
    case 2:
      return ParchmentQuoteFrame(
        title: statConfiguration.name,
        body: body,
        hideTitle: hideTitle,
      );
    default:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hideTitle)
            Text(
              statConfiguration.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: CustomThemeProvider.of(context).theme.darkTextColor,
                  fontSize: 20),
            ),
          if (!hideTitle)
            SizedBox(
              height: 10,
            ),
          CustomMarkdownBody(text: body),
          SizedBox(
            height: 10,
          ),
        ],
      );
  }
}
