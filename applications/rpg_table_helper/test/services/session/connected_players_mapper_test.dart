import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/session/connected_players_mapper.dart';

void main() {
  group('mapCharactersToOpenPlayerConnections', () {
    test('maps a hydrated character with a persisted config', () {
      final config = RpgCharacterConfiguration.getBaseConfiguration(null)
          .copyWith(characterName: 'Frodo');
      final character = PlayerCharacter(
        id: PlayerCharacterIdentifier($value: 'pc-1'),
        playerUserId: UserIdentifier($value: 'user-1'),
        characterName: 'Frodo',
        rpgCharacterConfiguration: jsonEncode(config),
      );

      final result = mapCharactersToOpenPlayerConnections([character]);

      expect(result, hasLength(1));
      expect(result.single.playerCharacterId.$value, 'pc-1');
      expect(result.single.userId.$value, 'user-1');
      expect(result.single.configuration.characterName, 'Frodo');
      expect(result.single.lastPing, isNull);
    });

    test('maps multiple characters preserving order', () {
      final characters = [
        PlayerCharacter(
          id: PlayerCharacterIdentifier($value: 'pc-1'),
          playerUserId: UserIdentifier($value: 'user-1'),
          characterName: 'Frodo',
          rpgCharacterConfiguration: jsonEncode(
            RpgCharacterConfiguration.getBaseConfiguration(null)
                .copyWith(characterName: 'Frodo'),
          ),
        ),
        PlayerCharacter(
          id: PlayerCharacterIdentifier($value: 'pc-2'),
          playerUserId: UserIdentifier($value: 'user-2'),
          characterName: 'Sam',
          rpgCharacterConfiguration: jsonEncode(
            RpgCharacterConfiguration.getBaseConfiguration(null)
                .copyWith(characterName: 'Sam'),
          ),
        ),
      ];

      final result = mapCharactersToOpenPlayerConnections(characters);

      expect(result, hasLength(2));
      expect(result[0].playerCharacterId.$value, 'pc-1');
      expect(result[1].playerCharacterId.$value, 'pc-2');
    });

    test('skips characters missing an id', () {
      final character = PlayerCharacter(
        id: null,
        playerUserId: UserIdentifier($value: 'user-1'),
        characterName: 'Frodo',
      );

      final result = mapCharactersToOpenPlayerConnections([character]);

      expect(result, isEmpty);
    });

    test('skips characters missing a player user id', () {
      final character = PlayerCharacter(
        id: PlayerCharacterIdentifier($value: 'pc-1'),
        playerUserId: null,
        characterName: 'Frodo',
      );

      final result = mapCharactersToOpenPlayerConnections([character]);

      expect(result, isEmpty);
    });

    test(
        'falls back to a named base configuration when no config was persisted yet',
        () {
      final character = PlayerCharacter(
        id: PlayerCharacterIdentifier($value: 'pc-1'),
        playerUserId: UserIdentifier($value: 'user-1'),
        characterName: 'Frodo',
        rpgCharacterConfiguration: null,
      );

      final result = mapCharactersToOpenPlayerConnections(
        [character],
        campagneConfig: RpgConfigurationModel.getBaseConfiguration(),
      );

      expect(result, hasLength(1));
      expect(result.single.configuration.characterName, 'Frodo');
    });

    test('falls back to a named base configuration on malformed JSON', () {
      final character = PlayerCharacter(
        id: PlayerCharacterIdentifier($value: 'pc-1'),
        playerUserId: UserIdentifier($value: 'user-1'),
        characterName: 'Frodo',
        rpgCharacterConfiguration: 'not valid json{{{',
      );

      final result = mapCharactersToOpenPlayerConnections([character]);

      expect(result, hasLength(1));
      expect(result.single.configuration.characterName, 'Frodo');
    });
  });
}
