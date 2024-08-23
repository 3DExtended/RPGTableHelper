import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/navigation_service.dart';

class NavbarButton {
  final void Function() onPressed;
  final Widget icon;
  final TabItem tabItem;

  NavbarButton(
      {required this.onPressed, required this.icon, required this.tabItem});
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
    var navigationSerivce =
        DependencyProvider.of(context).getService<INavigationService>();
    var currentTabItem = navigationSerivce.getCurrentTabItem();

    List<Widget> children = navbarButtons.asMap().entries.map((e) {
      var isSelected = e.value.tabItem == currentTabItem;

      return CupertinoButton(
        minSize: 0,
        onPressed: () {
          navigationSerivce.setCurrentTabItem(e.value.tabItem);
          e.value.onPressed();
        },
        padding: const EdgeInsets.all(0),
        child: Theme(
          data: ThemeData(
            iconTheme: IconThemeData(
              color: isSelected == true
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
                color: isSelected ? secondaryNavbarColor : Colors.transparent,
              ),
              padding: const EdgeInsets.all(12),
              child: e.value.icon,
            ),
          ),
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
