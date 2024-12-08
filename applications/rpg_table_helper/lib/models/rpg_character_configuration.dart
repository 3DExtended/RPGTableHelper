import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:uuid/v7.dart';

part 'rpg_character_configuration.g.dart';

abstract class RpgCharacterConfigurationBase {
  final String uuid;
  final String characterName;
  final List<RpgCharacterStatValue> characterStats;

  RpgCharacterConfigurationBase(
      {required this.uuid,
      required this.characterName,
      required this.characterStats});

  String getImageUrlWithoutBasePath(RpgConfigurationModel? rpgConfig) {
    var result = "assets/images/charactercard_placeholder.png";

    if (rpgConfig == null) {
      // we seemingly have no information about the current rpg. hence we search for a single image stat
      for (var stat in characterStats) {
        if (stat.serializedValue.contains("imageUrl")) {
          var imageUrl = jsonDecode(stat.serializedValue)["imageUrl"];
          if (imageUrl != null) return imageUrl;
        }
      }

      return result;
    }

    // check if there are generated image stats in default tab
    var imageStat = rpgConfig.characterStatTabsDefinition
        ?.firstWhereOrNull((e) => e.isDefaultTab)
        ?.statsInTab
        .firstWhereOrNull(
            (e) => e.valueType == CharacterStatValueType.singleImage);

    if (imageStat != null) {
      var statValueForCharacter = characterStats
          .firstWhereOrNull((e) => e.statUuid == imageStat.statUuid);
      if (statValueForCharacter != null) {
        var imageUrl =
            jsonDecode(statValueForCharacter.serializedValue)["imageUrl"];
        if (imageUrl != null) return imageUrl;
      }
    }

    // if not, search different tabs for images
    var imageStatInOtherTab = rpgConfig.characterStatTabsDefinition
        ?.map((e) => e.statsInTab)
        .expand((i) => i)
        .firstWhereOrNull(
            (e) => e.valueType == CharacterStatValueType.singleImage);

    if (imageStatInOtherTab != null) {
      var statValueForCharacter = characterStats
          .firstWhereOrNull((e) => e.statUuid == imageStatInOtherTab.statUuid);
      if (statValueForCharacter != null) {
        var imageUrl =
            jsonDecode(statValueForCharacter.serializedValue)["imageUrl"];
        if (imageUrl != null) return imageUrl;
      }
    }

    return result;
  }
}

@JsonSerializable()
@CopyWith()
class RpgAlternateCharacterConfiguration extends RpgCharacterConfigurationBase {
  // this can be used to create pets or other forms (like a druid might have)
  factory RpgAlternateCharacterConfiguration.fromJson(
          Map<String, dynamic> json) =>
      _$RpgAlternateCharacterConfigurationFromJson(json);

  RpgAlternateCharacterConfiguration({
    required super.uuid,
    required super.characterName,
    required super.characterStats,
  });

  Map<String, dynamic> toJson() =>
      _$RpgAlternateCharacterConfigurationToJson(this);
}

@JsonSerializable()
@CopyWith()
class RpgCharacterConfiguration extends RpgCharacterConfigurationBase {
  final int? moneyInBaseType;
  final List<RpgCharacterOwnedItemPair> inventory;
  // this can be used to create pets
  final List<RpgAlternateCharacterConfiguration>? companionCharacters;

  // this can be used to create pets
  final List<RpgAlternateCharacterConfiguration>? alternateForms;

  final int? activeAlternateFormIndex;

  factory RpgCharacterConfiguration.fromJson(Map<String, dynamic> json) =>
      _$RpgCharacterConfigurationFromJson(json);

  RpgCharacterConfiguration({
    required super.uuid,
    required super.characterName,
    required this.alternateForms,
    required this.moneyInBaseType,
    required this.activeAlternateFormIndex,
    required super.characterStats,
    required this.inventory,
    required this.companionCharacters,
  });

  Map<String, dynamic> toJson() => _$RpgCharacterConfigurationToJson(this);

  static RpgCharacterConfiguration getBaseConfiguration(
          RpgConfigurationModel? rpgConfig) =>
      RpgCharacterConfiguration(
        activeAlternateFormIndex: null,
        companionCharacters: [
          RpgAlternateCharacterConfiguration(
            uuid: "f6af1852-e928-4a4f-8d07-93ce87b879e8",
            characterName: "Lucky",
            characterStats: getDefaultStats(rpgConfig, true),
          ),
        ],
        alternateForms: [],
        uuid: const UuidV7().generate(),
        characterName: "Gandalf",
        characterStats: getDefaultStats(rpgConfig, false),
        inventory: [
          RpgCharacterOwnedItemPair(
              itemUuid: "a7537746-260d-4aed-b182-26768a9c2d51", amount: 2),
          RpgCharacterOwnedItemPair(
              itemUuid: "8abe00a8-fa94-4e5d-9c99-2a68b9de60e7", amount: 1)
        ],
        moneyInBaseType: 23456,
      );

  static List<RpgCharacterStatValue> getDefaultStats(
      RpgConfigurationModel? rpgConfig, bool filterForCompanionStats) {
    return rpgConfig == null || rpgConfig.characterStatTabsDefinition == null
        ? []
        : rpgConfig.characterStatTabsDefinition!
            .firstWhere((t) => t.isDefaultTab == true)
            .statsInTab
            .where((s) =>
                filterForCompanionStats == false ||
                s.isOptionalForAlternateForms != true)
            .map((stat) {
            switch (stat.valueType) {
              case CharacterStatValueType.int:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue: '{"value": 17}',
                );
              case CharacterStatValueType.intWithMaxValue:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue: '{"value": 17, "maxValue": 21}',
                );
              case CharacterStatValueType.listOfIntWithCalculatedValues:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue: '{"values": []}',
                );
              case CharacterStatValueType.intWithCalculatedValue:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue: '{"value": 17, "otherValue": 2}',
                );
              case CharacterStatValueType.multiLineText:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue:
                      '{"value": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum.\\nStet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.\\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."}',
                );
              case CharacterStatValueType.singleImage:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue:
                      '{"value": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmo", "imageUrl":"assets/images/charactercard_placeholder.png"}',
                );
              case CharacterStatValueType.singleLineText:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue:
                      '{"value": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr."}',
                );
              case CharacterStatValueType.multiselect:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue: '{"values": []}',
                );

              default:
                throw NotImplementedException();
            }
          }).toList();
  }
}

@JsonSerializable()
@CopyWith()
class RpgCharacterStatValue {
  final String statUuid;
  final String serializedValue;
  final bool? hideFromCharacterScreen;
  final bool? hideLabelOfStat;
  final int? variant;

  factory RpgCharacterStatValue.fromJson(Map<String, dynamic> json) =>
      _$RpgCharacterStatValueFromJson(json);

  RpgCharacterStatValue({
    required this.statUuid,
    required this.serializedValue,
    required this.hideFromCharacterScreen,
    required this.variant,
    required this.hideLabelOfStat,
  });

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
