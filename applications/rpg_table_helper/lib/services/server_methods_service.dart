import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
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

    serverCommunicationService.registerCallbackFourStrings(
      function: requestJoinPermission,
      functionName: "requestJoinPermission",
    );

    serverCommunicationService.registerCallbackWithoutParameters(
      function: joinRequestAccepted,
      functionName: "joinRequestAccepted",
    );
    serverCommunicationService.registerCallbackWithoutParameters(
      function: requestStatusFromPlayers,
      functionName: "requestStatusFromPlayers",
    );

    serverCommunicationService.registerCallbackSingleString(
      function: updateRpgConfig,
      functionName: "updateRpgConfig",
    );

    serverCommunicationService.registerCallbackThreeStrings(
      function: updateRpgCharacterConfigOnDmSide,
      functionName: "updateRpgCharacterConfigOnDmSide",
    );

    serverCommunicationService.registerCallbackSingleString(
      function: grantPlayerItems,
      functionName: "grantPlayerItems",
    );
    serverCommunicationService.registerCallbackSingleString(
      function: clientDisconnected,
      functionName: "clientDisconnected",
    );
  }

  // this should contain every method that is callable by the server
  void registerGameResponse(String parameter);
  void requestJoinPermission(String playerName, String username,
      String playerCharacterId, String campagneJoinRequestId);
  void joinRequestAccepted();
  void updateRpgConfig(String parameter);
  void updateRpgCharacterConfigOnDmSide(
      String config, String playerId, String userId);
  void grantPlayerItems(String grantedItemsJson);
  void requestStatusFromPlayers();
  void clientDisconnected(String userId);

  // this should contain every method that call the server
  Future registerGame({required String campagneId});
  Future readdToSignalRGroups();
  Future joinGameSession({required String playerCharacterId});

  Future sendUpdatedRpgConfig(
      {required RpgConfigurationModel rpgConfig, required String campagneId});

  Future sendUpdatedRpgCharacterConfig(
      {required RpgCharacterConfiguration charConfig,
      required String playercharacterid});

  Future sendGrantedItemsToPlayers(
      {required String campagneId,
      required List<GrantedItemsForPlayer> grantedItems});
}

class ServerMethodsService extends IServerMethodsService {
  ServerMethodsService(
      {required super.serverCommunicationService, required super.widgetRef})
      : super(isMock: false);

  @override
  Future registerGame({required String campagneId}) async {
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        (widgetRef.read(connectionDetailsProvider).value ??
                ConnectionDetails.defaultValue())
            .copyWith(
                isConnected: false,
                isConnecting: true,
                campagneId: campagneId));

    await serverCommunicationService
        .executeServerFunction("RegisterGame", args: [campagneId]);
  }

  @override
  Future joinGameSession({required String playerCharacterId}) async {
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        (widgetRef.read(connectionDetailsProvider).value ??
                ConnectionDetails.defaultValue())
            .copyWith(
                isConnected: true,
                isConnecting: false,
                playerCharacterId: playerCharacterId));

    await serverCommunicationService
        .executeServerFunction("JoinGame", args: [playerCharacterId]);
  }

  @override
  void registerGameResponse(String parameter) {
    log("Gamecode: $parameter");
    // as we have loaded the session here, we now can update the riverpod state to reflect that
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        (widgetRef.read(connectionDetailsProvider).value ??
                ConnectionDetails.defaultValue())
            .copyWith(
                isConnected: true,
                isConnecting: false,
                isDm: true,
                isInSession: true,
                sessionConnectionNumberForPlayers: parameter));
  }

  @override
  void requestJoinPermission(String playerName, String username,
      String playerCharacterId, String campagneJoinRequestId) {
    log("requestJoinPermission:");

    List<PlayerJoinRequests> openRequests = [
      ...(widgetRef.read(connectionDetailsProvider).value?.openPlayerRequests ??
          []),
      PlayerJoinRequests(
        playerName: playerName,
        username: username,
        playerCharacterId: playerCharacterId,
        campagneJoinRequestId: campagneJoinRequestId,
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
      playercharacterid: connectionDetails.playerCharacterId!,
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
  Future sendUpdatedRpgConfig(
      {required RpgConfigurationModel rpgConfig,
      required String campagneId}) async {
    await serverCommunicationService.executeServerFunction(
        "SendUpdatedRpgConfig",
        args: [campagneId, jsonEncode(rpgConfig)]);
  }

  @override
  Future sendUpdatedRpgCharacterConfig(
      {required RpgCharacterConfiguration charConfig,
      required String playercharacterid}) async {
    await serverCommunicationService.executeServerFunction(
        "SendUpdatedRpgCharacterConfigToDm",
        args: [playercharacterid, jsonEncode(charConfig)]);
  }

  @override
  Future sendGrantedItemsToPlayers(
      {required String campagneId,
      required List<GrantedItemsForPlayer> grantedItems}) async {
    await serverCommunicationService.executeServerFunction(
        "SendGrantedItemsToPlayers",
        args: [campagneId, jsonEncode(grantedItems)]);
  }

  @override
  void updateRpgCharacterConfigOnDmSide(
      String config, String playerId, String userId) {
    if (kDebugMode == true) {
      log("Received new rpg character config");
    }

    Map<String, dynamic> map = jsonDecode(config);

    var receivedConfig = RpgCharacterConfiguration.fromJson(map);

    // we should update the connection info with this player data
    var currentConnectionDetails =
        widgetRef.read(connectionDetailsProvider).requireValue;

    List<OpenPlayerConnection> updatedPlayerProfiles = [
      ...(currentConnectionDetails.connectedPlayers ?? [])
    ];

    var indexOfExistingPlayer = updatedPlayerProfiles
        .indexWhere((p) => p.playerCharacterId.$value! == playerId);

    var connectionObject = OpenPlayerConnection(
      configuration: receivedConfig,
      playerCharacterId: PlayerCharacterIdentifier($value: playerId),
      userId: UserIdentifier($value: userId),
    );

    if (indexOfExistingPlayer == -1) {
      updatedPlayerProfiles.add(connectionObject);
    } else {
      updatedPlayerProfiles[indexOfExistingPlayer] = connectionObject;
    }

    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        currentConnectionDetails.copyWith(
            connectedPlayers: updatedPlayerProfiles));
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

  @override
  void requestStatusFromPlayers() {
    var connectionDetails =
        widgetRef.read(connectionDetailsProvider).requireValue;
    var charDetails =
        widgetRef.read(rpgCharacterConfigurationProvider).requireValue;

    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        connectionDetails.copyWith(
            isConnected: true, isConnecting: false, isInSession: true));

    sendUpdatedRpgCharacterConfig(
      charConfig: charDetails,
      playercharacterid: connectionDetails.playerCharacterId!,
    );
  }

  @override
  Future readdToSignalRGroups() async {
    var connectionDetails =
        widgetRef.read(connectionDetailsProvider).requireValue;

    // ReaddToSignalRGroups(string? campagneId, string? characterId)
    await serverCommunicationService
        .executeServerFunction("ReaddToSignalRGroups", args: [
      connectionDetails.campagneId ?? "NULL",
      connectionDetails.playerCharacterId ?? "NULL"
    ]);
  }

  @override
  void clientDisconnected(String userId) {
    // we should update the connection info with this player data
    var currentConnectionDetails =
        widgetRef.read(connectionDetailsProvider).valueOrNull;
    if (currentConnectionDetails == null) {
      return;
    }

    List<OpenPlayerConnection> updatedPlayerProfiles = [
      ...(currentConnectionDetails.connectedPlayers ?? [])
    ];

    var indexOfExistingPlayer =
        updatedPlayerProfiles.indexWhere((p) => p.userId.$value! == userId);

    if (indexOfExistingPlayer < 0) {
      return;
    }

    updatedPlayerProfiles.removeAt(indexOfExistingPlayer);

    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        currentConnectionDetails.copyWith(
            connectedPlayers: updatedPlayerProfiles));
  }
}
