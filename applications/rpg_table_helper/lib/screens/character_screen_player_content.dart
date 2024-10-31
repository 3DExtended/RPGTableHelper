import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/fill_remaining_space.dart';
import 'package:rpg_table_helper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

class CharacterScreenPlayerContent extends ConsumerStatefulWidget {
  const CharacterScreenPlayerContent({
    super.key,
  });

  @override
  ConsumerState<CharacterScreenPlayerContent> createState() =>
      _CharacterScreenPlayerContentState();
}

class _CharacterScreenPlayerContentState
    extends ConsumerState<CharacterScreenPlayerContent> {
  var rpgConfigurationLoaded = false;
  var rpgCharacterConfigurationLoaded = false;
  var possiblyMissingCharacterStatsHandled = false;

  RpgConfigurationModel? rpgConfig;
  RpgCharacterConfiguration? characterConfig;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData(
      (value) {
        rpgConfig = value;
        rpgConfigurationLoaded = true;
        handlePossiblyMissingCharacterStats();
      },
    );
    ref.watch(rpgCharacterConfigurationProvider).whenData(
      (value) {
        characterConfig = value;
        rpgCharacterConfigurationLoaded = true;
        handlePossiblyMissingCharacterStats();
      },
    );

    return FillRemainingSpace(
        child: Container(
      padding: const EdgeInsets.all(20),
      child: const Text(
        "CharacterScreen",
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  void handlePossiblyMissingCharacterStats() {
    if (!rpgCharacterConfigurationLoaded ||
        !rpgConfigurationLoaded ||
        possiblyMissingCharacterStatsHandled ||
        DependencyProvider.of(context).isMocked) {
      return;
    }

    possiblyMissingCharacterStatsHandled = true;

    Future.delayed(Duration.zero, () async {
      // find all stat uuids:
      var listOfStats = rpgConfig!.characterStatTabsDefinition
              ?.map((t) => t.statsInTab)
              .expand((i) => i)
              .toList() ??
          [];

      var anyStatNotFilledYet = listOfStats
          .where((st) => !characterConfig!.characterStats
              .map((charstat) => charstat.statUuid)
              .contains(st.statUuid))
          .toList();

      if (anyStatNotFilledYet.isNotEmpty) {
        // TODO show modal asking the user if they want to configure their character now or later

        List<RpgCharacterStatValue> updatedCharacterStats = [];
        for (var statToFill in anyStatNotFilledYet) {
          var modalResult = await showGetPlayerConfigurationModal(
              context: context, statConfiguration: statToFill);

          if (modalResult != null) {
            updatedCharacterStats.add(modalResult);
          } else {
            // cancelled once cancells all configuration
            break;
          }
        }

        // add modalResult to characterConfiguration
        if (updatedCharacterStats.isNotEmpty) {
          var newestCharacterConfig =
              ref.read(rpgCharacterConfigurationProvider).requireValue;

          var mergedStats = newestCharacterConfig.characterStats;
          mergedStats.removeWhere((st) => updatedCharacterStats
              .any((upst) => upst.statUuid == st.statUuid));
          mergedStats.addAll(updatedCharacterStats);

          ref
              .read(rpgCharacterConfigurationProvider.notifier)
              .updateConfiguration(
                  newestCharacterConfig.copyWith(characterStats: mergedStats));
        }
      }
    });
  }
}
