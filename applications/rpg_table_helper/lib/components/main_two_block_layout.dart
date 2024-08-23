import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/constants.dart';

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

    // TODO is connected or not
    var isConnectedToServer = false;

    var isConnectedBtn = Padding(
      padding: EdgeInsets.fromLTRB(
        outerPadding,
        outerPadding,
        !isLandscape ? outerPadding * 2 : outerPadding,
        isLandscape ? outerPadding * 2 : outerPadding,
      ),
      child: StyledBox(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1000),
              color: Colors.transparent,
            ),
            padding: const EdgeInsets.all(12),
            child: Theme(
                data: ThemeData(
                  iconTheme: IconThemeData(
                    color: isConnectedToServer
                        ? const Color.fromARGB(255, 12, 163, 90)
                        : const Color.fromARGB(255, 163, 12, 12),
                    size: 24,
                  ),
                ),
                child: FaIcon(isConnectedToServer
                    ? FontAwesomeIcons.link
                    : FontAwesomeIcons.linkSlash)),
          ),
        ),
      ),
    );

    var children = [
      const SizedBox(
        height: outerPadding,
        width: outerPadding,
      ),
      RowColumnFlipper(
        isLandscapeMode: !isLandscape,
        children: [
          const Spacer(),
          CupertinoButton(
              minSize: 0,
              padding: const EdgeInsets.all(0),
              onPressed: () {},
              child: isConnectedBtn),
          Center(
            child: NavbarBlock(
              isLandscapeMode: isLandscape,
              navbarButtons: navbarButtons,
            ),
          ),
          Opacity(
            opacity: 0,
            child: isConnectedBtn,
          ),
          const Spacer(),
        ],
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isLandscape ? outerPadding : outerPadding * 2,
            outerPadding * 2,
            outerPadding * 2,
            !isLandscape ? outerPadding : outerPadding * 2,
          ),
          child: StyledBox(
            overrideInnerDecoration: BoxDecoration(
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
