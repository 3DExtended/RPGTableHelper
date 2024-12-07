import 'package:flutter/material.dart';

class CardBorder extends StatelessWidget {
  const CardBorder({
    super.key,
    required this.borderRadius,
    required this.color,
    required this.borderSize,
    required this.child,
  });

  final double borderRadius;
  final Color color;
  final double borderSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: color,
      ),
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.all(borderSize),
      child: child,
    );
  }
}
