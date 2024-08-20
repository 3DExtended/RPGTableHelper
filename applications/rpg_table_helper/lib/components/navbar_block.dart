import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/components/styled_box.dart';

class NavbarButton {
  final void Function() onPressed;
  final Widget icon;

  NavbarButton({required this.onPressed, required this.icon});
}

class NavbarBlock extends StatelessWidget {
  final List<NavbarButton> navbarButtons;
  final bool isLandscapeMode;

  const NavbarBlock({
    super.key,
    required this.navbarButtons,
    required this.isLandscapeMode,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = navbarButtons
        .map((e) => Container(
              padding: const EdgeInsets.all(10),
              child: e.icon,
            ))
        .toList();

    return StyledBox(
      borderRadius: 400, // fully rounded
      borderThickness: 2,
      child: RowColumnFlipper(
        isLandscapeMode: !isLandscapeMode,
        children: children,
      ),
    );
  }
}
