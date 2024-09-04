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
          characterStatsDefinition: CharacterStatsDefinition(
              mainPlayerStat: CharacterStatDefinition(
                statUuid: "5251c0bb-02ee-405b-b697-8e6ff0482983",
                name: "HP",
                helperText: "Lebenspunkte",
                valueType: CharacterStatValueType.intWithMaxValue,
                editType: CharacterStatEditType.oneTap,
              ),
              secondaryPlayerStat: CharacterStatDefinition(
                statUuid: "d728a934-6b3d-4548-9fe9-53a42e88712b",
                name: "AC",
                helperText: "Rüstungsklasse",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.static,
              ),
              thirdPlayerStat: CharacterStatDefinition(
                statUuid: "8882935f-a3e8-42b3-9b38-0d87aa71df73",
                name: "SP",
                helperText: "Geschwindigkeit",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.static,
              ),
              otherPlayerStats: [
                CharacterStatDefinition(
                  statUuid: "9ff51b8e-59a2-427f-8236-3ab6933ded5b",
                  name: "Class",
                  helperText: "The main class of your character.",
                  valueType: CharacterStatValueType.string,
                  editType: CharacterStatEditType.static,
                ),
                // TODO add list of bools as type (for selection of skills)
                // TODO add list of ints as type (for base stats)
                // TODO add list of strings as type (for features)
              ]),
          itemCategories: [
            ItemCategory(uuid: "0", name: "Kleidung", subCategories: [
              ItemCategory(uuid: "01", name: "Rüstung", subCategories: []),
              ItemCategory(uuid: "02", name: "Accessoire", subCategories: []),
            ]),
            ItemCategory(uuid: "6", name: "Zutaten", subCategories: []),
            ItemCategory(uuid: "1", name: "Trank", subCategories: [
              ItemCategory(uuid: "11", name: "Heilung", subCategories: []),
              ItemCategory(uuid: "12", name: "Gift", subCategories: []),
              ItemCategory(uuid: "13", name: "Gegengift", subCategories: []),
              ItemCategory(uuid: "14", name: "Buff", subCategories: []),
            ]),
            ItemCategory(uuid: "2", name: "Waffen", subCategories: [
              ItemCategory(uuid: "21", name: "Finesse", subCategories: []),
              ItemCategory(uuid: "22", name: "Fernkampf", subCategories: []),
              ItemCategory(uuid: "23", name: "Magie", subCategories: []),
              ItemCategory(uuid: "24", name: "Wurfwaffe", subCategories: []),
            ]),
            ItemCategory(uuid: "3", name: "Schätze", subCategories: []),
            ItemCategory(uuid: "4", name: "Tools", subCategories: []),
            ItemCategory(uuid: "5", name: "Sonstiges", subCategories: []),
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
                uuid: "asdf",
                name: "Ascheveilchen",
                categoryId: "6",
                baseCurrencyPrice: 20000,
                placeOfFindingIds: ["wald", "berg"],
                description: "Eine Beschreibung"),
            RpgItem(
                uuid: "asdfew",
                name: "Aloe Vera",
                categoryId: "6",
                baseCurrencyPrice: 200300,
                placeOfFindingIds: ["savanne", "wüste", "steppe"],
                description: "Eine Beschreibung"),
            RpgItem(
                uuid: "asdeefew",
                name: "Aurora Rose",
                categoryId: "6",
                baseCurrencyPrice: 2300,
                placeOfFindingIds: ["wald", "berg", "grasland"],
                description: "Eine Beschreibung"),
            RpgItem(
                uuid: "asde323efew",
                name: "Roter Amanita Pilz",
                categoryId: "6",
                baseCurrencyPrice: 232100,
                placeOfFindingIds: ["wald", "sümpfe", "höhle"],
                description: "Eine Beschreibung"),
            RpgItem(
                uuid: "Lebenslikörasdf",
                name: "Lebenslikör",
                categoryId: "11",
                baseCurrencyPrice: 232133300,
                placeOfFindingIds: null,
                description: "Eine Beschreibung"),
          ],
          craftingRecipes: [
            CraftingRecipe(
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
      expect(serializedText != null, true);

      // debugLog(serializedText, "uuidErrorCode");
      expect(serializedText,
          '{"rpgName":"DnD - Marie config","allItems":[{"uuid":"asdf","name":"Ascheveilchen","description":"Eine Beschreibung","categoryId":"6","placeOfFindingIds":["wald","berg"],"baseCurrencyPrice":20000},{"uuid":"asdfew","name":"Aloe Vera","description":"Eine Beschreibung","categoryId":"6","placeOfFindingIds":["savanne","wüste","steppe"],"baseCurrencyPrice":200300},{"uuid":"asdeefew","name":"Aurora Rose","description":"Eine Beschreibung","categoryId":"6","placeOfFindingIds":["wald","berg","grasland"],"baseCurrencyPrice":2300},{"uuid":"asde323efew","name":"Roter Amanita Pilz","description":"Eine Beschreibung","categoryId":"6","placeOfFindingIds":["wald","sümpfe","höhle"],"baseCurrencyPrice":232100},{"uuid":"Lebenslikörasdf","name":"Lebenslikör","description":"Eine Beschreibung","categoryId":"11","placeOfFindingIds":null,"baseCurrencyPrice":232133300}],"placesOfFindings":[{"uuid":"wald","name":"Wald"},{"uuid":"grasland","name":"Grasland"},{"uuid":"berg","name":"Berg"},{"uuid":"steppe","name":"Steppe"},{"uuid":"wüste","name":"Wüste"},{"uuid":"savanne","name":"Savanne"},{"uuid":"sümpfe","name":"Sümpfe"},{"uuid":"höhle","name":"Höhle"}],"itemCategories":[{"uuid":"0","name":"Kleidung","subCategories":[{"uuid":"01","name":"Rüstung","subCategories":[],"hideInInventoryFilters":false},{"uuid":"02","name":"Accessoire","subCategories":[],"hideInInventoryFilters":false}],"hideInInventoryFilters":false},{"uuid":"6","name":"Zutaten","subCategories":[],"hideInInventoryFilters":false},{"uuid":"1","name":"Trank","subCategories":[{"uuid":"11","name":"Heilung","subCategories":[],"hideInInventoryFilters":false},{"uuid":"12","name":"Gift","subCategories":[],"hideInInventoryFilters":false},{"uuid":"13","name":"Gegengift","subCategories":[],"hideInInventoryFilters":false},{"uuid":"14","name":"Buff","subCategories":[],"hideInInventoryFilters":false}],"hideInInventoryFilters":false},{"uuid":"2","name":"Waffen","subCategories":[{"uuid":"21","name":"Finesse","subCategories":[],"hideInInventoryFilters":false},{"uuid":"22","name":"Fernkampf","subCategories":[],"hideInInventoryFilters":false},{"uuid":"23","name":"Magie","subCategories":[],"hideInInventoryFilters":false},{"uuid":"24","name":"Wurfwaffe","subCategories":[],"hideInInventoryFilters":false}],"hideInInventoryFilters":false},{"uuid":"3","name":"Schätze","subCategories":[],"hideInInventoryFilters":false},{"uuid":"4","name":"Tools","subCategories":[],"hideInInventoryFilters":false},{"uuid":"5","name":"Sonstiges","subCategories":[],"hideInInventoryFilters":false}],"characterStatsDefinition":{"mainPlayerStat":{"name":"HP","statUuid":"5251c0bb-02ee-405b-b697-8e6ff0482983","helperText":"Lebenspunkte","valueType":"intWithMaxValue","editType":"oneTap"},"secondaryPlayerStat":{"name":"AC","statUuid":"d728a934-6b3d-4548-9fe9-53a42e88712b","helperText":"Rüstungsklasse","valueType":"int","editType":"static"},"thirdPlayerStat":{"name":"SP","statUuid":"8882935f-a3e8-42b3-9b38-0d87aa71df73","helperText":"Geschwindigkeit","valueType":"int","editType":"static"},"otherPlayerStats":[{"name":"Class","statUuid":"9ff51b8e-59a2-427f-8236-3ab6933ded5b","helperText":"The main class of your character.","valueType":"string","editType":"static"}]},"craftingRecipes":[{"recipeUuid":"123456789087654321","ingredients":[{"itemUuid":"asdfew","amountOfUsedItem":1},{"itemUuid":"asdeefew","amountOfUsedItem":1},{"itemUuid":"asde323efew","amountOfUsedItem":1}],"createdItem":{"itemUuid":"Lebenslikörasdf","amountOfUsedItem":1}}],"currencyDefinition":{"currencyTypes":[{"name":"Kupfer","multipleOfPreviousValue":null},{"name":"Silber","multipleOfPreviousValue":10},{"name":"Gold","multipleOfPreviousValue":10},{"name":"Platin","multipleOfPreviousValue":10}]}}');
    });
  });
}
