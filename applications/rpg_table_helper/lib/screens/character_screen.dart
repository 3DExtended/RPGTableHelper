import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.enums.swagger.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/iterable_extension.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/character_screen_player_content.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/rpg_entity_service.dart';

class CharacterScreen extends ConsumerStatefulWidget {
  static String route = "character";

  const CharacterScreen({super.key});

  @override
  ConsumerState<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends ConsumerState<CharacterScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      // check once if there are open join requests for this campagne if you are the dm
      if (ref.read(connectionDetailsProvider).valueOrNull?.isDm != true) {
        return;
      }

      var campagneId =
          ref.read(connectionDetailsProvider).valueOrNull?.campagneId;
      if (campagneId == null) {
        return;
      }

      var service =
          DependencyProvider.of(context).getService<IRpgEntityService>();
      var loadJoinRequestsResponse =
          await service.getOpenJoinRequestsForCampagne(
              campagneId: CampagneIdentifier($value: campagneId));

      await loadJoinRequestsResponse.possiblyHandleError(context);

      if (loadJoinRequestsResponse.isSuccessful) {
        var currentlyLoadedOpenRequests = ref
                .read(connectionDetailsProvider)
                .requireValue
                .openPlayerRequests ??
            [];

        currentlyLoadedOpenRequests.addAll(loadJoinRequestsResponse.result!.map(
          (e) => PlayerJoinRequests(
              campagneJoinRequestId: e.request.id!.$value!,
              playerCharacterId: e.playerCharacter.id!.$value!,
              playerName: e.playerCharacter.characterName!,
              username: e.username),
        ));

        currentlyLoadedOpenRequests = currentlyLoadedOpenRequests
            .distinct(by: (e) => e.campagneJoinRequestId)
            .toList();

        ref.read(connectionDetailsProvider.notifier).updateConfiguration(ref
            .read(connectionDetailsProvider)
            .requireValue
            .copyWith(openPlayerRequests: currentlyLoadedOpenRequests));
      }
    });
    super.initState();
  }

  var characterPlayerContentKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    var connectionDetails = ref.watch(connectionDetailsProvider).valueOrNull;
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;

    return connectionDetails?.isDm == true
        ? Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CharacterScreen for DMs",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomMarkdownBody(
                    text:
                        "Deine Session ID (für deine Player): __${connectionDetails!.sessionConnectionNumberForPlayers ?? ""}__"),
                const SizedBox(
                  height: 20,
                ),
                if ((connectionDetails.openPlayerRequests?.length ?? 0) != 0)
                  CustomMarkdownBody(
                      text:
                          "Offene Spieler Anfragen (${connectionDetails.openPlayerRequests?.length ?? 0}):"),
                const SizedBox(
                  height: 20,
                ),
                if ((connectionDetails.openPlayerRequests?.length ?? 0) != 0)
                  OpenPlayerJoinRequests(connectionDetails: connectionDetails),
                if ((connectionDetails.openPlayerRequests?.length ?? 0) != 0)
                  const SizedBox(
                    height: 20,
                  ),
                const HorizontalLine(),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      runSpacing: 10,
                      spacing: 10,
                      children: [
                        ...(connectionDetails.connectedPlayers ?? []).map(
                          (player) => Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(156, 255, 255, 255),
                              ),
                              color: whiteBgTint,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    player.configuration.characterName.trim(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.white,
                                          fontSize: 24,
                                        ),
                                  ),
                                  Text(
                                    "Anzahl Items: ${player.configuration.inventory.map((it) => it.amount).sum}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                  ),
                                  if (rpgConfig != null)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 20, 0, 20),
                                      child: HorizontalLine(),
                                    ),
                                  if (rpgConfig != null)
                                    // render all number stats of the default screen of all players
                                    Builder(builder: (context) {
                                      var defaultTab = rpgConfig
                                          .characterStatTabsDefinition
                                          ?.firstWhereOrNull(
                                              (tab) => tab.isDefaultTab);
                                      if (defaultTab == null)
                                        return Container();

                                      var numberStatsInDefaultTab = defaultTab
                                          .statsInTab
                                          .where((stat) =>
                                              stat.valueType ==
                                                  CharacterStatValueType.int ||
                                              stat.valueType ==
                                                  CharacterStatValueType
                                                      .intWithCalculatedValue ||
                                              stat.valueType ==
                                                  CharacterStatValueType
                                                      .intWithMaxValue)
                                          .toList();

                                      var statsWithPlayerStats =
                                          numberStatsInDefaultTab
                                              .map((stat) {
                                                var playerStat = player
                                                    .configuration
                                                    .characterStats
                                                    .firstWhereOrNull(
                                                        (charStat) =>
                                                            charStat.statUuid ==
                                                            stat.statUuid);

                                                return (stat, playerStat);
                                              })
                                              .where(
                                                  (tuple) => tuple.$2 != null)
                                              .toList();
                                      CharacterStatValueType? lastType;
                                      return Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 50,
                                        runSpacing: 10,
                                        children: statsWithPlayerStats
                                            .map((stuple) {
                                              var breakItems = false;

                                              if (lastType != null &&
                                                  !areTwoValueTypesSimilar(
                                                      stuple.$1.valueType,
                                                      lastType)) {
                                                breakItems = true;
                                              }

                                              lastType = stuple.$1.valueType;

                                              return [
                                                if (breakItems)
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Container())
                                                    ],
                                                  ),
                                                getPlayerVisualizationWidget(
                                                    context: context,
                                                    statConfiguration:
                                                        stuple.$1,
                                                    characterValue: stuple.$2!)
                                              ];
                                            })
                                            .expand((i) => i)
                                            .toList(),
                                      );
                                    })
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        : CharacterScreenPlayerContent(
            key: characterPlayerContentKey,
          );
  }
}

class OpenPlayerJoinRequests extends ConsumerStatefulWidget {
  const OpenPlayerJoinRequests({
    super.key,
    required this.connectionDetails,
  });

  final ConnectionDetails connectionDetails;

  @override
  ConsumerState<OpenPlayerJoinRequests> createState() =>
      _OpenPlayerJoinRequestsState();
}

class _OpenPlayerJoinRequestsState
    extends ConsumerState<OpenPlayerJoinRequests> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: [
        ...widget.connectionDetails.openPlayerRequests!
            .asMap()
            .entries
            .map((request) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StyledBox(
                        child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Spielername: ${request.value.playerName}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 15,
                            ),
                            CupertinoButton(
                                minSize: 0,
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  "Annehmen",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: const Color.fromARGB(
                                            255, 79, 255, 103),
                                      ),
                                ),
                                onPressed: () async {
                                  var com = DependencyProvider.of(context)
                                      .getService<IRpgEntityService>();

                                  var response = await com.handleJoinRequest(
                                      campagneJoinRequestId:
                                          request.value.campagneJoinRequestId,
                                      typeOfHandle:
                                          HandleJoinRequestType.accept);

                                  await response.possiblyHandleError(context);

                                  // remove this particular request from open requests
                                  deleteJoinRequestAt(request, ref);
                                }),
                            CupertinoButton(
                                minSize: 0,
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Text(
                                  "Ablehnen",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: const Color.fromARGB(
                                            255, 255, 79, 79),
                                      ),
                                ),
                                onPressed: () async {
                                  var com = DependencyProvider.of(context)
                                      .getService<IRpgEntityService>();

                                  var response = await com.handleJoinRequest(
                                      campagneJoinRequestId:
                                          request.value.campagneJoinRequestId,
                                      typeOfHandle: HandleJoinRequestType.deny);
                                  await response.possiblyHandleError(context);
                                  // remove this particular request from open requests
                                  deleteJoinRequestAt(request, ref);
                                }),
                            const SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    )),
                  ],
                )),
      ],
    );
  }

  void deleteJoinRequestAt(
      MapEntry<int, PlayerJoinRequests> request, WidgetRef ref) {
    var newRequests = [...widget.connectionDetails.openPlayerRequests!];
    newRequests.removeAt(request.key);
    ref
        .read(connectionDetailsProvider.notifier)
        .updateConfiguration(widget.connectionDetails.copyWith(
          openPlayerRequests: newRequests,
        ));
  }
}
