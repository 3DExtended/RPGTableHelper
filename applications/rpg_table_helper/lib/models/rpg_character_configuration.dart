import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:uuid/v7.dart';

part 'rpg_character_configuration.g.dart';

@JsonSerializable()
@CopyWith()
class RpgCharacterConfiguration {
  final String uuid;
  final String characterName;
  final int? moneyInBaseType;
  final List<RpgCharacterStatValue> characterStats;
  final List<RpgCharacterOwnedItemPair> inventory;
  factory RpgCharacterConfiguration.fromJson(Map<String, dynamic> json) =>
      _$RpgCharacterConfigurationFromJson(json);

  RpgCharacterConfiguration({
    required this.uuid,
    required this.characterName,
    required this.moneyInBaseType,
    required this.characterStats,
    required this.inventory,
  });

  Map<String, dynamic> toJson() => _$RpgCharacterConfigurationToJson(this);

  static RpgCharacterConfiguration getBaseConfiguration(
          RpgConfigurationModel? rpgConfig) =>
      RpgCharacterConfiguration(
        uuid: const UuidV7().generate(),
        characterName: "Gandalf",
        characterStats:
            rpgConfig == null || rpgConfig.characterStatTabsDefinition == null
                ? []
                : rpgConfig.characterStatTabsDefinition!
                    .firstWhere((t) => t.isDefaultTab == true)
                    .statsInTab
                    .map((stat) {
                    switch (stat.valueType) {
                      case CharacterStatValueType.int:
                        return RpgCharacterStatValue(
                          statUuid: stat.statUuid,
                          serializedValue: '{"value": 17}',
                        );
                      case CharacterStatValueType.intWithMaxValue:
                        return RpgCharacterStatValue(
                          statUuid: stat.statUuid,
                          serializedValue: '{"value": 17, "maxValue": 21}',
                        );
                      case CharacterStatValueType.intWithCalculatedValue:
                        return RpgCharacterStatValue(
                          statUuid: stat.statUuid,
                          serializedValue: '{"value": 17, "otherValue": 2}',
                        );
                      case CharacterStatValueType.multiLineText:
                        return RpgCharacterStatValue(
                          statUuid: stat.statUuid,
                          serializedValue:
                              '{"value": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum.\\nStet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.\\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."}',
                        );
                      case CharacterStatValueType.singleLineText:
                        return RpgCharacterStatValue(
                          statUuid: stat.statUuid,
                          serializedValue:
                              '{"value": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr."}',
                        );
                      case CharacterStatValueType.multiselect:
                        return RpgCharacterStatValue(
                          statUuid: stat.statUuid,
                          serializedValue: '{"values": []}',
                        );

                      default:
                        throw NotImplementedException();
                    }
                  }).toList(),
        inventory: [
          RpgCharacterOwnedItemPair(
              itemUuid: "a7537746-260d-4aed-b182-26768a9c2d51", amount: 2),
          RpgCharacterOwnedItemPair(
              itemUuid: "8abe00a8-fa94-4e5d-9c99-2a68b9de60e7", amount: 1)
        ],
        moneyInBaseType: 23456,
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
