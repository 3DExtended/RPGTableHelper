import 'package:flutter/material.dart';

class BorderCornerStone extends StatelessWidget {
  const BorderCornerStone({
    super.key,
    required this.alignment,
    required this.scalar,
    required this.backgroundColor,
  });

  final Alignment alignment;
  final double scalar;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(alignment.x * 7 * scalar, alignment.y * 7 * scalar),
        child: Transform.rotate(
          angle: 0.785398163,
          child: SizedBox(
            width: 25 * scalar,
            height: 25 * scalar,
            child: Container(color: backgroundColor),
          ),
        ),
      ),
    );
  }
}
