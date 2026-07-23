import 'dart:async';
import 'dart:convert';

import 'package:quest_keeper/services/sse/events_client.dart';
import 'package:quest_keeper/services/sse/sse_parser.dart';

/// Listens on the shared [EventsClient] stream for the table-session-scoped
/// fight/roll and item-grant SSE notifies (sse-06): `playersAreAskedForRolls`,
/// `dmReceivedFightSequenceAnswer`, and `itemsGranted`.
///
/// These mirror the old `AskPlayersForRolls` / `SendFightSequenceRollsToDm` /
/// `SendGrantedItemsToPlayers` SignalR hub relays, but are session-scoped
/// (`ISessionPresenceService`) and delivered inline over the same `/events`
/// stream used by [ConfigSyncSessionController] and
/// [JoinRequestNotificationController]. Callers should start this once the
/// table session UI is active and stop it when leaving the session.
class SessionCommandNotificationController {
  SessionCommandNotificationController({
    required this.eventsClient,
    required this.onPlayersAreAskedForRolls,
    required this.onDmReceivedFightSequenceAnswer,
    required this.onItemsGranted,
  });

  final EventsClient eventsClient;
  final void Function(FightSequenceNotification event)
      onPlayersAreAskedForRolls;
  final void Function(FightSequenceNotification event)
      onDmReceivedFightSequenceAnswer;
  final void Function(ItemsGrantedNotification event) onItemsGranted;

  StreamSubscription<SseEvent>? _subscription;

  void start() {
    _subscription ??= eventsClient.events.listen(_onSseEvent);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onSseEvent(SseEvent event) {
    switch (event.type) {
      case 'playersAreAskedForRolls':
        final parsed = _tryParseFightSequence(event.data);
        if (parsed != null) {
          onPlayersAreAskedForRolls(parsed);
        }
        break;
      case 'dmReceivedFightSequenceAnswer':
        final parsed = _tryParseFightSequence(event.data);
        if (parsed != null) {
          onDmReceivedFightSequenceAnswer(parsed);
        }
        break;
      case 'itemsGranted':
        final parsed = _tryParseItemsGranted(event.data);
        if (parsed != null) {
          onItemsGranted(parsed);
        }
        break;
    }
  }

  FightSequenceNotification? _tryParseFightSequence(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final fightUuid = json['fightUuid'] as String?;
      final sequenceRaw = json['sequence'] as List<dynamic>?;
      if (fightUuid == null || sequenceRaw == null) {
        return null;
      }
      final sequence = sequenceRaw.map((entryRaw) {
        final entry = entryRaw as Map<String, dynamic>;
        return (
          entry['characterId'] as String?,
          entry['characterName'] as String,
          (entry['roll'] as num).toInt(),
        );
      }).toList();
      return FightSequenceNotification(fightUuid: fightUuid, sequence: sequence);
    } catch (_) {
      return null;
    }
  }

  ItemsGrantedNotification? _tryParseItemsGranted(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final playerCharacterId = json['playerCharacterId'] as String?;
      final itemsRaw = json['items'] as List<dynamic>?;
      if (playerCharacterId == null || itemsRaw == null) {
        return null;
      }
      final items = itemsRaw.map((itemRaw) {
        final item = itemRaw as Map<String, dynamic>;
        return GrantedItemNotification(
          itemUuid: item['itemUuid'] as String,
          amount: (item['amount'] as num).toInt(),
        );
      }).toList();
      return ItemsGrantedNotification(
        playerCharacterId: playerCharacterId,
        items: items,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Parsed `playersAreAskedForRolls` / `dmReceivedFightSequenceAnswer` SSE
/// payload: an inline, ephemeral fight-order roll sequence.
class FightSequenceNotification {
  const FightSequenceNotification({
    required this.fightUuid,
    required this.sequence,
  });

  final String fightUuid;

  // characterId is null for opponents the DM added manually to the fight.
  final List<(String? characterId, String characterName, int roll)> sequence;
}

/// Parsed `itemsGranted` SSE payload: a tiny toast notify sent straight to
/// the granted player, carrying the grant details.
class ItemsGrantedNotification {
  const ItemsGrantedNotification({
    required this.playerCharacterId,
    required this.items,
  });

  final String playerCharacterId;
  final List<GrantedItemNotification> items;
}

class GrantedItemNotification {
  const GrantedItemNotification({
    required this.itemUuid,
    required this.amount,
  });

  final String itemUuid;
  final int amount;
}
