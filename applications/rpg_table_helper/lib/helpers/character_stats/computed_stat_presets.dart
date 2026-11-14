import 'package:collection/collection.dart';
import 'package:quest_keeper/helpers/character_stats/computed_stat_editor.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/models/computed_stat_formula.dart';

/// Ready-made D&D 5e formulas that fill the builder.
enum ComputedStatPresetId {
  passivePerception,
  passiveInsight,
  passiveInvestigation,
  passiveStealth,
  initiative,
  unarmoredArmorClass,
}

/// Names (German and English, lower case, without the "(Wei)" suffix) a
/// preset looks for in the campaign.
class _Names {
  static const wisdom = ["weisheit", "wisdom", "wei", "wis"];
  static const dexterity = ["geschicklichkeit", "dexterity", "ges", "dex"];
  static const intelligence = ["intelligenz", "intelligence", "int"];
  static const proficiencyBonus = [
    "übungsbonus",
    "üb",
    "ub",
    "proficiency bonus",
    "proficiency",
    "pb",
  ];
  static const perception = ["wahrnehmung", "perception"];
  static const insight = ["motiv erkennen", "insight"];
  static const investigation = ["nachforschungen", "investigation"];
  static const stealth = ["heimlichkeit", "stealth"];
}

class _PresetDefinition {
  final int base;
  final List<String> ability;

  /// The skill whose proficiency adds the proficiency bonus, if any.
  final List<String>? skill;

  const _PresetDefinition({
    required this.base,
    required this.ability,
    this.skill,
  });
}

/// The result of filling a preset in for one campaign.
class ComputedStatPresetResult {
  final ComputedStatFormula formula;

  /// `false` when a value the preset needs is missing from the campaign;
  /// its building block is left out and the DM adds it by hand.
  final bool complete;

  const ComputedStatPresetResult({
    required this.formula,
    required this.complete,
  });
}

class ComputedStatPresets {
  static const _definitions = {
    ComputedStatPresetId.passivePerception: _PresetDefinition(
      base: 10,
      ability: _Names.wisdom,
      skill: _Names.perception,
    ),
    ComputedStatPresetId.passiveInsight: _PresetDefinition(
      base: 10,
      ability: _Names.wisdom,
      skill: _Names.insight,
    ),
    ComputedStatPresetId.passiveInvestigation: _PresetDefinition(
      base: 10,
      ability: _Names.intelligence,
      skill: _Names.investigation,
    ),
    ComputedStatPresetId.passiveStealth: _PresetDefinition(
      base: 10,
      ability: _Names.dexterity,
      skill: _Names.stealth,
    ),
    ComputedStatPresetId.initiative: _PresetDefinition(
      base: 0,
      ability: _Names.dexterity,
    ),
    ComputedStatPresetId.unarmoredArmorClass: _PresetDefinition(
      base: 10,
      ability: _Names.dexterity,
    ),
  };

  /// "Wahrnehmung (Wei)" -> "wahrnehmung".
  static String normalize(String label) =>
      label.replaceAll(RegExp(r"\([^)]*\)"), "").trim().toLowerCase();

  static bool _matches(String label, List<String> names) =>
      names.contains(normalize(label));

  /// [id] filled in with the matching values of [stats]. Building blocks
  /// whose value or condition the campaign does not have are left out
  /// (never counted wrongly), and the result says so.
  static ComputedStatPresetResult build(
    ComputedStatPresetId id,
    List<StatWithTab> stats, {
    String? excludeStatUuid,
  }) {
    var definition = _definitions[id]!;
    // Labels are only used for matching, not shown.
    const labels = StatNumberLabels(calculated: "", max: "", level: "");
    var sources = StatNumbers.options(
      stats,
      labels,
      includeMaxAndLevel: true,
      excludeStatUuid: excludeStatUuid,
    ).where((o) => o.ref.field == StatNumberField.value).toList();

    StatNumberRef? sourceNamed(List<String> names) =>
        sources.firstWhereOrNull((o) => _matches(o.label, names))?.ref;

    var terms = <ComputedStatTerm>[];
    var complete = true;

    var ability = sourceNamed(definition.ability);
    if (ability != null) {
      terms.add(
        ComputedStatTerm(source: ability, mode: ComputedTermMode.modifier),
      );
    } else {
      complete = false;
    }

    if (definition.skill != null) {
      var proficiency = sourceNamed(_Names.proficiencyBonus);
      var condition = computedConditionOptions(stats)
          .firstWhereOrNull((c) => _matches(c.optionLabel, definition.skill!))
          ?.condition;
      if (proficiency != null && condition != null) {
        terms.add(ComputedStatTerm(source: proficiency, condition: condition));
      } else {
        complete = false;
      }
    }

    return ComputedStatPresetResult(
      formula: ComputedStatFormula(base: definition.base, terms: terms),
      complete: complete,
    );
  }
}
