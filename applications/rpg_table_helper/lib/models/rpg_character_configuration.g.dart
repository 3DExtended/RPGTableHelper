// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpg_character_configuration.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RpgAlternateCharacterConfigurationCWProxy {
  RpgAlternateCharacterConfiguration uuid(String uuid);

  RpgAlternateCharacterConfiguration characterName(String characterName);

  RpgAlternateCharacterConfiguration characterStats(
    List<RpgCharacterStatValue> characterStats,
  );

  RpgAlternateCharacterConfiguration transformationComponents(
    List<TransformationComponent>? transformationComponents,
  );

  RpgAlternateCharacterConfiguration alternateForm(
    RpgAlternateCharacterConfiguration? alternateForm,
  );

  RpgAlternateCharacterConfiguration isAlternateFormActive(
    bool? isAlternateFormActive,
  );

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RpgAlternateCharacterConfiguration(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RpgAlternateCharacterConfiguration(...).copyWith(id: 12, name: "My name")
  /// ```
  RpgAlternateCharacterConfiguration call({
    String uuid,
    String characterName,
    List<RpgCharacterStatValue> characterStats,
    List<TransformationComponent>? transformationComponents,
    RpgAlternateCharacterConfiguration? alternateForm,
    bool? isAlternateFormActive,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRpgAlternateCharacterConfiguration.copyWith(...)` or call `instanceOfRpgAlternateCharacterConfiguration.copyWith.fieldName(value)` for a single field.
class _$RpgAlternateCharacterConfigurationCWProxyImpl
    implements _$RpgAlternateCharacterConfigurationCWProxy {
  const _$RpgAlternateCharacterConfigurationCWProxyImpl(this._value);

  final RpgAlternateCharacterConfiguration _value;

  @override
  RpgAlternateCharacterConfiguration uuid(String uuid) => call(uuid: uuid);

  @override
  RpgAlternateCharacterConfiguration characterName(String characterName) =>
      call(characterName: characterName);

  @override
  RpgAlternateCharacterConfiguration characterStats(
    List<RpgCharacterStatValue> characterStats,
  ) => call(characterStats: characterStats);

  @override
  RpgAlternateCharacterConfiguration transformationComponents(
    List<TransformationComponent>? transformationComponents,
  ) => call(transformationComponents: transformationComponents);

  @override
  RpgAlternateCharacterConfiguration alternateForm(
    RpgAlternateCharacterConfiguration? alternateForm,
  ) => call(alternateForm: alternateForm);

  @override
  RpgAlternateCharacterConfiguration isAlternateFormActive(
    bool? isAlternateFormActive,
  ) => call(isAlternateFormActive: isAlternateFormActive);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RpgAlternateCharacterConfiguration(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RpgAlternateCharacterConfiguration(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RpgAlternateCharacterConfiguration call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? characterName = const $CopyWithPlaceholder(),
    Object? characterStats = const $CopyWithPlaceholder(),
    Object? transformationComponents = const $CopyWithPlaceholder(),
    Object? alternateForm = const $CopyWithPlaceholder(),
    Object? isAlternateFormActive = const $CopyWithPlaceholder(),
  }) {
    return RpgAlternateCharacterConfiguration(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      characterName:
          characterName == const $CopyWithPlaceholder() || characterName == null
          ? _value.characterName
          // ignore: cast_nullable_to_non_nullable
          : characterName as String,
      characterStats:
          characterStats == const $CopyWithPlaceholder() ||
              characterStats == null
          ? _value.characterStats
          // ignore: cast_nullable_to_non_nullable
          : characterStats as List<RpgCharacterStatValue>,
      transformationComponents:
          transformationComponents == const $CopyWithPlaceholder()
          ? _value.transformationComponents
          // ignore: cast_nullable_to_non_nullable
          : transformationComponents as List<TransformationComponent>?,
      alternateForm: alternateForm == const $CopyWithPlaceholder()
          ? _value.alternateForm
          // ignore: cast_nullable_to_non_nullable
          : alternateForm as RpgAlternateCharacterConfiguration?,
      isAlternateFormActive:
          isAlternateFormActive == const $CopyWithPlaceholder()
          ? _value.isAlternateFormActive
          // ignore: cast_nullable_to_non_nullable
          : isAlternateFormActive as bool?,
    );
  }
}

extension $RpgAlternateCharacterConfigurationCopyWith
    on RpgAlternateCharacterConfiguration {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRpgAlternateCharacterConfiguration.copyWith(...)` or `instanceOfRpgAlternateCharacterConfiguration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgAlternateCharacterConfigurationCWProxy get copyWith =>
      _$RpgAlternateCharacterConfigurationCWProxyImpl(this);
}

abstract class _$TransformationComponentCWProxy {
  TransformationComponent transformationUuid(String transformationUuid);

  TransformationComponent transformationName(String transformationName);

  TransformationComponent transformationDescription(
    String? transformationDescription,
  );

  TransformationComponent transformationStats(
    List<RpgCharacterStatValue> transformationStats,
  );

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `TransformationComponent(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TransformationComponent(...).copyWith(id: 12, name: "My name")
  /// ```
  TransformationComponent call({
    String transformationUuid,
    String transformationName,
    String? transformationDescription,
    List<RpgCharacterStatValue> transformationStats,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfTransformationComponent.copyWith(...)` or call `instanceOfTransformationComponent.copyWith.fieldName(value)` for a single field.
class _$TransformationComponentCWProxyImpl
    implements _$TransformationComponentCWProxy {
  const _$TransformationComponentCWProxyImpl(this._value);

  final TransformationComponent _value;

  @override
  TransformationComponent transformationUuid(String transformationUuid) =>
      call(transformationUuid: transformationUuid);

  @override
  TransformationComponent transformationName(String transformationName) =>
      call(transformationName: transformationName);

  @override
  TransformationComponent transformationDescription(
    String? transformationDescription,
  ) => call(transformationDescription: transformationDescription);

  @override
  TransformationComponent transformationStats(
    List<RpgCharacterStatValue> transformationStats,
  ) => call(transformationStats: transformationStats);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `TransformationComponent(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TransformationComponent(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  TransformationComponent call({
    Object? transformationUuid = const $CopyWithPlaceholder(),
    Object? transformationName = const $CopyWithPlaceholder(),
    Object? transformationDescription = const $CopyWithPlaceholder(),
    Object? transformationStats = const $CopyWithPlaceholder(),
  }) {
    return TransformationComponent(
      transformationUuid:
          transformationUuid == const $CopyWithPlaceholder() ||
              transformationUuid == null
          ? _value.transformationUuid
          // ignore: cast_nullable_to_non_nullable
          : transformationUuid as String,
      transformationName:
          transformationName == const $CopyWithPlaceholder() ||
              transformationName == null
          ? _value.transformationName
          // ignore: cast_nullable_to_non_nullable
          : transformationName as String,
      transformationDescription:
          transformationDescription == const $CopyWithPlaceholder()
          ? _value.transformationDescription
          // ignore: cast_nullable_to_non_nullable
          : transformationDescription as String?,
      transformationStats:
          transformationStats == const $CopyWithPlaceholder() ||
              transformationStats == null
          ? _value.transformationStats
          // ignore: cast_nullable_to_non_nullable
          : transformationStats as List<RpgCharacterStatValue>,
    );
  }
}

extension $TransformationComponentCopyWith on TransformationComponent {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfTransformationComponent.copyWith(...)` or `instanceOfTransformationComponent.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TransformationComponentCWProxy get copyWith =>
      _$TransformationComponentCWProxyImpl(this);
}

abstract class _$RpgTabConfigurationCWProxy {
  RpgTabConfiguration tabUuid(String tabUuid);

  RpgTabConfiguration tabIcon(String tabIcon);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RpgTabConfiguration(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RpgTabConfiguration(...).copyWith(id: 12, name: "My name")
  /// ```
  RpgTabConfiguration call({String tabUuid, String tabIcon});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRpgTabConfiguration.copyWith(...)` or call `instanceOfRpgTabConfiguration.copyWith.fieldName(value)` for a single field.
class _$RpgTabConfigurationCWProxyImpl implements _$RpgTabConfigurationCWProxy {
  const _$RpgTabConfigurationCWProxyImpl(this._value);

  final RpgTabConfiguration _value;

  @override
  RpgTabConfiguration tabUuid(String tabUuid) => call(tabUuid: tabUuid);

  @override
  RpgTabConfiguration tabIcon(String tabIcon) => call(tabIcon: tabIcon);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RpgTabConfiguration(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RpgTabConfiguration(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RpgTabConfiguration call({
    Object? tabUuid = const $CopyWithPlaceholder(),
    Object? tabIcon = const $CopyWithPlaceholder(),
  }) {
    return RpgTabConfiguration(
      tabUuid: tabUuid == const $CopyWithPlaceholder() || tabUuid == null
          ? _value.tabUuid
          // ignore: cast_nullable_to_non_nullable
          : tabUuid as String,
      tabIcon: tabIcon == const $CopyWithPlaceholder() || tabIcon == null
          ? _value.tabIcon
          // ignore: cast_nullable_to_non_nullable
          : tabIcon as String,
    );
  }
}

extension $RpgTabConfigurationCopyWith on RpgTabConfiguration {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRpgTabConfiguration.copyWith(...)` or `instanceOfRpgTabConfiguration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgTabConfigurationCWProxy get copyWith =>
      _$RpgTabConfigurationCWProxyImpl(this);
}

abstract class _$RpgCharacterConfigurationCWProxy {
  RpgCharacterConfiguration uuid(String uuid);

  RpgCharacterConfiguration characterName(String characterName);

  RpgCharacterConfiguration tabConfigurations(
    List<RpgTabConfiguration>? tabConfigurations,
  );

  RpgCharacterConfiguration transformationComponents(
    List<TransformationComponent>? transformationComponents,
  );

  RpgCharacterConfiguration alternateForms(
    @Deprecated("alternate Forms are now in companionCharacters")
    List<RpgAlternateCharacterConfiguration>? alternateForms,
  );

  RpgCharacterConfiguration moneyInBaseType(int? moneyInBaseType);

  RpgCharacterConfiguration isAlternateFormActive(bool? isAlternateFormActive);

  RpgCharacterConfiguration alternateForm(
    RpgAlternateCharacterConfiguration? alternateForm,
  );

  RpgCharacterConfiguration characterStats(
    List<RpgCharacterStatValue> characterStats,
  );

  RpgCharacterConfiguration inventory(
    List<RpgCharacterOwnedItemPair> inventory,
  );

  RpgCharacterConfiguration companionCharacters(
    List<RpgAlternateCharacterConfiguration>? companionCharacters,
  );

  RpgCharacterConfiguration skinId(String? skinId);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RpgCharacterConfiguration(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RpgCharacterConfiguration(...).copyWith(id: 12, name: "My name")
  /// ```
  RpgCharacterConfiguration call({
    String uuid,
    String characterName,
    List<RpgTabConfiguration>? tabConfigurations,
    List<TransformationComponent>? transformationComponents,
    @Deprecated("alternate Forms are now in companionCharacters")
    List<RpgAlternateCharacterConfiguration>? alternateForms,
    int? moneyInBaseType,
    bool? isAlternateFormActive,
    RpgAlternateCharacterConfiguration? alternateForm,
    List<RpgCharacterStatValue> characterStats,
    List<RpgCharacterOwnedItemPair> inventory,
    List<RpgAlternateCharacterConfiguration>? companionCharacters,
    String? skinId,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRpgCharacterConfiguration.copyWith(...)` or call `instanceOfRpgCharacterConfiguration.copyWith.fieldName(value)` for a single field.
class _$RpgCharacterConfigurationCWProxyImpl
    implements _$RpgCharacterConfigurationCWProxy {
  const _$RpgCharacterConfigurationCWProxyImpl(this._value);

  final RpgCharacterConfiguration _value;

  @override
  RpgCharacterConfiguration uuid(String uuid) => call(uuid: uuid);

  @override
  RpgCharacterConfiguration characterName(String characterName) =>
      call(characterName: characterName);

  @override
  RpgCharacterConfiguration tabConfigurations(
    List<RpgTabConfiguration>? tabConfigurations,
  ) => call(tabConfigurations: tabConfigurations);

  @override
  RpgCharacterConfiguration transformationComponents(
    List<TransformationComponent>? transformationComponents,
  ) => call(transformationComponents: transformationComponents);

  @override
  RpgCharacterConfiguration alternateForms(
    @Deprecated("alternate Forms are now in companionCharacters")
    List<RpgAlternateCharacterConfiguration>? alternateForms,
  ) => call(alternateForms: alternateForms);

  @override
  RpgCharacterConfiguration moneyInBaseType(int? moneyInBaseType) =>
      call(moneyInBaseType: moneyInBaseType);

  @override
  RpgCharacterConfiguration isAlternateFormActive(
    bool? isAlternateFormActive,
  ) => call(isAlternateFormActive: isAlternateFormActive);

  @override
  RpgCharacterConfiguration alternateForm(
    RpgAlternateCharacterConfiguration? alternateForm,
  ) => call(alternateForm: alternateForm);

  @override
  RpgCharacterConfiguration characterStats(
    List<RpgCharacterStatValue> characterStats,
  ) => call(characterStats: characterStats);

  @override
  RpgCharacterConfiguration inventory(
    List<RpgCharacterOwnedItemPair> inventory,
  ) => call(inventory: inventory);

  @override
  RpgCharacterConfiguration companionCharacters(
    List<RpgAlternateCharacterConfiguration>? companionCharacters,
  ) => call(companionCharacters: companionCharacters);

  @override
  RpgCharacterConfiguration skinId(String? skinId) => call(skinId: skinId);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RpgCharacterConfiguration(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RpgCharacterConfiguration(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RpgCharacterConfiguration call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? characterName = const $CopyWithPlaceholder(),
    Object? tabConfigurations = const $CopyWithPlaceholder(),
    Object? transformationComponents = const $CopyWithPlaceholder(),
    @Deprecated("alternate Forms are now in companionCharacters")
    Object? alternateForms = const $CopyWithPlaceholder(),
    Object? moneyInBaseType = const $CopyWithPlaceholder(),
    Object? isAlternateFormActive = const $CopyWithPlaceholder(),
    Object? alternateForm = const $CopyWithPlaceholder(),
    Object? characterStats = const $CopyWithPlaceholder(),
    Object? inventory = const $CopyWithPlaceholder(),
    Object? companionCharacters = const $CopyWithPlaceholder(),
    Object? skinId = const $CopyWithPlaceholder(),
  }) {
    return RpgCharacterConfiguration(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      characterName:
          characterName == const $CopyWithPlaceholder() || characterName == null
          ? _value.characterName
          // ignore: cast_nullable_to_non_nullable
          : characterName as String,
      tabConfigurations: tabConfigurations == const $CopyWithPlaceholder()
          ? _value.tabConfigurations
          // ignore: cast_nullable_to_non_nullable
          : tabConfigurations as List<RpgTabConfiguration>?,
      transformationComponents:
          transformationComponents == const $CopyWithPlaceholder()
          ? _value.transformationComponents
          // ignore: cast_nullable_to_non_nullable
          : transformationComponents as List<TransformationComponent>?,
      alternateForms: alternateForms == const $CopyWithPlaceholder()
          ? _value.alternateForms
          // ignore: cast_nullable_to_non_nullable
          : alternateForms as List<RpgAlternateCharacterConfiguration>?,
      moneyInBaseType: moneyInBaseType == const $CopyWithPlaceholder()
          ? _value.moneyInBaseType
          // ignore: cast_nullable_to_non_nullable
          : moneyInBaseType as int?,
      isAlternateFormActive:
          isAlternateFormActive == const $CopyWithPlaceholder()
          ? _value.isAlternateFormActive
          // ignore: cast_nullable_to_non_nullable
          : isAlternateFormActive as bool?,
      alternateForm: alternateForm == const $CopyWithPlaceholder()
          ? _value.alternateForm
          // ignore: cast_nullable_to_non_nullable
          : alternateForm as RpgAlternateCharacterConfiguration?,
      characterStats:
          characterStats == const $CopyWithPlaceholder() ||
              characterStats == null
          ? _value.characterStats
          // ignore: cast_nullable_to_non_nullable
          : characterStats as List<RpgCharacterStatValue>,
      inventory: inventory == const $CopyWithPlaceholder() || inventory == null
          ? _value.inventory
          // ignore: cast_nullable_to_non_nullable
          : inventory as List<RpgCharacterOwnedItemPair>,
      companionCharacters: companionCharacters == const $CopyWithPlaceholder()
          ? _value.companionCharacters
          // ignore: cast_nullable_to_non_nullable
          : companionCharacters as List<RpgAlternateCharacterConfiguration>?,
      skinId: skinId == const $CopyWithPlaceholder()
          ? _value.skinId
          // ignore: cast_nullable_to_non_nullable
          : skinId as String?,
    );
  }
}

extension $RpgCharacterConfigurationCopyWith on RpgCharacterConfiguration {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRpgCharacterConfiguration.copyWith(...)` or `instanceOfRpgCharacterConfiguration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgCharacterConfigurationCWProxy get copyWith =>
      _$RpgCharacterConfigurationCWProxyImpl(this);
}

abstract class _$RpgCharacterStatValueCWProxy {
  RpgCharacterStatValue statUuid(String statUuid);

  RpgCharacterStatValue serializedValue(String serializedValue);

  RpgCharacterStatValue hideFromCharacterScreen(bool? hideFromCharacterScreen);

  RpgCharacterStatValue variant(int? variant);

  RpgCharacterStatValue hideLabelOfStat(bool? hideLabelOfStat);

  RpgCharacterStatValue isCopy(bool? isCopy);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RpgCharacterStatValue(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RpgCharacterStatValue(...).copyWith(id: 12, name: "My name")
  /// ```
  RpgCharacterStatValue call({
    String statUuid,
    String serializedValue,
    bool? hideFromCharacterScreen,
    int? variant,
    bool? hideLabelOfStat,
    bool? isCopy,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRpgCharacterStatValue.copyWith(...)` or call `instanceOfRpgCharacterStatValue.copyWith.fieldName(value)` for a single field.
class _$RpgCharacterStatValueCWProxyImpl
    implements _$RpgCharacterStatValueCWProxy {
  const _$RpgCharacterStatValueCWProxyImpl(this._value);

  final RpgCharacterStatValue _value;

  @override
  RpgCharacterStatValue statUuid(String statUuid) => call(statUuid: statUuid);

  @override
  RpgCharacterStatValue serializedValue(String serializedValue) =>
      call(serializedValue: serializedValue);

  @override
  RpgCharacterStatValue hideFromCharacterScreen(
    bool? hideFromCharacterScreen,
  ) => call(hideFromCharacterScreen: hideFromCharacterScreen);

  @override
  RpgCharacterStatValue variant(int? variant) => call(variant: variant);

  @override
  RpgCharacterStatValue hideLabelOfStat(bool? hideLabelOfStat) =>
      call(hideLabelOfStat: hideLabelOfStat);

  @override
  RpgCharacterStatValue isCopy(bool? isCopy) => call(isCopy: isCopy);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RpgCharacterStatValue(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RpgCharacterStatValue(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RpgCharacterStatValue call({
    Object? statUuid = const $CopyWithPlaceholder(),
    Object? serializedValue = const $CopyWithPlaceholder(),
    Object? hideFromCharacterScreen = const $CopyWithPlaceholder(),
    Object? variant = const $CopyWithPlaceholder(),
    Object? hideLabelOfStat = const $CopyWithPlaceholder(),
    Object? isCopy = const $CopyWithPlaceholder(),
  }) {
    return RpgCharacterStatValue(
      statUuid: statUuid == const $CopyWithPlaceholder() || statUuid == null
          ? _value.statUuid
          // ignore: cast_nullable_to_non_nullable
          : statUuid as String,
      serializedValue:
          serializedValue == const $CopyWithPlaceholder() ||
              serializedValue == null
          ? _value.serializedValue
          // ignore: cast_nullable_to_non_nullable
          : serializedValue as String,
      hideFromCharacterScreen:
          hideFromCharacterScreen == const $CopyWithPlaceholder()
          ? _value.hideFromCharacterScreen
          // ignore: cast_nullable_to_non_nullable
          : hideFromCharacterScreen as bool?,
      variant: variant == const $CopyWithPlaceholder()
          ? _value.variant
          // ignore: cast_nullable_to_non_nullable
          : variant as int?,
      hideLabelOfStat: hideLabelOfStat == const $CopyWithPlaceholder()
          ? _value.hideLabelOfStat
          // ignore: cast_nullable_to_non_nullable
          : hideLabelOfStat as bool?,
      isCopy: isCopy == const $CopyWithPlaceholder()
          ? _value.isCopy
          // ignore: cast_nullable_to_non_nullable
          : isCopy as bool?,
    );
  }
}

extension $RpgCharacterStatValueCopyWith on RpgCharacterStatValue {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRpgCharacterStatValue.copyWith(...)` or `instanceOfRpgCharacterStatValue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgCharacterStatValueCWProxy get copyWith =>
      _$RpgCharacterStatValueCWProxyImpl(this);
}

abstract class _$RpgCharacterOwnedItemPairCWProxy {
  RpgCharacterOwnedItemPair itemUuid(String itemUuid);

  RpgCharacterOwnedItemPair amount(int amount);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RpgCharacterOwnedItemPair(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RpgCharacterOwnedItemPair(...).copyWith(id: 12, name: "My name")
  /// ```
  RpgCharacterOwnedItemPair call({String itemUuid, int amount});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRpgCharacterOwnedItemPair.copyWith(...)` or call `instanceOfRpgCharacterOwnedItemPair.copyWith.fieldName(value)` for a single field.
class _$RpgCharacterOwnedItemPairCWProxyImpl
    implements _$RpgCharacterOwnedItemPairCWProxy {
  const _$RpgCharacterOwnedItemPairCWProxyImpl(this._value);

  final RpgCharacterOwnedItemPair _value;

  @override
  RpgCharacterOwnedItemPair itemUuid(String itemUuid) =>
      call(itemUuid: itemUuid);

  @override
  RpgCharacterOwnedItemPair amount(int amount) => call(amount: amount);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RpgCharacterOwnedItemPair(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RpgCharacterOwnedItemPair(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RpgCharacterOwnedItemPair call({
    Object? itemUuid = const $CopyWithPlaceholder(),
    Object? amount = const $CopyWithPlaceholder(),
  }) {
    return RpgCharacterOwnedItemPair(
      itemUuid: itemUuid == const $CopyWithPlaceholder() || itemUuid == null
          ? _value.itemUuid
          // ignore: cast_nullable_to_non_nullable
          : itemUuid as String,
      amount: amount == const $CopyWithPlaceholder() || amount == null
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as int,
    );
  }
}

extension $RpgCharacterOwnedItemPairCopyWith on RpgCharacterOwnedItemPair {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRpgCharacterOwnedItemPair.copyWith(...)` or `instanceOfRpgCharacterOwnedItemPair.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgCharacterOwnedItemPairCWProxy get copyWith =>
      _$RpgCharacterOwnedItemPairCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpgAlternateCharacterConfiguration _$RpgAlternateCharacterConfigurationFromJson(
  Map<String, dynamic> json,
) => RpgAlternateCharacterConfiguration(
  uuid: json['uuid'] as String,
  characterName: json['characterName'] as String,
  characterStats: (json['characterStats'] as List<dynamic>)
      .map((e) => RpgCharacterStatValue.fromJson(e as Map<String, dynamic>))
      .toList(),
  transformationComponents: (json['transformationComponents'] as List<dynamic>?)
      ?.map((e) => TransformationComponent.fromJson(e as Map<String, dynamic>))
      .toList(),
  alternateForm: json['alternateForm'] == null
      ? null
      : RpgAlternateCharacterConfiguration.fromJson(
          json['alternateForm'] as Map<String, dynamic>,
        ),
  isAlternateFormActive: json['isAlternateFormActive'] as bool?,
);

Map<String, dynamic> _$RpgAlternateCharacterConfigurationToJson(
  RpgAlternateCharacterConfiguration instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'characterName': instance.characterName,
  'characterStats': instance.characterStats,
  'isAlternateFormActive': instance.isAlternateFormActive,
  'alternateForm': instance.alternateForm,
  'transformationComponents': instance.transformationComponents,
};

TransformationComponent _$TransformationComponentFromJson(
  Map<String, dynamic> json,
) => TransformationComponent(
  transformationUuid: json['transformationUuid'] as String,
  transformationName: json['transformationName'] as String,
  transformationDescription: json['transformationDescription'] as String?,
  transformationStats: (json['transformationStats'] as List<dynamic>)
      .map((e) => RpgCharacterStatValue.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TransformationComponentToJson(
  TransformationComponent instance,
) => <String, dynamic>{
  'transformationUuid': instance.transformationUuid,
  'transformationName': instance.transformationName,
  'transformationDescription': instance.transformationDescription,
  'transformationStats': instance.transformationStats,
};

RpgTabConfiguration _$RpgTabConfigurationFromJson(Map<String, dynamic> json) =>
    RpgTabConfiguration(
      tabUuid: json['tabUuid'] as String,
      tabIcon: json['tabIcon'] as String,
    );

Map<String, dynamic> _$RpgTabConfigurationToJson(
  RpgTabConfiguration instance,
) => <String, dynamic>{
  'tabUuid': instance.tabUuid,
  'tabIcon': instance.tabIcon,
};

RpgCharacterConfiguration _$RpgCharacterConfigurationFromJson(
  Map<String, dynamic> json,
) => RpgCharacterConfiguration(
  uuid: json['uuid'] as String,
  characterName: json['characterName'] as String,
  tabConfigurations: (json['tabConfigurations'] as List<dynamic>?)
      ?.map((e) => RpgTabConfiguration.fromJson(e as Map<String, dynamic>))
      .toList(),
  transformationComponents: (json['transformationComponents'] as List<dynamic>?)
      ?.map((e) => TransformationComponent.fromJson(e as Map<String, dynamic>))
      .toList(),
  alternateForms: (json['alternateForms'] as List<dynamic>?)
      ?.map(
        (e) => RpgAlternateCharacterConfiguration.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  moneyInBaseType: (json['moneyInBaseType'] as num?)?.toInt(),
  isAlternateFormActive: json['isAlternateFormActive'] as bool?,
  alternateForm: json['alternateForm'] == null
      ? null
      : RpgAlternateCharacterConfiguration.fromJson(
          json['alternateForm'] as Map<String, dynamic>,
        ),
  characterStats: (json['characterStats'] as List<dynamic>)
      .map((e) => RpgCharacterStatValue.fromJson(e as Map<String, dynamic>))
      .toList(),
  inventory: (json['inventory'] as List<dynamic>)
      .map((e) => RpgCharacterOwnedItemPair.fromJson(e as Map<String, dynamic>))
      .toList(),
  companionCharacters: (json['companionCharacters'] as List<dynamic>?)
      ?.map(
        (e) => RpgAlternateCharacterConfiguration.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  skinId: json['skinId'] as String?,
);

Map<String, dynamic> _$RpgCharacterConfigurationToJson(
  RpgCharacterConfiguration instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'characterName': instance.characterName,
  'characterStats': instance.characterStats,
  'isAlternateFormActive': instance.isAlternateFormActive,
  'alternateForm': instance.alternateForm,
  'transformationComponents': instance.transformationComponents,
  'moneyInBaseType': instance.moneyInBaseType,
  'tabConfigurations': instance.tabConfigurations,
  'inventory': instance.inventory,
  'companionCharacters': instance.companionCharacters,
  'alternateForms': instance.alternateForms,
  'skinId': ?instance.skinId,
};

RpgCharacterStatValue _$RpgCharacterStatValueFromJson(
  Map<String, dynamic> json,
) => RpgCharacterStatValue(
  statUuid: json['statUuid'] as String,
  serializedValue: json['serializedValue'] as String,
  hideFromCharacterScreen: json['hideFromCharacterScreen'] as bool?,
  variant: (json['variant'] as num?)?.toInt(),
  hideLabelOfStat: json['hideLabelOfStat'] as bool?,
  isCopy: json['isCopy'] as bool? ?? false,
);

Map<String, dynamic> _$RpgCharacterStatValueToJson(
  RpgCharacterStatValue instance,
) => <String, dynamic>{
  'statUuid': instance.statUuid,
  'serializedValue': instance.serializedValue,
  'hideFromCharacterScreen': instance.hideFromCharacterScreen,
  'hideLabelOfStat': instance.hideLabelOfStat,
  'variant': instance.variant,
  'isCopy': instance.isCopy,
};

RpgCharacterOwnedItemPair _$RpgCharacterOwnedItemPairFromJson(
  Map<String, dynamic> json,
) => RpgCharacterOwnedItemPair(
  itemUuid: json['itemUuid'] as String,
  amount: (json['amount'] as num).toInt(),
);

Map<String, dynamic> _$RpgCharacterOwnedItemPairToJson(
  RpgCharacterOwnedItemPair instance,
) => <String, dynamic>{
  'itemUuid': instance.itemUuid,
  'amount': instance.amount,
};
