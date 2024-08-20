import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:shadow_widget/shadow_widget.dart';

class StyledBox extends StatelessWidget {
  final Widget child;
  late BoxDecoration? kInnerDecoration;
  late BoxDecoration? kGradientBoxDecoration;
  final double? borderRadius;
  final double? borderThickness;
  StyledBox({
    super.key,
    required this.child,
    this.borderRadius,
    this.kInnerDecoration,
    this.kGradientBoxDecoration,
    this.borderThickness,
  }) {
    kInnerDecoration = kInnerDecoration ??
        BoxDecoration(
          gradient: navbarBackground,
          borderRadius: BorderRadius.circular(borderRadius ?? 32),
        );

    kGradientBoxDecoration = kGradientBoxDecoration ??
        BoxDecoration(
          gradient: borderGradient,
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 32),
        );
  }

  @override
  Widget build(BuildContext context) {
    return ShadowWidget(
      blurRadius: 7,
      offset: const Offset(2, 3),
      color: const Color.fromARGB(197, 0, 0, 0),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: kGradientBoxDecoration,
        child: Padding(
          padding: EdgeInsets.all(borderThickness ?? 2.0),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: kInnerDecoration,
            child: child,
          ),
        ),
      ),
    );
  }
}
