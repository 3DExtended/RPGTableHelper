import 'dart:async';
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
import 'package:quest_keeper/constants.dart';
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

    serverCommunicationService.registerCallbackSingleString(
      function: updateRpgConfigCold,
      functionName: "updateRpgConfigCold",
    );

    serverCommunicationService.registerCallbackSingleString(
      function: updateRpgConfigHot,
      functionName: "updateRpgConfigHot",
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

    serverCommunicationService.registerCallbackSingleString(
      function: signalRGroupsRejoined,
      functionName: "signalRGroupsRejoined",
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
  void updateRpgConfigCold(String parameter);
  void updateRpgConfigHot(String parameter);
  void updateRpgCharacterConfigOnDmSide(
      String config, String playerId, String userId);
  void grantPlayerItems(String grantedItemsJson);
  void requestStatusFromPlayers();
  void clientDisconnected(String userId);

  void pingFromDm(DateTime timestamp);
  void pongFromPlayer(DateTime timestamp, String userId);

  /// Server confirmation after [ReaddToSignalRGroups] applied groups for this connection.
  void signalRGroupsRejoined(String campagneId);

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

  /// Brief SignalR reconnects should not drop the player from the DM list immediately.
  final Map<String, Timer> _pendingDisconnectByUserId = {};

  String? _latestRpgConfigColdJson;
  String? _latestRpgConfigHotJson;

  // Debounce outgoing config sync to prevent spamming SignalR on rapid provider updates.
  static const Duration _outgoingConfigDebounce = Duration(milliseconds: 800);
  final Map<String, Timer> _pendingCampagneConfigSendTimers = {};
  final Map<String, String> _pendingCampagneColdJsonById = {};
  final Map<String, String> _pendingCampagneHotJsonById = {};
  final Map<String, int> _lastSentCampagneColdHashById = {};
  final Map<String, int> _lastSentCampagneHotHashById = {};

  final Map<String, Timer> _pendingCharacterConfigSendTimers = {};
  final Map<String, String> _pendingCharacterJsonById = {};
  final Map<String, int> _lastSentCharacterHashById = {};

  static const Set<String> _rpgConfigColdKeys = {
    "allItems",
    "placesOfFindings",
    "itemCategories",
    "characterStatTabsDefinition",
    "craftingRecipes",
    "currencyDefinition",
  };

  void _applyRpgConfigFromSlicesIfPossible() {
    if (_latestRpgConfigColdJson == null || _latestRpgConfigHotJson == null) {
      return;
    }

    try {
      final coldMap =
          (jsonDecode(_latestRpgConfigColdJson!) as Map).cast<String, dynamic>();
      final hotMap =
          (jsonDecode(_latestRpgConfigHotJson!) as Map).cast<String, dynamic>();

      // Hot overwrites cold on conflict.
      final merged = <String, dynamic>{...coldMap, ...hotMap};

      final receivedConfig = RpgConfigurationModel.fromJson(merged);
      serverCommunicationService.updateRpgConfiguration(receivedConfig);
    } catch (e, st) {
      if (kDebugMode == true) {
        log("Failed to merge rpg config slices: $e", stackTrace: st);
      }
    }
  }

  Future<void> _flushCampagneConfigIfPending(String campagneId) async {
    final coldJson = _pendingCampagneColdJsonById[campagneId];
    final hotJson = _pendingCampagneHotJsonById[campagneId];

    if (coldJson == null || hotJson == null) {
      return;
    }

    final coldHash = coldJson.hashCode;
    final hotHash = hotJson.hashCode;

    final lastColdHash = _lastSentCampagneColdHashById[campagneId];
    final lastHotHash = _lastSentCampagneHotHashById[campagneId];

    // Skip sending unchanged payloads.
    if (lastColdHash == coldHash && lastHotHash == hotHash) {
      return;
    }

    // Send cold first (big) then hot (small), server recombines for legacy clients.
    if (lastColdHash != coldHash) {
      await serverCommunicationService.executeCriticalServerFunction(
          "SendUpdatedRpgConfigCold",
          args: [campagneId, coldJson]);
      _lastSentCampagneColdHashById[campagneId] = coldHash;
    }

    if (lastHotHash != hotHash) {
      await serverCommunicationService.executeCriticalServerFunction(
          "SendUpdatedRpgConfigHot",
          args: [campagneId, hotJson]);
      _lastSentCampagneHotHashById[campagneId] = hotHash;
    }
  }

  void _debounceCampagneConfigSend({
    required String campagneId,
    required String coldJson,
    required String hotJson,
  }) {
    _pendingCampagneColdJsonById[campagneId] = coldJson;
    _pendingCampagneHotJsonById[campagneId] = hotJson;

    _pendingCampagneConfigSendTimers[campagneId]?.cancel();
    _pendingCampagneConfigSendTimers[campagneId] = Timer(
      _outgoingConfigDebounce,
      () => _flushCampagneConfigIfPending(campagneId),
    );
  }

  Future<void> _flushCharacterConfigIfPending(String playerCharacterId) async {
    final json = _pendingCharacterJsonById[playerCharacterId];
    if (json == null) return;

    final hash = json.hashCode;
    final lastHash = _lastSentCharacterHashById[playerCharacterId];
    if (lastHash == hash) {
      return;
    }

    await serverCommunicationService.executeCriticalServerFunction(
        "SendUpdatedRpgCharacterConfigToDm",
        args: [playerCharacterId, json]);
    _lastSentCharacterHashById[playerCharacterId] = hash;
  }

  void _debounceCharacterConfigSend({
    required String playerCharacterId,
    required String json,
  }) {
    _pendingCharacterJsonById[playerCharacterId] = json;
    _pendingCharacterConfigSendTimers[playerCharacterId]?.cancel();
    _pendingCharacterConfigSendTimers[playerCharacterId] = Timer(
      _outgoingConfigDebounce,
      () => _flushCharacterConfigIfPending(playerCharacterId),
    );
  }

  void _cancelPendingDisconnect(String userId) {
    _pendingDisconnectByUserId[userId]?.cancel();
    _pendingDisconnectByUserId.remove(userId);
  }

  @override
  Future registerGame({required String campagneId}) async {
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        (widgetRef.read(connectionDetailsProvider).value ??
                ConnectionDetails.defaultValue())
            .copyWith(
                isConnected: false,
                isConnecting: true,
                campagneId: campagneId));

    await serverCommunicationService.executeCriticalServerFunction(
        "RegisterGame",
        args: [campagneId]);
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

    await serverCommunicationService.executeCriticalServerFunction(
        "JoinGame",
        args: [playerCharacterId]);
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

    // Keep slice cache in sync for follow-up hot/cold updates in the same session.
    final full = receivedConfig.toJson();
    final cold = <String, dynamic>{};
    final hot = <String, dynamic>{};
    for (final entry in full.entries) {
      if (_rpgConfigColdKeys.contains(entry.key)) {
        cold[entry.key] = entry.value;
      } else {
        hot[entry.key] = entry.value;
      }
    }
    _latestRpgConfigColdJson = jsonEncode(cold);
    _latestRpgConfigHotJson = jsonEncode(hot);
  }

  @override
  void updateRpgConfigCold(String parameter) {
    if (kDebugMode == true) {
      log("Received rpg config cold slice");
    }
    _latestRpgConfigColdJson = parameter;
    _applyRpgConfigFromSlicesIfPossible();
  }

  @override
  void updateRpgConfigHot(String parameter) {
    if (kDebugMode == true) {
      log("Received rpg config hot slice");
    }
    _latestRpgConfigHotJson = parameter;
    _applyRpgConfigFromSlicesIfPossible();
  }

  @override
  Future sendUpdatedRpgConfig(
      {required RpgConfigurationModel rpgConfig,
      required String campagneId}) async {
    final full = rpgConfig.toJson();
    final cold = <String, dynamic>{};
    final hot = <String, dynamic>{};

    for (final entry in full.entries) {
      if (_rpgConfigColdKeys.contains(entry.key)) {
        cold[entry.key] = entry.value;
      } else {
        hot[entry.key] = entry.value;
      }
    }

    // v2 protocol: debounce + last-sent equality; server recombines for legacy clients.
    _debounceCampagneConfigSend(
      campagneId: campagneId,
      coldJson: jsonEncode(cold),
      hotJson: jsonEncode(hot),
    );
  }

  @override
  Future askPlayersForRolls(
      {required String campagneId,
      required FightSequence fightSequence}) async {
    var strippedFightSequence = fightSequence.copyWith(
        sequence: fightSequence.sequence.where((e) => e.$1 != null).toList());

    await serverCommunicationService.executeCriticalServerFunction(
        "AskPlayersForRolls",
        args: [campagneId, jsonEncode(strippedFightSequence)]);
  }

  @override
  Future sendFightSequenceRollsToDm(
      {required String playerId, required FightSequence fightSequence}) async {
    var strippedFightSequence = fightSequence.copyWith(
        sequence: fightSequence.sequence.where((e) => e.$1 != null).toList());

    await serverCommunicationService.executeCriticalServerFunction(
        "SendFightSequenceRollsToDm",
        args: [playerId, jsonEncode(strippedFightSequence)]);
  }

  @override
  Future sendUpdatedRpgCharacterConfig(
      {required RpgCharacterConfiguration charConfig,
      required String playercharacterid}) async {
    _debounceCharacterConfigSend(
      playerCharacterId: playercharacterid,
      json: jsonEncode(charConfig),
    );
  }

  @override
  Future sendGrantedItemsToPlayers(
      {required String campagneId,
      required List<GrantedItemsForPlayer> grantedItems}) async {
    await serverCommunicationService.executeCriticalServerFunction(
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

    _cancelPendingDisconnect(userId);

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
    await serverCommunicationService.executeServerFunction(
      "ReaddToSignalRGroups",
      args: [
        connectionDetails.campagneId ?? "NULL",
        connectionDetails.playerCharacterId ?? "NULL"
      ],
      maxInvokeRetries: 3,
    );
  }

  void _applyClientDisconnectedRemoval(String userId) {
    _pendingDisconnectByUserId.remove(userId);
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
  void clientDisconnected(String userId) {
    _cancelPendingDisconnect(userId);
    _pendingDisconnectByUserId[userId] =
        Timer(clientDisconnectedDebounce, () {
      _applyClientDisconnectedRemoval(userId);
    });
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
      log("pingFromDm is called: $timestamp");
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
    log("pingFromDm is received");
    _cancelPendingDisconnect(userId);

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
  void signalRGroupsRejoined(String campagneId) {
    if (kDebugMode) {
      log('signalRGroupsRejoined: $campagneId', name: 'SignalR');
    }
    final d = widgetRef.read(connectionDetailsProvider).valueOrNull;
    if (d == null || !d.isInSession) {
      return;
    }
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        d.copyWith(isConnected: true, isConnecting: false));
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
    log("sendPongToDm is called: $timestamp");
    // SendPongToDm(string campagneId, DateTime timestamp)
    await serverCommunicationService
        .executeServerFunction("SendPongToDm", args: [
      campagneId,
      timestamp.toIso8601String(),
    ]);
  }
}
