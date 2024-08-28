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
        currencyDefinition: CurrencyDefinition(currencyTypes: []),
        itemCategories: [],
        placesOfFindings: [],
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
