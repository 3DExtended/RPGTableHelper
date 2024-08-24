// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpg_character_configuration.dart';

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
