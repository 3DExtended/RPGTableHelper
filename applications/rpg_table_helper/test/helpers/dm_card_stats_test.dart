import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_stats/dm_card_stats.dart';
import 'package:quest_keeper/models/dm_character_card_settings.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

const _hpUuid = "803f55cb-5d7e-425d-8054-0cb293620481";
const _skillsUuid = "44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3";
const _wisdomEntry = "167b94e6-d674-43a4-a25b-fca1309a12b0";
const _iconListUuid = "01933514-7eef-7523-a4cc-974802dc96e7";
const _acEntry = "01933512-97e4-70fe-877d-0e1f64224a00";

RpgCharacterConfiguration _character(
  RpgConfigurationModel config,
  List<RpgCharacterStatValue> stats,
) =>
    RpgCharacterConfiguration.getBaseConfiguration(config)
        .copyWith(characterStats: stats);

RpgCharacterStatValue _value({
  required String statUuid,
  required String serializedValue,
}) => RpgCharacterStatValue(
  statUuid: statUuid,
  serializedValue: serializedValue,
  hideFromCharacterScreen: false,
  variant: null,
  hideLabelOfStat: false,
);

void main() {
  final config = RpgConfigurationModel.getBaseConfiguration();

  group('automatic selection (what cards showed before)', () {
    test('base config: HP bar, icon list sorted by label, at most 6', () {
      var character = RpgCharacterConfiguration.getBaseConfiguration(config);
      var selection = DmCardStats.selectionFor(
        config,
        DmCharacterCardSettings.empty,
        isAlternateForm: false,
        isCompanion: false,
      );

      expect(selection.barStatUuid, _hpUuid);
      expect(DmCardStats.barFor(config, selection, character)?.$1.name, "HP");
      expect(
        DmCardStats.numbersFor(
          config,
          selection,
          character,
          "calc.",
        ).map((e) => "${e.label}=${e.value}"),
        ["AC=12", "SP=12", "Temp HP=12", "ÜB=12"],
      );
    });

    test('plain int stats win over the icon list, at most 8', () {
      var ints = List.generate(
        10,
        (i) => CharacterStatDefinition(
          name: "Int $i",
          groupId: null,
          isOptionalForAlternateForms: false,
          isOptionalForCompanionCharacters: false,
          statUuid: "int-$i",
          helperText: "",
          valueType: CharacterStatValueType.int,
          editType: CharacterStatEditType.static,
        ),
      );
      var tabs = config.characterStatTabsDefinition!
          .map(
            (t) => t.isDefaultTab
                ? CharacterStatsTabDefinition(
                    uuid: t.uuid,
                    tabName: t.tabName,
                    isOptional: t.isOptional,
                    isDefaultTab: true,
                    statsInTab: [...t.statsInTab, ...ints],
                  )
                : t,
          )
          .toList();
      var withInts = config.copyWith(characterStatTabsDefinition: tabs);
      var character = _character(withInts, [
        for (var i = 0; i < 10; i++)
          _value(statUuid: "int-$i", serializedValue: '{"value": $i}'),
      ]);

      var selection = DmCardStats.automaticSelection(
        withInts,
        isAlternateForm: false,
        isCompanion: false,
      );
      var numbers = DmCardStats.numbersFor(
        withInts,
        selection,
        character,
        "calc.",
      );

      expect(numbers.length, 8);
      expect(numbers.first, (label: "Int 0", value: 0));
    });
  });

  group('custom selection', () {
    test('lists the numbers the DM picked, incl. calculated ones', () {
      var character = _character(config, [
        _value(
          statUuid: _skillsUuid,
          serializedValue:
              '{"values":[{"uuid":"$_wisdomEntry","value":14,"otherValue":2}]}',
        ),
        _value(
          statUuid: _iconListUuid,
          serializedValue: '{"values":[{"uuid":"$_acEntry","value":17}]}',
        ),
        _value(
          statUuid: _hpUuid,
          serializedValue: '{"value": 30, "maxValue": 36}',
        ),
      ]);
      var settings = DmCharacterCardSettings(
        useCustomStats: true,
        barStatUuid: null,
        numberStats: [
          DmCardStatRef(statUuid: _iconListUuid, entryUuid: _acEntry),
          DmCardStatRef(
            statUuid: _skillsUuid,
            entryUuid: _wisdomEntry,
            field: DmCardStatField.otherValue,
          ),
        ],
      );

      var selection = DmCardStats.selectionFor(
        config,
        settings,
        isAlternateForm: false,
        isCompanion: false,
      );

      expect(DmCardStats.barFor(config, selection, character), isNull);
      expect(DmCardStats.numbersFor(config, selection, character, "calc."), [
        (label: "AC", value: 17),
        (label: "Weisheit (calc.)", value: 2),
      ]);
    });

    test('leaves out stats the character or the campaign does not have', () {
      var character = _character(config, []);
      var settings = DmCharacterCardSettings(
        useCustomStats: true,
        barStatUuid: _hpUuid,
        numberStats: [
          DmCardStatRef(statUuid: _iconListUuid, entryUuid: _acEntry),
          DmCardStatRef(statUuid: "deleted-stat"),
        ],
      );
      var selection = DmCardStats.selectionFor(
        config,
        settings,
        isAlternateForm: false,
        isCompanion: false,
      );

      expect(
        DmCardStats.numbersFor(config, selection, character, "calc."),
        isEmpty,
      );
      expect(DmCardStats.barFor(config, selection, character), isNull);
    });

    test('reads the legacy "calculatedValue" key as second number', () {
      var character = _character(config, [
        _value(
          statUuid: "x",
          serializedValue: '{"value": 17, "calculatedValue": 3}',
        ),
      ]);
      expect(
        DmCardStats.resolve(
          DmCardStatRef(statUuid: "x", field: DmCardStatField.otherValue),
          character,
        ),
        3,
      );
    });
  });

  test('number options cover every number of the campaign', () {
    var options = DmCardStats.numberOptions(config, "calc.");
    var labels = options.map((o) => o.label).toList();

    expect(
      labels,
      containsAll(["AC", "Temp HP", "Weisheit", "Weisheit (calc.)"]),
    );
    // The icon list has no name; its tab names the group.
    expect(options.firstWhere((o) => o.label == "AC").groupLabel, "Stats");
    expect(DmCardStats.barOptions(config).map((s) => s.name), contains("HP"));
  });
}
