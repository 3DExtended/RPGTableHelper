import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_6_create_or_edit_item_modal.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../../../test_configuration.dart';

void main() {
  group('Create or edit Item modal renderings', () {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    testConfigurations(
      disableLocals: true,
      pathPrefix: "../../",
      widgetName: 'showCreateOrEditItemModal',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) async {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        await loadAppFonts();
        await loadAppFonts();
        await tester.pumpAndSettle();
        await loadAppFonts();
        await tester.pumpAndSettle();
      },
      screenFactory: (Locale locale) => ProviderScope(
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
                RpgConfigurationModel.getBaseConfiguration(),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
        ],
        child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              fontFamily: 'Roboto',
              useMaterial3: true,
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 16,
              ),
            ),
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Builder(builder: (context) {
                return ElevatedButton(
                    onPressed: () async {
                      await showCreateOrEditItemModal(
                        overrideNavigatorKey: navigatorKey,
                        context,
                        RpgItem(
                            uuid: "asdf",
                            name: "Test",
                            categoryId: null,
                            description: "Ich bin ein text",
                            patchSize: DiceRoll(
                                numDice: 22, diceSides: 6, modifier: 1),
                            baseCurrencyPrice: 1000,
                            placeOfFindings: [
                              RpgItemRarity(
                                placeOfFindingId:
                                    "5b9690c1-afc9-436d-8912-d223c440eb6a",
                                diceChallenge: 5,
                              )
                            ]),
                      );
                    },
                    child: const Text("Click me"));
              }),
            )),
      ),
      getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
        MapEntry(
          'default',
          DependencyProvider.getMockedDependecyProvider(
            child: Center(
              child: widgetToTest,
            ),
          ),
        ),
      ]),
    );
  });
}
