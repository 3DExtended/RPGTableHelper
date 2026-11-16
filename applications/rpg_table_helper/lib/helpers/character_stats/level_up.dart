import 'dart:convert';

import 'package:quest_keeper/helpers/character_stats/character_stats_form_pages.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// Key in a property's additional data: the guided level-up ("Stufenaufstieg")
/// asks for the property. Older app versions ignore it.
const statAskOnLevelUpKey = 'askOnLevelUp';

Map<String, dynamic> _additionalData(String? json) {
  if (json == null || json.trim().isEmpty) return {};
  try {
    final decoded = jsonDecode(json);
    return decoded is Map<String, dynamic> ? decoded : {};
  } catch (_) {
    return {};
  }
}

/// Whether the level-up asks for [stat].
bool statAsksOnLevelUp(CharacterStatDefinition stat) =>
    _additionalData(stat.jsonSerializedAdditionalData)[statAskOnLevelUpKey] ==
    true;

/// [additionalData] with the level-up mark set or taken away; null when
/// nothing is left.
String? withAskOnLevelUp(String? additionalData, bool ask) {
  final data = _additionalData(additionalData);
  if (ask) {
    data[statAskOnLevelUpKey] = true;
  } else {
    data.remove(statAskOnLevelUpKey);
  }
  return data.isEmpty ? null : jsonEncode(data);
}

/// Field types the level-up can ask for. The character summary is always
/// asked (it holds the level); companions and transformations are chosen
/// elsewhere.
bool canAskOnLevelUp(CharacterStatValueType type) => switch (type) {
  CharacterStatValueType.characterNameWithLevelAndAdditionalDetails ||
  CharacterStatValueType.companionSelector ||
  CharacterStatValueType.transformIntoAlternateFormBtn ||
  CharacterStatValueType.unsupported => false,
  _ => true,
};

/// The character summary that holds the level, or null when the campaign
/// has none (or switched the level off): then there is no level-up.
CharacterStatDefinition? levelStatOf(RpgConfigurationModel config) {
  for (final tab in config.characterStatTabsDefinition ??
      const <CharacterStatsTabDefinition>[]) {
    for (final stat in tab.statsInTab) {
      if (stat.valueType ==
              CharacterStatValueType
                  .characterNameWithLevelAndAdditionalDetails &&
          characterSummaryShowsLevel(stat)) {
        return stat;
      }
    }
  }
  return null;
}

/// The level stored in [value] of the character summary (1 without one).
int levelOf(RpgCharacterStatValue? value) {
  final level = _additionalData(value?.serializedValue)['level'];
  final parsed = level is int ? level : int.tryParse('${level ?? ''}');
  return parsed == null || parsed < 1 ? 1 : parsed;
}

/// [value] of the character summary [levelStat] one level up; a fresh value
/// at level 2 when there is none yet.
RpgCharacterStatValue nextLevelValue(
  CharacterStatDefinition levelStat,
  RpgCharacterStatValue? value,
) {
  final data = _additionalData(value?.serializedValue);
  final serialized = jsonEncode({
    ...data,
    'values': data['values'] is List ? data['values'] : const [],
    'level': levelOf(value) + 1,
  });
  return value == null
      ? RpgCharacterStatValue(
          statUuid: levelStat.statUuid,
          serializedValue: serialized,
          hideFromCharacterScreen: false,
          variant: 0,
          hideLabelOfStat: false,
        )
      : value.copyWith(serializedValue: serialized);
}

/// The pages of the level-up, in tab order: the tab with the character
/// summary (the level) first, then every tab with properties marked "Beim
/// Stufenaufstieg abfragen". Empty when the campaign has no level.
List<CharacterStatsFormPage> buildLevelUpPages({
  required RpgConfigurationModel rpgConfig,
  required bool isCompanion,
}) {
  final levelStat = levelStatOf(rpgConfig);
  if (levelStat == null) return const [];

  final pages = <CharacterStatsFormPage>[];
  CharacterStatsFormPage? levelPage;
  for (final tab in rpgConfig.characterStatTabsDefinition ??
      const <CharacterStatsTabDefinition>[]) {
    final stats = fillableStatsOfTab(tab, isCompanion: isCompanion)
        .where((s) =>
            s.statUuid == levelStat.statUuid ||
            (canAskOnLevelUp(s.valueType) && statAsksOnLevelUp(s)))
        .toList();
    if (stats.isEmpty) continue;
    final page =
        CharacterStatsFormPage(tab: tab, stats: stats, showNameField: false);
    if (stats.any((s) => s.statUuid == levelStat.statUuid)) {
      // The level first, also on its own page.
      levelPage = CharacterStatsFormPage(
        tab: tab,
        stats: [
          levelStat,
          ...stats.where((s) => s.statUuid != levelStat.statUuid),
        ],
        showNameField: false,
      );
    } else {
      pages.add(page);
    }
  }
  return [?levelPage, ...pages];
}
