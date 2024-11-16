import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/dynamic_height_column_layout.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:rpg_table_helper/helpers/list_extensions.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class PlayerScreenCharacterStatsForTab extends StatelessWidget {
  const PlayerScreenCharacterStatsForTab({
    super.key,
    required this.tabDef,
    required this.rpgConfig,
    required this.charToRender,
  });

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

      var padding = 20.0;
      var columnWidth =
          (constraints.maxWidth - padding * (numberOfColumns + 1)) /
              numberOfColumns.toDouble();

      var isOnlyTextPage = tabDef.statsInTab.every(
        (el) =>
            el.valueType == CharacterStatValueType.multiLineText ||
            el.valueType == CharacterStatValueType.singleLineText,
      );

      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(padding),
          clipBehavior: Clip.none,
          color: bgColor,
          child: isOnlyTextPage
              ? DynamicHeightColumnLayout(
                  spacing: padding,
                  runSpacing: padding,
                  numberOfColumns: numberOfColumns,
                  children:
                      getStatWidgetForTab(context, columnWidth: columnWidth),
                )
              : true
                  ? DynamicHeightColumnLayout(
                      numberOfColumns: numberOfColumns,
                      spacing: 20,
                      runSpacing: 20,
                      children: getStatWidgetForTab(context,
                          columnWidth: columnWidth),
                    )
                  : Builder(builder: (context) {
                      var children = getStatWidgetForTab(context,
                          columnWidth: columnWidth);

                      List<List<Widget>> columnChildren =
                          List.generate(numberOfColumns, (index) => []);
                      var runSpacing = 20.0;

                      var columnCounter = 0;
                      for (var child in children) {
                        if (columnChildren[columnCounter % numberOfColumns]
                            .isNotEmpty) {
                          columnChildren[columnCounter % numberOfColumns]
                              .add(SizedBox(
                            height: runSpacing,
                          ));
                        }
                        columnChildren[columnCounter % numberOfColumns]
                            .add(child);
                        columnCounter++;
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: columnChildren
                            .asMap()
                            .entries
                            .map((children) => [
                                  SizedBox(
                                    width: columnWidth,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: children.value,
                                    ),
                                  ),
                                  if (children.key < columnChildren.length - 1)
                                    SizedBox(
                                      width: padding,
                                    ),
                                ])
                            .expand((i) => i)
                            .toList(),
                      );
                    }),
        ),
      );
    });
  }

  List<Widget> getStatWidgetForTab(BuildContext context,
      {required double columnWidth}) {
    List<Widget> result = [];

    var statsInTab = tabDef.statsInTab;
    var statsOfCharacterInTab = statsInTab
        .where((st) =>
            charToRender?.characterStats
                .any((cs) => cs.statUuid == st.statUuid) ??
            false)
        .toList();

    // TODO use me to make group widgets...
    var statValueTypeConsecutiveCounts =
        statsOfCharacterInTab.consecutiveTypeCounts((a) => a.valueType);

    CharacterStatValueType? lastStatTypeUsed;
    for (var statToRender in statsOfCharacterInTab) {
      var matchingPlayerCharacterStat = charToRender?.characterStats
          .firstWhere((stat) => statToRender.statUuid == stat.statUuid);

      // TODO use me somehow
      var areStatTypesSimilar =
          areTwoValueTypesSimilar(statToRender.valueType, lastStatTypeUsed);

      result.add(SizedBox(
          width: columnWidth,
          child: getPlayerVisualizationWidget(
              context: context,
              characterName: charToRender?.characterName ?? "Charakter Name",
              statConfiguration: statToRender,
              useNewDesign: true,
              characterValue: matchingPlayerCharacterStat!)));
    }

    return result;
  }
}
