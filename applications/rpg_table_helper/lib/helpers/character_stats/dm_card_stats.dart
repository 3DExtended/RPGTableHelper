import 'package:collection/collection.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/models/dm_character_card_settings.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// A number the DM can put on a character card.
typedef DmCardStatOption = StatNumberOption;

/// What a card shows: an optional bar and a list of numbers.
class DmCardStatSelection {
  final String? barStatUuid;
  final List<StatNumberRef> numberStats;

  /// Used by the automatic mode only: tried when none of [numberStats]
  /// resolves for a character.
  final List<StatNumberRef> fallbackNumberStats;

  const DmCardStatSelection({
    required this.barStatUuid,
    required this.numberStats,
    this.fallbackNumberStats = const [],
  });
}

class DmCardStats {
  static List<CharacterStatDefinition> _allStats(
    RpgConfigurationModel config,
  ) => StatNumbers.allStats(config);

  static List<Map<String, dynamic>> _entriesOf(CharacterStatDefinition stat) =>
      StatNumbers.entriesOf(stat);

  static String _entryLabel(Map<String, dynamic> entry) =>
      StatNumbers.entryLabel(entry);

  /// Every stat with a maximum, in the order of the tabs: candidates for the
  /// bar.
  static List<CharacterStatDefinition> barOptions(
    RpgConfigurationModel config,
  ) =>
      _allStats(config)
          .where((s) => s.valueType == CharacterStatValueType.intWithMaxValue)
          .toList();

  /// Every number the campaign's stats hold (computed stats included), in
  /// the order of the tabs.
  static List<DmCardStatOption> numberOptions(
    RpgConfigurationModel config,
    StatNumberLabels labels,
  ) => StatNumbers.options(StatNumbers.statsWithTabs(config), labels);

  /// The automatic choice (what cards showed before the DM could pick):
  /// from the default tab, the first stat with a maximum as bar, the first 8
  /// plain numbers, and if a character has none of those, up to 6 entries of
  /// the first icon list sorted by label.
  static DmCardStatSelection automaticSelection(
    RpgConfigurationModel config, {
    required bool isAlternateForm,
    required bool isCompanion,
  }) {
    var defaultTab = config.characterStatTabsDefinition?.firstWhereOrNull(
      (e) => e.isDefaultTab,
    );
    if (defaultTab == null) {
      return const DmCardStatSelection(barStatUuid: null, numberStats: []);
    }
    var stats = defaultTab.statsInTab
        .where((e) => !isAlternateForm || e.isOptionalForAlternateForms != true)
        .where(
          (e) => !isCompanion || e.isOptionalForCompanionCharacters != true,
        )
        .toList();

    var bar = stats.firstWhereOrNull(
      (e) => e.valueType == CharacterStatValueType.intWithMaxValue,
    );
    var ints = stats
        .where((e) => e.valueType == CharacterStatValueType.int)
        .take(DmCharacterCardSettings.maxNumberStats)
        .map((e) => StatNumberRef(statUuid: e.statUuid))
        .toList();
    var iconList = stats.firstWhereOrNull(
      (e) => e.valueType == CharacterStatValueType.listOfIntsWithIcons,
    );
    var fallback = iconList == null
        ? <StatNumberRef>[]
        : _entriesOf(iconList)
              .where((e) => e["uuid"] != null)
              .sortedBy(_entryLabel)
              .take(6)
              .map(
                (e) => StatNumberRef(
                  statUuid: iconList.statUuid,
                  entryUuid: e["uuid"].toString(),
                ),
              )
              .toList();

    return DmCardStatSelection(
      barStatUuid: bar?.statUuid,
      numberStats: ints,
      fallbackNumberStats: fallback,
    );
  }

  /// What a card shows for this character with the DM's [settings].
  static DmCardStatSelection selectionFor(
    RpgConfigurationModel config,
    DmCharacterCardSettings settings, {
    required bool isAlternateForm,
    required bool isCompanion,
  }) {
    if (!settings.useCustomStats) {
      return automaticSelection(
        config,
        isAlternateForm: isAlternateForm,
        isCompanion: isCompanion,
      );
    }
    return DmCardStatSelection(
      barStatUuid: settings.barStatUuid,
      numberStats: settings.numberStats
          .take(DmCharacterCardSettings.maxNumberStats)
          .toList(),
    );
  }

  /// Label for [ref] on a card, or `null` when the campaign no longer has
  /// that stat or entry.
  static String? labelFor(
    RpgConfigurationModel config,
    StatNumberRef ref,
    StatNumberLabels labels,
  ) => StatNumbers.labelFor(_allStats(config), ref, labels);

  /// The number [ref] points at for [character] (computed stats evaluated),
  /// or `null` when the character has no value for that stat (then the card
  /// leaves it out).
  static int? resolve(
    RpgConfigurationModel config,
    StatNumberRef ref,
    RpgCharacterConfigurationBase character,
  ) => StatNumbers.resolve(_allStats(config), ref, character);

  /// The numbers to print on the card of [character].
  static List<({String label, int value})> numbersFor(
    RpgConfigurationModel config,
    DmCardStatSelection selection,
    RpgCharacterConfigurationBase character,
    StatNumberLabels labels,
  ) {
    List<({String label, int value})> resolveAll(List<StatNumberRef> refs) {
      var result = <({String label, int value})>[];
      for (var ref in refs) {
        var label = labelFor(config, ref, labels);
        var value = resolve(config, ref, character);
        if (label == null || value == null) continue;
        result.add((label: label, value: value));
      }
      return result;
    }

    var numbers = resolveAll(selection.numberStats);
    if (numbers.isEmpty && selection.fallbackNumberStats.isNotEmpty) {
      numbers = resolveAll(selection.fallbackNumberStats);
    }
    return numbers;
  }

  /// The bar stat with this character's value, or `null`.
  static (CharacterStatDefinition, RpgCharacterStatValue)? barFor(
    RpgConfigurationModel config,
    DmCardStatSelection selection,
    RpgCharacterConfigurationBase character,
  ) {
    if (selection.barStatUuid == null) return null;
    var stat = _allStats(config).firstWhereOrNull(
      (s) =>
          s.statUuid == selection.barStatUuid &&
          s.valueType == CharacterStatValueType.intWithMaxValue,
    );
    if (stat == null) return null;
    var value = character.characterStats.firstWhereOrNull(
      (cs) => cs.statUuid == stat.statUuid,
    );
    if (value == null) return null;
    return (stat, value);
  }
}
