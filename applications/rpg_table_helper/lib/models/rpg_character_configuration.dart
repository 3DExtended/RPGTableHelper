import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:uuid/v7.dart';

part 'rpg_character_configuration.g.dart';

abstract class RpgCharacterConfigurationBase {
  final String uuid;
  final String characterName;
  final List<RpgCharacterStatValue> characterStats;

  final bool? isAlternateFormActive;
  final RpgAlternateCharacterConfiguration? alternateForm;
  final List<TransformationComponent>? transformationComponents;

  RpgCharacterConfigurationBase(
      {required this.uuid,
      required this.characterName,
      required this.alternateForm,
      required this.isAlternateFormActive,
      required this.transformationComponents,
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
    required super.transformationComponents,
    required super.alternateForm,
    required super.isAlternateFormActive,
  });

  Map<String, dynamic> toJson() =>
      _$RpgAlternateCharacterConfigurationToJson(this);
}

@JsonSerializable()
@CopyWith()
class TransformationComponent {
  final String transformationUuid;
  final String transformationName;
  final String? transformationDescription;
  final List<RpgCharacterStatValue> transformationStats;

  factory TransformationComponent.fromJson(Map<String, dynamic> json) =>
      _$TransformationComponentFromJson(json);
  Map<String, dynamic> toJson() => _$TransformationComponentToJson(this);

  TransformationComponent({
    required this.transformationUuid,
    required this.transformationName,
    required this.transformationDescription,
    required this.transformationStats,
  });
}

@JsonSerializable()
@CopyWith()
class RpgTabConfiguration {
  final String tabUuid;
  final String tabIcon;

  factory RpgTabConfiguration.fromJson(Map<String, dynamic> json) =>
      _$RpgTabConfigurationFromJson(json);

  RpgTabConfiguration({
    required this.tabUuid,
    required this.tabIcon,
  });

  Map<String, dynamic> toJson() => _$RpgTabConfigurationToJson(this);
}

@JsonSerializable()
@CopyWith()
class RpgCharacterConfiguration extends RpgCharacterConfigurationBase {
  final int? moneyInBaseType;
  final List<RpgTabConfiguration>? tabConfigurations;

  final List<RpgCharacterOwnedItemPair> inventory;
  // this can be used to create pets
  final List<RpgAlternateCharacterConfiguration>? companionCharacters;

  // this can be used to create pets
  @Deprecated("alternate Forms are now in companionCharacters")
  final List<RpgAlternateCharacterConfiguration>? alternateForms;

  factory RpgCharacterConfiguration.fromJson(Map<String, dynamic> json) =>
      _$RpgCharacterConfigurationFromJson(json);

  RpgCharacterConfiguration({
    required super.uuid,
    required super.characterName,
    required this.tabConfigurations,
    required super.transformationComponents,
    required this.alternateForms,
    required this.moneyInBaseType,
    required super.isAlternateFormActive,
    required super.alternateForm,
    required super.characterStats,
    required this.inventory,
    required this.companionCharacters,
  });

  Map<String, dynamic> toJson() => _$RpgCharacterConfigurationToJson(this);

  static RpgCharacterConfiguration getBaseConfiguration(
          RpgConfigurationModel? rpgConfig,
          {int? variant}) =>
      RpgCharacterConfiguration(
        tabConfigurations: null,
        transformationComponents: [
          TransformationComponent(
              transformationUuid: "fb00e3f7-b8b4-4161-b13f-58f8072ce8df",
              transformationName: "Base",
              transformationDescription: "The base for all my transformations.",
              transformationStats: []),
          TransformationComponent(
              transformationUuid: "9febaf04-3119-4be4-b99e-ba0f69e91c44",
              transformationName: "Fire paw",
              transformationDescription: "One of the two paw types",
              transformationStats: []),
        ],
        alternateForm: null,
        isAlternateFormActive: null,
        companionCharacters: [
          RpgAlternateCharacterConfiguration(
            alternateForm: null,
            isAlternateFormActive: null,
            transformationComponents: null,
            uuid: "f6af1852-e928-4a4f-8d07-93ce87b879e8",
            characterName: "Lucky",
            characterStats: getDefaultStats(rpgConfig, true, 2),
          ),
        ],
        alternateForms: [],
        uuid: const UuidV7().generate(),
        characterName: "Gandalf",
        characterStats: getDefaultStats(rpgConfig, false, variant),
        inventory: [
          RpgCharacterOwnedItemPair(
              itemUuid: "a7537746-260d-4aed-b182-26768a9c2d51", amount: 2),
          RpgCharacterOwnedItemPair(
              itemUuid: "8abe00a8-fa94-4e5d-9c99-2a68b9de60e7", amount: 1),
          RpgCharacterOwnedItemPair(
              itemUuid: "73b51a58-8a07-4de2-828c-d0952d42af34", amount: 5),
          RpgCharacterOwnedItemPair(
              itemUuid: "01921428-f433-7519-880f-d012289b60da", amount: 1),
          RpgCharacterOwnedItemPair(
              itemUuid: "01921424-0eca-74bb-bc3d-be2c82996103", amount: 2)
        ],
        moneyInBaseType: 23456,
      );

  static List<RpgCharacterStatValue> getDefaultStats(
      RpgConfigurationModel? rpgConfig,
      bool filterForCompanionStats,
      int? variant) {
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
                  serializedValue: variant == null
                      ? '{"value": 17}'
                      : variant == 0
                          ? '{"value": 25}'
                          : '{"value": 30}',
                );
              case CharacterStatValueType.intWithMaxValue:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: 3,
                  statUuid: stat.statUuid,
                  serializedValue: variant == null
                      ? '{"value": 17, "maxValue": 21}'
                      : variant == 0
                          ? '{"value": 17, "maxValue": 30}'
                          : '{"value": 25, "maxValue": 25}',
                );
              case CharacterStatValueType.listOfIntWithCalculatedValues:
                var values =
                    jsonDecode(stat.jsonSerializedAdditionalData!)["values"];

                var stringToAdd = "";
                for (var i = 0; i < values.length; i++) {
                  if (i > 3) {
                    stringToAdd +=
                        '{"uuid":"${values[i]["uuid"]}", "value":9, "otherValue": -1}';
                  } else {
                    stringToAdd +=
                        '{"uuid":"${values[i]["uuid"]}", "value":12, "otherValue": 1}';
                  }
                  if (i < values.length - 1) stringToAdd += ",";
                }

                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue: '{"values": [$stringToAdd]}',
                );
              case CharacterStatValueType.listOfIntsWithIcons:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: 1,
                  statUuid: stat.statUuid,
                  serializedValue:
                      "{\"values\":[{\"uuid\":\"01933512-97e4-70fe-877d-0e1f64224a00\",\"value\":12},{\"uuid\":\"01933512-997d-7628-9de3-72827cf4f419\",\"value\":12},{\"uuid\":\"01933512-9cb6-7466-9977-0768e0dda2a7\",\"value\":12},{\"uuid\":\"01933512-a096-701e-875d-05ad93810ba2\",\"value\":12}]}",
                );
              case CharacterStatValueType
                    .characterNameWithLevelAndAdditionalDetails:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue:
                      '{"level":6, "values": [{"uuid":"019317b8-49eb-7575-9f8e-c28c9c8eded2","value":"Magier"},{"uuid":"019317b8-4bb6-7881-a4db-2a8ec3c751f6","value":"Mensch"}]}',
                );
              case CharacterStatValueType.intWithCalculatedValue:
                return RpgCharacterStatValue(
                  hideFromCharacterScreen: false,
                  hideLabelOfStat: false,
                  variant: null,
                  statUuid: stat.statUuid,
                  serializedValue: variant == null
                      ? '{"value": 17, "calculatedValue": 2}'
                      : variant == 0
                          ? '{"value": 10, "calculatedValue": 0}'
                          : '{"value": 9, "calculatedValue": -1}',
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
                      '{"value": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmo", "imageUrl":"assets/images/fortests/${variant == null ? 'charactercard_placeholder' : (variant == 0 ? 'somegandalfcharacter' : (variant == 1 ? 'somefrodocharacter' : 'somewolfcharacter'))}.png"}',
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
                  variant:
                      (jsonDecode(stat.jsonSerializedAdditionalData!)["options"]
                                      as List<dynamic>)
                                  .length >
                              6
                          ? 1
                          : null,
                  statUuid: stat.statUuid,
                  serializedValue:
                      '${'${'{"values": ["' + jsonDecode(stat.jsonSerializedAdditionalData!)["options"][0]["uuid"]}", "' + jsonDecode(stat.jsonSerializedAdditionalData!)["options"][2]["uuid"]}"]}',
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
  final bool? isCopy;

  factory RpgCharacterStatValue.fromJson(Map<String, dynamic> json) =>
      _$RpgCharacterStatValueFromJson(json);

  RpgCharacterStatValue({
    required this.statUuid,
    required this.serializedValue,
    required this.hideFromCharacterScreen,
    required this.variant,
    required this.hideLabelOfStat,
    this.isCopy = false,
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
