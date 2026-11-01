import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/current_fight_provider.dart';
import 'package:quest_keeper/helpers/modals/show_add_further_enemies_to_fight_sequence.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/fight_state.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:themed/themed.dart';

class DmScreenFightSquence extends ConsumerStatefulWidget {
  const DmScreenFightSquence({
    super.key,
  });

  @override
  ConsumerState<DmScreenFightSquence> createState() =>
      _DmScreenFightSquenceState();
}

class _DmScreenFightSquenceState extends ConsumerState<DmScreenFightSquence> {
  List<String> excludedPlayerCharacterIds = [];

  IServerMethodsService get _serverMethods =>
      DependencyProvider.of(context).getService<IServerMethodsService>();

  @override
  Widget build(BuildContext context) {
    var connectionDetails = ref.watch(connectionDetailsProvider).value;
    var currentFight = ref.watch(currentFightProvider);
    var _ = ref.watch(rpgConfigurationProvider).value;

    // With fights kept on the server, players who are away are asked when
    // they come back, so the DM can include them.
    var includeAway = _serverMethods.usesPersistedFights;
    var candidates = connectionDetails == null
        ? <FightCandidate>[]
        : getFightCandidates(connectionDetails, includeAway: includeAway);
    var hasFight = connectionDetails?.fightSequence != null;

    return Container(
      color: characterSheetSurfaceColor(context),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: CustomThemeProvider.of(context)
                                .theme
                                .middleBgColor,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _heading(S.of(context).currentFightOrdering),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: connectionDetails == null
                                ? CustomLoadingSpinner()
                                : (connectionDetails.fightSequence == null
                                    ? Center(
                                        child: _emptyText(
                                            S.of(context).noFIghtStarted),
                                      )
                                    : SingleChildScrollView(
                                        child: Column(children: [
                                          ...connectionDetails
                                              .fightSequence!.sequence
                                              .asMap()
                                              .entries
                                              .map((e) => _orderRow(
                                                    index: e.key,
                                                    name: e.value.$2,
                                                    roll: e.value.$3,
                                                  )),
                                          if (currentFight != null &&
                                              currentFight
                                                  .pending.isNotEmpty) ...[
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: _subHeading(S
                                                  .of(context)
                                                  .waitingForInitiative),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            ...currentFight.pending
                                                .map(_pendingRow),
                                          ],
                                        ]),
                                      )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 00, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _heading(S.of(context).newFightOrdering),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: connectionDetails == null
                                ? CustomLoadingSpinner()
                                : candidates.isEmpty
                                    ? Center(
                                        child: _emptyText(includeAway
                                            ? S
                                                .of(context)
                                                .noCharactersInCampagne
                                            : S.of(context).noPlayersOnline),
                                      )
                                    : SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              alignment:
                                                  WrapAlignment.spaceEvenly,
                                              children: [
                                                // show selection of all characters
                                                ...candidates
                                                    .map(_candidateChip),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Wraps instead of overflowing when the labels get long.
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 10,
              runSpacing: 10,
              children: [
                CustomButton(
                    variant: CustomButtonVariant.AccentButton,
                    label: S.of(context).additionalFightParticipants,
                    onPressed: !hasFight
                        ? null
                        : () async {
                            // show modal and add further enemies
                            await showAddFurtherEnemiesToFightSequence(
                                context: context);
                          }),
                CustomButton(
                    key: const ValueKey('endFightButton'),
                    variant: CustomButtonVariant.AccentButton,
                    label: S.of(context).endFight,
                    onPressed: !hasFight ? null : _endFight),
                CustomButton(
                    key: const ValueKey('rollForInitiativeButton'),
                    variant: CustomButtonVariant.AccentButton,
                    label: S.of(context).rollForInitiative,
                    onPressed: connectionDetails == null
                        ? null
                        : () => _startFight(connectionDetails, candidates)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future _startFight(ConnectionDetails connectionDetails,
      List<FightCandidate> candidates) async {
    var participants = candidates
        .where(
            (c) => !excludedPlayerCharacterIds.contains(c.configuration.uuid))
        .map((c) => FightStartParticipant(
              characterUuid: c.configuration.uuid,
              playerCharacterId: c.player.playerCharacterId.value,
              name: c.configuration.characterName,
            ))
        .toList();

    var response = await _serverMethods.startFight(
      campagneId: connectionDetails.campagneId!,
      participants: participants,
    );
    if (!mounted) return;
    await response.possiblyHandleError(context);
    if (!mounted || !response.isSuccessful) return;

    // show modal and add further enemies
    await showAddFurtherEnemiesToFightSequence(context: context);
  }

  Future _endFight() async {
    var confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CustomThemeProvider.of(context).theme.bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: CustomThemeProvider.of(context).theme.darkColor,
            width: 1,
          ),
        ),
        title: Text(
          S.of(context).endFight,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(
          S.of(context).endFightConfirmation,
          style: TextStyle(
            color: CustomThemeProvider.of(context).theme.darkTextColor,
          ),
        ),
        actions: [
          CustomButton(
            label: S.of(context).cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CustomButton(
            key: const ValueKey('endFightConfirm'),
            variant: CustomButtonVariant.AccentButton,
            label: S.of(context).endFight,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _run(_serverMethods.endFight());
  }

  Future _run(Future<HRResponse<bool>> action) async {
    var response = await action;
    if (!mounted) return;
    // 409: the fight changed meanwhile; the service already reloaded it.
    await response.possiblyHandleError(context, allowedStatusCodes: [409]);
  }

  Widget _heading(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: CustomThemeProvider.of(context).theme.darkTextColor,
          fontSize: 24,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _subHeading(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: CustomThemeProvider.of(context).theme.darkTextColor,
          fontSize: 18,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _emptyText(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: CustomThemeProvider.of(context).theme.darkTextColor,
          fontSize: 16,
          fontWeight: FontWeight.bold),
    );
  }

  Color _tileColor() {
    return CustomThemeProvider.of(context).brightnessNotifier.value ==
            Brightness.light
        ? CustomThemeProvider.of(context).theme.middleBgColor
        : CustomThemeProvider.of(context).theme.bgColor.lighter(0.1);
  }

  Widget _iconButton(FaIconData icon, VoidCallback onPressed, {Key? key}) {
    return CustomButton(
        key: key,
        icon: CustomFaIcon(
            color: CustomThemeProvider.of(context).theme.darkColor, icon: icon),
        onPressed: onPressed);
  }

  Widget _orderRow(
      {required int index, required String name, required int roll}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: _tileColor(),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: CustomThemeProvider.of(context)
                              .theme
                              .darkTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  CustomFaIcon(
                    icon: FontAwesomeIcons.dice,
                    color: CustomThemeProvider.of(context).theme.darkColor,
                    size: 24,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    roll.toString(),
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color:
                            CustomThemeProvider.of(context).theme.darkTextColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          //  move item down in list
          _iconButton(
              FontAwesomeIcons.chevronDown,
              () =>
                  _run(_serverMethods.moveFightEntry(index: index, offset: 1))),
          SizedBox(
            width: 10,
          ),
          //  move item up in list
          _iconButton(
              FontAwesomeIcons.chevronUp,
              () => _run(
                  _serverMethods.moveFightEntry(index: index, offset: -1))),
          SizedBox(
            width: 10,
          ),
          //  delete entry from list
          _iconButton(FontAwesomeIcons.trash,
              () => _run(_serverMethods.removeFightEntry(index: index))),
        ],
      ),
    );
  }

  Widget _pendingRow(FightParticipantState participant) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: _tileColor(), width: 2),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      participant.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: CustomThemeProvider.of(context)
                              .theme
                              .darkTextColor,
                          fontSize: 16),
                    ),
                  ),
                  CustomFaIcon(
                    icon: FontAwesomeIcons.hourglassHalf,
                    color: CustomThemeProvider.of(context).theme.darkColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          // stop waiting for this roll
          _iconButton(
              FontAwesomeIcons.trash,
              () => _run(
                  _serverMethods.removePendingFightParticipant(participant.id)),
              key: ValueKey('removePending_${participant.id}')),
        ],
      ),
    );
  }

  Widget _candidateChip(FightCandidate candidate) {
    var char = candidate.configuration;
    var label = "${S.of(context).character} ${char.characterName}";
    if (!candidate.isAtTheTable) {
      label = "$label (${S.of(context).notAtTheTable})";
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _tileColor(),
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            isSubbutton: true,
            onPressed: () {
              setState(() {
                if (excludedPlayerCharacterIds.contains(char.uuid)) {
                  excludedPlayerCharacterIds.remove(char.uuid);
                } else {
                  excludedPlayerCharacterIds.add(char.uuid);
                }
              });
            },
            icon: Container(
              width: 20,
              height: 20,
              color: !excludedPlayerCharacterIds.contains(char.uuid)
                  ? CustomThemeProvider.of(context).theme.darkColor
                  : Colors.transparent,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 16),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}

/// A character or companion the DM can ask to roll for initiative.
class FightCandidate {
  final RpgCharacterConfigurationBase configuration;
  final OpenPlayerConnection player;

  const FightCandidate({required this.configuration, required this.player});

  /// Whether the player has the character open right now.
  bool get isAtTheTable => player.lastPing != null;
}

/// The characters of the campagne and their companions. Without
/// [includeAway] only those whose players are at the table right now.
List<FightCandidate> getFightCandidates(ConnectionDetails connectionDetails,
    {required bool includeAway}) {
  List<FightCandidate> result = [];

  for (var char in (connectionDetails.connectedPlayers ??
      List<OpenPlayerConnection>.empty())) {
    // Presence: only session-online players (lastPing set).
    if (char.lastPing == null && !includeAway) {
      continue;
    }
    result.add(FightCandidate(configuration: char.configuration, player: char));

    for (var companion in char.configuration.companionCharacters ?? []) {
      result.add(FightCandidate(configuration: companion, player: char));
    }
  }

  return result;
}

List<RpgCharacterConfigurationBase> getAllOnlineCharactersAndCompanions(
    ConnectionDetails connectionDetails) {
  return getFightCandidates(connectionDetails, includeAway: false)
      .map((c) => c.configuration)
      .toList();
}
