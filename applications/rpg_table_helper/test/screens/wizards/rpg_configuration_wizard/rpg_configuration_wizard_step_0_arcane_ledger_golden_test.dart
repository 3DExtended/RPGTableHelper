import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_0_character_sheet_skin.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../../custom_font_loader.dart';
import '../../../test_configuration.dart';

void main() {
  group('arcane ledger dm wizard appearance', () {
    testConfigurations(
      disableLocals: true,
      disableDarkMode: true,
      pathPrefix: "../../",
      overrideSkinId: CharacterSheetSkinIds.arcaneLedger,
      devices: testDevicesLedger,
      widgetName: 'arcane-ledger-dm-wizard-appearance',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) async {
        await tester.pumpAndSettle();
        await customLoadAppFonts();
        await tester.pumpAndSettle();
      },
      screenFactory: (Locale locale, Brightness brightnessToTest) =>
          ProviderScope(
        overrides: [
          rpgConfigurationProvider.overrideWith((ref) {
            return RpgConfigurationNotifier(
              decks: AsyncValue.data(
                RpgConfigurationModel.getBaseConfiguration().copyWith(
                  defaultSkinId: CharacterSheetSkinIds.arcaneLedger,
                ),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
        ],
        child: ThemeConfigurationForApp(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              fontFamily: 'Ruwudu',
              useMaterial3: true,
            ),
            home: CustomThemeProvider(
              overrideBrightness: Brightness.light,
              overrideSkinId: CharacterSheetSkinIds.arcaneLedger,
              child: Scaffold(
                body: RpgConfigurationWizardStep0CharacterSheetSkin(
                  onPreviousBtnPressed: () {},
                  onNextBtnPressed: () {},
                  setWizardTitle: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
      getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
          Map.fromEntries([
        MapEntry(
          'arcane_ledger',
          CustomThemeProvider(
            overrideBrightness: Brightness.light,
            overrideSkinId: CharacterSheetSkinIds.arcaneLedger,
            child: DependencyProvider.getMockedDependecyProvider(
              child: Center(child: widgetToTest),
            ),
          ),
        ),
      ]),
    );
  });
}
