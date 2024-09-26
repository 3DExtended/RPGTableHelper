import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
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
  }

  // this should contain every method that is callable by the server
  void registerGameResponse(String parameter);
  void requestJoinPermission(
      String playerName, String gameCode, String connectionId);
  void joinRequestAccepted();
  void updateRpgConfig(String parameter);
  void updateRpgCharacterConfigOnDmSide(String parameter);

  // this should contain every method that call the server
  Future registerGame({required String campagneName});
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
}

class ServerMethodsService extends IServerMethodsService {
  ServerMethodsService(
      {required super.serverCommunicationService, required super.widgetRef})
      : super(isMock: false);

  @override
  Future registerGame({required String campagneName}) async {
    await serverCommunicationService
        .executeServerFunction("RegisterGame", args: [campagneName]);
  }

  @override
  Future joinGameSession(
      {required String playerName, required String gameCode}) async {
    await serverCommunicationService
        .executeServerFunction("JoinGame", args: [playerName, gameCode]);
  }

  @override
  void registerGameResponse(String parameter) {
    print("Gamecode: $parameter");
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
    print("requestJoinPermission:");

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
    print("accepted as player within session");
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        widgetRef.read(connectionDetailsProvider).value?.copyWith(
                isConnected: true, isConnecting: false, isInSession: true) ??
            ConnectionDetails.defaultValue());
  }

  @override
  void updateRpgConfig(String parameter) {
    print("Received new rpg config");
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
  void updateRpgCharacterConfigOnDmSide(String parameter) {
    print("Received new rpg character config");
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
}
