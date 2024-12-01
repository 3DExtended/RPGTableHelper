import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:rpg_table_helper/constants.dart';

class CustomMarkdownBody extends StatelessWidget {
  const CustomMarkdownBody({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineLarge: TextStyle(color: darkTextColor),
              headlineMedium: TextStyle(color: darkTextColor),
              headlineSmall: TextStyle(color: darkTextColor),
              titleLarge: TextStyle(color: darkTextColor),
              titleMedium: TextStyle(color: darkTextColor),
              titleSmall: TextStyle(color: darkTextColor),
              bodySmall: TextStyle(color: darkTextColor),
              bodyMedium: TextStyle(color: darkTextColor),
              bodyLarge: TextStyle(color: darkTextColor),
              labelSmall: TextStyle(color: darkTextColor),
              labelMedium: TextStyle(color: darkTextColor),
              labelLarge: TextStyle(color: darkTextColor),
              displaySmall: TextStyle(color: darkTextColor),
              displayMedium: TextStyle(color: darkTextColor),
              displayLarge: TextStyle(color: darkTextColor),
            ),
      ),
      child: MarkdownBody(
        data: text,
      ),
    );
  }
}
