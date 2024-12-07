import 'package:flutter/material.dart';

class BorderCornerStoneRound extends StatelessWidget {
  const BorderCornerStoneRound({
    super.key,
    required this.alignment,
    required this.scalar,
    required this.backgroundColor,
    required this.lightColor,
  });

  final Color lightColor;
  final Alignment alignment;
  final double scalar;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(alignment.x * 6 * scalar, alignment.y * 6 * scalar),
          child: Container(
            width: 16 * scalar,
            height: 16 * scalar,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: lightColor,
                    shape: BoxShape.circle,
                  ),
                  width: 7,
                  height: 7,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
