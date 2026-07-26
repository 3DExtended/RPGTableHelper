import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

class InitiativeBonusHint {
  final String label;
  final int bonus;

  const InitiativeBonusHint({required this.label, required this.bonus});
}

/// A selectable entry of a list-type stat (e.g. one ability row).
class InitiativeBonusListEntry {
  final String uuid;
  final String label;

  const InitiativeBonusListEntry({required this.uuid, required this.label});
}

/// Stat types the DM can mark as the initiative bonus source.
const eligibleInitiativeBonusStatTypes = {
  CharacterStatValueType.int,
  CharacterStatValueType.intWithCalculatedValue,
  CharacterStatValueType.intWithMaxValue,
  CharacterStatValueType.listOfIntWithCalculatedValues,
  CharacterStatValueType.listOfIntsWithIcons,
};

/// Stat types that require a list-entry pick (one row of the group).
const listInitiativeBonusStatTypes = {
  CharacterStatValueType.listOfIntWithCalculatedValues,
  CharacterStatValueType.listOfIntsWithIcons,
};

/// Stat types where the DM has to disambiguate between two numbers.
const fieldPickerInitiativeBonusStatTypes = {
  CharacterStatValueType.intWithCalculatedValue,
  CharacterStatValueType.listOfIntWithCalculatedValues,
  CharacterStatValueType.intWithMaxValue,
};

bool isListInitiativeBonusStatType(CharacterStatValueType type) =>
    listInitiativeBonusStatTypes.contains(type);

bool hasFieldPickerForInitiativeBonusStatType(CharacterStatValueType type) =>
    fieldPickerInitiativeBonusStatTypes.contains(type);

/// Parses the selectable list entries (uuid + label) of a list-type stat.
List<InitiativeBonusListEntry> initiativeBonusListEntriesFor(
  CharacterStatDefinition definition,
) {
  final raw = definition.jsonSerializedAdditionalData;
  if (raw == null || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final values = decoded['values'];
    if (values is! List) return const [];
    return values.whereType<Map>().map((entry) {
      final uuid = entry['uuid']?.toString() ?? '';
      final label = entry['label']?.toString() ?? '';
      return InitiativeBonusListEntry(uuid: uuid, label: label);
    }).where((entry) => entry.uuid.isNotEmpty).toList();
  } catch (_) {
    return const [];
  }
}

/// Formats a bonus for the player helper sentence: `(+N)` / `(-N)` / `(0)`.
String formatInitiativeBonus(int bonus) {
  if (bonus == 0) return '(0)';
  if (bonus > 0) return '(+$bonus)';
  return '($bonus)';
}

/// Resolves the campaign-marked initiative bonus for [character].
///
/// Returns null when unset, soft-invalid (missing definition/entry/value),
/// or the stored number is missing/unfilled.
InitiativeBonusHint? resolveInitiativeBonus({
  required RpgConfigurationModel rpgConfig,
  required RpgCharacterConfigurationBase character,
}) {
  final statUuid = rpgConfig.initiativeBonusStatUuid;
  if (statUuid == null || statUuid.isEmpty) return null;

  final definition = _findStatDefinition(rpgConfig, statUuid);
  if (definition == null) return null;

  final characterStat =
      character.characterStats.where((s) => s.statUuid == statUuid).firstOrNull;
  if (characterStat == null) return null;

  Map<String, dynamic> parsed;
  try {
    parsed = jsonDecode(characterStat.serializedValue) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }

  final field = rpgConfig.initiativeBonusField ??
      defaultInitiativeBonusFieldFor(definition.valueType);

  switch (definition.valueType) {
    case CharacterStatValueType.int:
    case CharacterStatValueType.intWithCalculatedValue:
    case CharacterStatValueType.intWithMaxValue:
      final bonus = _readField(parsed, field);
      if (bonus == null) return null;
      return InitiativeBonusHint(label: definition.name, bonus: bonus);

    case CharacterStatValueType.listOfIntWithCalculatedValues:
    case CharacterStatValueType.listOfIntsWithIcons:
      final entryUuid = rpgConfig.initiativeBonusListEntryUuid;
      if (entryUuid == null || entryUuid.isEmpty) return null;

      final label = _listEntryLabel(definition, entryUuid);
      if (label == null) return null;

      final values = parsed['values'];
      if (values is! List) return null;
      final entry = values.whereType<Map>().cast<Map>().firstWhereOrNull(
            (e) => e['uuid']?.toString() == entryUuid,
          );
      if (entry == null) return null;

      final bonus = _readField(Map<String, dynamic>.from(entry), field);
      if (bonus == null) return null;
      return InitiativeBonusHint(label: label, bonus: bonus);

    default:
      return null;
  }
}

CharacterStatDefinition? _findStatDefinition(
  RpgConfigurationModel rpgConfig,
  String statUuid,
) {
  for (final tab in rpgConfig.characterStatTabsDefinition ?? const []) {
    for (final stat in tab.statsInTab) {
      if (stat.statUuid == statUuid) return stat;
    }
  }
  return null;
}

/// Default field per PRD: `otherValue` for calculated pairs, `value` (current)
/// for HP-style max pairs, `value` for everything else.
InitiativeBonusField defaultInitiativeBonusFieldFor(CharacterStatValueType type) {
  switch (type) {
    case CharacterStatValueType.intWithCalculatedValue:
    case CharacterStatValueType.listOfIntWithCalculatedValues:
      return InitiativeBonusField.otherValue;
    case CharacterStatValueType.intWithMaxValue:
      return InitiativeBonusField.value;
    default:
      return InitiativeBonusField.value;
  }
}

String? _listEntryLabel(CharacterStatDefinition definition, String entryUuid) {
  final raw = definition.jsonSerializedAdditionalData;
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final values = decoded['values'];
    if (values is! List) return null;
    final entry = values.whereType<Map>().cast<Map>().firstWhereOrNull(
          (e) => e['uuid']?.toString() == entryUuid,
        );
    if (entry == null) return null;
    final label = entry['label']?.toString();
    if (label == null || label.isEmpty) return null;
    return label;
  } catch (_) {
    return null;
  }
}

int? _readField(Map<String, dynamic> map, InitiativeBonusField field) {
  final key = switch (field) {
    InitiativeBonusField.value => 'value',
    InitiativeBonusField.otherValue => 'otherValue',
    InitiativeBonusField.maxValue => 'maxValue',
  };
  if (!map.containsKey(key) || map[key] == null) {
    // Legacy single calculated stats sometimes used calculatedValue.
    if (field == InitiativeBonusField.otherValue &&
        map.containsKey('calculatedValue') &&
        map['calculatedValue'] != null) {
      return _asInt(map['calculatedValue']);
    }
    return null;
  }
  return _asInt(map[key]);
}

int? _asInt(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw.toString());
}
