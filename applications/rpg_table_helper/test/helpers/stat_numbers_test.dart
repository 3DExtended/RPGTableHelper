import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_stats/dm_card_stats.dart';
import 'package:quest_keeper/helpers/character_stats/has_missing_required_campaign_stats.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/helpers/initiative_bonus_resolver.dart';
import 'package:quest_keeper/models/computed_stat_formula.dart';
import 'package:quest_keeper/models/dm_character_card_settings.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

const skillsUuid = "44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3";
const wisdom = "167b94e6-d674-43a4-a25b-fca1309a12b0";
const dexterity = "a7aa4151-8c7c-41d4-91d2-2ff0a3d084a4";
const iconListUuid = "01933514-7eef-7523-a4cc-974802dc96e7";
const proficiencyEntry = "01933512-9cb6-7466-9977-0768e0dda2a7"; // "ÜB"
const proficienciesUuid = "c5ef782a-8d8b-4a88-98b2-be277f741e4c";
const perception = "827f2550-9683-45cf-b8fb-cad229c47fe8";
const passivePerceptionUuid = "passive-perception";

const labels = StatNumberLabels(
  calculated: "calc.",
  max: "max.",
  level: "Level",
);

/// Passive Perception = 10 + Mod(Wisdom) + proficiency bonus (if trained).
const passivePerception = ComputedStatFormula(
  base: 10,
  terms: [
    ComputedStatTerm(
      source: StatNumberRef(statUuid: skillsUuid, entryUuid: wisdom),
      mode: ComputedTermMode.modifier,
    ),
    ComputedStatTerm(
      source: StatNumberRef(
        statUuid: iconListUuid,
        entryUuid: proficiencyEntry,
      ),
      condition: ComputedTermCondition(
        statUuid: proficienciesUuid,
        optionUuid: perception,
      ),
    ),
  ],
);

CharacterStatDefinition computedStat(
  String uuid,
  String name,
  ComputedStatFormula formula, {
  bool optionalForCompanions = false,
}) => CharacterStatDefinition(
  statUuid: uuid,
  name: name,
  groupId: null,
  helperText: "",
  valueType: CharacterStatValueType.int,
  editType: CharacterStatEditType.static,
  isOptionalForAlternateForms: false,
  isOptionalForCompanionCharacters: optionalForCompanions,
  jsonSerializedAdditionalData: formula.toAdditionalData(),
);

RpgConfigurationModel withStats(List<CharacterStatDefinition> extra) {
  var config = RpgConfigurationModel.getBaseConfiguration();
  return config.copyWith(
    characterStatTabsDefinition: config.characterStatTabsDefinition!
        .map(
          (t) => t.isDefaultTab
              ? CharacterStatsTabDefinition(
                  uuid: t.uuid,
                  tabName: t.tabName,
                  isOptional: t.isOptional,
                  isDefaultTab: true,
                  statsInTab: [...t.statsInTab, ...extra],
                )
              : t,
        )
        .toList(),
  );
}

RpgCharacterStatValue value(String statUuid, Object json) =>
    RpgCharacterStatValue(
      statUuid: statUuid,
      serializedValue: jsonEncode(json),
      hideFromCharacterScreen: false,
      variant: null,
      hideLabelOfStat: false,
    );

RpgCharacterConfiguration character({
  int wis = 14,
  int proficiency = 3,
  List<String> trained = const [],
}) {
  return RpgCharacterConfiguration.getBaseConfiguration(
    RpgConfigurationModel.getBaseConfiguration(),
  ).copyWith(
    uuid: "kardan",
    characterStats: [
      value(skillsUuid, {
        "values": [
          {"uuid": wisdom, "value": wis, "otherValue": 0},
          {"uuid": dexterity, "value": 15, "otherValue": 2},
        ],
      }),
      value(iconListUuid, {
        "values": [
          {"uuid": proficiencyEntry, "value": proficiency},
        ],
      }),
      value(proficienciesUuid, {"values": trained}),
    ],
  );
}

void main() {
  group('ComputedStatFormula', () {
    test('round-trips through the stat definition', () {
      var stat = computedStat(
        passivePerceptionUuid,
        "Passive Wahrnehmung",
        passivePerception,
      );

      expect(ComputedStatFormula.of(stat), passivePerception);
      // Old app versions read a plain int stat: the definition still parses.
      var reparsed = CharacterStatDefinition.fromJson(
        jsonDecode(jsonEncode(stat.toJson())) as Map<String, dynamic>,
      );
      expect(reparsed.valueType, CharacterStatValueType.int);
      expect(ComputedStatFormula.of(reparsed), passivePerception);
    });

    test('only int stats with a formula are computed', () {
      var plain = computedStat(
        "x",
        "x",
        passivePerception,
      ).copyWith(jsonSerializedAdditionalData: null);
      var otherType = computedStat(
        "y",
        "y",
        passivePerception,
      ).copyWith(valueType: CharacterStatValueType.intWithMaxValue);

      expect(StatNumbers.isComputed(plain), isFalse);
      expect(StatNumbers.isComputed(otherType), isFalse);
    });
  });

  group('evaluate', () {
    final config = withStats([
      computedStat(
        passivePerceptionUuid,
        "Passive Wahrnehmung",
        passivePerception,
      ),
    ]);
    final stats = StatNumbers.allStats(config);
    int passive(RpgCharacterConfigurationBase c) => StatNumbers.resolve(
      stats,
      const StatNumberRef(statUuid: passivePerceptionUuid),
      c,
    )!;

    test('10 + Mod(WIS 14) without training', () {
      expect(passive(character(wis: 14)), 12);
    });

    test('adds the proficiency bonus when trained in Perception', () {
      expect(passive(character(wis: 14, trained: [perception])), 15);
    });

    test('a pick allowed twice counts twice (expertise)', () {
      expect(
        passive(character(wis: 14, trained: [perception, perception])),
        18,
      );
    });

    test('the modifier rounds down for odd and low scores', () {
      expect(passive(character(wis: 9)), 9);
      expect(passive(character(wis: 1)), 5);
    });

    test('a value the character does not have adds nothing', () {
      var empty = character().copyWith(characterStats: []);
      expect(passive(empty), 10);
    });

    test('computed stats can build on computed stats, cycles count as 0', () {
      var a = computedStat(
        "a",
        "A",
        const ComputedStatFormula(
          base: 1,
          terms: [
            ComputedStatTerm(source: StatNumberRef(statUuid: "b"), factor: 2),
          ],
        ),
      );
      var b = computedStat(
        "b",
        "B",
        const ComputedStatFormula(
          base: 5,
          terms: [ComputedStatTerm(source: StatNumberRef(statUuid: "a"))],
        ),
      );
      var defs = [a, b];

      // b = 5 + a, a = 1 + 2 × b, b inside a's evaluation is 5 + (a → 0)
      expect(
        StatNumbers.resolve(
          defs,
          const StatNumberRef(statUuid: "a"),
          character(),
        ),
        11,
      );
    });
  });

  group('stored values', () {
    final config = withStats([
      computedStat(
        passivePerceptionUuid,
        "Passive Wahrnehmung",
        passivePerception,
        optionalForCompanions: true,
      ),
    ]);

    test('withComputedValues adds and updates the computed value', () {
      var c = character(wis: 16, trained: [perception]);
      var stats = StatNumbers.withComputedValues(config, c);
      var stored = stats.singleWhere(
        (s) => s.statUuid == passivePerceptionUuid,
      );
      expect(jsonDecode(stored.serializedValue), {"value": 16});

      var stale = c.copyWith(
        characterStats: [
          ...c.characterStats,
          value(passivePerceptionUuid, {"value": 99}),
        ],
      );
      var updated = StatNumbers.withComputedValues(
        config,
        stale,
      ).singleWhere((s) => s.statUuid == passivePerceptionUuid);
      expect(jsonDecode(updated.serializedValue), {"value": 16});
    });

    test('applyComputedValues skips companions the stat is optional for', () {
      var applied = StatNumbers.applyComputedValues(config, character());

      expect(
        applied.characterStats.any((s) => s.statUuid == passivePerceptionUuid),
        isTrue,
      );
      expect(
        applied.companionCharacters!.single.characterStats.any(
          (s) => s.statUuid == passivePerceptionUuid,
        ),
        isFalse,
      );
    });

    test('a campaign without computed stats leaves the character as it is', () {
      var c = character();
      expect(
        identical(
          StatNumbers.applyComputedValues(
            RpgConfigurationModel.getBaseConfiguration(),
            c,
          ),
          c,
        ),
        isTrue,
      );
    });
  });

  test('a computed stat is never missing', () {
    var config = withStats([
      computedStat(
        passivePerceptionUuid,
        "Passive Wahrnehmung",
        passivePerception,
      ),
    ]);
    // Has a value for every stat except the computed one.
    var full = character().copyWith(
      characterStats: [
        for (var stat in StatNumbers.allStats(config))
          if (!StatNumbers.isComputed(stat)) value(stat.statUuid, {}),
      ],
    );

    expect(
      hasMissingRequiredCampaignStats(rpgConfig: config, character: full),
      isFalse,
    );
  });

  test('the DM card shows the computed value', () {
    var config = withStats([
      computedStat(
        passivePerceptionUuid,
        "Passive Wahrnehmung",
        passivePerception,
      ),
    ]);
    var settings = DmCharacterCardSettings(
      useCustomStats: true,
      numberStats: [const StatNumberRef(statUuid: passivePerceptionUuid)],
    );
    var selection = DmCardStats.selectionFor(
      config,
      settings,
      isAlternateForm: false,
      isCompanion: false,
    );

    expect(
      DmCardStats.numbersFor(
        config,
        selection,
        character(wis: 14, trained: [perception]),
        labels,
      ),
      [(label: "Passive Wahrnehmung", value: 15)],
    );
  });

  test('a computed initiative bonus is evaluated', () {
    var initiative = computedStat(
      "initiative",
      "Initiative",
      const ComputedStatFormula(
        terms: [
          ComputedStatTerm(
            source: StatNumberRef(statUuid: skillsUuid, entryUuid: dexterity),
            mode: ComputedTermMode.modifier,
          ),
        ],
      ),
    );
    var config = withStats([initiative])
        .copyWith(initiativeBonusStatUuid: "initiative");

    expect(
      resolveInitiativeBonus(rpgConfig: config, character: character())?.bonus,
      2,
    );
  });

  test('building-block options include maximum and level', () {
    var options = StatNumbers.options(
      StatNumbers.statsWithTabs(RpgConfigurationModel.getBaseConfiguration()),
      labels,
      includeMaxAndLevel: true,
    );
    var labelsOnly = options.map((o) => o.label);

    expect(labelsOnly, containsAll(["TP (max.)", "Level", "Weisheit"]));
  });
}
