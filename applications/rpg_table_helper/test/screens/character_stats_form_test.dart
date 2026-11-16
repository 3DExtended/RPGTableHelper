import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/character_stats_form_pages.dart';
import 'package:quest_keeper/helpers/character_stats/show_character_stats_form.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../custom_font_loader.dart';

/// The character form (SP-2): one page per sheet tab instead of one dialog
/// per field, with progress, "Fill in later" and validation.
///
/// Modals draw their content twice (the blurred shadow copy behind the real
/// one), so texts are found twice and taps go to the last (top) match.
void main() {
  final config = RpgConfigurationModel.getBaseConfiguration();
  final tabs = config.characterStatTabsDefinition!;
  final backgroundTab = tabs.firstWhere((t) => t.tabName == 'Hintergrund');
  final statsTab = tabs.firstWhere((t) => t.isDefaultTab);
  final summaryStat = statsTab.statsInTab.firstWhere(
    (s) =>
        s.valueType ==
        CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
  );

  RpgCharacterConfiguration newCharacter({String name = 'Mira Dornwald'}) =>
      RpgCharacterConfiguration.getBaseConfiguration(null)
          .copyWith(characterName: name, characterStats: []);

  Widget buildHarness({
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

  /// Opens the setup form for a new character in the D&D template.
  Future<
    ({
      List<CharacterStatsFormPage> pages,
      List<({List<RpgCharacterStatValue> stats, String? name})> persisted,
      CharacterStatsFormOutcome? Function() outcome,
    })
  >
  openSetupForm(
    WidgetTester tester, {
    Size? size,
    String name = 'Mira Dornwald',
  }) async {
    if (size != null) {
      // Real fonts: the test font draws every glyph as a wide square.
      await customLoadAppFonts();
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    final navigatorKey = GlobalKey<NavigatorState>();
    final pages = buildCharacterStatsFormPages(
      rpgConfig: config,
      character: newCharacter(name: name),
      isCompanion: false,
    );
    final persisted = <({List<RpgCharacterStatValue> stats, String? name})>[];
    CharacterStatsFormOutcome? outcome;

    await tester.pumpWidget(
      buildHarness(
        navigatorKey: navigatorKey,
        onPressed: (context) async {
          outcome = await showCharacterStatsForm(
            context: context,
            pages: pages,
            mode: CharacterStatsFormMode.setup,
            characterName: name,
            initialValues: const {},
            characterToRenderStatFor: newCharacter(name: name),
            isEditingAlternateForm: false,
            overrideNavigatorKey: navigatorKey,
            onPersist: (stats, name) =>
                persisted.add((stats: List.of(stats), name: name)),
          );
        },
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return (pages: pages, persisted: persisted, outcome: () => outcome);
  }

  Finder fieldLabelled(String label) =>
      find.widgetWithText(TextField, label).last;

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows one page per tab with progress', (tester) async {
    final form = await openSetupForm(tester);

    expect(
      form.pages.length,
      lessThan(10),
      reason: 'a handful of pages instead of ~30 dialogs',
    );
    expect(
      find.text(
        S.current.characterSetupProgress(1, form.pages.length, 'Hintergrund'),
      ),
      findsWidgets,
    );
    // All Background fields are on the first page at once.
    for (final stat in backgroundTab.statsInTab) {
      expect(
        find.widgetWithText(TextField, stat.name),
        findsWidgets,
        reason: '${stat.name} should be on the Background page',
      );
    }

    await tapText(tester, S.current.next);

    expect(
      find.text(
        S.current.characterSetupProgress(2, form.pages.length, 'Werte'),
      ),
      findsWidgets,
    );
  });

  testWidgets('"Next" stores the whole page, also fields left empty', (
    tester,
  ) async {
    final form = await openSetupForm(tester);

    await tester.enterText(fieldLabelled('Herkunft'), 'Aus dem Norden');
    await tester.pump();
    await tapText(tester, S.current.next);

    expect(form.persisted, hasLength(1));
    final stored = form.persisted.single.stats;
    expect(
      stored.map((s) => s.statUuid).toSet(),
      backgroundTab.statsInTab.map((s) => s.statUuid).toSet(),
    );
    final origin = stored.firstWhere(
      (s) =>
          s.statUuid ==
          backgroundTab.statsInTab
              .firstWhere((d) => d.name == 'Herkunft')
              .statUuid,
    );
    expect(jsonDecode(origin.serializedValue)['value'], 'Aus dem Norden');
  });

  testWidgets(
    '"Fill in later" keeps what was typed and leaves the rest missing',
    (tester) async {
      final form = await openSetupForm(tester);

      await tester.enterText(fieldLabelled('Herkunft'), 'Aus dem Norden');
      await tester.pump();
      await tapText(tester, S.current.fillInLater);

      expect(form.outcome(), CharacterStatsFormOutcome.filledInLater);
      expect(
        find.text(S.current.characterSetupTitle),
        findsNothing,
        reason: 'the form is closed',
      );

      // Only the typed field is stored ...
      expect(form.persisted, hasLength(1));
      final stored = form.persisted.single.stats;
      expect(stored, hasLength(1));
      expect(
        jsonDecode(stored.single.serializedValue)['value'],
        'Aus dem Norden',
      );

      // ... so the next form continues with the untouched fields.
      final character = newCharacter().copyWith(characterStats: stored);
      final nextPages = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: character,
        isCompanion: false,
      );
      expect(nextPages.first.tab!.uuid, backgroundTab.uuid);
      expect(
        nextPages.first.stats.map((s) => s.statUuid),
        isNot(contains(stored.single.statUuid)),
      );
      expect(
        nextPages.first.stats,
        hasLength(backgroundTab.statsInTab.length - 1),
      );
    },
  );

  testWidgets('"Cancel" keeps confirmed pages and drops the open page', (
    tester,
  ) async {
    final form = await openSetupForm(tester);

    await tapText(tester, S.current.next);
    expect(form.persisted, hasLength(1), reason: 'Background confirmed');

    await tester.enterText(fieldLabelled('Klasse'), 'Waldläuferin');
    await tester.pump();
    await tapText(tester, S.current.cancel);

    expect(form.outcome(), CharacterStatsFormOutcome.cancelled);
    expect(
      form.persisted,
      hasLength(1),
      reason: 'nothing of the cancelled page is stored',
    );
  });

  testWidgets('"Back" returns to the previous page with its values', (
    tester,
  ) async {
    final form = await openSetupForm(tester);

    await tester.enterText(fieldLabelled('Herkunft'), 'Aus dem Norden');
    await tester.pump();
    await tapText(tester, S.current.next);
    await tapText(tester, S.current.back);

    expect(
      find.text(
        S.current.characterSetupProgress(1, form.pages.length, 'Hintergrund'),
      ),
      findsWidgets,
    );
    expect(find.text('Aus dem Norden'), findsWidgets);
  });

  testWidgets('a level typed as text shows an error and blocks "Next"', (
    tester,
  ) async {
    final form = await openSetupForm(tester);
    await tapText(tester, S.current.next);
    form.persisted.clear();

    await tester.enterText(fieldLabelled('Level'), 'Waldläuferin');
    await tester.pumpAndSettle();

    expect(find.text(S.current.invalidLevelInput), findsWidgets);
    expect(find.text(S.current.fixMarkedFieldsHint), findsWidgets);

    await tapText(tester, S.current.next);
    expect(form.persisted, isEmpty, reason: 'nothing stored as level 0');
    expect(
      find.text(
        S.current.characterSetupProgress(2, form.pages.length, 'Werte'),
      ),
      findsWidgets,
      reason: 'still on the Stats page',
    );

    await tester.enterText(fieldLabelled('Level'), '4');
    await tester.pumpAndSettle();
    expect(find.text(S.current.invalidLevelInput), findsNothing);

    await tapText(tester, S.current.next);

    final summary = form.persisted
        .expand((p) => p.stats)
        .firstWhere((s) => s.statUuid == summaryStat.statUuid);
    expect(jsonDecode(summary.serializedValue)['level'], 4);
  });

  testWidgets('renders every page at iPhone width without overflow', (
    tester,
  ) async {
    final form = await openSetupForm(tester, size: const Size(402, 874));

    for (var i = 0; i < form.pages.length; i++) {
      expect(tester.takeException(), isNull);
      final isLast = i == form.pages.length - 1;
      await tapText(
        tester,
        isLast ? S.current.characterSetupFinish : S.current.next,
      );
    }

    expect(form.outcome(), CharacterStatsFormOutcome.completed);
    final storedUuids = form.persisted
        .expand((p) => p.stats)
        .map((s) => s.statUuid)
        .toSet();
    expect(
      storedUuids,
      form.pages.expand((p) => p.stats).map((s) => s.statUuid).toSet(),
    );
  });

  group('"Schnell starten"', () {
    final portraitStat = statsTab.statsInTab.firstWhere(
      (s) => s.valueType == CharacterStatValueType.singleImage,
    );

    List<CharacterStatsFormPage> setupPages({String name = 'Mira'}) =>
        buildCharacterStatsFormPages(
          rpgConfig: config,
          character: newCharacter(name: name),
          isCompanion: false,
        );

    test('asks for the summary and the portrait, from any page', () {
      final quick = quickStartPageOf(setupPages())!;
      expect(quick.stats.map((s) => s.statUuid), [
        summaryStat.statUuid,
        portraitStat.statUuid,
      ]);
      expect(quick.showNameField, isFalse);
      expect(quick.tab, isNull);

      expect(quickStartPageOf(setupPages(name: ''))!.showNameField, isTrue);
    });

    test('is not offered when it would save little or ask nothing', () {
      expect(quickStartPageOf(const []), isNull);

      // "Leer": the summary and a description, nothing to skip.
      final empty = RpgConfigurationTemplates.empty();
      expect(
        quickStartPageOf(buildCharacterStatsFormPages(
          rpgConfig: empty,
          character: newCharacter(),
          isCompanion: false,
        )),
        isNull,
      );

      // Summary and portrait filled in already, the name is there.
      final rest = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: newCharacter().copyWith(characterStats: [
          for (final stat in [summaryStat, portraitStat])
            RpgCharacterStatValue(
              statUuid: stat.statUuid,
              serializedValue: '{}',
              hideFromCharacterScreen: false,
              variant: 0,
              hideLabelOfStat: false,
            ),
        ]),
        isCompanion: false,
      );
      expect(rest, isNotEmpty);
      expect(quickStartPageOf(rest), isNull);
    });

    Future<void> startQuick(WidgetTester tester) async {
      final button = find.byKey(CharacterStatsFormContent.quickStartKey).last;
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('is the first choice on the first page only', (tester) async {
      final form = await openSetupForm(tester);
      expect(find.byKey(CharacterStatsFormContent.quickStartKey),
          findsWidgets);
      expect(
        find.textContaining(
          'Charakter-Zusammenfassung ${S.current.quickStartAnd} Porträt',
        ),
        findsWidgets,
        reason: 'says what it asks for',
      );

      await tapText(tester, S.current.next);
      expect(find.byKey(CharacterStatsFormContent.quickStartKey), findsNothing);
      await tapText(tester, S.current.back);
      expect(find.byKey(CharacterStatsFormContent.quickStartKey),
          findsWidgets);
      expect(form.persisted, hasLength(1));
    });

    testWidgets('stores the quick fields and what was typed, the rest stays '
        'open', (tester) async {
      final form = await openSetupForm(tester);
      await tester.enterText(fieldLabelled('Herkunft'), 'Aus dem Norden');
      await tester.pump();

      await startQuick(tester);
      expect(find.text(S.current.quickStartTitle), findsWidgets);
      expect(
        find.text(S.current.characterSetupProgress(
            1, form.pages.length, 'Hintergrund')),
        findsNothing,
      );
      expect(find.widgetWithText(TextField, 'Herkunft'), findsNothing);
      expect(find.widgetWithText(TextField, 'Level'), findsWidgets);
      expect(find.widgetWithText(TextField, 'Porträt'), findsWidgets);

      await tester.enterText(fieldLabelled('Level'), '3');
      await tester.pumpAndSettle();
      await tapText(tester, S.current.characterSetupFinish);

      expect(form.outcome(), CharacterStatsFormOutcome.filledInLater);
      final stored = form.persisted.expand((p) => p.stats).toList();
      expect(stored.map((s) => s.statUuid).toSet(), {
        summaryStat.statUuid,
        portraitStat.statUuid,
        backgroundTab.statsInTab
            .firstWhere((d) => d.name == 'Herkunft')
            .statUuid,
      });
      final summary =
          stored.firstWhere((s) => s.statUuid == summaryStat.statUuid);
      expect(jsonDecode(summary.serializedValue)['level'], 3);

      // The next form goes on with everything else.
      final next = buildCharacterStatsFormPages(
        rpgConfig: config,
        character: newCharacter().copyWith(characterStats: stored),
        isCompanion: false,
      );
      expect(next.expand((p) => p.stats), hasLength(
          form.pages.expand((p) => p.stats).length - 3));
    });

    testWidgets('asks for the name while it is missing', (tester) async {
      final form = await openSetupForm(tester, name: '');
      await startQuick(tester);

      final finish = find.text(S.current.characterSetupFinish).last;
      await tester.tap(finish);
      await tester.pumpAndSettle();
      expect(form.outcome(), isNull, reason: 'no name yet');

      await tester.enterText(fieldLabelled(S.current.characterName), 'Mira');
      await tester.pumpAndSettle();
      await tapText(tester, S.current.characterSetupFinish);
      expect(form.outcome(), CharacterStatsFormOutcome.filledInLater);
      expect(form.persisted.last.name, 'Mira');
    });

    testWidgets('"Alle Abschnitte" goes back to the sections', (tester) async {
      final form = await openSetupForm(tester);
      await startQuick(tester);

      final back = find.byKey(CharacterStatsFormContent.allSectionsKey).last;
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(
        find.text(S.current.characterSetupProgress(
            1, form.pages.length, 'Hintergrund')),
        findsWidgets,
      );
      expect(form.persisted, isEmpty);
    });

    testWidgets('fits at iPhone width', (tester) async {
      await openSetupForm(tester, size: const Size(402, 874), name: '');
      expect(tester.takeException(), isNull);
      await startQuick(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
