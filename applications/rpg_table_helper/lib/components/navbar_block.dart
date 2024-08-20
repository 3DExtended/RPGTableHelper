import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/constants.dart';

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
    var selectedIndex = 3;

    List<Widget> children = navbarButtons.asMap().entries.map((e) {
      var isSelected = e.key == selectedIndex;

      return Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            color: isSelected ? secondaryNavbarColor : Colors.transparent,
          ),
          padding: const EdgeInsets.all(12),
          child: e.value.icon,
        ),
      );
    }).toList();

    return StyledBox(
      borderRadius: 400, // fully rounded
      borderThickness: 2,
      child: RowColumnFlipper(
        isLandscapeMode: !isLandscapeMode,
        children: [
          const SizedBox(
            width: paddingBeforeAndAfterNavbarButtons,
            height: paddingBeforeAndAfterNavbarButtons,
          ),
          ...children,
          const SizedBox(
            width: paddingBeforeAndAfterNavbarButtons,
            height: paddingBeforeAndAfterNavbarButtons,
          ),
        ],
      ),
    );
  }
}
