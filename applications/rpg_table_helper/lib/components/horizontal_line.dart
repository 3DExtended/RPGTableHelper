import 'package:flutter/material.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class HorizontalLine extends StatelessWidget {
  final bool? useDarkColor;

  const HorizontalLine({super.key, this.useDarkColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: useDarkColor == true
                ? CustomThemeProvider.of(context).theme.darkColor
                : CustomThemeProvider.of(context).theme.middleBgColor,
          ),
        ),
      ],
    );
  }
}
