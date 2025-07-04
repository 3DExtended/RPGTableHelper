import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/rpg_model_helpers.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

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
                imageDescription: null,
                imageUrlWithoutBasePath: null,
                uuid: 'item1',
                name: 'Iron Ore',
                categoryId: 'cat1',
                baseCurrencyPrice: 10,
                patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
                placeOfFindings: [
                  RpgItemRarity(placeOfFindingId: "place1", diceChallenge: 3)
                ],
                description: "Eine Beschreibung"),
            RpgItem(
                imageDescription: null,
                imageUrlWithoutBasePath: null,
                uuid: 'item2',
                name: 'Wood',
                categoryId: 'cat1',
                baseCurrencyPrice: 5,
                patchSize: DiceRoll(numDice: 2, diceSides: 10, modifier: 7),
                placeOfFindings: [
                  RpgItemRarity(placeOfFindingId: "place1", diceChallenge: 3)
                ],
                description: "Eine Beschreibung"),
            RpgItem(
                imageDescription: null,
                imageUrlWithoutBasePath: null,
                uuid: 'item3',
                name: 'Iron Sword',
                categoryId: 'cat2',
                baseCurrencyPrice: 50,
                patchSize: DiceRoll(numDice: 3, diceSides: 6, modifier: 1),
                placeOfFindings: [
                  RpgItemRarity(placeOfFindingId: "place2", diceChallenge: 3)
                ],
                description: "Eine Beschreibung"),
          ],
          placesOfFindings: [],
          itemCategories: [],
          characterStatTabsDefinition: [
            CharacterStatsTabDefinition(
                isDefaultTab: false,
                uuid: "8416802b-4785-446d-af1d-c6bd97385810",
                isOptional: false,
                tabName: "Test",
                statsInTab: [
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat1',
                    name: 'Strength',
                    helperText: 'Character strength',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat2',
                    name: 'Dexterity',
                    helperText: 'Character dexterity',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat3',
                    name: 'Intelligence',
                    helperText: 'Character intelligence',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                ]),
          ],
          currencyDefinition: CurrencyDefinition(
            currencyTypes: [
              CurrencyType(name: 'Gold', multipleOfPreviousValue: 1),
            ],
          ),
          craftingRecipes: [
            CraftingRecipe(
              requiredItemIds: [],
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
          tabConfigurations: null,
          transformationComponents: null,
          alternateForm: null,
          isAlternateFormActive: null,
          alternateForms: [],
          companionCharacters: [],
          uuid: "f2d956b6-a739-451a-8213-c60a2337868d",
          characterName: 'Hero',
          moneyInBaseType: 100,
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
            requiredItemIds: [],
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
            requiredItemIds: [],
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
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          categoryId: "",
          placeOfFindings: []);
      var item2 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          patchSize: DiceRoll(numDice: 5, diceSides: 6, modifier: 1),
          placeOfFindings: []);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatTabsDefinition: [
            CharacterStatsTabDefinition(
                isDefaultTab: false,
                uuid: "bb06054e-7507-4234-8e9e-5625ab3d726d",
                isOptional: false,
                tabName: "Test",
                statsInTab: [
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat1',
                    name: 'Strength',
                    helperText: 'Character strength',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat2',
                    name: 'Dexterity',
                    helperText: 'Character dexterity',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat3',
                    name: 'Intelligence',
                    helperText: 'Character intelligence',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                ]),
          ],
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var character = RpgCharacterConfiguration(
          tabConfigurations: null,
          transformationComponents: null,
          alternateForm: null,
          isAlternateFormActive: null,
          alternateForms: [],
          companionCharacters: [],
          uuid: "70cafb00-e08a-473c-9d57-10b712c5b9b0",
          inventory: [],
          characterName: "",
          characterStats: [],
          moneyInBaseType: 0);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result, isEmpty);
    });

    test('Character with one item in inventory', () {
      // Arrange
      var item1 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var item2 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatTabsDefinition: [
            CharacterStatsTabDefinition(
                isDefaultTab: false,
                uuid: "c76e99fe-e57f-431c-96b4-3dab8b26d7f2",
                isOptional: false,
                tabName: "Test",
                statsInTab: [
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat1',
                    name: 'Strength',
                    helperText: 'Character strength',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat2',
                    name: 'Dexterity',
                    helperText: 'Character dexterity',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat3',
                    name: 'Intelligence',
                    helperText: 'Character intelligence',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                ]),
          ],
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var inventoryItem =
          RpgCharacterOwnedItemPair(itemUuid: 'uuid1', amount: 1);
      var character = RpgCharacterConfiguration(
          tabConfigurations: null,
          transformationComponents: null,
          alternateForm: null,
          isAlternateFormActive: null,
          alternateForms: [],
          companionCharacters: [],
          uuid: "b29172ae-c46d-4ac1-9736-8f70d56e53b1",
          inventory: [inventoryItem],
          characterName: "",
          characterStats: [],
          moneyInBaseType: 0);

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
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var item2 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var item3 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid3',
          name: 'Potion',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2, item3],
          characterStatTabsDefinition: [
            CharacterStatsTabDefinition(
                isDefaultTab: false,
                uuid: "9c71700e-886b-48d5-8030-6acccdfa31c5",
                isOptional: false,
                tabName: "Test",
                statsInTab: [
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat1',
                    name: 'Strength',
                    helperText: 'Character strength',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat2',
                    name: 'Dexterity',
                    helperText: 'Character dexterity',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat3',
                    name: 'Intelligence',
                    helperText: 'Character intelligence',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                ]),
          ],
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
          tabConfigurations: null,
          transformationComponents: null,
          alternateForm: null,
          isAlternateFormActive: null,
          alternateForms: [],
          companionCharacters: [],
          uuid: "09f070d6-dd4a-4b5b-bb92-9c085fa0b507",
          inventory: [inventoryItem1, inventoryItem2],
          characterName: "",
          characterStats: [],
          moneyInBaseType: 0);

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
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var item2 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatTabsDefinition: [
            CharacterStatsTabDefinition(
                isDefaultTab: false,
                uuid: "050845f9-fa4c-4dc1-897c-e81d633aadeb",
                isOptional: false,
                tabName: "Test",
                statsInTab: [
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat1',
                    name: 'Strength',
                    helperText: 'Character strength',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat2',
                    name: 'Dexterity',
                    helperText: 'Character dexterity',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat3',
                    name: 'Intelligence',
                    helperText: 'Character intelligence',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                ]),
          ],
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var inventoryItem1 = RpgCharacterOwnedItemPair(
          itemUuid: 'uuid3', amount: 5); // Not in rpgConfig.allItems
      var character = RpgCharacterConfiguration(
          tabConfigurations: null,
          transformationComponents: null,
          alternateForm: null,
          isAlternateFormActive: null,
          alternateForms: [],
          companionCharacters: [],
          uuid: "e7f433f9-4c48-47b6-bd14-927f7bd1a71a",
          inventory: [inventoryItem1],
          characterName: "",
          characterStats: [],
          moneyInBaseType: 0);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result, isEmpty);
    });

    test('Character with items having zero quantity in inventory', () {
      // Arrange
      var item1 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var item2 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatTabsDefinition: [
            CharacterStatsTabDefinition(
                isDefaultTab: false,
                uuid: "90e5a327-7f5e-48f2-8615-fa592be43efe",
                isOptional: false,
                tabName: "Test",
                statsInTab: [
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat1',
                    name: 'Strength',
                    helperText: 'Character strength',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat2',
                    name: 'Dexterity',
                    helperText: 'Character dexterity',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat3',
                    name: 'Intelligence',
                    helperText: 'Character intelligence',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                ]),
          ],
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var inventoryItem1 =
          RpgCharacterOwnedItemPair(itemUuid: 'uuid1', amount: 0);
      var character = RpgCharacterConfiguration(
          tabConfigurations: null,
          transformationComponents: null,
          alternateForm: null,
          isAlternateFormActive: null,
          alternateForms: [],
          companionCharacters: [],
          uuid: "b3d29e6d-05d1-4aa2-b17a-a8b0b541995f",
          inventory: [inventoryItem1],
          characterName: "",
          characterStats: [],
          moneyInBaseType: 0);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result, isEmpty);
    });

    test('Character with all items from the list in inventory', () {
      // Arrange
      var item1 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var item2 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatTabsDefinition: [
            CharacterStatsTabDefinition(
                isDefaultTab: false,
                uuid: "8f6faec8-26cd-42fd-88da-5b6e9a984aa5",
                isOptional: false,
                tabName: "Test",
                statsInTab: [
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat1',
                    name: 'Strength',
                    helperText: 'Character strength',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat2',
                    name: 'Dexterity',
                    helperText: 'Character dexterity',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat3',
                    name: 'Intelligence',
                    helperText: 'Character intelligence',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                ]),
          ],
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
          tabConfigurations: null,
          transformationComponents: null,
          alternateForm: null,
          isAlternateFormActive: null,
          alternateForms: [],
          companionCharacters: [],
          uuid: "0398ad10-1469-40e6-9e92-ef1ce483e284",
          inventory: [inventoryItem1, inventoryItem2],
          characterName: "",
          characterStats: [],
          moneyInBaseType: 0);

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
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid1',
          name: 'Sword',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var item2 = RpgItem(
          imageDescription: null,
          imageUrlWithoutBasePath: null,
          patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: -1),
          description: "Eine Beschreibung",
          uuid: 'uuid2',
          name: 'Shield',
          baseCurrencyPrice: 0,
          categoryId: "",
          placeOfFindings: []);
      var rpgConfig = RpgConfigurationModel(
          allItems: [item1, item2],
          characterStatTabsDefinition: [
            CharacterStatsTabDefinition(
                isDefaultTab: false,
                uuid: "d257e1cb-8ae2-4532-b078-bcb53235f2c0",
                isOptional: false,
                tabName: "Test",
                statsInTab: [
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat1',
                    name: 'Strength',
                    helperText: 'Character strength',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat2',
                    name: 'Dexterity',
                    helperText: 'Character dexterity',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    groupId: null,
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: null,
                    statUuid: 'stat3',
                    name: 'Intelligence',
                    helperText: 'Character intelligence',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                ]),
          ],
          craftingRecipes: [],
          currencyDefinition: CurrencyDefinition(currencyTypes: []),
          itemCategories: [],
          placesOfFindings: [],
          rpgName: "asdf");
      var character = RpgCharacterConfiguration(
          tabConfigurations: null,
          transformationComponents: null,
          alternateForm: null,
          isAlternateFormActive: null,
          alternateForms: [],
          companionCharacters: [],
          uuid: "cfada5f0-6f72-48d2-a5f6-4ab3d660ba0f",
          inventory: [],
          characterName: "",
          characterStats: [],
          moneyInBaseType: 0);

      // Act
      var result = getInventoryOfCharacter(rpgConfig, character);

      // Assert
      expect(result, isEmpty);
    });
  });
}
