import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/session/dm_roster_refresh.dart';

PlayerCharacter _character(String id, String userId, int hp) {
  final config = RpgCharacterConfiguration.getBaseConfiguration(null)
      .copyWith(characterName: 'Char $id');
  final json = jsonDecode(jsonEncode(config)) as Map<String, dynamic>;
  json['hpForTest'] = hp;
  return PlayerCharacter(
    id: PlayerCharacterIdentifier(value: id),
    playerUserId: UserIdentifier(value: userId),
    characterName: 'Char $id',
    rpgCharacterConfiguration: jsonEncode(json),
  );
}

void main() {
  test('rebuilds the roster from the server, so values changed while the DM '
      'was offline show up', () async {
    final rpg = MockRpgEntityService(
      apiConnectorService: MockApiConnectorService(),
      getPlayerCharactersForCampagneOverride: HRResponse.fromResult([
        _character('pc-1', 'user-1', 21),
        _character('pc-2', 'user-2', 9),
      ]),
    );

    final roster = await refreshDmRoster(
      rpgEntityService: rpg,
      campagneId: CampagneIdentifier(value: 'c-1'),
      campagneConfig: null,
      onlineUserIds: const ['user-1', 'dm-user'],
      dmUserId: 'dm-user',
    );

    expect(roster, isNotNull);
    expect(roster!.map((p) => p.playerCharacterId.value), ['pc-1', 'pc-2']);
    expect(roster[0].lastPing, isNotNull, reason: 'user-1 is online');
    expect(roster[1].lastPing, isNull, reason: 'user-2 is offline');
  });

  test('the DM account never counts as an online player', () async {
    final rpg = MockRpgEntityService(
      apiConnectorService: MockApiConnectorService(),
      getPlayerCharactersForCampagneOverride: HRResponse.fromResult([
        _character('pc-dm', 'dm-user', 5),
      ]),
    );

    final roster = await refreshDmRoster(
      rpgEntityService: rpg,
      campagneId: CampagneIdentifier(value: 'c-1'),
      campagneConfig: null,
      onlineUserIds: const ['dm-user'],
      dmUserId: 'dm-user',
    );

    expect(roster!.single.lastPing, isNull);
  });

  test('keeps the current roster when the server call fails', () async {
    final rpg = MockRpgEntityService(
      apiConnectorService: MockApiConnectorService(),
      getPlayerCharactersForCampagneOverride: HRResponse.error(
        'down',
        'test-error',
      ),
    );

    final roster = await refreshDmRoster(
      rpgEntityService: rpg,
      campagneId: CampagneIdentifier(value: 'c-1'),
      campagneConfig: null,
      onlineUserIds: const [],
    );

    expect(roster, isNull);
  });
}
