import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/bordered_image.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/l10n.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.enums.swagger.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/rpg_entity_service.dart';

class DmScreenCampagneManagement extends ConsumerStatefulWidget {
  const DmScreenCampagneManagement({
    super.key,
  });

  @override
  ConsumerState<DmScreenCampagneManagement> createState() =>
      _DmScreenCampagneManagementState();
}

class _DmScreenCampagneManagementState
    extends ConsumerState<DmScreenCampagneManagement> {
  List<PlayerCharacter>? fromServerLoadedPlayers;

  bool isLoadingFromServer = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      var service =
          DependencyProvider.of(context).getService<IRpgEntityService>();

      var connectionDetails = ref.read(connectionDetailsProvider).requireValue;

      var loadedCharsResponse = await service.getPlayerCharactersForCampagne(
          campagneId:
              CampagneIdentifier($value: connectionDetails.campagneId!));

      if (!context.mounted) return;
      await loadedCharsResponse.possiblyHandleError(context);
      if (!context.mounted) return;

      setState(() {
        if (loadedCharsResponse.isSuccessful) {
          fromServerLoadedPlayers = loadedCharsResponse.result;
        }
        isLoadingFromServer = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var connectionDetails = ref.watch(connectionDetailsProvider).valueOrNull;
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Alle Spieler:",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: darkTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              if (isLoadingFromServer) CustomLoadingSpinner(),

              // Wrap with player images (black and white for offline) and label for each image
              if (!isLoadingFromServer)
                Wrap(spacing: 20, runSpacing: 20, children: [
                  ...getAllPlayersOfflineStatusWidgets(
                      connectionDetails, rpgConfig),
                ]),
              SizedBox(
                height: 10,
              ),
              HorizontalLine(),
              SizedBox(
                height: 10,
              ),

              Text(
                "Join Anfragen:",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: darkTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),

              if (connectionDetails?.sessionConnectionNumberForPlayers != null)
                Text(
                  "Join Code (für neue Spieler): ${connectionDetails!.sessionConnectionNumberForPlayers!}",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: darkTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),

              SizedBox(
                height: 20,
              ),

              if ((connectionDetails?.openPlayerRequests ?? []).isEmpty)
                Text(
                  "Keine offenen Anfragen",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 16, color: darkTextColor),
                ),

              if ((connectionDetails?.openPlayerRequests ?? []).isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...(connectionDetails?.openPlayerRequests ?? [])
                        .asMap()
                        .entries
                        .map(
                          (request) => SizedBox(
                            width: 350,
                            child: Container(
                              decoration: BoxDecoration(
                                color: middleBgColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "User: ${request.value.username}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                fontSize: 20,
                                                color: darkColor,
                                              ),
                                        ),
                                        Text(
                                          "Charakter: ${request.value.playerName}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                fontSize: 16,
                                                color: darkColor,
                                              ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: CupertinoButton(
                                        minSize: 0,
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: lightGreen,
                                            borderRadius:
                                                BorderRadius.circular(3.0),
                                            border: Border.all(
                                              color: darkColor,
                                            ),
                                          ),
                                          child: CustomFaIcon(
                                            icon: FontAwesomeIcons.check,
                                            color: darkColor,
                                            size: 24,
                                          ),
                                        ),
                                        onPressed: () async {
                                          var com = DependencyProvider.of(
                                                  context)
                                              .getService<IRpgEntityService>();

                                          var response =
                                              await com.handleJoinRequest(
                                                  campagneJoinRequestId: request
                                                      .value
                                                      .campagneJoinRequestId,
                                                  typeOfHandle:
                                                      HandleJoinRequestType
                                                          .accept);

                                          await response
                                              .possiblyHandleError(context);

                                          // remove this particular request from open requests
                                          deleteJoinRequestAt(
                                              request.value, ref);
                                        }),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: CupertinoButton(
                                        minSize: 0,
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: lightRed,
                                            borderRadius:
                                                BorderRadius.circular(3.0),
                                            border: Border.all(
                                              color: darkColor,
                                            ),
                                          ),
                                          child: CustomFaIcon(
                                            icon: FontAwesomeIcons.xmark,
                                            color: textColor,
                                            size: 24,
                                          ),
                                        ),
                                        onPressed: () async {
                                          var com = DependencyProvider.of(
                                                  context)
                                              .getService<IRpgEntityService>();

                                          var response =
                                              await com.handleJoinRequest(
                                                  campagneJoinRequestId: request
                                                      .value
                                                      .campagneJoinRequestId,
                                                  typeOfHandle:
                                                      HandleJoinRequestType
                                                          .deny);
                                          await response
                                              .possiblyHandleError(context);
                                          // remove this particular request from open requests
                                          deleteJoinRequestAt(
                                              request.value, ref);
                                        }),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  void deleteJoinRequestAt(PlayerJoinRequests request, WidgetRef ref) {
    var newestConnectionDetails =
        ref.read(connectionDetailsProvider).requireValue;
    var newestPlayerRequests = newestConnectionDetails.openPlayerRequests ?? [];

    var newRequests = [...newestPlayerRequests];
    newRequests.removeWhere(
        (e) => e.campagneJoinRequestId == request.campagneJoinRequestId);

    ref
        .read(connectionDetailsProvider.notifier)
        .updateConfiguration(newestConnectionDetails.copyWith(
          openPlayerRequests: newRequests,
        ));
  }

  List<Widget> getAllPlayersOfflineStatusWidgets(
      ConnectionDetails? connectionDetails, RpgConfigurationModel? rpgConfig) {
    List<Widget> result = [];

    if (fromServerLoadedPlayers != null) {
      // this should be a better list than the connection details list.
      // hence, if present, we show all characters from this list and get the online status from connectiondetails
      for (var char in fromServerLoadedPlayers!) {
        var connectedPlayerDetails = connectionDetails?.connectedPlayers
            ?.firstWhereOrNull(
                (cp) => cp.playerCharacterId.$value == char.id!.$value!);

        var isOnline = connectedPlayerDetails != null;

        var parsedConfig = RpgCharacterConfiguration.fromJson(
            jsonDecode(char.rpgCharacterConfiguration!));

        var imageOfPlayerCharacter =
            (connectedPlayerDetails?.configuration ?? parsedConfig)
                .getImageUrlWithoutBasePath(rpgConfig);

        var playerCharacterName = char.characterName ??
            connectedPlayerDetails?.configuration.characterName ??
            "Player Name";

        result.add(getSingleConfiguredPlayerOnlineStatus(
          isOnline: isOnline,
          imageUrl: imageOfPlayerCharacter,
          playerCharacterName: playerCharacterName,
          charConfig: connectedPlayerDetails?.configuration ?? parsedConfig,
        ));
      }
    } else {
      // if we havent loaded any chars from the server we simply show all online users using the connectionDetails
      for (var connectedPlayer in connectionDetails?.connectedPlayers ??
          List<OpenPlayerConnection>.empty()) {
        var isOnline = true;

        var imageOfPlayerCharacter =
            connectedPlayer.configuration.getImageUrlWithoutBasePath(rpgConfig);

        var playerCharacterName = connectedPlayer.configuration.characterName ??
            S.of(context).characterNameDefault;

        result.add(getSingleConfiguredPlayerOnlineStatus(
          charConfig: connectedPlayer.configuration,
          isOnline: isOnline,
          imageUrl: imageOfPlayerCharacter,
          playerCharacterName: playerCharacterName,
        ));
      }
    }

    return result;
  }

  Widget getSingleConfiguredPlayerOnlineStatus(
      {required bool isOnline,
      required String? imageUrl,
      required String playerCharacterName,
      required RpgCharacterConfigurationBase charConfig}) {
    var fullImageUrl = imageUrl == null
        ? null
        : (imageUrl.startsWith("assets")
            ? imageUrl
            : (apiBaseUrl +
                (imageUrl.startsWith("/")
                    ? (imageUrl.length > 1 ? imageUrl.substring(1) : '')
                    : imageUrl)));
    return CupertinoButton(
      onPressed: () {
        navigatorKey.currentState!.pushNamed(PlayerPageScreen.route,
            arguments: PlayerPageScreenRouteSettings(
              disableEdit: true,
              showMoney: true,
              characterConfigurationOverride: charConfig,
              showInventory: false,
              showLore: false,
              showRecipes: false,
            ));
      },
      minSize: 0,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 260,
            width: 260,
            child: BorderedImage(
              noPadding: true,
              backgroundColor: bgColor,
              lightColor: darkColor,
              imageUrl: fullImageUrl,
              isLoading: false,
              isGreyscale: !isOnline,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: darkColor,
                ),
                padding: EdgeInsets.all(1),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? lightGreen : lightRed,
                  ),
                  padding: EdgeInsets.all(1),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerCharacterName,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: darkTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                  Text(
                    isOnline ? "Online" : "Offline",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: darkTextColor,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
