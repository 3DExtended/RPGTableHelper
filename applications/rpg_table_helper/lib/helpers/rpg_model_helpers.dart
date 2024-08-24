import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

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
