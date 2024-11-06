import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

void main() {
  group('RpgConfigurationModel tests', () {
    test('RpgConfigurationModel - json serializes correctly', () {
      // arrange
      final model = RpgConfigurationModel(
          rpgName: "DnD - Marie config",
          currencyDefinition: CurrencyDefinition(currencyTypes: [
            // 100 copper = 10 silver = 1 gold = 1/10 platinum
            CurrencyType(name: "Kupfer", multipleOfPreviousValue: null),
            CurrencyType(name: "Silber", multipleOfPreviousValue: 10),
            CurrencyType(name: "Gold", multipleOfPreviousValue: 10),
            CurrencyType(name: "Platin", multipleOfPreviousValue: 10),
          ]),
          characterStatTabsDefinition: [
            CharacterStatsTabDefinition(
                isDefaultTab: false,
                uuid: "38413393-765a-4718-b1b3-af6b3ee2a130",
                isOptional: false,
                tabName: "Test",
                statsInTab: [
                  CharacterStatDefinition(
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: 'stat1',
                    name: 'Strength',
                    helperText: 'Character strength',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: 'stat2',
                    name: 'Dexterity',
                    helperText: 'Character dexterity',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                  CharacterStatDefinition(
                    isOptionalForAlternateForms: false,
                    isOptionalForCompanionCharacters: false,
                    statUuid: 'stat3',
                    name: 'Intelligence',
                    helperText: 'Character intelligence',
                    valueType: CharacterStatValueType.int,
                    editType: CharacterStatEditType.static,
                  ),
                ]),
          ],
          itemCategories: [
            ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "0",
                name: "Kleidung",
                subCategories: [
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: "01",
                      name: "Rüstung",
                      subCategories: []),
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: "02",
                      name: "Accessoire",
                      subCategories: []),
                ]),
            ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "6",
                name: "Zutaten",
                subCategories: []),
            ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "1",
                name: "Trank",
                subCategories: [
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: "11",
                      name: "Heilung",
                      subCategories: []),
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: "12",
                      name: "Gift",
                      subCategories: []),
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: "13",
                      name: "Gegengift",
                      subCategories: []),
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: "14",
                      name: "Buff",
                      subCategories: []),
                ]),
            ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "2",
                name: "Waffen",
                subCategories: [
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: "21",
                      name: "Finesse",
                      subCategories: []),
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: "22",
                      name: "Fernkampf",
                      subCategories: []),
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: "23",
                      name: "Magie",
                      subCategories: []),
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: "24",
                      name: "Wurfwaffe",
                      subCategories: []),
                ]),
            ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "3",
                name: "Schätze",
                subCategories: []),
            ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "4",
                name: "Tools",
                subCategories: []),
            ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: "5",
                name: "Sonstiges",
                subCategories: []),
          ],
          placesOfFindings: [
            PlaceOfFinding(uuid: "wald", name: "Wald"),
            PlaceOfFinding(uuid: "grasland", name: "Grasland"),
            PlaceOfFinding(uuid: "berg", name: "Berg"),
            PlaceOfFinding(uuid: "steppe", name: "Steppe"),
            PlaceOfFinding(uuid: "wüste", name: "Wüste"),
            PlaceOfFinding(uuid: "savanne", name: "Savanne"),
            PlaceOfFinding(uuid: "sümpfe", name: "Sümpfe"),
            PlaceOfFinding(uuid: "höhle", name: "Höhle"),
          ],
          allItems: [
            RpgItem(
                imageDescription: null,
                imageUrlWithoutBasePath: null,
                uuid: "asdf",
                name: "Ascheveilchen",
                categoryId: "6",
                baseCurrencyPrice: 20000,
                patchSize: DiceRoll(numDice: 22, diceSides: 6, modifier: 1),
                placeOfFindings: [
                  RpgItemRarity(placeOfFindingId: "wald", diceChallenge: 2),
                  RpgItemRarity(placeOfFindingId: "berg", diceChallenge: 2)
                ],
                description: "Eine Beschreibung"),
            RpgItem(
                imageDescription: null,
                imageUrlWithoutBasePath: null,
                uuid: "asdfew",
                name: "Aloe Vera",
                categoryId: "6",
                baseCurrencyPrice: 200300,
                patchSize: DiceRoll(numDice: 22, diceSides: 6, modifier: 1),
                placeOfFindings: [
                  RpgItemRarity(placeOfFindingId: "savanne", diceChallenge: 22),
                  RpgItemRarity(placeOfFindingId: "wüste", diceChallenge: 2),
                  RpgItemRarity(placeOfFindingId: "steppe", diceChallenge: 2)
                ],
                description: "Eine Beschreibung"),
            RpgItem(
                imageDescription: null,
                imageUrlWithoutBasePath: null,
                uuid: "asdeefew",
                name: "Aurora Rose",
                categoryId: "6",
                baseCurrencyPrice: 2300,
                patchSize: DiceRoll(numDice: 22, diceSides: 6, modifier: 1),
                placeOfFindings: [
                  RpgItemRarity(placeOfFindingId: "wald", diceChallenge: 5),
                  RpgItemRarity(placeOfFindingId: "berg", diceChallenge: 2),
                  RpgItemRarity(placeOfFindingId: "grasland", diceChallenge: 2)
                ],
                description: "Eine Beschreibung"),
            RpgItem(
                imageDescription: null,
                imageUrlWithoutBasePath: null,
                uuid: "asde323efew",
                name: "Roter Amanita Pilz",
                categoryId: "6",
                baseCurrencyPrice: 232100,
                patchSize: DiceRoll(numDice: 22, diceSides: 6, modifier: 1),
                placeOfFindings: [
                  RpgItemRarity(placeOfFindingId: "wald", diceChallenge: 7),
                  RpgItemRarity(placeOfFindingId: "sümpfe", diceChallenge: 2),
                  RpgItemRarity(placeOfFindingId: "höhle", diceChallenge: 2)
                ],
                description: "Eine Beschreibung"),
            RpgItem(
                imageDescription: null,
                imageUrlWithoutBasePath: null,
                uuid: "Lebenslikörasdf",
                name: "Lebenslikör",
                categoryId: "11",
                patchSize: DiceRoll(numDice: 22, diceSides: 6, modifier: 1),
                baseCurrencyPrice: 232133300,
                placeOfFindings: [],
                description: "Eine Beschreibung"),
          ],
          craftingRecipes: [
            CraftingRecipe(
              requiredItemIds: [],
              recipeUuid: "123456789087654321",
              ingredients: [
                CraftingRecipeIngredientPair(
                    itemUuid: "asdfew", amountOfUsedItem: 1),
                CraftingRecipeIngredientPair(
                    itemUuid: "asdeefew", amountOfUsedItem: 1),
                CraftingRecipeIngredientPair(
                    itemUuid: "asde323efew", amountOfUsedItem: 1),
              ],
              createdItem: CraftingRecipeIngredientPair(
                  itemUuid: "Lebenslikörasdf", amountOfUsedItem: 1),
            )
          ]);

      // act
      var serializedText = jsonEncode(model);

      // assert
      expect(serializedText,
          '{"rpgName":"DnD - Marie config","allItems":[{"uuid":"asdf","name":"Ascheveilchen","description":"Eine Beschreibung","categoryId":"6","imageUrlWithoutBasePath":null,"imageDescription":null,"placeOfFindings":[{"placeOfFindingId":"wald","diceChallenge":2},{"placeOfFindingId":"berg","diceChallenge":2}],"patchSize":{"numDice":22,"diceSides":6,"modifier":1},"baseCurrencyPrice":20000},{"uuid":"asdfew","name":"Aloe Vera","description":"Eine Beschreibung","categoryId":"6","imageUrlWithoutBasePath":null,"imageDescription":null,"placeOfFindings":[{"placeOfFindingId":"savanne","diceChallenge":22},{"placeOfFindingId":"wüste","diceChallenge":2},{"placeOfFindingId":"steppe","diceChallenge":2}],"patchSize":{"numDice":22,"diceSides":6,"modifier":1},"baseCurrencyPrice":200300},{"uuid":"asdeefew","name":"Aurora Rose","description":"Eine Beschreibung","categoryId":"6","imageUrlWithoutBasePath":null,"imageDescription":null,"placeOfFindings":[{"placeOfFindingId":"wald","diceChallenge":5},{"placeOfFindingId":"berg","diceChallenge":2},{"placeOfFindingId":"grasland","diceChallenge":2}],"patchSize":{"numDice":22,"diceSides":6,"modifier":1},"baseCurrencyPrice":2300},{"uuid":"asde323efew","name":"Roter Amanita Pilz","description":"Eine Beschreibung","categoryId":"6","imageUrlWithoutBasePath":null,"imageDescription":null,"placeOfFindings":[{"placeOfFindingId":"wald","diceChallenge":7},{"placeOfFindingId":"sümpfe","diceChallenge":2},{"placeOfFindingId":"höhle","diceChallenge":2}],"patchSize":{"numDice":22,"diceSides":6,"modifier":1},"baseCurrencyPrice":232100},{"uuid":"Lebenslikörasdf","name":"Lebenslikör","description":"Eine Beschreibung","categoryId":"11","imageUrlWithoutBasePath":null,"imageDescription":null,"placeOfFindings":[],"patchSize":{"numDice":22,"diceSides":6,"modifier":1},"baseCurrencyPrice":232133300}],"placesOfFindings":[{"uuid":"wald","name":"Wald"},{"uuid":"grasland","name":"Grasland"},{"uuid":"berg","name":"Berg"},{"uuid":"steppe","name":"Steppe"},{"uuid":"wüste","name":"Wüste"},{"uuid":"savanne","name":"Savanne"},{"uuid":"sümpfe","name":"Sümpfe"},{"uuid":"höhle","name":"Höhle"}],"itemCategories":[{"uuid":"0","name":"Kleidung","subCategories":[{"uuid":"01","name":"Rüstung","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"02","name":"Accessoire","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"}],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"6","name":"Zutaten","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"1","name":"Trank","subCategories":[{"uuid":"11","name":"Heilung","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"12","name":"Gift","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"13","name":"Gegengift","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"14","name":"Buff","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"}],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"2","name":"Waffen","subCategories":[{"uuid":"21","name":"Finesse","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"22","name":"Fernkampf","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"23","name":"Magie","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"24","name":"Wurfwaffe","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"}],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"3","name":"Schätze","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"4","name":"Tools","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"},{"uuid":"5","name":"Sonstiges","subCategories":[],"hideInInventoryFilters":false,"colorCode":"#ffff00ff","iconName":"spellbook-svgrepo-com"}],"characterStatTabsDefinition":[{"uuid":"38413393-765a-4718-b1b3-af6b3ee2a130","tabName":"Test","isOptional":false,"isDefaultTab":false,"statsInTab":[{"name":"Strength","statUuid":"stat1","helperText":"Character strength","valueType":"int","editType":"static","isOptionalForAlternateForms":false,"isOptionalForCompanionCharacters":false,"jsonSerializedAdditionalData":null},{"name":"Dexterity","statUuid":"stat2","helperText":"Character dexterity","valueType":"int","editType":"static","isOptionalForAlternateForms":false,"isOptionalForCompanionCharacters":false,"jsonSerializedAdditionalData":null},{"name":"Intelligence","statUuid":"stat3","helperText":"Character intelligence","valueType":"int","editType":"static","isOptionalForAlternateForms":false,"isOptionalForCompanionCharacters":false,"jsonSerializedAdditionalData":null}]}],"craftingRecipes":[{"recipeUuid":"123456789087654321","ingredients":[{"itemUuid":"asdfew","amountOfUsedItem":1},{"itemUuid":"asdeefew","amountOfUsedItem":1},{"itemUuid":"asde323efew","amountOfUsedItem":1}],"createdItem":{"itemUuid":"Lebenslikörasdf","amountOfUsedItem":1},"requiredItemIds":[]}],"currencyDefinition":{"currencyTypes":[{"name":"Kupfer","multipleOfPreviousValue":null},{"name":"Silber","multipleOfPreviousValue":10},{"name":"Gold","multipleOfPreviousValue":10},{"name":"Platin","multipleOfPreviousValue":10}]}}');
    });
  });

  group('ItemCategory flattenCategoriesRecursive', () {
    late ItemCategory categoryA;
    late ItemCategory categoryB;
    late ItemCategory categoryA1;
    late ItemCategory categoryA2;
    late ItemCategory categoryB1;

    setUp(() {
      // Setup sample categories
      categoryA1 = ItemCategory(
        colorCode: "#ffff00ff",
        iconName: "spellbook-svgrepo-com",
        uuid: '1-1',
        name: 'Category A1',
        subCategories: [],
      );

      categoryA2 = ItemCategory(
        colorCode: "#ffff00ff",
        iconName: "spellbook-svgrepo-com",
        uuid: '1-2',
        name: 'Category A2',
        subCategories: [],
      );

      categoryA = ItemCategory(
        colorCode: "#ffff00ff",
        iconName: "spellbook-svgrepo-com",
        uuid: '1',
        name: 'Category A',
        subCategories: [categoryA1, categoryA2],
      );

      categoryB1 = ItemCategory(
        colorCode: "#ffff00ff",
        iconName: "spellbook-svgrepo-com",
        uuid: '2-1',
        name: 'Category B1',
        subCategories: [],
      );

      categoryB = ItemCategory(
        colorCode: "#ffff00ff",
        iconName: "spellbook-svgrepo-com",
        uuid: '2',
        name: 'Category B',
        subCategories: [categoryB1],
      );
    });

    test('should flatten categories without combining names', () {
      // Arrange
      final categories = [categoryA, categoryB];

      // Act
      final result = ItemCategory.flattenCategoriesRecursive(
        categories: categories,
        combineCategoryNames: false,
      );

      // Assert
      expect(result.length, equals(5));
      expect(result[0].name, equals('Category A'));
      expect(result[1].name, equals('Category A1'));
      expect(result[2].name, equals('Category A2'));
      expect(result[3].name, equals('Category B'));
      expect(result[4].name, equals('Category B1'));
    });

    test('should flatten categories with combined names', () {
      // Arrange
      final categories = [categoryA, categoryB];

      // Act
      final result = ItemCategory.flattenCategoriesRecursive(
        categories: categories,
        combineCategoryNames: true,
      );

      // Assert
      expect(result.length, equals(5));
      expect(result[0].name, equals('Category A'));
      expect(result[1].name, equals('Category A > Category A1'));
      expect(result[2].name, equals('Category A > Category A2'));
      expect(result[3].name, equals('Category B'));
      expect(result[4].name, equals('Category B > Category B1'));
    });

    test('should return empty list when no categories are passed', () {
      // Act
      final result = ItemCategory.flattenCategoriesRecursive(categories: []);

      // Assert
      expect(result, isEmpty);
    });

    test('should flatten deeply nested categories', () {
      // Arrange
      final deeplyNestedCategory = ItemCategory(
        colorCode: "#ffff00ff",
        iconName: "spellbook-svgrepo-com",
        uuid: '1',
        name: 'Category A',
        subCategories: [
          ItemCategory(
            colorCode: "#ffff00ff",
            iconName: "spellbook-svgrepo-com",
            uuid: '1-1',
            name: 'Category A1',
            subCategories: [
              ItemCategory(
                colorCode: "#ffff00ff",
                iconName: "spellbook-svgrepo-com",
                uuid: '1-1-1',
                name: 'Category A1A',
                subCategories: [],
              )
            ],
          )
        ],
      );

      // Act
      final result = ItemCategory.flattenCategoriesRecursive(
        categories: [deeplyNestedCategory],
        combineCategoryNames: true,
      );

      // Assert
      expect(result.length, equals(3));
      expect(result[0].name, equals('Category A'));
      expect(result[1].name, equals('Category A > Category A1'));
      expect(result[2].name, equals('Category A > Category A1 > Category A1A'));
    });
  });

  group('CurrencyDefinition', () {
    test('valueOfItemForDefinition returns correct result for simple case', () {
      final currencyDefinition = CurrencyDefinition(
        currencyTypes: [
          CurrencyType(name: "", multipleOfPreviousValue: 1),
          CurrencyType(name: "", multipleOfPreviousValue: 10),
          CurrencyType(name: "", multipleOfPreviousValue: 10),
        ],
      );

      final result =
          CurrencyDefinition.valueOfItemForDefinition(currencyDefinition, 155);
      expect(result, [1, 5, 5]); // Expecting 1 * 10 * 10 + 5 * 10 + 5 * 1 = 155
    });

    test('valueOfItemForDefinition returns correct result when no remainder',
        () {
      final currencyDefinition = CurrencyDefinition(
        currencyTypes: [
          CurrencyType(name: "", multipleOfPreviousValue: 1),
          CurrencyType(name: "", multipleOfPreviousValue: 10),
          CurrencyType(name: "", multipleOfPreviousValue: 10),
        ],
      );

      final result =
          CurrencyDefinition.valueOfItemForDefinition(currencyDefinition, 250);
      expect(result, [2, 5, 0]); // Expecting 2 * 100 + 5 * 10 = 250
    });

    test(
        'valueOfItemForDefinition returns correct result when base currency only',
        () {
      final currencyDefinition = CurrencyDefinition(
        currencyTypes: [
          CurrencyType(name: "", multipleOfPreviousValue: 1),
        ],
      );

      final result =
          CurrencyDefinition.valueOfItemForDefinition(currencyDefinition, 42);
      expect(result, [42]); // Only base currency should be used
    });

    test('valueOfItemForDefinition returns correct result for large values',
        () {
      final currencyDefinition = CurrencyDefinition(
        currencyTypes: [
          CurrencyType(name: "", multipleOfPreviousValue: 1),
          CurrencyType(name: "", multipleOfPreviousValue: 5),
          CurrencyType(name: "", multipleOfPreviousValue: 2),
        ],
      );

      final result =
          CurrencyDefinition.valueOfItemForDefinition(currencyDefinition, 387);
      expect(result, [38, 1, 2]); // Expecting 3 * 2 * 5 + 4 * 5 + 7 * 1 = 387
    });

    test('valueOfItemForDefinition handles zero base currency value', () {
      final currencyDefinition = CurrencyDefinition(
        currencyTypes: [
          CurrencyType(name: "", multipleOfPreviousValue: 1),
          CurrencyType(name: "", multipleOfPreviousValue: 10),
        ],
      );

      final result =
          CurrencyDefinition.valueOfItemForDefinition(currencyDefinition, 0);
      expect(result, [0, 0]); // Expecting 0 for both currencies
    });
  });
  group('DiceRoll.parse', () {
    test('parses "1D10+5" correctly', () {
      DiceRoll roll = DiceRoll.parse("1D10+5");
      expect(roll.numDice, equals(1));
      expect(roll.diceSides, equals(10));
      expect(roll.modifier, equals(5));
    });

    test('parses "2D6-1" correctly', () {
      DiceRoll roll = DiceRoll.parse("2D6-1");
      expect(roll.numDice, equals(2));
      expect(roll.diceSides, equals(6));
      expect(roll.modifier, equals(-1));
    });

    test('parses "8D4" without a modifier correctly', () {
      DiceRoll roll = DiceRoll.parse("8D4");
      expect(roll.numDice, equals(8));
      expect(roll.diceSides, equals(4));
      expect(roll.modifier, equals(0)); // No modifier means it defaults to 0
    });

    test('parses "D20" with implicit 1 dice correctly', () {
      DiceRoll roll = DiceRoll.parse("D20");
      expect(roll.numDice, equals(1)); // Implicit 1 dice
      expect(roll.diceSides, equals(20));
      expect(roll.modifier, equals(0)); // No modifier means it defaults to 0
    });

    test('parses "1W10+5" correctly', () {
      DiceRoll roll = DiceRoll.parse("1W10+5");
      expect(roll.numDice, equals(1));
      expect(roll.diceSides, equals(10));
      expect(roll.modifier, equals(5));
    });

    test('parses "2W6-1" correctly', () {
      DiceRoll roll = DiceRoll.parse("2W6-1");
      expect(roll.numDice, equals(2));
      expect(roll.diceSides, equals(6));
      expect(roll.modifier, equals(-1));
    });

    test('parses "8W4" without a modifier correctly', () {
      DiceRoll roll = DiceRoll.parse("8W4");
      expect(roll.numDice, equals(8));
      expect(roll.diceSides, equals(4));
      expect(roll.modifier, equals(0)); // No modifier means it defaults to 0
    });

    test('parses "W20" with implicit 1 dice correctly', () {
      DiceRoll roll = DiceRoll.parse("W20");
      expect(roll.numDice, equals(1)); // Implicit 1 dice
      expect(roll.diceSides, equals(20));
      expect(roll.modifier, equals(0)); // No modifier means it defaults to 0
    });

    test('throws FormatException for invalid input', () {
      expect(() => DiceRoll.parse("Invalid"), throwsFormatException);
      expect(() => DiceRoll.parse("2D"), throwsFormatException);
      expect(() => DiceRoll.parse("D"), throwsFormatException);
      expect(() => DiceRoll.parse("W"), throwsFormatException);
      expect(() => DiceRoll.parse("2W"), throwsFormatException);
    });
  });

  group('DiceRoll.roll', () {
    test('rolls a dice with no modifier and number of dice 1 correctly', () {
      DiceRoll roll = DiceRoll(numDice: 1, diceSides: 6, modifier: 0);

      for (int i = 0; i < 100; i++) {
        int result = roll.roll();
        expect(result, inInclusiveRange(1, 6));
      }
    });

    test('rolls multiple dice with a positive modifier', () {
      DiceRoll roll = DiceRoll(numDice: 2, diceSides: 6, modifier: 3);

      for (int i = 0; i < 100; i++) {
        int result = roll.roll();
        expect(
            result,
            inInclusiveRange(
                5, 15)); // 2D6 minimum is 2, max is 12, plus 3 modifier
      }
    });

    test('rolls multiple dice with a negative modifier', () {
      DiceRoll roll = DiceRoll(numDice: 3, diceSides: 4, modifier: -2);

      for (int i = 0; i < 100; i++) {
        int result = roll.roll();
        expect(result,
            inInclusiveRange(1, 10)); // 3D4 min is 3, max is 12, minus 2
      }
    });

    test('handles rolls of single dice with large number of sides', () {
      DiceRoll roll = DiceRoll(numDice: 1, diceSides: 100, modifier: 0);

      for (int i = 0; i < 100; i++) {
        int result = roll.roll();
        expect(result, inInclusiveRange(1, 100)); // 1D100 min is 1, max is 100
      }
    });
  });

  group('DiceRoll.toString', () {
    test('formats correctly for positive modifier', () {
      DiceRoll roll = DiceRoll(numDice: 1, diceSides: 10, modifier: 5);
      expect(roll.toString(), equals('1D10+5'));
    });

    test('formats correctly for negative modifier', () {
      DiceRoll roll = DiceRoll(numDice: 2, diceSides: 6, modifier: -1);
      expect(roll.toString(), equals('2D6-1'));
    });

    test('formats correctly without modifier', () {
      DiceRoll roll = DiceRoll(numDice: 8, diceSides: 4, modifier: 0);
      expect(roll.toString(), equals('8D4'));
    });

    test('formats correctly for single dice without explicit number', () {
      DiceRoll roll = DiceRoll(numDice: 1, diceSides: 20, modifier: 0);
      expect(roll.toString(), equals('1D20'));
    });
  });
  group('DiceRoll.parse with random spaces and characters', () {
    test('parses "1 D 1 0 + 5" correctly', () {
      DiceRoll roll = DiceRoll.parse("1 D 1 0 + 5");
      expect(roll.numDice, equals(1));
      expect(roll.diceSides, equals(10));
      expect(roll.modifier, equals(5));
    });

    test('parses "  2  W6   - 1  " correctly', () {
      DiceRoll roll = DiceRoll.parse("  2  W6   - 1  ");
      expect(roll.numDice, equals(2));
      expect(roll.diceSides, equals(6));
      expect(roll.modifier, equals(-1));
    });

    test('parses "W  20" with random spaces correctly', () {
      DiceRoll roll = DiceRoll.parse("W  20");
      expect(roll.numDice, equals(1)); // Implicit 1 dice
      expect(roll.diceSides, equals(20));
      expect(roll.modifier, equals(0)); // No modifier
    });

    test('parses " 1D6+1abc!@#" with random characters correctly', () {
      DiceRoll roll = DiceRoll.parse(" 1D6+1abc!@#");
      expect(roll.numDice, equals(1));
      expect(roll.diceSides, equals(6));
      expect(roll.modifier, equals(1));
    });

    test('throws FormatException for invalid input', () {
      expect(() => DiceRoll.parse("Invalid"), throwsFormatException);
      expect(() => DiceRoll.parse("2X"),
          throwsFormatException); // Invalid delimiter 'X'
    });
  });
}
