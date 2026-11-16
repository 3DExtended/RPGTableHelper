import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_stats/dm_card_stats.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/helpers/initiative_bonus_resolver.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';

const _labels = StatNumberLabels(calculated: "ber.", max: "Max.", level: "LVL");

CharacterStatDefinition _statNamed(RpgConfigurationModel config, String name) =>
    StatNumbers.allStats(config).singleWhere((s) => s.name == name);

void main() {
  group('every template', () {
    for (final id in RpgConfigurationTemplates.ids) {
      final config = RpgConfigurationTemplates.build(id);

      test('$id survives a JSON round trip unchanged', () {
        final json = jsonEncode(config);
        final reloaded = RpgConfigurationModel.fromJson(jsonDecode(json));
        expect(jsonEncode(reloaded), json);
        expect(
          RpgConfigurationTemplates.matchingTemplateOf(reloaded),
          id,
          reason: 'a campaign loaded from the server still matches',
        );
      });

      test('$id has what the app needs', () {
        final tabs = config.characterStatTabsDefinition!;
        expect(tabs.where((t) => t.isDefaultTab), hasLength(1));
        expect(config.currencyDefinition.currencyTypes, isNotEmpty);
        expect(
          config.currencyDefinition.currencyTypes.first.multipleOfPreviousValue,
          isNull,
        );
        final uuids = StatNumbers.allStats(config).map((s) => s.statUuid);
        expect(uuids.toSet(), hasLength(uuids.length));
        expect(tabs.map((t) => t.uuid).toSet(), hasLength(tabs.length));
        // The fallback character of a campaign is built from its default
        // tab; that must not throw for any stat type of a template.
        final character = RpgCharacterConfiguration.getBaseConfiguration(
          config,
        );
        expect(
          character.characterStats.map((s) => s.statUuid),
          tabs
              .firstWhere((t) => t.isDefaultTab)
              .statsInTab
              .map((s) => s.statUuid),
        );
      });

      test('$id is built the same every time', () {
        expect(
          jsonEncode(RpgConfigurationTemplates.build(id)),
          jsonEncode(config),
        );
      });
    }

    test('match each other only with themselves', () {
      for (final id in RpgConfigurationTemplates.ids) {
        expect(
          RpgConfigurationTemplates.matchingTemplateOf(
            RpgConfigurationTemplates.build(id),
          ),
          id,
        );
      }
      final changed = RpgConfigurationTemplates.narrative().copyWith(
        currencyDefinition: CurrencyDefinition(
          currencyTypes: [
            CurrencyType(name: "Taler", multipleOfPreviousValue: null),
          ],
        ),
      );
      expect(RpgConfigurationTemplates.matchingTemplateOf(changed), isNull);
    });

    test('applying keeps the campaign name and sheet skin', () {
      final campaign = RpgConfigurationTemplates.fantasySrd().copyWith(
        rpgName: "Die Klingen von Varn",
        defaultSkinId: "arcane_ledger",
      );
      for (final id in RpgConfigurationTemplates.ids) {
        final applied = RpgConfigurationTemplates.applyTo(id, campaign);
        expect(applied.rpgName, "Die Klingen von Varn");
        expect(applied.defaultSkinId, "arcane_ledger");
        expect(RpgConfigurationTemplates.matchingTemplateOf(applied), id);
      }
    });
  });

  test('"Fantasy 5E (SRD)" is the SRD configuration without items', () {
    final base = RpgConfigurationModel.getBaseConfiguration();
    final template = RpgConfigurationTemplates.fantasySrd();

    expect(
      RpgConfigurationTemplates.defaultId,
      RpgConfigurationTemplateId.fantasySrd,
    );
    expect(template.allItems, isEmpty);
    expect(template.craftingRecipes, isEmpty);
    expect(
      jsonEncode(template),
      jsonEncode(base.copyWith(allItems: [], craftingRecipes: [])),
    );
    expect(template.initiativeBonusStatUuid, base.initiativeBonusStatUuid);
  });

  test('"Leer" has one tab with name and level and one currency', () {
    final config = RpgConfigurationTemplates.empty();

    final tab = config.characterStatTabsDefinition!.single;
    expect(tab.tabName, "Charakter");
    expect(tab.isDefaultTab, isTrue);
    final summary = tab.statsInTab.single;
    expect(
      summary.valueType,
      CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
    );
    expect(characterSummaryShowsLevel(summary), isTrue);

    expect(config.currencyDefinition.currencyTypes.map((c) => c.name), [
      "Münzen",
    ]);
    expect(config.allItems, isEmpty);
    expect(config.itemCategories, isEmpty);
    expect(config.placesOfFindings, isEmpty);
    expect(config.craftingRecipes, isEmpty);
    expect(config.initiativeBonusStatUuid, isNull);
  });

  group('"Erzählerisch (Aspekte & Stress)"', () {
    final config = RpgConfigurationTemplates.narrative();

    test('has the narrative stats in two tabs', () {
      final tabs = config.characterStatTabsDefinition!;
      expect(tabs.map((t) => t.tabName), ["Charakter", "Fertigkeiten"]);
      expect(tabs.first.isDefaultTab, isTrue);
      expect(
        {for (final s in StatNumbers.allStats(config)) s.name: s.valueType},
        {
          "Grundwerte":
              CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
          "Porträt": CharacterStatValueType.singleImage,
          "Aspekte": CharacterStatValueType.textList,
          "Erzählpunkte": CharacterStatValueType.int,
          "Erholung": CharacterStatValueType.int,
          "Stress": CharacterStatValueType.checkboxTrack,
          "Konsequenzen": CharacterStatValueType.textList,
          "Fertigkeiten": CharacterStatValueType.textList,
          "Stunts": CharacterStatValueType.textList,
        },
      );
      expect(
        tabs.first.statsInTab.map((s) => s.name),
        containsAll(["Aspekte", "Stress", "Konsequenzen", "Erzählpunkte"]),
      );
    });

    test('hides the level', () {
      expect(
        characterSummaryShowsLevel(_statNamed(config, "Grundwerte")),
        isFalse,
      );
    });

    test('configures aspects, stress, consequences, skills and stunts', () {
      final aspects = TextListConfig.of(_statNamed(config, "Aspekte"));
      expect(aspects.slots.map((s) => s.label), ["Hauptaspekt", "Dilemma"]);
      expect(aspects.allowCustomEntries, isTrue);

      final stress = _statNamed(config, "Stress");
      expect(CheckboxTrackConfig.of(stress).boxCount, 3);
      expect(stress.editType, CharacterStatEditType.oneTap);

      final consequences = TextListConfig.of(
        _statNamed(config, "Konsequenzen"),
      );
      expect(consequences.slots.map((s) => s.label), [
        "Leicht (2)",
        "Mittel (4)",
        "Schwer (6)",
      ]);
      expect(consequences.allowCustomEntries, isFalse);

      final skills = TextListConfig.of(_statNamed(config, "Fertigkeiten"));
      expect(skills.slots.map((s) => s.label), ["+4", "+3", "+2", "+1"]);
      expect(skills.allowCustomEntries, isFalse);

      final stunts = TextListConfig.of(_statNamed(config, "Stunts"));
      expect(stunts.slots, isEmpty);
      expect(stunts.allowCustomEntries, isTrue);

      // Slot uuids are unique across the template.
      final slotUuids = [
        for (final stat in StatNumbers.allStats(config))
          if (stat.valueType == CharacterStatValueType.textList)
            ...TextListConfig.of(stat).slots.map((s) => s.uuid),
      ];
      expect(slotUuids.toSet(), hasLength(slotUuids.length));
    });

    test('has no items, places, categories, recipes or initiative', () {
      expect(config.allItems, isEmpty);
      expect(config.itemCategories, isEmpty);
      expect(config.placesOfFindings, isEmpty);
      expect(config.craftingRecipes, isEmpty);
      expect(config.initiativeBonusStatUuid, isNull);
      expect(config.currencyDefinition.currencyTypes.map((c) => c.name), [
        "Münzen",
      ]);
    });
  });

  group('DM cards and initiative without hit points', () {
    final kardan = RpgCharacterConfiguration.getBaseConfiguration(null);

    test('"Leer": no bar, no numbers, no initiative hint', () {
      final config = RpgConfigurationTemplates.empty();
      final selection = DmCardStats.automaticSelection(
        config,
        isAlternateForm: false,
        isCompanion: false,
      );
      expect(selection.barStatUuid, isNull);
      expect(selection.numberStats, isEmpty);
      expect(selection.fallbackNumberStats, isEmpty);
      expect(DmCardStats.barOptions(config), isEmpty);
      expect(
        resolveInitiativeBonus(rpgConfig: config, character: kardan),
        isNull,
      );
    });

    test('"Erzählerisch": the cards show the story points', () {
      final config = RpgConfigurationTemplates.narrative();
      final character = kardan.copyWith(
        characterStats: [
          for (final (name, value) in [("Erzählpunkte", 3), ("Erholung", 2)])
            RpgCharacterStatValue(
              statUuid: _statNamed(config, name).statUuid,
              serializedValue: jsonEncode({"value": value}),
              hideFromCharacterScreen: false,
              hideLabelOfStat: false,
              variant: null,
            ),
        ],
      );
      final selection = DmCardStats.automaticSelection(
        config,
        isAlternateForm: false,
        isCompanion: false,
      );
      expect(selection.barStatUuid, isNull);
      expect(DmCardStats.numbersFor(config, selection, character, _labels), [
        (label: "Erzählpunkte", value: 3),
        (label: "Erholung", value: 2),
      ]);
      expect(DmCardStats.barFor(config, selection, character), isNull);
      expect(
        resolveInitiativeBonus(rpgConfig: config, character: character),
        isNull,
      );
    });
  });

  test('no brand names in the templates or the step texts', () {
    const forbidden = [
      "fate",
      "evil hat",
      "fudge",
      "d&d",
      "dungeons & dragons",
      "dungeons and dragons",
    ];
    final newKeys = RegExp(
      r'^(wizardTemplate|wizardSkinStepHelperAfterTemplate)',
    );
    final texts = <String, String>{
      for (final id in RpgConfigurationTemplates.ids)
        "template $id": jsonEncode(RpgConfigurationTemplates.build(id)),
      for (final locale in ["de", "en"])
        for (final entry
            in (jsonDecode(File("lib/l10n/intl_$locale.arb").readAsStringSync())
                    as Map<String, dynamic>)
                .entries
                .where((e) => newKeys.hasMatch(e.key)))
          "$locale ${entry.key}": entry.value as String,
    };
    expect(texts.keys.where((k) => k.startsWith("de ")), hasLength(16));

    for (final MapEntry(:key, :value) in texts.entries) {
      final lower = value.toLowerCase();
      final found = forbidden.firstWhereOrNull(lower.contains);
      expect(found, isNull, reason: '"$found" in $key');
    }
  });
}
