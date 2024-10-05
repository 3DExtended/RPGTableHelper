import 'package:flutter/cupertino.dart';
import 'package:rpg_table_helper/constants.dart';

class CategorizedItemLayout extends StatelessWidget {
  const CategorizedItemLayout({
    super.key,
    required this.categoryColumns,
    required this.contentChildren,
  });

  final List<Widget> categoryColumns;
  final List<Widget> contentChildren;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: const Color.fromARGB(32, 124, 124, 124),
          width: 240,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categoryColumns,
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: whiteBgTint,
            child: Column(
              children: contentChildren,
            ),
          ),
        ),
      ],
    );
  }
}
