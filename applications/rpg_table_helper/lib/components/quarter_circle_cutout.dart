import 'dart:math';

import 'package:flutter/material.dart';

class QuarterCircleCutout extends StatelessWidget {
  const QuarterCircleCutout({
    super.key,
    required this.circleOuterDiameter,
    required this.circleDegrees,
    required this.circleColor,
    required this.circleInnerDiameter,
    required this.cicleInnerColor,
  });

  final double circleOuterDiameter;
  final int circleDegrees;
  final Color circleColor;
  final double circleInnerDiameter;
  final Color cicleInnerColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: circleOuterDiameter,
      height: circleOuterDiameter,
      child: Transform.rotate(
        angle: circleDegrees * (pi / 180),
        child: Transform.translate(
          offset:
              Offset(-circleOuterDiameter * 2.0, -circleOuterDiameter * 2.0),
          child: ClipRRect(
            child: Transform.translate(
              offset:
                  Offset(circleOuterDiameter * 2.0, circleOuterDiameter * 2.0),
              child: Container(
                width: circleOuterDiameter,
                height: circleOuterDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                ),
                padding: EdgeInsets.all(
                    (circleOuterDiameter - circleInnerDiameter) / 2.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cicleInnerColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
