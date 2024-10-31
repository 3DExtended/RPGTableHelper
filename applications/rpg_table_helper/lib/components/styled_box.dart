import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:shadow_widget/shadow_widget.dart';

class StyledBox extends StatelessWidget {
  final Widget child;
  late final BoxDecoration? kInnerDecoration;
  late final BoxDecoration? kGradientBoxDecoration;
  final bool? disableShadow;
  final double? borderRadius;
  final double? borderThickness;
  StyledBox({
    super.key,
    required this.child,
    this.disableShadow,
    this.borderRadius,
    BoxDecoration? overrideGradientBoxDecoration,
    BoxDecoration? overrideInnerDecoration,
    this.borderThickness,
  }) {
    kInnerDecoration = overrideInnerDecoration ??
        BoxDecoration(
          gradient: navbarBackground,
          borderRadius: BorderRadius.circular(borderRadius ?? 32),
        );

    kGradientBoxDecoration = overrideGradientBoxDecoration ??
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
    var shadowChild = Container(
      clipBehavior: Clip.hardEdge,
      decoration: kGradientBoxDecoration,
      child: Padding(
        padding: EdgeInsets.all(borderThickness ?? 1.0),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: kInnerDecoration,
          child: child,
        ),
      ),
    );

    if (disableShadow == true) return shadowChild;

    return ShadowWidget(
        blurRadius: 7,
        offset: const Offset(2, 3),
        color: const Color.fromARGB(197, 0, 0, 0),
        child: shadowChild);
  }
}
