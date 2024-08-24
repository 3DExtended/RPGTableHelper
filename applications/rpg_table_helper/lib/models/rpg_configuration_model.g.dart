// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpg_configuration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpgConfigurationModel _$RpgConfigurationModelFromJson(
        Map<String, dynamic> json) =>
    RpgConfigurationModel(
      rpgName: json['rpgName'] as String,
      allItems: (json['allItems'] as List<dynamic>)
          .map((e) => RpgItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      placesOfFindings: (json['placesOfFindings'] as List<dynamic>)
          .map((e) => PlaceOfFinding.fromJson(e as Map<String, dynamic>))
          .toList(),
      currencyDefinition: CurrencyDefinition.fromJson(
          json['currencyDefinition'] as Map<String, dynamic>),
      itemCategories: (json['itemCategories'] as List<dynamic>)
          .map((e) => ItemCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      characterStatsDefinition: CharacterStatsDefinition.fromJson(
          json['characterStatsDefinition'] as Map<String, dynamic>),
      craftingRecipes: (json['craftingRecipes'] as List<dynamic>)
          .map((e) => CraftingRecipe.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RpgConfigurationModelToJson(
        RpgConfigurationModel instance) =>
    <String, dynamic>{
      'rpgName': instance.rpgName,
      'allItems': instance.allItems,
      'placesOfFindings': instance.placesOfFindings,
      'itemCategories': instance.itemCategories,
      'characterStatsDefinition': instance.characterStatsDefinition,
      'craftingRecipes': instance.craftingRecipes,
      'currencyDefinition': instance.currencyDefinition,
    };

ItemCategory _$ItemCategoryFromJson(Map<String, dynamic> json) => ItemCategory(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) => ItemCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      hideInInventoryFilters: json['hideInInventoryFilters'] as bool? ?? false,
    );

Map<String, dynamic> _$ItemCategoryToJson(ItemCategory instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'subCategories': instance.subCategories,
      'hideInInventoryFilters': instance.hideInInventoryFilters,
    };

CurrencyType _$CurrencyTypeFromJson(Map<String, dynamic> json) => CurrencyType(
      name: json['name'] as String,
      multipleOfPreviousValue:
          (json['multipleOfPreviousValue'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CurrencyTypeToJson(CurrencyType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'multipleOfPreviousValue': instance.multipleOfPreviousValue,
    };

CurrencyDefinition _$CurrencyDefinitionFromJson(Map<String, dynamic> json) =>
    CurrencyDefinition(
      currencyTypes: (json['currencyTypes'] as List<dynamic>)
          .map((e) => CurrencyType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CurrencyDefinitionToJson(CurrencyDefinition instance) =>
    <String, dynamic>{
      'currencyTypes': instance.currencyTypes,
    };

CraftingRecipeIngredientPair _$CraftingRecipeIngredientPairFromJson(
        Map<String, dynamic> json) =>
    CraftingRecipeIngredientPair(
      itemUuid: json['itemUuid'] as String,
      amountOfUsedItem: (json['amountOfUsedItem'] as num).toInt(),
    );

Map<String, dynamic> _$CraftingRecipeIngredientPairToJson(
        CraftingRecipeIngredientPair instance) =>
    <String, dynamic>{
      'itemUuid': instance.itemUuid,
      'amountOfUsedItem': instance.amountOfUsedItem,
    };

CraftingRecipe _$CraftingRecipeFromJson(Map<String, dynamic> json) =>
    CraftingRecipe(
      recipeUuid: json['recipeUuid'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) =>
              CraftingRecipeIngredientPair.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdItem: CraftingRecipeIngredientPair.fromJson(
          json['createdItem'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CraftingRecipeToJson(CraftingRecipe instance) =>
    <String, dynamic>{
      'recipeUuid': instance.recipeUuid,
      'ingredients': instance.ingredients,
      'createdItem': instance.createdItem,
    };

CharacterStatDefinition _$CharacterStatDefinitionFromJson(
        Map<String, dynamic> json) =>
    CharacterStatDefinition(
      statUuid: json['statUuid'] as String,
      name: json['name'] as String,
      helperText: json['helperText'] as String,
      valueType:
          $enumDecode(_$CharacterStatValueTypeEnumMap, json['valueType']),
      editType: $enumDecode(_$CharacterStatEditTypeEnumMap, json['editType']),
    );

Map<String, dynamic> _$CharacterStatDefinitionToJson(
        CharacterStatDefinition instance) =>
    <String, dynamic>{
      'name': instance.name,
      'statUuid': instance.statUuid,
      'helperText': instance.helperText,
      'valueType': _$CharacterStatValueTypeEnumMap[instance.valueType]!,
      'editType': _$CharacterStatEditTypeEnumMap[instance.editType]!,
    };

const _$CharacterStatValueTypeEnumMap = {
  CharacterStatValueType.string: 'string',
  CharacterStatValueType.int: 'int',
  CharacterStatValueType.intWithMaxValue: 'intWithMaxValue',
  CharacterStatValueType.bool: 'bool',
  CharacterStatValueType.double: 'double',
};

const _$CharacterStatEditTypeEnumMap = {
  CharacterStatEditType.static: 'static',
  CharacterStatEditType.oneTap: 'oneTap',
};

CharacterStatsDefinition _$CharacterStatsDefinitionFromJson(
        Map<String, dynamic> json) =>
    CharacterStatsDefinition(
      mainPlayerStat: CharacterStatDefinition.fromJson(
          json['mainPlayerStat'] as Map<String, dynamic>),
      secondaryPlayerStat: CharacterStatDefinition.fromJson(
          json['secondaryPlayerStat'] as Map<String, dynamic>),
      thirdPlayerStat: CharacterStatDefinition.fromJson(
          json['thirdPlayerStat'] as Map<String, dynamic>),
      otherPlayerStats: (json['otherPlayerStats'] as List<dynamic>)
          .map((e) =>
              CharacterStatDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CharacterStatsDefinitionToJson(
        CharacterStatsDefinition instance) =>
    <String, dynamic>{
      'mainPlayerStat': instance.mainPlayerStat,
      'secondaryPlayerStat': instance.secondaryPlayerStat,
      'thirdPlayerStat': instance.thirdPlayerStat,
      'otherPlayerStats': instance.otherPlayerStats,
    };

PlaceOfFinding _$PlaceOfFindingFromJson(Map<String, dynamic> json) =>
    PlaceOfFinding(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$PlaceOfFindingToJson(PlaceOfFinding instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
    };

RpgItem _$RpgItemFromJson(Map<String, dynamic> json) => RpgItem(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      baseCurrencyPrice: (json['baseCurrencyPrice'] as num).toInt(),
      placeOfFindingIds: (json['placeOfFindingIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$RpgItemToJson(RpgItem instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'categoryId': instance.categoryId,
      'placeOfFindingIds': instance.placeOfFindingIds,
      'baseCurrencyPrice': instance.baseCurrencyPrice,
    };
