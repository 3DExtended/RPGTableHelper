import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/modals/show_add_further_enemies_to_fight_sequence.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/server_methods_service.dart';
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
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;

    return Container(
      color: bgColor,
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
                            color: middleBgColor,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Aktuelle Kampfreihenfolge",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    color: darkTextColor,
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
                                          "Aktuell kein Kampf gestartet",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                  color: darkTextColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: Column(children: [
                                          ...connectionDetails
                                              .fightSequence!.sequence
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
                                                              color:
                                                                  middleBgColor,
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  e.$2,
                                                                  style: Theme
                                                                          .of(
                                                                              context)
                                                                      .textTheme
                                                                      .labelMedium!
                                                                      .copyWith(
                                                                          color:
                                                                              darkTextColor,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                ),
                                                                Spacer(),
                                                                Text(
                                                                  e.$3.toString(),
                                                                  style: Theme
                                                                          .of(
                                                                              context)
                                                                      .textTheme
                                                                      .labelMedium!
                                                                      .copyWith(
                                                                          color:
                                                                              darkTextColor,
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
                                                        CustomButtonNewdesign(
                                                            icon: CustomFaIcon(
                                                                color:
                                                                    darkColor,
                                                                icon: FontAwesomeIcons
                                                                    .chevronDown),
                                                            onPressed: () {
                                                              // TODO move item down in list
                                                            }),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        CustomButtonNewdesign(
                                                            icon: CustomFaIcon(
                                                                color:
                                                                    darkColor,
                                                                icon: FontAwesomeIcons
                                                                    .chevronUp),
                                                            onPressed: () {
                                                              // TODO move item down in list
                                                            }),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        CustomButtonNewdesign(
                                                            icon: CustomFaIcon(
                                                                color:
                                                                    darkColor,
                                                                icon:
                                                                    FontAwesomeIcons
                                                                        .trash),
                                                            onPressed: () {
                                                              // TODO delete entry from list
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
                            "Neue Kampfreihenfolge",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    color: darkTextColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: connectionDetails == null
                                ? CustomLoadingSpinner()
                                : SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        getAllOnlineCharactersAndCompanions(
                                                    connectionDetails)
                                                .isEmpty
                                            ? Center(
                                                child: Text(
                                                  "Aktuell keine Player Online",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .copyWith(
                                                          color: darkTextColor,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                              )
                                            : Wrap(
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
                                                              color:
                                                                  middleBgColor,
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                CustomButtonNewdesign(
                                                                  isSubbutton:
                                                                      true,
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      if (excludedPlayerCharacterIds
                                                                          .contains(
                                                                              char.uuid)) {
                                                                        excludedPlayerCharacterIds
                                                                            .remove(char.uuid);
                                                                      } else {
                                                                        excludedPlayerCharacterIds
                                                                            .add(char.uuid);
                                                                      }
                                                                    });
                                                                  },
                                                                  icon:
                                                                      Container(
                                                                    width: 20,
                                                                    height: 20,
                                                                    color: !excludedPlayerCharacterIds.contains(char
                                                                            .uuid)
                                                                        ? darkColor
                                                                        : Colors
                                                                            .transparent,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Charakter: ${char.characterName}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .labelMedium!
                                                                      .copyWith(
                                                                          color:
                                                                              darkTextColor,
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
                        child: CustomButtonNewdesign(
                            variant: CustomButtonNewdesignVariant.AccentButton,
                            label: "Weitere Teilnehmer",
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
                        child: CustomButtonNewdesign(
                            variant: CustomButtonNewdesignVariant.AccentButton,
                            label: "Kampfreihenfolge würfeln",
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
