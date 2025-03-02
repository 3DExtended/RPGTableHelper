import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/modals/show_recipe_card_details.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_recepies.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('showRecipeCardDetails renderings', () {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    testConfigurations(
      disableLocals: false,
      pathPrefix: "",
      widgetName: 'showRecipeCardDetails',
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
        child: ThemeConfigurationForApp(
          child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate
              ],
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              darkTheme: ThemeData.dark(),
              themeMode: ThemeMode.dark,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                fontFamily: 'Ruwudu',
                useMaterial3: true,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 16,
                ),
              ),
              home: ThemeConfigurationForApp(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Builder(builder: (context) {
                    var recipe = RpgConfigurationModel.getBaseConfiguration()
                        .craftingRecipes
                        .first;
                    CraftingRecipeWithRpgItemDetails mappedrecipe =
                        CraftingRecipeWithRpgItemDetails(
                            originalRecipe: recipe,
                            recipeUuid: recipe.recipeUuid,
                            requiredItems: recipe.requiredItemIds
                                .map((id) =>
                                    RpgConfigurationModel.getBaseConfiguration()
                                        .getItemForId(id))
                                .toList(),
                            ingredients: recipe.ingredients
                                .map(
                                  (ing) =>
                                      CraftingRecipeIngredientPairWithRpgItemDetails(
                                    item: RpgConfigurationModel
                                            .getBaseConfiguration()
                                        .getItemForId(ing.itemUuid),
                                    amountOfUsedItem: ing.amountOfUsedItem,
                                  ),
                                )
                                .toList(),
                            createdItem:
                                CraftingRecipeIngredientPairWithRpgItemDetails(
                                    item: RpgConfigurationModel
                                            .getBaseConfiguration()
                                        .getItemForId(
                                            recipe.createdItem.itemUuid),
                                    amountOfUsedItem:
                                        recipe.createdItem.amountOfUsedItem));

                    return ElevatedButton(
                        onPressed: () async {
                          await showRecipeCardDetails(
                            overrideNavigatorKey: navigatorKey,
                            currentInventory:
                                RpgCharacterConfiguration.getBaseConfiguration(
                                    RpgConfigurationModel
                                        .getBaseConfiguration()),
                            rpgConfig:
                                RpgConfigurationModel.getBaseConfiguration(),
                            recipe: mappedrecipe,
                            context,
                          );
                        },
                        child: const Text("Click me"));
                  }),
                ),
              )),
        ),
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
