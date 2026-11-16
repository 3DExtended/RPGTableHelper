import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/sheet_building_blocks.dart';
import 'package:quest_keeper/helpers/character_stats/show_building_block_picker.dart';
import 'package:quest_keeper/helpers/character_stats/show_property_purpose_picker.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// Properties of the templates as ready-made building blocks for any sheet.
///
/// The modal's shadow draws its content a second time; use the real one.
Finder real(Finder finder) => finder.last;

void main() {
  final blocks = sheetBuildingBlocks();
  SheetBuildingBlock named(RpgConfigurationTemplateId template, String name) =>
      blocks.firstWhere((b) => b.template == template && b.stat.name == name);

  group('blocks', () {
    test('every property of the templates but "Leer", once', () {
      final expected = [
        for (final id in [
          RpgConfigurationTemplateId.fantasySrd,
          RpgConfigurationTemplateId.narrative,
        ])
          ...StatNumbers.allStats(RpgConfigurationTemplates.build(id))
              .map((s) => s.statUuid),
      ];
      expect(blocks.map((b) => b.stat.statUuid), expected);
      expect(expected.toSet(), hasLength(expected.length));
    });

    test('a block keeps its template property, uuid included', () {
      final hp = named(RpgConfigurationTemplateId.fantasySrd, 'TP');
      final template = StatNumbers.allStats(RpgConfigurationTemplates.fantasySrd())
          .firstWhere((s) => s.name == 'TP');
      expect(jsonEncode(hp.stat), jsonEncode(template));
      expect(hp.tabName, 'Werte');
    });

    test('already on the sheet: the same property or a second summary', () {
      final hp = named(RpgConfigurationTemplateId.fantasySrd, 'TP');
      final summary =
          named(RpgConfigurationTemplateId.narrative, 'Grundwerte');
      final ownSheet = StatNumbers.allStats(RpgConfigurationTemplates.empty());

      expect(hp.isOn(ownSheet), isFalse);
      expect(hp.isOn([...ownSheet, hp.stat]), isTrue);
      // "Leer" has its own name and level.
      expect(summary.isOn(ownSheet), isTrue);
      expect(summary.isOn(const []), isFalse);
    });

    for (final locale in AppLocalizations.supportedLocales) {
      test('every block says what kind of property it is ($locale)',
          () async {
        final s = await S.load(locale);
        for (final block in blocks) {
          expect(block.kind(s), isNotEmpty, reason: block.stat.name);
        }
      });
    }
  });

  Future<Future<List<CharacterStatDefinition>> Function()> pumpAndOpen(
    WidgetTester tester, {
    List<CharacterStatDefinition> onSheet = const [],
  }) async {
    List<CharacterStatDefinition>? added;
    tester.view.physicalSize = const Size(1200, 2400) * 3;
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
              locale: const Locale('de'),
              supportedLocales: AppLocalizations.supportedLocales,
              home: CustomThemeProvider(
                child: DependencyProvider.getMockedDependecyProvider(
                  child: Scaffold(
                    body: Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: () async {
                          added = await showNewPropertyEditor(
                            context: context,
                            availableStats: [
                              for (final stat in onSheet)
                                (tabName: 'Werte', stat: stat),
                            ],
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
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(real(find.byKey(PropertyPurposePicker.buildingBlocksKey)));
    await tester.pumpAndSettle();
    return () async {
      expect(added, isNotNull, reason: 'the pickers are closed');
      return added!;
    };
  }

  Future<void> tapReal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(real(finder));
    await tester.pumpAndSettle();
    await tester.tap(real(finder));
    await tester.pumpAndSettle();
  }

  Finder tile(SheetBuildingBlock block) =>
      find.byKey(BuildingBlockPicker.keyFor(block.stat.statUuid));

  testWidgets('ticked blocks are added in template order', (tester) async {
    final result = await pumpAndOpen(tester);
    final stress = named(RpgConfigurationTemplateId.narrative, 'Stress');
    final abilities = named(RpgConfigurationTemplateId.fantasySrd, 'Attribute');

    expect(find.text(S.current.wizardTemplateFantasyName), findsWidgets);
    expect(find.text(S.current.wizardTemplateNarrativeName), findsWidgets);
    expect(find.text(S.current.wizardTemplateEmptyName), findsNothing);

    await tapReal(tester, tile(stress));
    await tapReal(tester, tile(abilities));
    await tapReal(tester, tile(stress));
    await tapReal(tester, tile(stress));
    expect(find.text(S.current.buildingBlocksAddCount(2)), findsWidgets);

    await tapReal(tester, find.text(S.current.buildingBlocksAddCount(2)));
    final added = await result();
    expect(added.map((s) => s.statUuid),
        [abilities.stat.statUuid, stress.stat.statUuid]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('what the sheet has cannot be ticked', (tester) async {
    final hp = named(RpgConfigurationTemplateId.fantasySrd, 'TP');
    final result = await pumpAndOpen(tester, onSheet: [hp.stat]);

    expect(
      find.descendant(
        of: real(tile(hp)),
        matching: find.textContaining(S.current.buildingBlocksAlreadyOnSheet),
      ),
      findsOneWidget,
    );
    await tapReal(tester, tile(hp));
    expect(find.text(S.current.buildingBlocksAdd), findsWidgets,
        reason: 'nothing ticked');

    // Nothing to add: the button does nothing.
    await tapReal(tester, find.text(S.current.buildingBlocksAdd));
    expect(find.byType(BuildingBlockPicker), findsWidgets);

    await tapReal(tester, find.text(S.current.cancel));
    expect(await result(), isEmpty);
  });
}
