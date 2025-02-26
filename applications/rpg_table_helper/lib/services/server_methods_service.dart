import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/list_extensions.dart';
import 'package:quest_keeper/helpers/modals/show_ask_player_for_fight_order_roll.dart';
import 'package:quest_keeper/helpers/modals/show_player_has_been_granted_items_through_dm_modal.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/navigation_service.dart';
import 'package:quest_keeper/services/server_communication_service.dart';

abstract class IServerMethodsService {
  final bool isMock;
  final WidgetRef widgetRef;
  final IServerCommunicationService serverCommunicationService;
  final INavigationService navigationService;

  IServerMethodsService({
    required this.isMock,
    required this.widgetRef,
    required this.serverCommunicationService,
    required this.navigationService,
  }) {
    serverCommunicationService.registerCallbackSingleString(
      function: registerGameResponse,
      functionName: "registerGameResponse",
    );

    serverCommunicationService.registerCallbackSingleString(
      function: playersAreAskedForRolls,
      functionName: "playersAreAskedForRolls",
    );

    serverCommunicationService.registerCallbackSingleString(
      function: dmReceivedFightSequenceAnswer,
      functionName: "dmReceivedFightSequenceAnswer",
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

    serverCommunicationService.registerCallbackSingleDateTime(
      function: pingFromDm,
      functionName: "pingFromDm",
    );
    serverCommunicationService.registerCallbackSingleDateTimeAndOneString(
      function: pongFromPlayer,
      functionName: "pongFromPlayer",
    );
  }

  // this should contain every method that is callable by the server
  void playersAreAskedForRolls(String serializedFightSequence);
  void dmReceivedFightSequenceAnswer(String serializedFightSequence);

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

  void pingFromDm(DateTime timestamp);
  void pongFromPlayer(DateTime timestamp, String userId);

  // this should contain every method that call the server
  Future sendPingToPlayers(
      {required String campagneId, required DateTime timestamp});
  Future sendPongToDm(
      {required String campagneId, required DateTime timestamp});

  Future registerGame({required String campagneId});
  Future readdToSignalRGroups();
  Future joinGameSession({required String playerCharacterId});

  Future sendUpdatedRpgConfig(
      {required RpgConfigurationModel rpgConfig, required String campagneId});

  Future askPlayersForRolls(
      {required String campagneId, required FightSequence fightSequence});

  Future sendFightSequenceRollsToDm(
      {required String playerId, required FightSequence fightSequence});

  Future sendUpdatedRpgCharacterConfig(
      {required RpgCharacterConfiguration charConfig,
      required String playercharacterid});

  Future sendGrantedItemsToPlayers(
      {required String campagneId,
      required List<GrantedItemsForPlayer> grantedItems});
}

class ServerMethodsService extends IServerMethodsService {
  ServerMethodsService(
      {required super.serverCommunicationService,
      required super.navigationService,
      required super.widgetRef})
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
    var serializedConfig = jsonEncode(rpgConfig);

    await serverCommunicationService.executeServerFunction(
        "SendUpdatedRpgConfig",
        args: [campagneId, serializedConfig]);
  }

  @override
  Future askPlayersForRolls(
      {required String campagneId,
      required FightSequence fightSequence}) async {
    var strippedFightSequence = fightSequence.copyWith(
        sequence: fightSequence.sequence.where((e) => e.$1 != null).toList());

    await serverCommunicationService.executeServerFunction("AskPlayersForRolls",
        args: [campagneId, jsonEncode(strippedFightSequence)]);
  }

  @override
  Future sendFightSequenceRollsToDm(
      {required String playerId, required FightSequence fightSequence}) async {
    var strippedFightSequence = fightSequence.copyWith(
        sequence: fightSequence.sequence.where((e) => e.$1 != null).toList());

    await serverCommunicationService.executeServerFunction(
        "SendFightSequenceRollsToDm",
        args: [playerId, jsonEncode(strippedFightSequence)]);
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
      lastPing: DateTime.now(),
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
  void playersAreAskedForRolls(String serializedFightSequence) {
    // TODO
    // decode fight sequence
    var decodedFightSequence =
        FightSequence.fromJson(jsonDecode(serializedFightSequence));

    // search which of my characters are asked for a roll
    var currentCharacter =
        widgetRef.read(rpgCharacterConfigurationProvider).requireValue;

    var connectionDetails =
        widgetRef.read(connectionDetailsProvider).requireValue;

    List<RpgCharacterConfigurationBase> charactersInQuestion = [];
    if (decodedFightSequence.sequence
        .any((t) => t.$1 == currentCharacter.uuid)) {
      charactersInQuestion.add(currentCharacter);
    }

    var companionsAsked = currentCharacter.companionCharacters
        ?.where((c) => decodedFightSequence.sequence
            .any((fighttuple) => fighttuple.$1 == c.uuid))
        .toList();
    if (companionsAsked != null && companionsAsked.isNotEmpty) {
      charactersInQuestion.addAll(companionsAsked);
    }

    var alternateFormsAsked = currentCharacter.alternateForms
        ?.where((c) => decodedFightSequence.sequence
            .any((fighttuple) => fighttuple.$1 == c.uuid))
        .toList();
    if (alternateFormsAsked != null && alternateFormsAsked.isNotEmpty) {
      charactersInQuestion.addAll(alternateFormsAsked);
    }

    Future.delayed(Duration.zero, () async {
      List<(String?, String, int)> rollAnswers = [];
      var navKey = navigationService.getCurrentNavigationKey();
      if (navKey.currentContext == null) {
        navKey = navigatorKey;
      }

      for (var characterAsked in charactersInQuestion) {
        // for every character ask show modal which asks for a roll
        var roll = await showAskPlayerForFightOrderRoll(
          navKey.currentContext!,
          characterName: characterAsked.characterName,
        );

        if (roll == null) continue;
        rollAnswers
            .add((characterAsked.uuid, characterAsked.characterName, roll));
      }

      var fightSequenceAnswer = FightSequence(
          fightUuid: decodedFightSequence.fightUuid, sequence: rollAnswers);

      // send answer to dm
      await sendFightSequenceRollsToDm(
          playerId: connectionDetails.playerCharacterId!,
          fightSequence: fightSequenceAnswer);
    });
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
        .grantItems(myNewItems.grantedItems);

    var rpgConfig = widgetRef.read(rpgConfigurationProvider).requireValue;

    var navKey = navigationService.getCurrentNavigationKey();
    if (navKey.currentContext == null) {
      navKey = navigatorKey;
    }

    // show modal
    showPlayerHasBeenGrantedItemsThroughDmModal(
      navKey.currentContext!,
      grantedItems: myNewItems,
      rpgConfig: rpgConfig,
    );
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

  @override
  void dmReceivedFightSequenceAnswer(String serializedFightSequence) {
    // decode fight sequence
    var decodedFightSequence =
        FightSequence.fromJson(jsonDecode(serializedFightSequence));

    var currentConnectionDetails =
        widgetRef.read(connectionDetailsProvider).requireValue;

    var currentFightSequenceAskedFor = currentConnectionDetails.fightSequence;

    if (currentFightSequenceAskedFor == null ||
        currentFightSequenceAskedFor.fightUuid !=
            decodedFightSequence.fightUuid) {
      return;
    }

    // merge answers into connectiondetails
    var fightSequenceList = currentFightSequenceAskedFor.sequence;

    fightSequenceList.addAllIntoSortedList(
        decodedFightSequence.sequence, (a, b) => b.$3.compareTo(a.$3));

    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        currentConnectionDetails.copyWith(
            fightSequence: FightSequence(
                fightUuid: currentFightSequenceAskedFor.fightUuid,
                sequence: fightSequenceList)));
  }

  @override
  void pingFromDm(DateTime timestamp) {
    Future.delayed(Duration.zero, () async {
      print("pingFromDm is called: $timestamp");
      // update lastPing on connection details
      var currentConnectionDetails =
          widgetRef.read(connectionDetailsProvider).requireValue;
      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          currentConnectionDetails.copyWith(lastPing: timestamp));

      await sendPongToDm(
          campagneId: widgetRef
              .read(connectionDetailsProvider)
              .requireValue
              .campagneId!,
          timestamp: timestamp);
    });
  }

  @override
  void pongFromPlayer(DateTime timestamp, String userId) {
    print("pingFromDm is received");

    var currentConnectionDetails =
        widgetRef.read(connectionDetailsProvider).requireValue;

    var indexOfExistingPlayer = currentConnectionDetails.connectedPlayers
        ?.indexWhere((p) => p.userId.$value! == userId);

    if (indexOfExistingPlayer == -1 || indexOfExistingPlayer == null) {
      return;
    } else {
      currentConnectionDetails.connectedPlayers![indexOfExistingPlayer] =
          currentConnectionDetails.connectedPlayers![indexOfExistingPlayer]
              .copyWith(lastPing: timestamp);

      widgetRef
          .read(connectionDetailsProvider.notifier)
          .updateConfiguration(currentConnectionDetails);
    }
  }

  @override
  Future sendPingToPlayers(
      {required String campagneId, required DateTime timestamp}) async {
    // SendPingToPlayers(string campagneId, DateTime timestamp)
    await serverCommunicationService
        .executeServerFunction("SendPingToPlayers", args: [
      campagneId,
      timestamp.toIso8601String(),
    ]);
  }

  @override
  Future sendPongToDm(
      {required String campagneId, required DateTime timestamp}) async {
    print("sendPongToDm is called: $timestamp");
    // SendPongToDm(string campagneId, DateTime timestamp)
    await serverCommunicationService
        .executeServerFunction("SendPongToDm", args: [
      campagneId,
      timestamp.toIso8601String(),
    ]);
  }
}
