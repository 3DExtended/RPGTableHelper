import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';

class HorizontalLine extends StatelessWidget {
  const HorizontalLine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: middleBgColor,
          ),
        ),
      ],
    );
  }
}
