import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/newdesign/navbar_new_design.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/pageviews/player_pageview/player_screen_character_stats_for_tab.dart';

class PlayerPageScreenRouteSettings {
  final RpgCharacterConfigurationBase? characterConfigurationOverride;
  final bool? disableEdit;
  final bool showInventory;
  final bool showRecipes;
  final bool showLore;

  PlayerPageScreenRouteSettings(
      {required this.characterConfigurationOverride,
      required this.showInventory,
      required this.showRecipes,
      required this.showLore,
      required this.disableEdit});

  static PlayerPageScreenRouteSettings defaultValue() {
    return PlayerPageScreenRouteSettings(
      disableEdit: false,
      characterConfigurationOverride: null,
      showInventory: true,
      showLore: true,
      showRecipes: true,
    );
  }
}

// TODO refactor this class as it is a direct copy of the dm_page_screen
class PlayerPageScreen extends ConsumerStatefulWidget {
  static const String route = "playerpagescreen";
  final int? startScreenOverride;

  // used by the dm screen to view stats of (offline) players
  final PlayerPageScreenRouteSettings? routeSettings;

  const PlayerPageScreen({
    super.key,
    this.startScreenOverride,
    this.routeSettings,
  });

  @override
  ConsumerState<PlayerPageScreen> createState() => _PlayerPageScreenState();
}

class _PlayerPageScreenState extends ConsumerState<PlayerPageScreen> {
  var pageViewController = PageController(
    initialPage: 0,
  );

  var _currentStep = 0;

  bool showInventory = true;
  bool showLore = true;
  bool showRecipes = true;

  Future _goToStepId(int id) async {
    setState(() {
      _currentStep = id;
    });
    pageViewController.jumpToPage(id);
  }

  List<(String title, Widget child)> getDmScreens(
      BuildContext context, RpgCharacterConfigurationBase? charToRender) {
    var rpgConfig = ref.read(rpgConfigurationProvider).valueOrNull;

    if (rpgConfig == null) return [];

    List<(String title, Widget child)> result = [];

    for (var tabDef in (rpgConfig.characterStatTabsDefinition ??
        List<CharacterStatsTabDefinition>.empty())) {
      result.add((
        tabDef.tabName,
        PlayerScreenCharacterStatsForTab(
            tabDef: tabDef, rpgConfig: rpgConfig, charToRender: charToRender)
      ));
    }

    if (showInventory &&
        charToRender != null &&
        charToRender is RpgCharacterConfiguration) {
      result.add(("Inventar", Container())); // TODO add me
    }
    if (showRecipes &&
        charToRender != null &&
        charToRender is RpgCharacterConfiguration) {
      result.add(("Herstellen", Container())); // TODO add me
    }
    if (showLore) {
      result.add(("Weltgeschichte", Container())); // TODO add me
    }

    return result;
  }

  RpgCharacterConfigurationBase? rpgCharacterToRender;
  bool disableEdit = false;

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

        // check route settings
        final currentRouteSettings = ModalRoute.of(context)!.settings;

        var applicableRouteSettings = currentRouteSettings.arguments == null
            ? (widget.routeSettings ??
                PlayerPageScreenRouteSettings.defaultValue())
            : currentRouteSettings.arguments as PlayerPageScreenRouteSettings;

        rpgCharacterToRender =
            applicableRouteSettings.characterConfigurationOverride;

        showInventory = applicableRouteSettings.showInventory;
        showLore = applicableRouteSettings.showLore;
        showRecipes = applicableRouteSettings.showRecipes;

        disableEdit = applicableRouteSettings.disableEdit ?? false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RpgCharacterConfigurationBase? charToRender;
    if (rpgCharacterToRender != null) {
      charToRender = rpgCharacterToRender;
    } else {
      ref.watch(rpgCharacterConfigurationProvider).whenData((data) {
        charToRender = data;
      });
    }

    var dmScreensToSwipe = getDmScreens(context, charToRender);
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
