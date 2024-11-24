import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/screens/wizards/all_wizard_configurations.dart';

class MainTwoBlockLayout extends ConsumerWidget {
  final List<NavbarButton> navbarButtons;
  final Widget content;
  final int selectedNavbarButton;
  final bool showIsConnectedButton;
  const MainTwoBlockLayout({
    super.key,
    required this.navbarButtons,
    required this.selectedNavbarButton,
    required this.content,
    required this.showIsConnectedButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // figure out if landscape or if portrait mode
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var isLandscape = width >= height;

    var connectionDetails = ref.watch(connectionDetailsProvider).value;
    var isConnectedToServer = connectionDetails?.isConnected ?? false;
    var isDmDevice = connectionDetails?.isDm ?? true;
    var isInSession = connectionDetails?.isInSession ?? false;

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
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1000),
              color: Colors.transparent,
            ),
            padding: const EdgeInsets.fromLTRB(12, 13, 12, 13),
            child: Theme(
                data: ThemeData(
                  iconTheme: IconThemeData(
                    color: isInSession
                        ? const Color.fromARGB(255, 12, 163, 90)
                        : const Color.fromARGB(255, 163, 12, 12),
                    size: 16,
                  ),
                ),
                child: FaIcon(isInSession
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
          if (showIsConnectedButton)
            CupertinoButton(
                minSize: 0,
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  if (isInSession) {
                    if (isDmDevice) {
                      Navigator.of(context)
                          .pushNamed(allWizardConfigurations.entries.first.key);
                    } else {
                      // TODO open configuration for players
                    }
                  } else {
                    // open "connect modal"
                    if (isConnectedToServer) {
                    } else {
                      // This is a fallback such that the dm can work offline on their configurations
                      Navigator.of(context)
                          .pushNamed(allWizardConfigurations.entries.first.key);
                    }
                  }
                },
                child: isConnectedBtn),
          Center(
            child: NavbarBlock(
              isLandscapeMode: isLandscape,
              navbarButtons: navbarButtons,
              selectedNavbarButton: selectedNavbarButton,
            ),
          ),
          if (showIsConnectedButton)
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
            disableShadow: true,
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
