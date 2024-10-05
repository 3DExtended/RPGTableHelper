import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_create_or_edit_item_recipe_modal.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../../../test_configuration.dart';

void main() {
  group('Create or edit Item modal renderings', () {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    testConfigurations(
      disableLocals: true,
      pathPrefix: "../../",
      widgetName: 'showCreateOrEditCraftingRecipeModal',
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
            debugShowCheckedModeBanner: false,
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
                      await showCreateOrEditCraftingRecipeModal(
                        overrideNavigatorKey: navigatorKey,
                        context,
                        CraftingRecipe(
                          recipeUuid: "7fe8e70c-c276-4e98-b8d5-255a27ae2b49",
                          ingredients: [
                            CraftingRecipeIngredientPair(
                                itemUuid:
                                    "8abe00a8-fa94-4e5d-9c99-2a68b9de60e7",
                                amountOfUsedItem: 2),
                            CraftingRecipeIngredientPair(
                                itemUuid:
                                    "73b51a58-8a07-4de2-828c-d0952d42af34",
                                amountOfUsedItem: 1),
                          ],
                          requiredItemIds: [
                            "dc497952-1989-40d1-9d50-a5b4e53dd1be",
                          ],
                          createdItem: CraftingRecipeIngredientPair(
                            itemUuid: "a7537746-260d-4aed-b182-26768a9c2d51",
                            amountOfUsedItem: 1,
                          ),
                        ),
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
