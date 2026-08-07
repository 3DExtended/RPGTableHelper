import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/dynamic_height_column_layout.dart';
import 'package:quest_keeper/components/long_press_scale_widget.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_helpers.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class PlayerScreenCharacterStatsForTab extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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

      final ledger = isArcaneLedgerActive(context) && !onlyTextTab;
      // Mock Arcane Ledger Stats is a fixed 3-column composition — only on default Stats tab.
      final ledgerStatsLayout = ledger && tabDef.isDefaultTab == true;
      if (ledgerStatsLayout && numberOfColumns > 3) {
        numberOfColumns = 3;
      }

      var padding = 20.0;
      var columnWidth =
          (constraints.maxWidth - padding * (numberOfColumns + 1)) /
              numberOfColumns.toDouble();

      final widgetsAndTypes = getStatWidgetsForCurrentTab(
        context,
        ref,
        columnWidth: columnWidth,
      );
      final children = widgetsAndTypes.map((e) => e.widget).toList();
      Map<int, int>? fixedMapping;
      if (ledgerStatsLayout && numberOfColumns == 3) {
        fixedMapping = {
          for (var i = 0; i < widgetsAndTypes.length; i++)
            i: _ledgerColumnFor(widgetsAndTypes[i].valueType),
        };
      }

      return Stack(
        children: [
          SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(padding),
                clipBehavior: Clip.none,
                color: characterSheetSurfaceColor(context),
                child: DynamicHeightColumnLayout(
                  spacing: padding,
                  runSpacing: padding,
                  numberOfColumns: numberOfColumns,
                  fixedChildMapping: fixedMapping,
                  children: children,
                )),
          ),
          if (ledgerStatsLayout && fixedMapping != null && numberOfColumns >= 2)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _LedgerColumnRulePainter(
                    columns: numberOfColumns,
                    padding: padding,
                    ink: CustomThemeProvider.of(context).theme.darkColor,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  /// Mock Stats columns:
  /// 0 = identity / combat icons / lists
  /// 1 = portrait (+ quote)
  /// 2 = ability hexes / HP
  static int _ledgerColumnFor(CharacterStatValueType type) {
    switch (type) {
      case CharacterStatValueType.singleImage:
        return 1;
      case CharacterStatValueType.listOfIntWithCalculatedValues:
      case CharacterStatValueType.intWithMaxValue:
        return 2;
      case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
      case CharacterStatValueType.listOfIntsWithIcons:
      case CharacterStatValueType.multiselect:
      default:
        return 0;
    }
  }

  List<({Widget widget, CharacterStatValueType valueType})>
      getStatWidgetsForCurrentTab(BuildContext context, WidgetRef ref,
          {required double columnWidth}) {
    List<({Widget widget, CharacterStatValueType valueType})> result = [];

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

      result.add((
        valueType: statToRender.valueType,
        widget: LongPressScaleWidget(
          onLongPress: () {
            // Preview / DM views may not have hydrated the player character
            // provider; missing-stats edits only apply to the live player session.
            final connectionDetails =
                ref.read(connectionDetailsProvider).valueOrNull;
            if (connectionDetails == null ||
                connectionDetails.isDm ||
                !connectionDetails.isInSession ||
                !ref.read(rpgCharacterConfigurationProvider).hasValue) {
              return;
            }

            Future.delayed(Duration.zero, () async {
              if (!context.mounted) return;

              PlayerPageHelpers.handlePossiblyMissingCharacterStats(
                  ref: ref,
                  context: context,
                  filterStatUuid: statToRender.statUuid,
                  rpgConfig: rpgConfig,
                  selectedCharacter: charToRender!);
            });
          },
          child: SizedBox(
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
                  characterValue: matchingPlayerCharacterStat)),
        ),
      ));
    }

    return result;
  }
}

class _LedgerColumnRulePainter extends CustomPainter {
  final int columns;
  final double padding;
  final Color ink;

  _LedgerColumnRulePainter({
    required this.columns,
    required this.padding,
    required this.ink,
  });

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -pi / 2 + i * pi / 4;
      final radius = i.isEven ? r : r * 0.4;
      final p = Offset(c.dx + cos(angle) * radius, c.dy + sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (columns < 2) return;
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.38)
      ..strokeWidth = 1.0;
    final paintInner = Paint()
      ..color = ink.withValues(alpha: 0.22)
      ..strokeWidth = 0.8;
    final star = Paint()
      ..color = ink.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final usable = size.width - padding * 2;
    for (var i = 1; i < columns; i++) {
      final x = padding + usable * (i / columns);
      final top = padding + 18;
      final bottom = size.height - padding - 18;
      canvas.drawLine(Offset(x - 1.2, top), Offset(x - 1.2, bottom), paint);
      canvas.drawLine(Offset(x + 1.2, top), Offset(x + 1.2, bottom), paintInner);
      _drawStar(canvas, Offset(x, padding + 10), 5.5, star);
      _drawStar(canvas, Offset(x, size.height - padding - 10), 5.5, star);
      _drawStar(canvas, Offset(x, size.height / 2), 4.0, star);
    }
  }

  @override
  bool shouldRepaint(covariant _LedgerColumnRulePainter oldDelegate) =>
      oldDelegate.columns != columns ||
      oldDelegate.padding != padding ||
      oldDelegate.ink != ink;
}
