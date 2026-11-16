import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// Character sheet tabs a player gets to see.
///
/// Tabs without any property in the campaign's character sheet are left out
/// (UX test 2026-11-16, SP-5): they would only be empty pages, like the
/// unused template tabs "Features", "Attacks" and "Spells".
List<CharacterStatsTabDefinition> visibleCharacterStatTabs(
  RpgConfigurationModel rpgConfig,
) {
  return (rpgConfig.characterStatTabsDefinition ?? const [])
      .where((tab) => tab.statsInTab.isNotEmpty)
      .toList();
}

/// Page index of the campaign's default tab among [visibleCharacterStatTabs],
/// or null when there is none.
int? defaultVisibleCharacterStatTabIndex(RpgConfigurationModel rpgConfig) {
  final index = visibleCharacterStatTabs(rpgConfig)
      .indexWhere((tab) => tab.isDefaultTab);
  return index < 0 ? null : index;
}
