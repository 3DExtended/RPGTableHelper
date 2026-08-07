import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../../custom_font_loader.dart';
import '../../../test_configuration.dart';

const _stepNames = [
  'appearance',
  'campaign-name',
  'character-stats',
  'fight-initiative',
  'currencies',
  'item-locations',
  'item-categories',
  'items',
  'recipes',
];

void main() {
  final config = allWizardConfigurations['/rpgconfigurationwizard']!;

  group('night cartographer dm wizard steps', () {
    for (var i = 0; i < config.stepBuilders.length; i++) {
      final stepName = _stepNames[i];
      testConfigurations(
        disableLocals: true,
        disableDarkMode: true,
        pathPrefix: "../../",
        overrideSkinId: CharacterSheetSkinIds.nightCartographer,
        devices: testDevicesLedger,
        widgetName: 'night-cartographer-dm-wizard-step-$i-$stepName',
        useMaterialAppWrapper: true,
        testerInteractions: (tester, local) async {
          await tester.pumpAndSettle();
          await customLoadAppFonts();
          await customLoadAppFonts();
          await tester.pumpAndSettle();
          await customLoadAppFonts();
          await tester.pumpAndSettle();
        },
        screenFactory: (Locale locale, Brightness brightnessToTest) =>
            ProviderScope(
          overrides: [
            rpgCharacterConfigurationProvider.overrideWith((ref) {
              return RpgCharacterConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgCharacterConfiguration.getBaseConfiguration(null),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
            rpgConfigurationProvider.overrideWith((ref) {
              return RpgConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgConfigurationModel.getBaseConfiguration().copyWith(
                    defaultSkinId: CharacterSheetSkinIds.nightCartographer,
                  ),
                ),
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
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: ThemeMode.dark,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
                fontFamily: 'Ruwudu',
                useMaterial3: true,
              ),
              home: CustomThemeProvider(
                overrideBrightness: Brightness.dark,
                overrideSkinId: CharacterSheetSkinIds.nightCartographer,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: WizardRendererForConfiguration(
                    configuration: config,
                    startStepIndex: i,
                  ),
                ),
              ),
            ),
          ),
        ),
        getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
            Map.fromEntries([
          MapEntry(
            'night_cartographer',
            CustomThemeProvider(
              overrideBrightness: Brightness.dark,
              overrideSkinId: CharacterSheetSkinIds.nightCartographer,
              child: DependencyProvider.getMockedDependecyProvider(
                child: Center(child: widgetToTest),
              ),
            ),
          ),
        ]),
      );
    }
  });
}
