import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/initiative_bonus_resolver.dart';
import 'package:quest_keeper/helpers/list_extensions.dart';
import 'package:quest_keeper/helpers/modals/show_ask_player_for_fight_order_roll.dart';
import 'package:quest_keeper/helpers/modals/show_player_has_been_granted_items_through_dm_modal.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/config_sync/config_sync_session_controller.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/navigation_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';

/// Session-scoped table interactions, all delivered over SSE + REST (sse-01..08).
///
/// After the SignalR hard cut (sse-08) there is no hub connection: durable
/// config writes flow through the active [ConfigSyncSessionController]
/// (debounced REST PATCH/PUT with revision + 409 rebase), inbound edits arrive
/// as `campagneConfigChanged` / `characterConfigChanged` SSE notifies, and
/// ephemeral fight/roll/grant signals travel over the shared `/events` stream
/// (handled here by [playersAreAskedForRolls], [dmReceivedFightSequenceAnswer]
/// and [grantPlayerItems]).
abstract class IServerMethodsService {
  final bool isMock;
  final WidgetRef widgetRef;
  final INavigationService navigationService;

  /// Write path for the currently entered table session's config documents.
  /// Set by the session-entry flow (select game mode screen) once the
  /// coordinators are wired to this session's Riverpod stores, and cleared on
  /// leave. `null` outside of an active session.
  ConfigSyncSessionController? activeConfigSyncSessionController;

  IServerMethodsService({
    required this.isMock,
    required this.widgetRef,
    required this.navigationService,
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
  Future sendGrantedItemsToPlayers(
      {required String campagneId,
      required List<GrantedItemsForPlayer> grantedItems});

  // --- Inbound SSE session-command handlers ---
  void playersAreAskedForRolls(String serializedFightSequence);
  void dmReceivedFightSequenceAnswer(String serializedFightSequence);
  void grantPlayerItems(String grantedItemsJson);
}

class ServerMethodsService extends IServerMethodsService {
  ServerMethodsService({
    required super.navigationService,
    required super.widgetRef,
  }) : super(isMock: false);

  IRpgEntityService? get _rpgEntityService =>
      DependencyProvider.getIt?.get<IRpgEntityService>();

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
      campagneId: CampagneIdentifier($value: campagneId),
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
      playerCharacterId: PlayerCharacterIdentifier($value: playercharacterid),
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
      campagneId: CampagneIdentifier($value: campagneId),
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
      playerCharacterId: PlayerCharacterIdentifier($value: playerId),
      fightSequence: strippedFightSequence,
    );
  }

  @override
  Future sendGrantedItemsToPlayers(
      {required String campagneId,
      required List<GrantedItemsForPlayer> grantedItems}) async {
    // sse-06: REST grant-items (revisioned config write) + itemsGranted SSE.
    // One REST call per granted player character.
    final rpgEntityService = _rpgEntityService;
    if (rpgEntityService == null) {
      return;
    }
    for (final grant in grantedItems) {
      await rpgEntityService.grantItemsToCharacter(
        playerCharacterId: PlayerCharacterIdentifier($value: grant.playerId),
        items: grant.grantedItems,
      );
    }
  }

  @override
  void playersAreAskedForRolls(String serializedFightSequence) {
    var decodedFightSequence =
        FightSequence.fromJson(jsonDecode(serializedFightSequence));

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

      final rpgConfig =
          widgetRef.read(rpgConfigurationProvider).requireValue;

      for (var characterAsked in charactersInQuestion) {
        final hint = resolveInitiativeBonus(
          rpgConfig: rpgConfig,
          character: characterAsked,
        );
        var roll = await showAskPlayerForFightOrderRoll(
          navKey.currentContext!,
          characterName: characterAsked.characterName,
          initiativeBonusHint: hint,
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

    var currentCharacter =
        widgetRef.read(rpgCharacterConfigurationProvider).requireValue;

    var myNewItems = castedList
        .where((el) => el.playerId == currentCharacter.uuid)
        .singleOrNull;
    if (myNewItems == null) {
      return;
    }

    widgetRef
        .read(rpgCharacterConfigurationProvider.notifier)
        .grantItems(myNewItems.grantedItems);

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
}
