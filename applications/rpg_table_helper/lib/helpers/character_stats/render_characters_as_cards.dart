import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:quest_keeper/components/custom_character_card.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

class RenderCharactersAsCards {
  static List<Widget> renderCharactersAsCharacterCard(
      BuildContext context,
      List<
              ({
                RpgCharacterConfigurationBase characterToRender,
                bool isAlternateForm,
                bool isCompanion
              })>
          charactersToRender,
      RpgConfigurationModel rpgConfig) {
    List<Widget> result = [];

    // build player character card for every entry in charactersToRender
    for (var tuple in charactersToRender) {
      var defaultStatTab = rpgConfig.characterStatTabsDefinition
          ?.firstWhere((e) => e.isDefaultTab);
      var characterName = tuple.characterToRender.characterName.trim().isEmpty
          ? S.of(context).characterNameDefault
          : tuple.characterToRender.characterName;
      var characterImage =
          tuple.characterToRender.getImageUrlWithoutBasePath(rpgConfig);
      (
        CharacterStatDefinition,
        RpgCharacterStatValue
      )? characterStatWithMaxValueForBarVisuals;

      List<({String label, int value})> characterSingleNumberStats = [];

      if (defaultStatTab != null &&
          rpgConfig.characterStatTabsDefinition != null) {
        var statsToConsiderForCharacter = defaultStatTab.statsInTab
            .where((e) =>
                tuple.isAlternateForm == false ||
                e.isOptionalForAlternateForms != true)
            .where((e) =>
                tuple.isCompanion == false ||
                e.isOptionalForCompanionCharacters != true)
            .toList();

        characterStatWithMaxValueForBarVisuals =
            getIntWithMaxValueStatForCharacter(
                statsToConsiderForCharacter, tuple.characterToRender);

        var intStatsToConsider = statsToConsiderForCharacter
            .where((e) => e.valueType == CharacterStatValueType.int)
            .take(8) // print maximum 8 stats
            .toList();

        for (var statToConsider in intStatsToConsider) {
          // search stat in char
          var statValue = tuple.characterToRender.characterStats
              .firstWhereOrNull((cs) => cs.statUuid == statToConsider.statUuid);
          if (statValue != null) {
            // => RpgCharacterStatValue.serializedValue == {"value": 17}
            characterSingleNumberStats.add((
              label: statToConsider.name,
              value: int.parse((jsonDecode(statValue.serializedValue)
                          as Map<String, dynamic>)["value"]
                      ?.toString() ??
                  "0")
            ));
          }
        }

        if (characterSingleNumberStats.isEmpty) {
          // look for ints with icons and transform (and show) them instead
          var intListStatsToConsider = statsToConsiderForCharacter
              .where((e) =>
                  e.valueType == CharacterStatValueType.listOfIntsWithIcons)
              .take(1) // print maximum 8 stats
              .toList();

          for (var statConfiguration in intListStatsToConsider) {
            // search stat in char
            var statValue = tuple.characterToRender.characterStats
                .firstWhereOrNull(
                    (cs) => cs.statUuid == statConfiguration.statUuid);
            if (statValue != null) {
              // => RpgCharacterStatValue.serializedValue == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "value": 12, "otherValue": 2}]}
              // => statConfiguration.jsonSerializedAdditionalData! == {"values":[{"uuid":"theCorrespondingUuidOfTheGroupValue", "label": "HP"}]}
              var parsedValue = ((jsonDecode(statValue.serializedValue)
                      as Map<String, dynamic>)["values"] as List<dynamic>)
                  .map((t) => t as Map<String, dynamic>)
                  .toList();

              var statConfigLabels =
                  (jsonDecode(statConfiguration.jsonSerializedAdditionalData!)[
                          "values"] as List<dynamic>)
                      .map((t) => t as Map<String, dynamic>)
                      .toList();

              var filledValues = statConfigLabels
                  .map(
                    (e) {
                      var parsedMatchingValue = parsedValue.singleWhereOrNull(
                        (element) => element["uuid"] == e["uuid"],
                      );

                      return (
                        label: e["label"] as String,
                        iconName: e["iconName"] as String,
                        value: parsedMatchingValue?["value"] as int? ?? 0,
                      );
                    },
                  )
                  .sortedBy((e) => e.label)
                  .toList();

              characterSingleNumberStats.addAll(filledValues
                  .take(6)
                  .map((e) => (label: e.label, value: e.value)));
            }
          }
        }
      }

      result.add(
        CustomCharacterCard(
          characterName: characterName,
          characterSingleNumberStats: characterSingleNumberStats,
          imageUrl: characterImage,
          isGreyscale: false,
          isLoading: false,
          characterStatWithMaxValueForBarVisuals:
              characterStatWithMaxValueForBarVisuals,
        ),
      );
    }

    return result;
  }

  static (CharacterStatDefinition, RpgCharacterStatValue)?
      getIntWithMaxValueStatForCharacter(
          List<CharacterStatDefinition> statsToConsiderForCharacter,
          RpgCharacterConfigurationBase characterToRender) {
    var firstRequiredIntWithMaxValueStat =
        statsToConsiderForCharacter.firstWhereOrNull(
            (e) => e.valueType == CharacterStatValueType.intWithMaxValue);
    if (firstRequiredIntWithMaxValueStat != null) {
      var statValueOfCharacter = characterToRender.characterStats
          .firstWhereOrNull(
              (cs) => cs.statUuid == firstRequiredIntWithMaxValueStat.statUuid);
      if (statValueOfCharacter != null) {
        return (firstRequiredIntWithMaxValueStat, statValueOfCharacter);
      }
    }
    return null;
  }
}
