import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rpg_configuration_model.g.dart';

@JsonSerializable()
@CopyWith()
class RpgConfigurationModel {
  final String rpgName;
  final List<RpgItem> allItems;
  final List<PlaceOfFinding> placesOfFindings;
  final List<ItemCategory> itemCategories;
  final CharacterStatsDefinition characterStatsDefinition;
  final List<CraftingRecipe> craftingRecipes;
  final CurrencyDefinition currencyDefinition;

  factory RpgConfigurationModel.fromJson(Map<String, dynamic> json) =>
      _$RpgConfigurationModelFromJson(json);

  RpgConfigurationModel({
    required this.rpgName,
    required this.allItems,
    required this.placesOfFindings,
    required this.currencyDefinition,
    required this.itemCategories,
    required this.characterStatsDefinition,
    required this.craftingRecipes,
  });

  Map<String, dynamic> toJson() => _$RpgConfigurationModelToJson(this);

  static RpgConfigurationModel getBaseConfiguration() => RpgConfigurationModel(
        rpgName: "Maries Kampagne",
        currencyDefinition: CurrencyDefinition(
          currencyTypes: [
            CurrencyType(name: "Kupfer", multipleOfPreviousValue: null),
            CurrencyType(name: "Silber", multipleOfPreviousValue: 10),
            CurrencyType(name: "Gold", multipleOfPreviousValue: 10),
            CurrencyType(name: "Platin", multipleOfPreviousValue: 10),
          ],
        ),
        placesOfFindings: [
          PlaceOfFinding(
            uuid: "5b9690c1-afc9-436d-8912-d223c440eb6a",
            name: "Berge",
          ),
          PlaceOfFinding(
            uuid: "4a9abc76-df97-4790-9abe-cee5f6bec8a7",
            name: "Höhlen",
          ),
          PlaceOfFinding(
            uuid: "f4e2605a-1d22-45e8-92d6-44534eafdc44",
            name: "Wiesen",
          ),
          PlaceOfFinding(
            uuid: "2ed1f4ca-8ae0-4945-8771-5f74cf7ac546",
            name: "Wüste",
          ),
          PlaceOfFinding(
            uuid: "8ea924d4-7160-48dd-9d7f-5afa04c27048",
            name: "Wälder",
          ),
        ],
        itemCategories: [
          ItemCategory(
            uuid: "d0a0168f-02d0-4205-b0af-689b52f24186",
            name: "Kleidung",
            subCategories: [
              ItemCategory(
                uuid: "263dc67f-bfae-4559-a909-1479e24354a6",
                name: "Rüstung",
                subCategories: null,
              ),
              ItemCategory(
                uuid: "544cdaac-a8d2-4ee6-8a8f-4772bfb95a93",
                name: "Accessoire",
                subCategories: null,
              ),
            ],
          ),
          ItemCategory(
            uuid: "b895a30a-2c0a-4aba-8629-9a363e405281",
            name: "Zutaten",
            subCategories: null,
          ),
          ItemCategory(
            uuid: "4bba577f-c4c0-43a4-bc70-cbb39cbb7bee",
            name: "Trank",
            subCategories: [
              ItemCategory(
                uuid: "79773521-2fd6-4aff-942e-87b9e4bb6599",
                name: "Heilung",
                subCategories: null,
              ),
              ItemCategory(
                uuid: "64031e58-a816-4c84-9ca8-d80cd514a908",
                name: "Gift",
                subCategories: null,
              ),
              ItemCategory(
                uuid: "b0b0b636-6637-48c2-a899-4bd62435dba0",
                name: "Gegengift",
                subCategories: null,
              ),
              ItemCategory(
                uuid: "04b75751-0a85-4d82-8b66-361f47743797",
                name: "Buff",
                subCategories: null,
              ),
            ],
          ),
          ItemCategory(
            uuid: "f9cc6513-36b4-4e4e-b3ba-dd9f40fca078",
            name: "Waffen",
            subCategories: [
              ItemCategory(
                uuid: "1666d606-b839-4664-930d-2f51b552111c",
                name: "Finesse",
                subCategories: null,
              ),
              ItemCategory(
                uuid: "4ab9bded-a516-4a1b-a66d-fd5d972957cf",
                name: "Fernkampf",
                subCategories: null,
              ),
              ItemCategory(
                uuid: "8d86c1df-fe26-420d-8ccf-f5ef0af535a3",
                name: "Magie",
                subCategories: null,
              ),
              ItemCategory(
                uuid: "1d21556e-8993-4883-a9a5-f9853697f21e",
                name: "Wurfwaffe",
                subCategories: null,
              ),
            ],
          ),
          ItemCategory(
            uuid: "c7690cb0-39b4-45d2-b7c5-75b6e8eeb88f",
            name: "Schätze",
            subCategories: null,
          ),
          ItemCategory(
            uuid: "f9f4ba0d-9314-4f70-b7ba-fa6375490c70",
            name: "Tools",
            subCategories: null,
          ),
          ItemCategory(
            uuid: "06996121-b48d-4660-91f3-540bc91b0186",
            name: "Sonstiges",
            subCategories: null,
          ),
        ],
        allItems: [],
        craftingRecipes: [],
        characterStatsDefinition: CharacterStatsDefinition(
            mainPlayerStat: CharacterStatDefinition(
                statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
                name: "HP",
                helperText: "Health Points",
                valueType: CharacterStatValueType.intWithMaxValue,
                editType: CharacterStatEditType.oneTap),
            secondaryPlayerStat: CharacterStatDefinition(
                statUuid: "886df3c2-a93f-47ae-931f-86153997860d",
                name: "AC",
                helperText: "Armor Class",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.static),
            thirdPlayerStat: CharacterStatDefinition(
                statUuid: "082e62cb-7c17-4702-8529-172fb8e74c04",
                name: "SP",
                helperText: "Speed",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.static),
            otherPlayerStats: []),
      );
}

@JsonSerializable()
@CopyWith()
class ItemCategory {
  final String uuid;
  final String name;
  final List<ItemCategory>? subCategories;
  final bool hideInInventoryFilters;

  factory ItemCategory.fromJson(Map<String, dynamic> json) =>
      _$ItemCategoryFromJson(json);

  ItemCategory({
    required this.uuid,
    required this.name,
    required this.subCategories,
    this.hideInInventoryFilters = false,
  });

  Map<String, dynamic> toJson() => _$ItemCategoryToJson(this);
}

@JsonSerializable()
@CopyWith()
class CurrencyType {
  final String name;
  final int? multipleOfPreviousValue;
  CurrencyType({
    required this.name,
    required this.multipleOfPreviousValue,
  });

  factory CurrencyType.fromJson(Map<String, dynamic> json) =>
      _$CurrencyTypeFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyTypeToJson(this);
}

@JsonSerializable()
@CopyWith()
class CurrencyDefinition {
  final List<CurrencyType> currencyTypes;
  CurrencyDefinition({
    required this.currencyTypes,
  });

  factory CurrencyDefinition.fromJson(Map<String, dynamic> json) =>
      _$CurrencyDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyDefinitionToJson(this);
}

@JsonSerializable()
@CopyWith()
class CraftingRecipeIngredientPair {
  final String itemUuid;
  final int amountOfUsedItem;
  CraftingRecipeIngredientPair({
    required this.itemUuid,
    required this.amountOfUsedItem,
  });

  factory CraftingRecipeIngredientPair.fromJson(Map<String, dynamic> json) =>
      _$CraftingRecipeIngredientPairFromJson(json);

  Map<String, dynamic> toJson() => _$CraftingRecipeIngredientPairToJson(this);
}

@JsonSerializable()
@CopyWith()
class CraftingRecipe {
  final String recipeUuid;
  final List<CraftingRecipeIngredientPair> ingredients;
  final CraftingRecipeIngredientPair createdItem;

  CraftingRecipe({
    required this.recipeUuid,
    required this.ingredients,
    required this.createdItem,
  });
  factory CraftingRecipe.fromJson(Map<String, dynamic> json) =>
      _$CraftingRecipeFromJson(json);

  Map<String, dynamic> toJson() => _$CraftingRecipeToJson(this);
}

@JsonEnum()
enum CharacterStatEditType {
  static,
  oneTap,
}

@JsonEnum()
enum CharacterStatValueType {
  string,
  int,
  intWithMaxValue,
  bool,
  double,
}

@JsonSerializable()
@CopyWith()
class CharacterStatDefinition {
  final String name;
  final String statUuid;
  final String helperText;
  final CharacterStatValueType valueType;
  final CharacterStatEditType editType;

  CharacterStatDefinition({
    required this.statUuid,
    required this.name,
    required this.helperText,
    required this.valueType,
    required this.editType,
  });

  factory CharacterStatDefinition.fromJson(Map<String, dynamic> json) =>
      _$CharacterStatDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterStatDefinitionToJson(this);
}

@JsonSerializable()
@CopyWith()
class CharacterStatsDefinition {
  final CharacterStatDefinition mainPlayerStat;
  final CharacterStatDefinition secondaryPlayerStat;
  final CharacterStatDefinition thirdPlayerStat;
  final List<CharacterStatDefinition> otherPlayerStats;
  CharacterStatsDefinition({
    required this.mainPlayerStat,
    required this.secondaryPlayerStat,
    required this.thirdPlayerStat,
    required this.otherPlayerStats,
  });

  factory CharacterStatsDefinition.fromJson(Map<String, dynamic> json) =>
      _$CharacterStatsDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterStatsDefinitionToJson(this);
}

@JsonSerializable()
@CopyWith()
class PlaceOfFinding {
  final String uuid;
  final String name;

  factory PlaceOfFinding.fromJson(Map<String, dynamic> json) =>
      _$PlaceOfFindingFromJson(json);

  PlaceOfFinding({
    required this.uuid,
    required this.name,
  });

  Map<String, dynamic> toJson() => _$PlaceOfFindingToJson(this);
}

@JsonSerializable()
@CopyWith()
class RpgItem {
  final String uuid;
  final String name;
  final String categoryId;

  final List<String>? placeOfFindingIds;

  /// price without looking at the exchange rates. always a multiple of the smalles currency definition
  final int baseCurrencyPrice;

  factory RpgItem.fromJson(Map<String, dynamic> json) =>
      _$RpgItemFromJson(json);

  RpgItem({
    required this.uuid,
    required this.name,
    required this.categoryId,
    required this.baseCurrencyPrice,
    required this.placeOfFindingIds,
  });

  Map<String, dynamic> toJson() => _$RpgItemToJson(this);
}
