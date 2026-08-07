import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class HorizontalLine extends StatelessWidget {
  final bool? useDarkColor;

  const HorizontalLine({super.key, this.useDarkColor});

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final Color lineColor;
    if (useDarkColor == true) {
      lineColor = theme.darkColor;
    } else if (isDecoratedSheetSkinActive(context)) {
      // middleBg is nearly invisible on parchment / night atlas.
      lineColor = theme.darkColor.withValues(alpha: 0.35);
    } else {
      lineColor = theme.middleBgColor;
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: lineColor,
          ),
        ),
      ],
    );
  }
}
