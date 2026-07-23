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
/// This is the primary new sync path for session config edits (sse-04); the
/// SignalR hub invoke queue is left in place for other flows until sse-08.
class ConfigSyncSessionController {
  ConfigSyncSessionController({
    required this.rpgEntityService,
    required this.eventsClient,
    required this.applyCampagneConfig,
    required this.readCampagneConfig,
    required this.applyCharacterConfig,
    required this.readCharacterConfig,
  });

  final IRpgEntityService rpgEntityService;
  final EventsClient eventsClient;
  final void Function(RpgConfigurationModel config) applyCampagneConfig;
  final RpgConfigurationModel Function() readCampagneConfig;
  final void Function(RpgCharacterConfiguration config) applyCharacterConfig;
  final RpgCharacterConfiguration Function() readCharacterConfig;

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
    if (event.type != 'campagneConfigChanged' &&
        event.type != 'characterConfigChanged') {
      return;
    }

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
    } else if (event.type == 'characterConfigChanged' && id == _characterId) {
      unawaited(_characterCoordinator?.onRemoteChanged(revision));
    }
  }
}
