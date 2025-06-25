import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/colored_rotated_square.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/components/prevent_swipe_navigation.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/context_extension.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/lore_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_helpers.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_inventar.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_money.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_stats_for_tab.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_recepies.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:signalr_netcore/errors.dart';

class PlayerPageScreenRouteSettings {
  final RpgCharacterConfigurationBase? characterConfigurationOverride;
  final bool? disableEdit;
  final bool showInventory;
  final bool showRecipes;
  final bool showMoney;
  final bool showLore;

  PlayerPageScreenRouteSettings(
      {required this.characterConfigurationOverride,
      required this.showInventory,
      required this.showMoney,
      required this.showRecipes,
      required this.showLore,
      required this.disableEdit});

  static PlayerPageScreenRouteSettings defaultValue() {
    return PlayerPageScreenRouteSettings(
      disableEdit: false,
      characterConfigurationOverride: null,
      showInventory: true,
      showMoney: true,
      showRecipes: true,
      showLore: true,
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
  bool showMoney = true;
  bool showLore = true;
  bool showRecipes = true;

  Future _goToStepId(int id) async {
    setState(() {
      _currentStep = id;
    });
    pageViewController.jumpToPage(id);
  }

  List<(String title, Widget child)> getPlayerScreens(
      BuildContext context,
      RpgCharacterConfigurationBase? charToRender,
      RpgConfigurationModel rpgConfig) {
    List<(String title, Widget child)> result = [];

    for (var tabDef in (rpgConfig.characterStatTabsDefinition ??
        List<CharacterStatsTabDefinition>.empty())) {
      result.add((
        tabDef.tabName,
        PlayerScreenCharacterStatsForTab(
            onStatValueChanged: (updatedStat) {
              if (charToRender == null) return;
              var newestCharacterConfig =
                  ref.read(rpgCharacterConfigurationProvider).valueOrNull;
              if (newestCharacterConfig == null) return;

              var mergedStats = charToRender!.characterStats;

              mergedStats
                  .removeWhere((st) => st.statUuid == updatedStat.statUuid);
              mergedStats.add(updatedStat);

              var isUpdatingMainCharacter =
                  newestCharacterConfig.uuid == charToRender!.uuid;

              if (isUpdatingMainCharacter) {
                charToRender =
                    newestCharacterConfig.copyWith(characterStats: mergedStats);

                ref
                    .read(rpgCharacterConfigurationProvider.notifier)
                    .updateConfiguration(newestCharacterConfig.copyWith(
                        characterStats: mergedStats));
              } else {
                List<RpgAlternateCharacterConfiguration>
                    companionCharactersCopy = [
                  ...(newestCharacterConfig.companionCharacters ?? [])
                ];

                var indexOfSelectedCompChar = companionCharactersCopy
                    .indexWhere((e) => e.uuid == charToRender!.uuid);

                if (indexOfSelectedCompChar == -1) {
                  if (newestCharacterConfig.alternateForm == null) {
                    throw NotImplementedException();
                  }

                  // check altforms
                  charToRender = newestCharacterConfig.copyWith(
                      alternateForm: newestCharacterConfig.alternateForm!
                          .copyWith(characterStats: mergedStats));

                  ref
                      .read(rpgCharacterConfigurationProvider.notifier)
                      .updateConfiguration(newestCharacterConfig.copyWith(
                          alternateForm: newestCharacterConfig.alternateForm!
                              .copyWith(characterStats: mergedStats)));
                } else {
                  companionCharactersCopy[indexOfSelectedCompChar] =
                      companionCharactersCopy[indexOfSelectedCompChar]
                          .copyWith(characterStats: mergedStats);

                  charToRender = newestCharacterConfig.copyWith(
                      companionCharacters: companionCharactersCopy);

                  ref
                      .read(rpgCharacterConfigurationProvider.notifier)
                      .updateConfiguration(newestCharacterConfig.copyWith(
                          companionCharacters: companionCharactersCopy));
                }
              }
              setState(() {});
            },
            tabDef: tabDef,
            rpgConfig: rpgConfig,
            charToRender: charToRender)
      ));
    }

    if (showMoney &&
        charToRender != null &&
        charToRender is RpgCharacterConfiguration) {
      result.add((
        S.of(context).navBarHeaderMoney,
        PlayerScreenCharacterMoney(
          rpgConfig: rpgConfig,
          charToRender: charToRender as RpgCharacterConfiguration,
        )
      ));
    }
    if (showInventory &&
        charToRender != null &&
        charToRender is RpgCharacterConfiguration) {
      result.add((
        S.of(context).navBarHeaderInventory,
        PlayerScreenCharacterInventory(
          rpgConfig: rpgConfig,
          charToRender: charToRender,
        )
      ));
    }
    if (showRecipes &&
        charToRender != null &&
        charToRender is RpgCharacterConfiguration) {
      result.add((S.of(context).navBarHeaderCrafting, PlayerScreenRecepies()));
    }

    var campagneId =
        ref.read(connectionDetailsProvider).valueOrNull?.campagneId;
    if (showLore && campagneId != null) {
      result.add((S.of(context).navBarHeaderLore, LoreScreen()));
    }

    return result;
  }

  RpgCharacterConfigurationBase? rpgCharacterToRender;
  bool disableEdit = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      // open default screen
      var rpgConfig = ref.read(rpgConfigurationProvider).requireValue;

      if (widget.startScreenOverride != null) {
        _goToStepId(widget.startScreenOverride!);
      } else {
        if (rpgConfig.characterStatTabsDefinition != null) {
          _goToStepId(rpgConfig.characterStatTabsDefinition!
              .indexWhere((tab) => tab.isDefaultTab == true));
        }
      }

      // check route settings
      if (!mounted || !context.mounted) return;

      final currentRouteSettings = ModalRoute.of(context)!.settings;

      var applicableRouteSettings = currentRouteSettings.arguments == null
          ? (widget.routeSettings ??
              PlayerPageScreenRouteSettings.defaultValue())
          : currentRouteSettings.arguments as PlayerPageScreenRouteSettings;

      rpgCharacterToRender =
          applicableRouteSettings.characterConfigurationOverride;
      _alreadyCheckedForMissingStats = false;

      showInventory = applicableRouteSettings.showInventory;
      showLore = applicableRouteSettings.showLore;
      showRecipes = applicableRouteSettings.showRecipes;
      showMoney = applicableRouteSettings.showMoney;

      disableEdit = applicableRouteSettings.disableEdit ?? false;
    });
    super.initState();
  }

  bool? _alreadyCheckedForMissingStats;

  @override
  Widget build(BuildContext context) {
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;
    var connectionDetails = ref.watch(connectionDetailsProvider).valueOrNull;
    var tempLoadedRpgCharacter =
        ref.watch(rpgCharacterConfigurationProvider).valueOrNull;

    RpgCharacterConfigurationBase? charToRender;
    if (rpgCharacterToRender != null) {
      charToRender = rpgCharacterToRender;
    } else {
      charToRender = tempLoadedRpgCharacter;
    }

    if (connectionDetails != null &&
        rpgConfig != null &&
        charToRender != null &&
        (_alreadyCheckedForMissingStats == false)) {
      _alreadyCheckedForMissingStats = true;

      if (connectionDetails.isPlayer) {
        Future.delayed(Duration.zero, () async {
          if (!mounted || !context.mounted) return;

          PlayerPageHelpers.handlePossiblyMissingCharacterStats(
            context: context,
            ref: ref,
            rpgConfig: rpgConfig,
            selectedCharacter: charToRender!,
          );
        });
      }
    }

    var playerScreensToSwipe = rpgConfig == null || charToRender == null
        ? List<(String, Widget)>.empty()
        : getPlayerScreens(context, charToRender, rpgConfig);
    var currentTitle = playerScreensToSwipe.isEmpty
        ? ""
        : playerScreensToSwipe[_currentStep].$1;

    return PreventSwipeNavigation(
      child: Scaffold(
        backgroundColor: CustomThemeProvider.of(context).theme.bgColor,
        body: Column(
          children: [
            Navbar(
              backInsteadOfCloseIcon: rpgConfig?.characterStatTabsDefinition!
                      .indexWhere((tab) => tab.isDefaultTab == true) !=
                  _currentStep,
              useTopSafePadding: true,
              closeFunction: () {
                if (rpgConfig?.characterStatTabsDefinition!
                        .indexWhere((tab) => tab.isDefaultTab == true) !=
                    _currentStep) {
                  setState(() {
                    _goToStepId(rpgConfig!.characterStatTabsDefinition!
                        .indexWhere((tab) => tab.isDefaultTab == true));
                  });
                } else {
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
                }
              },
              titleWidget: Row(
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
                      child: ColoredRotatedSquare(
                          isSolidSquare: index == _currentStep,
                          color: index == _currentStep
                              ? CustomThemeProvider.of(context)
                                  .theme
                                  .accentColor
                              : CustomThemeProvider.of(context)
                                  .theme
                                  .middleBgColor),
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
                              color: CustomThemeProvider.of(context)
                                  .theme
                                  .textColor,
                              fontSize: 24,
                            ),
                      ),
                    ),
                  ...List.generate(
                    playerScreensToSwipe.isEmpty
                        ? 0
                        : playerScreensToSwipe.length - (_currentStep + 1),
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
                              color: CustomThemeProvider.of(context)
                                  .theme
                                  .middleBgColor),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
              menuOpen: connectionDetails == null ||
                      connectionDetails.isDm ||
                      (rpgConfig?.characterStatTabsDefinition ??
                                  List<CharacterStatsTabDefinition>.empty())
                              .length <=
                          _currentStep ||
                      rpgConfig == null ||
                      charToRender == null
                  ? null
                  : () {
                      Future.delayed(Duration.zero, () async {
                        if (!mounted || !context.mounted) return;

                        PlayerPageHelpers.handlePossiblyMissingCharacterStats(
                            ref: ref,
                            context: context,
                            filterTabId: rpgConfig
                                .characterStatTabsDefinition![_currentStep]
                                .uuid,
                            rpgConfig: rpgConfig,
                            selectedCharacter: charToRender!);
                      });
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
                  children: playerScreensToSwipe.map((e) => e.$2).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
