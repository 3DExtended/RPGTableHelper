// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpg_character_configuration.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RpgCharacterConfigurationCWProxy {
  RpgCharacterConfiguration characterName(String characterName);

  RpgCharacterConfiguration moneyCoinCount(List<int> moneyCoinCount);

  RpgCharacterConfiguration characterStats(
      List<RpgCharacterStatValue> characterStats);

  RpgCharacterConfiguration inventory(
      List<RpgCharacterOwnedItemPair> inventory);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgCharacterConfiguration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgCharacterConfiguration(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgCharacterConfiguration call({
    String? characterName,
    List<int>? moneyCoinCount,
    List<RpgCharacterStatValue>? characterStats,
    List<RpgCharacterOwnedItemPair>? inventory,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRpgCharacterConfiguration.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRpgCharacterConfiguration.copyWith.fieldName(...)`
class _$RpgCharacterConfigurationCWProxyImpl
    implements _$RpgCharacterConfigurationCWProxy {
  const _$RpgCharacterConfigurationCWProxyImpl(this._value);

  final RpgCharacterConfiguration _value;

  @override
  RpgCharacterConfiguration characterName(String characterName) =>
      this(characterName: characterName);

  @override
  RpgCharacterConfiguration moneyCoinCount(List<int> moneyCoinCount) =>
      this(moneyCoinCount: moneyCoinCount);

  @override
  RpgCharacterConfiguration characterStats(
          List<RpgCharacterStatValue> characterStats) =>
      this(characterStats: characterStats);

  @override
  RpgCharacterConfiguration inventory(
          List<RpgCharacterOwnedItemPair> inventory) =>
      this(inventory: inventory);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RpgCharacterConfiguration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RpgCharacterConfiguration(...).copyWith(id: 12, name: "My name")
  /// ````
  RpgCharacterConfiguration call({
    Object? characterName = const $CopyWithPlaceholder(),
    Object? moneyCoinCount = const $CopyWithPlaceholder(),
    Object? characterStats = const $CopyWithPlaceholder(),
    Object? inventory = const $CopyWithPlaceholder(),
  }) {
    return RpgCharacterConfiguration(
      characterName:
          characterName == const $CopyWithPlaceholder() || characterName == null
              ? _value.characterName
              // ignore: cast_nullable_to_non_nullable
              : characterName as String,
      moneyCoinCount: moneyCoinCount == const $CopyWithPlaceholder() ||
              moneyCoinCount == null
          ? _value.moneyCoinCount
          // ignore: cast_nullable_to_non_nullable
          : moneyCoinCount as List<int>,
      characterStats: characterStats == const $CopyWithPlaceholder() ||
              characterStats == null
          ? _value.characterStats
          // ignore: cast_nullable_to_non_nullable
          : characterStats as List<RpgCharacterStatValue>,
      inventory: inventory == const $CopyWithPlaceholder() || inventory == null
          ? _value.inventory
          // ignore: cast_nullable_to_non_nullable
          : inventory as List<RpgCharacterOwnedItemPair>,
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

RpgCharacterConfiguration _$RpgCharacterConfigurationFromJson(
        Map<String, dynamic> json) =>
    RpgCharacterConfiguration(
      characterName: json['characterName'] as String,
      moneyCoinCount: (json['moneyCoinCount'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      characterStats: (json['characterStats'] as List<dynamic>)
          .map((e) => RpgCharacterStatValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      inventory: (json['inventory'] as List<dynamic>)
          .map((e) =>
              RpgCharacterOwnedItemPair.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RpgCharacterConfigurationToJson(
        RpgCharacterConfiguration instance) =>
    <String, dynamic>{
      'characterName': instance.characterName,
      'moneyCoinCount': instance.moneyCoinCount,
      'characterStats': instance.characterStats,
      'inventory': instance.inventory,
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
