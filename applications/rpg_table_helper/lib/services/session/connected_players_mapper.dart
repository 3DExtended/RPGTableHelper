import 'dart:convert';

import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// Maps the [PlayerCharacter] DTOs hydrated by
/// `SessionEntryCoordinator.enterAsDm` (`allCharacters`) into
/// [OpenPlayerConnection]s for `ConnectionDetails.connectedPlayers`.
///
/// This is what makes the DM's live views (character overview, fight
/// sequence, grant items, ...) have something to render right after session
/// entry, before any `characterConfigChanged` SSE notify has arrived for a
/// given character.
///
/// [onlineUserIds] is the presence snapshot returned by `POST /Session/enter`
/// — matching characters get a non-null [OpenPlayerConnection.lastPing]
/// (online); everyone else stays offline (`lastPing: null`). Roster membership
/// alone must never be treated as online.
///
/// Characters missing an id or a player user id are skipped (they cannot be
/// addressed by later SSE-driven updates). Characters with no persisted
/// config yet, or a config that fails to parse, fall back to a base
/// configuration seeded with the character's name so the DM still sees an
/// entry instead of silently dropping the character.
List<OpenPlayerConnection> mapCharactersToOpenPlayerConnections(
  List<PlayerCharacter> characters, {
  RpgConfigurationModel? campagneConfig,
  Iterable<String>? onlineUserIds,
}) {
  final online = onlineUserIds == null
      ? const <String>{}
      : onlineUserIds.where((id) => id.isNotEmpty).toSet();
  final now = DateTime.now();
  final result = <OpenPlayerConnection>[];

  for (final character in characters) {
    final playerCharacterId = character.id;
    final userId = character.playerUserId;
    if (playerCharacterId == null || userId == null) {
      continue;
    }

    final userIdValue = userId.$value;
    final isOnline = userIdValue != null && online.contains(userIdValue);

    result.add(
      OpenPlayerConnection(
        userId: userId,
        playerCharacterId: playerCharacterId,
        configuration: _parseCharacterConfiguration(character, campagneConfig),
        lastPing: isOnline ? now : null,
      ),
    );
  }

  return result;
}

/// Applies a `participantOnline` / `participantOffline` presence delta onto
/// an existing [connectedPlayers] roster.
///
/// When [online] is true and [userId] is not yet in the roster, [allCharacters]
/// (fresh REST pull) is used to grow the roster via
/// [mapCharactersToOpenPlayerConnections], preserving existing lastPing values
/// and marking [userId] online. Returns the unchanged list when offline for an
/// unknown user, or when growth is requested but no characters were supplied.
List<OpenPlayerConnection> applyParticipantPresence({
  required List<OpenPlayerConnection> connectedPlayers,
  required String userId,
  required bool online,
  List<PlayerCharacter>? allCharacters,
  RpgConfigurationModel? campagneConfig,
}) {
  final known = connectedPlayers.any((p) => p.userId.$value == userId);
  if (!known) {
    if (!online || allCharacters == null) {
      return connectedPlayers;
    }

    final previousPings = <String, DateTime?>{
      for (final p in connectedPlayers)
        if (p.userId.$value != null) p.userId.$value!: p.lastPing,
    };
    previousPings[userId] = DateTime.now();

    final remapped = mapCharactersToOpenPlayerConnections(
      allCharacters,
      campagneConfig: campagneConfig,
      onlineUserIds: previousPings.entries
          .where((e) => e.value != null)
          .map((e) => e.key),
    );

    // Preserve exact lastPing timestamps for users that were already online.
    return remapped
        .map((p) {
          final id = p.userId.$value;
          if (id == null) return p;
          final previous = previousPings[id];
          if (previous == null && p.lastPing == null) return p;
          if (previous != null && p.lastPing != null) {
            return p.copyWith(lastPing: previous);
          }
          return p;
        })
        .toList();
  }

  return connectedPlayers
      .map((p) => p.userId.$value == userId
          ? p.copyWith(lastPing: online ? DateTime.now() : null)
          : p)
      .toList();
}

RpgCharacterConfiguration _parseCharacterConfiguration(
  PlayerCharacter character,
  RpgConfigurationModel? campagneConfig,
) {
  final rawConfig = character.rpgCharacterConfiguration;
  if (rawConfig != null && rawConfig.isNotEmpty) {
    try {
      return RpgCharacterConfiguration.fromJson(
        jsonDecode(rawConfig) as Map<String, dynamic>,
      );
    } catch (_) {
      // fall through to the base-configuration fallback below.
    }
  }

  final base = RpgCharacterConfiguration.getBaseConfiguration(campagneConfig);
  final characterName = character.characterName;
  return characterName == null || characterName.isEmpty
      ? base
      : base.copyWith(characterName: characterName);
}
