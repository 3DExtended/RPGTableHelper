import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/newdesign/navbar_new_design.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/screens/pageviews/dm_pageview/dm_screen_campagne_management.dart';
import 'package:rpg_table_helper/screens/pageviews/dm_pageview/dm_screen_character_overview.dart';
import 'package:rpg_table_helper/screens/pageviews/dm_pageview/dm_screen_fight_squence.dart';
import 'package:rpg_table_helper/screens/pageviews/dm_pageview/dm_screen_grant_items.dart';
import 'package:rpg_table_helper/screens/wizards/all_wizard_configurations.dart';

class DmPageScreen extends StatefulWidget {
  static const String route = "dmpagescreen";
  final int? startScreenOverride;

  const DmPageScreen({
    super.key,
    this.startScreenOverride,
  });

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
      ("Kampagnen Management", DmScreenCampagneManagement()),
      ("Charakter Übersicht", DmScreenCharacterOverview()),
      ("Kampf Reihenfolge", DmScreenFightSquence()),
      (
        "Items verteilen",
        DmScreenGrantItems(),
      ),
    ];
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (widget.startScreenOverride != null) {
        _goToStepId(widget.startScreenOverride!);
      }
    });
    super.initState();
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
              navigatorKey.currentState!.pop();
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
              Navigator.of(context)
                  .pushNamed(allWizardConfigurations.entries.first.key);
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
