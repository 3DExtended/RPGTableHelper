import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// True when the character is missing any campaign-defined stat uuid, or has an
/// empty name. Used for Appearance picker hybrid mode (immediate vs Save/Cancel).
bool hasMissingRequiredCampaignStats({
  required RpgConfigurationModel rpgConfig,
  required RpgCharacterConfigurationBase character,
}) {
  final defs = rpgConfig.characterStatTabsDefinition
          ?.expand((t) => t.statsInTab)
          .toList() ??
      const <CharacterStatDefinition>[];
  final present = character.characterStats.map((s) => s.statUuid).toSet();
  // Computed stats are never typed in, so they are never missing; neither
  // are stats of a type from a newer app version (nothing to type in here).
  final missingDef = defs.any((st) =>
      !present.contains(st.statUuid) &&
      !StatNumbers.isComputed(st) &&
      st.valueType != CharacterStatValueType.unsupported);
  return missingDef || character.characterName.trim().isEmpty;
}
