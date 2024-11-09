import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/components/newdesign/custom_item_card.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class DmScreenCharacterOverview extends ConsumerStatefulWidget {
  const DmScreenCharacterOverview({
    super.key,
  });

  @override
  ConsumerState<DmScreenCharacterOverview> createState() =>
      _DmScreenCharacterOverviewState();
}

class _DmScreenCharacterOverviewState
    extends ConsumerState<DmScreenCharacterOverview> {
  @override
  Widget build(BuildContext context) {
    var connectionDetails = ref.watch(connectionDetailsProvider).valueOrNull;
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;

    return Container(
        color: bgColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: connectionDetails == null || rpgConfig == null
                ? CustomLoadingSpinner()
                : Wrap(
                    runSpacing: 20,
                    spacing: 20,
                    children: getPlayerCharacterCards(
                        context, connectionDetails, rpgConfig),
                  ),
          ),
        ));
  }

  List<Widget> getPlayerCharacterCards(BuildContext context,
      ConnectionDetails connectionDetails, RpgConfigurationModel rpgConfig) {
    List<
        (
          RpgCharacterConfigurationBase,
          bool isAlternateForm,
          bool isCompanion
        )> charactersToRender = [];

    if (connectionDetails.connectedPlayers != null) {
      for (var connectedPlayer in (connectionDetails.connectedPlayers!)) {
        var charConfig = connectedPlayer.configuration;

        if (charConfig.activeAlternateFormIndex == null ||
            charConfig.alternateForms == null ||
            charConfig.alternateForms!.length <=
                charConfig.activeAlternateFormIndex!) {
          charactersToRender.add((charConfig, false, false));
        } else {
          charactersToRender.add((
            charConfig.alternateForms![charConfig.activeAlternateFormIndex!],
            true,
            false
          ));
        }

        if (charConfig.companionCharacters != null &&
            charConfig.companionCharacters!.isNotEmpty) {
          charactersToRender.addAll(
              charConfig.companionCharacters!.map((c) => (c, false, true)));
        }
      }
    }

    if (charactersToRender.isEmpty) {
      return [
        SizedBox(
          height: 50,
        ),
        Center(
          child: Text(
            "Aktuell keine Spieler online",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: darkTextColor, fontWeight: FontWeight.bold),
          ),
        )
      ];
    }

    List<Widget> result = [];

    var defaultStatTab = rpgConfig.characterStatTabsDefinition
        ?.firstWhere((e) => e.isDefaultTab);

    // build player character card for every entry in charactersToRender
    for (var (characterToRender, isAlternateForm, isCompanion)
        in charactersToRender) {
      var characterName = characterToRender.characterName.trim().isEmpty
          ? "Player"
          : characterToRender.characterName;
      var characterImage =
          characterToRender.getImageUrlWithoutBasePath(rpgConfig);
      (
        CharacterStatDefinition,
        RpgCharacterStatValue
      )? characterStatWithMaxValueForBarVisuals;

      List<(CharacterStatDefinition, RpgCharacterStatValue)>
          characterSingleNumberStats = [];

      if (defaultStatTab != null &&
          rpgConfig.characterStatTabsDefinition != null) {
        var statsToConsiderForCharacter = defaultStatTab.statsInTab
            .where((e) =>
                isAlternateForm == false ||
                e.isOptionalForAlternateForms == false)
            .where((e) =>
                isCompanion == false ||
                e.isOptionalForCompanionCharacters == false)
            .toList();

        characterStatWithMaxValueForBarVisuals =
            getIntWithMaxValueStatForCharacter(
                statsToConsiderForCharacter, characterToRender);

        var intStatsToConsider = statsToConsiderForCharacter
            .where((e) => e.valueType == CharacterStatValueType.int)
            .take(8) // print maximum 8 stats
            .toList();

        for (var statToConsider in intStatsToConsider) {
          // search stat in char
          var statValue = characterToRender.characterStats
              .firstWhereOrNull((cs) => cs.statUuid == statToConsider.statUuid);
          if (statValue != null) {
            characterSingleNumberStats.add((statToConsider, statValue));
          }
        }
      }

      result.add(
        CustomCharacterCard(
          characterName: characterName,
          characterSingleNumberStats: characterSingleNumberStats,
          imageUrl: characterImage,
          greyScale: false,
          isLoadingNewImage: false,
          characterStatWithMaxValueForBarVisuals:
              characterStatWithMaxValueForBarVisuals,
        ),
      );
    }

    return result;
  }

  (CharacterStatDefinition, RpgCharacterStatValue)?
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
