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
/// Characters missing an id or a player user id are skipped (they cannot be
/// addressed by later SSE-driven updates). Characters with no persisted
/// config yet, or a config that fails to parse, fall back to a base
/// configuration seeded with the character's name so the DM still sees an
/// entry instead of silently dropping the character.
List<OpenPlayerConnection> mapCharactersToOpenPlayerConnections(
  List<PlayerCharacter> characters, {
  RpgConfigurationModel? campagneConfig,
}) {
  final result = <OpenPlayerConnection>[];

  for (final character in characters) {
    final playerCharacterId = character.id;
    final userId = character.playerUserId;
    if (playerCharacterId == null || userId == null) {
      continue;
    }

    result.add(
      OpenPlayerConnection(
        userId: userId,
        playerCharacterId: playerCharacterId,
        configuration: _parseCharacterConfiguration(character, campagneConfig),
        lastPing: null,
      ),
    );
  }

  return result;
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
