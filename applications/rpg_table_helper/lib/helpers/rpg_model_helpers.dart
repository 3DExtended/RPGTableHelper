import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

enum RecipeCraftabilityFilter { all, craftableOnly, notCraftableOnly }

List<({T recipe, int amountCraftable})> applyRecipeCraftabilityFilter<T>(
  List<({T recipe, int amountCraftable})> recipes,
  RecipeCraftabilityFilter filter,
) {
  return switch (filter) {
    RecipeCraftabilityFilter.all => recipes,
    RecipeCraftabilityFilter.craftableOnly =>
      recipes.where((t) => t.amountCraftable > 0).toList(),
    RecipeCraftabilityFilter.notCraftableOnly =>
      recipes.where((t) => t.amountCraftable == 0).toList(),
  };
}

int getItemCountInCharacterInventory(
    RpgCharacterConfiguration characterConfig, String itemUuid) {
  return characterConfig.inventory
          .where((i) => i.itemUuid == itemUuid)
          .singleOrNull
          ?.amount ??
      0;
}

int getAmountCreatableForRecipe(
    RpgCharacterConfiguration characterConfig, CraftingRecipe recipe) {
  const int maxValue = -1 >>> 1;

  for (var requirement in recipe.requiredItemIds) {
    if (getItemCountInCharacterInventory(characterConfig, requirement) == 0) {
      return 0;
    }
  }

  var createable = maxValue;

  for (var ingredientPair in recipe.ingredients) {
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

List<(RpgItem item, int amount)> getInventoryOfCharacter(
    RpgConfigurationModel rpgConfig, RpgCharacterConfiguration character) {
  var result = rpgConfig.allItems
      .map((e) => (
            e,
            character.inventory
                    .where((i) => i.itemUuid == e.uuid)
                    .firstOrNull
                    ?.amount ??
                0
          ))
      .toList();

  return result.where((t) => t.$2 != 0).toList();
}

List<(CraftingRecipe recipe, int craftableCount)> getCraftingRecipesOfCharacter(
    {required RpgConfigurationModel rpgConfig,
    required RpgCharacterConfiguration character}) {
  int numberOfCraftsPossilbe(
      CraftingRecipe recipe, RpgCharacterConfiguration character) {
    const int maxValue = -1 >>> 1;
    var minResourceMultiple = maxValue;

    for (var ingredientToCheck in recipe.ingredients) {
      var itemCountInInventory = character.inventory
              .where((e) => e.itemUuid == ingredientToCheck.itemUuid)
              .singleOrNull
              ?.amount ??
          0;

      var tempMultipleOfIngredientPart =
          (itemCountInInventory / ingredientToCheck.amountOfUsedItem).floor();

      if (tempMultipleOfIngredientPart < minResourceMultiple) {
        minResourceMultiple = tempMultipleOfIngredientPart;
      }
    }

    return minResourceMultiple;
  }

  var craftingRecipes = rpgConfig.craftingRecipes
      .map((e) => (e, numberOfCraftsPossilbe(e, character)))
      .toList();

  craftingRecipes.sort((a, b) => b.$2.compareTo(a.$2));

  return craftingRecipes;
}
