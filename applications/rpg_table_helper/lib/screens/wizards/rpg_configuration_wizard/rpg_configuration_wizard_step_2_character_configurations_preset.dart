import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/components/wizards/wizard_step_save_registry.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/modals/show_confirm_delete_dialog.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/wizards/player_sheet_preview_screen.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/character_stat_group_editing.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:uuid/v7.dart';

/// How many of the campaign's characters (or their companions) hold a value
/// for [statUuid]. Uses the roster the DM screen already loaded.
int countCharactersWithValuesForStat(
  List<OpenPlayerConnection>? players,
  String statUuid,
) {
  bool hasValue(RpgCharacterConfigurationBase character) =>
      character.characterStats.any(
          (s) => s.statUuid == statUuid && s.serializedValue.isNotEmpty);

  return (players ?? const <OpenPlayerConnection>[])
      .where((p) =>
          hasValue(p.configuration) ||
          (p.configuration.companionCharacters ?? const [])
              .any((companion) => hasValue(companion)))
      .length;
}

const wizardDeleteTabButtonKeyPrefix = 'wizardDeleteTab-';
const wizardDeleteStatButtonKeyPrefix = 'wizardDeleteStat-';
const wizardDeleteGroupButtonKeyPrefix = 'wizardDeleteGroup-';

class RpgConfigurationWizardStep2CharacterConfigurationsPreset
    extends WizardStepBase {
  const RpgConfigurationWizardStep2CharacterConfigurationsPreset({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
    required super.setWizardTitle,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep2CharacterConfigurationsPreset>
      createState() =>
          _RpgConfigurationWizardStep2CharacterConfigurationsPresetState();
}

class StatOrGroupIndicator {
  final CharacterStatDefinition? stat;
  final String? groupHandleId;

  StatOrGroupIndicator({required this.stat, required this.groupHandleId});
}

class _RpgConfigurationWizardStep2CharacterConfigurationsPresetState
    extends ConsumerState<
        RpgConfigurationWizardStep2CharacterConfigurationsPreset> {
  bool hasDataLoaded = false;
  List<
      (
        String uuid,
        TextEditingController tabName,
        bool isOptional,
        bool isDefaultTab,
      )> tabsToEdit = [];

  Map<String, List<StatOrGroupIndicator>> statsUnderTab = {};

  bool isFormValid = true;
  RpgConfigurationNotifier? _configNotifier;

  /// Every stat being edited, all tabs in order: sources for computed stats.
  List<StatWithTab> _statsWithTabs() => [
        for (var tab in tabsToEdit)
          for (var entry in statsUnderTab[tab.$1] ?? <StatOrGroupIndicator>[])
            if (entry.stat != null)
              (tabName: tab.$2.text, stat: entry.stat!),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.setWizardTitle(S.of(context).wizardCharacterSheetStepTitle);
    });
  }

  static bool _isGroupDivider(StatOrGroupIndicator entry) =>
      entry.groupHandleId != null;

  String _displayNameOfStat(CharacterStatDefinition stat) {
    final name = stat.name.trim();
    return name.isEmpty ? S.of(context).wizardUnnamedProperty : name;
  }

  String _displayNameOfTab(TextEditingController tabName) {
    final name = tabName.text.trim();
    return name.isEmpty ? S.of(context).wizardUnnamedTab : name;
  }

  /// Asks with the tab's name and number of properties, then removes it.
  Future<void> _confirmAndDeleteTab(String tabUuid) async {
    final tab = tabsToEdit.firstWhere((t) => t.$1 == tabUuid);
    final statCount = countStats(
      statsUnderTab[tabUuid] ?? const <StatOrGroupIndicator>[],
      isGroupDivider: _isGroupDivider,
    );
    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: S.of(context).wizardDeleteTabTitle,
      message: S
          .of(context)
          .wizardDeleteTabMessage(statCount, _displayNameOfTab(tab.$2)),
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      final index = tabsToEdit.indexWhere((t) => t.$1 == tabUuid);
      if (index < 0) {
        return;
      }
      final removed = tabsToEdit.removeAt(index);
      statsUnderTab.remove(tabUuid);
      // Keep a start tab when the deleted one was it.
      if (removed.$4 && tabsToEdit.isNotEmpty) {
        final first = tabsToEdit.first;
        tabsToEdit[0] = (first.$1, first.$2, first.$3, true);
      }
    });
  }

  /// Deletes a property. Asks first when characters already hold values for
  /// it; otherwise deletes right away and offers to undo.
  Future<void> _deleteStat(String tabUuid, CharacterStatDefinition stat) async {
    final statName = _displayNameOfStat(stat);
    final charactersWithValues = countCharactersWithValuesForStat(
      ref.read(connectionDetailsProvider).value?.connectedPlayers,
      stat.statUuid,
    );

    if (charactersWithValues > 0) {
      final confirmed = await showConfirmDeleteDialog(
        context: context,
        title: S.of(context).wizardDeletePropertyTitle,
        message: S
            .of(context)
            .wizardDeletePropertyMessage(charactersWithValues, statName),
      );
      if (!confirmed || !mounted) {
        return;
      }
      _removeStatEntry(tabUuid, stat);
      return;
    }

    final before = [...statsUnderTab[tabUuid] ?? <StatOrGroupIndicator>[]];
    final indexBefore = before.indexWhere((e) => identical(e.stat, stat));
    final removed = _removeStatEntry(tabUuid, stat);
    if (removed == null) {
      return;
    }
    // The editor mutates the tab's list in place (reorder, add), so compare
    // against a copy.
    final after = [...removed];

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(
      content: Text(S.of(context).wizardPropertyDeletedSnackbar(statName)),
      action: SnackBarAction(
        label: S.of(context).wizardUndo,
        onPressed: () {
          if (!mounted) return;
          final current = statsUnderTab[tabUuid];
          if (current == null) return;
          setState(() {
            final unchanged = current.length == after.length &&
                Iterable.generate(current.length)
                    .every((i) => identical(current[i], after[i]));
            if (unchanged) {
              statsUnderTab[tabUuid] = before;
            } else {
              current.insert(indexBefore.clamp(0, current.length),
                  StatOrGroupIndicator(stat: stat, groupHandleId: null));
            }
          });
        },
      ),
    ));
  }

  /// Removes [stat] and a group divider left empty by it. Returns the new
  /// list of the tab, or null when the stat was not found.
  List<StatOrGroupIndicator>? _removeStatEntry(
      String tabUuid, CharacterStatDefinition stat) {
    final entries = statsUnderTab[tabUuid];
    if (entries == null) return null;
    final index = entries.indexWhere((e) => identical(e.stat, stat));
    if (index < 0) return null;

    final updated = removeStatAndEmptyGroup(entries, index,
        isGroupDivider: _isGroupDivider);
    setState(() {
      statsUnderTab[tabUuid] = updated;
    });
    return updated;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configNotifier = ref.read(rpgConfigurationProvider.notifier);
    registerWizardStepSave(_persistToProviderIfReady);
  }

  void _populateEditorsFromConfig(RpgConfigurationModel data) {
    var loadedTabs = data.characterStatTabsDefinition ??
        RpgConfigurationModel.getBaseConfiguration()
            .characterStatTabsDefinition!;

    for (var tab in loadedTabs) {
      tabsToEdit.add((
        tab.uuid,
        TextEditingController(text: tab.tabName),
        tab.isOptional,
        tab.isDefaultTab
      ));

      var lastGroupIndicator = tab.statsInTab.firstOrNull?.groupId;

      for (var stat in tab.statsInTab) {
        if (stat.groupId != lastGroupIndicator) {
          statsUnderTab.putIfAbsent(tab.uuid, () => []).add(
              StatOrGroupIndicator(
                  stat: null, groupHandleId: UuidV7().generate()));
          lastGroupIndicator = stat.groupId;
        }

        statsUnderTab
            .putIfAbsent(tab.uuid, () => [])
            .add(StatOrGroupIndicator(stat: stat, groupHandleId: null));
      }
    }
  }

  void _persistToProviderIfReady() {
    if (!hasDataLoaded) {
      return;
    }
    saveChanges();
  }

  @override
  void dispose() {
    unregisterWizardStepSave(_persistToProviderIfReady);
    for (final tab in tabsToEdit) {
      tab.$2.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || hasDataLoaded) {
            return;
          }
          setState(() {
            if (hasDataLoaded) {
              return;
            }
            hasDataLoaded = true;
            _populateEditorsFromConfig(data);
          });
        });
      }
    });

    if (!hasDataLoaded) {
      return const SizedBox.shrink();
    }

    var stepHelperText = S.of(context).rpgConfigurationDmWizardStep2Tutorial;

    return TwoPartWizardStepBody(
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepHelperText: stepHelperText,
      onNextBtnPressed: !isFormValid
          ? null
          : () {
              _persistToProviderIfReady();
              widget.onNextBtnPressed();
            },
      onPreviousBtnPressed: () {
        _persistToProviderIfReady();
        widget.onPreviousBtnPressed();
      },
      sideBarFlex: 1,
      contentFlex: 2,
      contentChildren: [
        // Phase 3: the sheet as a player sees it, before anyone has joined.
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            key: const ValueKey('openPlayerSheetPreview'),
            isSubbutton: true,
            variant: CustomButtonVariant.FlatButton,
            icon: CustomFaIcon(
                size: 16,
                color: CustomThemeProvider.of(context).theme.darkColor,
                icon: FontAwesomeIcons.eye),
            label: S.of(context).playerPreviewButton,
            onPressed: () {
              _persistToProviderIfReady();
              final config = ref.read(rpgConfigurationProvider).value;
              if (config == null) return;
              PlayerSheetPreviewScreen.open(config);
            },
          ),
        ),
        const SizedBox(height: 10),
        ...tabsToEdit.asMap().entries.map((tab) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Tab title textfield
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      labelText: S.of(context).wizardTabNameLabel,
                      textEditingController: tab.value.$2,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 50,
                    width: 40,
                    clipBehavior: Clip.none,
                    child: CustomButton(
                      key: ValueKey(
                          '$wizardDeleteTabButtonKeyPrefix${tab.value.$1}'),
                      isSubbutton: true,
                      variant: CustomButtonVariant.FlatButton,
                      onPressed: () {
                        _confirmAndDeleteTab(tab.value.$1);
                      },
                      icon: CustomFaIcon(
                          size: 16,
                          color:
                              CustomThemeProvider.of(context).theme.darkColor,
                          icon: FontAwesomeIcons.trashCan),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).defaultTab,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      CustomButton(
                        isSubbutton: true,
                        onPressed: () {
                          setState(() {
                            var newTabsToEdit = [...tabsToEdit];
                            for (var i = 0; i < newTabsToEdit.length; i++) {
                              newTabsToEdit[i] = (
                                newTabsToEdit[i].$1,
                                newTabsToEdit[i].$2,
                                newTabsToEdit[i].$3,
                                i == tab.key
                              );
                            }
                            tabsToEdit = newTabsToEdit;
                          });
                        },
                        icon: Container(
                          width: 20,
                          height: 20,
                          color: tab.value.$4
                              ? (isNightCartographerActive(context)
                                  ? CustomThemeProvider.of(context)
                                      .theme
                                      .accentColor
                                  : CustomThemeProvider.of(context)
                                      .theme
                                      .darkColor)
                              : Colors.transparent,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),

              // stats beneath
              Builder(
                builder: (context) {
                  final groupNumbers = groupNumbersForDividers(
                    statsUnderTab[tab.value.$1] ??
                        const <StatOrGroupIndicator>[],
                    isGroupDivider: _isGroupDivider,
                  );
                  return ReorderableListView(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        var item =
                            statsUnderTab[tab.value.$1]!.removeAt(oldIndex);
                        statsUnderTab[tab.value.$1]!.insert(newIndex, item);
                      });
                    },
                    proxyDecorator:
                        (Widget child, int index, Animation<double> animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (BuildContext context, Widget? child) {
                          final double animValue =
                              Curves.easeInOut.transform(animation.value);
                          final double elevation = lerpDouble(0, 6, animValue)!;
                          return Material(
                            elevation: elevation,
                            color: Colors.transparent,
                            shadowColor: Colors.black.withOpacity(0.3),
                            child: child,
                          );
                        },
                        child: child,
                      );
                    },
                    children: (statsUnderTab[tab.value.$1] ?? [])
                        .asMap()
                        .entries
                        .map(
                          (e) => e.value.groupHandleId != null
                              ? Padding(
                                  key: ValueKey(e.value),
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Row(
                                    children: [
                                      CustomFaIcon(
                                        icon: FontAwesomeIcons.gripVertical,
                                        color: Color.lerp(
                                            CustomThemeProvider.of(context)
                                                .theme
                                                .middleBgColor,
                                            CustomThemeProvider.of(context)
                                                .theme
                                                .darkColor,
                                            0.5),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 12, 0, 12),
                                          child: Column(
                                            children: [
                                              HorizontalLine(
                                                useDarkColor: true,
                                              ),
                                              Center(
                                                child: Text(
                                                  S.of(context).wizardGroupLabel(
                                                      groupNumbers[e.key] ?? 1),
                                                  style: TextStyle(
                                                    color:
                                                        CustomThemeProvider.of(
                                                                context)
                                                            .theme
                                                            .darkTextColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Lines up with the stats' delete
                                      // buttons (edit button width + gap).
                                      SizedBox(width: 50),
                                      Container(
                                        height: 50,
                                        width: 40,
                                        clipBehavior: Clip.none,
                                        child: CustomButton(
                                          key: ValueKey(
                                              '$wizardDeleteGroupButtonKeyPrefix${e.value.groupHandleId}'),
                                          isSubbutton: true,
                                          variant:
                                              CustomButtonVariant.FlatButton,
                                          onPressed: () {
                                            // Only the divider goes; its
                                            // properties join the group above.
                                            setState(() {
                                              statsUnderTab[tab.value.$1]!
                                                  .removeWhere((entry) =>
                                                      identical(
                                                          entry, e.value));
                                            });
                                          },
                                          icon: CustomFaIcon(
                                              size: 16,
                                              color: CustomThemeProvider.of(
                                                      context)
                                                  .theme
                                                  .darkColor,
                                              icon: FontAwesomeIcons.trashCan),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  color: characterSheetSurfaceColor(context),
                                  key: ValueKey(e.value),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CustomFaIcon(
                                        icon: FontAwesomeIcons.gripVertical,
                                        color: Color.lerp(
                                            CustomThemeProvider.of(context)
                                                .theme
                                                .middleBgColor,
                                            CustomThemeProvider.of(context)
                                                .theme
                                                .darkColor,
                                            0.5),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 5, 0, 5),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: CustomThemeProvider.of(
                                                          context)
                                                      .theme
                                                      .darkColor,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: CustomMarkdownBody(
                                                      text:
                                                          "### ${_displayNameOfStat(e.value.stat!)} (${e.value.stat!.valueType.toCustomString(context)}${StatNumbers.isComputed(e.value.stat!) ? ", ${S.of(context).computedValueBadge}" : ""})",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      // Edit Button
                                      Container(
                                        height: 50,
                                        width: 40,
                                        clipBehavior: Clip.none,
                                        child: CustomButton(
                                          variant:
                                              CustomButtonVariant.FlatButton,
                                          isSubbutton: true,
                                          onPressed: () async {
                                            await showGetDmConfigurationModal(
                                                    context: context,
                                                    availableStats:
                                                        _statsWithTabs(),
                                                    predefinedConfiguration:
                                                        e.value.stat)
                                                .then((value) {
                                              if (value == null) {
                                                return;
                                              }
                                              setState(() {
                                                statsUnderTab[tab.value.$1]![
                                                        e.key] =
                                                    StatOrGroupIndicator(
                                                        stat: value,
                                                        groupHandleId: null);
                                              });
                                            });
                                          },
                                          icon: CustomFaIcon(
                                              size: 16,
                                              color: CustomThemeProvider.of(
                                                      context)
                                                  .theme
                                                  .darkColor,
                                              icon:
                                                  FontAwesomeIcons.penToSquare),
                                        ),
                                      ),
                                      Container(
                                        height: 50,
                                        width: 40,
                                        clipBehavior: Clip.none,
                                        child: CustomButton(
                                          key: ValueKey(
                                              '$wizardDeleteStatButtonKeyPrefix${e.value.stat!.statUuid}'),
                                          isSubbutton: true,
                                          variant:
                                              CustomButtonVariant.FlatButton,
                                          onPressed: () {
                                            _deleteStat(
                                                tab.value.$1, e.value.stat!);
                                          },
                                          icon: CustomFaIcon(
                                              size: 16,
                                              color: CustomThemeProvider.of(
                                                      context)
                                                  .theme
                                                  .darkColor,
                                              icon: FontAwesomeIcons.trashCan),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        )
                        .toList(),
                  );
                },
              ),

              // add new stat beneath
              Padding(
                padding: const EdgeInsets.fromLTRB(34, 20, 0, 20),
                child: Row(
                  children: [
                    CustomButton(
                      isSubbutton: true,
                      onPressed: () async {
                        setState(() {
                          statsUnderTab.putIfAbsent(tab.value.$1, () => []).add(
                              StatOrGroupIndicator(
                                  groupHandleId: UuidV7().generate(),
                                  stat: null));
                        });
                      },
                      label: S.of(context).newGroupBtnLabel,
                      icon: Theme(
                          data: ThemeData(
                            fontFamily: "Ruwudu",
                            iconTheme: IconThemeData(
                              color: CustomThemeProvider.of(context)
                                  .theme
                                  .darkTextColor,
                              size: 16,
                            ),
                            textTheme: TextTheme(
                              bodyMedium: TextStyle(
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Container(
                                width: 16,
                                height: 16,
                                alignment: AlignmentDirectional.center,
                                child: const FaIcon(FontAwesomeIcons.plus)),
                          )),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    CustomButton(
                      isSubbutton: true,
                      onPressed: () async {
                        // open new modal for dm config
                        // if it returns non null add the stat
                        await showGetDmConfigurationModal(
                                context: context,
                                availableStats: _statsWithTabs())
                            .then((value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            statsUnderTab
                                .putIfAbsent(tab.value.$1, () => [])
                                .add(StatOrGroupIndicator(
                                  stat: value,
                                  groupHandleId: null,
                                ));
                          });
                        });
                      },
                      label: S.of(context).newPropertyBtnLabel,
                      icon: Theme(
                          data: ThemeData(
                            fontFamily: "Ruwudu",
                            iconTheme: IconThemeData(
                              color: CustomThemeProvider.of(context)
                                  .theme
                                  .darkTextColor,
                              size: 16,
                            ),
                            textTheme: TextTheme(
                              bodyMedium: TextStyle(
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Container(
                                width: 16,
                                height: 16,
                                alignment: AlignmentDirectional.center,
                                child: const FaIcon(FontAwesomeIcons.plus)),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),

        // add new tab button
        CustomButton(
          variant: CustomButtonVariant.Default,
          onPressed: () {
            addNewTab();
          },
          label: S.of(context).newTabBtnLabel,
          icon: Theme(
              data: ThemeData(
                fontFamily: "Ruwudu",
                iconTheme: IconThemeData(
                  color: CustomThemeProvider.of(context).theme.darkColor,
                  size: 16,
                ),
                textTheme: TextTheme(
                  bodyMedium: TextStyle(
                    color: CustomThemeProvider.of(context).theme.darkColor,
                  ),
                ),
              ),
              child: Container(
                  width: 24,
                  height: 24,
                  alignment: AlignmentDirectional.center,
                  child: const FaIcon(FontAwesomeIcons.plus))),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void addNewTab() {
    setState(() {
      var newId = UuidV7().generate();

      tabsToEdit.add((
        newId,
        TextEditingController(),
        false, // isOptional
        tabsToEdit.isEmpty, // isDefaultTab
      ));

      statsUnderTab[newId] = [];
    });
  }

  List<CharacterStatsTabDefinition> _buildConstructedTabs() {
    return tabsToEdit.map((tuple) {
      List<CharacterStatDefinition> correctyGroupedStats = [];

      int groupCountInTab = 0;

      for (var groupStat
          in (statsUnderTab[tuple.$1] ?? List<StatOrGroupIndicator>.empty())) {
        if (groupStat.groupHandleId != null) {
          groupCountInTab++;
        } else {
          correctyGroupedStats
              .add(groupStat.stat!.copyWith(groupId: groupCountInTab));
        }
      }

      return CharacterStatsTabDefinition(
        isOptional: tuple.$3,
        isDefaultTab: tuple.$4,
        tabName: tuple.$2.text,
        uuid: tuple.$1,
        statsInTab: correctyGroupedStats,
      );
    }).toList();
  }

  void saveChanges() {
    final RpgConfigurationNotifier notifier =
        _configNotifier ?? ref.read(rpgConfigurationProvider.notifier);
    notifier.updateCharacterScreenStatsTabs(_buildConstructedTabs());
  }
}

extension on CharacterStatValueType {
  toCustomString(BuildContext context) {
    switch (this) {
      case CharacterStatValueType.int:
        return S.of(context).integerValue;
      case CharacterStatValueType.transformIntoAlternateFormBtn:
        return S.of(context).transformIntoAlternateForm;
      case CharacterStatValueType.listOfIntsWithIcons:
        return S.of(context).listOfIntegersWithIcons;
      case CharacterStatValueType.intWithMaxValue:
        return S.of(context).integerValueWithMaxValue;
      case CharacterStatValueType.characterNameWithLevelAndAdditionalDetails:
        return S.of(context).characterNameWithLevelAndConfigurableDetails;
      case CharacterStatValueType.listOfIntWithCalculatedValues:
        return S.of(context).listOfInterValuesWithCalculatedIntegerValues;

      case CharacterStatValueType.intWithCalculatedValue:
        return S.of(context).integerValueWithCalculatedValue;
      case CharacterStatValueType.multiLineText:
        return S.of(context).multilineText;
      case CharacterStatValueType.singleImage:
        return S.of(context).generatedImage;
      case CharacterStatValueType.singleLineText:
        return S.of(context).singleLineText;
      case CharacterStatValueType.multiselect:
        return S.of(context).multiselectOption;
      case CharacterStatValueType.companionSelector:
        return S.of(context).companionOverview;
      case CharacterStatValueType.checkboxTrack:
        return S.of(context).statTypeCheckboxTrack;
      case CharacterStatValueType.textList:
        return S.of(context).statTypeTextList;
      case CharacterStatValueType.singleSelect:
        return S.of(context).statTypeSingleSelect;
      case CharacterStatValueType.unsupported:
        return S.of(context).statTypeUnsupported;
    }
  }
}
