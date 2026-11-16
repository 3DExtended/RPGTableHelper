import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_stats/character_stats_form_pages.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

RpgCharacterStatValue _value(String statUuid) => RpgCharacterStatValue(
  hideFromCharacterScreen: false,
  hideLabelOfStat: false,
  variant: 0,
  statUuid: statUuid,
  serializedValue: '{"value": "x"}',
);

RpgCharacterConfiguration _newCharacter(
  RpgConfigurationModel config, {
  String name = 'Mira Dornwald',
  List<RpgCharacterStatValue> stats = const [],
}) =>
    RpgCharacterConfiguration.getBaseConfiguration(null)
        .copyWith(characterName: name, characterStats: stats);

void main() {
  final config = RpgConfigurationModel.getBaseConfiguration();
  final tabs = config.characterStatTabsDefinition!;
  final tabsWithFields = tabs
      .where((t) => fillableStatsOfTab(t, isCompanion: false).isNotEmpty)
      .toList();

  group('buildCharacterStatsFormPages (setup)', () {
    test('one page per tab, all fields of the tab on that page', () {
      final pages = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: _newCharacter(config),
        isCompanion: false,
      );

      expect(pages.map((p) => p.tab!.uuid), tabsWithFields.map((t) => t.uuid));
      for (final page in pages) {
        expect(
          page.stats.map((s) => s.statUuid),
          fillableStatsOfTab(
            page.tab!,
            isCompanion: false,
          ).map((s) => s.statUuid),
        );
      }
      // The D&D template has ~30 fields; the form needs only a few pages.
      expect(pages.length, lessThanOrEqualTo(tabs.length));
      expect(pages.expand((p) => p.stats).length, greaterThan(pages.length));
    });

    test('continues where something is missing', () {
      final background = tabs.first;
      final firstBackgroundStat = background.statsInTab.first;
      final allOtherBackgroundStats = background.statsInTab.skip(1);

      // Whole Background tab filled: it is skipped.
      var pages = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: _newCharacter(
          config,
          stats: background.statsInTab.map((s) => _value(s.statUuid)).toList(),
        ),
        isCompanion: false,
      );
      expect(pages.first.tab!.uuid, isNot(background.uuid));

      // Background partly filled: only the missing field is asked again.
      pages = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: _newCharacter(
          config,
          stats: allOtherBackgroundStats
              .map((s) => _value(s.statUuid))
              .toList(),
        ),
        isCompanion: false,
      );
      expect(pages.first.tab!.uuid, background.uuid);
      expect(pages.first.stats.map((s) => s.statUuid), [
        firstBackgroundStat.statUuid,
      ]);
    });

    test('nothing to fill in gives no pages', () {
      final everything = tabs
          .expand((t) => t.statsInTab)
          .map((s) => _value(s.statUuid))
          .toList();
      final pages = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: _newCharacter(config, stats: everything),
        isCompanion: false,
      );
      expect(pages, isEmpty);
    });

    test('an empty name is asked on the first page only', () {
      final pages = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: _newCharacter(config, name: '  '),
        isCompanion: false,
      );
      expect(pages.first.showNameField, isTrue);
      expect(pages.skip(1).any((p) => p.showNameField), isFalse);

      final named = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: _newCharacter(config),
        isCompanion: false,
      );
      expect(named.any((p) => p.showNameField), isFalse);
    });

    test('only a missing name gives a single name page', () {
      final everything = tabs
          .expand((t) => t.statsInTab)
          .map((s) => _value(s.statUuid))
          .toList();
      final pages = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: _newCharacter(config, name: '', stats: everything),
        isCompanion: false,
      );
      expect(pages, hasLength(1));
      expect(pages.single.showNameField, isTrue);
      expect(pages.single.stats, isEmpty);
    });

    test('companions are not asked for a companion selector', () {
      final configWithSelector = config.copyWith(
        characterStatTabsDefinition: [
          CharacterStatsTabDefinition(
            uuid: 'tab',
            tabName: 'Tab',
            isOptional: false,
            isDefaultTab: true,
            statsInTab: [
              CharacterStatDefinition(
                statUuid: 'selector',
                name: 'Begleiter',
                groupId: null,
                helperText: '',
                valueType: CharacterStatValueType.companionSelector,
                editType: CharacterStatEditType.static,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
              ),
            ],
          ),
        ],
      );
      final character = _newCharacter(configWithSelector);

      expect(
        buildCharacterStatsFormPages(
          rpgConfig: configWithSelector,
          character: character,
          isCompanion: true,
        ),
        isEmpty,
      );
      expect(
        buildCharacterStatsFormPages(
          rpgConfig: configWithSelector,
          character: character,
          isCompanion: false,
        ),
        hasLength(1),
      );
    });
  });

  group('buildCharacterStatsFormPages (edit one tab)', () {
    test('shows every field of the tab, also filled ones', () {
      final background = tabs.first;
      final pages = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: _newCharacter(
          config,
          stats: background.statsInTab.map((s) => _value(s.statUuid)).toList(),
        ),
        isCompanion: false,
        filterTabId: background.uuid,
      );
      expect(pages, hasLength(1));
      expect(
        pages.single.stats.map((s) => s.statUuid),
        background.statsInTab.map((s) => s.statUuid),
      );
      expect(pages.single.showNameField, isFalse);
    });

    test('the default tab also edits the name', () {
      final defaultTab = tabs.firstWhere((t) => t.isDefaultTab);
      final pages = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: _newCharacter(config),
        isCompanion: false,
        filterTabId: defaultTab.uuid,
      );
      expect(pages.single.showNameField, isTrue);
    });
  });
}
