import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_character_card.dart';
import 'package:quest_keeper/components/stat_types/checkbox_track_view.dart';
import 'package:quest_keeper/components/stat_types/text_list_view.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/character_stats/character_stats_form_pages.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/helpers/character_stats/render_characters_as_cards.dart';
import 'package:quest_keeper/helpers/character_stats/show_character_stats_form.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_stats_for_tab.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../custom_font_loader.dart';

/// A new character in the "Leer" and "Erzählerisch" templates: the character
/// form asks for every field, the sheet shows every tab in every skin, and
/// the DM's card works without hit points.
///
/// Modals draw their content twice (the blurred shadow copy behind the real
/// one), so taps go to the last (top) match.
void main() {
  const templates = {
    "Leer": RpgConfigurationTemplateId.empty,
    "Erzählerisch": RpgConfigurationTemplateId.narrative,
  };
  const skins = [
    CharacterSheetSkinIds.classicLight,
    CharacterSheetSkinIds.classicDark,
    CharacterSheetSkinIds.arcaneLedger,
    CharacterSheetSkinIds.nightCartographer,
  ];

  RpgCharacterConfiguration newCharacter() =>
      RpgCharacterConfiguration.getBaseConfiguration(null)
          .copyWith(characterName: '', characterStats: []);

  CharacterStatDefinition statNamed(RpgConfigurationModel config, String n) =>
      StatNumbers.allStats(config).singleWhere((s) => s.name == n);

  Future<void> usePhoneSize(WidgetTester tester) async {
    // Real fonts: the test font draws every glyph as a wide square.
    await customLoadAppFonts();
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<void> tapReal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder.last);
    await tester.pumpAndSettle();
    await tester.tap(finder.last);
    await tester.pumpAndSettle();
  }

  group('character form', () {
    /// Opens the setup form of a new character at iPhone size.
    Future<
      ({
        List<CharacterStatsFormPage> pages,
        List<RpgCharacterStatValue> Function() stored,
        String? Function() name,
        CharacterStatsFormOutcome? Function() outcome,
      })
    >
    openSetupForm(WidgetTester tester, RpgConfigurationModel config) async {
      await usePhoneSize(tester);
      final navigatorKey = GlobalKey<NavigatorState>();
      final pages = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: newCharacter(),
        isCompanion: false,
      );
      final persisted = <List<RpgCharacterStatValue>>[];
      String? storedName;
      CharacterStatsFormOutcome? outcome;

      await tester.pumpWidget(
        CustomThemeProvider(
          overrideBrightness: Brightness.light,
          child: ProviderScope(
            overrides: [
              rpgCharacterConfigurationProvider.overrideWith((ref) {
                return RpgCharacterConfigurationNotifier(
                  decks: AsyncValue.data(newCharacter()),
                  ref: ref,
                  runningInTests: true,
                );
              }),
              rpgConfigurationProvider.overrideWith((ref) {
                return RpgConfigurationNotifier(
                  decks: AsyncValue.data(config),
                  ref: ref,
                  runningInTests: true,
                );
              }),
            ],
            child: ThemeConfigurationForApp(
              child: MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [
                  ...AppLocalizations.localizationsDelegates,
                  S.delegate,
                ],
                locale: const Locale("de"),
                supportedLocales: AppLocalizations.supportedLocales,
                home: DependencyProvider.getMockedDependecyProvider(
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: () async {
                          outcome = await showCharacterStatsForm(
                            context: context,
                            pages: pages,
                            mode: CharacterStatsFormMode.setup,
                            characterName: '',
                            initialValues: const {},
                            characterToRenderStatFor: newCharacter(),
                            isEditingAlternateForm: false,
                            overrideNavigatorKey: navigatorKey,
                            onPersist: (stats, name) {
                              persisted.add(List.of(stats));
                              storedName = name ?? storedName;
                            },
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
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return (
        pages: pages,
        stored: () => persisted.expand((p) => p).toList(),
        name: () => storedName,
        outcome: () => outcome,
      );
    }

    Future<void> enterName(WidgetTester tester, String name) async {
      final field = find.widgetWithText(TextField, S.current.characterName);
      await tester.ensureVisible(field.last);
      await tester.enterText(field.last, name);
      await tester.pump();
    }

    testWidgets('"Leer" asks for name and level on one page', (tester) async {
      final config = RpgConfigurationTemplates.empty();
      final form = await openSetupForm(tester, config);
      expect(tester.takeException(), isNull);

      expect(form.pages, hasLength(1));
      expect(form.pages.single.showNameField, isTrue);
      await enterName(tester, 'Mira Dornwald');
      final level = find.widgetWithText(TextField, S.current.level);
      expect(level, findsWidgets);
      await tester.enterText(level.last, '3');
      await tester.pump();

      await tapReal(tester, find.text(S.current.characterSetupFinish));
      expect(tester.takeException(), isNull);
      expect(form.outcome(), CharacterStatsFormOutcome.completed);
      expect(form.name(), 'Mira Dornwald');

      final summary = form.stored().single;
      expect(summary.statUuid, statNamed(config, "Grundwerte").statUuid);
      expect(jsonDecode(summary.serializedValue)['level'], 3);
    });

    testWidgets('"Erzählerisch" asks for every field, without a level', (
      tester,
    ) async {
      final config = RpgConfigurationTemplates.narrative();
      final form = await openSetupForm(tester, config);
      expect(tester.takeException(), isNull);

      expect(form.pages.map((p) => p.tab!.tabName), [
        "Charakter",
        "Fertigkeiten",
      ]);
      expect(find.widgetWithText(TextField, S.current.level), findsNothing);

      await enterName(tester, 'Mira Dornwald');
      final aspects = TextListConfig.of(statNamed(config, "Aspekte"));
      final concept = find.descendant(
        of: find
            .byKey(ValueKey('text-list-slot-field-${aspects.slots.first.uuid}'))
            .last,
        matching: find.byType(TextField),
        matchRoot: true,
      );
      await tester.ensureVisible(concept);
      await tester.enterText(concept, 'Fahrende Ritterin ohne Pferd');
      await tester.pump();
      await tapReal(tester, find.byKey(CheckboxTrackView.boxKey(0)));

      await tapReal(tester, find.text(S.current.next));
      expect(tester.takeException(), isNull);
      await tapReal(tester, find.text(S.current.characterSetupFinish));
      expect(tester.takeException(), isNull);
      expect(form.outcome(), CharacterStatsFormOutcome.completed);

      final stored = form.stored();
      expect(
        stored.map((s) => s.statUuid).toSet(),
        StatNumbers.allStats(config).map((s) => s.statUuid).toSet(),
      );
      String valueOf(String name) => stored
          .lastWhere((s) => s.statUuid == statNamed(config, name).statUuid)
          .serializedValue;
      expect(jsonDecode(valueOf("Stress")), {
        "checked": [0],
      });
      expect(
        textListEntriesOf(valueOf("Aspekte")).first.value,
        'Fahrende Ritterin ohne Pferd',
      );
    });
  });

  group('character sheet', () {
    /// A value for every stat of [config], as a filled-in character has.
    List<RpgCharacterStatValue> filledValues(RpgConfigurationModel config) => [
      for (final stat in StatNumbers.allStats(config))
        RpgCharacterStatValue(
          statUuid: stat.statUuid,
          variant: 0,
          hideFromCharacterScreen: false,
          hideLabelOfStat: false,
          serializedValue: switch (stat.valueType) {
            CharacterStatValueType.characterNameWithLevelAndAdditionalDetails =>
              jsonEncode({"level": 4, "values": []}),
            CharacterStatValueType.singleImage => jsonEncode({
              "value": "",
              "imageUrl": "assets/images/charactercard_placeholder.png",
            }),
            CharacterStatValueType.int => jsonEncode({"value": 3}),
            CharacterStatValueType.checkboxTrack => serializeCheckedBoxes([1]),
            CharacterStatValueType.textList => serializeTextListEntries([
              for (final slot in TextListConfig.of(stat).slots)
                TextListEntry(
                  uuid: slot.uuid,
                  value: "Ein ziemlich langer Eintrag für ${slot.label}",
                ),
            ]),
            _ => throw StateError("no value for ${stat.valueType}"),
          },
        ),
    ];

    Future<List<RpgCharacterStatValue>> pumpTab(
      WidgetTester tester, {
      required RpgConfigurationModel config,
      required CharacterStatsTabDefinition tab,
      required String skinId,
    }) async {
      final saved = <RpgCharacterStatValue>[];
      await tester.pumpWidget(
        ProviderScope(
          child: CustomThemeProvider(
            overrideSkinId: skinId,
            child: ThemeConfigurationForApp(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [
                  ...AppLocalizations.localizationsDelegates,
                  S.delegate,
                ],
                locale: const Locale("de"),
                supportedLocales: AppLocalizations.supportedLocales,
                home: DependencyProvider.getMockedDependecyProvider(
                  child: Scaffold(
                    body: SingleChildScrollView(
                      child: PlayerScreenCharacterStatsForTab(
                        key: UniqueKey(),
                        tabDef: tab,
                        rpgConfig: config,
                        charToRender: newCharacter().copyWith(
                          characterName: "Mira Dornwald",
                          characterStats: filledValues(config),
                        ),
                        onStatValueChanged: saved.add,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return saved;
    }

    for (final MapEntry(key: name, value: id) in templates.entries) {
      for (final skin in skins) {
        testWidgets('$name, $skin: every tab fits at iPhone width', (
          tester,
        ) async {
          await usePhoneSize(tester);
          final config = RpgConfigurationTemplates.build(id);

          for (final tab in config.characterStatTabsDefinition!) {
            await pumpTab(tester, config: config, tab: tab, skinId: skin);
            expect(tester.takeException(), isNull, reason: tab.tabName);
            if (tab.isDefaultTab) {
              expect(find.textContaining("Mira Dornwald"), findsWidgets);
            } else {
              expect(find.text("Ein ziemlich langer Eintrag für +4"), findsOne);
            }
          }
        });
      }
    }

    testWidgets('"Erzählerisch": stress is ticked right on the sheet', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final config = RpgConfigurationTemplates.narrative();
      final saved = await pumpTab(
        tester,
        config: config,
        tab: config.characterStatTabsDefinition!.first,
        skinId: CharacterSheetSkinIds.classicDark,
      );

      expect(find.byType(TextListView), findsNWidgets(2));
      expect(find.text("Hauptaspekt"), findsOneWidget);
      expect(find.text("Schwer (6)"), findsOneWidget);
      expect(find.textContaining(S.current.levelAbbr), findsNothing);

      await tester.ensureVisible(find.byKey(CheckboxTrackView.boxKey(2)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(CheckboxTrackView.boxKey(2)));
      await tester.pumpAndSettle();

      expect(saved.single.statUuid, statNamed(config, "Stress").statUuid);
      expect(jsonDecode(saved.single.serializedValue), {
        "checked": [1, 2],
      });
    });
  });

  group('DM card', () {
    for (final MapEntry(key: name, value: id) in templates.entries) {
      testWidgets('$name: the card renders without hit points', (tester) async {
        final config = RpgConfigurationTemplates.build(id);
        final character = newCharacter().copyWith(
          characterName: "Mira Dornwald",
          characterStats: [
            for (final stat in StatNumbers.allStats(config))
              if (stat.valueType == CharacterStatValueType.int)
                RpgCharacterStatValue(
                  statUuid: stat.statUuid,
                  serializedValue: jsonEncode({"value": 3}),
                  variant: 0,
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                ),
          ],
        );

        await tester.pumpWidget(
          CustomThemeProvider(
            child: MaterialApp(
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale("de"),
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) => Center(
                    child: SizedBox(
                      width: 260,
                      child: Column(
                        children:
                            RenderCharactersAsCards.renderCharactersAsCharacterCard(
                              context,
                              [
                                (
                                  characterToRender: character,
                                  isAlternateForm: false,
                                  isCompanion: false,
                                ),
                              ],
                              config,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final card = tester.widget<CustomCharacterCard>(
          find.byType(CustomCharacterCard),
        );
        expect(card.characterStatWithMaxValueForBarVisuals, isNull);
        expect(
          card.characterSingleNumberStats.map((n) => n.label),
          id == RpgConfigurationTemplateId.narrative
              ? ["Erzählpunkte", "Erholung"]
              : isEmpty,
        );
      });
    }
  });
}
