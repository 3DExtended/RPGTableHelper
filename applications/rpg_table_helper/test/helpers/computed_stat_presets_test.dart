import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_stats/computed_stat_presets.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/models/computed_stat_formula.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

import 'stat_numbers_test.dart' as h;

const intelligence = "0f6557a8-c3b6-4832-a673-a8903f87ff24";
const insight = "a3040091-cf15-4e63-87b7-3c449a9b3dd4";
const investigation = "d6833b01-0f6e-4bc3-9590-60a6bc3cdc01";

void main() {
  final stats = StatNumbers.statsWithTabs(
    RpgConfigurationModel.getBaseConfiguration(),
  );

  test('passive Perception finds Wisdom, ÜB and the Perception skill', () {
    var result = ComputedStatPresets.build(
      ComputedStatPresetId.passivePerception,
      stats,
    );

    expect(result.complete, isTrue);
    expect(result.formula, h.passivePerception);
  });

  test('passive Insight and Investigation use their own skill and ability', () {
    var insightResult = ComputedStatPresets.build(
      ComputedStatPresetId.passiveInsight,
      stats,
    );
    var investigationResult = ComputedStatPresets.build(
      ComputedStatPresetId.passiveInvestigation,
      stats,
    );

    expect(insightResult.formula.terms[1].condition!.optionUuid, insight);
    expect(investigationResult.formula.terms[0].source.entryUuid, intelligence);
    expect(
      investigationResult.formula.terms[1].condition!.optionUuid,
      investigation,
    );
  });

  test('a missing skill leaves the proficiency block out instead of always '
      'counting it', () {
    // The base campaign has no Stealth skill.
    var result = ComputedStatPresets.build(
      ComputedStatPresetId.passiveStealth,
      stats,
    );

    expect(result.complete, isFalse);
    expect(
      result.formula,
      const ComputedStatFormula(
        base: 10,
        terms: [
          ComputedStatTerm(
            source: StatNumberRef(
              statUuid: h.skillsUuid,
              entryUuid: h.dexterity,
            ),
            mode: ComputedTermMode.modifier,
          ),
        ],
      ),
    );
  });

  test('initiative and unarmored AC are built on Dexterity', () {
    var initiative = ComputedStatPresets.build(
      ComputedStatPresetId.initiative,
      stats,
    );
    var ac = ComputedStatPresets.build(
      ComputedStatPresetId.unarmoredArmorClass,
      stats,
    );

    expect(initiative.formula.base, 0);
    expect(ac.formula.base, 10);
    for (var result in [initiative, ac]) {
      expect(result.complete, isTrue);
      expect(result.formula.terms.single.source.entryUuid, h.dexterity);
    }
  });

  test(
    'a campaign without matching values gets an empty, incomplete formula',
    () {
      var result = ComputedStatPresets.build(
        ComputedStatPresetId.passivePerception,
        [],
      );

      expect(result.complete, isFalse);
      expect(result.formula, const ComputedStatFormula(base: 10));
    },
  );

  test('English names match too', () {
    expect(ComputedStatPresets.normalize("Perception (Wis)"), "perception");
    expect(ComputedStatPresets.normalize("  Wisdom "), "wisdom");
  });
}
