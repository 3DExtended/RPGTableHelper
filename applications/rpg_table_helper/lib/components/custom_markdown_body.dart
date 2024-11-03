import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:rpg_table_helper/constants.dart';

class CustomMarkdownBody extends StatelessWidget {
  const CustomMarkdownBody({
    super.key,
    required this.text,
    this.isNewDesign,
  });

  final bool? isNewDesign;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineLarge: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              headlineMedium: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              headlineSmall: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              titleLarge: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              titleMedium: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              titleSmall: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              bodySmall: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              bodyMedium: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              bodyLarge: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              labelSmall: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              labelMedium: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              labelLarge: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              displaySmall: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              displayMedium: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
              displayLarge: TextStyle(
                  color: isNewDesign == true ? darkTextColor : textColor),
            ),
      ),
      child: MarkdownBody(
        data: text,
      ),
    );
  }
}
