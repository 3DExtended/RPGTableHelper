import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/categorized_item_layout.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_dropdown_menu.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:rpg_table_helper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:uuid/v7.dart';

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

  String? selectedTab;

  RpgConfigurationModel? rpgConfig;
  RpgCharacterConfiguration? characterConfig;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  String? selectedCharacterId;

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData(
      (value) {
        rpgConfig = value;
        rpgConfigurationLoaded = true;
        handlePossiblyMissingCharacterStats(null, null);

        var defaultTab = value.characterStatTabsDefinition
            ?.firstWhere((tab) => tab.isDefaultTab == true);

        if (defaultTab != null && selectedTab == null) {
          setState(() {
            selectedTab = defaultTab.uuid;
          });
        }
      },
    );
    ref.watch(rpgCharacterConfigurationProvider).whenData(
      (value) {
        characterConfig = value;

        if (!rpgCharacterConfigurationLoaded) {
          setState(() {
            selectedCharacterId = characterConfig!.uuid;
          });
          rpgCharacterConfigurationLoaded = true;
        }

        handlePossiblyMissingCharacterStats(null, null);
      },
    );

    var tabs = rpgConfig?.characterStatTabsDefinition ?? [];

    return CategorizedItemLayout(
      categoryColumns: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 20, 11),
          child: CustomDropdownMenu(
              selectedValueTemp: selectedCharacterId,
              setter: (newValue) {
                Future.delayed(Duration.zero, () async {
                  if (newValue == "new") {
                    // create a new alternate character
                    var playerCharacterName =
                        await askPlayerForCharacterName(context: context);

                    if (playerCharacterName == null) return;

                    var newAlternateCharacter =
                        RpgAlternateCharacterConfiguration(
                            uuid: UuidV7().generate(),
                            characterName: playerCharacterName,
                            characterStats: []);

                    var currentAlternateCharacters = ref
                            .read(rpgCharacterConfigurationProvider)
                            .requireValue
                            .alternateCharacters ??
                        [];

                    ref
                        .read(rpgCharacterConfigurationProvider.notifier)
                        .updateConfiguration(ref
                            .read(rpgCharacterConfigurationProvider)
                            .requireValue
                            .copyWith(alternateCharacters: [
                          ...currentAlternateCharacters,
                          newAlternateCharacter
                        ]));
                    setState(() {
                      selectedCharacterId = newAlternateCharacter.uuid;
                    });
                  } else {
                    setState(() {
                      selectedCharacterId = newValue;
                    });
                  }

                  // ensure stats are filled for that character
                  handlePossiblyMissingCharacterStats(null, true);
                });
              },
              noBorder: true,
              items: characterConfig == null
                  ? []
                  : [
                      DropdownMenuItem(
                        value: characterConfig!.uuid,
                        child: Text(characterConfig?.characterName == null ||
                                characterConfig!.characterName.isEmpty
                            ? "Player Name"
                            : characterConfig!.characterName),
                      ),
                      ...(characterConfig!.alternateCharacters ?? []).map(
                        (altChar) => DropdownMenuItem(
                          value: altChar.uuid,
                          child: Text(altChar.characterName.isEmpty
                              ? "Player Name"
                              : altChar.characterName),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "new",
                        child: Text("Neu"),
                      ),
                    ],
              label: ""),
        ),
        const HorizontalLine(),
        ...tabs.map(
          (tab) => CupertinoButton(
            onPressed: () {
              setState(() {
                selectedTab = tab.uuid;
              });
            },
            minSize: 0,
            padding: const EdgeInsets.all(0),
            child: Container(
              color: tab.uuid == selectedTab ? whiteBgTint : Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tab.tabName,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      contentChildren: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 23.0),
              child: Text(
                "Charakter Sheet", // TODO localize
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: Colors.white, fontSize: 32),
              ),
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: selectedTab == null
                      ? Container()
                      : CustomButton(
                          isSubbutton: true,
                          onPressed: () async {
                            handlePossiblyMissingCharacterStats(
                                selectedTab, null);
                          },
                          icon: const CustomFaIcon(icon: FontAwesomeIcons.gear),
                        ),
                ),
              ],
            ))
          ],
        ),
        const HorizontalLine(),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Builder(builder: (context) {
                CharacterStatValueType? lastStatTypeUsed;
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 10,
                  children: tabs
                          .singleWhereOrNull((tab) => tab.uuid == selectedTab)
                          ?.statsInTab
                          .where((statInTab) {
                            List<RpgCharacterStatValue>?
                                selectedCharacterStats =
                                getSelectedCharacterStats();

                            var matchingPlayerCharacterStat =
                                selectedCharacterStats?.firstWhereOrNull(
                                    (stat) =>
                                        statInTab.statUuid == stat.statUuid);
                            if (matchingPlayerCharacterStat == null) {
                              return false;
                            }
                            return true;
                          })
                          .toList()
                          .asMap()
                          .entries
                          .map((statInTab) {
                            List<Widget> result = [];
                            List<RpgCharacterStatValue>?
                                selectedCharacterStats =
                                getSelectedCharacterStats();

                            var matchingPlayerCharacterStat =
                                selectedCharacterStats?.firstWhereOrNull(
                                    (stat) =>
                                        statInTab.value.statUuid ==
                                        stat.statUuid);

                            if (!areTwoValueTypesSimilar(
                                statInTab.value.valueType, lastStatTypeUsed)) {
                              if (statInTab.key != 0) {
                                result.add(Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      height: 1,
                                    )),
                                  ],
                                ));
                              }
                              lastStatTypeUsed = statInTab.value.valueType;
                            }

                            if (matchingPlayerCharacterStat == null) {
                              result.add(Container());
                              return result;
                            }

                            var child = getPlayerVisualizationWidget(
                                context: context,
                                statConfiguration: statInTab.value,
                                characterValue: matchingPlayerCharacterStat);

                            if (statInTab.value.valueType ==
                                    CharacterStatValueType.multiLineText ||
                                statInTab.value.valueType ==
                                    CharacterStatValueType.singleLineText ||
                                statInTab.value.valueType ==
                                    CharacterStatValueType.intWithMaxValue) {
                              result.add(Row(
                                children: [Expanded(child: child)],
                              ));
                              return result;
                            }
                            result.add(child);

                            return result;
                          })
                          .expand((l) => l)
                          .toList() ??
                      [],
                );
              }),
            ),
          ),
        )),
      ],
    );
  }

  List<RpgCharacterStatValue>? getSelectedCharacterStats(
      {RpgCharacterConfiguration? overrideRpgCharConfig}) {
    return getSelectedCharacterBase(
            overrideRpgCharConfig: overrideRpgCharConfig)
        ?.characterStats;
  }

  RpgCharacterConfigurationBase? getSelectedCharacterBase(
      {RpgCharacterConfiguration? overrideRpgCharConfig}) {
    var charConfigToUse = overrideRpgCharConfig ?? characterConfig;

    if (selectedCharacterId != null && charConfigToUse != null) {
      if (charConfigToUse.uuid == selectedCharacterId) {
        return charConfigToUse;
      } else {
        return charConfigToUse.alternateCharacters
            ?.firstWhereOrNull((alt) => alt.uuid == selectedCharacterId);
      }
    }
    return charConfigToUse;
  }

  void handlePossiblyMissingCharacterStats(
      String? tabFilter, bool? ignorePossiblyMissingCharacterStatsHandled) {
    if (!rpgCharacterConfigurationLoaded ||
        !rpgConfigurationLoaded ||
        (ignorePossiblyMissingCharacterStatsHandled != true &&
            (possiblyMissingCharacterStatsHandled && tabFilter == null)) ||
        DependencyProvider.of(context).isMocked) {
      return;
    }

    if (ignorePossiblyMissingCharacterStatsHandled != true) {
      possiblyMissingCharacterStatsHandled = true;
    }

    Future.delayed(Duration.zero, () async {
      // find all stat uuids:
      var listOfStats = rpgConfig!.characterStatTabsDefinition
              ?.where((tab) => tabFilter == null || tab.uuid == tabFilter)
              .map((t) => t.statsInTab)
              .expand((i) => i)
              .toList() ??
          [];

      var selectedCharacterStats = getSelectedCharacterStats();

      var anyStatNotFilledYet = listOfStats
          .where((st) =>
              tabFilter != null ||
              !(selectedCharacterStats ?? [])
                  .map((charstat) => charstat.statUuid)
                  .contains(st.statUuid))
          .toList();

      if (anyStatNotFilledYet.isNotEmpty) {
        // TODO show modal asking the user if they want to configure their character now or later

        List<RpgCharacterStatValue> updatedCharacterStats = [];
        var characterName = getSelectedCharacterBase()?.characterName;
        for (var statToFill in anyStatNotFilledYet) {
          // check if the user already configured some stats
          var possiblyFilledStat = selectedCharacterStats
              ?.firstWhereOrNull((s) => s.statUuid == statToFill.statUuid);

          var modalResult = await showGetPlayerConfigurationModal(
            context: context,
            statConfiguration: statToFill,
            characterValue: possiblyFilledStat,
            characterName: characterName,
          );

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

          var mergedStatsForSelectedCharacter = getSelectedCharacterStats(
              overrideRpgCharConfig: newestCharacterConfig);

          var mergedStats = mergedStatsForSelectedCharacter ?? [];
          mergedStats.removeWhere((st) => updatedCharacterStats
              .any((upst) => upst.statUuid == st.statUuid));
          mergedStats.addAll(updatedCharacterStats);

          setState(() {
            var isUpdatingMainCharacter = selectedCharacterId == null ||
                selectedCharacterId == characterConfig!.uuid;

            if (isUpdatingMainCharacter) {
              characterConfig =
                  newestCharacterConfig.copyWith(characterStats: mergedStats);

              ref
                  .read(rpgCharacterConfigurationProvider.notifier)
                  .updateConfiguration(newestCharacterConfig.copyWith(
                      characterStats: mergedStats));
            } else {
              List<RpgAlternateCharacterConfiguration> alternateCharactersCopy =
                  [...(newestCharacterConfig.alternateCharacters ?? [])];

              var indexOfSelectedAltChar = alternateCharactersCopy
                  .indexWhere((e) => e.uuid == selectedCharacterId!);

              if (indexOfSelectedAltChar == -1) {
                throw NotImplementedException();
              } else {
                alternateCharactersCopy[indexOfSelectedAltChar] =
                    alternateCharactersCopy[indexOfSelectedAltChar]
                        .copyWith(characterStats: mergedStats);

                characterConfig = newestCharacterConfig.copyWith(
                    alternateCharacters: alternateCharactersCopy);

                ref
                    .read(rpgCharacterConfigurationProvider.notifier)
                    .updateConfiguration(newestCharacterConfig.copyWith(
                        alternateCharacters: alternateCharactersCopy));
              }
            }
          });
        }
      }
    });
  }
}
