import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_recipe_card.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/color_extension.dart';
import 'package:rpg_table_helper/helpers/custom_iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/fuzzysort.dart';
import 'package:rpg_table_helper/helpers/icons_helper.dart';
import 'package:rpg_table_helper/helpers/iterable_extension.dart';
import 'package:rpg_table_helper/helpers/modals/show_recipe_card_details.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class PlayerScreenRecepies extends ConsumerStatefulWidget {
  const PlayerScreenRecepies({
    super.key,
  });

  @override
  ConsumerState<PlayerScreenRecepies> createState() =>
      _PlayerScreenRecepiesState();
}

class CraftingRecipeIngredientPairWithRpgItemDetails {
  final RpgItem item;
  final int amountOfUsedItem;

  CraftingRecipeIngredientPairWithRpgItemDetails(
      {required this.item, required this.amountOfUsedItem});
}

class CraftingRecipeWithRpgItemDetails {
  final String recipeUuid;
  final CraftingRecipe originalRecipe;
  final List<CraftingRecipeIngredientPairWithRpgItemDetails> ingredients;
  final CraftingRecipeIngredientPairWithRpgItemDetails createdItem;
  final List<RpgItem> requiredItems;

  CraftingRecipeWithRpgItemDetails(
      {required this.recipeUuid,
      required this.ingredients,
      required this.originalRecipe,
      required this.createdItem,
      required this.requiredItems});
}

class _PlayerScreenRecepiesState extends ConsumerState<PlayerScreenRecepies> {
  String? selectedCategory;
  bool showOnlyCraftableItems = true;
  bool isSearchFieldShowing = true;
  TextEditingController searchtextEditingController = TextEditingController();

  Fuzzysort fuzzysortForSearch = Fuzzysort();
  Map<String, ({FuzzySearchPreparedTarget labelSearchTarget})> preparedTargets =
      {};
  List<FuzzySearchResult> searchItemFilters = [];

  List<CraftingRecipeWithRpgItemDetails> _allRecipes = [];

  @override
  void initState() {
    searchtextEditingController.addListener(onTextEditControllerChange);

    super.initState();
  }

  @override
  void dispose() {
    searchtextEditingController.removeListener(onTextEditControllerChange);
    super.dispose();
  }

  void onTextEditControllerChange() {
    var query = searchtextEditingController.text;

    var searchTargets = preparedTargets.values
        .map((t) => [t.labelSearchTarget])
        .expand((i) => i)
        .toList();

    var tempResult = fuzzysortForSearch.go(query, searchTargets, null);
    setState(() {
      searchItemFilters = tempResult.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;
    var rpgCharacterConfig =
        ref.watch(rpgCharacterConfigurationProvider).valueOrNull;

    if (rpgConfig == null || rpgCharacterConfig == null) {
      return Container(); // TODO show error
    }

    ref.watch(rpgConfigurationProvider).whenData((data) {
      // update _allRecipes
      _allRecipes = data.craftingRecipes
          .map((r) => enrichCraftingRecipe(r, data))
          .toList();

      for (var item in _allRecipes) {
        if (preparedTargets.containsKey(item.recipeUuid)) continue;

        preparedTargets[item.recipeUuid] = (
          labelSearchTarget: FuzzySearchPreparedTarget(
            target: item.createdItem.item.name,
            identifier: "label${item.recipeUuid}",
          ),
        );
      }
    });

    var recipesToRender = searchtextEditingController.text.isEmpty
        ? _allRecipes
        : searchItemFilters
            .map((r) => r.targetIdentifier)
            .map((id) =>
                _allRecipes.firstWhere((i) => id.contains(i.recipeUuid)))
            .distinct(by: (r) => r.recipeUuid);

    recipesToRender =
        recipesToRender.sortBy((r) => r.createdItem.item.name).toList();

    if (selectedCategory != "" && selectedCategory != null) {
      recipesToRender = recipesToRender
          .where((r) =>
              ItemCategory.parentCategoryForCategoryIdRecursive(
                      categories: rpgConfig.itemCategories,
                      categoryId: r.createdItem.item.categoryId)
                  ?.uuid ==
              selectedCategory)
          .toList();
    }

    // enrich recipesToRender with amount creatable by user
    var craftableFilteredRecipes = recipesToRender
        .map((r) => (
              recipe: r,
              amountCraftable: getAmountCreatableForRecipe(
                rpgCharacterConfig,
                r.originalRecipe,
              )
            ))
        .toList();

    if (showOnlyCraftableItems) {
      craftableFilteredRecipes =
          craftableFilteredRecipes.where((t) => t.amountCraftable > 0).toList();
    }

    return Column(
      children: [
        // search text field
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isSearchFieldShowing
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20, 0.0),
                  child: CustomTextField(
                      labelText: "Suche",
                      textEditingController: searchtextEditingController,
                      keyboardType: TextInputType.text),
                )
              : SizedBox.shrink(),
        ),

        // category filters
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CategoryFilterButton(
                          withoutLeadingPadding: true,
                          isSelected: showOnlyCraftableItems,
                          categoryForFilter: ItemCategory(
                            colorCode: null,
                            iconName: null,
                            name: "Herstellbar",
                            subCategories: [],
                            uuid: "craftable",
                            hideInInventoryFilters: false,
                          ),
                          onpressedHandler: () {
                            setState(() {
                              showOnlyCraftableItems = !showOnlyCraftableItems;
                            });
                          }),
                      Container(
                        height: 24,
                        width: 1,
                        color: darkColor,
                      ),
                      ...[
                        ItemCategory(
                          colorCode: null,
                          iconName: null,
                          name: "Alles",
                          subCategories: [],
                          uuid: "",
                          hideInInventoryFilters: false,
                        ),
                        ...CustomIterableExtensions(rpgConfig.itemCategories)
                            .sortBy((e) => e.name),
                      ].map(
                        (e) => CategoryFilterButton(
                            isSelected: (selectedCategory == e.uuid ||
                                (e.uuid == "" && selectedCategory == null)),
                            categoryForFilter: e,
                            onpressedHandler: () {
                              setState(() {
                                selectedCategory = e.uuid;
                              });
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              CustomButton(
                  variant: isSearchFieldShowing
                      ? CustomButtonVariant.DarkButton
                      : CustomButtonVariant.Default,
                  icon: CustomFaIcon(
                    icon: FontAwesomeIcons.magnifyingGlass,
                    color: isSearchFieldShowing ? textColor : darkColor,
                    size: 21,
                    noPadding: true,
                  ),
                  onPressed: () {
                    setState(() {
                      isSearchFieldShowing = !isSearchFieldShowing;
                      searchtextEditingController.text = "";
                      onTextEditControllerChange();
                    });
                  }),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              var layoutWidth = constraints.maxWidth;
              const scalar = 1.0;

              const cardWidth = 289 * scalar;

              const targetedCardWidth = cardWidth;
              const itemCardPadding = 9.0;

              var numberOfColumnsOnScreen = 1;
              var calculatedWidth = itemCardPadding + targetedCardWidth;

              while (calculatedWidth < layoutWidth) {
                calculatedWidth += itemCardPadding + targetedCardWidth;
                numberOfColumnsOnScreen++;
              }

              numberOfColumnsOnScreen--;

              if (craftableFilteredRecipes.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      showOnlyCraftableItems
                          ? "In dieser Kategorie sind keine Items herstellbar"
                          : "Keine Items unter dieser Kategorie",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 24, color: darkTextColor),
                    ),
                  ],
                );
              }

              return ListView.builder(
                itemCount: ((craftableFilteredRecipes.length ~/
                                numberOfColumnsOnScreen) *
                            numberOfColumnsOnScreen ==
                        craftableFilteredRecipes.length)
                    ? (craftableFilteredRecipes.length ~/
                        numberOfColumnsOnScreen)
                    : (craftableFilteredRecipes.length ~/
                            numberOfColumnsOnScreen) +
                        1,
                itemBuilder: (context, index) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(numberOfColumnsOnScreen, (subindex) {
                          var indexOfRecipeToRender =
                              index * numberOfColumnsOnScreen + subindex;
                          if (indexOfRecipeToRender >=
                              craftableFilteredRecipes.length) {
                            return List<Widget>.empty();
                          }

                          var recipeToRender =
                              craftableFilteredRecipes[indexOfRecipeToRender];

                          return [
                            Column(
                              children: [
                                CupertinoButton(
                                  minSize: 0,
                                  padding: EdgeInsets.all(0),
                                  onPressed: () async {
                                    await showRecipeCardDetails(context,
                                            recipe: recipeToRender.recipe,
                                            rpgConfig: rpgConfig,
                                            currentInventory:
                                                rpgCharacterConfig)
                                        .then((valueToAdjustAmountBy) {
                                      if (valueToAdjustAmountBy == null) {
                                        return;
                                      }

                                      ref
                                          .read(
                                              rpgCharacterConfigurationProvider
                                                  .notifier)
                                          .grantItems([
                                        ...valueToAdjustAmountBy.addedItems.map(
                                          (ai) => RpgCharacterOwnedItemPair(
                                            itemUuid: ai.itemUuid,
                                            amount: ai.amountOfUsedItem,
                                          ),
                                        ),
                                        ...valueToAdjustAmountBy.removedItems
                                            .map(
                                          (ai) => RpgCharacterOwnedItemPair(
                                            itemUuid: ai.itemUuid,
                                            amount: -1 * ai.amountOfUsedItem,
                                          ),
                                        ),
                                      ]);
                                      setState(() {});
                                    });
                                  },
                                  child: CustomRecipeCard(
                                    imageUrl: recipeToRender.recipe.createdItem
                                        .item.imageUrlWithoutBasePath,
                                    title: recipeToRender
                                        .recipe.createdItem.item.name,
                                    requirements: recipeToRender
                                        .recipe.requiredItems
                                        .map((req) => CustomRecipeCardItemPair(
                                              amount: 1,
                                              itemName: req.name,
                                            ))
                                        .toList(),
                                    ingedients: recipeToRender
                                        .recipe.ingredients
                                        .map((ing) => CustomRecipeCardItemPair(
                                              amount: ing.amountOfUsedItem,
                                              itemName: ing.item.name,
                                            ))
                                        .toList(),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Herstellbar: ${recipeToRender.amountCraftable}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color: darkTextColor,
                                        fontSize: 16,
                                      ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            if (numberOfColumnsOnScreen != subindex + 1)
                              SizedBox(
                                width: itemCardPadding,
                              ),
                          ];
                        }).expand((i) => i),
                      ]);
                },
              );
            },
          ),
        ),
      ],
    );
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

  RpgItem getItemForId(RpgConfigurationModel rpgConfig, String id) {
    return rpgConfig.allItems.singleWhere((it) => it.uuid == id);
  }

  CraftingRecipeWithRpgItemDetails enrichCraftingRecipe(
      CraftingRecipe r, RpgConfigurationModel rpgConfig) {
    return CraftingRecipeWithRpgItemDetails(
      originalRecipe: r,
      recipeUuid: r.recipeUuid,
      createdItem: CraftingRecipeIngredientPairWithRpgItemDetails(
        item: getItemForId(rpgConfig, r.createdItem.itemUuid),
        amountOfUsedItem: r.createdItem.amountOfUsedItem,
      ),
      requiredItems:
          r.requiredItemIds.map((req) => getItemForId(rpgConfig, req)).toList(),
      ingredients: r.ingredients
          .map(
            (ing) => CraftingRecipeIngredientPairWithRpgItemDetails(
              item: getItemForId(rpgConfig, ing.itemUuid),
              amountOfUsedItem: ing.amountOfUsedItem,
            ),
          )
          .toList(),
    );
  }
}

class CategoryFilterButton extends StatelessWidget {
  const CategoryFilterButton({
    super.key,
    required this.isSelected,
    required this.categoryForFilter,
    required this.onpressedHandler,
    this.withoutLeadingPadding,
  });

  final bool? withoutLeadingPadding;
  final bool isSelected;
  final ItemCategory categoryForFilter;
  final Null Function() onpressedHandler;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          right: 12, left: withoutLeadingPadding == true ? 0 : 12),
      child: CustomButton(
        variant: isSelected
            ? CustomButtonVariant.DarkButton
            : CustomButtonVariant.Default,
        onPressed: onpressedHandler,
        label: categoryForFilter.name,
        icon: categoryForFilter.iconName == null
            ? null
            : getIconForIdentifier(
                    name: categoryForFilter.iconName!,
                    size: 20,
                    color: isSelected
                        ? (categoryForFilter.colorCode
                            ?.parseHexColorRepresentation())
                        : darkColor)
                .$2,
      ),
    );
  }
}
