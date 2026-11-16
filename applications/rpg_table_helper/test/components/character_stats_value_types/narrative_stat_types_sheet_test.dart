import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/stat_types/checkbox_track_view.dart';
import 'package:quest_keeper/components/stat_types/single_select_view.dart';
import 'package:quest_keeper/components/stat_types/text_list_view.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_stats_for_tab.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../custom_font_loader.dart';
import 'narrative_stat_fixtures.dart';

/// The checkboxTrack, textList and singleSelect types on the character sheet
/// (edited right there), the sheet without a level, and all of it in every
/// skin at iPhone width.
void main() {
  const skins = [
    CharacterSheetSkinIds.classicLight,
    CharacterSheetSkinIds.classicDark,
    CharacterSheetSkinIds.arcaneLedger,
    CharacterSheetSkinIds.nightCartographer,
  ];

  Future<void> usePhoneSize(WidgetTester tester) async {
    // Real fonts: the test font draws every glyph as a wide square.
    await customLoadAppFonts();
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// The sheet tab of [config] as the player sees it. Every change is stored
  /// in the character (like the player page does) and reported in the list.
  Future<List<RpgCharacterStatValue>> pumpSheet(
    WidgetTester tester, {
    required RpgConfigurationModel config,
    required List<RpgCharacterStatValue> values,
    String skinId = CharacterSheetSkinIds.classicDark,
    bool readOnly = false,
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
                  body: _SheetHost(
                    // A fresh character on every pump.
                    key: UniqueKey(),
                    config: config,
                    character: characterWith(values),
                    readOnly: readOnly,
                    onSaved: saved.add,
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

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Map<String, String> entriesByUuid(RpgCharacterStatValue value) => {
    for (final e in textListEntriesOf(value.serializedValue)) e.uuid: e.value,
  };

  group('checkbox track', () {
    testWidgets('a tap ticks a box and stores it, no dialog', (tester) async {
      final saved = await pumpSheet(
        tester,
        config: configWithStoryTab([stressTrack]),
        values: [statValue("stat-stress", serializeCheckedBoxes(const []))],
      );
      expect(find.text("Ausgeschaltet"), findsOneWidget);

      await tap(tester, find.byKey(CheckboxTrackView.boxKey(1)));
      expect(find.byType(Dialog), findsNothing);
      expect(saved.single.statUuid, "stat-stress");
      expect(jsonDecode(saved.single.serializedValue), {
        "checked": [1],
      });

      await tap(tester, find.byKey(CheckboxTrackView.boxKey(3)));
      expect(jsonDecode(saved.last.serializedValue), {
        "checked": [1, 3],
      });

      // A second tap frees the box again.
      await tap(tester, find.byKey(CheckboxTrackView.boxKey(1)));
      expect(jsonDecode(saved.last.serializedValue), {
        "checked": [3],
      });
      expect(saved, hasLength(3));
    });

    testWidgets('the DM view of the sheet does not tick boxes', (tester) async {
      final saved = await pumpSheet(
        tester,
        config: configWithStoryTab([stressTrack]),
        values: [
          statValue("stat-stress", serializeCheckedBoxes(const [0])),
        ],
        readOnly: true,
      );

      await tap(tester, find.byKey(CheckboxTrackView.boxKey(2)));
      expect(saved, isEmpty);
    });
  });

  group('text list', () {
    testWidgets('a tap on a fixed slot edits it in a small dialog', (
      tester,
    ) async {
      final saved = await pumpSheet(
        tester,
        config: configWithStoryTab([aspects]),
        values: [
          statValue(
            "stat-aspects",
            serializeTextListEntries(const [
              TextListEntry(uuid: "slot-trouble", value: "Jähzornig"),
            ]),
          ),
        ],
      );
      expect(find.text("Hauptaspekt"), findsOneWidget);
      expect(find.text("Dilemma"), findsOneWidget);
      expect(find.text("Jähzornig"), findsOneWidget);

      await tap(tester, find.byKey(TextListView.rowKey("slot-concept")));
      expect(
        find.text(S.current.textListDeleteEntry),
        findsNothing,
        reason: 'a fixed slot cannot be deleted',
      );
      await tester.enterText(
        find.widgetWithText(TextField, "Hauptaspekt").last,
        "  Fahrende Ritterin ",
      );
      await tap(tester, find.text(S.current.save).last);

      expect(entriesByUuid(saved.single), {
        "slot-trouble": "Jähzornig",
        "slot-concept": "Fahrende Ritterin",
      });
      expect(find.text("Fahrende Ritterin"), findsOneWidget);
    });

    testWidgets('own entries can be added and deleted', (tester) async {
      final saved = await pumpSheet(
        tester,
        config: configWithStoryTab([aspects]),
        values: [statValue("stat-aspects", serializeTextListEntries(const []))],
      );

      await tap(tester, find.byKey(TextListView.addEntryKey));
      await tester.enterText(
        find.byType(TextField).last,
        "Schuldet der Gilde Geld",
      );
      await tap(tester, find.text(S.current.save).last);

      final ownUuid = entriesByUuid(saved.last).keys.single;
      expect(ownUuid, isNot(anyOf("slot-concept", "slot-trouble")));
      expect(entriesByUuid(saved.last)[ownUuid], "Schuldet der Gilde Geld");
      expect(find.text("Schuldet der Gilde Geld"), findsOneWidget);

      await tap(tester, find.byKey(TextListView.rowKey(ownUuid)));
      await tap(tester, find.text(S.current.textListDeleteEntry).last);

      expect(entriesByUuid(saved.last), isEmpty);
      expect(find.text("Schuldet der Gilde Geld"), findsNothing);
    });

    testWidgets('without own entries allowed there is no add button', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        config: configWithStoryTab([
          aspects.copyWith(
            jsonSerializedAdditionalData: const TextListConfig(
              slots: [TextListSlot(uuid: "slot-concept", label: "Hauptaspekt")],
              allowCustomEntries: false,
            ).toAdditionalData(),
          ),
        ]),
        values: [statValue("stat-aspects", serializeTextListEntries(const []))],
      );

      expect(find.text("Hauptaspekt"), findsOneWidget);
      expect(find.byKey(TextListView.addEntryKey), findsNothing);
    });
  });

  group('single select', () {
    testWidgets('a tap picks an option and replaces the previous choice', (
      tester,
    ) async {
      final saved = await pumpSheet(
        tester,
        config: configWithStoryTab([origin]),
        values: [
          statValue("stat-origin", serializeSingleSelect(null), variant: 1),
        ],
      );

      await tap(tester, find.byKey(SingleSelectOptionTile.keyFor("opt-noble")));
      expect(jsonDecode(saved.last.serializedValue), {"value": "opt-noble"});

      await tap(
        tester,
        find.byKey(SingleSelectOptionTile.keyFor("opt-street")),
      );
      expect(jsonDecode(saved.last.serializedValue), {"value": "opt-street"});

      // Tapping the chosen option again changes nothing.
      await tap(
        tester,
        find.byKey(SingleSelectOptionTile.keyFor("opt-street")),
      );
      expect(saved, hasLength(2));
    });

    testWidgets('variant 0 shows only the chosen option', (tester) async {
      await pumpSheet(
        tester,
        config: configWithStoryTab([origin]),
        values: [statValue("stat-origin", serializeSingleSelect("opt-street"))],
      );
      expect(find.text("Gosse"), findsOneWidget);
      expect(find.text("Adel"), findsNothing);

      await pumpSheet(
        tester,
        config: configWithStoryTab([origin]),
        values: [statValue("stat-origin", serializeSingleSelect(null))],
      );
      expect(find.text(S.current.singleSelectNothingChosen), findsOneWidget);
    });
  });

  group('character summary level', () {
    for (final variant in [0, 1, 2, 3]) {
      testWidgets('variant $variant without level shows no level', (
        tester,
      ) async {
        await pumpSheet(
          tester,
          config: configWithStoryTab([characterSummary(showLevel: false)]),
          values: [summaryValue(variant: variant)],
        );

        expect(find.textContaining("Mira Dornwald"), findsWidgets);
        expect(find.textContaining("Fahrende Ritterin"), findsWidgets);
        expect(find.textContaining("$summaryLevel"), findsNothing);
        expect(find.textContaining(S.current.levelAbbr), findsNothing);
      });

      testWidgets('variant $variant with level is unchanged', (tester) async {
        await pumpSheet(
          tester,
          config: configWithStoryTab([characterSummary(showLevel: true)]),
          values: [summaryValue(variant: variant)],
        );

        expect(find.textContaining("Mira Dornwald"), findsWidgets);
        expect(find.textContaining("$summaryLevel"), findsWidgets);
      });
    }
  });

  group('every skin at iPhone width', () {
    final exhaustionTrack = narrativeStat(
      uuid: "stat-exhaustion",
      name: "Erschöpfung und andere lange Bezeichnungen",
      type: CharacterStatValueType.checkboxTrack,
      additionalData: CheckboxTrackConfig(
        boxCount: CheckboxTrackConfig.maxBoxes,
        labels: List.generate(
          CheckboxTrackConfig.maxBoxes,
          (i) => i.isEven ? "Unverhältnismäßig erschöpft ${i + 1}" : "",
        ),
      ).toAdditionalData(),
    );
    final originList = origin.copyWith(
      statUuid: "stat-origin-list",
      name: "Herkunft (alle Optionen)",
    );

    RpgConfigurationModel config({bool showLevel = false}) =>
        configWithStoryTab([
          characterSummary(showLevel: showLevel),
          stressTrack,
          exhaustionTrack,
          aspects,
          origin,
          originList,
          futureStat,
        ]);

    List<RpgCharacterStatValue> values({int summaryVariant = 0}) => [
      summaryValue(variant: summaryVariant),
      statValue("stat-stress", serializeCheckedBoxes(const [0, 3])),
      statValue("stat-exhaustion", serializeCheckedBoxes(const [1, 19])),
      statValue(
        "stat-aspects",
        serializeTextListEntries(const [
          TextListEntry(
            uuid: "slot-concept",
            value:
                "Fahrende Ritterin ohne Pferd, ohne Herrin und ohne jede "
                "Ahnung, wohin die Straße führt",
          ),
          TextListEntry(uuid: "own-1", value: "Schuldet der Gilde Geld"),
        ]),
      ),
      statValue("stat-origin", serializeSingleSelect("opt-street")),
      statValue(
        "stat-origin-list",
        serializeSingleSelect("opt-noble"),
        variant: 1,
      ),
      statValue("stat-future", '{"cells": []}'),
    ];

    for (final skin in skins) {
      testWidgets('$skin: the new types fit without overflow', (tester) async {
        await usePhoneSize(tester);

        for (final summaryVariant in [0, 1, 2, 3]) {
          await pumpSheet(
            tester,
            config: config(),
            values: values(summaryVariant: summaryVariant),
            skinId: skin,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'summary variant $summaryVariant',
          );
        }

        expect(find.byType(CheckboxTrackView), findsNWidgets(2));
        expect(find.byType(TextListView), findsOneWidget);
        expect(find.byType(SingleSelectView), findsNWidgets(2));
        expect(find.text(S.current.statTypeUnsupportedHint), findsOneWidget);
        expect(find.textContaining(S.current.levelAbbr), findsNothing);
        // Classic draws filled boxes, the decorated skins ink squares.
        final isClassic = skin.startsWith("classic");
        expect(
          find.descendant(
            of: find.byKey(CheckboxTrackView.boxKey(0)).first,
            matching: find.byType(AnimatedContainer),
          ),
          isClassic ? findsOneWidget : findsNothing,
        );

        // Ticking still works in this skin.
        await tap(tester, find.byKey(CheckboxTrackView.boxKey(19)).first);
        expect(tester.takeException(), isNull);
      });

      testWidgets('$skin: with level, the summary fits as before', (
        tester,
      ) async {
        await usePhoneSize(tester);

        for (final summaryVariant in [0, 1, 2, 3]) {
          await pumpSheet(
            tester,
            config: config(showLevel: true),
            values: values(summaryVariant: summaryVariant),
            skinId: skin,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'summary variant $summaryVariant',
          );
          expect(find.textContaining("$summaryLevel"), findsWidgets);
        }
      });
    }
  });
}

/// Holds the character like the player page: a changed stat value replaces
/// the old one and the sheet rebuilds with it.
class _SheetHost extends StatefulWidget {
  const _SheetHost({
    super.key,
    required this.config,
    required this.character,
    required this.readOnly,
    required this.onSaved,
  });

  final RpgConfigurationModel config;
  final RpgCharacterConfiguration character;
  final bool readOnly;
  final void Function(RpgCharacterStatValue) onSaved;

  @override
  State<_SheetHost> createState() => _SheetHostState();
}

class _SheetHostState extends State<_SheetHost> {
  late RpgCharacterConfiguration character = widget.character;

  @override
  Widget build(BuildContext context) {
    return PlayerScreenCharacterStatsForTab(
      tabDef: widget.config.characterStatTabsDefinition!.single,
      rpgConfig: widget.config,
      charToRender: character,
      readOnly: widget.readOnly,
      onStatValueChanged: (value) {
        widget.onSaved(value);
        setState(() {
          character = character.copyWith(
            characterStats: [
              for (final stat in character.characterStats)
                stat.statUuid == value.statUuid ? value : stat,
            ],
          );
        });
      },
    );
  }
}
