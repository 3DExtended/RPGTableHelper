import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/level_up.dart';
import 'package:quest_keeper/helpers/character_stats/show_character_stats_form.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:quest_keeper/helpers/character_stats/show_template_update_picker.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/helpers/character_stats/template_update.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// "Stufenaufstieg": the level one up, then the properties the campaign
/// marked for it, tab by tab.
void main() {
  final srd = RpgConfigurationTemplates.fantasySrd();
  final summary = levelStatOf(srd)!;

  RpgCharacterStatValue value(String statUuid, Map<String, dynamic> json) =>
      RpgCharacterStatValue(
        statUuid: statUuid,
        serializedValue: jsonEncode(json),
        hideFromCharacterScreen: false,
        variant: 0,
        hideLabelOfStat: false,
      );

  group('the mark on a property', () {
    test('is read from and written to the additional data', () {
      final hp = StatNumbers.allStats(srd).firstWhere((s) => s.name == 'TP');
      expect(statAsksOnLevelUp(hp), isTrue);
      final origin =
          StatNumbers.allStats(srd).firstWhere((s) => s.name == 'Herkunft');
      expect(statAsksOnLevelUp(origin), isFalse);

      final marked = withAskOnLevelUp('{"example": "Ein Dorf."}', true)!;
      expect(jsonDecode(marked), {'example': 'Ein Dorf.', 'askOnLevelUp': true});
      expect(jsonDecode(withAskOnLevelUp(marked, false)!),
          {'example': 'Ein Dorf.'});
      expect(withAskOnLevelUp('{"askOnLevelUp": true}', false), isNull);
      expect(withAskOnLevelUp(null, false), isNull);
    });

    test('the templates mark only properties a player can type in', () {
      for (final id in RpgConfigurationTemplates.ids) {
        for (final stat
            in StatNumbers.allStats(RpgConfigurationTemplates.build(id))) {
          if (!statAsksOnLevelUp(stat)) continue;
          expect(canAskOnLevelUp(stat.valueType), isTrue, reason: stat.name);
          expect(StatNumbers.isComputed(stat), isFalse, reason: stat.name);
        }
      }
    });
  });

  group('the level', () {
    test('is in the character summary unless the campaign switched it off',
        () {
      expect(summary.valueType,
          CharacterStatValueType.characterNameWithLevelAndAdditionalDetails);
      expect(levelStatOf(RpgConfigurationTemplates.empty()), isNotNull);
      expect(levelStatOf(RpgConfigurationTemplates.narrative()), isNull);
    });

    test('goes one up and keeps the rest of the summary', () {
      final before = value(summary.statUuid, {
        'level': 4,
        'values': [
          {'uuid': 'class', 'value': 'Waldläuferin'},
        ],
        'imageUrl': 'https://example.test/mira.png',
      }).copyWith(hideLabelOfStat: true);
      expect(levelOf(before), 4);

      final after = nextLevelValue(summary, before);
      expect(levelOf(after), 5);
      expect(after.hideLabelOfStat, isTrue);
      final json = jsonDecode(after.serializedValue);
      expect(json['values'], [
        {'uuid': 'class', 'value': 'Waldläuferin'},
      ]);
      expect(json['imageUrl'], 'https://example.test/mira.png');

      expect(levelOf(nextLevelValue(summary, null)), 2);
      expect(levelOf(value(summary.statUuid, {'level': '3', 'values': []})),
          3);
    });
  });

  group('the pages', () {
    test('start with the level, then each tab with marked properties', () {
      final pages = buildLevelUpPages(rpgConfig: srd, isCompanion: false);
      expect(
        [
          for (final page in pages)
            '${page.tab!.tabName}: ${page.stats.map((s) => s.name).join(', ')}',
        ],
        [
          'Werte: Charakter-Zusammenfassung, Attribute, Kampfwerte, TP',
          'Merkmale: Merkmale',
          'Angriffe: Angriffe',
          'Zauber: Zauberplätze gesamt, Zaubertricks',
        ],
      );
      expect(pages.every((p) => !p.showNameField), isTrue);
    });

    test('only the level when nothing is marked, none without a level', () {
      final empty = buildLevelUpPages(
        rpgConfig: RpgConfigurationTemplates.empty(),
        isCompanion: false,
      );
      expect(empty.single.stats.single.valueType,
          CharacterStatValueType.characterNameWithLevelAndAdditionalDetails);

      expect(
        buildLevelUpPages(
          rpgConfig: RpgConfigurationTemplates.narrative(),
          isCompanion: false,
        ),
        isEmpty,
      );
    });
  });

  test('the template update offers the marks to older campaigns', () async {
    final old = srd.copyWith(characterStatTabsDefinition: [
      for (final tab in srd.characterStatTabsDefinition!)
        tab.copyWith(statsInTab: [
          for (final stat in tab.statsInTab)
            CharacterStatDefinition.fromJson({
              ...stat.toJson(),
              'jsonSerializedAdditionalData': withAskOnLevelUp(
                stat.jsonSerializedAdditionalData,
                false,
              ),
            }),
        ]),
    ]);
    final update = templateUpdateFor(old)!;
    final hp = update.changes.singleWhere((c) => c.updated.name == 'TP');
    expect(hp.levelUpChanged, isTrue);
    expect(hp.otherSettingsChanged, isFalse);
    final s = await S.load(const Locale('de'));
    expect(describeTemplateStatChange(s, hp), s.templateUpdateLevelUpChanged);
    expect(update.changes.where((c) => c.levelUpChanged), hasLength(7));
  });

  testWidgets('the form raises the level and asks tab by tab',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final character = RpgCharacterConfiguration.getBaseConfiguration(null)
        .copyWith(characterName: 'Mira', characterStats: [
      value(summary.statUuid, {
        'level': 4,
        'values': [
          {'uuid': '019317b8-49eb-7575-9f8e-c28c9c8eded2', 'value': 'Magierin'},
        ],
      }),
    ]);
    final pages = buildLevelUpPages(rpgConfig: srd, isCompanion: false);
    final persisted = <RpgCharacterStatValue>[];
    CharacterStatsFormOutcome? outcome;
    final key = GlobalKey<NavigatorState>();

    await tester.pumpWidget(CustomThemeProvider(
      overrideBrightness: Brightness.light,
      child: ProviderScope(
        overrides: [
          rpgCharacterConfigurationProvider.overrideWith((ref) =>
              RpgCharacterConfigurationNotifier(
                decks: AsyncValue.data(character),
                ref: ref,
                runningInTests: true,
              )),
          rpgConfigurationProvider.overrideWith((ref) =>
              RpgConfigurationNotifier(
                decks: AsyncValue.data(srd),
                ref: ref,
                runningInTests: true,
              )),
        ],
        child: ThemeConfigurationForApp(
          child: MaterialApp(
            navigatorKey: key,
            locale: const Locale('de'),
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: DependencyProvider.getMockedDependecyProvider(
              child: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () async {
                      outcome = await showCharacterStatsForm(
                        context: context,
                        pages: pages,
                        mode: CharacterStatsFormMode.levelUp,
                        characterName: 'Mira',
                        initialValues: {
                          summary.statUuid: nextLevelValue(
                            summary,
                            character.characterStats.single,
                          ),
                        },
                        characterToRenderStatFor: character,
                        isEditingAlternateForm: false,
                        overrideNavigatorKey: key,
                        previousLevel: 4,
                        onPersist: (stats, name) => persisted.addAll(stats),
                      );
                    },
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text(S.current.levelUpTitle), findsWidgets);
    expect(find.textContaining(S.current.levelUpIntro(4, 5)), findsWidgets);
    expect(
      find.text(S.current.characterSetupProgress(1, pages.length, 'Werte')),
      findsWidgets,
    );
    expect(find.text(S.current.fillInLater), findsNothing);
    final level = find.widgetWithText(TextField, 'Level').last;
    expect(tester.widget<TextField>(level).controller!.text, '5');

    for (var i = 0; i < pages.length; i++) {
      final isLast = i == pages.length - 1;
      await tester.tap(find
          .text(isLast ? S.current.characterSetupFinish : S.current.next)
          .last);
      await tester.pumpAndSettle();
    }

    expect(outcome, CharacterStatsFormOutcome.completed);
    final stored =
        persisted.lastWhere((s) => s.statUuid == summary.statUuid);
    final json = jsonDecode(stored.serializedValue);
    expect(json['level'], 5);
    expect(json['values'], contains(containsPair('value', 'Magierin')));
    expect(
      persisted.map((s) => s.statUuid).toSet(),
      pages.expand((p) => p.stats).map((s) => s.statUuid).toSet(),
    );
  });

  testWidgets('the property editor sets and keeps the mark', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final origin =
        StatNumbers.allStats(srd).firstWhere((s) => s.name == 'Herkunft');
    CharacterStatDefinition? saved;

    await tester.pumpWidget(ProviderScope(
      child: CustomThemeProvider(
        child: ThemeConfigurationForApp(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            home: CustomThemeProvider(
              child: DependencyProvider.getMockedDependecyProvider(
                child: Scaffold(
                  body: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () async {
                        saved = await showGetDmConfigurationModal(
                          context: context,
                          predefinedConfiguration: origin,
                        );
                      },
                      child: const Text('open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    Future<void> tapLast(Finder finder) async {
      await tester.ensureVisible(finder.last);
      await tester.pumpAndSettle();
      await tester.tap(finder.last);
      await tester.pumpAndSettle();
    }

    await tapLast(find.text(S.current.additionalSettings));
    // The box of the tile is what reacts.
    await tapLast(find.descendant(
      of: find.byKey(const ValueKey('propertyAskOnLevelUp')),
      matching: find.byType(CustomButton),
    ));
    await tapLast(find.text(S.current.save));

    expect(statAsksOnLevelUp(saved!), isTrue);
    expect(jsonDecode(saved!.jsonSerializedAdditionalData!)['example'],
        isNotEmpty,
        reason: 'the example stays');
    expect(tester.takeException(), isNull);
  });
}
