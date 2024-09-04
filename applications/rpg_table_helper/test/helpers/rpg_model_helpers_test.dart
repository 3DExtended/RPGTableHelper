import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/helpers/rpg_model_helpers.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

void main() {
  group("getCraftingRecipiesForCharacter", () {
    group('getCraftingRecipesOfCharacter', () {
      late RpgConfigurationModel rpgConfig;
      late RpgCharacterConfiguration character;

      setUp(() {
        // Set up sample data for the tests
        rpgConfig = RpgConfigurationModel(
          rpgName: 'Test RPG',
          allItems: [
            RpgItem(
                uuid: 'item1',
                name: 'Iron Ore',
                categoryId: 'cat1',
                baseCurrencyPrice: 10,
                placeOfFindingIds: ['place1'],
                description: "Eine Beschreibung"),
            RpgItem(
                uuid: 'item2',
                name: 'Wood',
                categoryId: 'cat1',
                baseCurrencyPrice: 5,
                placeOfFindingIds: ['place1'],
                description: "Eine Beschreibung"),
            RpgItem(
                uuid: 'item3',
                name: 'Iron Sword',
                categoryId: 'cat2',
                baseCurrencyPrice: 50,
                placeOfFindingIds: ['place2'],
                description: "Eine Beschreibung"),
          ],
          placesOfFindings: [],
          itemCategories: [],
          characterStatsDefinition: CharacterStatsDefinition(
            mainPlayerStat: CharacterStatDefinition(
              statUuid: 'stat1',
              name: 'Strength',
              helperText: 'Character strength',
              valueType: CharacterStatValueType.int,
              editType: CharacterStatEditType.static,
            ),
            secondaryPlayerStat: CharacterStatDefinition(
              statUuid: 'stat2',
              name: 'Dexterity',
              helperText: 'Character dexterity',
              valueType: CharacterStatValueType.int,
              editType: CharacterStatEditType.static,
            ),
            thirdPlayerStat: CharacterStatDefinition(
              statUuid: 'stat3',
              name: 'Intelligence',
              helperText: 'Character intelligence',
              valueType: CharacterStatValueType.int,
              editType: CharacterStatEditType.static,
            ),
            otherPlayerStats: [],
          ),
          currencyDefinition: CurrencyDefinition(
            currencyTypes: [
              CurrencyType(name: 'Gold', multipleOfPreviousValue: 1),
            ],
          ),
          craftingRecipes: [
            CraftingRecipe(
              recipeUuid: 'recipe1',
              ingredients: [
                CraftingRecipeIngredientPair(
                    itemUuid: 'item1', amountOfUsedItem: 2),
                CraftingRecipeIngredientPair(
                    itemUuid: 'item2', amountOfUsedItem: 1),
              ],
              createdItem: CraftingRecipeIngredientPair(
                  itemUuid: 'item3', amountOfUsedItem: 1),
            ),
          ],
        );

        character = RpgCharacterConfiguration(
          characterName: 'Hero',
          moneyCoinCount: [100],
          characterStats: [],
          inventory: [
            RpgCharacterOwnedItemPair(itemUuid: 'item1', amount: 4),
            RpgCharacterOwnedItemPair(itemUuid: 'item2', amount: 1),
          ],
        );
      });

      test('returns craftable recipes when character has sufficient resources',
          () {
        var result = getCraftingRecipesOfCharacter(
          rpgConfig: rpgConfig,
          character: character,
        );

        expect(result, isNotEmpty);
        expect(result.first.$1.recipeUuid, 'recipe1');
        expect(result.first.$2, 1); // Can craft 1 times
      });

      test('returns an empty list when character has no resources', () {
        character.inventory.clear(); // Clear inventory

        var result = getCraftingRecipesOfCharacter(
          rpgConfig: rpgConfig,
          character: character,
        );

        expect(result, isNotEmpty);
        expect(result.first.$1.recipeUuid, 'recipe1');
        expect(result.first.$2, 0); // Can craft 0 times
      });

      test('returns an empty list when recipe ingredients exceed inventory',
          () {
        character.inventory.add(
          RpgCharacterOwnedItemPair(itemUuid: 'item1', amount: 1),
        );
        character.inventory.add(
          RpgCharacterOwnedItemPair(itemUuid: 'item2', amount: 0),
        );

        var result = getCraftingRecipesOfCharacter(
          rpgConfig: rpgConfig,
          character: character,
        );

        expect(result, isNotEmpty);
        expect(result.first.$1.recipeUuid, 'recipe1');
        expect(result.first.$2, 0); // Can craft 0 times
      });

      test('returns multiple craftable recipes sorted by craftable count', () {
        rpgConfig.craftingRecipes.add(
          CraftingRecipe(
            recipeUuid: 'recipe2',
            ingredients: [
              CraftingRecipeIngredientPair(
                  itemUuid: 'item1', amountOfUsedItem: 1),
            ],
            createdItem: CraftingRecipeIngredientPair(
                itemUuid: 'item3', amountOfUsedItem: 1),
          ),
        );

        var result = getCraftingRecipesOfCharacter(
          rpgConfig: rpgConfig,
          character: character,
        );

        expect(result.length, 2);
        expect(result.first.$1.recipeUuid,
            'recipe2'); // recipe2 should come first because it's more craftable
        expect(result.first.$2, 4);
        expect(result.last.$1.recipeUuid, 'recipe1');
        expect(result.last.$2, 1);
      });

      test('returns zero craftable count for recipe with missing ingredients',
          () {
        rpgConfig.craftingRecipes.add(
          CraftingRecipe(
            recipeUuid: 'recipe3',
            ingredients: [
              CraftingRecipeIngredientPair(
                  itemUuid: 'item3', amountOfUsedItem: 1), // Not in inventory
            ],
            createdItem: CraftingRecipeIngredientPair(
                itemUuid: 'item1', amountOfUsedItem: 1),
          ),
        );

        var result = getCraftingRecipesOfCharacter(
          rpgConfig: rpgConfig,
          character: character,
        );

        expect(result.last.$1.recipeUuid, 'recipe3');
        expect(result.last.$2, 0); // Cannot craft at all
      });
    });
  });
  group("getInventoryOfCharacter", () {
    test('Character with no items in inventory', () {
      // Arrange
      var item1 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var item2 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatsDefinition: CharacterStatsDefinition(
            mainPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            secondaryPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            thirdPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            otherPlayerStats: [],
          ),
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var character = RpgCharacterConfiguration(
          inventory: [],
          characterName: "",
          characterStats: [],
          moneyCoinCount: []);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result, isEmpty);
    });

    test('Character with one item in inventory', () {
      // Arrange
      var item1 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var item2 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatsDefinition: CharacterStatsDefinition(
            mainPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            secondaryPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            thirdPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            otherPlayerStats: [],
          ),
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var inventoryItem =
          RpgCharacterOwnedItemPair(itemUuid: 'uuid1', amount: 1);
      var character = RpgCharacterConfiguration(
          inventory: [inventoryItem],
          characterName: "",
          characterStats: [],
          moneyCoinCount: []);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result.length, 1);
      expect(result.first.$1, item1);
      expect(result.first.$2, 1);
    });

    test('Character with multiple items in inventory', () {
      // Arrange
      var item1 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var item2 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var item3 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid3',
          name: 'Potion',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2, item3],
          characterStatsDefinition: CharacterStatsDefinition(
            mainPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            secondaryPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            thirdPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            otherPlayerStats: [],
          ),
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var inventoryItem1 =
          RpgCharacterOwnedItemPair(itemUuid: 'uuid1', amount: 1);
      var inventoryItem2 =
          RpgCharacterOwnedItemPair(itemUuid: 'uuid2', amount: 2);
      var character = RpgCharacterConfiguration(
          inventory: [inventoryItem1, inventoryItem2],
          characterName: "",
          characterStats: [],
          moneyCoinCount: []);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result.length, 2);
      expect(result[0].$1, item1);
      expect(result[0].$2, 1);
      expect(result[1].$1, item2);
      expect(result[1].$2, 2);
    });

    test('Character with items not in global item list', () {
      // Arrange
      var item1 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var item2 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatsDefinition: CharacterStatsDefinition(
            mainPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            secondaryPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            thirdPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            otherPlayerStats: [],
          ),
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var inventoryItem1 = RpgCharacterOwnedItemPair(
          itemUuid: 'uuid3', amount: 5); // Not in rpgConfig.allItems
      var character = RpgCharacterConfiguration(
          inventory: [inventoryItem1],
          characterName: "",
          characterStats: [],
          moneyCoinCount: []);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result, isEmpty);
    });

    test('Character with items having zero quantity in inventory', () {
      // Arrange
      var item1 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var item2 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatsDefinition: CharacterStatsDefinition(
            mainPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            secondaryPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            thirdPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            otherPlayerStats: [],
          ),
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var inventoryItem1 =
          RpgCharacterOwnedItemPair(itemUuid: 'uuid1', amount: 0);
      var character = RpgCharacterConfiguration(
          inventory: [inventoryItem1],
          characterName: "",
          characterStats: [],
          moneyCoinCount: []);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result, isEmpty);
    });

    test('Character with all items from the list in inventory', () {
      // Arrange
      var item1 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var item2 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatsDefinition: CharacterStatsDefinition(
            mainPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            secondaryPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            thirdPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            otherPlayerStats: [],
          ),
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var inventoryItem1 =
          RpgCharacterOwnedItemPair(itemUuid: 'uuid1', amount: 2);
      var inventoryItem2 =
          RpgCharacterOwnedItemPair(itemUuid: 'uuid2', amount: 3);
      var character = RpgCharacterConfiguration(
          inventory: [inventoryItem1, inventoryItem2],
          characterName: "",
          characterStats: [],
          moneyCoinCount: []);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result.length, 2);
      expect(result[0].$1, item1);
      expect(result[0].$2, 2);
      expect(result[1].$1, item2);
      expect(result[1].$2, 3);
    });

    test(
        'Character with an empty inventory list but items in the global item list',
        () {
      // Arrange
      var item1 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var item2 = RpgItem(
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindingIds: null);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatsDefinition: CharacterStatsDefinition(
            mainPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            secondaryPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            thirdPlayerStat: CharacterStatDefinition(
                statUuid: "statUuid",
                name: "name",
                helperText: "helperText",
                valueType: CharacterStatValueType.string,
                editType: CharacterStatEditType.static),
            otherPlayerStats: [],
          ),
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var character = RpgCharacterConfiguration(
          inventory: [],
          characterName: "",
          characterStats: [],
          moneyCoinCount: []);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result, isEmpty);
    });
  });
}
