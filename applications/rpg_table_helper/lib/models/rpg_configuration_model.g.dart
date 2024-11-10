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

  RpgConfigurationModel characterStatTabsDefinition(
      List<CharacterStatsTabDefinition>? characterStatTabsDefinition);

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
    List<CharacterStatsTabDefinition>? characterStatTabsDefinition,
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
  RpgConfigurationModel characterStatTabsDefinition(
          List<CharacterStatsTabDefinition>? characterStatTabsDefinition) =>
      this(characterStatTabsDefinition: characterStatTabsDefinition);

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
    Object? characterStatTabsDefinition = const $CopyWithPlaceholder(),
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
      characterStatTabsDefinition: characterStatTabsDefinition ==
              const $CopyWithPlaceholder()
          ? _value.characterStatTabsDefinition
          // ignore: cast_nullable_to_non_nullable
          : characterStatTabsDefinition as List<CharacterStatsTabDefinition>?,
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

  ItemCategory colorCode(String? colorCode);

  ItemCategory iconName(String? iconName);

  ItemCategory subCategories(List<ItemCategory> subCategories);

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
    String? colorCode,
    String? iconName,
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
  ItemCategory colorCode(String? colorCode) => this(colorCode: colorCode);

  @override
  ItemCategory iconName(String? iconName) => this(iconName: iconName);

  @override
  ItemCategory subCategories(List<ItemCategory> subCategories) =>
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
    Object? colorCode = const $CopyWithPlaceholder(),
    Object? iconName = const $CopyWithPlaceholder(),
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
      colorCode: colorCode == const $CopyWithPlaceholder()
          ? _value.colorCode
          // ignore: cast_nullable_to_non_nullable
          : colorCode as String?,
      iconName: iconName == const $CopyWithPlaceholder()
          ? _value.iconName
          // ignore: cast_nullable_to_non_nullable
          : iconName as String?,
      subCategories:
          subCategories == const $CopyWithPlaceholder() || subCategories == null
              ? _value.subCategories
              // ignore: cast_nullable_to_non_nullable
              : subCategories as List<ItemCategory>,
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

  CraftingRecipe requiredItemIds(List<String> requiredItemIds);

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
    List<String>? requiredItemIds,
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
  CraftingRecipe requiredItemIds(List<String> requiredItemIds) =>
      this(requiredItemIds: requiredItemIds);

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
    Object? requiredItemIds = const $CopyWithPlaceholder(),
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
      requiredItemIds: requiredItemIds == const $CopyWithPlaceholder() ||
              requiredItemIds == null
          ? _value.requiredItemIds
          // ignore: cast_nullable_to_non_nullable
          : requiredItemIds as List<String>,
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

  CharacterStatDefinition groupId(int? groupId);

  CharacterStatDefinition helperText(String helperText);

  CharacterStatDefinition valueType(CharacterStatValueType valueType);

  CharacterStatDefinition editType(CharacterStatEditType editType);

  CharacterStatDefinition isOptionalForAlternateForms(
      bool? isOptionalForAlternateForms);

  CharacterStatDefinition isOptionalForCompanionCharacters(
      bool? isOptionalForCompanionCharacters);

  CharacterStatDefinition jsonSerializedAdditionalData(
      String? jsonSerializedAdditionalData);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CharacterStatDefinition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CharacterStatDefinition(...).copyWith(id: 12, name: "My name")
  /// ````
  CharacterStatDefinition call({
    String? statUuid,
    String? name,
    int? groupId,
    String? helperText,
    CharacterStatValueType? valueType,
    CharacterStatEditType? editType,
    bool? isOptionalForAlternateForms,
    bool? isOptionalForCompanionCharacters,
    String? jsonSerializedAdditionalData,
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
  CharacterStatDefinition groupId(int? groupId) => this(groupId: groupId);

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
  CharacterStatDefinition isOptionalForAlternateForms(
          bool? isOptionalForAlternateForms) =>
      this(isOptionalForAlternateForms: isOptionalForAlternateForms);

  @override
  CharacterStatDefinition isOptionalForCompanionCharacters(
          bool? isOptionalForCompanionCharacters) =>
      this(isOptionalForCompanionCharacters: isOptionalForCompanionCharacters);

  @override
  CharacterStatDefinition jsonSerializedAdditionalData(
          String? jsonSerializedAdditionalData) =>
      this(jsonSerializedAdditionalData: jsonSerializedAdditionalData);

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
    Object? groupId = const $CopyWithPlaceholder(),
    Object? helperText = const $CopyWithPlaceholder(),
    Object? valueType = const $CopyWithPlaceholder(),
    Object? editType = const $CopyWithPlaceholder(),
    Object? isOptionalForAlternateForms = const $CopyWithPlaceholder(),
    Object? isOptionalForCompanionCharacters = const $CopyWithPlaceholder(),
    Object? jsonSerializedAdditionalData = const $CopyWithPlaceholder(),
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
      groupId: groupId == const $CopyWithPlaceholder()
          ? _value.groupId
          // ignore: cast_nullable_to_non_nullable
          : groupId as int?,
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
      isOptionalForAlternateForms:
          isOptionalForAlternateForms == const $CopyWithPlaceholder()
              ? _value.isOptionalForAlternateForms
              // ignore: cast_nullable_to_non_nullable
              : isOptionalForAlternateForms as bool?,
      isOptionalForCompanionCharacters:
          isOptionalForCompanionCharacters == const $CopyWithPlaceholder()
              ? _value.isOptionalForCompanionCharacters
              // ignore: cast_nullable_to_non_nullable
              : isOptionalForCompanionCharacters as bool?,
      jsonSerializedAdditionalData:
          jsonSerializedAdditionalData == const $CopyWithPlaceholder()
              ? _value.jsonSerializedAdditionalData
              // ignore: cast_nullable_to_non_nullable
              : jsonSerializedAdditionalData as String?,
    );
  }
}

extension $CharacterStatDefinitionCopyWith on CharacterStatDefinition {
  /// Returns a callable class that can be used as follows: `instanceOfCharacterStatDefinition.copyWith(...)` or like so:`instanceOfCharacterStatDefinition.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CharacterStatDefinitionCWProxy get copyWith =>
      _$CharacterStatDefinitionCWProxyImpl(this);
}

abstract class _$CharacterStatsTabDefinitionCWProxy {
  CharacterStatsTabDefinition uuid(String uuid);

  CharacterStatsTabDefinition tabName(String tabName);

  CharacterStatsTabDefinition isOptional(bool isOptional);

  CharacterStatsTabDefinition statsInTab(
      List<CharacterStatDefinition> statsInTab);

  CharacterStatsTabDefinition isDefaultTab(bool isDefaultTab);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CharacterStatsTabDefinition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CharacterStatsTabDefinition(...).copyWith(id: 12, name: "My name")
  /// ````
  CharacterStatsTabDefinition call({
    String? uuid,
    String? tabName,
    bool? isOptional,
    List<CharacterStatDefinition>? statsInTab,
    bool? isDefaultTab,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCharacterStatsTabDefinition.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCharacterStatsTabDefinition.copyWith.fieldName(...)`
class _$CharacterStatsTabDefinitionCWProxyImpl
    implements _$CharacterStatsTabDefinitionCWProxy {
  const _$CharacterStatsTabDefinitionCWProxyImpl(this._value);

  final CharacterStatsTabDefinition _value;

  @override
  CharacterStatsTabDefinition uuid(String uuid) => this(uuid: uuid);

  @override
  CharacterStatsTabDefinition tabName(String tabName) => this(tabName: tabName);

  @override
  CharacterStatsTabDefinition isOptional(bool isOptional) =>
      this(isOptional: isOptional);

  @override
  CharacterStatsTabDefinition statsInTab(
          List<CharacterStatDefinition> statsInTab) =>
      this(statsInTab: statsInTab);

  @override
  CharacterStatsTabDefinition isDefaultTab(bool isDefaultTab) =>
      this(isDefaultTab: isDefaultTab);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CharacterStatsTabDefinition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CharacterStatsTabDefinition(...).copyWith(id: 12, name: "My name")
  /// ````
  CharacterStatsTabDefinition call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? tabName = const $CopyWithPlaceholder(),
    Object? isOptional = const $CopyWithPlaceholder(),
    Object? statsInTab = const $CopyWithPlaceholder(),
    Object? isDefaultTab = const $CopyWithPlaceholder(),
  }) {
    return CharacterStatsTabDefinition(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      tabName: tabName == const $CopyWithPlaceholder() || tabName == null
          ? _value.tabName
          // ignore: cast_nullable_to_non_nullable
          : tabName as String,
      isOptional:
          isOptional == const $CopyWithPlaceholder() || isOptional == null
              ? _value.isOptional
              // ignore: cast_nullable_to_non_nullable
              : isOptional as bool,
      statsInTab:
          statsInTab == const $CopyWithPlaceholder() || statsInTab == null
              ? _value.statsInTab
              // ignore: cast_nullable_to_non_nullable
              : statsInTab as List<CharacterStatDefinition>,
      isDefaultTab:
          isDefaultTab == const $CopyWithPlaceholder() || isDefaultTab == null
              ? _value.isDefaultTab
              // ignore: cast_nullable_to_non_nullable
              : isDefaultTab as bool,
    );
  }
}

extension $CharacterStatsTabDefinitionCopyWith on CharacterStatsTabDefinition {
  /// Returns a callable class that can be used as follows: `instanceOfCharacterStatsTabDefinition.copyWith(...)` or like so:`instanceOfCharacterStatsTabDefinition.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CharacterStatsTabDefinitionCWProxy get copyWith =>
      _$CharacterStatsTabDefinitionCWProxyImpl(this);
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

abstract class _$RpgItemRarityCWProxy {
  RpgItemRarity placeOfFindingId(String placeOfFindingId);

  RpgItemRarity diceChallenge(int diceChallenge);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgItemRarity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgItemRarity(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgItemRarity call({
    String? placeOfFindingId,
    int? diceChallenge,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRpgItemRarity.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRpgItemRarity.copyWith.fieldName(...)`
class _$RpgItemRarityCWProxyImpl implements _$RpgItemRarityCWProxy {
  const _$RpgItemRarityCWProxyImpl(this._value);

  final RpgItemRarity _value;

  @override
  RpgItemRarity placeOfFindingId(String placeOfFindingId) =>
      this(placeOfFindingId: placeOfFindingId);

  @override
  RpgItemRarity diceChallenge(int diceChallenge) =>
      this(diceChallenge: diceChallenge);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgItemRarity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgItemRarity(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgItemRarity call({
    Object? placeOfFindingId = const $CopyWithPlaceholder(),
    Object? diceChallenge = const $CopyWithPlaceholder(),
  }) {
    return RpgItemRarity(
      placeOfFindingId: placeOfFindingId == const $CopyWithPlaceholder() ||
              placeOfFindingId == null
          ? _value.placeOfFindingId
          // ignore: cast_nullable_to_non_nullable
          : placeOfFindingId as String,
      diceChallenge:
          diceChallenge == const $CopyWithPlaceholder() || diceChallenge == null
              ? _value.diceChallenge
              // ignore: cast_nullable_to_non_nullable
              : diceChallenge as int,
    );
  }
}

extension $RpgItemRarityCopyWith on RpgItemRarity {
  /// Returns a callable class that can be used as follows: `instanceOfRpgItemRarity.copyWith(...)` or like so:`instanceOfRpgItemRarity.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgItemRarityCWProxy get copyWith => _$RpgItemRarityCWProxyImpl(this);
}

abstract class _$RpgItemCWProxy {
  RpgItem uuid(String uuid);

  RpgItem name(String name);

  RpgItem imageUrlWithoutBasePath(String? imageUrlWithoutBasePath);

  RpgItem patchSize(DiceRoll? patchSize);

  RpgItem categoryId(String categoryId);

  RpgItem description(String description);

  RpgItem imageDescription(String? imageDescription);

  RpgItem baseCurrencyPrice(int baseCurrencyPrice);

  RpgItem placeOfFindings(List<RpgItemRarity> placeOfFindings);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgItem(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgItem call({
    String? uuid,
    String? name,
    String? imageUrlWithoutBasePath,
    DiceRoll? patchSize,
    String? categoryId,
    String? description,
    String? imageDescription,
    int? baseCurrencyPrice,
    List<RpgItemRarity>? placeOfFindings,
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
  RpgItem imageUrlWithoutBasePath(String? imageUrlWithoutBasePath) =>
      this(imageUrlWithoutBasePath: imageUrlWithoutBasePath);

  @override
  RpgItem patchSize(DiceRoll? patchSize) => this(patchSize: patchSize);

  @override
  RpgItem categoryId(String categoryId) => this(categoryId: categoryId);

  @override
  RpgItem description(String description) => this(description: description);

  @override
  RpgItem imageDescription(String? imageDescription) =>
      this(imageDescription: imageDescription);

  @override
  RpgItem baseCurrencyPrice(int baseCurrencyPrice) =>
      this(baseCurrencyPrice: baseCurrencyPrice);

  @override
  RpgItem placeOfFindings(List<RpgItemRarity> placeOfFindings) =>
      this(placeOfFindings: placeOfFindings);

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
    Object? imageUrlWithoutBasePath = const $CopyWithPlaceholder(),
    Object? patchSize = const $CopyWithPlaceholder(),
    Object? categoryId = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? imageDescription = const $CopyWithPlaceholder(),
    Object? baseCurrencyPrice = const $CopyWithPlaceholder(),
    Object? placeOfFindings = const $CopyWithPlaceholder(),
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
      imageUrlWithoutBasePath:
          imageUrlWithoutBasePath == const $CopyWithPlaceholder()
              ? _value.imageUrlWithoutBasePath
              // ignore: cast_nullable_to_non_nullable
              : imageUrlWithoutBasePath as String?,
      patchSize: patchSize == const $CopyWithPlaceholder()
          ? _value.patchSize
          // ignore: cast_nullable_to_non_nullable
          : patchSize as DiceRoll?,
      categoryId:
          categoryId == const $CopyWithPlaceholder() || categoryId == null
              ? _value.categoryId
              // ignore: cast_nullable_to_non_nullable
              : categoryId as String,
      description:
          description == const $CopyWithPlaceholder() || description == null
              ? _value.description
              // ignore: cast_nullable_to_non_nullable
              : description as String,
      imageDescription: imageDescription == const $CopyWithPlaceholder()
          ? _value.imageDescription
          // ignore: cast_nullable_to_non_nullable
          : imageDescription as String?,
      baseCurrencyPrice: baseCurrencyPrice == const $CopyWithPlaceholder() ||
              baseCurrencyPrice == null
          ? _value.baseCurrencyPrice
          // ignore: cast_nullable_to_non_nullable
          : baseCurrencyPrice as int,
      placeOfFindings: placeOfFindings == const $CopyWithPlaceholder() ||
              placeOfFindings == null
          ? _value.placeOfFindings
          // ignore: cast_nullable_to_non_nullable
          : placeOfFindings as List<RpgItemRarity>,
    );
  }
}

extension $RpgItemCopyWith on RpgItem {
  /// Returns a callable class that can be used as follows: `instanceOfRpgItem.copyWith(...)` or like so:`instanceOfRpgItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgItemCWProxy get copyWith => _$RpgItemCWProxyImpl(this);
}

abstract class _$DiceRollCWProxy {
  DiceRoll numDice(int numDice);

  DiceRoll diceSides(int diceSides);

  DiceRoll modifier(int modifier);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DiceRoll(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DiceRoll(...).copyWith(id: 12, name: "My name")
  /// ````
  DiceRoll call({
    int? numDice,
    int? diceSides,
    int? modifier,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDiceRoll.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDiceRoll.copyWith.fieldName(...)`
class _$DiceRollCWProxyImpl implements _$DiceRollCWProxy {
  const _$DiceRollCWProxyImpl(this._value);

  final DiceRoll _value;

  @override
  DiceRoll numDice(int numDice) => this(numDice: numDice);

  @override
  DiceRoll diceSides(int diceSides) => this(diceSides: diceSides);

  @override
  DiceRoll modifier(int modifier) => this(modifier: modifier);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DiceRoll(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DiceRoll(...).copyWith(id: 12, name: "My name")
  /// ````
  DiceRoll call({
    Object? numDice = const $CopyWithPlaceholder(),
    Object? diceSides = const $CopyWithPlaceholder(),
    Object? modifier = const $CopyWithPlaceholder(),
  }) {
    return DiceRoll(
      numDice: numDice == const $CopyWithPlaceholder() || numDice == null
          ? _value.numDice
          // ignore: cast_nullable_to_non_nullable
          : numDice as int,
      diceSides: diceSides == const $CopyWithPlaceholder() || diceSides == null
          ? _value.diceSides
          // ignore: cast_nullable_to_non_nullable
          : diceSides as int,
      modifier: modifier == const $CopyWithPlaceholder() || modifier == null
          ? _value.modifier
          // ignore: cast_nullable_to_non_nullable
          : modifier as int,
    );
  }
}

extension $DiceRollCopyWith on DiceRoll {
  /// Returns a callable class that can be used as follows: `instanceOfDiceRoll.copyWith(...)` or like so:`instanceOfDiceRoll.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DiceRollCWProxy get copyWith => _$DiceRollCWProxyImpl(this);
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
      characterStatTabsDefinition: (json['characterStatTabsDefinition']
              as List<dynamic>?)
          ?.map((e) =>
              CharacterStatsTabDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      'characterStatTabsDefinition': instance.characterStatTabsDefinition,
      'craftingRecipes': instance.craftingRecipes,
      'currencyDefinition': instance.currencyDefinition,
    };

ItemCategory _$ItemCategoryFromJson(Map<String, dynamic> json) => ItemCategory(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      colorCode: json['colorCode'] as String?,
      iconName: json['iconName'] as String?,
      subCategories: (json['subCategories'] as List<dynamic>)
          .map((e) => ItemCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      hideInInventoryFilters: json['hideInInventoryFilters'] as bool? ?? false,
    );

Map<String, dynamic> _$ItemCategoryToJson(ItemCategory instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'subCategories': instance.subCategories,
      'hideInInventoryFilters': instance.hideInInventoryFilters,
      'colorCode': instance.colorCode,
      'iconName': instance.iconName,
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
      requiredItemIds: (json['requiredItemIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdItem: CraftingRecipeIngredientPair.fromJson(
          json['createdItem'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CraftingRecipeToJson(CraftingRecipe instance) =>
    <String, dynamic>{
      'recipeUuid': instance.recipeUuid,
      'ingredients': instance.ingredients,
      'createdItem': instance.createdItem,
      'requiredItemIds': instance.requiredItemIds,
    };

CharacterStatDefinition _$CharacterStatDefinitionFromJson(
        Map<String, dynamic> json) =>
    CharacterStatDefinition(
      statUuid: json['statUuid'] as String,
      name: json['name'] as String,
      groupId: (json['groupId'] as num?)?.toInt(),
      helperText: json['helperText'] as String,
      valueType:
          $enumDecode(_$CharacterStatValueTypeEnumMap, json['valueType']),
      editType: $enumDecode(_$CharacterStatEditTypeEnumMap, json['editType']),
      isOptionalForAlternateForms: json['isOptionalForAlternateForms'] as bool?,
      isOptionalForCompanionCharacters:
          json['isOptionalForCompanionCharacters'] as bool?,
      jsonSerializedAdditionalData:
          json['jsonSerializedAdditionalData'] as String?,
    );

Map<String, dynamic> _$CharacterStatDefinitionToJson(
        CharacterStatDefinition instance) =>
    <String, dynamic>{
      'name': instance.name,
      'statUuid': instance.statUuid,
      'helperText': instance.helperText,
      'groupId': instance.groupId,
      'valueType': _$CharacterStatValueTypeEnumMap[instance.valueType]!,
      'editType': _$CharacterStatEditTypeEnumMap[instance.editType]!,
      'isOptionalForAlternateForms': instance.isOptionalForAlternateForms,
      'isOptionalForCompanionCharacters':
          instance.isOptionalForCompanionCharacters,
      'jsonSerializedAdditionalData': instance.jsonSerializedAdditionalData,
    };

const _$CharacterStatValueTypeEnumMap = {
  CharacterStatValueType.multiLineText: 'multiLineText',
  CharacterStatValueType.singleLineText: 'singleLineText',
  CharacterStatValueType.int: 'int',
  CharacterStatValueType.intWithMaxValue: 'intWithMaxValue',
  CharacterStatValueType.multiselect: 'multiselect',
  CharacterStatValueType.intWithCalculatedValue: 'intWithCalculatedValue',
  CharacterStatValueType.singleImage: 'singleImage',
  CharacterStatValueType.listOfIntWithCalculatedValues:
      'listOfIntWithCalculatedValues',
  CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
      'characterNameWithLevelAndAdditionalDetails',
};

const _$CharacterStatEditTypeEnumMap = {
  CharacterStatEditType.static: 'static',
  CharacterStatEditType.oneTap: 'oneTap',
};

CharacterStatsTabDefinition _$CharacterStatsTabDefinitionFromJson(
        Map<String, dynamic> json) =>
    CharacterStatsTabDefinition(
      uuid: json['uuid'] as String,
      tabName: json['tabName'] as String,
      isOptional: json['isOptional'] as bool,
      statsInTab: (json['statsInTab'] as List<dynamic>)
          .map((e) =>
              CharacterStatDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      isDefaultTab: json['isDefaultTab'] as bool,
    );

Map<String, dynamic> _$CharacterStatsTabDefinitionToJson(
        CharacterStatsTabDefinition instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'tabName': instance.tabName,
      'isOptional': instance.isOptional,
      'isDefaultTab': instance.isDefaultTab,
      'statsInTab': instance.statsInTab,
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

RpgItemRarity _$RpgItemRarityFromJson(Map<String, dynamic> json) =>
    RpgItemRarity(
      placeOfFindingId: json['placeOfFindingId'] as String,
      diceChallenge: (json['diceChallenge'] as num).toInt(),
    );

Map<String, dynamic> _$RpgItemRarityToJson(RpgItemRarity instance) =>
    <String, dynamic>{
      'placeOfFindingId': instance.placeOfFindingId,
      'diceChallenge': instance.diceChallenge,
    };

RpgItem _$RpgItemFromJson(Map<String, dynamic> json) => RpgItem(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      imageUrlWithoutBasePath: json['imageUrlWithoutBasePath'] as String?,
      patchSize: json['patchSize'] == null
          ? null
          : DiceRoll.fromJson(json['patchSize'] as Map<String, dynamic>),
      categoryId: json['categoryId'] as String,
      description: json['description'] as String,
      imageDescription: json['imageDescription'] as String?,
      baseCurrencyPrice: (json['baseCurrencyPrice'] as num).toInt(),
      placeOfFindings: (json['placeOfFindings'] as List<dynamic>)
          .map((e) => RpgItemRarity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RpgItemToJson(RpgItem instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'imageUrlWithoutBasePath': instance.imageUrlWithoutBasePath,
      'imageDescription': instance.imageDescription,
      'placeOfFindings': instance.placeOfFindings,
      'patchSize': instance.patchSize,
      'baseCurrencyPrice': instance.baseCurrencyPrice,
    };

DiceRoll _$DiceRollFromJson(Map<String, dynamic> json) => DiceRoll(
      numDice: (json['numDice'] as num).toInt(),
      diceSides: (json['diceSides'] as num).toInt(),
      modifier: (json['modifier'] as num).toInt(),
    );

Map<String, dynamic> _$DiceRollToJson(DiceRoll instance) => <String, dynamic>{
      'numDice': instance.numDice,
      'diceSides': instance.diceSides,
      'modifier': instance.modifier,
    };
