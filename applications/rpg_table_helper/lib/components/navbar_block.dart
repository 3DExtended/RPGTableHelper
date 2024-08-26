import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/services/navigation_service.dart';

class NavbarButton {
  final void Function(TabItem? clickedItem)? onPressed;
  final Widget icon;
  final TabItem? tabItem;

  NavbarButton({
    required this.onPressed,
    required this.icon,
    required this.tabItem,
  });
}

class NavbarBlock extends StatelessWidget {
  final List<NavbarButton> navbarButtons;
  final bool isLandscapeMode;
  final int selectedNavbarButton;

  const NavbarBlock({
    super.key,
    required this.navbarButtons,
    required this.isLandscapeMode,
    required this.selectedNavbarButton,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = navbarButtons.asMap().entries.map((e) {
      var buttonChild = Theme(
        data: ThemeData(
          iconTheme: IconThemeData(
            color: selectedNavbarButton == e.key
                ? Colors.white
                : const Color.fromARGB(255, 141, 141, 141),
            size: 24,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1000),
              color: selectedNavbarButton == e.key
                  ? secondaryNavbarColor
                  : Colors.transparent,
            ),
            padding: const EdgeInsets.all(12),
            child: e.value.icon,
          ),
        ),
      );

      if (e.value.onPressed != null)
        return CupertinoButton(
          minSize: 0,
          onPressed: () {
            if (e.value.onPressed != null) e.value.onPressed!(e.value.tabItem);
          },
          padding: const EdgeInsets.all(0),
          child: buttonChild,
        );
      else {
        return buttonChild;
      }
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
