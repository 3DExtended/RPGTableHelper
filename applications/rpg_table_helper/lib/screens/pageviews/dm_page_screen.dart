import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/newdesign/navbar_new_design.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/screens/select_game_mode_screen.dart';

class DmPageScreen extends StatefulWidget {
  static const String route = "dmpagescreen";
  const DmPageScreen({super.key});

  @override
  State<DmPageScreen> createState() => _DmPageScreenState();
}

class _DmPageScreenState extends State<DmPageScreen> {
  var pageViewController = PageController(
    initialPage: 0,
  );

  var _currentStep = 0;

  Future _goToStepId(int id) async {
    setState(() {
      _currentStep = id;
    });
    pageViewController.jumpToPage(id);
  }

  List<(String title, Widget child)> getDmScreens(BuildContext context) {
    return [
      (
        "1",
        Container(
          color: Colors.orange,
        )
      ),
      (
        "2",
        Container(
          color: Colors.red,
        )
      ),
      (
        "3",
        Container(
          color: Colors.blue,
        )
      ),
      (
        "4",
        Container(
          color: Colors.green,
        )
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var dmScreensToSwipe = getDmScreens(context);
    var currentTitle = dmScreensToSwipe[_currentStep].$1;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          NavbarNewDesign(
            useTopSafePadding: true,
            closeFunction: () {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  SelectGameModeScreen.route, (r) => false);
            },
            titleWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                ...List.generate(
                  _currentStep + 1,
                  (index) => CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.all(0),
                    onPressed: () async {
                      await _goToStepId(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Transform.rotate(
                        alignment: Alignment.center,
                        angle: 0.785398163, // 45 deg
                        child: CustomFaIcon(
                            icon: index == _currentStep
                                ? FontAwesomeIcons.solidSquare
                                : FontAwesomeIcons.square,
                            color: index == _currentStep
                                ? accentColor
                                : middleBgColor),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 20.0),
                  child: Text(
                    currentTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: textColor,
                          fontSize: 24,
                        ),
                  ),
                ),
                ...List.generate(
                  // TODO what is the correct number of steps
                  dmScreensToSwipe.length - (_currentStep + 1),
                  (index) => CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      _goToStepId(index + _currentStep + 1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Transform.rotate(
                        alignment: Alignment.center,
                        angle: 0.785398163, // 45 deg
                        child: CustomFaIcon(
                            icon: FontAwesomeIcons.square,
                            color: middleBgColor),
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            menuOpen: () {
              // TODO maybe open the configuration of the rpg
            },
            backInsteadOfCloseIcon: true,
          ),
          Expanded(
            child: Container(
              color: bgColor,
              child: PageView(
                controller: pageViewController,
                onPageChanged: (value) {
                  setState(() {
                    _currentStep = value;
                  });
                },
                scrollDirection: Axis.horizontal,
                children: dmScreensToSwipe.map((e) => e.$2).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
