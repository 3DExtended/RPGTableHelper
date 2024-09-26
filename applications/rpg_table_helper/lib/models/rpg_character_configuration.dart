import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:uuid/v7.dart';

part 'rpg_character_configuration.g.dart';

@JsonSerializable()
@CopyWith()
class RpgCharacterConfiguration {
  final String uuid;
  final String characterName;
  final List<int> moneyCoinCount;
  final List<RpgCharacterStatValue> characterStats;
  final List<RpgCharacterOwnedItemPair> inventory;
  factory RpgCharacterConfiguration.fromJson(Map<String, dynamic> json) =>
      _$RpgCharacterConfigurationFromJson(json);

  RpgCharacterConfiguration({
    required this.uuid,
    required this.characterName,
    required this.moneyCoinCount,
    required this.characterStats,
    required this.inventory,
  });

  Map<String, dynamic> toJson() => _$RpgCharacterConfigurationToJson(this);

  static RpgCharacterConfiguration getBaseConfiguration(
          RpgConfigurationModel? rpgConfig) =>
      RpgCharacterConfiguration(
        uuid: const UuidV7().generate(),
        characterName: "",
        characterStats: [],
        inventory: [],
        moneyCoinCount: rpgConfig?.currencyDefinition.currencyTypes
                .map((e) => 0)
                .toList() ??
            [],
      );
}

@JsonSerializable()
@CopyWith()
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
@CopyWith()
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
