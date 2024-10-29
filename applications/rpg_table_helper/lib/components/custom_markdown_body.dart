import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
              bodySmall: const TextStyle(color: Colors.white),
              bodyMedium: const TextStyle(color: Colors.white),
              bodyLarge: const TextStyle(color: Colors.white),
              labelSmall: const TextStyle(color: Colors.white),
              labelMedium: const TextStyle(color: Colors.white),
              labelLarge: const TextStyle(color: Colors.white),
              displaySmall: const TextStyle(color: Colors.white),
              displayMedium: const TextStyle(color: Colors.white),
              displayLarge: const TextStyle(color: Colors.white),
            ),
      ),
      child: MarkdownBody(
        data: text,
      ),
    );
  }
}
