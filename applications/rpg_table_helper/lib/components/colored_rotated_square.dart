import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';

class ColoredRotatedSquare extends StatelessWidget {
  const ColoredRotatedSquare({
    super.key,
    required this.isSolidSquare,
    required this.color,
  });

  final bool isSolidSquare;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Transform.rotate(
        alignment: Alignment.center,
        angle: pi / 4,
        child: CustomFaIcon(
          icon: isSolidSquare
              ? FontAwesomeIcons.solidSquare
              : FontAwesomeIcons.square,
          color: color,
        ),
      ),
    );
  }
}
