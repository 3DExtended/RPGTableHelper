import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A join request the player sent from this device and that the DM has not
/// answered yet (as far as this device knows).
///
/// The API has no endpoint that lists a player's open requests, so the app
/// remembers them locally to show "waiting for approval" on the character.
@immutable
class PendingJoinRequest {
  const PendingJoinRequest({
    required this.playerCharacterId,
    required this.joinCode,
    required this.requestedAt,
    this.campagneJoinRequestId,
  });

  final String playerCharacterId;
  final String? campagneJoinRequestId;
  final String joinCode;
  final DateTime requestedAt;

  Map<String, dynamic> toJson() => {
    'playerCharacterId': playerCharacterId,
    'campagneJoinRequestId': campagneJoinRequestId,
    'joinCode': joinCode,
    'requestedAt': requestedAt.toUtc().toIso8601String(),
  };

  static PendingJoinRequest? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final characterId = json['playerCharacterId'];
    final joinCode = json['joinCode'];
    final requestedAt = DateTime.tryParse('${json['requestedAt']}');
    if (characterId is! String || joinCode is! String || requestedAt == null) {
      return null;
    }
    final requestId = json['campagneJoinRequestId'];
    return PendingJoinRequest(
      playerCharacterId: characterId,
      campagneJoinRequestId: requestId is String ? requestId : null,
      joinCode: joinCode,
      requestedAt: requestedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PendingJoinRequest &&
      other.playerCharacterId == playerCharacterId &&
      other.campagneJoinRequestId == campagneJoinRequestId &&
      other.joinCode == joinCode &&
      other.requestedAt == requestedAt;

  @override
  int get hashCode => Object.hash(
    playerCharacterId,
    campagneJoinRequestId,
    joinCode,
    requestedAt,
  );
}

/// Keeps [PendingJoinRequest]s on this device, keyed by character id.
abstract class IPendingJoinRequestStore {
  Future<Map<String, PendingJoinRequest>> loadAll();
  Future<void> save(PendingJoinRequest request);
  Future<void> remove(String playerCharacterId);
}

class SharedPreferencesPendingJoinRequestStore
    implements IPendingJoinRequestStore {
  const SharedPreferencesPendingJoinRequestStore();

  static const storageKey = 'pendingJoinRequests';

  @override
  Future<Map<String, PendingJoinRequest>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      final result = <String, PendingJoinRequest>{};
      for (final entry in decoded.entries) {
        final parsed = PendingJoinRequest.tryFromJson(entry.value);
        if (parsed != null) result[entry.key] = parsed;
      }
      return result;
    } catch (e) {
      debugPrint('Could not load pending join requests: $e');
      return {};
    }
  }

  Future<void> _write(Map<String, PendingJoinRequest> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storageKey,
      jsonEncode(entries.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }

  @override
  Future<void> save(PendingJoinRequest request) async {
    try {
      final entries = await loadAll();
      entries[request.playerCharacterId] = request;
      await _write(entries);
    } catch (e) {
      debugPrint('Could not save pending join request: $e');
    }
  }

  @override
  Future<void> remove(String playerCharacterId) async {
    try {
      final entries = await loadAll();
      if (entries.remove(playerCharacterId) == null) return;
      await _write(entries);
    } catch (e) {
      debugPrint('Could not remove pending join request: $e');
    }
  }
}

/// In-memory store for tests.
class InMemoryPendingJoinRequestStore implements IPendingJoinRequestStore {
  InMemoryPendingJoinRequestStore([Map<String, PendingJoinRequest>? entries])
    : entries = entries ?? {};

  final Map<String, PendingJoinRequest> entries;

  @override
  Future<Map<String, PendingJoinRequest>> loadAll() async => {...entries};

  @override
  Future<void> save(PendingJoinRequest request) async {
    entries[request.playerCharacterId] = request;
  }

  @override
  Future<void> remove(String playerCharacterId) async {
    entries.remove(playerCharacterId);
  }
}

final pendingJoinRequestStoreProvider = Provider<IPendingJoinRequestStore>(
  (ref) => const SharedPreferencesPendingJoinRequestStore(),
);

/// Drops the pending entries whose character the server already lists as
/// part of a campagne (the DM accepted) and returns what is still pending.
///
/// Entries for characters missing from [characters] stay: they may belong to
/// another account that used this device.
Future<Map<String, PendingJoinRequest>> reconcilePendingJoinRequests({
  required IPendingJoinRequestStore store,
  required List<PlayerCharacter> characters,
}) async {
  final pending = await store.loadAll();
  for (final character in characters) {
    final id = character.id?.value;
    if (id == null || !pending.containsKey(id)) continue;
    final campagneId = character.campagneId?.value;
    if (campagneId != null && campagneId.isNotEmpty) {
      await store.remove(id);
      pending.remove(id);
    }
  }
  return pending;
}
