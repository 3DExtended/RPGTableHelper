import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:quest_keeper/models/computed_stat_formula.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// A number of a stat that can be picked (for a card, or as a building
/// block of a computed stat).
class StatNumberOption {
  final StatNumberRef ref;

  /// The stat it belongs to (heading in a picker).
  final String groupLabel;

  /// Short label, e.g. "AC", "Weisheit (ber.)", "HP (Max.)".
  final String label;

  const StatNumberOption({
    required this.ref,
    required this.groupLabel,
    required this.label,
  });
}

/// Localized suffixes for [StatNumbers] labels.
class StatNumberLabels {
  /// Marks the second ("calculated") number, e.g. "ber.".
  final String calculated;

  /// Marks the maximum, e.g. "Max.".
  final String max;

  /// The level of the character summary, e.g. "Stufe".
  final String level;

  const StatNumberLabels({
    required this.calculated,
    required this.max,
    required this.level,
  });
}

typedef StatWithTab = ({String tabName, CharacterStatDefinition stat});

/// Reads numbers out of character stats, including computed stats.
class StatNumbers {
  /// Deepest chain of computed stats referring to computed stats.
  static const maxDepth = 16;

  static List<CharacterStatDefinition> allStats(RpgConfigurationModel config) =>
      (config.characterStatTabsDefinition ?? [])
          .expand((tab) => tab.statsInTab)
          .toList();

  static List<StatWithTab> statsWithTabs(RpgConfigurationModel config) =>
      (config.characterStatTabsDefinition ?? [])
          .expand(
            (tab) => tab.statsInTab.map(
              (stat) => (tabName: tab.tabName, stat: stat),
            ),
          )
          .toList();

  static List<Map<String, dynamic>> entriesOf(CharacterStatDefinition stat) {
    try {
      var data = jsonDecode(stat.jsonSerializedAdditionalData ?? "{}");
      var values = (data as Map<String, dynamic>)["values"];
      if (values is! List) return [];
      return values.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }

  static String entryLabel(Map<String, dynamic> entry) =>
      entry["label"]?.toString() ?? "";

  /// Every number [stats] hold, in their order.
  ///
  /// [includeMaxAndLevel] adds the maximum of values with a maximum and the
  /// level of the character summary (useful as building blocks, not shown on
  /// cards). [excludeStatUuid] leaves one stat out (a computed stat cannot
  /// be built from itself).
  static List<StatNumberOption> options(
    List<StatWithTab> stats,
    StatNumberLabels labels, {
    bool includeMaxAndLevel = false,
    String? excludeStatUuid,
  }) {
    var result = <StatNumberOption>[];
    void add(StatNumberRef ref, String group, String label) =>
        result.add(StatNumberOption(ref: ref, groupLabel: group, label: label));

    for (var (:tabName, :stat) in stats) {
      if (stat.statUuid == excludeStatUuid) continue;
      // Icon lists often have no name of their own; use the tab's then.
      var group = stat.name.trim().isEmpty ? tabName : stat.name;
      switch (stat.valueType) {
        case CharacterStatValueType.int:
          add(StatNumberRef(statUuid: stat.statUuid), group, stat.name);
          break;
        case CharacterStatValueType.intWithMaxValue:
          if (!includeMaxAndLevel) break;
          add(StatNumberRef(statUuid: stat.statUuid), group, stat.name);
          add(
            StatNumberRef(
              statUuid: stat.statUuid,
              field: StatNumberField.maxValue,
            ),
            group,
            "${stat.name} (${labels.max})",
          );
          break;
        case CharacterStatValueType.intWithCalculatedValue:
          add(StatNumberRef(statUuid: stat.statUuid), group, stat.name);
          add(
            StatNumberRef(
              statUuid: stat.statUuid,
              field: StatNumberField.otherValue,
            ),
            group,
            "${stat.name} (${labels.calculated})",
          );
          break;
        case CharacterStatValueType.listOfIntWithCalculatedValues:
          for (var entry in entriesOf(stat)) {
            var uuid = entry["uuid"]?.toString();
            if (uuid == null) continue;
            add(
              StatNumberRef(statUuid: stat.statUuid, entryUuid: uuid),
              group,
              entryLabel(entry),
            );
            add(
              StatNumberRef(
                statUuid: stat.statUuid,
                entryUuid: uuid,
                field: StatNumberField.otherValue,
              ),
              group,
              "${entryLabel(entry)} (${labels.calculated})",
            );
          }
          break;
        case CharacterStatValueType.listOfIntsWithIcons:
          for (var entry in entriesOf(stat)) {
            var uuid = entry["uuid"]?.toString();
            if (uuid == null) continue;
            add(
              StatNumberRef(statUuid: stat.statUuid, entryUuid: uuid),
              group,
              entryLabel(entry),
            );
          }
          break;
        case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
          if (!includeMaxAndLevel) break;
          add(
            StatNumberRef(
              statUuid: stat.statUuid,
              field: StatNumberField.level,
            ),
            group,
            labels.level,
          );
          break;
        default:
          break;
      }
    }
    return result;
  }

  /// Label for [ref], or `null` when [stats] no longer have that stat or
  /// entry.
  static String? labelFor(
    List<CharacterStatDefinition> stats,
    StatNumberRef ref,
    StatNumberLabels labels,
  ) {
    var stat = stats.firstWhereOrNull((s) => s.statUuid == ref.statUuid);
    if (stat == null) return null;
    var label = stat.name;
    if (ref.entryUuid != null) {
      var entry = entriesOf(stat)
          .firstWhereOrNull((e) => e["uuid"]?.toString() == ref.entryUuid);
      if (entry == null) return null;
      label = entryLabel(entry);
    }
    return switch (ref.field) {
      StatNumberField.value => label,
      StatNumberField.otherValue => "$label (${labels.calculated})",
      StatNumberField.maxValue => "$label (${labels.max})",
      StatNumberField.level => labels.level,
    };
  }

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? "") ?? 0;

  /// The number [ref] points at for [character], or `null` when the
  /// character has no value for that stat. A computed stat is evaluated
  /// from the character's other values, whatever is stored for it.
  static int? resolve(
    List<CharacterStatDefinition> stats,
    StatNumberRef ref,
    RpgCharacterConfigurationBase character, {
    Set<String> visiting = const {},
  }) {
    var stat = stats.firstWhereOrNull((s) => s.statUuid == ref.statUuid);
    var formula = stat == null ? null : ComputedStatFormula.of(stat);
    if (formula != null) {
      return evaluate(
        stats,
        stat!.statUuid,
        formula,
        character,
        visiting: visiting,
      );
    }

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
      StatNumberField.value => _toInt(source["value"]),
      // "calculatedValue" is the legacy key of the second number.
      StatNumberField.otherValue => _toInt(
        source["otherValue"] ?? source["calculatedValue"],
      ),
      StatNumberField.maxValue => _toInt(source["maxValue"]),
      StatNumberField.level => _toInt(source["level"]),
    };
  }

  /// How often [character] picked [condition]'s option (0 = not picked).
  static int conditionCount(
    ComputedTermCondition condition,
    RpgCharacterConfigurationBase character,
  ) {
    var statValue = character.characterStats.firstWhereOrNull(
      (cs) => cs.statUuid == condition.statUuid,
    );
    if (statValue == null) return 0;
    try {
      var values = (jsonDecode(
        statValue.serializedValue,
      ) as Map<String, dynamic>)["values"];
      if (values is! List) return 0;
      return values.where((v) => v?.toString() == condition.optionUuid).length;
    } catch (_) {
      return 0;
    }
  }

  static int applyMode(ComputedTermMode mode, int value) => switch (mode) {
    ComputedTermMode.value => value,
    ComputedTermMode.modifier => ((value - 10) / 2).floor(),
  };

  /// `base + Σ factor × mode(source)` for [character]. Values the character
  /// does not have add nothing; a computed stat that (indirectly) refers to itself counts its
  /// self-reference as 0.
  static int evaluate(
    List<CharacterStatDefinition> stats,
    String statUuid,
    ComputedStatFormula formula,
    RpgCharacterConfigurationBase character, {
    Set<String> visiting = const {},
  }) {
    if (visiting.contains(statUuid) || visiting.length >= maxDepth) return 0;
    var nextVisiting = {...visiting, statUuid};

    var total = formula.base;
    for (var term in formula.terms) {
      var times = 1;
      if (term.condition != null) {
        times = conditionCount(term.condition!, character);
        if (times == 0) continue;
      }
      var source = resolve(
        stats,
        term.source,
        character,
        visiting: nextVisiting,
      );
      // A value the character does not have adds nothing (not Mod(0) = −5).
      if (source == null) continue;
      total += times * term.factor * applyMode(term.mode, source);
    }
    return total;
  }

  /// [stats] with every computed stat's stored value set to its current
  /// result, so app versions without computed stats, the API and the MCP
  /// server see a current number. Adds missing entries for computed stats
  /// unless they are optional for this kind of character.
  static List<RpgCharacterStatValue> withComputedValues(
    RpgConfigurationModel config,
    RpgCharacterConfigurationBase character, {
    bool isCompanion = false,
    bool isAlternateForm = false,
  }) {
    var stats = allStats(config);
    var computed = stats
        .map((s) => (stat: s, formula: ComputedStatFormula.of(s)))
        .where((e) => e.formula != null)
        .toList();
    if (computed.isEmpty) return character.characterStats;

    var result = [...character.characterStats];
    for (var (:stat, :formula) in computed) {
      var index = result.indexWhere((cs) => cs.statUuid == stat.statUuid);
      if (index == -1 &&
          ((isCompanion && stat.isOptionalForCompanionCharacters == true) ||
              (isAlternateForm && stat.isOptionalForAlternateForms == true))) {
        continue;
      }
      var serialized = jsonEncode({
        "value": evaluate(stats, stat.statUuid, formula!, character),
      });
      if (index == -1) {
        result.add(
          RpgCharacterStatValue(
            statUuid: stat.statUuid,
            serializedValue: serialized,
            hideFromCharacterScreen: false,
            variant: null,
            hideLabelOfStat: false,
          ),
        );
      } else if (result[index].serializedValue != serialized) {
        result[index] = result[index].copyWith(serializedValue: serialized);
      }
    }
    return result;
  }

  /// [character] with the computed stats of itself, its active alternate
  /// form and its companions brought up to date (see [withComputedValues]).
  static RpgCharacterConfiguration applyComputedValues(
    RpgConfigurationModel config,
    RpgCharacterConfiguration character,
  ) {
    if (!allStats(config).any((s) => ComputedStatFormula.of(s) != null)) {
      return character;
    }
    return character.copyWith(
      characterStats: withComputedValues(config, character),
      alternateForm: character.alternateForm?.copyWith(
        characterStats: withComputedValues(
          config,
          character.alternateForm!,
          isAlternateForm: true,
        ),
      ),
      companionCharacters: character.companionCharacters
          ?.map(
            (c) => c.copyWith(
              characterStats: withComputedValues(config, c, isCompanion: true),
            ),
          )
          .toList(),
    );
  }

  /// Whether [stat] is computed (players never type it in).
  static bool isComputed(CharacterStatDefinition stat) =>
      ComputedStatFormula.of(stat) != null;
}
