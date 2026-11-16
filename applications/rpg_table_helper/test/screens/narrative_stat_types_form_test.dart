import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/stat_types/checkbox_track_view.dart';
import 'package:quest_keeper/components/stat_types/single_select_view.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/character_stats_form_pages.dart';
import 'package:quest_keeper/helpers/character_stats/show_character_stats_form.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../components/character_stats_value_types/narrative_stat_fixtures.dart';
import '../custom_font_loader.dart';

/// The character form asks for the checkboxTrack, textList and singleSelect
/// types, and asks for the level only while the DM shows it.
///
/// Modals draw their content twice (the blurred shadow copy behind the real
/// one), so taps go to the last (top) match.
void main() {
  RpgCharacterConfiguration newCharacter() => characterWith(const []);

  Widget buildHarness({
    required RpgConfigurationModel config,
    required GlobalKey<NavigatorState> navigatorKey,
    required Future<void> Function(BuildContext context) onPressed,
  }) {
    return CustomThemeProvider(
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
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () => onPressed(context),
                      child: const Text('open'),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Opens the setup form of a new character at iPhone size.
  Future<
    ({
      List<CharacterStatsFormPage> pages,
      List<RpgCharacterStatValue> Function() stored,
      CharacterStatsFormOutcome? Function() outcome,
    })
  >
  openSetupForm(
    WidgetTester tester, {
    required RpgConfigurationModel config,
    Map<String, RpgCharacterStatValue> initialValues = const {},
  }) async {
    // Real fonts: the test font draws every glyph as a wide square.
    await customLoadAppFonts();
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final navigatorKey = GlobalKey<NavigatorState>();
    final pages = buildCharacterStatsFormPages(
      rpgConfig: config,
      character: newCharacter(),
      isCompanion: false,
    );
    final persisted = <List<RpgCharacterStatValue>>[];
    CharacterStatsFormOutcome? outcome;

    await tester.pumpWidget(
      buildHarness(
        config: config,
        navigatorKey: navigatorKey,
        onPressed: (context) async {
          outcome = await showCharacterStatsForm(
            context: context,
            pages: pages,
            mode: CharacterStatsFormMode.setup,
            characterName: 'Mira Dornwald',
            initialValues: initialValues,
            characterToRenderStatFor: newCharacter(),
            isEditingAlternateForm: false,
            overrideNavigatorKey: navigatorKey,
            onPersist: (stats, name) => persisted.add(List.of(stats)),
          );
        },
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return (
      pages: pages,
      stored: () => persisted.expand((p) => p).toList(),
      outcome: () => outcome,
    );
  }

  Future<void> tapReal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder.last);
    await tester.pumpAndSettle();
    await tester.tap(finder.last);
    await tester.pumpAndSettle();
  }

  /// Types into [field] (a text field or a widget holding one).
  Future<void> enterReal(WidgetTester tester, Finder field, String text) async {
    final textField = find.descendant(
      of: field.last,
      matching: find.byType(TextField),
      matchRoot: true,
    );
    await tester.ensureVisible(textField);
    await tester.pumpAndSettle();
    await tester.enterText(textField, text);
    await tester.pump();
  }

  Finder levelField() => find.widgetWithText(TextField, S.current.level);

  RpgCharacterStatValue storedValue(
    List<RpgCharacterStatValue> stored,
    String statUuid,
  ) => stored.lastWhere((s) => s.statUuid == statUuid);

  List<String> ownEntryUuids(WidgetTester tester) {
    const prefix = 'text-list-own-entry-delete-';
    return tester
        .widgetList(
          find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key as ValueKey<String>).value.startsWith(prefix),
          ),
        )
        .map((w) => (w.key as ValueKey<String>).value.substring(prefix.length))
        .toSet()
        .toList();
  }

  testWidgets('asks for the new types and stores them in their formats', (
    tester,
  ) async {
    final form = await openSetupForm(
      tester,
      config: configWithStoryTab([
        characterSummary(showLevel: false),
        stressTrack,
        aspects,
        origin,
        futureStat,
      ]),
    );
    expect(tester.takeException(), isNull);

    // One page with every new type; a type of a newer version is not asked.
    expect(form.pages, hasLength(1));
    expect(form.pages.single.stats.map((s) => s.statUuid), [
      "stat-summary",
      "stat-stress",
      "stat-aspects",
      "stat-origin",
    ]);
    for (final name in ["Stress", "Aspekte", "Herkunft"]) {
      expect(find.text(name), findsWidgets, reason: '$name is asked');
    }
    expect(find.text(S.current.statTypeUnsupportedHint), findsNothing);
    expect(levelField(), findsNothing, reason: 'the DM hid the level');

    await enterReal(
      tester,
      find.widgetWithText(TextField, "Rolle"),
      "Fahrende Ritterin",
    );

    // Checkbox track: a tap ticks a box.
    await tapReal(tester, find.byKey(CheckboxTrackView.boxKey(2)));

    // Text list: fixed slot, then two own entries of which one is deleted.
    await enterReal(
      tester,
      find.byKey(const ValueKey('text-list-slot-field-slot-concept')),
      "Ritterin ohne Pferd",
    );
    await tapReal(
      tester,
      find.byKey(const ValueKey('text-list-add-own-entry')),
    );
    await tapReal(
      tester,
      find.byKey(const ValueKey('text-list-add-own-entry')),
    );
    final own = ownEntryUuids(tester);
    expect(own, hasLength(2));
    await enterReal(
      tester,
      find.byKey(ValueKey('text-list-own-entry-${own[0]}')),
      "Wird gleich gelöscht",
    );
    await enterReal(
      tester,
      find.byKey(ValueKey('text-list-own-entry-${own[1]}')),
      "Schuldet der Gilde Geld",
    );
    await tapReal(
      tester,
      find.byKey(ValueKey('text-list-own-entry-delete-${own[0]}')),
    );
    expect(ownEntryUuids(tester), [own[1]]);

    // Single select: the second choice replaces the first.
    await tapReal(
      tester,
      find.byKey(SingleSelectOptionTile.keyFor("opt-noble")),
    );
    await tapReal(
      tester,
      find.byKey(SingleSelectOptionTile.keyFor("opt-street")),
    );
    expect(tester.takeException(), isNull);

    await tapReal(tester, find.text(S.current.characterSetupFinish));
    expect(form.outcome(), CharacterStatsFormOutcome.completed);

    final stored = form.stored();
    expect(jsonDecode(storedValue(stored, "stat-stress").serializedValue), {
      "checked": [2],
    });
    expect(jsonDecode(storedValue(stored, "stat-aspects").serializedValue), {
      "values": [
        {"uuid": "slot-concept", "value": "Ritterin ohne Pferd"},
        {"uuid": "slot-trouble", "value": ""},
        {"uuid": own[1], "value": "Schuldet der Gilde Geld"},
      ],
    });
    expect(jsonDecode(storedValue(stored, "stat-origin").serializedValue), {
      "value": "opt-street",
    });
    expect(stored.where((s) => s.statUuid == "stat-future"), isEmpty);

    final summary = jsonDecode(
      storedValue(stored, "stat-summary").serializedValue,
    );
    expect(summary["values"], [
      {"uuid": "detail-role", "value": "Fahrende Ritterin"},
      {"uuid": "detail-folk", "value": ""},
    ]);
    expect(summary["level"], 1, reason: 'still written for older app versions');
  });

  testWidgets('a hidden level keeps the level stored before', (tester) async {
    final form = await openSetupForm(
      tester,
      config: configWithStoryTab([characterSummary(showLevel: false)]),
      initialValues: {"stat-summary": summaryValue()},
    );
    expect(levelField(), findsNothing);

    await tapReal(tester, find.text(S.current.characterSetupFinish));

    final summary = jsonDecode(
      storedValue(form.stored(), "stat-summary").serializedValue,
    );
    expect(summary["level"], summaryLevel);
  });

  testWidgets('with the level shown the form asks for it as before', (
    tester,
  ) async {
    final form = await openSetupForm(
      tester,
      config: configWithStoryTab([characterSummary(showLevel: true)]),
    );
    expect(levelField(), findsWidgets);

    await enterReal(tester, levelField(), "4");
    await tapReal(tester, find.text(S.current.characterSetupFinish));

    final summary = jsonDecode(
      storedValue(form.stored(), "stat-summary").serializedValue,
    );
    expect(summary["level"], 4);
  });
}
