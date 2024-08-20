import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';

class MainTwoBlockLayout extends StatelessWidget {
  final List<NavbarButton> navbarButtons;
  final Widget content;
  const MainTwoBlockLayout({
    super.key,
    required this.navbarButtons,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    // figure out if landscape or if portrait mode
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var isLandscape = width >= height;

    var children = [
      const SizedBox(
        height: 30,
        width: 30,
      ),
      NavbarBlock(
        isLandscapeMode: isLandscape,
        navbarButtons: navbarButtons,
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isLandscape ? 30 : 60,
            60,
            60,
            !isLandscape ? 30 : 60,
          ),
          child: content,
        ),
      ),
    ];

    if (!isLandscape) {
      children = children.reversed.toList();
    }

    return RowColumnFlipper(
      isLandscapeMode: isLandscape,
      children: children,
    );
  }
}
