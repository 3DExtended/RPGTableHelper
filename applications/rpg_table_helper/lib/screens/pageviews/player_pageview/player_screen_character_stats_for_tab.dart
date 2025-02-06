import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/dynamic_height_column_layout.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

class PlayerScreenCharacterStatsForTab extends StatelessWidget {
  const PlayerScreenCharacterStatsForTab({
    super.key,
    required this.tabDef,
    required this.rpgConfig,
    required this.charToRender,
    required this.onStatValueChanged,
  });

  final void Function(RpgCharacterStatValue) onStatValueChanged;
  final CharacterStatsTabDefinition tabDef;
  final RpgConfigurationModel rpgConfig;
  final RpgCharacterConfigurationBase? charToRender;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // we need to define the width of each widget for the upcoming columnized view
      var numberOfColumns = 1;
      if (constraints.maxWidth > 333 * 2.0) {
        numberOfColumns++;
      }
      if (constraints.maxWidth > 333 * 3.0) {
        numberOfColumns++;
      }
      if (constraints.maxWidth > 333 * 4.0) {
        numberOfColumns++;
      }

      // reduce number of columns if there arent as many stats to render
      var onlyTextTab = tabDef.statsInTab.every((s) =>
          s.valueType == CharacterStatValueType.singleLineText ||
          s.valueType == CharacterStatValueType.multiLineText);

      if (onlyTextTab) {
        numberOfColumns = min(tabDef.statsInTab.length, numberOfColumns);
      }

      var padding = 20.0;
      var columnWidth =
          (constraints.maxWidth - padding * (numberOfColumns + 1)) /
              numberOfColumns.toDouble();

      return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(padding),
            clipBehavior: Clip.none,
            color: bgColor,
            child: DynamicHeightColumnLayout(
              spacing: padding,
              runSpacing: padding,
              numberOfColumns: numberOfColumns,
              children: getStatWidgetsForCurrentTab(context,
                  columnWidth: columnWidth),
            )),
      );
    });
  }

  List<Widget> getStatWidgetsForCurrentTab(BuildContext context,
      {required double columnWidth}) {
    List<Widget> result = [];

    var statsInTab = tabDef.statsInTab;
    var statsOfCharacterInTab = statsInTab
        .where((st) =>
            charToRender?.characterStats
                .any((cs) => cs.statUuid == st.statUuid) ??
            false)
        .toList();

    for (var statToRender in statsOfCharacterInTab) {
      var matchingPlayerCharacterStat = charToRender?.characterStats
          .firstWhereOrNull((stat) =>
              statToRender.statUuid == stat.statUuid &&
              stat.hideFromCharacterScreen != true);

      if (matchingPlayerCharacterStat == null) continue;

      result.add(SizedBox(
          width: columnWidth,
          child: getPlayerVisualizationWidget(
              characterToRenderStatFor: charToRender != null &&
                      charToRender is RpgCharacterConfiguration
                  ? charToRender as RpgCharacterConfiguration
                  : null,
              onNewStatValue: (newSerializedValue) {
                var updatedStatValue = matchingPlayerCharacterStat.copyWith(
                    serializedValue: newSerializedValue);
                onStatValueChanged(updatedStatValue);
              },
              context: context,
              characterName: charToRender?.characterName ??
                  S.of(context).characterNameDefault,
              statConfiguration: statToRender,
              characterValue: matchingPlayerCharacterStat)));
    }

    return result;
  }
}
