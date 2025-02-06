import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:signalr_netcore/errors.dart';

class PlayerPageHelpers {
  static Future<String?> askPlayerForCharacterName(
      {required BuildContext context, String? currentCharacterName}) async {
    var characterNameStat = CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: false,
      statUuid: "00000000-0000-0000-0000-000000000000",
      name: S.of(context).characterName,
      helperText: S.of(context).nameOfCharacterHelperText,
      valueType: CharacterStatValueType.singleLineText,
      editType: CharacterStatEditType.static,
    );

    var result = await showGetPlayerConfigurationModal(
        context: context,
        statConfiguration: characterNameStat,
        hideAdditionalSetting: true,
        hideVariantSelection: true,
        characterToRenderStatFor: null,
        characterName:
            currentCharacterName ?? S.of(context).characterNameDefault,
        characterValue: currentCharacterName == null
            ? null
            : RpgCharacterStatValue(
                hideLabelOfStat: false,
                hideFromCharacterScreen: false,
                statUuid: characterNameStat.statUuid,
                serializedValue: '{"value": "$currentCharacterName"}',
                variant: null,
              ));

    if (result == null) return null;
    var parsedValue = jsonDecode(result.serializedValue)["value"];

    return parsedValue;
  }

  static void handlePossiblyMissingCharacterStats({
    required WidgetRef ref,
    required BuildContext context,
    required RpgConfigurationModel rpgConfig,
    required RpgCharacterConfigurationBase selectedCharacter,
    String? filterTabId,
  }) {
    if (DependencyProvider.of(context).isMocked) {
      return;
    }

    Future.delayed(Duration.zero, () async {
      var tabsToValidate = rpgConfig.characterStatTabsDefinition
          ?.where((tab) => filterTabId == null || tab.uuid == filterTabId);

      var tempLoadedCharacterConfig =
          ref.read(rpgCharacterConfigurationProvider).requireValue;

      var selectedCharacterId = selectedCharacter.uuid;
      var isUpdatingMainCharacter =
          selectedCharacterId == tempLoadedCharacterConfig.uuid;
      var isUpdatingCompanionCharacter =
          (tempLoadedCharacterConfig.companionCharacters ?? [])
              .any((e) => e.uuid == selectedCharacterId);

      // find all stat uuids:
      var listOfStats =
          tabsToValidate?.map((t) => t.statsInTab).expand((i) => i).toList() ??
              [];

      var selectedCharacterStats = selectedCharacter.characterStats;

      var anyStatNotFilledYet = listOfStats
          .where((st) =>
              (!isUpdatingCompanionCharacter ||
                  st.valueType !=
                      CharacterStatValueType
                          .companionSelector // we are not allowing the companionSelector stat on companions
              ) &&
              (filterTabId != null ||
                  !(selectedCharacterStats
                      .map((charstat) => charstat.statUuid)
                      .contains(st.statUuid))))
          .toList();

      if (anyStatNotFilledYet.isNotEmpty ||
          selectedCharacter.characterName.trim().isEmpty) {
        List<RpgCharacterStatValue> updatedCharacterStats = [];

        String? updatedCharacterName = selectedCharacter.characterName;
        if (updatedCharacterName.trim().isEmpty ||
            (filterTabId != null &&
                tabsToValidate?.firstOrNull?.isDefaultTab == true)) {
          if (!context.mounted) return;

          updatedCharacterName = await askPlayerForCharacterName(
              context: context,
              currentCharacterName: selectedCharacter.characterName);

          if (updatedCharacterName == null) return;
        }

        for (var statToFill in anyStatNotFilledYet) {
          // check if the user already configured some stats
          var possiblyFilledStat = selectedCharacterStats
              .firstWhereOrNull((s) => s.statUuid == statToFill.statUuid);
          if (!context.mounted) return;

          var modalResult = await showGetPlayerConfigurationModal(
            characterToRenderStatFor:
                selectedCharacter is RpgCharacterConfiguration
                    ? selectedCharacter
                    : null,
            context: context,
            statConfiguration: statToFill,
            characterValue: possiblyFilledStat,
            characterName: updatedCharacterName,
          );

          if (modalResult != null) {
            updatedCharacterStats.add(modalResult);
          } else {
            // cancelled once cancells all configuration
            break;
          }
        }

        // add modalResult to characterConfiguration
        if (updatedCharacterStats.isNotEmpty ||
            updatedCharacterName != selectedCharacter.characterName) {
          var newestCharacterConfig =
              ref.read(rpgCharacterConfigurationProvider).requireValue;

          var mergedStatsForSelectedCharacter =
              selectedCharacter.characterStats;

          var mergedStats = mergedStatsForSelectedCharacter;
          mergedStats.removeWhere((st) => updatedCharacterStats
              .any((upst) => upst.statUuid == st.statUuid));
          mergedStats.addAll(updatedCharacterStats);

          if (isUpdatingMainCharacter) {
            ref
                .read(rpgCharacterConfigurationProvider.notifier)
                .updateConfiguration(newestCharacterConfig.copyWith(
                    characterName: updatedCharacterName,
                    characterStats: mergedStats));
          } else {
            List<RpgAlternateCharacterConfiguration> companionCharactersCopy = [
              ...(newestCharacterConfig.companionCharacters ?? [])
            ];

            var indexOfSelectedCompChar = companionCharactersCopy
                .indexWhere((e) => e.uuid == selectedCharacterId);

            if (indexOfSelectedCompChar == -1) {
              // check altforms
              List<RpgAlternateCharacterConfiguration> altCharactersCopy = [
                ...(newestCharacterConfig.alternateForms ?? [])
              ];
              var indexOfSelectedAltForm = altCharactersCopy
                  .indexWhere((e) => e.uuid == selectedCharacterId);

              if (indexOfSelectedAltForm == -1) {
                throw NotImplementedException();
              } else {
                altCharactersCopy[indexOfSelectedAltForm] =
                    altCharactersCopy[indexOfSelectedAltForm].copyWith(
                  characterStats: mergedStats,
                  characterName: updatedCharacterName,
                );

                ref
                    .read(rpgCharacterConfigurationProvider.notifier)
                    .updateConfiguration(newestCharacterConfig.copyWith(
                        alternateForms: altCharactersCopy));
              }
            } else {
              companionCharactersCopy[indexOfSelectedCompChar] =
                  companionCharactersCopy[indexOfSelectedCompChar].copyWith(
                characterStats: mergedStats,
                characterName: updatedCharacterName,
              );

              ref
                  .read(rpgCharacterConfigurationProvider.notifier)
                  .updateConfiguration(newestCharacterConfig.copyWith(
                      companionCharacters: companionCharactersCopy));
            }
          }
        }
      }
    });
  }
}
