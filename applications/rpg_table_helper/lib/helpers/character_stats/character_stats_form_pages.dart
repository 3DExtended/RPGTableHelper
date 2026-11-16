import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// One page of the character form: the fields of one sheet tab.
class CharacterStatsFormPage {
  const CharacterStatsFormPage({
    required this.tab,
    required this.stats,
    required this.showNameField,
  });

  /// The sheet tab this page belongs to. Null only for a page that asks for
  /// nothing but the character name.
  final CharacterStatsTabDefinition? tab;

  /// The fields shown on this page, in tab order.
  final List<CharacterStatDefinition> stats;

  /// Whether the character name field is shown at the top of this page.
  final bool showNameField;
}

/// Stats of [tab] a player types in for [character]: computed stats are
/// never typed in, and companions cannot select companions.
List<CharacterStatDefinition> fillableStatsOfTab(
  CharacterStatsTabDefinition tab, {
  required bool isCompanion,
}) {
  return tab.statsInTab
      .where((s) => !StatNumbers.isComputed(s))
      .where(
        (s) =>
            !isCompanion ||
            s.valueType != CharacterStatValueType.companionSelector,
      )
      .toList();
}

/// Builds the pages of the character form, one page per sheet tab.
///
/// Without [filterTabId] (first setup, or resuming it) a page holds only the
/// fields the character has no value for yet, and tabs without such fields
/// are left out. So the form always continues where something is missing.
/// The name field sits on the first page while the name is empty.
///
/// With [filterTabId] (editing one tab from the sheet menu) there is a single
/// page with every field of that tab; the name is part of the default tab.
///
/// Returns an empty list when there is nothing to fill in.
List<CharacterStatsFormPage> buildCharacterStatsFormPages({
  required RpgConfigurationModel rpgConfig,
  required RpgCharacterConfigurationBase character,
  required bool isCompanion,
  String? filterTabId,
}) {
  final tabs =
      rpgConfig.characterStatTabsDefinition ??
      const <CharacterStatsTabDefinition>[];
  final nameMissing = character.characterName.trim().isEmpty;

  if (filterTabId != null) {
    final tab = tabs.where((t) => t.uuid == filterTabId).firstOrNull;
    if (tab == null) return const [];
    final stats = fillableStatsOfTab(tab, isCompanion: isCompanion);
    final showName = nameMissing || tab.isDefaultTab;
    if (stats.isEmpty && !showName) return const [];
    return [
      CharacterStatsFormPage(tab: tab, stats: stats, showNameField: showName),
    ];
  }

  final present = character.characterStats.map((s) => s.statUuid).toSet();
  final pages = <CharacterStatsFormPage>[];
  for (final tab in tabs) {
    final missing = fillableStatsOfTab(
      tab,
      isCompanion: isCompanion,
    ).where((s) => !present.contains(s.statUuid)).toList();
    if (missing.isEmpty) continue;
    pages.add(
      CharacterStatsFormPage(
        tab: tab,
        stats: missing,
        showNameField: nameMissing && pages.isEmpty,
      ),
    );
  }

  if (pages.isEmpty && nameMissing) {
    return const [
      CharacterStatsFormPage(tab: null, stats: [], showNameField: true),
    ];
  }
  return pages;
}
