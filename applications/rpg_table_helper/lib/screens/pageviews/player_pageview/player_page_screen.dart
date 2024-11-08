import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/newdesign/navbar_new_design.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

// TODO refactor this class as it is a direct copy of the dm_page_screen
class PlayerPageScreen extends ConsumerStatefulWidget {
  static const String route = "playerpagescreen";
  final int? startScreenOverride;

  // used by the dm screen to view stats of (offline) players
  final RpgCharacterConfiguration? characterConfigurationOverride;
  final bool? disableEdit;

  // TODO WILO i need to set those through page routes...
  const PlayerPageScreen({
    super.key,
    this.startScreenOverride,
    this.disableEdit,
    this.characterConfigurationOverride,
  });

  @override
  ConsumerState<PlayerPageScreen> createState() => _PlayerPageScreenState();
}

class _PlayerPageScreenState extends ConsumerState<PlayerPageScreen> {
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
    var rpgConfig = ref.read(rpgConfigurationProvider).valueOrNull;

    if (rpgConfig == null) return [];

    List<(String title, Widget child)> result = [];

    for (var tabDef in (rpgConfig.characterStatTabsDefinition ??
        List<CharacterStatsTabDefinition>.empty())) {
      result.add((
        tabDef.tabName,
        Container(
          // TODO create me
          color: Colors.red,
          child: Text(tabDef.tabName),
        )
      ));
    }

    if (widget.characterConfigurationOverride == null) {
      result.add(("Inventar", Container())); // TODO add me
    }
    if (widget.characterConfigurationOverride == null) {
      result.add(("Herstellen", Container())); // TODO add me
    }
    if (widget.characterConfigurationOverride == null) {
      result.add(("Weltgeschichte", Container())); // TODO add me
    }

    return result;
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (widget.startScreenOverride != null) {
        _goToStepId(widget.startScreenOverride!);
      } else {
        // open default screen
        var rpgConfig = ref.read(rpgConfigurationProvider).valueOrNull;
        if (rpgConfig != null &&
            rpgConfig.characterStatTabsDefinition != null) {
          _goToStepId(rpgConfig.characterStatTabsDefinition!
              .indexWhere((tab) => tab.isDefaultTab == true));
        }
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
              // Navigator.of(context)
              //     .pushNamed(allWizardConfigurations.entries.first.key);
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
