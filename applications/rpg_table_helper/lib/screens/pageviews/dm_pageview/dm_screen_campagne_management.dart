import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/newdesign/bordered_image.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
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
                  ...getAllPlayersOfflineStatusWidgets(connectionDetails),
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

              // TODO WILO join requests
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getAllPlayersOfflineStatusWidgets(
      ConnectionDetails? connectionDetails) {
    List<Widget> result = [];

    if (fromServerLoadedPlayers != null) {
      // this should be a better list than the connection details list.
      // hence, if present, we show all characters from this list and get the online status from connectiondetails
      for (var char in fromServerLoadedPlayers!) {
        var connectedPlayerDetails = connectionDetails?.connectedPlayers
            ?.firstWhereOrNull(
                (cp) => cp.playerCharacterId.$value == char.id!.$value!);

        var isOnline = connectedPlayerDetails != null ?? false;

        var imageOfPlayerCharacter =
            connectedPlayerDetails?.configuration.imageUrlWithoutBasePath ??
                "assets/images/charactercard_placeholder.png";

        var playerCharacterName = char.characterName ??
            connectedPlayerDetails?.configuration.characterName ??
            "Player Name";

        result.add(getSingleConfiguredPlayerOnlineStatus(
          isOnline: isOnline,
          imageUrl: imageOfPlayerCharacter,
          playerCharacterName: playerCharacterName,
        ));
      }
    } else {
      // if we havent loaded any chars from the server we simply show all online users using the connectionDetails
      for (var connectedPlayer in connectionDetails?.connectedPlayers ?? []) {
        var isOnline = true;

        var imageOfPlayerCharacter =
            connectedPlayer?.configuration.imageUrlWithoutBasePath ??
                "assets/images/charactercard_placeholder.png";

        var playerCharacterName =
            connectedPlayer?.configuration.characterName ?? "Player Name";

        result.add(getSingleConfiguredPlayerOnlineStatus(
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
      required String playerCharacterName}) {
    var fullImageUrl = imageUrl == null
        ? null
        : (imageUrl.startsWith("assets")
            ? imageUrl
            : (apiBaseUrl +
                (imageUrl.startsWith("/") ? imageUrl.substring(1) : imageUrl)));
    return CupertinoButton(
      onPressed: () {
        navigatorKey.currentState!.pushNamed(PlayerPageScreen.route);
      },
      minSize: 0,
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 260,
            width: 260,
            child: BorderedImage(
              withoutPadding: true,
              backgroundColor: bgColor,
              lightColor: darkColor,
              imageUrl: fullImageUrl,
              isLoadingNewImage: false,
              greyscale: !isOnline,
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
                    color: isOnline ? Color(0xff3ED22B) : Color(0xffD22B2E),
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
