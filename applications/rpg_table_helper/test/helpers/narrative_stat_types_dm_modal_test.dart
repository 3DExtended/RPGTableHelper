import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../components/character_stats_value_types/narrative_stat_fixtures.dart';
import '../custom_font_loader.dart';

/// The DM sets up the checkboxTrack, textList and singleSelect types and the
/// "show level" switch of the character summary.
///
/// The modal's shadow draws its content a second time; use the real one.
Finder real(Finder finder) => finder.last;

void main() {
  Future<Future<CharacterStatDefinition?> Function()> openModal(
    WidgetTester tester,
    CharacterStatDefinition stat, {
    Size size = const Size(1200, 2400),
  }) async {
    CharacterStatDefinition? saved;
    var done = false;
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: CustomThemeProvider(
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale("de"),
              supportedLocales: AppLocalizations.supportedLocales,
              home: CustomThemeProvider(
                child: DependencyProvider.getMockedDependecyProvider(
                  child: Scaffold(
                    body: Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: () async {
                          saved = await showGetDmConfigurationModal(
                            context: context,
                            predefinedConfiguration: stat,
                          );
                          done = true;
                        },
                        child: const Text("open"),
                      ),
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
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
    return () async {
      expect(done, isTrue);
      return saved;
    };
  }

  Future<void> tapReal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(real(finder));
    await tester.pumpAndSettle();
    await tester.tap(real(finder));
    await tester.pumpAndSettle();
  }

  /// A [SelectableTile] switches with its box button.
  Future<void> toggleTile(WidgetTester tester, String key) => tapReal(
    tester,
    find.descendant(
      of: real(find.byKey(ValueKey(key))),
      matching: find.byType(CustomButton),
    ),
  );

  Future<void> enterReal(WidgetTester tester, Finder field, String text) async {
    final textField = find.descendant(
      of: real(field),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(textField);
    await tester.pumpAndSettle();
    await tester.enterText(textField, text);
    await tester.pump();
  }

  Future<CharacterStatDefinition> save(
    WidgetTester tester,
    Future<CharacterStatDefinition?> Function() result,
  ) async {
    await tapReal(tester, find.text("Speichern"));
    return (await result())!;
  }

  Map<String, dynamic> additionalDataOf(CharacterStatDefinition stat) =>
      jsonDecode(stat.jsonSerializedAdditionalData!) as Map<String, dynamic>;

  testWidgets('the type picker offers the new types with a short help', (
    tester,
  ) async {
    final result = await openModal(
      tester,
      narrativeStat(
        uuid: "new-stat",
        name: "Stress",
        type: CharacterStatValueType.int,
      ),
    );

    await tapReal(tester, find.text(S.current.integerValue));
    for (final label in [
      S.current.statTypeCheckboxTrack,
      S.current.statTypeTextList,
      S.current.statTypeSingleSelect,
    ]) {
      expect(find.text(label), findsWidgets, reason: '$label is offered');
    }
    expect(
      find.textContaining(S.current.statTypeUnsupported),
      findsNothing,
      reason: 'the placeholder for unknown types is never offered',
    );

    await tapReal(tester, find.text(S.current.statTypeCheckboxTrack));
    expect(find.text(S.current.statTypeCheckboxTrackHelp), findsWidgets);
    expect(find.byKey(const ValueKey("checkboxTrackBoxCount")), findsWidgets);

    final saved = await save(tester, result);
    expect(saved.valueType, CharacterStatValueType.checkboxTrack);
    expect(additionalDataOf(saved), {
      "boxCount": CheckboxTrackConfig.defaultBoxCount,
    });
  });

  testWidgets('checkbox track: number of boxes and their labels', (
    tester,
  ) async {
    final result = await openModal(tester, stressTrack);
    expect(find.text(S.current.statTypeCheckboxTrackHelp), findsWidgets);

    await tapReal(
      tester,
      find.descendant(
        of: real(find.byKey(const ValueKey("checkboxTrackBoxCount"))),
        matching: find.byIcon(FontAwesomeIcons.plus.data),
      ),
    );
    await enterReal(
      tester,
      find.byKey(const ValueKey("checkboxTrackLabel-4")),
      "Raus",
    );

    final saved = await save(tester, result);
    expect(additionalDataOf(saved), {
      "boxCount": 5,
      "labels": ["1", "2", "3", "Ausgeschaltet", "Raus"],
    });
  });

  testWidgets('text list: fixed slots and whether own entries are allowed', (
    tester,
  ) async {
    final result = await openModal(
      tester,
      narrativeStat(
        uuid: "stat-aspects",
        name: "Aspekte",
        type: CharacterStatValueType.textList,
      ),
    );
    expect(find.text(S.current.statTypeTextListHelp), findsWidgets);

    await tapReal(tester, find.byKey(const ValueKey("textListAddSlot")));
    await tapReal(tester, find.byKey(const ValueKey("textListAddSlot")));
    await enterReal(
      tester,
      find.byKey(const ValueKey("textListSlot-0")),
      "Hauptaspekt",
    );
    await enterReal(
      tester,
      find.byKey(const ValueKey("textListSlot-1")),
      "Dilemma",
    );
    await toggleTile(tester, "textListAllowCustomEntriesToggle");

    final saved = await save(tester, result);
    final config = TextListConfig.of(saved);
    expect(config.slots.map((s) => s.label), ["Hauptaspekt", "Dilemma"]);
    expect(config.slots.map((s) => s.uuid).toSet(), hasLength(2));
    expect(config.slots.every((s) => s.uuid.isNotEmpty), isTrue);
    expect(config.allowCustomEntries, isFalse);
    expect(additionalDataOf(saved)["allowCustomEntries"], isFalse);
  });

  testWidgets('single select: options are set up like a multiselect', (
    tester,
  ) async {
    final result = await openModal(tester, origin);
    expect(find.text(S.current.statTypeSingleSelectHelp), findsWidgets);
    expect(find.text(S.current.singleSelectOptionsHeadline), findsWidgets);

    final saved = await save(tester, result);
    expect(saved.valueType, CharacterStatValueType.singleSelect);
    expect(selectOptionsOf(saved).map((o) => "${o.uuid}=${o.label}"), [
      "opt-noble=Adel",
      "opt-street=Gosse",
    ]);
    expect(
      selectOptionsOf(saved).first.description,
      startsWith("Aus gutem Hause"),
    );
  });

  testWidgets('the level of the character summary can be switched off', (
    tester,
  ) async {
    var result = await openModal(tester, characterSummary(showLevel: true));
    await toggleTile(tester, "showLevelToggle");
    final hidden = await save(tester, result);

    expect(characterSummaryShowsLevel(hidden), isFalse);
    expect(additionalDataOf(hidden)["showLevel"], isFalse);
    expect(
      (additionalDataOf(hidden)["values"] as List).map((v) => v["label"]),
      ["Rolle", "Volk"],
    );

    // Switched on again, the configuration looks like before the switch.
    result = await openModal(tester, hidden);
    await toggleTile(tester, "showLevelToggle");
    final shown = await save(tester, result);
    expect(characterSummaryShowsLevel(shown), isTrue);
    expect(additionalDataOf(shown).containsKey("showLevel"), isFalse);
  });

  testWidgets('the setup of every new type fits at iPhone width', (
    tester,
  ) async {
    // Real fonts: the test font draws every glyph as a wide square.
    await customLoadAppFonts();
    for (final stat in [
      stressTrack,
      aspects,
      origin,
      characterSummary(showLevel: false),
      futureStat,
    ]) {
      await openModal(tester, stat, size: const Size(402, 874));
      expect(tester.takeException(), isNull, reason: stat.name);
    }
  });

  testWidgets('a type of a newer app version keeps its type when saved', (
    tester,
  ) async {
    final result = await openModal(tester, futureStat);
    expect(
      find.text("${S.current.statTypeUnsupported} (hexMap)"),
      findsWidgets,
    );
    expect(find.text(S.current.statTypeUnsupportedHint), findsWidgets);

    final saved = await save(tester, result);
    expect(saved.valueType, CharacterStatValueType.unsupported);
    expect(saved.toJson()["valueType"], "hexMap");
    expect(saved.jsonSerializedAdditionalData, '{"size": 7}');
  });
}
