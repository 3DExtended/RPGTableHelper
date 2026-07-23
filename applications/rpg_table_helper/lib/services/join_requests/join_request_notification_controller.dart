import 'dart:async';
import 'dart:convert';

import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/services/sse/events_client.dart';
import 'package:quest_keeper/services/sse/sse_parser.dart';

/// Listens on the shared [EventsClient] stream for the membership-scoped
/// `joinRequestCreated` / `joinRequestResolved` SSE notifies (sse-05).
///
/// Unlike [ConfigSyncSessionController]'s `*ConfigChanged` events, these are
/// not session-gated: the DM must see new join requests, and the player must
/// see resolutions, whenever their `/events` stream is up - even from the app
/// shell before any `SessionEnter` (PRD user story 29). Callers should start
/// this once as early as possible after login (e.g. on the campagne/character
/// picker screen) and keep it running for the lifetime of that screen.
class JoinRequestNotificationController {
  JoinRequestNotificationController({
    required this.eventsClient,
    required this.onJoinRequestCreated,
    required this.onJoinRequestResolved,
  });

  final EventsClient eventsClient;
  final void Function(JoinRequestCreatedEvent event) onJoinRequestCreated;
  final void Function(JoinRequestResolvedEvent event) onJoinRequestResolved;

  StreamSubscription<SseEvent>? _subscription;

  void start() {
    _subscription ??= eventsClient.events.listen(_onSseEvent);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onSseEvent(SseEvent event) {
    if (event.type == 'joinRequestCreated') {
      final parsed = _tryParseCreated(event.data);
      if (parsed != null) {
        onJoinRequestCreated(parsed);
      }
    } else if (event.type == 'joinRequestResolved') {
      final parsed = _tryParseResolved(event.data);
      if (parsed != null) {
        onJoinRequestResolved(parsed);
      }
    }
  }

  JoinRequestCreatedEvent? _tryParseCreated(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final requestId = json['requestId'] as String?;
      final campagneId = json['campagneId'] as String?;
      final playerCharacterId = json['playerCharacterId'] as String?;
      final playerName = json['playerName'] as String?;
      final username = json['username'] as String?;
      if (requestId == null ||
          campagneId == null ||
          playerCharacterId == null ||
          playerName == null ||
          username == null) {
        return null;
      }
      return JoinRequestCreatedEvent(
        requestId: requestId,
        campagneId: campagneId,
        playerCharacterId: playerCharacterId,
        playerName: playerName,
        username: username,
      );
    } catch (_) {
      return null;
    }
  }

  JoinRequestResolvedEvent? _tryParseResolved(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final requestId = json['requestId'] as String?;
      final campagneId = json['campagneId'] as String?;
      final type = json['type'] as String?;
      if (requestId == null || campagneId == null || type == null) {
        return null;
      }
      return JoinRequestResolvedEvent(
        requestId: requestId,
        campagneId: campagneId,
        accepted: type == 'Accept',
      );
    } catch (_) {
      return null;
    }
  }
}

/// Parsed `joinRequestCreated` SSE payload: the request identity plus enough
/// player display info for the DM's open-requests list.
class JoinRequestCreatedEvent {
  const JoinRequestCreatedEvent({
    required this.requestId,
    required this.campagneId,
    required this.playerCharacterId,
    required this.playerName,
    required this.username,
  });

  final String requestId;
  final String campagneId;
  final String playerCharacterId;
  final String playerName;
  final String username;

  PlayerJoinRequests toPlayerJoinRequest() => PlayerJoinRequests(
        playerName: playerName,
        username: username,
        playerCharacterId: playerCharacterId,
        campagneJoinRequestId: requestId,
      );
}

/// Parsed `joinRequestResolved` SSE payload delivered to the requesting
/// player once the DM accepts or denies their request.
class JoinRequestResolvedEvent {
  const JoinRequestResolvedEvent({
    required this.requestId,
    required this.campagneId,
    required this.accepted,
  });

  final String requestId;
  final String campagneId;
  final bool accepted;
}
