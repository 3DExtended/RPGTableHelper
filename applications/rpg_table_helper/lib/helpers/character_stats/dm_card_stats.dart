import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:quest_keeper/models/dm_character_card_settings.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// A number the DM can put on a character card.
class DmCardStatOption {
  final DmCardStatRef ref;

  /// The stat it belongs to (heading in the picker).
  final String groupLabel;

  /// Short label as shown on the card.
  final String label;

  const DmCardStatOption({
    required this.ref,
    required this.groupLabel,
    required this.label,
  });
}

/// What a card shows: an optional bar and a list of numbers.
class DmCardStatSelection {
  final String? barStatUuid;
  final List<DmCardStatRef> numberStats;

  /// Used by the automatic mode only: tried when none of [numberStats]
  /// resolves for a character.
  final List<DmCardStatRef> fallbackNumberStats;

  const DmCardStatSelection({
    required this.barStatUuid,
    required this.numberStats,
    this.fallbackNumberStats = const [],
  });
}

class DmCardStats {
  static List<CharacterStatDefinition> _allStats(
    RpgConfigurationModel config,
  ) => (config.characterStatTabsDefinition ?? [])
      .expand((tab) => tab.statsInTab)
      .toList();

  static List<Map<String, dynamic>> _entriesOf(CharacterStatDefinition stat) {
    try {
      var data = jsonDecode(stat.jsonSerializedAdditionalData ?? "{}");
      var values = (data as Map<String, dynamic>)["values"];
      if (values is! List) return [];
      return values.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }

  static String _entryLabel(Map<String, dynamic> entry) =>
      entry["label"]?.toString() ?? "";

  /// Every stat with a maximum, in the order of the tabs: candidates for the
  /// bar.
  static List<CharacterStatDefinition> barOptions(
    RpgConfigurationModel config,
  ) =>
      _allStats(config)
          .where((s) => s.valueType == CharacterStatValueType.intWithMaxValue)
          .toList();

  /// Every number the campaign's stats hold, in the order of the tabs.
  /// [calculatedSuffix] marks the second ("calculated") number, e.g. "calc.".
  static List<DmCardStatOption> numberOptions(
    RpgConfigurationModel config,
    String calculatedSuffix,
  ) {
    var result = <DmCardStatOption>[];
    var statsWithTab = (config.characterStatTabsDefinition ?? []).expand(
      (tab) => tab.statsInTab.map((stat) => (tab: tab, stat: stat)),
    );
    for (var (:tab, :stat) in statsWithTab) {
      // Icon lists often have no name of their own; use the tab's then.
      var groupLabel = stat.name.trim().isEmpty ? tab.tabName : stat.name;
      switch (stat.valueType) {
        case CharacterStatValueType.int:
          result.add(
            DmCardStatOption(
              ref: DmCardStatRef(statUuid: stat.statUuid),
              groupLabel: groupLabel,
              label: stat.name,
            ),
          );
          break;
        case CharacterStatValueType.intWithCalculatedValue:
          result.add(
            DmCardStatOption(
              ref: DmCardStatRef(statUuid: stat.statUuid),
              groupLabel: groupLabel,
              label: stat.name,
            ),
          );
          result.add(
            DmCardStatOption(
              ref: DmCardStatRef(
                statUuid: stat.statUuid,
                field: DmCardStatField.otherValue,
              ),
              groupLabel: groupLabel,
              label: "${stat.name} ($calculatedSuffix)",
            ),
          );
          break;
        case CharacterStatValueType.listOfIntWithCalculatedValues:
          for (var entry in _entriesOf(stat)) {
            var uuid = entry["uuid"]?.toString();
            if (uuid == null) continue;
            result.add(
              DmCardStatOption(
                ref: DmCardStatRef(statUuid: stat.statUuid, entryUuid: uuid),
                groupLabel: groupLabel,
                label: _entryLabel(entry),
              ),
            );
            result.add(
              DmCardStatOption(
                ref: DmCardStatRef(
                  statUuid: stat.statUuid,
                  entryUuid: uuid,
                  field: DmCardStatField.otherValue,
                ),
                groupLabel: groupLabel,
                label: "${_entryLabel(entry)} ($calculatedSuffix)",
              ),
            );
          }
          break;
        case CharacterStatValueType.listOfIntsWithIcons:
          for (var entry in _entriesOf(stat)) {
            var uuid = entry["uuid"]?.toString();
            if (uuid == null) continue;
            result.add(
              DmCardStatOption(
                ref: DmCardStatRef(statUuid: stat.statUuid, entryUuid: uuid),
                groupLabel: groupLabel,
                label: _entryLabel(entry),
              ),
            );
          }
          break;
        default:
          break;
      }
    }
    return result;
  }

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
        .map((e) => DmCardStatRef(statUuid: e.statUuid))
        .toList();
    var iconList = stats.firstWhereOrNull(
      (e) => e.valueType == CharacterStatValueType.listOfIntsWithIcons,
    );
    var fallback = iconList == null
        ? <DmCardStatRef>[]
        : _entriesOf(iconList)
              .where((e) => e["uuid"] != null)
              .sortedBy(_entryLabel)
              .take(6)
              .map(
                (e) => DmCardStatRef(
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
    DmCardStatRef ref,
    String calculatedSuffix,
  ) {
    var stat = _allStats(config)
        .firstWhereOrNull((s) => s.statUuid == ref.statUuid);
    if (stat == null) return null;
    var label = stat.name;
    if (ref.entryUuid != null) {
      var entry = _entriesOf(stat)
          .firstWhereOrNull((e) => e["uuid"]?.toString() == ref.entryUuid);
      if (entry == null) return null;
      label = _entryLabel(entry);
    }
    return ref.field == DmCardStatField.otherValue
        ? "$label ($calculatedSuffix)"
        : label;
  }

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? "") ?? 0;

  /// The number [ref] points at for [character], or `null` when the character
  /// has no value for that stat (then the card leaves it out).
  static int? resolve(
    DmCardStatRef ref,
    RpgCharacterConfigurationBase character,
  ) {
    var statValue = character.characterStats.firstWhereOrNull(
      (cs) => cs.statUuid == ref.statUuid,
    );
    if (statValue == null) return null;

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(statValue.serializedValue) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }

    var source = parsed;
    if (ref.entryUuid != null) {
      var values = parsed["values"];
      if (values is! List) return null;
      var entry = values.whereType<Map<String, dynamic>>().firstWhereOrNull(
        (e) => e["uuid"]?.toString() == ref.entryUuid,
      );
      // The stat exists but this entry was never filled in: count it as 0.
      if (entry == null) return 0;
      source = entry;
    }

    return switch (ref.field) {
      DmCardStatField.value => _toInt(source["value"]),
      // "calculatedValue" is the legacy key of the second number.
      DmCardStatField.otherValue => _toInt(
        source["otherValue"] ?? source["calculatedValue"],
      ),
    };
  }

  /// The numbers to print on the card of [character].
  static List<({String label, int value})> numbersFor(
    RpgConfigurationModel config,
    DmCardStatSelection selection,
    RpgCharacterConfigurationBase character,
    String calculatedSuffix,
  ) {
    List<({String label, int value})> resolveAll(List<DmCardStatRef> refs) {
      var result = <({String label, int value})>[];
      for (var ref in refs) {
        var label = labelFor(config, ref, calculatedSuffix);
        var value = resolve(ref, character);
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
