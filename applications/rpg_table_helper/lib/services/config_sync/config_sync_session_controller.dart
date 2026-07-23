import 'dart:async';
import 'dart:convert';

import 'package:json_patch/json_patch.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/config_sync/config_sync_coordinator.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/sse/events_client.dart';
import 'package:quest_keeper/services/sse/sse_parser.dart';

/// Wires per-entity [ConfigSyncCoordinator]s (campagne config + own player
/// character config) to REST and to the active table session's inbound SSE
/// stream (sse-04).
///
/// - UI-driven local edits are pushed in via [notifyLocalCampagneEdit] /
///   [notifyLocalCharacterEdit] and debounced/coalesced by the coordinators.
/// - `campagneConfigChanged` / `characterConfigChanged` SSE notifications for
///   the entity ids started here drive a `GET ?sinceRevision=` catch-up that
///   is applied back via [applyCampagneConfig] / [applyCharacterConfig].
///
/// After the SignalR hard cut (sse-08) this is the sole sync path for session
/// config edits: durable writes go out as debounced REST PATCH/PUT and inbound
/// changes arrive via the `/events` SSE stream.
class ConfigSyncSessionController {
  ConfigSyncSessionController({
    required this.rpgEntityService,
    required this.eventsClient,
    required this.applyCampagneConfig,
    required this.readCampagneConfig,
    required this.applyCharacterConfig,
    required this.readCharacterConfig,
    this.onRemoteCharacterConfig,
    this.onParticipantOnline,
    this.onParticipantOffline,
  });

  final IRpgEntityService rpgEntityService;
  final EventsClient eventsClient;
  final void Function(RpgConfigurationModel config) applyCampagneConfig;
  final RpgConfigurationModel Function() readCampagneConfig;
  final void Function(RpgCharacterConfiguration config) applyCharacterConfig;
  final RpgCharacterConfiguration Function() readCharacterConfig;

  /// DM-only companion hook (sse-08 follow-up): invoked whenever a
  /// `characterConfigChanged` SSE notify arrives for a character other than
  /// the one started via [startForCharacter] (i.e. not "our own" character -
  /// relevant for the DM, who never calls [startForCharacter]). The
  /// controller GETs that character's current config and hands the parsed
  /// result back to the caller, which is expected to patch it into whatever
  /// roster it keeps (e.g. `ConnectionDetails.connectedPlayers`).
  final void Function(String characterId, RpgCharacterConfiguration config)?
      onRemoteCharacterConfig;

  /// DM-only companion hooks: invoked on `participantOnline` /
  /// `participantOffline` SSE notifies (sse-03 presence) for any other
  /// session participant, so the caller can reflect presence in its own
  /// roster (e.g. update `lastPing` on `ConnectionDetails.connectedPlayers`).
  final void Function(String userId)? onParticipantOnline;
  final void Function(String userId)? onParticipantOffline;

  ConfigSyncCoordinator? _campagneCoordinator;
  ConfigSyncCoordinator? _characterCoordinator;
  String? _campagneId;
  String? _characterId;
  StreamSubscription<SseEvent>? _sseSubscription;

  /// Starts the campagne config sync coordinator for [campagneId]. Call once
  /// right after session hydration; [initialRevision] should be the revision
  /// the campagne config was hydrated at (if known) so the first local edit
  /// or SSE notify does not force an unnecessary catch-up round-trip.
  void startForCampagne({
    required CampagneIdentifier campagneId,
    int? initialRevision,
  }) {
    final id = campagneId.$value;
    if (id == null) {
      return;
    }
    _campagneId = id;
    _campagneCoordinator = ConfigSyncCoordinator(
      write: (fromRevision, json) => rpgEntityService.saveCampagneRpgConfig(
        campagneId: campagneId,
        rpgConfigurationJson: json,
        fromRevision: fromRevision,
      ),
      read: (sinceRevision) => rpgEntityService.getCampagneRpgConfigSnapshot(
        campagneId: campagneId,
        sinceRevision: sinceRevision,
      ),
      applyFull: (json, revision) => applyCampagneConfig(
        RpgConfigurationModel.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        ),
      ),
      applyPatch: (ops, revision) => _applyCampagnePatch(ops),
    );
    if (initialRevision != null) {
      _campagneCoordinator!.seed(revision: initialRevision);
    }
    _ensureSseSubscription();
  }

  /// Starts the character config sync coordinator for [playerCharacterId].
  void startForCharacter({
    required PlayerCharacterIdentifier playerCharacterId,
    int? initialRevision,
  }) {
    final id = playerCharacterId.$value;
    if (id == null) {
      return;
    }
    _characterId = id;
    _characterCoordinator = ConfigSyncCoordinator(
      write: (fromRevision, json) => rpgEntityService.saveCharacterRpgConfig(
        playerCharacterId: playerCharacterId,
        rpgCharacterConfigurationJson: json,
        fromRevision: fromRevision,
      ),
      read: (sinceRevision) => rpgEntityService.getCharacterRpgConfigSnapshot(
        playerCharacterId: playerCharacterId,
        sinceRevision: sinceRevision,
      ),
      applyFull: (json, revision) => applyCharacterConfig(
        RpgCharacterConfiguration.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        ),
      ),
      applyPatch: (ops, revision) => _applyCharacterPatch(ops),
    );
    if (initialRevision != null) {
      _characterCoordinator!.seed(revision: initialRevision);
    }
    _ensureSseSubscription();
  }

  /// Call whenever the local campagne config Riverpod state changes due to a
  /// UI-driven edit (not one applied by this controller itself).
  void notifyLocalCampagneEdit(RpgConfigurationModel config) {
    _campagneCoordinator?.notifyLocalEdit(jsonEncode(config));
  }

  /// Call whenever the local character config Riverpod state changes due to
  /// a UI-driven edit (not one applied by this controller itself).
  void notifyLocalCharacterEdit(RpgCharacterConfiguration config) {
    _characterCoordinator?.notifyLocalEdit(jsonEncode(config));
  }

  /// Stops both coordinators and the SSE subscription (e.g. on table leave).
  Future<void> stop() async {
    await _sseSubscription?.cancel();
    _sseSubscription = null;
    _campagneCoordinator?.dispose();
    _characterCoordinator?.dispose();
    _campagneCoordinator = null;
    _characterCoordinator = null;
    _campagneId = null;
    _characterId = null;
  }

  void _applyCampagnePatch(List<dynamic> patchOperations) {
    final current = jsonDecode(jsonEncode(readCampagneConfig()));
    final patched = JsonPatch.apply(current, _asPatchOps(patchOperations));
    if (patched is Map) {
      applyCampagneConfig(
        RpgConfigurationModel.fromJson(Map<String, dynamic>.from(patched)),
      );
    }
  }

  void _applyCharacterPatch(List<dynamic> patchOperations) {
    final current = jsonDecode(jsonEncode(readCharacterConfig()));
    final patched = JsonPatch.apply(current, _asPatchOps(patchOperations));
    if (patched is Map) {
      applyCharacterConfig(
        RpgCharacterConfiguration.fromJson(Map<String, dynamic>.from(patched)),
      );
    }
  }

  static List<Map<String, dynamic>> _asPatchOps(List<dynamic> ops) =>
      ops.map((op) => Map<String, dynamic>.from(op as Map)).toList();

  void _ensureSseSubscription() {
    _sseSubscription ??= eventsClient.events.listen(_onSseEvent);
  }

  void _onSseEvent(SseEvent event) {
    switch (event.type) {
      case 'campagneConfigChanged':
      case 'characterConfigChanged':
        _onConfigChangedEvent(event);
        break;
      case 'participantOnline':
        _onPresenceEvent(event, online: true);
        break;
      case 'participantOffline':
        _onPresenceEvent(event, online: false);
        break;
      default:
        break;
    }
  }

  void _onConfigChangedEvent(SseEvent event) {
    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(event.data) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final id = payload['id'] as String?;
    final revision = payload['revision'] as int?;
    if (id == null || revision == null) {
      return;
    }

    if (event.type == 'campagneConfigChanged' && id == _campagneId) {
      unawaited(_campagneCoordinator?.onRemoteChanged(revision));
    } else if (event.type == 'characterConfigChanged') {
      if (id == _characterId) {
        unawaited(_characterCoordinator?.onRemoteChanged(revision));
      } else if (onRemoteCharacterConfig != null) {
        unawaited(_fetchAndForwardRemoteCharacterConfig(id));
      }
    }
  }

  /// DM path: a character we're not `startForCharacter`-tracking changed
  /// remotely. There is no revision-tracked coordinator for it, so we simply
  /// GET the current character (which carries the full config) and forward
  /// the parsed result to [onRemoteCharacterConfig].
  Future<void> _fetchAndForwardRemoteCharacterConfig(String characterId) async {
    final response = await rpgEntityService.getPlayerCharacterById(
      playerCharacterId: PlayerCharacterIdentifier($value: characterId),
    );
    if (!response.isSuccessful || response.result == null) {
      return;
    }

    final rawConfig = response.result!.rpgCharacterConfiguration;
    if (rawConfig == null || rawConfig.isEmpty) {
      return;
    }

    try {
      final config = RpgCharacterConfiguration.fromJson(
        jsonDecode(rawConfig) as Map<String, dynamic>,
      );
      onRemoteCharacterConfig?.call(characterId, config);
    } catch (_) {
      // Malformed remote config must not take down the session's SSE loop.
    }
  }

  void _onPresenceEvent(SseEvent event, {required bool online}) {
    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(event.data) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final userId = payload['userId'] as String?;
    if (userId == null) {
      return;
    }

    final campagneId = payload['campagneId'] as String?;
    if (_campagneId != null && campagneId != null && campagneId != _campagneId) {
      return;
    }

    if (online) {
      onParticipantOnline?.call(userId);
    } else {
      onParticipantOffline?.call(userId);
    }
  }
}
