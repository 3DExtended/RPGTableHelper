import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:shadow_widget/shadow_widget.dart';

class ProgressIndicatorForCharacterScreen extends StatelessWidget {
  const ProgressIndicatorForCharacterScreen({
    super.key,
    required this.padding,
    required this.progressPercentage,
    required this.value,
    required this.maxValue,
    required this.title,
  });

  final double padding;
  final double progressPercentage;
  final int value;
  final int maxValue;
  final String title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var width = max(350, min(constraints.maxWidth, constraints.maxHeight)) -
          2.0 * padding;
      var strokeWidth = width * .1;

      var containerWidth = width - 2.5 * strokeWidth;
      var fontSize = containerWidth * 0.2;

      return ShadowWidget(
        offset: Offset(-4, 4),
        blurRadius: 5,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Circle
              Container(
                width: width, // Adjust the size as needed
                height: width,
                decoration: BoxDecoration(
                  color: darkColor,
                  shape: BoxShape.circle,
                ),
              ),
              // Circular Progress Indicator for HP
              SizedBox(
                width: containerWidth,
                height: containerWidth,
                child: CircularProgressIndicator(
                  value: progressPercentage,
                  strokeWidth: strokeWidth,
                  color: accentColor,
                  backgroundColor: Colors.transparent,
                ),
              ),
              // HP Text (e.g., "9/14")
              SizedBox(
                width: containerWidth,
                height: containerWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$value/$maxValue',
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    SizedBox(
                      height: strokeWidth * 0.5,
                    ),
                    AutoSizeText(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      minFontSize: 10,
                      softWrap: true,
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
