import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/character_portrait.dart';
import 'package:quest_keeper/helpers/character_stats/player_stats_configuration_visuals.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// One image picker per character: the portrait of "Grundwerte" is only
/// asked for when the sheet has no image property of its own.
void main() {
  CharacterStatDefinition summaryOf(RpgConfigurationModel config) =>
      config.characterStatTabsDefinition!
          .expand((t) => t.statsInTab)
          .firstWhere((s) =>
              s.valueType ==
              CharacterStatValueType.characterNameWithLevelAndAdditionalDetails);

  group('sheetHasImageProperty', () {
    test('the templates with an image property', () {
      expect(sheetHasImageProperty(RpgConfigurationTemplates.fantasySrd()),
          isTrue);
      expect(
          sheetHasImageProperty(RpgConfigurationTemplates.narrative()), isTrue);
    });

    test('"Leer" has none, nor does an unknown configuration', () {
      expect(sheetHasImageProperty(RpgConfigurationTemplates.empty()), isFalse);
      expect(sheetHasImageProperty(null), isFalse);
    });
  });

  test('a sheet without image property shows the summary portrait on cards',
      () {
    final config = RpgConfigurationTemplates.empty();
    final character = RpgCharacterConfiguration.getBaseConfiguration(config)
        .copyWith(characterStats: [
      RpgCharacterStatValue(
        statUuid: summaryOf(config).statUuid,
        serializedValue: jsonEncode({
          "level": 1,
          "values": [],
          "imageUrl": "images/portrait.png",
        }),
        variant: null,
        hideFromCharacterScreen: false,
        hideLabelOfStat: false,
      ),
    ]);

    expect(character.getImageUrlWithoutBasePath(config), "images/portrait.png");
  });

  Future<void> pumpSummaryForm(
    WidgetTester tester,
    RpgConfigurationModel config,
  ) async {
    tester.view.physicalSize = const Size(2048, 2732);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      CustomThemeProvider(
        overrideBrightness: Brightness.light,
        child: ProviderScope(
          overrides: [
            rpgConfigurationProvider.overrideWith((ref) =>
                RpgConfigurationNotifier(
                  decks: AsyncValue.data(config),
                  ref: ref,
                  runningInTests: true,
                )),
            rpgCharacterConfigurationProvider.overrideWith((ref) =>
                RpgCharacterConfigurationNotifier(
                  decks: AsyncValue.data(
                      RpgCharacterConfiguration.getBaseConfiguration(config)),
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
                    statConfiguration: summaryOf(config),
                    characterName: 'Mira',
                    characterToRenderStatFor: null,
                    onNewStatValue: (_) {},
                    hideVariantSelection: true,
                    hideAdditionalSetting: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the form asks for the portrait on a sheet without image',
      (tester) async {
    await pumpSummaryForm(tester, RpgConfigurationTemplates.empty());

    expect(find.text('Porträtbeschreibung'), findsOneWidget);
  });

  testWidgets('the form leaves the portrait to the image property',
      (tester) async {
    await pumpSummaryForm(tester, RpgConfigurationTemplates.narrative());

    expect(find.text('Porträtbeschreibung'), findsNothing);
  });
}
