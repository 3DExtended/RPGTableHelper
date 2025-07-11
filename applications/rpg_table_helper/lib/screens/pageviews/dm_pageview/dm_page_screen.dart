import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/components/prevent_swipe_navigation.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/context_extension.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_screen_campagne_management.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_screen_character_overview.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_screen_fight_squence.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_screen_grant_items.dart';
import 'package:quest_keeper/screens/pageviews/generated_images_screen.dart';
import 'package:quest_keeper/screens/pageviews/lore_screen.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class DmPageScreen extends ConsumerStatefulWidget {
  static const String route = "dmpagescreen";
  final int? startScreenOverride;

  const DmPageScreen({
    super.key,
    this.startScreenOverride,
  });

  @override
  ConsumerState<DmPageScreen> createState() => _DmPageScreenState();
}

class _DmPageScreenState extends ConsumerState<DmPageScreen> {
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
      (S.of(context).campaignManagement, DmScreenCampagneManagement()),
      (S.of(context).characterOverview, DmScreenCharacterOverview()),
      (S.of(context).fightingOrdering, DmScreenFightSquence()),
      (
        S.of(context).grantItems,
        DmScreenGrantItems(),
      ),
      (
        S.of(context).lore,
        LoreScreen(),
      ),
      (
        S.of(context).generatedImagesTabTitle,
        GeneratedImagesScreen(),
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

    return PreventSwipeNavigation(
      child: Scaffold(
        backgroundColor: CustomThemeProvider.of(context).theme.bgColor,
        body: Column(
          children: [
            Navbar(
              backInsteadOfCloseIcon: false,
              useTopSafePadding: true,
              closeFunction: () {
                // close connection
                ref
                    .read(connectionDetailsProvider.notifier)
                    .updateConfiguration(ref
                        .read(connectionDetailsProvider)
                        .requireValue
                        .copyWith(
                          isInSession: false,
                          isDm: false,
                        ));
                navigatorKey.currentState!.pop();
              },
              titleWidget: Builder(builder: (context) {
                var selectedIconColor =
                    CustomThemeProvider.of(context).theme.accentColor;
                var unselectedIconColor =
                    CustomThemeProvider.of(context).brightnessNotifier.value ==
                            Brightness.light
                        ? CustomThemeProvider.of(context).theme.textColor
                        : CustomThemeProvider.of(context).theme.darkTextColor;
                var textColor =
                    CustomThemeProvider.of(context).brightnessNotifier.value ==
                            Brightness.light
                        ? CustomThemeProvider.of(context).theme.textColor
                        : CustomThemeProvider.of(context).theme.darkTextColor;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    ...List.generate(
                      _currentStep + 1,
                      (index) => CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await _goToStepId(index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Transform.rotate(
                            alignment: Alignment.center,
                            angle: pi / 4, // 45 deg
                            child: CustomFaIcon(
                                icon: index == _currentStep
                                    ? FontAwesomeIcons.solidSquare
                                    : FontAwesomeIcons.square,
                                color: index == _currentStep
                                    ? selectedIconColor
                                    : unselectedIconColor),
                          ),
                        ),
                      ),
                    ),
                    if (context.isTablet)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 20.0),
                        child: Text(
                          currentTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: textColor,
                                fontSize: 24,
                              ),
                        ),
                      ),
                    ...List.generate(
                      dmScreensToSwipe.length - (_currentStep + 1),
                      (index) => CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _goToStepId(index + _currentStep + 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Transform.rotate(
                            alignment: Alignment.center,
                            angle: pi / 4, // 45 deg
                            child: CustomFaIcon(
                                icon: FontAwesomeIcons.square,
                                color: unselectedIconColor),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                );
              }),
              menuOpen: () {
                Navigator.of(context)
                    .pushNamed(allWizardConfigurations.entries.first.key);
              },
            ),
            Expanded(
              child: Container(
                color: CustomThemeProvider.of(context).theme.bgColor,
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
      ),
    );
  }
}
