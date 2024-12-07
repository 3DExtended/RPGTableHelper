import 'package:flutter/material.dart';
import 'package:shadow_widget/shadow_widget.dart';

class CustomShadowWidget extends StatelessWidget {
  const CustomShadowWidget({
    super.key,
    required this.child,
    this.offset = const Offset(-4, 4),
    this.blurRadius = 5.0,
  });

  final Widget child;
  final Offset offset;
  final double blurRadius;

  @override
  Widget build(BuildContext context) {
    return ShadowWidget(
      offset: offset,
      blurRadius: blurRadius,
      child: child,
    );
  }
}
