import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:quest_keeper/constants.dart';

class CustomMarkdownBody extends StatelessWidget {
  const CustomMarkdownBody({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    var darkTextStyle = TextStyle(color: darkTextColor);

    return Theme(
      data: ThemeData(
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineLarge: darkTextStyle,
              headlineMedium: darkTextStyle,
              headlineSmall: darkTextStyle,
              titleLarge: darkTextStyle,
              titleMedium: darkTextStyle,
              titleSmall: darkTextStyle,
              bodySmall: darkTextStyle,
              bodyMedium: darkTextStyle,
              bodyLarge: darkTextStyle,
              labelSmall: darkTextStyle,
              labelMedium: darkTextStyle,
              labelLarge: darkTextStyle,
              displaySmall: darkTextStyle,
              displayMedium: darkTextStyle,
              displayLarge: darkTextStyle,
            ),
      ),
      child: MarkdownBody(
        data: text,
      ),
    );
  }
}
