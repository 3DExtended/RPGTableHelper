import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/categorized_item_layout.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/item_visualization.dart';
import 'package:rpg_table_helper/components/static_grid.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/iterable_extension.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class CraftingScreen extends ConsumerStatefulWidget {
  static String route = "crafting";

  const CraftingScreen({super.key});

  @override
  ConsumerState<CraftingScreen> createState() => _CraftingScreenState();
}

class _CraftingScreenState extends ConsumerState<CraftingScreen> {
  String? selectedCategory;
  String? selectedParentCategory;

  @override
  Widget build(BuildContext context) {
    var characterConfig =
        ref.watch(rpgCharacterConfigurationProvider).valueOrNull;

    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;

    var categories = getCategoriesForRecipes(rpgConfig);

    if (selectedCategory == null && categories.isNotEmpty) {
      selectedParentCategory = categories.first.uuid;
      if (categories.first.subCategories.isEmpty) {
        selectedCategory = categories.first.uuid;
      } else {
        selectedCategory = categories.first.subCategories.first.uuid;
      }
    }

    var recipesForSelectedCategory = getRecipesForSelectedCategory(
        rpgConfig, selectedParentCategory, selectedCategory);

    var isLandscape =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    var categoryColumns = [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: CustomMarkdownBody(
            text:
                "# ${characterConfig?.characterName == null || characterConfig!.characterName.isEmpty ? "Player Name" : characterConfig.characterName}"),
      ),
      const HorizontalLine(),
      ...categories.map(
        (category) => Column(
          children: [
            CupertinoButton(
              onPressed: () {
                setState(() {
                  selectedCategory = category.uuid;
                  selectedParentCategory = category.uuid;
                });
              },
              minSize: 0,
              padding: const EdgeInsets.all(0),
              child: Container(
                color: category.uuid == selectedParentCategory
                    ? whiteBgTint
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      // show chevron if subcategories
                      if (category.subCategories.isNotEmpty)
                        CustomFaIcon(
                          size: 20,
                          icon: selectedParentCategory == category.uuid
                              ? FontAwesomeIcons.chevronUp
                              : FontAwesomeIcons.chevronDown,
                        )
                    ],
                  ),
                ),
              ),
            ),
            if (category.subCategories.isNotEmpty &&
                category.uuid == selectedParentCategory)
              ...category.subCategories
                  .where((sc) => getSubcategoryHasRecipes(rpgConfig, sc))
                  .map((subCategory) => CupertinoButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = subCategory.uuid;
                            selectedParentCategory = category.uuid;
                          });
                        },
                        minSize: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 30),
                              child: Row(
                                children: [
                                  StyledBox(
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      color:
                                          selectedCategory == subCategory.uuid
                                              ? Colors.white
                                              : Colors.transparent,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    subCategory.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                            color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
          ],
        ),
      ),
    ];

    var normalizedScreenWidth = MediaQuery.of(context).devicePixelRatio *
        MediaQuery.of(context).size.width;

    if (isLandscape) {
      normalizedScreenWidth = MediaQuery.of(context).devicePixelRatio *
          MediaQuery.of(context).size.height;
    }
    var numberOfColumnsInMainContent = 1;
    if (normalizedScreenWidth > 1300) {
      numberOfColumnsInMainContent = 2;
    }
    if (normalizedScreenWidth > 1600) {
      numberOfColumnsInMainContent = 3;
    }

    var contentChildren = [
      Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 9.0),
        child: Text(
          "Rezepte",
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: Colors.white, fontSize: 32),
        ),
      ),
      const HorizontalLine(),
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: StaticGrid(
              colGap: 20,
              rowGap: 20,
              columnCount: numberOfColumnsInMainContent,
              children: [
                ...recipesForSelectedCategory
                    .map((r) =>
                        (r, getAmountCreatableForRecipe(characterConfig, r)))
                    .map(
                      (rece) => Builder(builder: (context) {
                        RpgItem itemToRender = getItemForId(
                            rpgConfig!, rece.$1.createdItem.itemUuid);
                        int numberOfItemsInInventory =
                            getItemCountInCharacterInventory(
                                characterConfig, itemToRender.uuid);

                        return ItemVisualization(
                            useItem: null,
                            itemToRender: itemToRender,
                            renderRecipeRelatedThings: true,
                            itemNameSuffix:
                                " (x${rece.$1.createdItem.amountOfUsedItem})",
                            numberOfItemsInInventory: numberOfItemsInInventory,
                            numberOfCreateableInstances: rece.$2,
                            craftItem: () {
                              ref
                                  .read(rpgCharacterConfigurationProvider
                                      .notifier)
                                  .tryCraftItem(rpgConfig, rece.$1);
                            });
                      }),
                    ),
              ],
            ),
          ),
        ),
      )
    ];

    return CategorizedItemLayout(
        categoryColumns: categoryColumns, contentChildren: contentChildren);
  }

  RpgItem getItemForId(RpgConfigurationModel rpgConfig, String id) {
    return rpgConfig.allItems.singleWhere((it) => it.uuid == id);
  }

  List<ItemCategory> getCategoriesForRecipes(RpgConfigurationModel? rpgConfig) {
    if (rpgConfig == null) return [];

    var allCreatableItems = rpgConfig.craftingRecipes
        .map((re) => re.createdItem.itemUuid)
        .distinct(by: (e) => e)
        .toList();

    var allRecipeCategoryIds = rpgConfig.allItems
        .where((it) => allCreatableItems.contains(it.uuid))
        .map((it) => it.categoryId)
        .where((it) => it != null)
        .distinct(by: (by) => by)
        .toList();

    return rpgConfig.itemCategories
        .where((c) =>
            allRecipeCategoryIds.contains(c.uuid) ||
            c.subCategories.any((sC) => allRecipeCategoryIds.contains(sC.uuid)))
        .toList();
  }

  List<CraftingRecipe> getRecipesForSelectedCategory(
      RpgConfigurationModel? rpgConfig,
      String? selectedParentCategory,
      String? selectedCategory) {
    if (rpgConfig == null) return [];

    var allCreatableItemIds = rpgConfig.craftingRecipes
        .map((re) => (re, re.createdItem.itemUuid))
        .toList();

    var recipesForSelectedCategories = allCreatableItemIds
        .map((tuple) => (
              tuple.$1,
              tuple.$2,
              rpgConfig.allItems.singleWhere((it) => it.uuid == tuple.$2)
            ))
        .where((tuple) => tuple.$3.categoryId == selectedCategory)
        .toList();

    return recipesForSelectedCategories.map((tuple) => tuple.$1).toList();
  }

  int getItemCountInCharacterInventory(
      RpgCharacterConfiguration? characterConfig, String itemUuid) {
    if (characterConfig == null) return 0;

    var res = characterConfig.inventory
        .where((i) => i.itemUuid == itemUuid)
        .singleOrNull;

    if (res == null) return 0;

    return res.amount;
  }

  int getAmountCreatableForRecipe(
      RpgCharacterConfiguration? characterConfig, CraftingRecipe r) {
    if (characterConfig == null) return 0;
    const int maxValue = -1 >>> 1;

    // check if requirements are met
    for (var requirement in r.requiredItemIds) {
      var ingredientsInInventory =
          getItemCountInCharacterInventory(characterConfig, requirement);
      if (ingredientsInInventory == 0) {
        return 0;
      }
    }

    // check how often a user can execute the recipe
    int createable = maxValue;

    for (var ingredientPair in r.ingredients) {
      var ingredientsInInventory = getItemCountInCharacterInventory(
          characterConfig, ingredientPair.itemUuid);

      var numberOfTimes =
          ingredientsInInventory ~/ ingredientPair.amountOfUsedItem;

      if (createable > numberOfTimes) {
        createable = numberOfTimes;
      }
    }

    return createable;
  }

  bool getSubcategoryHasRecipes(
      RpgConfigurationModel? rpgConfig, ItemCategory sc) {
    if (rpgConfig == null) return false;

    return rpgConfig.craftingRecipes.any((cr) =>
        getItemForId(rpgConfig, cr.createdItem.itemUuid).categoryId == sc.uuid);
  }
}
