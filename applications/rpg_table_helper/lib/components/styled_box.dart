import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';

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
          color: Colors.white,
          border: Border.all(color: Colors.white),
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
    return Container(
      decoration: kGradientBoxDecoration,
      child: Padding(
        padding: EdgeInsets.all(borderThickness ?? 2.0),
        child: Container(
          decoration: kInnerDecoration,
          child: Padding(
            padding: EdgeInsets.all(borderThickness ?? 2.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
