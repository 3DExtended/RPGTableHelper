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
  final missingDef = defs.any((st) => !present.contains(st.statUuid));
  return missingDef || character.characterName.trim().isEmpty;
}
