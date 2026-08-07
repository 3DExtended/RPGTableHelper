import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/modals/show_ask_player_for_fight_order_roll.dart';
import 'package:quest_keeper/helpers/modals/show_character_sheet_appearance_modal.dart';
import 'package:quest_keeper/helpers/modals/show_item_card_details.dart';
import 'package:quest_keeper/helpers/modals/show_player_has_been_granted_items_through_dm_modal.dart';
import 'package:quest_keeper/helpers/modals/show_recipe_card_details.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_recepies.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../custom_font_loader.dart';
import '../../test_configuration.dart';

/// iPad-landscape Night Cartographer goldens for major skinned modals (skin-09).
void main() {
  Future<void> pumpModalFonts(WidgetTester tester) async {
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await customLoadAppFonts();
    await customLoadAppFonts();
    await tester.pumpAndSettle();
    await customLoadAppFonts();
    await tester.pumpAndSettle();
  }

  Widget ncHost({
    required Locale locale,
    required GlobalKey<NavigatorState> navigatorKey,
    required VoidCallback onPressed,
  }) {
    return ProviderScope(
      overrides: [
        rpgCharacterConfigurationProvider.overrideWith((ref) {
          return RpgCharacterConfigurationNotifier(
            decks: AsyncValue.data(
              RpgCharacterConfiguration.getBaseConfiguration(null).copyWith(
                skinId: CharacterSheetSkinIds.nightCartographer,
              ),
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
          theme: ThemeData(
            fontFamily: 'Ruwudu',
            useMaterial3: true,
            iconTheme: const IconThemeData(color: Colors.white, size: 16),
          ),
          home: CustomThemeProvider(
            overrideBrightness: Brightness.dark,
            overrideSkinId: CharacterSheetSkinIds.nightCartographer,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: onPressed,
                  child: const Text('Click me'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, Widget> ncConfigs(Widget widgetToTest) => {
        'night_cartographer': CustomThemeProvider(
          overrideBrightness: Brightness.dark,
          overrideSkinId: CharacterSheetSkinIds.nightCartographer,
          child: DependencyProvider.getMockedDependecyProvider(
            child: Center(child: widgetToTest),
          ),
        ),
      };

  group('night cartographer modals', () {
    testConfigurations(
      disableLocals: true,
      disableDarkMode: true,
      pathPrefix: "../",
      overrideSkinId: CharacterSheetSkinIds.nightCartographer,
      devices: testDevicesLedger,
      widgetName: 'night-cartographer-modal-item-card-details',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) => pumpModalFonts(tester),
      screenFactory: (locale, _) {
        final navigatorKey = GlobalKey<NavigatorState>();
        return ncHost(
          locale: locale,
          navigatorKey: navigatorKey,
          onPressed: () async {
            final ctx = navigatorKey.currentContext!;
            await showItemCardDetails(
              overrideNavigatorKey: navigatorKey,
              currentlyOwned: 2,
              item: RpgConfigurationModel.getBaseConfiguration().allItems.first,
              rpgConfig: RpgConfigurationModel.getBaseConfiguration(),
              ctx,
            );
          },
        );
      },
      getTestConfigurations: (w, _) => ncConfigs(w),
    );

    testConfigurations(
      disableLocals: true,
      disableDarkMode: true,
      pathPrefix: "../",
      overrideSkinId: CharacterSheetSkinIds.nightCartographer,
      devices: testDevicesLedger,
      widgetName: 'night-cartographer-modal-recipe-card-details',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) => pumpModalFonts(tester),
      screenFactory: (locale, _) {
        final navigatorKey = GlobalKey<NavigatorState>();
        final rpg = RpgConfigurationModel.getBaseConfiguration();
        final recipe = rpg.craftingRecipes.first;
        final mapped = CraftingRecipeWithRpgItemDetails(
          originalRecipe: recipe,
          recipeUuid: recipe.recipeUuid,
          requiredItems: recipe.requiredItemIds
              .map((id) => rpg.getItemForId(id))
              .toList(),
          ingredients: recipe.ingredients
              .map(
                (ing) => CraftingRecipeIngredientPairWithRpgItemDetails(
                  item: rpg.getItemForId(ing.itemUuid),
                  amountOfUsedItem: ing.amountOfUsedItem,
                ),
              )
              .toList(),
          createdItem: CraftingRecipeIngredientPairWithRpgItemDetails(
            item: rpg.getItemForId(recipe.createdItem.itemUuid),
            amountOfUsedItem: recipe.createdItem.amountOfUsedItem,
          ),
        );
        return ncHost(
          locale: locale,
          navigatorKey: navigatorKey,
          onPressed: () async {
            final ctx = navigatorKey.currentContext!;
            await showRecipeCardDetails(
              overrideNavigatorKey: navigatorKey,
              currentInventory:
                  RpgCharacterConfiguration.getBaseConfiguration(rpg),
              rpgConfig: rpg,
              recipe: mapped,
              ctx,
            );
          },
        );
      },
      getTestConfigurations: (w, _) => ncConfigs(w),
    );

    testConfigurations(
      disableLocals: true,
      disableDarkMode: true,
      pathPrefix: "../",
      overrideSkinId: CharacterSheetSkinIds.nightCartographer,
      devices: testDevicesLedger,
      widgetName: 'night-cartographer-modal-appearance',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) => pumpModalFonts(tester),
      screenFactory: (locale, _) {
        final navigatorKey = GlobalKey<NavigatorState>();
        return ncHost(
          locale: locale,
          navigatorKey: navigatorKey,
          onPressed: () async {
            final ctx = navigatorKey.currentContext!;
            await showCharacterSheetAppearanceModal(
              context: ctx,
              currentSkinId: CharacterSheetSkinIds.nightCartographer,
              campaignDefaultSkinId: CharacterSheetSkinIds.nightCartographer,
              immediateApply: false,
            );
          },
        );
      },
      getTestConfigurations: (w, _) => ncConfigs(w),
    );

    testConfigurations(
      disableLocals: true,
      disableDarkMode: true,
      pathPrefix: "../",
      overrideSkinId: CharacterSheetSkinIds.nightCartographer,
      devices: testDevicesLedger,
      widgetName: 'night-cartographer-modal-granted-items',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) => pumpModalFonts(tester),
      screenFactory: (locale, _) {
        final navigatorKey = GlobalKey<NavigatorState>();
        final rpg = RpgConfigurationModel.getBaseConfiguration();
        return ncHost(
          locale: locale,
          navigatorKey: navigatorKey,
          onPressed: () async {
            final ctx = navigatorKey.currentContext!;
            await showPlayerHasBeenGrantedItemsThroughDmModal(
              grantedItems: GrantedItemsForPlayer(
                characterName: 'Gandalf',
                playerId: '6e574e88-630e-4728-a113-0f3f96a0f0ed',
                grantedItems: rpg.allItems
                    .take(3)
                    .map(
                      (e) => RpgCharacterOwnedItemPair(
                        amount: 2,
                        itemUuid: e.uuid,
                      ),
                    )
                    .toList(),
              ),
              rpgConfig: rpg,
              overrideNavigatorKey: navigatorKey,
              ctx,
            );
          },
        );
      },
      getTestConfigurations: (w, _) => ncConfigs(w),
    );

    testConfigurations(
      disableLocals: true,
      disableDarkMode: true,
      pathPrefix: "../",
      overrideSkinId: CharacterSheetSkinIds.nightCartographer,
      devices: testDevicesLedger,
      widgetName: 'night-cartographer-modal-fight-order-roll',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) => pumpModalFonts(tester),
      screenFactory: (locale, _) {
        final navigatorKey = GlobalKey<NavigatorState>();
        return ncHost(
          locale: locale,
          navigatorKey: navigatorKey,
          onPressed: () async {
            final ctx = navigatorKey.currentContext!;
            await showAskPlayerForFightOrderRoll(
              ctx,
              characterName: 'Gandalf',
              overrideNavigatorKey: navigatorKey,
            );
          },
        );
      },
      getTestConfigurations: (w, _) => ncConfigs(w),
    );
  });
}
