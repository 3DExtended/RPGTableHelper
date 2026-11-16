import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/colored_rotated_square.dart';
import 'package:quest_keeper/components/long_press_scale_widget.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/components/page_tab_strip.dart';
import 'package:quest_keeper/components/prevent_swipe_navigation.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/level_up.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/character_stats/has_missing_required_campaign_stats.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/context_extension.dart';
import 'package:quest_keeper/helpers/phone_layout.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/helpers/modals/show_character_sheet_appearance_modal.dart';
import 'package:quest_keeper/helpers/modals/show_tab_icon_configuration.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/lore_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_helpers.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_tabs.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_inventar.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_money.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_stats_for_tab.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_recepies.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

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
  late final PageController pageViewController;

  var _currentStep = 0;

  /// Skin chrome remounts [PageView] (different wrapper trees). Re-sync to
  /// [_currentStep] after each skin id change so navbar and content stay aligned.
  String? _lastSyncedSkinIdForPageView;
  bool _suppressPageChangeFromSkinRemount = false;

  bool showInventory = true;
  bool showMoney = true;
  bool showLore = true;
  bool showRecipes = true;

  Future _goToStepId(int id) async {
    setState(() {
      _currentStep = id;
    });
    if (pageViewController.hasClients) {
      pageViewController.jumpToPage(id);
    }
  }

  List<(String title, Widget child, String uuid)> getPlayerScreens(
      BuildContext context,
      RpgCharacterConfigurationBase? charToRender,
      RpgConfigurationModel rpgConfig) {
    List<(String title, Widget child, String uuid)> result = [];

    for (var tabDef in visibleCharacterStatTabs(rpgConfig)) {
      result.add((
        tabDef.tabName,
        PlayerScreenCharacterStatsForTab(
            onStatValueChanged: (updatedStat) {
              if (charToRender == null) return;
              var newestCharacterConfig =
                  ref.read(rpgCharacterConfigurationProvider).value;
              if (newestCharacterConfig == null) return;

              // Copy before mutate — in-place edits to charToRender.characterStats
              // also mutate provider state and trip the json-equality skip.
              var mergedStats =
                  List<RpgCharacterStatValue>.from(charToRender!.characterStats);

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
                    throw UnimplementedError();
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
            charToRender: charToRender,
            readOnly: disableEdit),
        tabDef.uuid
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
        ),
        "money_tab_uuid"
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
        ),
        "inventory_tab_uuid"
      ));
    }
    if (showRecipes &&
        charToRender != null &&
        charToRender is RpgCharacterConfiguration) {
      result.add((
        S.of(context).navBarHeaderCrafting,
        PlayerScreenRecepies(),
        "recipes_tab_uuid"
      ));
    }

    var campagneId =
        ref.read(connectionDetailsProvider).value?.campagneId;
    if (showLore && campagneId != null) {
      result
          .add((S.of(context).navBarHeaderLore, LoreScreen(), "lore_tab_uuid"));
    }

    return result;
  }

  RpgCharacterConfigurationBase? rpgCharacterToRender;
  bool disableEdit = false;
  bool _routeSettingsApplied = false;

  void _applyRouteSettings(PlayerPageScreenRouteSettings settings) {
    rpgCharacterToRender = settings.characterConfigurationOverride;
    _alreadyCheckedForMissingStats = false;
    showInventory = settings.showInventory;
    showLore = settings.showLore;
    showRecipes = settings.showRecipes;
    showMoney = settings.showMoney;
    disableEdit = settings.disableEdit ?? false;
    _routeSettingsApplied = true;
  }

  @override
  void initState() {
    super.initState();

    // Honor startScreenOverride on the controller itself so the first paint
    // (and golden captures) land on the intended tab without a post-frame jump.
    // Without it, start on the campaign's default tab right away: a jump in a
    // post-frame callback is undone by the skin sync in build, which left
    // players on the first tab with a "<" back to the stats (SP-5).
    final loadedRpgConfig = ref.read(rpgConfigurationProvider).value;
    final initialStep = widget.startScreenOverride ??
        (loadedRpgConfig == null
            ? null
            : defaultVisibleCharacterStatTabIndex(loadedRpgConfig)) ??
        0;
    _currentStep = initialStep;
    pageViewController = PageController(initialPage: initialStep);

    // Constructor-injected settings (preferred) — available before first paint so
    // DM character preview does not flash an empty/wrong chrome layer.
    if (widget.routeSettings != null) {
      _applyRouteSettings(widget.routeSettings!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !context.mounted) return;

      if (!_routeSettingsApplied) {
        final args = ModalRoute.of(context)?.settings.arguments;
        _applyRouteSettings(
          args is PlayerPageScreenRouteSettings
              ? args
              : PlayerPageScreenRouteSettings.defaultValue(),
        );
        setState(() {});
      }

      // Live player sessions without startScreenOverride open the default tab.
      if (widget.startScreenOverride != null) return;
      final rpgConfig = ref.read(rpgConfigurationProvider).value;
      if (rpgConfig == null) return;
      final defaultIdx = defaultVisibleCharacterStatTabIndex(rpgConfig);
      if (defaultIdx != null && defaultIdx != _currentStep) {
        _goToStepId(defaultIdx);
      }
    });
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }

  bool? _alreadyCheckedForMissingStats;

  @override
  Widget build(BuildContext context) {
    var rpgConfig = ref.watch(rpgConfigurationProvider).value;
    var connectionDetails = ref.watch(connectionDetailsProvider).value;
    var tempLoadedRpgCharacter =
        ref.watch(rpgCharacterConfigurationProvider).value;

    RpgCharacterConfigurationBase? charToRender;
    if (rpgCharacterToRender != null) {
      // DM preview: prefer live roster config so characterConfigChanged SSE
      // updates (via connectedPlayers) refresh this open screen.
      final liveFromRoster = connectionDetails?.connectedPlayers
          ?.map((p) => p.configuration)
          .where((c) => c.uuid == rpgCharacterToRender!.uuid)
          .firstOrNull;

      // Own alt form/companion: resolve against the live provider state too,
      // otherwise this stays a frozen snapshot forever and every edit after
      // the first is a silent no-op (recomputes the same target value, which
      // trips the json-equality skip in updateConfiguration).
      RpgCharacterConfigurationBase? liveOwnMatch;
      if (tempLoadedRpgCharacter != null) {
        if (tempLoadedRpgCharacter.uuid == rpgCharacterToRender!.uuid) {
          liveOwnMatch = tempLoadedRpgCharacter;
        } else if (tempLoadedRpgCharacter.alternateForm?.uuid ==
            rpgCharacterToRender!.uuid) {
          liveOwnMatch = tempLoadedRpgCharacter.alternateForm;
        } else {
          liveOwnMatch = tempLoadedRpgCharacter.companionCharacters
              ?.where((c) => c.uuid == rpgCharacterToRender!.uuid)
              .firstOrNull;
        }
      }

      charToRender = liveFromRoster ?? liveOwnMatch ?? rpgCharacterToRender;
    } else {
      charToRender = tempLoadedRpgCharacter;
    }

    if (connectionDetails != null &&
        rpgConfig != null &&
        charToRender != null &&
        (_alreadyCheckedForMissingStats == false)) {
      _alreadyCheckedForMissingStats = true;

      // Only the player configuring their own live character — never the DM
      // previewing via characterConfigurationOverride / disableEdit.
      final shouldPromptMissingStats = connectionDetails.isPlayer &&
          connectionDetails.isInSession &&
          rpgCharacterToRender == null &&
          !disableEdit;

      if (shouldPromptMissingStats) {
        Future.delayed(Duration.zero, () async {
          if (!mounted || !context.mounted) return;

          PlayerPageHelpers.handlePossiblyMissingCharacterStats(
            context: context,
            ref: ref,
            rpgConfig: rpgConfig,
            selectedCharacter: charToRender!,
            openedAutomatically: true,
          );
        });
      }
    }

    // Apply resolved sheet skin (companions/alternates inherit the main sheet).
    // Only while this route is current — avoid fighting a pushed companion/
    // alternate sheet's skin (same double-chrome remount as DM → player).
    final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (rpgConfig != null && routeIsCurrent) {
      final String? ownerSkinId;
      final overrideChar = rpgCharacterToRender;
      if (overrideChar is RpgCharacterConfiguration) {
        ownerSkinId = overrideChar.skinId;
      } else {
        final mainChar =
            ref.watch(rpgCharacterConfigurationProvider).value;
        final localChar = charToRender;
        if (localChar is RpgCharacterConfiguration && mainChar == null) {
          ownerSkinId = localChar.skinId;
        } else {
          ownerSkinId = mainChar?.skinId ?? tempLoadedRpgCharacter?.skinId;
        }
      }
      final resolved = resolveCharacterSheetSkin(
        characterSkinId: ownerSkinId,
        campaignDefaultSkinId: rpgConfig.defaultSkinId,
      );
      final themeProvider = CustomThemeProvider.of(context);
      if (themeProvider.skinIdNotifier.value != resolved.renderSkinId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !context.mounted) return;
          if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
          CustomThemeProvider.of(context)
              .setActiveSkinId(resolved.renderSkinId);
        });
      }
    }

    var playerScreensToSwipe = rpgConfig == null || charToRender == null
        ? List<(String tabName, Widget child, String uuid)>.empty()
        : getPlayerScreens(context, charToRender, rpgConfig);
    var currentTitle = playerScreensToSwipe.isEmpty
        ? ""
        : playerScreensToSwipe[
                _currentStep.clamp(0, playerScreensToSwipe.length - 1)]
            .$1;
    final visibleStatTabCount =
        rpgConfig == null ? 0 : visibleCharacterStatTabs(rpgConfig).length;
    final isPhone = context.isPhone;

    final ledger = isDecoratedSheetSkinActive(context);
    var selectedIconColor = ledger
        ? ledgerNavbarAccent(context)
        : CustomThemeProvider.of(context).theme.accentColor;
    // Mock inactive diamonds are parchment-cream outlines, not accent gold.
    var unselectedIconColor = ledger
        ? const Color(0xffEDE3D4)
        : (CustomThemeProvider.of(context).brightnessNotifier.value ==
                Brightness.light
            ? CustomThemeProvider.of(context).theme.textColor
            : CustomThemeProvider.of(context).theme.darkTextColor);
    var textColor = CustomThemeProvider.of(context).brightnessNotifier.value ==
            Brightness.light
        ? CustomThemeProvider.of(context).theme.textColor
        : CustomThemeProvider.of(context).theme.darkTextColor;

    // Ledger mock: champagne-bronze title (not classic accent terracotta).
    final titleColor = ledger
        ? ledgerNavbarAccent(context)
        : (CustomThemeProvider.of(context).brightnessNotifier.value ==
                Brightness.dark
            ? CustomThemeProvider.of(context).theme.accentColor
            : textColor);

    // Mock: near-black leather bar sits above parchment chrome (not inside it).
    final scaffoldBg = ledger
        ? CustomThemeProvider.of(context).theme.secondaryNavbarColor
        : CustomThemeProvider.of(context).theme.bgColor;

    return PreventSwipeNavigation(
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: ValueListenableBuilder<String>(
          valueListenable: CustomThemeProvider.of(context).skinIdNotifier,
          builder: (context, skinId, _) {
            if (_lastSyncedSkinIdForPageView != skinId) {
              _lastSyncedSkinIdForPageView = skinId;
              final stepToKeep = _currentStep;
              _suppressPageChangeFromSkinRemount = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (pageViewController.hasClients &&
                    pageViewController.page?.round() != stepToKeep) {
                  pageViewController.jumpToPage(stepToKeep);
                }
                if (_currentStep != stepToKeep) {
                  setState(() {
                    _currentStep = stepToKeep;
                    _suppressPageChangeFromSkinRemount = false;
                  });
                } else {
                  _suppressPageChangeFromSkinRemount = false;
                }
              });
            }
            return Column(
              children: [
                Navbar(
                  hideWhileKeyboardVisible: true,
                  // Always "X" (SP-5): it used to be a "<" that jumped to the
                  // default tab and only turned into "X" there. The pages
                  // are reached through the diamonds / tabs instead.
                  backInsteadOfCloseIcon: false,
                  useTopSafePadding: true,
                  closeFunction: () {
                    // Player leaving their own live session: mark out of session.
                    // Do NOT clear isDm when the DM is only previewing another
                    // character via characterConfigurationOverride — that would
                    // make the next open look like a player session and crash on
                    // AsyncLoading character provider.
                    final details =
                        ref.read(connectionDetailsProvider).requireValue;
                    final isPreviewOnly = rpgCharacterToRender != null ||
                        details.isDm ||
                        disableEdit;
                    if (!isPreviewOnly) {
                      ref
                          .read(connectionDetailsProvider.notifier)
                          .updateConfiguration(details.copyWith(
                            isInSession: false,
                            isDm: false,
                          ));
                    }

                    navigatorKey.currentState!.pop();
                  },
                  bottom: !isPhone
                      ? null
                      : PageTabStrip(
                          items: [
                            for (final screen in playerScreensToSwipe)
                              PageTabStripItem(
                                label: screen.$1,
                                iconBuilder: _configuredTabIconBuilder(
                                    tempLoadedRpgCharacter, screen.$3),
                              ),
                          ],
                          currentIndex: _currentStep,
                          onSelected: (index) => _goToStepId(index),
                          onLongPress: connectionDetails == null ||
                                  connectionDetails.isDm ||
                                  rpgConfig == null ||
                                  tempLoadedRpgCharacter == null
                              ? null
                              : (_) => openTabIconConfigurationDialog(context,
                                  rpgConfig, tempLoadedRpgCharacter),
                          // The notes come last; keep them in sight (B8).
                          pinLastItem: playerScreensToSwipe.isNotEmpty &&
                              playerScreensToSwipe.last.$3 == "lore_tab_uuid",
                        ),
                  titleWidget: isPhone
                      ? Text(
                          currentTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: titleColor,
                                fontSize: ledger ? 24 : 20,
                                fontFamily: ledger ? 'Ruwudu' : null,
                                fontWeight: FontWeight.w400,
                                letterSpacing: ledger ? 0.4 : null,
                                height: 1.0,
                              ),
                        )
                      : Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        ...List.generate(
                          _currentStep + 1,
                          (index) => LongPressScaleWidget(
                            onLongPress: () {
                              // if dm, return early
                              if (connectionDetails == null ||
                                  connectionDetails.isDm ||
                                  rpgConfig == null ||
                                  tempLoadedRpgCharacter == null) {
                                return;
                              }

                              openTabIconConfigurationDialog(
                                  context, rpgConfig, tempLoadedRpgCharacter);
                            },
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                await _goToStepId(index);
                              },
                              minimumSize: Size(0, 0),
                              child: Builder(builder: (context) {
                                // if tempLoadedRpgCharacter has tab icon configuration, use it
                                var tabIcon2 = tempLoadedRpgCharacter
                                    ?.tabConfigurations
                                    ?.firstWhereOrNull((e) =>
                                        e.tabUuid ==
                                        playerScreensToSwipe[index].$3)
                                    ?.tabIcon;

                                return tabIcon2 != null && tabIcon2 != "square"
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: getIconForIdentifier(
                                          name: tempLoadedRpgCharacter!
                                              .tabConfigurations!
                                              .firstWhereOrNull((e) =>
                                                  e.tabUuid ==
                                                  playerScreensToSwipe[index]
                                                      .$3)!
                                              .tabIcon,
                                          color: index == _currentStep
                                              ? selectedIconColor
                                              : unselectedIconColor,
                                          size: 24,
                                        ).$2,
                                      )
                                    : ColoredRotatedSquare(
                                        isSolidSquare: index == _currentStep,
                                        color: index == _currentStep
                                            ? selectedIconColor
                                            : unselectedIconColor);
                              }),
                            ),
                          ),
                        ),
                        if (context.isTablet)
                          Padding(
                            padding: EdgeInsets.only(
                              left: ledger ? 10.0 : 4.0,
                              right: ledger ? 14.0 : 20.0,
                            ),
                            child: Text(
                              currentTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color: titleColor,
                                    fontSize: ledger ? 26 : 24,
                                    fontFamily: ledger ? 'Ruwudu' : null,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: ledger ? 0.4 : null,
                                    height: 1.0,
                                  ),
                            ),
                          ),
                        ...List.generate(
                          playerScreensToSwipe.isEmpty
                              ? 0
                              : playerScreensToSwipe.length -
                                  (_currentStep + 1),
                          (index) => LongPressScaleWidget(
                            onLongPress: () {
                              // if dm, return early
                              if (connectionDetails == null ||
                                  connectionDetails.isDm ||
                                  rpgConfig == null ||
                                  tempLoadedRpgCharacter == null) {
                                return;
                              }

                              openTabIconConfigurationDialog(
                                  context, rpgConfig, tempLoadedRpgCharacter);
                            },
                            child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _goToStepId(index + _currentStep + 1);
                                },
                                minimumSize: Size(0, 0),
                                child: Builder(builder: (context) {
                                  var tabIcon2 = tempLoadedRpgCharacter
                                      ?.tabConfigurations
                                      ?.firstWhereOrNull((e) =>
                                          e.tabUuid ==
                                          playerScreensToSwipe[
                                                  index + _currentStep + 1]
                                              .$3)
                                      ?.tabIcon;
                                  return // if tempLoadedRpgCharacter has tab icon configuration, use it
                                      tabIcon2 != null && tabIcon2 != "square"
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: getIconForIdentifier(
                                                name: tempLoadedRpgCharacter!
                                                    .tabConfigurations!
                                                    .firstWhereOrNull((e) =>
                                                        e.tabUuid ==
                                                        playerScreensToSwipe[
                                                                index +
                                                                    _currentStep +
                                                                    1]
                                                            .$3)!
                                                    .tabIcon,
                                                color: unselectedIconColor,
                                                size: 24,
                                              ).$2,
                                            )
                                          : ColoredRotatedSquare(
                                              isSolidSquare: false,
                                              color: unselectedIconColor,
                                            );
                                })),
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                  menuOpen: connectionDetails == null ||
                          connectionDetails.isDm ||
                          disableEdit ||
                          visibleStatTabCount <= _currentStep ||
                          rpgConfig == null ||
                          charToRender == null
                      ? null
                      : () {
                          // Flow analysis promotes these in the ternary arm, but the
                          // async closure still needs non-null locals.
                          // ignore: unnecessary_non_null_assertion
                          final menuRpgConfig = rpgConfig!;
                          // ignore: unnecessary_non_null_assertion
                          final menuChar = charToRender!;
                          Future.delayed(Duration.zero, () async {
                            if (!mounted || !context.mounted) return;
                            await _openPlayerSheetMenu(
                              context: context,
                              rpgConfig: menuRpgConfig,
                              charToRender: menuChar,
                            );
                          });
                        },
                ),
                Expanded(
                  child: CharacterSheetSkinChrome(
                    child: Padding(
                      padding: characterSheetContentInsets(context),
                      child: Container(
                        color: characterSheetSurfaceColor(context),
                        child: PageView(
                          controller: pageViewController,
                          onPageChanged: (value) {
                            if (_suppressPageChangeFromSkinRemount) return;
                            setState(() {
                              _currentStep = value;
                            });
                          },
                          scrollDirection: Axis.horizontal,
                          children:
                              playerScreensToSwipe.map((e) => e.$2).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openPlayerSheetMenu({
    required BuildContext context,
    required RpgConfigurationModel rpgConfig,
    required RpgCharacterConfigurationBase charToRender,
  }) async {
    final theme = CustomThemeProvider.of(context).theme;
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: SkinnedModalPanel(
            child: ConstrainedBox(
              constraints: skinnedModalContentConstraints(
                ctx,
                maxWidth: 420,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(ctx).configureProperties,
                      textAlign: TextAlign.center,
                      style: Theme.of(ctx).textTheme.titleLarge!.copyWith(
                            color: theme.darkTextColor,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(
                        S.of(ctx).characterSheetAppearanceTitle,
                        style: TextStyle(color: theme.darkTextColor),
                      ),
                      onTap: () => Navigator.of(ctx).pop('appearance'),
                    ),
                    ListTile(
                      title: Text(
                        S.of(ctx).configureProperties,
                        style: TextStyle(color: theme.darkTextColor),
                      ),
                      onTap: () => Navigator.of(ctx).pop('stats'),
                    ),
                    if (levelStatOf(rpgConfig) != null &&
                        PlayerPageHelpers.isOwnCharacter(ref, charToRender))
                      ListTile(
                        key: const ValueKey('sheetMenuLevelUp'),
                        title: Text(
                          S.of(ctx).levelUpMenuEntry,
                          style: TextStyle(color: theme.darkTextColor),
                        ),
                        onTap: () => Navigator.of(ctx).pop('levelUp'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || !context.mounted || choice == null) return;

    if (choice == 'stats') {
      PlayerPageHelpers.handlePossiblyMissingCharacterStats(
        ref: ref,
        context: context,
        filterTabId: visibleCharacterStatTabs(rpgConfig)[_currentStep].uuid,
        rpgConfig: rpgConfig,
        selectedCharacter: charToRender,
      );
      return;
    }

    if (choice == 'levelUp') {
      await PlayerPageHelpers.startLevelUp(
        ref: ref,
        context: context,
        rpgConfig: rpgConfig,
        selectedCharacter: charToRender,
      );
      return;
    }

    if (choice == 'appearance') {
      // Appearance is only for the player's own main character config.
      final mainCharacter =
          ref.read(rpgCharacterConfigurationProvider).value;
      if (mainCharacter == null || rpgCharacterToRender != null) return;

      final immediate = hasMissingRequiredCampaignStats(
        rpgConfig: rpgConfig,
        character: mainCharacter,
      );
      final result = await showCharacterSheetAppearanceModal(
        context: context,
        currentSkinId: mainCharacter.skinId,
        campaignDefaultSkinId: rpgConfig.defaultSkinId,
        immediateApply: immediate,
      );
      if (!mounted || !context.mounted) return;
      if (result is! AppearanceModalSelection) return;

      final newSkinId = result.skinId;
      ref.read(rpgCharacterConfigurationProvider.notifier).updateConfiguration(
            mainCharacter.copyWith(skinId: newSkinId),
          );
      final resolved = resolveCharacterSheetSkin(
        characterSkinId: newSkinId,
        campaignDefaultSkinId: rpgConfig.defaultSkinId,
      );
      CustomThemeProvider.of(context).setActiveSkinId(resolved.renderSkinId);
    }
  }

  /// The tab icon the player chose for the page [tabUuid], if any.
  Widget Function(Color color)? _configuredTabIconBuilder(
      RpgCharacterConfiguration? character, String tabUuid) {
    final tabIcon = character?.tabConfigurations
        ?.firstWhereOrNull((e) => e.tabUuid == tabUuid)
        ?.tabIcon;
    if (tabIcon == null || tabIcon == "square") return null;
    return (color) =>
        getIconForIdentifier(name: tabIcon, color: color, size: 16).$2;
  }

  void openTabIconConfigurationDialog(BuildContext context,
      RpgConfigurationModel rpgConfig, RpgCharacterConfiguration charToRender) {
    Future.delayed(Duration.zero, () async {
      if (!mounted || !context.mounted) return;

      var tabIconConfiguration = await showTabIconConfiguration(
        context: context,
        rpgConfig: rpgConfig,
        rpgCharacterToRender: charToRender,
      );

      if (tabIconConfiguration == null) return;

      ref
          .read(rpgCharacterConfigurationProvider.notifier)
          .updateConfiguration(charToRender.copyWith(
            tabConfigurations: tabIconConfiguration,
          ));
    });
  }
}
