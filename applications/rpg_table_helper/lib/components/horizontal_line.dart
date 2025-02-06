import 'package:flutter/material.dart';
import 'package:quest_keeper/constants.dart';

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
            color: useDarkColor == true ? darkColor : middleBgColor,
          ),
        ),
      ],
    );
  }
}
