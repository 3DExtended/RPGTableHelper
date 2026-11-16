import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/join_requests/join_campagne_flow.dart';

import '../../fakes/fake_join_rpg_entity_service.dart';

void main() {
  FakeJoinRpgEntityService service({
    List<HRResponse<CampagneJoinRequestIdentifier>> joinRequestResponses =
        const [],
    HRResponse<PlayerCharacterIdentifier>? createCharacterResponse,
  }) => FakeJoinRpgEntityService(
    apiConnectorService: MockApiConnectorService(),
    joinRequestResponses: joinRequestResponses,
    createCharacterResponse: createCharacterResponse,
  );

  test('creates the character, then sends the request for it', () async {
    final fake = service();

    final outcome = await requestToJoinCampagne(
      service: fake,
      joinCode: '699-457',
      newCharacterName: '  Mira Dornwald ',
    );

    expect(outcome, isA<JoinCampagneRequested>());
    expect(fake.createdCharacterNames, ['Mira Dornwald']);
    expect(fake.joinRequests.single.joinCode, '699-457');
    expect(
      fake.joinRequests.single.characterId,
      FakeJoinRpgEntityService.createdCharacterId,
    );
    expect(
      (outcome as JoinCampagneRequested).campagneJoinRequestId,
      'request-1',
    );
  });

  test('an existing character is not created again', () async {
    final fake = service();

    await requestToJoinCampagne(
      service: fake,
      joinCode: '699-457',
      playerCharacterId: PlayerCharacterIdentifier(value: 'existing'),
    );

    expect(fake.createdCharacterNames, isEmpty);
    expect(fake.joinRequests.single.characterId, 'existing');
  });

  test(
    'an unknown code is reported as such, with the created character',
    () async {
      final fake = service(joinRequestResponses: [unknownJoinCodeResponse()]);

      final outcome = await requestToJoinCampagne(
        service: fake,
        joinCode: '999-999',
        newCharacterName: 'Mira',
      );

      expect(outcome, isA<JoinCampagneUnknownCode>());
      expect(
        outcome.playerCharacterId?.value,
        FakeJoinRpgEntityService.createdCharacterId,
      );
    },
  );

  test('other server errors are failures, not "unknown code"', () async {
    final fake = service(
      joinRequestResponses: [
        HRResponse.error<CampagneJoinRequestIdentifier>(
          'x',
          'y',
          errorFromServer: 'Could not verify player character',
          statusCode: 400,
        ),
      ],
    );

    final outcome = await requestToJoinCampagne(
      service: fake,
      joinCode: '699-457',
      newCharacterName: 'Mira',
    );

    expect(outcome, isA<JoinCampagneFailed>());
  });

  test('a failed character creation stops before the request', () async {
    final fake = service(
      createCharacterResponse: HRResponse.error<PlayerCharacterIdentifier>(
        'x',
        'y',
        statusCode: 500,
      ),
    );

    final outcome = await requestToJoinCampagne(
      service: fake,
      joinCode: '699-457',
      newCharacterName: 'Mira',
    );

    expect(outcome, isA<JoinCampagneFailed>());
    expect(outcome.playerCharacterId, isNull);
    expect(fake.joinRequests, isEmpty);
  });

  test('the new character starts without stats and with its name', () {
    final json = jsonDecode(
      buildInitialCharacterConfigJson('Mira'),
    ) as Map<String, dynamic>;
    expect(json['characterName'], 'Mira');
    expect(json['characterStats'], isEmpty);
  });
}
