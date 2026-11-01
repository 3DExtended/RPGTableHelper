import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/current_fight_provider.dart';
import 'package:quest_keeper/helpers/initiative_bonus_resolver.dart';
import 'package:quest_keeper/helpers/list_extensions.dart';
import 'package:quest_keeper/helpers/modals/show_ask_player_for_fight_order_roll.dart';
import 'package:quest_keeper/helpers/modals/show_player_has_been_granted_items_through_dm_modal.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/fight_state.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/backend_capabilities_service.dart';
import 'package:quest_keeper/services/config_sync/config_sync_session_controller.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/fights/fight_api_service.dart';
import 'package:quest_keeper/services/navigation_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:uuid/v7.dart';

/// Session-scoped table interactions, all delivered over SSE + REST (sse-01..08).
///
/// After the SignalR hard cut (sse-08) there is no hub connection: durable
/// config writes flow through the active [ConfigSyncSessionController]
/// (debounced REST PATCH/PUT with revision + 409 rebase), inbound edits arrive
/// as `campagneConfigChanged` / `characterConfigChanged` SSE notifies, and
/// ephemeral fight/roll/grant signals travel over the shared `/events` stream
/// (handled here by [playersAreAskedForRolls], [dmReceivedFightSequenceAnswer]
/// and [grantPlayerItems]).
///
/// A backend that advertises `persisted-fights` keeps fights on the server:
/// the DM starts, orders and ends them through `/Fight/*`, every player with a
/// character in the fight is asked to roll (also when they come back later,
/// see [catchUpOnFight]) and the `initiativeRequested` / `initiativeSettled` /
/// `fightUpdated` / `fightEnded` events replace the old fight events, which
/// that backend still sends for older apps.
abstract class IServerMethodsService {
  final bool isMock;
  final WidgetRef widgetRef;
  final INavigationService navigationService;

  /// Write path for the currently entered table session's config documents.
  /// Set by the session-entry flow (select game mode screen) once the
  /// coordinators are wired to this session's Riverpod stores, and cleared on
  /// leave. `null` outside of an active session.
  ConfigSyncSessionController? activeConfigSyncSessionController;

  /// Asks the player for an initiative roll; null when they dismiss it.
  final InitiativeRollPrompt? initiativeRollPrompt;

  IServerMethodsService({
    required this.isMock,
    required this.widgetRef,
    required this.navigationService,
    this.initiativeRollPrompt,
  });

  // --- Session entry (REST SessionEnter already done by the caller) ---
  Future registerGame({required String campagneId});
  Future joinGameSession({required String playerCharacterId});

  // --- Durable config writes (REST via ConfigSync) ---
  Future sendUpdatedRpgConfig(
      {required RpgConfigurationModel rpgConfig, required String campagneId});
  Future sendUpdatedRpgCharacterConfig(
      {required RpgCharacterConfiguration charConfig,
      required String playercharacterid});

  // --- Ephemeral session commands (REST + SSE fan-out) ---
  Future askPlayersForRolls(
      {required String campagneId, required FightSequence fightSequence});
  Future sendFightSequenceRollsToDm(
      {required String playerId, required FightSequence fightSequence});

  /// Returns the grants the server rejected (empty when all went through).
  Future<List<GrantedItemsForPlayer>> sendGrantedItemsToPlayers(
      {required String campagneId,
      required List<GrantedItemsForPlayer> grantedItems});

  // --- Fights (DM) ---

  /// True once the backend said it keeps fights (`persisted-fights`). Before
  /// [catchUpOnFight] or [startFight] loaded the capabilities this is false.
  bool get usesPersistedFights;

  /// Starts a fight and asks [participants] to roll. A backend that keeps
  /// fights also asks players who are not at the table right now; otherwise
  /// only those online are asked, over SSE.
  Future<HRResponse<bool>> startFight({
    required String campagneId,
    required List<FightStartParticipant> participants,
  });

  /// Adds enemies with their rolls; each is placed in the order by its roll.
  Future<HRResponse<bool>> addEnemiesToFight(
      List<(String name, int roll)> enemies);

  /// Moves the entry at [index] of the fight order by [offset] places.
  Future<HRResponse<bool>> moveFightEntry(
      {required int index, required int offset});

  /// Removes the entry at [index] of the fight order.
  Future<HRResponse<bool>> removeFightEntry({required int index});

  /// Stops waiting for the roll of a character or companion.
  Future<HRResponse<bool>> removePendingFightParticipant(String participantId);

  /// Ends the fight; nobody is asked to roll for it any more.
  Future<HRResponse<bool>> endFight();

  /// Loads the open fight from the server, if the backend keeps fights: the
  /// DM gets the current order, a player is asked to roll for every own
  /// character or companion still pending. Call it on entering the session
  /// and after the event stream reconnected.
  Future catchUpOnFight();

  // --- Inbound SSE session-command handlers ---
  void playersAreAskedForRolls(String serializedFightSequence);
  void dmReceivedFightSequenceAnswer(String serializedFightSequence);
  void grantPlayerItems(String grantedItemsJson);
  void initiativeRequested(InitiativeRequest request);

  /// Closes the roll prompts of [settlement]: the player rolled in another
  /// app, or the DM rolled or removed them.
  void initiativeSettled(InitiativeSettlement settlement);
  void fightUpdated(String fightId);
  void fightEnded(String fightId);
}

/// Asks for a roll; closes with null once [noLongerNeeded] completes.
typedef InitiativeRollPrompt = Future<int?> Function(
  String characterName,
  InitiativeBonusHint? initiativeBonusHint,
  Future<void> noLongerNeeded,
);

class ServerMethodsService extends IServerMethodsService {
  ServerMethodsService({
    required super.navigationService,
    required super.widgetRef,
    super.initiativeRollPrompt,
  }) : super(isMock: false);

  /// "fightId|characterUuid" of every roll the player is or was asked for, so
  /// the live event, the old event and a catch-up never ask twice.
  final Set<String> _askedInitiativeRolls = {};

  /// "fightId|characterUuid" of every roll prompt that is open or waits for
  /// the one before it; completing one closes or skips that prompt.
  final Map<String, Completer<void>> _openInitiativePrompts = {};

  IRpgEntityService? get _rpgEntityService =>
      DependencyProvider.getIt?.get<IRpgEntityService>();

  IFightApiService? get _fightApi => _service<IFightApiService>();

  IBackendCapabilitiesService? get _capabilities =>
      _service<IBackendCapabilitiesService>();

  static T? _service<T extends Object>() {
    final getIt = DependencyProvider.getIt;
    return getIt != null && getIt.isRegistered<T>() ? getIt.get<T>() : null;
  }

  @override
  Future registerGame({required String campagneId}) async {
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        (widgetRef.read(connectionDetailsProvider).value ??
                ConnectionDetails.defaultValue())
            .copyWith(
                isConnected: true,
                isConnecting: false,
                isDm: true,
                isInSession: true,
                campagneId: campagneId));
  }

  @override
  Future joinGameSession({required String playerCharacterId}) async {
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        (widgetRef.read(connectionDetailsProvider).value ??
                ConnectionDetails.defaultValue())
            .copyWith(
                isConnected: true,
                isConnecting: false,
                isInSession: true,
                playerCharacterId: playerCharacterId));
  }

  @override
  Future sendUpdatedRpgConfig(
      {required RpgConfigurationModel rpgConfig,
      required String campagneId}) async {
    final controller = activeConfigSyncSessionController;
    if (controller != null) {
      await controller.notifyLocalCampagneEdit(rpgConfig);
      return;
    }
    // Fallback (no active session controller): best-effort direct REST PUT.
    await _rpgEntityService?.updateCampagneRpgConfiguration(
      campagneId: CampagneIdentifier(value: campagneId),
      rpgConfigurationJson: jsonEncode(rpgConfig),
    );
  }

  @override
  Future sendUpdatedRpgCharacterConfig(
      {required RpgCharacterConfiguration charConfig,
      required String playercharacterid}) async {
    final controller = activeConfigSyncSessionController;
    if (controller != null) {
      await controller.notifyLocalCharacterEdit(charConfig);
      return;
    }
    // Fallback (no active session controller): best-effort direct REST PUT.
    await _rpgEntityService?.updatePlayerCharacterRpgConfiguration(
      playerCharacterId: PlayerCharacterIdentifier(value: playercharacterid),
      rpgCharacterConfigurationJson: jsonEncode(charConfig),
    );
  }

  @override
  Future askPlayersForRolls(
      {required String campagneId,
      required FightSequence fightSequence}) async {
    // sse-06: REST + SSE (playersAreAskedForRolls) fan-out.
    var strippedFightSequence = fightSequence.copyWith(
        sequence: fightSequence.sequence.where((e) => e.$1 != null).toList());

    await _rpgEntityService?.askPlayersForRolls(
      campagneId: CampagneIdentifier(value: campagneId),
      fightSequence: strippedFightSequence,
    );
  }

  @override
  Future sendFightSequenceRollsToDm(
      {required String playerId, required FightSequence fightSequence}) async {
    // sse-06: REST + SSE (dmReceivedFightSequenceAnswer) fan-out.
    var strippedFightSequence = fightSequence.copyWith(
        sequence: fightSequence.sequence.where((e) => e.$1 != null).toList());

    await _rpgEntityService?.sendFightSequenceRollsToDm(
      playerCharacterId: PlayerCharacterIdentifier(value: playerId),
      fightSequence: strippedFightSequence,
    );
  }

  @override
  Future<List<GrantedItemsForPlayer>> sendGrantedItemsToPlayers(
      {required String campagneId,
      required List<GrantedItemsForPlayer> grantedItems}) async {
    // sse-06: REST grant-items (revisioned config write) + itemsGranted SSE.
    // One REST call per granted player character, addressed by the
    // character's server id ([GrantedItemsForPlayer.playerId]).
    final rpgEntityService = _rpgEntityService;
    if (rpgEntityService == null) {
      return grantedItems;
    }
    final failedGrants = <GrantedItemsForPlayer>[];
    for (final grant in grantedItems) {
      final response = await rpgEntityService.grantItemsToCharacter(
        playerCharacterId: PlayerCharacterIdentifier(value: grant.playerId),
        items: grant.grantedItems,
      );
      if (!response.isSuccessful) {
        failedGrants.add(grant);
      }
    }
    return failedGrants;
  }

  @override
  void playersAreAskedForRolls(String serializedFightSequence) {
    var decodedFightSequence =
        FightSequence.fromJson(jsonDecode(serializedFightSequence));

    if (usesPersistedFights) {
      // The backend also sends initiativeRequested for this fight; ask from
      // the stored fight so a roll is asked for once and saved there. Only a
      // fight the server does not know falls back to the old flow.
      Future.delayed(Duration.zero, () async {
        final askedFromServer =
            await _askForStoredFight(decodedFightSequence.fightUuid);
        if (!askedFromServer) {
          _askForLegacyFight(decodedFightSequence);
        }
      });
      return;
    }

    _askForLegacyFight(decodedFightSequence);
  }

  void _askForLegacyFight(FightSequence decodedFightSequence) {
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

      final rpgConfig = widgetRef.read(rpgConfigurationProvider).requireValue;

      for (var characterAsked in charactersInQuestion) {
        final hint = resolveInitiativeBonus(
          rpgConfig: rpgConfig,
          character: characterAsked,
        );
        var roll = await _askForRoll(
          navKey,
          characterAsked.characterName,
          hint,
          // The old flow has no event that settles a roll.
          Completer<void>().future,
        );

        if (roll == null) continue;
        rollAnswers
            .add((characterAsked.uuid, characterAsked.characterName, roll));
      }

      var fightSequenceAnswer = FightSequence(
          fightUuid: decodedFightSequence.fightUuid, sequence: rollAnswers);

      await sendFightSequenceRollsToDm(
          playerId: connectionDetails.playerCharacterId!,
          fightSequence: fightSequenceAnswer);
    });
  }

  @override
  void dmReceivedFightSequenceAnswer(String serializedFightSequence) {
    var decodedFightSequence =
        FightSequence.fromJson(jsonDecode(serializedFightSequence));

    // A stored fight is reloaded on fightUpdated instead, which the backend
    // sends along with this event; adding the rolls here would double them.
    if (_sameId(widgetRef.read(currentFightProvider)?.id,
        decodedFightSequence.fightUuid)) {
      return;
    }

    var currentConnectionDetails =
        widgetRef.read(connectionDetailsProvider).requireValue;

    var currentFightSequenceAskedFor = currentConnectionDetails.fightSequence;

    if (currentFightSequenceAskedFor == null ||
        currentFightSequenceAskedFor.fightUuid !=
            decodedFightSequence.fightUuid) {
      return;
    }

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
  void grantPlayerItems(String grantedItemsJson) {
    List<dynamic> listOfGrants = jsonDecode(grantedItemsJson);
    var castedList = listOfGrants
        .map((e) => GrantedItemsForPlayer.fromJson(e as Map<String, dynamic>))
        .toList();

    // Grants are addressed to the character's server id, not to the
    // client-generated RpgCharacterConfiguration.uuid.
    var ownCharacterId = widgetRef
        .read(connectionDetailsProvider)
        .value
        ?.playerCharacterId;
    if (ownCharacterId == null) {
      return;
    }

    var myNewItems =
        castedList.where((el) => el.playerId == ownCharacterId).singleOrNull;
    if (myNewItems == null) {
      return;
    }

    // No local inventory update here: the server already merged the grant
    // into the character config and announces it via characterConfigChanged,
    // which ConfigSync applies. Adding the items again would double them.

    var rpgConfig = widgetRef.read(rpgConfigurationProvider).requireValue;

    var navKey = navigationService.getCurrentNavigationKey();
    if (navKey.currentContext == null) {
      navKey = navigatorKey;
    }

    showPlayerHasBeenGrantedItemsThroughDmModal(
      navKey.currentContext!,
      grantedItems: myNewItems,
      rpgConfig: rpgConfig,
    );
  }

  @override
  bool get usesPersistedFights =>
      _fightApi != null &&
      (_capabilities?.hasCapability(BackendCapability.persistedFights) ??
          false);

  Future<bool> _loadUsesPersistedFights() async {
    final capabilities = _capabilities;
    if (capabilities == null || _fightApi == null) {
      return false;
    }
    await capabilities.ensureCapabilitiesLoaded();
    return usesPersistedFights;
  }

  @override
  Future<HRResponse<bool>> startFight({
    required String campagneId,
    required List<FightStartParticipant> participants,
  }) async {
    if (await _loadUsesPersistedFights()) {
      final response = await _fightApi!.startFight(
        campagneId: campagneId,
        participants: participants,
      );
      if (response.isSuccessful) {
        _showDmFight(response.result!);
        return HRResponse.fromResult(true);
      }
      if (response.statusCode != 404) {
        return HRResponse.error(
          response.humanReadableError ?? 'Could not start the fight.',
          response.errorCode ?? '',
          statusCode: response.statusCode,
          errorFromServer: response.errorFromServer,
        );
      }
      // 404: the backend has no /Fight endpoints after all; use the old flow.
    }

    final fightSequence =
        FightSequence(fightUuid: UuidV7().generate(), sequence: []);
    widgetRef.read(currentFightProvider.notifier).state = null;
    _updateConnectionDetails(
        (details) => details.copyWith(fightSequence: fightSequence));

    await askPlayersForRolls(
      campagneId: campagneId,
      fightSequence: fightSequence.copyWith(
        sequence:
            participants.map((p) => (p.characterUuid, p.name, -1)).toList(),
      ),
    );
    return HRResponse.fromResult(true);
  }

  @override
  Future<HRResponse<bool>> addEnemiesToFight(
      List<(String name, int roll)> enemies) async {
    final fight = widgetRef.read(currentFightProvider);
    if (fight != null) {
      return _changeDmFight(
          _fightApi!.addEnemies(fightId: fight.id, enemies: enemies));
    }

    final fightSequence =
        widgetRef.read(connectionDetailsProvider).value?.fightSequence;
    if (fightSequence == null) {
      return HRResponse.fromResult(false);
    }
    final sequence = fightSequence.sequence;
    sequence.addAllIntoSortedList(
        enemies.map((e) => (null, e.$1, e.$2)), (a, b) => b.$3.compareTo(a.$3));
    _updateConnectionDetails((details) => details.copyWith(
        fightSequence: fightSequence.copyWith(sequence: sequence)));
    return HRResponse.fromResult(true);
  }

  @override
  Future<HRResponse<bool>> moveFightEntry(
      {required int index, required int offset}) async {
    final fight = widgetRef.read(currentFightProvider);
    if (fight != null) {
      final ids = fight.ordered.map((p) => p.id).toList();
      if (!_swap(ids, index, index + offset)) {
        return HRResponse.fromResult(false);
      }
      return _changeDmFight(
          _fightApi!.reorder(fightId: fight.id, participantIds: ids));
    }

    final fightSequence =
        widgetRef.read(connectionDetailsProvider).value?.fightSequence;
    if (fightSequence == null ||
        !_swap(fightSequence.sequence, index, index + offset)) {
      return HRResponse.fromResult(false);
    }
    _updateConnectionDetails(
        (details) => details.copyWith(fightSequence: fightSequence));
    return HRResponse.fromResult(true);
  }

  @override
  Future<HRResponse<bool>> removeFightEntry({required int index}) async {
    final fight = widgetRef.read(currentFightProvider);
    if (fight != null) {
      final ordered = fight.ordered;
      if (index < 0 || index >= ordered.length) {
        return HRResponse.fromResult(false);
      }
      return removePendingFightParticipant(ordered[index].id);
    }

    final fightSequence =
        widgetRef.read(connectionDetailsProvider).value?.fightSequence;
    if (fightSequence == null ||
        index < 0 ||
        index >= fightSequence.sequence.length) {
      return HRResponse.fromResult(false);
    }
    fightSequence.sequence.removeAt(index);
    _updateConnectionDetails(
        (details) => details.copyWith(fightSequence: fightSequence));
    return HRResponse.fromResult(true);
  }

  @override
  Future<HRResponse<bool>> removePendingFightParticipant(
      String participantId) async {
    final fight = widgetRef.read(currentFightProvider);
    if (fight == null) {
      return HRResponse.fromResult(false);
    }
    return _changeDmFight(_fightApi!
        .removeParticipant(fightId: fight.id, participantId: participantId));
  }

  @override
  Future<HRResponse<bool>> endFight() async {
    final fight = widgetRef.read(currentFightProvider);
    if (fight != null) {
      final response = await _fightApi!.endFight(fightId: fight.id);
      // 404/409: the fight is gone or over already - nothing left to end.
      if (!response.isSuccessful &&
          response.statusCode != 404 &&
          response.statusCode != 409) {
        return HRResponse.error(
          response.humanReadableError ?? 'Could not end the fight.',
          response.errorCode ?? '',
          statusCode: response.statusCode,
          errorFromServer: response.errorFromServer,
        );
      }
    }

    _showDmFight(null);
    return HRResponse.fromResult(true);
  }

  @override
  Future catchUpOnFight() async {
    if (!await _loadUsesPersistedFights()) {
      return;
    }
    final details = widgetRef.read(connectionDetailsProvider).value;
    final campagneId = details?.campagneId;
    if (details == null || campagneId == null) {
      return;
    }

    // Only prompts open before the request: a newer one may be missing in it.
    final openPrompts = _openInitiativePrompts.keys.toSet();
    final response = await _fightApi!.getCurrentFight(campagneId: campagneId);
    if (!response.isSuccessful) {
      return;
    }
    final fight = response.result;
    if (details.isDm) {
      _showDmFight(fight);
      return;
    }

    // Rolled elsewhere or ended while the event stream was down.
    final stillPending = {
      for (final p in fight?.pending ?? const <FightParticipantState>[])
        if (p.characterUuid != null) _promptKey(fight!.id, p.characterUuid!),
    };
    _closeInitiativePrompts(
        (key) => openPrompts.contains(key) && !stillPending.contains(key));

    if (fight != null) {
      await _askForInitiative(fight.id, fight.pending);
    }
  }

  @override
  void initiativeRequested(InitiativeRequest request) {
    final details = widgetRef.read(connectionDetailsProvider).value;
    if (details == null ||
        details.isDm ||
        !_sameId(details.campagneId, request.campagneId)) {
      return;
    }
    Future.delayed(Duration.zero,
        () => _askForInitiative(request.fightId, request.participants));
  }

  @override
  void initiativeSettled(InitiativeSettlement settlement) {
    final settled = {
      for (final uuid in settlement.characterUuids)
        _promptKey(settlement.fightId, uuid),
    };
    _closeInitiativePrompts(settled.contains);
  }

  @override
  void fightUpdated(String fightId) {
    final details = widgetRef.read(connectionDetailsProvider).value;
    final fight = widgetRef.read(currentFightProvider);
    if (details == null || !details.isDm) {
      return;
    }
    if (fight == null || _sameId(fight.id, fightId)) {
      catchUpOnFight();
    }
  }

  @override
  void fightEnded(String fightId) {
    _askedInitiativeRolls
        .removeWhere((key) => key.startsWith('${fightId.toLowerCase()}|'));
    _closeInitiativePrompts(
        (key) => key.startsWith('${fightId.toLowerCase()}|'));

    final details = widgetRef.read(connectionDetailsProvider).value;
    if (details != null &&
        details.isDm &&
        _sameId(widgetRef.read(currentFightProvider)?.id, fightId)) {
      _showDmFight(null);
    }
  }

  /// Asks for the rolls of the stored fight [fightId], if the server has it
  /// open; false when the old flow has to ask instead.
  Future<bool> _askForStoredFight(String fightId) async {
    final campagneId =
        widgetRef.read(connectionDetailsProvider).value?.campagneId;
    if (campagneId == null) {
      return false;
    }
    final response = await _fightApi!.getCurrentFight(campagneId: campagneId);
    final fight = response.result;
    if (!response.isSuccessful ||
        fight == null ||
        !_sameId(fight.id, fightId)) {
      return false;
    }
    await _askForInitiative(fight.id, fight.pending);
    return true;
  }

  /// Asks the player to roll for each of [participants] that belongs to the
  /// character they play and was not asked for yet, then saves the rolls.
  Future<void> _askForInitiative(
      String fightId, List<FightParticipantState> participants) async {
    final details = widgetRef.read(connectionDetailsProvider).value;
    if (details == null || details.isDm) {
      return;
    }
    final character =
        widgetRef.read(rpgCharacterConfigurationProvider).value;
    final ownCombatants = <String, RpgCharacterConfigurationBase>{
      if (character != null) character.uuid: character,
      for (final c in character?.companionCharacters ??
          const <RpgAlternateCharacterConfiguration>[])
        c.uuid: c,
      for (final c in character?.alternateForms ??
          const <RpgAlternateCharacterConfiguration>[])
        c.uuid: c,
    };

    final toAsk = participants.where((p) {
      final uuid = p.characterUuid;
      if (uuid == null || !p.isPending) {
        return false;
      }
      final isOwnCharacter = p.playerCharacterId != null
          ? _sameId(p.playerCharacterId, details.playerCharacterId)
          : ownCombatants.containsKey(uuid);
      return isOwnCharacter &&
          _askedInitiativeRolls.add(_promptKey(fightId, uuid));
    }).toList();
    if (toAsk.isEmpty) {
      return;
    }
    for (final participant in toAsk) {
      _openInitiativePrompts[_promptKey(fightId, participant.characterUuid!)] =
          Completer<void>();
    }

    var navKey = navigationService.getCurrentNavigationKey();
    if (navKey.currentContext == null) {
      navKey = navigatorKey;
    }
    final rpgConfig = widgetRef.read(rpgConfigurationProvider).value;

    final rolls = <(String, int)>[];
    for (final participant in toAsk) {
      final key = _promptKey(fightId, participant.characterUuid!);
      final noLongerNeeded = _openInitiativePrompts[key];
      final local = ownCombatants[participant.characterUuid];
      final hint = rpgConfig == null || local == null
          ? null
          : resolveInitiativeBonus(rpgConfig: rpgConfig, character: local);
      final roll = noLongerNeeded == null || noLongerNeeded.isCompleted
          ? null
          : await _askForRoll(
              navKey,
              local?.characterName ?? participant.name,
              hint,
              noLongerNeeded.future,
            );
      if (identical(_openInitiativePrompts[key], noLongerNeeded)) {
        _openInitiativePrompts.remove(key);
      }
      if (roll == null) {
        // Asked again when they come back or the stream reconnects, if the
        // server still waits for this roll.
        _askedInitiativeRolls.remove(key);
        continue;
      }
      rolls.add((participant.characterUuid!, roll));
    }

    if (rolls.isEmpty) {
      return;
    }
    // A 409 means the fight ended or the DM rolled already; nothing to do.
    await _fightApi?.submitRolls(fightId: fightId, rolls: rolls);
  }

  Future<int?> _askForRoll(
    GlobalKey<NavigatorState> navKey,
    String characterName,
    InitiativeBonusHint? hint,
    Future<void> noLongerNeeded,
  ) {
    final prompt = initiativeRollPrompt;
    if (prompt != null) {
      return prompt(characterName, hint, noLongerNeeded);
    }
    return showAskPlayerForFightOrderRoll(
      navKey.currentContext!,
      characterName: characterName,
      initiativeBonusHint: hint,
      noLongerNeeded: noLongerNeeded,
    );
  }

  /// Closes, or skips if not shown yet, the roll prompts whose key matches.
  void _closeInitiativePrompts(bool Function(String key) matches) {
    for (final entry in _openInitiativePrompts.entries) {
      if (matches(entry.key) && !entry.value.isCompleted) {
        entry.value.complete();
      }
    }
  }

  static String _promptKey(String fightId, String characterUuid) =>
      '${fightId.toLowerCase()}|$characterUuid';

  Future<HRResponse<bool>> _changeDmFight(
      Future<HRResponse<FightState>> change) async {
    final response = await change;
    if (response.isSuccessful) {
      _showDmFight(response.result!);
      return HRResponse.fromResult(true);
    }
    if (response.statusCode == 409 || response.statusCode == 404) {
      // Someone rolled meanwhile or the fight is over: show what is stored.
      await catchUpOnFight();
    }
    return HRResponse.error(
      response.humanReadableError ?? '',
      response.errorCode ?? '',
      statusCode: response.statusCode,
      errorFromServer: response.errorFromServer,
    );
  }

  void _showDmFight(FightState? fight) {
    final open = fight != null && fight.isOpen ? fight : null;
    widgetRef.read(currentFightProvider.notifier).state = open;
    _updateConnectionDetails(
        (details) => details.copyWith(fightSequence: open?.toFightSequence()));
  }

  void _updateConnectionDetails(
      ConnectionDetails Function(ConnectionDetails details) change) {
    final details = widgetRef.read(connectionDetailsProvider).value ??
        ConnectionDetails.defaultValue();
    widgetRef
        .read(connectionDetailsProvider.notifier)
        .updateConfiguration(change(details));
  }

  static bool _swap<T>(List<T> list, int a, int b) {
    if (a < 0 || b < 0 || a >= list.length || b >= list.length || a == b) {
      return false;
    }
    final temp = list[a];
    list[a] = list[b];
    list[b] = temp;
    return true;
  }

  static bool _sameId(String? a, String? b) =>
      a != null && b != null && a.toLowerCase() == b.toLowerCase();
}
