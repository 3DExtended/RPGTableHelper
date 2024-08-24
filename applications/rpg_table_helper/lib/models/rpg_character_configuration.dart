import 'package:json_annotation/json_annotation.dart';

part 'rpg_character_configuration.g.dart';

@JsonSerializable()
class RpgCharacterConfiguration {
  final String characterName;
  final List<int> moneyCoinCount;
  final List<RpgCharacterStatValue> characterStats;
  final List<RpgCharacterOwnedItemPair> inventory;
  factory RpgCharacterConfiguration.fromJson(Map<String, dynamic> json) =>
      _$RpgCharacterConfigurationFromJson(json);

  RpgCharacterConfiguration({
    required this.characterName,
    required this.moneyCoinCount,
    required this.characterStats,
    required this.inventory,
  });

  Map<String, dynamic> toJson() => _$RpgCharacterConfigurationToJson(this);
}

@JsonSerializable()
class RpgCharacterStatValue {
  final String statUuid;
  final String serializedValue;

  factory RpgCharacterStatValue.fromJson(Map<String, dynamic> json) =>
      _$RpgCharacterStatValueFromJson(json);

  RpgCharacterStatValue(
      {required this.statUuid, required this.serializedValue});

  Map<String, dynamic> toJson() => _$RpgCharacterStatValueToJson(this);
}

@JsonSerializable()
class RpgCharacterOwnedItemPair {
  final String itemUuid;
  final int amount;

  factory RpgCharacterOwnedItemPair.fromJson(Map<String, dynamic> json) =>
      _$RpgCharacterOwnedItemPairFromJson(json);

  RpgCharacterOwnedItemPair({
    required this.itemUuid,
    required this.amount,
  });

  Map<String, dynamic> toJson() => _$RpgCharacterOwnedItemPairToJson(this);
}
