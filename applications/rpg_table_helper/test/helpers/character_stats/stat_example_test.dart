import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/player_stats_configuration_visuals.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:quest_keeper/helpers/character_stats/show_template_update_picker.dart';
import 'package:quest_keeper/helpers/character_stats/stat_example.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/helpers/character_stats/template_update.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// Text properties can have an example answer; the character form shows it
/// grey in the empty field ("z. B. …").
void main() {
  CharacterStatDefinition text({
    String? additionalData,
    CharacterStatValueType type = CharacterStatValueType.multiLineText,
  }) => CharacterStatDefinition(
    statUuid: 'origin',
    name: 'Herkunft',
    helperText: 'Wo kommt dein Charakter her?',
    groupId: null,
    valueType: type,
    editType: CharacterStatEditType.static,
    isOptionalForAlternateForms: false,
    isOptionalForCompanionCharacters: false,
    jsonSerializedAdditionalData: additionalData,
  );

  group('the example of a property', () {
    test('is read from the additional data', () {
      expect(
        statExampleOf(text(additionalData: '{"example": " Ein Dorf. "}')),
        'Ein Dorf.',
      );
      expect(
        statExampleOf(text(
          type: CharacterStatValueType.singleImage,
          additionalData: statExampleAdditionalData('Rote Zöpfe'),
        )),
        'Rote Zöpfe',
      );
    });

    test('is none without one, when blank, broken or for other types', () {
      expect(statExampleOf(text()), isNull);
      expect(statExampleOf(text(additionalData: '{"example": "  "}')), isNull);
      expect(statExampleOf(text(additionalData: '{"example": 3}')), isNull);
      expect(statExampleOf(text(additionalData: 'kein json')), isNull);
      expect(
        statExampleOf(text(
          type: CharacterStatValueType.multiselect,
          additionalData: '{"example": "Ein Dorf."}',
        )),
        isNull,
      );
      expect(statExampleAdditionalData('   '), isNull);
    });

    test('every text property of the templates has one', () {
      for (final id in RpgConfigurationTemplates.ids) {
        for (final stat in StatNumbers.allStats(
            RpgConfigurationTemplates.build(id))) {
          if (!statTypesWithExample.contains(stat.valueType)) continue;
          expect(statExampleOf(stat), isNotNull, reason: '$id ${stat.name}');
        }
      }
    });
  });

  test('the template update offers a new example by name', () async {
    final template = RpgConfigurationTemplates.fantasySrd();
    // A campaign from before the examples.
    final old = template.copyWith(characterStatTabsDefinition: [
      for (final tab in template.characterStatTabsDefinition!)
        tab.copyWith(statsInTab: [
          for (final stat in tab.statsInTab)
            statExampleOf(stat) == null
                ? stat
                : CharacterStatDefinition.fromJson({
                    ...stat.toJson(),
                    'jsonSerializedAdditionalData': null,
                  }),
        ]),
    ]);

    final update = templateUpdateFor(old)!;
    expect(update.changes, hasLength(8));
    final origin =
        update.changes.singleWhere((c) => c.updated.name == 'Herkunft');
    expect(origin.exampleChanged, isTrue);
    expect(origin.otherSettingsChanged, isFalse);
    expect(origin.nameChanged, isFalse);

    final s = await S.load(const Locale('de'));
    expect(describeTemplateStatChange(s, origin), 'Neue Beispielantwort');

    final next = applyTemplateUpdate(old, update, update.allIds);
    expect(templateUpdateFor(next), isNull);
  });

  testWidgets('the form shows the example in the empty field',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      CustomThemeProvider(
        overrideBrightness: Brightness.light,
        child: ProviderScope(
          overrides: [
            rpgCharacterConfigurationProvider.overrideWith((ref) =>
                RpgCharacterConfigurationNotifier(
                  decks: AsyncValue.data(
                      RpgCharacterConfiguration.getBaseConfiguration(null)),
                  ref: ref,
                  runningInTests: true,
                )),
          ],
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              locale: const Locale('de'),
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: PlayerStatsConfigurationVisuals(
                    statConfiguration: text(
                      additionalData:
                          statExampleAdditionalData('Ein Fischerdorf.'),
                    ),
                    characterName: 'Mira',
                    characterToRenderStatFor: null,
                    onNewStatValue: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.hintText, 'z. B. Ein Fischerdorf.');
    expect(field.decoration!.floatingLabelBehavior,
        FloatingLabelBehavior.always,
        reason: 'visible before the field is tapped');
    expect(field.decoration!.helperText, 'Wo kommt dein Charakter her?');
    expect(find.text('z. B. Ein Fischerdorf.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Aus dem Norden.');
    await tester.pumpAndSettle();
    expect(find.text('Aus dem Norden.'), findsOneWidget);
  });

  group('the property editor', () {
    Future<Future<CharacterStatDefinition?> Function()> open(
      WidgetTester tester,
      CharacterStatDefinition stat,
    ) async {
      CharacterStatDefinition? saved;
      var done = false;
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
                            saved = await showGetDmConfigurationModal(
                              context: context,
                              predefinedConfiguration: stat,
                            );
                            done = true;
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
      return () async {
        expect(done, isTrue);
        return saved;
      };
    }

    // The modal's shadow draws the content a second time: the last is real.
    Finder exampleField() => find
        .descendant(
          of: find.byKey(const ValueKey('propertyExampleField')),
          matching: find.byType(TextField),
        )
        .last;

    Future<void> save(WidgetTester tester) async {
      final button = find.text(S.current.save).last;
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('loads and saves the example', (tester) async {
      final result = await open(
        tester,
        text(additionalData: statExampleAdditionalData('Ein Fischerdorf.')),
      );
      expect(tester.widget<TextField>(exampleField()).controller!.text,
          'Ein Fischerdorf.');

      await tester.ensureVisible(exampleField());
      await tester.enterText(exampleField(), 'Eine Bergstadt.');
      await tester.pumpAndSettle();
      await save(tester);

      final saved = (await result())!;
      expect(statExampleOf(saved), 'Eine Bergstadt.');
      expect(saved.name, 'Herkunft');
      expect(jsonDecode(saved.jsonSerializedAdditionalData!),
          {'example': 'Eine Bergstadt.'});
      expect(tester.takeException(), isNull);
    });

    testWidgets('an emptied example is gone', (tester) async {
      final result = await open(
        tester,
        text(additionalData: statExampleAdditionalData('Ein Fischerdorf.')),
      );
      await tester.ensureVisible(exampleField());
      await tester.enterText(exampleField(), '');
      await tester.pumpAndSettle();
      await save(tester);

      final saved = (await result())!;
      expect(statExampleOf(saved), isNull);
      expect(saved.jsonSerializedAdditionalData, isNull);
    });

    testWidgets('only text and portrait properties have the field',
        (tester) async {
      await open(
        tester,
        text(type: CharacterStatValueType.intWithMaxValue),
      );
      expect(find.byKey(const ValueKey('propertyExampleField')), findsNothing);
    });
  });
}
