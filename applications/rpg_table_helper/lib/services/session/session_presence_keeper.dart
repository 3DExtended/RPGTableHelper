import 'dart:async';

import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

/// Keeps the user present in a table session across SSE reconnects.
///
/// The backend removes a participant from the session once their `/events`
/// stream has been gone for longer than its grace period (e.g. the iPad was
/// locked) and does not restore them on reconnect. Without re-entering, the
/// client keeps running but silently misses every session-scoped notify,
/// such as `itemsGranted` or `characterConfigChanged`.
class SessionPresenceKeeper {
  SessionPresenceKeeper({
    required this.eventsClient,
    required this.rpgEntityService,
    required this.campagneId,
    this.onReentered,
  });

  final EventsClient eventsClient;
  final IRpgEntityService rpgEntityService;
  final CampagneIdentifier campagneId;

  /// Called after a successful re-enter, e.g. to catch up on config changes
  /// whose notifies were lost while disconnected.
  final Future<void> Function()? onReentered;

  StreamSubscription<void>? _subscription;
  bool _isEntering = false;

  void start() {
    _subscription ??=
        eventsClient.connected.listen((_) => unawaited(_reenter()));
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _reenter() async {
    if (_isEntering || _subscription == null) return;
    _isEntering = true;
    try {
      final response =
          await rpgEntityService.enterSession(campagneId: campagneId);
      if (response.isSuccessful && _subscription != null) {
        await onReentered?.call();
      }
    } finally {
      _isEntering = false;
    }
  }
}
