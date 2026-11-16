import 'dart:convert';

import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/character_stats_form_pages.dart';
import 'package:quest_keeper/helpers/character_stats/level_up.dart';
import 'package:quest_keeper/models/prepared_character.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:uuid/v7.dart';

/// A new prepared character without a name or values yet.
PreparedCharacter newPreparedCharacter() => PreparedCharacter(
  uuid: const UuidV7().generate(),
  characterName: '',
  characterStats: const [],
);

/// Field types a prepared character leaves to the player: companions and
/// transformations belong to the player's own character.
bool _isPreparable(CharacterStatDefinition stat) =>
    stat.valueType != CharacterStatValueType.companionSelector &&
    stat.valueType != CharacterStatValueType.transformIntoAlternateFormBtn;

/// The pages to fill in a prepared character: every tab with fields, all of
/// them (filled ones too, to edit them), the name on the first page.
List<CharacterStatsFormPage> preparedCharacterPages(
  RpgConfigurationModel config,
) {
  final pages = <CharacterStatsFormPage>[];
  for (final tab in config.characterStatTabsDefinition ??
      const <CharacterStatsTabDefinition>[]) {
    final stats = fillableStatsOfTab(tab, isCompanion: false)
        .where(_isPreparable)
        .toList();
    if (stats.isEmpty) continue;
    pages.add(CharacterStatsFormPage(
      tab: tab,
      stats: stats,
      showNameField: pages.isEmpty,
    ));
  }
  if (pages.isEmpty) {
    return const [
      CharacterStatsFormPage(tab: null, stats: [], showNameField: true),
    ];
  }
  return pages;
}

/// [prepared] with [stats] (by property) and, when given, the [name].
PreparedCharacter withPreparedValues(
  PreparedCharacter prepared,
  List<RpgCharacterStatValue> stats,
  String? name,
) {
  final changed = {for (final stat in stats) stat.statUuid: stat};
  return prepared.copyWith(
    characterName: name ?? prepared.characterName,
    characterStats: [
      for (final stat in prepared.characterStats)
        changed.remove(stat.statUuid) ?? stat,
      ...changed.values,
    ],
  );
}

/// [config] with [prepared] in place of the one with its uuid, or added.
RpgConfigurationModel withPreparedCharacter(
  RpgConfigurationModel config,
  PreparedCharacter prepared,
) {
  final list = [...?config.preparedCharacters];
  final index = list.indexWhere((p) => p.uuid == prepared.uuid);
  if (index < 0) {
    list.add(prepared);
  } else {
    list[index] = prepared;
  }
  return config.copyWith(preparedCharacters: list);
}

/// [config] without the prepared character [uuid].
RpgConfigurationModel withoutPreparedCharacter(
  RpgConfigurationModel config,
  String uuid,
) {
  final list = [...?config.preparedCharacters]
    ..removeWhere((p) => p.uuid == uuid);
  return config.copyWith(preparedCharacters: list.isEmpty ? null : list);
}

/// One line about [prepared] from its character summary, e.g.
/// "Stufe 3 · Magierin · Elfe"; empty when there is nothing to say.
String preparedCharacterSummary(
  S s,
  RpgConfigurationModel config,
  PreparedCharacter prepared,
) {
  final summaryStat = (config.characterStatTabsDefinition ??
          const <CharacterStatsTabDefinition>[])
      .expand((t) => t.statsInTab)
      .where((stat) =>
          stat.valueType ==
          CharacterStatValueType.characterNameWithLevelAndAdditionalDetails)
      .firstOrNull;
  if (summaryStat == null) return '';
  final value = prepared.characterStats
      .where((v) => v.statUuid == summaryStat.statUuid)
      .firstOrNull;
  if (value == null) return '';

  Map<String, dynamic> data;
  try {
    final decoded = jsonDecode(value.serializedValue);
    data = decoded is Map<String, dynamic> ? decoded : {};
  } catch (_) {
    data = {};
  }
  return [
    if (levelStatOf(config) != null) '${s.level} ${levelOf(value)}',
    for (final entry in (data['values'] is List ? data['values'] as List : []))
      if (entry is Map && '${entry['value'] ?? ''}'.trim().isNotEmpty)
        '${entry['value']}'.trim(),
  ].join(' · ');
}

/// [prepared] as a character of [config], to show its sheet the way the
/// player who takes it over sees it: its values and nothing else, so the
/// fields it leaves open read "Noch leer" there too.
RpgCharacterConfiguration preparedCharacterAsCharacter(
  RpgConfigurationModel config,
  PreparedCharacter prepared,
) => takePreparedCharacter(
  RpgCharacterConfiguration.getBaseConfiguration(config).copyWith(
    characterStats: [],
    companionCharacters: [],
    transformationComponents: [],
    alternateForms: [],
    alternateForm: null,
    isAlternateFormActive: null,
    inventory: [],
  ),
  prepared,
);

/// [own] taking over [prepared]: its name and sheet values. Values of the
/// player's own character the prepared one does not have stay.
RpgCharacterConfiguration takePreparedCharacter(
  RpgCharacterConfiguration own,
  PreparedCharacter prepared,
) {
  final taken = {for (final stat in prepared.characterStats) stat.statUuid};
  return own.copyWith(
    characterName: prepared.characterName.trim().isEmpty
        ? own.characterName
        : prepared.characterName,
    characterStats: [
      for (final stat in own.characterStats)
        if (!taken.contains(stat.statUuid)) stat,
      ...prepared.characterStats,
    ],
  );
}
