import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/components/styled_box.dart';

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
          child: StyledBox(
            kInnerDecoration: BoxDecoration(
              color: Colors.transparent,
              image: const DecorationImage(
                image: AssetImage(
                  "assets/images/bg.png",
                ),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: content,
          ),
        ),
      ),
    ];

    if (!isLandscape) {
      children = children.reversed.toList();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          "assets/images/bg.png",
          fit: BoxFit.fill,
        ),
        RowColumnFlipper(
          isLandscapeMode: isLandscape,
          children: children,
        ),
      ],
    );
  }
}
