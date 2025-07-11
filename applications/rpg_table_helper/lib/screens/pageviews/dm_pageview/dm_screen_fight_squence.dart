import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/modals/show_add_further_enemies_to_fight_sequence.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:themed/themed.dart';
import 'package:uuid/v7.dart';

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

  @override
  Widget build(BuildContext context) {
    var connectionDetails = ref.watch(connectionDetailsProvider).valueOrNull;
    var _ = ref.watch(rpgConfigurationProvider).valueOrNull;

    return Container(
      color: CustomThemeProvider.of(context).theme.bgColor,
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
                          Text(
                            S.of(context).currentFightOrdering,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    color: CustomThemeProvider.of(context)
                                        .theme
                                        .darkTextColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: connectionDetails == null
                                ? CustomLoadingSpinner()
                                : (connectionDetails.fightSequence == null
                                    ? Center(
                                        child: Text(
                                          S.of(context).noFIghtStarted,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                  color: CustomThemeProvider.of(
                                                          context)
                                                      .theme
                                                      .darkTextColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: Column(children: [
                                          ...connectionDetails
                                              .fightSequence!.sequence
                                              .asMap()
                                              .entries
                                              .map((e) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: CustomThemeProvider.of(
                                                                              context)
                                                                          .brightnessNotifier
                                                                          .value ==
                                                                      Brightness
                                                                          .light
                                                                  ? CustomThemeProvider.of(
                                                                          context)
                                                                      .theme
                                                                      .middleBgColor
                                                                  : CustomThemeProvider.of(
                                                                          context)
                                                                      .theme
                                                                      .bgColor
                                                                      .lighter(
                                                                          0.1),
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  e.value.$2,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .labelMedium!
                                                                      .copyWith(
                                                                          color: CustomThemeProvider.of(context)
                                                                              .theme
                                                                              .darkTextColor,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                ),
                                                                Spacer(),
                                                                CustomFaIcon(
                                                                  icon:
                                                                      FontAwesomeIcons
                                                                          .dice,
                                                                  color: CustomThemeProvider.of(
                                                                          context)
                                                                      .theme
                                                                      .darkColor,
                                                                  size: 24,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  e.value.$3
                                                                      .toString(),
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .labelMedium!
                                                                      .copyWith(
                                                                          color: CustomThemeProvider.of(context)
                                                                              .theme
                                                                              .darkTextColor,
                                                                          fontSize:
                                                                              24,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        CustomButton(
                                                            icon: CustomFaIcon(
                                                                color: CustomThemeProvider.of(
                                                                        context)
                                                                    .theme
                                                                    .darkColor,
                                                                icon: FontAwesomeIcons
                                                                    .chevronDown),
                                                            onPressed: () {
                                                              //  move item down in list
                                                              var indexOfItem =
                                                                  e.key;
                                                              if (indexOfItem >=
                                                                  connectionDetails
                                                                          .fightSequence!
                                                                          .sequence
                                                                          .length -
                                                                      1) {
                                                                return;
                                                              }

                                                              var temp = connectionDetails
                                                                      .fightSequence!
                                                                      .sequence[
                                                                  indexOfItem];
                                                              connectionDetails
                                                                      .fightSequence!
                                                                      .sequence[
                                                                  indexOfItem] = connectionDetails
                                                                      .fightSequence!
                                                                      .sequence[
                                                                  indexOfItem +
                                                                      1];
                                                              connectionDetails
                                                                      .fightSequence!
                                                                      .sequence[
                                                                  indexOfItem +
                                                                      1] = temp;

                                                              ref
                                                                  .read(connectionDetailsProvider
                                                                      .notifier)
                                                                  .updateConfiguration(
                                                                      connectionDetails);
                                                            }),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        CustomButton(
                                                            icon: CustomFaIcon(
                                                                color: CustomThemeProvider.of(
                                                                        context)
                                                                    .theme
                                                                    .darkColor,
                                                                icon: FontAwesomeIcons
                                                                    .chevronUp),
                                                            onPressed: () {
                                                              //  move item up in list
                                                              var indexOfItem =
                                                                  e.key;
                                                              if (indexOfItem ==
                                                                  0) {
                                                                return;
                                                              }

                                                              var temp = connectionDetails
                                                                      .fightSequence!
                                                                      .sequence[
                                                                  indexOfItem];
                                                              connectionDetails
                                                                      .fightSequence!
                                                                      .sequence[
                                                                  indexOfItem] = connectionDetails
                                                                      .fightSequence!
                                                                      .sequence[
                                                                  indexOfItem -
                                                                      1];
                                                              connectionDetails
                                                                      .fightSequence!
                                                                      .sequence[
                                                                  indexOfItem -
                                                                      1] = temp;

                                                              ref
                                                                  .read(connectionDetailsProvider
                                                                      .notifier)
                                                                  .updateConfiguration(
                                                                      connectionDetails);
                                                            }),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        CustomButton(
                                                            icon: CustomFaIcon(
                                                                color: CustomThemeProvider.of(
                                                                        context)
                                                                    .theme
                                                                    .darkColor,
                                                                icon:
                                                                    FontAwesomeIcons
                                                                        .trash),
                                                            onPressed: () {
                                                              //  delete entry from list
                                                              var indexOfItem =
                                                                  e.key;

                                                              connectionDetails
                                                                  .fightSequence!
                                                                  .sequence
                                                                  .removeAt(
                                                                      indexOfItem);

                                                              ref
                                                                  .read(connectionDetailsProvider
                                                                      .notifier)
                                                                  .updateConfiguration(
                                                                      connectionDetails);
                                                            }),
                                                      ],
                                                    ),
                                                  )),
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
                          Text(
                            S.of(context).newFightOrdering,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    color: CustomThemeProvider.of(context)
                                        .theme
                                        .darkTextColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: connectionDetails == null
                                ? CustomLoadingSpinner()
                                : getAllOnlineCharactersAndCompanions(
                                            connectionDetails)
                                        .isEmpty
                                    ? Center(
                                        child: Text(
                                          S.of(context).noPlayersOnline,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                  color: CustomThemeProvider.of(
                                                          context)
                                                      .theme
                                                      .darkTextColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                        ),
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
                                                ...getAllOnlineCharactersAndCompanions(
                                                        connectionDetails)
                                                    .map((char) => Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: CustomThemeProvider.of(
                                                                            context)
                                                                        .brightnessNotifier
                                                                        .value ==
                                                                    Brightness
                                                                        .light
                                                                ? CustomThemeProvider.of(
                                                                        context)
                                                                    .theme
                                                                    .middleBgColor
                                                                : CustomThemeProvider.of(
                                                                        context)
                                                                    .theme
                                                                    .bgColor
                                                                    .lighter(
                                                                        0.1),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              CustomButton(
                                                                isSubbutton:
                                                                    true,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    if (excludedPlayerCharacterIds
                                                                        .contains(
                                                                            char.uuid)) {
                                                                      excludedPlayerCharacterIds
                                                                          .remove(
                                                                              char.uuid);
                                                                    } else {
                                                                      excludedPlayerCharacterIds
                                                                          .add(char
                                                                              .uuid);
                                                                    }
                                                                  });
                                                                },
                                                                icon: Container(
                                                                  width: 20,
                                                                  height: 20,
                                                                  color: !excludedPlayerCharacterIds
                                                                          .contains(char
                                                                              .uuid)
                                                                      ? CustomThemeProvider.of(
                                                                              context)
                                                                          .theme
                                                                          .darkColor
                                                                      : Colors
                                                                          .transparent,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                "${S.of(context).character} ${char.characterName}",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .labelMedium!
                                                                    .copyWith(
                                                                        color: CustomThemeProvider.of(context)
                                                                            .theme
                                                                            .darkTextColor,
                                                                        fontSize:
                                                                            16),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                            ],
                                                          ),
                                                        )),
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Center(
                        child: CustomButton(
                            variant: CustomButtonVariant.AccentButton,
                            label: S.of(context).additionalFightParticipants,
                            onPressed: connectionDetails == null ||
                                    connectionDetails.fightSequence == null
                                ? null
                                : () async {
                                    // show modal and add further enemies
                                    await showAddFurtherEnemiesToFightSequence(
                                        context: context);
                                  }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Center(
                        child: CustomButton(
                            variant: CustomButtonVariant.AccentButton,
                            label: S.of(context).rollForInitiative,
                            onPressed: connectionDetails == null
                                ? null
                                : () async {
                                    var sequenceToAskPlayers =
                                        getAllOnlineCharactersAndCompanions(
                                                connectionDetails)
                                            .where((char) =>
                                                !excludedPlayerCharacterIds
                                                    .contains(char.uuid))
                                            .map((char) => (
                                                  char.uuid,
                                                  char.characterName,
                                                  -1
                                                ))
                                            .toList();

                                    var newFightingSequence = FightSequence(
                                      fightUuid: UuidV7().generate(),
                                      sequence: [],
                                    );

                                    // start fighting sequence
                                    ref
                                        .read(
                                            connectionDetailsProvider.notifier)
                                        .updateConfiguration(ref
                                            .read(connectionDetailsProvider)
                                            .requireValue
                                            .copyWith(
                                                fightSequence:
                                                    newFightingSequence));

                                    // send requests to players
                                    var service = DependencyProvider.of(context)
                                        .getService<IServerMethodsService>();

                                    await service.askPlayersForRolls(
                                        campagneId:
                                            connectionDetails.campagneId!,
                                        fightSequence:
                                            newFightingSequence.copyWith(
                                                sequence:
                                                    sequenceToAskPlayers));
                                    if (!context.mounted || !mounted) return;

                                    // show modal and add further enemies
                                    await showAddFurtherEnemiesToFightSequence(
                                        context: context);
                                  }),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

List<RpgCharacterConfigurationBase> getAllOnlineCharactersAndCompanions(
    ConnectionDetails connectionDetails) {
  List<RpgCharacterConfigurationBase> result = [];

  for (var char in (connectionDetails.connectedPlayers ??
      List<OpenPlayerConnection>.empty())) {
    result.add(char.configuration);

    result.addAll(char.configuration.companionCharacters ?? []);
  }

  return result;
}
