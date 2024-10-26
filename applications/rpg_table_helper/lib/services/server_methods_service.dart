import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/server_communication_service.dart';

abstract class IServerMethodsService {
  final bool isMock;
  final WidgetRef widgetRef;
  final IServerCommunicationService serverCommunicationService;

  IServerMethodsService({
    required this.isMock,
    required this.widgetRef,
    required this.serverCommunicationService,
  }) {
    serverCommunicationService.registerCallbackSingleString(
      function: registerGameResponse,
      functionName: "registerGameResponse",
    );

    serverCommunicationService.registerCallbackThreeStrings(
      function: requestJoinPermission,
      functionName: "requestJoinPermission",
    );

    serverCommunicationService.registerCallbackWithoutParameters(
      function: joinRequestAccepted,
      functionName: "joinRequestAccepted",
    );

    serverCommunicationService.registerCallbackSingleString(
      function: updateRpgConfig,
      functionName: "updateRpgConfig",
    );

    serverCommunicationService.registerCallbackSingleString(
      function: updateRpgCharacterConfigOnDmSide,
      functionName: "updateRpgCharacterConfigOnDmSide",
    );

    serverCommunicationService.registerCallbackSingleString(
      function: grantPlayerItems,
      functionName: "grantPlayerItems",
    );
  }

  // this should contain every method that is callable by the server
  void registerGameResponse(String parameter);
  void requestJoinPermission(
      String playerName, String gameCode, String connectionId);
  void joinRequestAccepted();
  void updateRpgConfig(String parameter);
  void updateRpgCharacterConfigOnDmSide(String parameter);
  void grantPlayerItems(String grantedItemsJson);

  // this should contain every method that call the server
  Future registerGame({required String campagneId});
  Future joinGameSession(
      {required String playerName, required String gameCode});
  Future acceptJoinRequest(
      {required String playerName,
      required String gameCode,
      required String connectionId,
      required RpgConfigurationModel rpgConfig});
  Future sendUpdatedRpgConfig(
      {required RpgConfigurationModel rpgConfig, required String gameCode});

  Future sendUpdatedRpgCharacterConfig(
      {required RpgCharacterConfiguration charConfig,
      required String gameCode});

  Future sendGrantedItemsToPlayers(
      {required String gameCode,
      required List<GrantedItemsForPlayer> grantedItems});
}

class ServerMethodsService extends IServerMethodsService {
  ServerMethodsService(
      {required super.serverCommunicationService, required super.widgetRef})
      : super(isMock: false);

  @override
  Future registerGame({required String campagneId}) async {
    await serverCommunicationService
        .executeServerFunction("RegisterGame", args: [campagneId]);
  }

  @override
  Future joinGameSession(
      {required String playerName, required String gameCode}) async {
    await serverCommunicationService
        .executeServerFunction("JoinGame", args: [playerName, gameCode]);
  }

  @override
  void registerGameResponse(String parameter) {
    log("Gamecode: $parameter");
    // as we have loaded the session here, we now can update the riverpod state to reflect that
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        widgetRef.read(connectionDetailsProvider).value?.copyWith(
                isConnected: true,
                isConnecting: false,
                isDm: true,
                isInSession: true,
                sessionConnectionNumberForPlayers: parameter) ??
            ConnectionDetails.defaultValue());
  }

  @override
  void requestJoinPermission(
      String playerName, String gameCode, String connectionId) {
    log("requestJoinPermission:");

    List<PlayerJoinRequests> openRequests = [
      ...(widgetRef.read(connectionDetailsProvider).value?.openPlayerRequests ??
          []),
      PlayerJoinRequests(
        playerName: playerName,
        gameCode: gameCode,
        connectionId: connectionId,
      ),
    ];

    // as we have loaded the session here, we now can update the riverpod state to reflect that
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        widgetRef.read(connectionDetailsProvider).value?.copyWith(
                isConnected: true,
                isConnecting: false,
                openPlayerRequests: openRequests) ??
            ConnectionDetails.defaultValue());
  }

  @override
  void joinRequestAccepted() {
    log("accepted as player within session");

    var connectionDetails =
        widgetRef.read(connectionDetailsProvider).requireValue;
    var charDetails =
        widgetRef.read(rpgCharacterConfigurationProvider).requireValue;

    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        connectionDetails.copyWith(
            isConnected: true, isConnecting: false, isInSession: true));

    sendUpdatedRpgCharacterConfig(
      charConfig: charDetails,
      gameCode: connectionDetails.sessionConnectionNumberForPlayers!,
    );
  }

  @override
  void updateRpgConfig(String parameter) {
    log("Received new rpg config");
    Map<String, dynamic> map = jsonDecode(parameter);

    var receivedConfig = RpgConfigurationModel.fromJson(map);
    serverCommunicationService.updateRpgConfiguration(receivedConfig);
  }

  @override
  Future acceptJoinRequest(
      {required String playerName,
      required String gameCode,
      required String connectionId,
      required RpgConfigurationModel rpgConfig}) async {
    await serverCommunicationService.executeServerFunction("AcceptJoinRequest",
        args: [playerName, gameCode, connectionId, jsonEncode(rpgConfig)]);
  }

  @override
  Future sendUpdatedRpgConfig(
      {required RpgConfigurationModel rpgConfig,
      required String gameCode}) async {
    await serverCommunicationService.executeServerFunction(
        "SendUpdatedRpgConfig",
        args: [gameCode, jsonEncode(rpgConfig)]);
  }

  @override
  Future sendUpdatedRpgCharacterConfig(
      {required RpgCharacterConfiguration charConfig,
      required String gameCode}) async {
    await serverCommunicationService.executeServerFunction(
        "SendUpdatedRpgCharacterConfigToDm",
        args: [gameCode, jsonEncode(charConfig)]);
  }

  @override
  Future sendGrantedItemsToPlayers(
      {required String gameCode,
      required List<GrantedItemsForPlayer> grantedItems}) async {
    await serverCommunicationService.executeServerFunction(
        "SendGrantedItemsToPlayers",
        args: [gameCode, jsonEncode(grantedItems)]);
  }

  @override
  void updateRpgCharacterConfigOnDmSide(String parameter) {
    if (kDebugMode == true) {
      log("Received new rpg character config");
    }

    Map<String, dynamic> map = jsonDecode(parameter);

    var receivedConfig = RpgCharacterConfiguration.fromJson(map);

    // we should update the connection info with this player data
    var currentConnectionDetails =
        widgetRef.read(connectionDetailsProvider).requireValue;

    List<RpgCharacterConfiguration> updatedPlayerProfiles = [
      ...(currentConnectionDetails.playerProfiles ?? [])
    ];

    var indexOfExistingPlayerWithName =
        updatedPlayerProfiles.indexWhere((p) => p.uuid == receivedConfig.uuid);

    if (indexOfExistingPlayerWithName == -1) {
      updatedPlayerProfiles.add(receivedConfig);
    } else {
      updatedPlayerProfiles[indexOfExistingPlayerWithName] = (receivedConfig);
    }

    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        currentConnectionDetails.copyWith(
            playerProfiles: updatedPlayerProfiles));
  }

  @override
  void grantPlayerItems(String grantedItemsJson) {
    List<dynamic> listOfGrants = jsonDecode(grantedItemsJson);
    var castedList = listOfGrants
        .map((e) => GrantedItemsForPlayer.fromJson(e as Map<String, dynamic>))
        .toList();

    var currentCharacter =
        widgetRef.read(rpgCharacterConfigurationProvider).requireValue;

    // filter correct grants for current user
    var myNewItems = castedList
        .where((el) => el.playerId == currentCharacter.uuid)
        .singleOrNull;
    if (myNewItems == null) {
      // do nothing...
      return;
    }

    // update inventory
    widgetRef
        .read(rpgCharacterConfigurationProvider.notifier)
        .grantItems(myNewItems);

    // TODO show modal
  }
}
