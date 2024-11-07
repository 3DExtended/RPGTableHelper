// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpg_character_configuration.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RpgAlternateCharacterConfigurationCWProxy {
  RpgAlternateCharacterConfiguration uuid(String uuid);

  RpgAlternateCharacterConfiguration characterName(String characterName);

  RpgAlternateCharacterConfiguration characterStats(
      List<RpgCharacterStatValue> characterStats);

  RpgAlternateCharacterConfiguration imageUrlWithoutBasePath(
      String? imageUrlWithoutBasePath);

  RpgAlternateCharacterConfiguration imageDescription(String? imageDescription);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgAlternateCharacterConfiguration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgAlternateCharacterConfiguration(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgAlternateCharacterConfiguration call({
    String? uuid,
    String? characterName,
    List<RpgCharacterStatValue>? characterStats,
    String? imageUrlWithoutBasePath,
    String? imageDescription,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRpgAlternateCharacterConfiguration.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRpgAlternateCharacterConfiguration.copyWith.fieldName(...)`
class _$RpgAlternateCharacterConfigurationCWProxyImpl
    implements _$RpgAlternateCharacterConfigurationCWProxy {
  const _$RpgAlternateCharacterConfigurationCWProxyImpl(this._value);

  final RpgAlternateCharacterConfiguration _value;

  @override
  RpgAlternateCharacterConfiguration uuid(String uuid) => this(uuid: uuid);

  @override
  RpgAlternateCharacterConfiguration characterName(String characterName) =>
      this(characterName: characterName);

  @override
  RpgAlternateCharacterConfiguration characterStats(
          List<RpgCharacterStatValue> characterStats) =>
      this(characterStats: characterStats);

  @override
  RpgAlternateCharacterConfiguration imageUrlWithoutBasePath(
          String? imageUrlWithoutBasePath) =>
      this(imageUrlWithoutBasePath: imageUrlWithoutBasePath);

  @override
  RpgAlternateCharacterConfiguration imageDescription(
          String? imageDescription) =>
      this(imageDescription: imageDescription);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgAlternateCharacterConfiguration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgAlternateCharacterConfiguration(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgAlternateCharacterConfiguration call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? characterName = const $CopyWithPlaceholder(),
    Object? characterStats = const $CopyWithPlaceholder(),
    Object? imageUrlWithoutBasePath = const $CopyWithPlaceholder(),
    Object? imageDescription = const $CopyWithPlaceholder(),
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
      characterStats: characterStats == const $CopyWithPlaceholder() ||
              characterStats == null
          ? _value.characterStats
          // ignore: cast_nullable_to_non_nullable
          : characterStats as List<RpgCharacterStatValue>,
      imageUrlWithoutBasePath:
          imageUrlWithoutBasePath == const $CopyWithPlaceholder()
              ? _value.imageUrlWithoutBasePath
              // ignore: cast_nullable_to_non_nullable
              : imageUrlWithoutBasePath as String?,
      imageDescription: imageDescription == const $CopyWithPlaceholder()
          ? _value.imageDescription
          // ignore: cast_nullable_to_non_nullable
          : imageDescription as String?,
    );
  }
}

extension $RpgAlternateCharacterConfigurationCopyWith
    on RpgAlternateCharacterConfiguration {
  /// Returns a callable class that can be used as follows: `instanceOfRpgAlternateCharacterConfiguration.copyWith(...)` or like so:`instanceOfRpgAlternateCharacterConfiguration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgAlternateCharacterConfigurationCWProxy get copyWith =>
      _$RpgAlternateCharacterConfigurationCWProxyImpl(this);
}

abstract class _$RpgCharacterConfigurationCWProxy {
  RpgCharacterConfiguration uuid(String uuid);

  RpgCharacterConfiguration characterName(String characterName);

  RpgCharacterConfiguration alternateForms(
      List<RpgAlternateCharacterConfiguration>? alternateForms);

  RpgCharacterConfiguration moneyInBaseType(int? moneyInBaseType);

  RpgCharacterConfiguration activeAlternateFormIndex(
      int? activeAlternateFormIndex);

  RpgCharacterConfiguration characterStats(
      List<RpgCharacterStatValue> characterStats);

  RpgCharacterConfiguration imageDescription(String? imageDescription);

  RpgCharacterConfiguration imageUrlWithoutBasePath(
      String? imageUrlWithoutBasePath);

  RpgCharacterConfiguration inventory(
      List<RpgCharacterOwnedItemPair> inventory);

  RpgCharacterConfiguration companionCharacters(
      List<RpgAlternateCharacterConfiguration>? companionCharacters);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgCharacterConfiguration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgCharacterConfiguration(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgCharacterConfiguration call({
    String? uuid,
    String? characterName,
    List<RpgAlternateCharacterConfiguration>? alternateForms,
    int? moneyInBaseType,
    int? activeAlternateFormIndex,
    List<RpgCharacterStatValue>? characterStats,
    String? imageDescription,
    String? imageUrlWithoutBasePath,
    List<RpgCharacterOwnedItemPair>? inventory,
    List<RpgAlternateCharacterConfiguration>? companionCharacters,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRpgCharacterConfiguration.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRpgCharacterConfiguration.copyWith.fieldName(...)`
class _$RpgCharacterConfigurationCWProxyImpl
    implements _$RpgCharacterConfigurationCWProxy {
  const _$RpgCharacterConfigurationCWProxyImpl(this._value);

  final RpgCharacterConfiguration _value;

  @override
  RpgCharacterConfiguration uuid(String uuid) => this(uuid: uuid);

  @override
  RpgCharacterConfiguration characterName(String characterName) =>
      this(characterName: characterName);

  @override
  RpgCharacterConfiguration alternateForms(
          List<RpgAlternateCharacterConfiguration>? alternateForms) =>
      this(alternateForms: alternateForms);

  @override
  RpgCharacterConfiguration moneyInBaseType(int? moneyInBaseType) =>
      this(moneyInBaseType: moneyInBaseType);

  @override
  RpgCharacterConfiguration activeAlternateFormIndex(
          int? activeAlternateFormIndex) =>
      this(activeAlternateFormIndex: activeAlternateFormIndex);

  @override
  RpgCharacterConfiguration characterStats(
          List<RpgCharacterStatValue> characterStats) =>
      this(characterStats: characterStats);

  @override
  RpgCharacterConfiguration imageDescription(String? imageDescription) =>
      this(imageDescription: imageDescription);

  @override
  RpgCharacterConfiguration imageUrlWithoutBasePath(
          String? imageUrlWithoutBasePath) =>
      this(imageUrlWithoutBasePath: imageUrlWithoutBasePath);

  @override
  RpgCharacterConfiguration inventory(
          List<RpgCharacterOwnedItemPair> inventory) =>
      this(inventory: inventory);

  @override
  RpgCharacterConfiguration companionCharacters(
          List<RpgAlternateCharacterConfiguration>? companionCharacters) =>
      this(companionCharacters: companionCharacters);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgCharacterConfiguration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgCharacterConfiguration(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgCharacterConfiguration call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? characterName = const $CopyWithPlaceholder(),
    Object? alternateForms = const $CopyWithPlaceholder(),
    Object? moneyInBaseType = const $CopyWithPlaceholder(),
    Object? activeAlternateFormIndex = const $CopyWithPlaceholder(),
    Object? characterStats = const $CopyWithPlaceholder(),
    Object? imageDescription = const $CopyWithPlaceholder(),
    Object? imageUrlWithoutBasePath = const $CopyWithPlaceholder(),
    Object? inventory = const $CopyWithPlaceholder(),
    Object? companionCharacters = const $CopyWithPlaceholder(),
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
      alternateForms: alternateForms == const $CopyWithPlaceholder()
          ? _value.alternateForms
          // ignore: cast_nullable_to_non_nullable
          : alternateForms as List<RpgAlternateCharacterConfiguration>?,
      moneyInBaseType: moneyInBaseType == const $CopyWithPlaceholder()
          ? _value.moneyInBaseType
          // ignore: cast_nullable_to_non_nullable
          : moneyInBaseType as int?,
      activeAlternateFormIndex:
          activeAlternateFormIndex == const $CopyWithPlaceholder()
              ? _value.activeAlternateFormIndex
              // ignore: cast_nullable_to_non_nullable
              : activeAlternateFormIndex as int?,
      characterStats: characterStats == const $CopyWithPlaceholder() ||
              characterStats == null
          ? _value.characterStats
          // ignore: cast_nullable_to_non_nullable
          : characterStats as List<RpgCharacterStatValue>,
      imageDescription: imageDescription == const $CopyWithPlaceholder()
          ? _value.imageDescription
          // ignore: cast_nullable_to_non_nullable
          : imageDescription as String?,
      imageUrlWithoutBasePath:
          imageUrlWithoutBasePath == const $CopyWithPlaceholder()
              ? _value.imageUrlWithoutBasePath
              // ignore: cast_nullable_to_non_nullable
              : imageUrlWithoutBasePath as String?,
      inventory: inventory == const $CopyWithPlaceholder() || inventory == null
          ? _value.inventory
          // ignore: cast_nullable_to_non_nullable
          : inventory as List<RpgCharacterOwnedItemPair>,
      companionCharacters: companionCharacters == const $CopyWithPlaceholder()
          ? _value.companionCharacters
          // ignore: cast_nullable_to_non_nullable
          : companionCharacters as List<RpgAlternateCharacterConfiguration>?,
    );
  }
}

extension $RpgCharacterConfigurationCopyWith on RpgCharacterConfiguration {
  /// Returns a callable class that can be used as follows: `instanceOfRpgCharacterConfiguration.copyWith(...)` or like so:`instanceOfRpgCharacterConfiguration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgCharacterConfigurationCWProxy get copyWith =>
      _$RpgCharacterConfigurationCWProxyImpl(this);
}

abstract class _$RpgCharacterStatValueCWProxy {
  RpgCharacterStatValue statUuid(String statUuid);

  RpgCharacterStatValue serializedValue(String serializedValue);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgCharacterStatValue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgCharacterStatValue(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgCharacterStatValue call({
    String? statUuid,
    String? serializedValue,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRpgCharacterStatValue.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRpgCharacterStatValue.copyWith.fieldName(...)`
class _$RpgCharacterStatValueCWProxyImpl
    implements _$RpgCharacterStatValueCWProxy {
  const _$RpgCharacterStatValueCWProxyImpl(this._value);

  final RpgCharacterStatValue _value;

  @override
  RpgCharacterStatValue statUuid(String statUuid) => this(statUuid: statUuid);

  @override
  RpgCharacterStatValue serializedValue(String serializedValue) =>
      this(serializedValue: serializedValue);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgCharacterStatValue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgCharacterStatValue(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgCharacterStatValue call({
    Object? statUuid = const $CopyWithPlaceholder(),
    Object? serializedValue = const $CopyWithPlaceholder(),
  }) {
    return RpgCharacterStatValue(
      statUuid: statUuid == const $CopyWithPlaceholder() || statUuid == null
          ? _value.statUuid
          // ignore: cast_nullable_to_non_nullable
          : statUuid as String,
      serializedValue: serializedValue == const $CopyWithPlaceholder() ||
              serializedValue == null
          ? _value.serializedValue
          // ignore: cast_nullable_to_non_nullable
          : serializedValue as String,
    );
  }
}

extension $RpgCharacterStatValueCopyWith on RpgCharacterStatValue {
  /// Returns a callable class that can be used as follows: `instanceOfRpgCharacterStatValue.copyWith(...)` or like so:`instanceOfRpgCharacterStatValue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgCharacterStatValueCWProxy get copyWith =>
      _$RpgCharacterStatValueCWProxyImpl(this);
}

abstract class _$RpgCharacterOwnedItemPairCWProxy {
  RpgCharacterOwnedItemPair itemUuid(String itemUuid);

  RpgCharacterOwnedItemPair amount(int amount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgCharacterOwnedItemPair(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgCharacterOwnedItemPair(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgCharacterOwnedItemPair call({
    String? itemUuid,
    int? amount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRpgCharacterOwnedItemPair.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRpgCharacterOwnedItemPair.copyWith.fieldName(...)`
class _$RpgCharacterOwnedItemPairCWProxyImpl
    implements _$RpgCharacterOwnedItemPairCWProxy {
  const _$RpgCharacterOwnedItemPairCWProxyImpl(this._value);

  final RpgCharacterOwnedItemPair _value;

  @override
  RpgCharacterOwnedItemPair itemUuid(String itemUuid) =>
      this(itemUuid: itemUuid);

  @override
  RpgCharacterOwnedItemPair amount(int amount) => this(amount: amount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgCharacterOwnedItemPair(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgCharacterOwnedItemPair(...).copyWith(id: 12, name: "My name")
  /// ````
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
  /// Returns a callable class that can be used as follows: `instanceOfRpgCharacterOwnedItemPair.copyWith(...)` or like so:`instanceOfRpgCharacterOwnedItemPair.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RpgCharacterOwnedItemPairCWProxy get copyWith =>
      _$RpgCharacterOwnedItemPairCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpgAlternateCharacterConfiguration _$RpgAlternateCharacterConfigurationFromJson(
        Map<String, dynamic> json) =>
    RpgAlternateCharacterConfiguration(
      uuid: json['uuid'] as String,
      characterName: json['characterName'] as String,
      characterStats: (json['characterStats'] as List<dynamic>)
          .map((e) => RpgCharacterStatValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrlWithoutBasePath: json['imageUrlWithoutBasePath'] as String?,
      imageDescription: json['imageDescription'] as String?,
    );

Map<String, dynamic> _$RpgAlternateCharacterConfigurationToJson(
        RpgAlternateCharacterConfiguration instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'characterName': instance.characterName,
      'characterStats': instance.characterStats,
      'imageUrlWithoutBasePath': instance.imageUrlWithoutBasePath,
      'imageDescription': instance.imageDescription,
    };

RpgCharacterConfiguration _$RpgCharacterConfigurationFromJson(
        Map<String, dynamic> json) =>
    RpgCharacterConfiguration(
      uuid: json['uuid'] as String,
      characterName: json['characterName'] as String,
      alternateForms: (json['alternateForms'] as List<dynamic>?)
          ?.map((e) => RpgAlternateCharacterConfiguration.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      moneyInBaseType: (json['moneyInBaseType'] as num?)?.toInt(),
      activeAlternateFormIndex:
          (json['activeAlternateFormIndex'] as num?)?.toInt(),
      characterStats: (json['characterStats'] as List<dynamic>)
          .map((e) => RpgCharacterStatValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageDescription: json['imageDescription'] as String?,
      imageUrlWithoutBasePath: json['imageUrlWithoutBasePath'] as String?,
      inventory: (json['inventory'] as List<dynamic>)
          .map((e) =>
              RpgCharacterOwnedItemPair.fromJson(e as Map<String, dynamic>))
          .toList(),
      companionCharacters: (json['companionCharacters'] as List<dynamic>?)
          ?.map((e) => RpgAlternateCharacterConfiguration.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RpgCharacterConfigurationToJson(
        RpgCharacterConfiguration instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'characterName': instance.characterName,
      'characterStats': instance.characterStats,
      'imageUrlWithoutBasePath': instance.imageUrlWithoutBasePath,
      'imageDescription': instance.imageDescription,
      'moneyInBaseType': instance.moneyInBaseType,
      'inventory': instance.inventory,
      'companionCharacters': instance.companionCharacters,
      'alternateForms': instance.alternateForms,
      'activeAlternateFormIndex': instance.activeAlternateFormIndex,
    };

RpgCharacterStatValue _$RpgCharacterStatValueFromJson(
        Map<String, dynamic> json) =>
    RpgCharacterStatValue(
      statUuid: json['statUuid'] as String,
      serializedValue: json['serializedValue'] as String,
    );

Map<String, dynamic> _$RpgCharacterStatValueToJson(
        RpgCharacterStatValue instance) =>
    <String, dynamic>{
      'statUuid': instance.statUuid,
      'serializedValue': instance.serializedValue,
    };

RpgCharacterOwnedItemPair _$RpgCharacterOwnedItemPairFromJson(
        Map<String, dynamic> json) =>
    RpgCharacterOwnedItemPair(
      itemUuid: json['itemUuid'] as String,
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$RpgCharacterOwnedItemPairToJson(
        RpgCharacterOwnedItemPair instance) =>
    <String, dynamic>{
      'itemUuid': instance.itemUuid,
      'amount': instance.amount,
    };
