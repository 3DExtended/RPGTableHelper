import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/categorized_item_layout.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/character_stats/get_player_visualization_widget.dart';
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

  String? selectedTab;

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

        var defaultTab = value.characterStatTabsDefinition
            ?.firstWhere((tab) => tab.isDefaultTab == true);

        if (defaultTab != null) {
          setState(() {
            selectedTab = defaultTab.uuid;
          });
        }
      },
    );
    ref.watch(rpgCharacterConfigurationProvider).whenData(
      (value) {
        characterConfig = value;
        rpgCharacterConfigurationLoaded = true;
        handlePossiblyMissingCharacterStats();
      },
    );

    var tabs = rpgConfig?.characterStatTabsDefinition ?? [];

    return CategorizedItemLayout(
      categoryColumns: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: CustomMarkdownBody(
              text:
                  "# ${characterConfig?.characterName == null || characterConfig!.characterName.isEmpty ? "Player Name" : characterConfig!.characterName}"),
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
              padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 14.0),
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
                  child: CustomButton(
                    isSubbutton: true,
                    onPressed: () async {
                      // TODO configure character
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
                  spacing: 50,
                  runSpacing: 20,
                  children: tabs
                          .singleWhereOrNull((tab) => tab.uuid == selectedTab)
                          ?.statsInTab
                          .where((statInTab) {
                            var matchingPlayerCharacterStat = characterConfig
                                ?.characterStats
                                .firstWhereOrNull((stat) =>
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
                            var matchingPlayerCharacterStat = characterConfig
                                ?.characterStats
                                .firstWhereOrNull((stat) =>
                                    statInTab.value.statUuid == stat.statUuid);

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

  bool areTwoValueTypesSimilar(CharacterStatValueType valueType,
      CharacterStatValueType? lastStatTypeUsed) {
    if (lastStatTypeUsed == null) {
      false;
    }

    if (lastStatTypeUsed == valueType) return true;
    if (lastStatTypeUsed == CharacterStatValueType.multiLineText &&
        valueType == CharacterStatValueType.singleLineText) {
      return true;
    }
    if (valueType == CharacterStatValueType.multiLineText &&
        lastStatTypeUsed == CharacterStatValueType.singleLineText) {
      return true;
    }

    return false;
  }
}
