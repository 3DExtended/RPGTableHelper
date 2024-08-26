// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpg_configuration_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RpgConfigurationModelCWProxy {
  RpgConfigurationModel rpgName(String rpgName);

  RpgConfigurationModel allItems(List<RpgItem> allItems);

  RpgConfigurationModel placesOfFindings(List<PlaceOfFinding> placesOfFindings);

  RpgConfigurationModel currencyDefinition(
      CurrencyDefinition currencyDefinition);

  RpgConfigurationModel itemCategories(List<ItemCategory> itemCategories);

  RpgConfigurationModel characterStatsDefinition(
      CharacterStatsDefinition characterStatsDefinition);

  RpgConfigurationModel craftingRecipes(List<CraftingRecipe> craftingRecipes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgConfigurationModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgConfigurationModel(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgConfigurationModel call({
    String? rpgName,
    List<RpgItem>? allItems,
    List<PlaceOfFinding>? placesOfFindings,
    CurrencyDefinition? currencyDefinition,
    List<ItemCategory>? itemCategories,
    CharacterStatsDefinition? characterStatsDefinition,
    List<CraftingRecipe>? craftingRecipes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRpgConfigurationModel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRpgConfigurationModel.copyWith.fieldName(...)`
class _$RpgConfigurationModelCWProxyImpl
    implements _$RpgConfigurationModelCWProxy {
  const _$RpgConfigurationModelCWProxyImpl(this._value);

  final RpgConfigurationModel _value;

  @override
  RpgConfigurationModel rpgName(String rpgName) => this(rpgName: rpgName);

  @override
  RpgConfigurationModel allItems(List<RpgItem> allItems) =>
      this(allItems: allItems);

  @override
  RpgConfigurationModel placesOfFindings(
          List<PlaceOfFinding> placesOfFindings) =>
      this(placesOfFindings: placesOfFindings);

  @override
  RpgConfigurationModel currencyDefinition(
          CurrencyDefinition currencyDefinition) =>
      this(currencyDefinition: currencyDefinition);

  @override
  RpgConfigurationModel itemCategories(List<ItemCategory> itemCategories) =>
      this(itemCategories: itemCategories);

  @override
  RpgConfigurationModel characterStatsDefinition(
          CharacterStatsDefinition characterStatsDefinition) =>
      this(characterStatsDefinition: characterStatsDefinition);

  @override
  RpgConfigurationModel craftingRecipes(List<CraftingRecipe> craftingRecipes) =>
      this(craftingRecipes: craftingRecipes);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgConfigurationModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgConfigurationModel(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgConfigurationModel call({
    Object? rpgName = const $CopyWithPlaceholder(),
    Object? allItems = const $CopyWithPlaceholder(),
    Object? placesOfFindings = const $CopyWithPlaceholder(),
    Object? currencyDefinition = const $CopyWithPlaceholder(),
    Object? itemCategories = const $CopyWithPlaceholder(),
    Object? characterStatsDefinition = const $CopyWithPlaceholder(),
    Object? craftingRecipes = const $CopyWithPlaceholder(),
  }) {
    return RpgConfigurationModel(
      rpgName: rpgName == const $CopyWithPlaceholder() || rpgName == null
          ? _value.rpgName
          // ignore: cast_nullable_to_non_nullable
          : rpgName as String,
      allItems: allItems == const $CopyWithPlaceholder() || allItems == null
          ? _value.allItems
          // ignore: cast_nullable_to_non_nullable
          : allItems as List<RpgItem>,
      placesOfFindings: placesOfFindings == const $CopyWithPlaceholder() ||
              placesOfFindings == null
          ? _value.placesOfFindings
          // ignore: cast_nullable_to_non_nullable
          : placesOfFindings as List<PlaceOfFinding>,
      currencyDefinition: currencyDefinition == const $CopyWithPlaceholder() ||
              currencyDefinition == null
          ? _value.currencyDefinition
          // ignore: cast_nullable_to_non_nullable
          : currencyDefinition as CurrencyDefinition,
      itemCategories: itemCategories == const $CopyWithPlaceholder() ||
              itemCategories == null
          ? _value.itemCategories
          // ignore: cast_nullable_to_non_nullable
          : itemCategories as List<ItemCategory>,
      characterStatsDefinition:
          characterStatsDefinition == const $CopyWithPlaceholder() ||
                  characterStatsDefinition == null
              ? _value.characterStatsDefinition
              // ignore: cast_nullable_to_non_nullable
              : characterStatsDefinition as CharacterStatsDefinition,
      craftingRecipes: craftingRecipes == const $CopyWithPlaceholder() ||
              craftingRecipes == null
          ? _value.craftingRecipes
          // ignore: cast_nullable_to_non_nullable
          : craftingRecipes as List<CraftingRecipe>,
    );
  }
}

extension $RpgConfigurationModelCopyWith on RpgConfigurationModel {
  /// Returns a callable class that can be used as follows: `instanceOfRpgConfigurationModel.copyWith(...)` or like so:`instanceOfRpgConfigurationModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgConfigurationModelCWProxy get copyWith =>
      _$RpgConfigurationModelCWProxyImpl(this);
}

abstract class _$ItemCategoryCWProxy {
  ItemCategory uuid(String uuid);

  ItemCategory name(String name);

  ItemCategory subCategories(List<ItemCategory>? subCategories);

  ItemCategory hideInInventoryFilters(bool hideInInventoryFilters);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ItemCategory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ItemCategory(...).copyWith(id: 12, name: "My name")
  /// ````
  ItemCategory call({
    String? uuid,
    String? name,
    List<ItemCategory>? subCategories,
    bool? hideInInventoryFilters,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfItemCategory.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfItemCategory.copyWith.fieldName(...)`
class _$ItemCategoryCWProxyImpl implements _$ItemCategoryCWProxy {
  const _$ItemCategoryCWProxyImpl(this._value);

  final ItemCategory _value;

  @override
  ItemCategory uuid(String uuid) => this(uuid: uuid);

  @override
  ItemCategory name(String name) => this(name: name);

  @override
  ItemCategory subCategories(List<ItemCategory>? subCategories) =>
      this(subCategories: subCategories);

  @override
  ItemCategory hideInInventoryFilters(bool hideInInventoryFilters) =>
      this(hideInInventoryFilters: hideInInventoryFilters);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ItemCategory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ItemCategory(...).copyWith(id: 12, name: "My name")
  /// ````
  ItemCategory call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? subCategories = const $CopyWithPlaceholder(),
    Object? hideInInventoryFilters = const $CopyWithPlaceholder(),
  }) {
    return ItemCategory(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      subCategories: subCategories == const $CopyWithPlaceholder()
          ? _value.subCategories
          // ignore: cast_nullable_to_non_nullable
          : subCategories as List<ItemCategory>?,
      hideInInventoryFilters:
          hideInInventoryFilters == const $CopyWithPlaceholder() ||
                  hideInInventoryFilters == null
              ? _value.hideInInventoryFilters
              // ignore: cast_nullable_to_non_nullable
              : hideInInventoryFilters as bool,
    );
  }
}

extension $ItemCategoryCopyWith on ItemCategory {
  /// Returns a callable class that can be used as follows: `instanceOfItemCategory.copyWith(...)` or like so:`instanceOfItemCategory.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ItemCategoryCWProxy get copyWith => _$ItemCategoryCWProxyImpl(this);
}

abstract class _$CurrencyTypeCWProxy {
  CurrencyType name(String name);

  CurrencyType multipleOfPreviousValue(int? multipleOfPreviousValue);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CurrencyType(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CurrencyType(...).copyWith(id: 12, name: "My name")
  /// ````
  CurrencyType call({
    String? name,
    int? multipleOfPreviousValue,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCurrencyType.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCurrencyType.copyWith.fieldName(...)`
class _$CurrencyTypeCWProxyImpl implements _$CurrencyTypeCWProxy {
  const _$CurrencyTypeCWProxyImpl(this._value);

  final CurrencyType _value;

  @override
  CurrencyType name(String name) => this(name: name);

  @override
  CurrencyType multipleOfPreviousValue(int? multipleOfPreviousValue) =>
      this(multipleOfPreviousValue: multipleOfPreviousValue);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CurrencyType(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CurrencyType(...).copyWith(id: 12, name: "My name")
  /// ````
  CurrencyType call({
    Object? name = const $CopyWithPlaceholder(),
    Object? multipleOfPreviousValue = const $CopyWithPlaceholder(),
  }) {
    return CurrencyType(
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      multipleOfPreviousValue:
          multipleOfPreviousValue == const $CopyWithPlaceholder()
              ? _value.multipleOfPreviousValue
              // ignore: cast_nullable_to_non_nullable
              : multipleOfPreviousValue as int?,
    );
  }
}

extension $CurrencyTypeCopyWith on CurrencyType {
  /// Returns a callable class that can be used as follows: `instanceOfCurrencyType.copyWith(...)` or like so:`instanceOfCurrencyType.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CurrencyTypeCWProxy get copyWith => _$CurrencyTypeCWProxyImpl(this);
}

abstract class _$CurrencyDefinitionCWProxy {
  CurrencyDefinition currencyTypes(List<CurrencyType> currencyTypes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CurrencyDefinition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CurrencyDefinition(...).copyWith(id: 12, name: "My name")
  /// ````
  CurrencyDefinition call({
    List<CurrencyType>? currencyTypes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCurrencyDefinition.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCurrencyDefinition.copyWith.fieldName(...)`
class _$CurrencyDefinitionCWProxyImpl implements _$CurrencyDefinitionCWProxy {
  const _$CurrencyDefinitionCWProxyImpl(this._value);

  final CurrencyDefinition _value;

  @override
  CurrencyDefinition currencyTypes(List<CurrencyType> currencyTypes) =>
      this(currencyTypes: currencyTypes);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CurrencyDefinition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CurrencyDefinition(...).copyWith(id: 12, name: "My name")
  /// ````
  CurrencyDefinition call({
    Object? currencyTypes = const $CopyWithPlaceholder(),
  }) {
    return CurrencyDefinition(
      currencyTypes:
          currencyTypes == const $CopyWithPlaceholder() || currencyTypes == null
              ? _value.currencyTypes
              // ignore: cast_nullable_to_non_nullable
              : currencyTypes as List<CurrencyType>,
    );
  }
}

extension $CurrencyDefinitionCopyWith on CurrencyDefinition {
  /// Returns a callable class that can be used as follows: `instanceOfCurrencyDefinition.copyWith(...)` or like so:`instanceOfCurrencyDefinition.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CurrencyDefinitionCWProxy get copyWith =>
      _$CurrencyDefinitionCWProxyImpl(this);
}

abstract class _$CraftingRecipeIngredientPairCWProxy {
  CraftingRecipeIngredientPair itemUuid(String itemUuid);

  CraftingRecipeIngredientPair amountOfUsedItem(int amountOfUsedItem);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CraftingRecipeIngredientPair(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CraftingRecipeIngredientPair(...).copyWith(id: 12, name: "My name")
  /// ````
  CraftingRecipeIngredientPair call({
    String? itemUuid,
    int? amountOfUsedItem,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCraftingRecipeIngredientPair.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCraftingRecipeIngredientPair.copyWith.fieldName(...)`
class _$CraftingRecipeIngredientPairCWProxyImpl
    implements _$CraftingRecipeIngredientPairCWProxy {
  const _$CraftingRecipeIngredientPairCWProxyImpl(this._value);

  final CraftingRecipeIngredientPair _value;

  @override
  CraftingRecipeIngredientPair itemUuid(String itemUuid) =>
      this(itemUuid: itemUuid);

  @override
  CraftingRecipeIngredientPair amountOfUsedItem(int amountOfUsedItem) =>
      this(amountOfUsedItem: amountOfUsedItem);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CraftingRecipeIngredientPair(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CraftingRecipeIngredientPair(...).copyWith(id: 12, name: "My name")
  /// ````
  CraftingRecipeIngredientPair call({
    Object? itemUuid = const $CopyWithPlaceholder(),
    Object? amountOfUsedItem = const $CopyWithPlaceholder(),
  }) {
    return CraftingRecipeIngredientPair(
      itemUuid: itemUuid == const $CopyWithPlaceholder() || itemUuid == null
          ? _value.itemUuid
          // ignore: cast_nullable_to_non_nullable
          : itemUuid as String,
      amountOfUsedItem: amountOfUsedItem == const $CopyWithPlaceholder() ||
              amountOfUsedItem == null
          ? _value.amountOfUsedItem
          // ignore: cast_nullable_to_non_nullable
          : amountOfUsedItem as int,
    );
  }
}

extension $CraftingRecipeIngredientPairCopyWith
    on CraftingRecipeIngredientPair {
  /// Returns a callable class that can be used as follows: `instanceOfCraftingRecipeIngredientPair.copyWith(...)` or like so:`instanceOfCraftingRecipeIngredientPair.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CraftingRecipeIngredientPairCWProxy get copyWith =>
      _$CraftingRecipeIngredientPairCWProxyImpl(this);
}

abstract class _$CraftingRecipeCWProxy {
  CraftingRecipe recipeUuid(String recipeUuid);

  CraftingRecipe ingredients(List<CraftingRecipeIngredientPair> ingredients);

  CraftingRecipe createdItem(CraftingRecipeIngredientPair createdItem);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CraftingRecipe(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CraftingRecipe(...).copyWith(id: 12, name: "My name")
  /// ````
  CraftingRecipe call({
    String? recipeUuid,
    List<CraftingRecipeIngredientPair>? ingredients,
    CraftingRecipeIngredientPair? createdItem,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCraftingRecipe.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCraftingRecipe.copyWith.fieldName(...)`
class _$CraftingRecipeCWProxyImpl implements _$CraftingRecipeCWProxy {
  const _$CraftingRecipeCWProxyImpl(this._value);

  final CraftingRecipe _value;

  @override
  CraftingRecipe recipeUuid(String recipeUuid) => this(recipeUuid: recipeUuid);

  @override
  CraftingRecipe ingredients(List<CraftingRecipeIngredientPair> ingredients) =>
      this(ingredients: ingredients);

  @override
  CraftingRecipe createdItem(CraftingRecipeIngredientPair createdItem) =>
      this(createdItem: createdItem);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CraftingRecipe(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CraftingRecipe(...).copyWith(id: 12, name: "My name")
  /// ````
  CraftingRecipe call({
    Object? recipeUuid = const $CopyWithPlaceholder(),
    Object? ingredients = const $CopyWithPlaceholder(),
    Object? createdItem = const $CopyWithPlaceholder(),
  }) {
    return CraftingRecipe(
      recipeUuid:
          recipeUuid == const $CopyWithPlaceholder() || recipeUuid == null
              ? _value.recipeUuid
              // ignore: cast_nullable_to_non_nullable
              : recipeUuid as String,
      ingredients:
          ingredients == const $CopyWithPlaceholder() || ingredients == null
              ? _value.ingredients
              // ignore: cast_nullable_to_non_nullable
              : ingredients as List<CraftingRecipeIngredientPair>,
      createdItem:
          createdItem == const $CopyWithPlaceholder() || createdItem == null
              ? _value.createdItem
              // ignore: cast_nullable_to_non_nullable
              : createdItem as CraftingRecipeIngredientPair,
    );
  }
}

extension $CraftingRecipeCopyWith on CraftingRecipe {
  /// Returns a callable class that can be used as follows: `instanceOfCraftingRecipe.copyWith(...)` or like so:`instanceOfCraftingRecipe.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CraftingRecipeCWProxy get copyWith => _$CraftingRecipeCWProxyImpl(this);
}

abstract class _$CharacterStatDefinitionCWProxy {
  CharacterStatDefinition statUuid(String statUuid);

  CharacterStatDefinition name(String name);

  CharacterStatDefinition helperText(String helperText);

  CharacterStatDefinition valueType(CharacterStatValueType valueType);

  CharacterStatDefinition editType(CharacterStatEditType editType);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CharacterStatDefinition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CharacterStatDefinition(...).copyWith(id: 12, name: "My name")
  /// ````
  CharacterStatDefinition call({
    String? statUuid,
    String? name,
    String? helperText,
    CharacterStatValueType? valueType,
    CharacterStatEditType? editType,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCharacterStatDefinition.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCharacterStatDefinition.copyWith.fieldName(...)`
class _$CharacterStatDefinitionCWProxyImpl
    implements _$CharacterStatDefinitionCWProxy {
  const _$CharacterStatDefinitionCWProxyImpl(this._value);

  final CharacterStatDefinition _value;

  @override
  CharacterStatDefinition statUuid(String statUuid) => this(statUuid: statUuid);

  @override
  CharacterStatDefinition name(String name) => this(name: name);

  @override
  CharacterStatDefinition helperText(String helperText) =>
      this(helperText: helperText);

  @override
  CharacterStatDefinition valueType(CharacterStatValueType valueType) =>
      this(valueType: valueType);

  @override
  CharacterStatDefinition editType(CharacterStatEditType editType) =>
      this(editType: editType);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CharacterStatDefinition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CharacterStatDefinition(...).copyWith(id: 12, name: "My name")
  /// ````
  CharacterStatDefinition call({
    Object? statUuid = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? helperText = const $CopyWithPlaceholder(),
    Object? valueType = const $CopyWithPlaceholder(),
    Object? editType = const $CopyWithPlaceholder(),
  }) {
    return CharacterStatDefinition(
      statUuid: statUuid == const $CopyWithPlaceholder() || statUuid == null
          ? _value.statUuid
          // ignore: cast_nullable_to_non_nullable
          : statUuid as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      helperText:
          helperText == const $CopyWithPlaceholder() || helperText == null
              ? _value.helperText
              // ignore: cast_nullable_to_non_nullable
              : helperText as String,
      valueType: valueType == const $CopyWithPlaceholder() || valueType == null
          ? _value.valueType
          // ignore: cast_nullable_to_non_nullable
          : valueType as CharacterStatValueType,
      editType: editType == const $CopyWithPlaceholder() || editType == null
          ? _value.editType
          // ignore: cast_nullable_to_non_nullable
          : editType as CharacterStatEditType,
    );
  }
}

extension $CharacterStatDefinitionCopyWith on CharacterStatDefinition {
  /// Returns a callable class that can be used as follows: `instanceOfCharacterStatDefinition.copyWith(...)` or like so:`instanceOfCharacterStatDefinition.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CharacterStatDefinitionCWProxy get copyWith =>
      _$CharacterStatDefinitionCWProxyImpl(this);
}

abstract class _$CharacterStatsDefinitionCWProxy {
  CharacterStatsDefinition mainPlayerStat(
      CharacterStatDefinition mainPlayerStat);

  CharacterStatsDefinition secondaryPlayerStat(
      CharacterStatDefinition secondaryPlayerStat);

  CharacterStatsDefinition thirdPlayerStat(
      CharacterStatDefinition thirdPlayerStat);

  CharacterStatsDefinition otherPlayerStats(
      List<CharacterStatDefinition> otherPlayerStats);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CharacterStatsDefinition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CharacterStatsDefinition(...).copyWith(id: 12, name: "My name")
  /// ````
  CharacterStatsDefinition call({
    CharacterStatDefinition? mainPlayerStat,
    CharacterStatDefinition? secondaryPlayerStat,
    CharacterStatDefinition? thirdPlayerStat,
    List<CharacterStatDefinition>? otherPlayerStats,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCharacterStatsDefinition.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCharacterStatsDefinition.copyWith.fieldName(...)`
class _$CharacterStatsDefinitionCWProxyImpl
    implements _$CharacterStatsDefinitionCWProxy {
  const _$CharacterStatsDefinitionCWProxyImpl(this._value);

  final CharacterStatsDefinition _value;

  @override
  CharacterStatsDefinition mainPlayerStat(
          CharacterStatDefinition mainPlayerStat) =>
      this(mainPlayerStat: mainPlayerStat);

  @override
  CharacterStatsDefinition secondaryPlayerStat(
          CharacterStatDefinition secondaryPlayerStat) =>
      this(secondaryPlayerStat: secondaryPlayerStat);

  @override
  CharacterStatsDefinition thirdPlayerStat(
          CharacterStatDefinition thirdPlayerStat) =>
      this(thirdPlayerStat: thirdPlayerStat);

  @override
  CharacterStatsDefinition otherPlayerStats(
          List<CharacterStatDefinition> otherPlayerStats) =>
      this(otherPlayerStats: otherPlayerStats);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CharacterStatsDefinition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CharacterStatsDefinition(...).copyWith(id: 12, name: "My name")
  /// ````
  CharacterStatsDefinition call({
    Object? mainPlayerStat = const $CopyWithPlaceholder(),
    Object? secondaryPlayerStat = const $CopyWithPlaceholder(),
    Object? thirdPlayerStat = const $CopyWithPlaceholder(),
    Object? otherPlayerStats = const $CopyWithPlaceholder(),
  }) {
    return CharacterStatsDefinition(
      mainPlayerStat: mainPlayerStat == const $CopyWithPlaceholder() ||
              mainPlayerStat == null
          ? _value.mainPlayerStat
          // ignore: cast_nullable_to_non_nullable
          : mainPlayerStat as CharacterStatDefinition,
      secondaryPlayerStat:
          secondaryPlayerStat == const $CopyWithPlaceholder() ||
                  secondaryPlayerStat == null
              ? _value.secondaryPlayerStat
              // ignore: cast_nullable_to_non_nullable
              : secondaryPlayerStat as CharacterStatDefinition,
      thirdPlayerStat: thirdPlayerStat == const $CopyWithPlaceholder() ||
              thirdPlayerStat == null
          ? _value.thirdPlayerStat
          // ignore: cast_nullable_to_non_nullable
          : thirdPlayerStat as CharacterStatDefinition,
      otherPlayerStats: otherPlayerStats == const $CopyWithPlaceholder() ||
              otherPlayerStats == null
          ? _value.otherPlayerStats
          // ignore: cast_nullable_to_non_nullable
          : otherPlayerStats as List<CharacterStatDefinition>,
    );
  }
}

extension $CharacterStatsDefinitionCopyWith on CharacterStatsDefinition {
  /// Returns a callable class that can be used as follows: `instanceOfCharacterStatsDefinition.copyWith(...)` or like so:`instanceOfCharacterStatsDefinition.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CharacterStatsDefinitionCWProxy get copyWith =>
      _$CharacterStatsDefinitionCWProxyImpl(this);
}

abstract class _$PlaceOfFindingCWProxy {
  PlaceOfFinding uuid(String uuid);

  PlaceOfFinding name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlaceOfFinding(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlaceOfFinding(...).copyWith(id: 12, name: "My name")
  /// ````
  PlaceOfFinding call({
    String? uuid,
    String? name,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlaceOfFinding.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlaceOfFinding.copyWith.fieldName(...)`
class _$PlaceOfFindingCWProxyImpl implements _$PlaceOfFindingCWProxy {
  const _$PlaceOfFindingCWProxyImpl(this._value);

  final PlaceOfFinding _value;

  @override
  PlaceOfFinding uuid(String uuid) => this(uuid: uuid);

  @override
  PlaceOfFinding name(String name) => this(name: name);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlaceOfFinding(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlaceOfFinding(...).copyWith(id: 12, name: "My name")
  /// ````
  PlaceOfFinding call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return PlaceOfFinding(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $PlaceOfFindingCopyWith on PlaceOfFinding {
  /// Returns a callable class that can be used as follows: `instanceOfPlaceOfFinding.copyWith(...)` or like so:`instanceOfPlaceOfFinding.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlaceOfFindingCWProxy get copyWith => _$PlaceOfFindingCWProxyImpl(this);
}

abstract class _$RpgItemCWProxy {
  RpgItem uuid(String uuid);

  RpgItem name(String name);

  RpgItem categoryId(String categoryId);

  RpgItem baseCurrencyPrice(int baseCurrencyPrice);

  RpgItem placeOfFindingIds(List<String>? placeOfFindingIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgItem(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgItem call({
    String? uuid,
    String? name,
    String? categoryId,
    int? baseCurrencyPrice,
    List<String>? placeOfFindingIds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRpgItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRpgItem.copyWith.fieldName(...)`
class _$RpgItemCWProxyImpl implements _$RpgItemCWProxy {
  const _$RpgItemCWProxyImpl(this._value);

  final RpgItem _value;

  @override
  RpgItem uuid(String uuid) => this(uuid: uuid);

  @override
  RpgItem name(String name) => this(name: name);

  @override
  RpgItem categoryId(String categoryId) => this(categoryId: categoryId);

  @override
  RpgItem baseCurrencyPrice(int baseCurrencyPrice) =>
      this(baseCurrencyPrice: baseCurrencyPrice);

  @override
  RpgItem placeOfFindingIds(List<String>? placeOfFindingIds) =>
      this(placeOfFindingIds: placeOfFindingIds);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgItem(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgItem call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? categoryId = const $CopyWithPlaceholder(),
    Object? baseCurrencyPrice = const $CopyWithPlaceholder(),
    Object? placeOfFindingIds = const $CopyWithPlaceholder(),
  }) {
    return RpgItem(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      categoryId:
          categoryId == const $CopyWithPlaceholder() || categoryId == null
              ? _value.categoryId
              // ignore: cast_nullable_to_non_nullable
              : categoryId as String,
      baseCurrencyPrice: baseCurrencyPrice == const $CopyWithPlaceholder() ||
              baseCurrencyPrice == null
          ? _value.baseCurrencyPrice
          // ignore: cast_nullable_to_non_nullable
          : baseCurrencyPrice as int,
      placeOfFindingIds: placeOfFindingIds == const $CopyWithPlaceholder()
          ? _value.placeOfFindingIds
          // ignore: cast_nullable_to_non_nullable
          : placeOfFindingIds as List<String>?,
    );
  }
}

extension $RpgItemCopyWith on RpgItem {
  /// Returns a callable class that can be used as follows: `instanceOfRpgItem.copyWith(...)` or like so:`instanceOfRpgItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgItemCWProxy get copyWith => _$RpgItemCWProxyImpl(this);
}

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
