import 'package:flutter/material.dart';
import 'package:shadow_widget/shadow_widget.dart';

class CustomShadowWidget extends StatelessWidget {
  const CustomShadowWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShadowWidget(
      offset: Offset(-4, 4),
      blurRadius: 5,
      child: child,
    );
  }
}
