import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';

/// The 400 the backend sends for a join code that no campagne has.
HRResponse<CampagneJoinRequestIdentifier> unknownJoinCodeResponse() =>
    HRResponse.error<CampagneJoinRequestIdentifier>(
      'Could not create new campagne join request.',
      'bc5a7091-86d6-489e-879c-1f50522ae589',
      errorFromServer: 'Could not find campagne for join code',
      statusCode: 400,
    );

/// [MockRpgEntityService] with the join-related calls answered and recorded.
class FakeJoinRpgEntityService extends MockRpgEntityService {
  FakeJoinRpgEntityService({
    required super.apiConnectorService,
    super.getCampagnesWithPlayerAsDmOverride,
    super.getPlayerCharacetersForPlayerOverride,
    this.joinRequestResponses = const [],
    this.openJoinRequestsByCampagne = const {},
    this.createCharacterResponse,
    this.characters,
    this.campagnes,
  });

  /// When set, the player's characters; [createNewCharacter] adds to it.
  final List<PlayerCharacter>? characters;

  /// When set, the DM's campagnes.
  final List<Campagne>? campagnes;

  /// Answers for consecutive join requests; the last one repeats.
  final List<HRResponse<CampagneJoinRequestIdentifier>> joinRequestResponses;
  final Map<String, int> openJoinRequestsByCampagne;
  final HRResponse<PlayerCharacterIdentifier>? createCharacterResponse;

  final List<String> createdCharacterNames = [];
  final List<({String joinCode, String? characterId})> joinRequests = [];

  static const createdCharacterId = 'c0ffee00-0000-4000-8000-000000000001';

  @override
  Future<HRResponse<PlayerCharacterIdentifier>> createNewCharacter({
    required String characterName,
    String? characterConfigJson,
  }) async {
    createdCharacterNames.add(characterName);
    if (createCharacterResponse == null) {
      characters?.add(
        PlayerCharacter(
          id: PlayerCharacterIdentifier(value: createdCharacterId),
          characterName: characterName,
          lastModifiedAt: DateTime(2026, 11, 16, 14, 15),
        ),
      );
    }
    return createCharacterResponse ??
        HRResponse.fromResult(
          PlayerCharacterIdentifier(value: createdCharacterId),
        );
  }

  @override
  Future<HRResponse<CampagneJoinRequestIdentifier>>
  createNewCampagneJoinRequest({
    required String joinCode,
    required PlayerCharacterIdentifier playerCharacterId,
  }) async {
    joinRequests.add((
      joinCode: joinCode,
      characterId: playerCharacterId.value,
    ));
    if (joinRequestResponses.isEmpty) {
      return HRResponse.fromResult(
        CampagneJoinRequestIdentifier(value: 'request-1'),
      );
    }
    final index = joinRequests.length - 1;
    return joinRequestResponses[index < joinRequestResponses.length
        ? index
        : joinRequestResponses.length - 1];
  }

  @override
  Future<HRResponse<List<PlayerCharacter>>> getPlayerCharacetersForPlayer() {
    if (characters != null) {
      return Future.value(HRResponse.fromResult([...characters!]));
    }
    return super.getPlayerCharacetersForPlayer();
  }

  @override
  Future<HRResponse<List<Campagne>>> getCampagnesWithPlayerAsDm() {
    if (campagnes != null) {
      return Future.value(HRResponse.fromResult([...campagnes!]));
    }
    return super.getCampagnesWithPlayerAsDm();
  }

  @override
  Future<HRResponse<List<JoinRequestForCampagneDto>>>
  getOpenJoinRequestsForCampagne({
    required CampagneIdentifier campagneId,
  }) async {
    final count = openJoinRequestsByCampagne[campagneId.value] ?? 0;
    return HRResponse.fromResult(
      List.generate(
        count,
        (i) => JoinRequestForCampagneDto(
          request: CampagneJoinRequest(
            id: CampagneJoinRequestIdentifier(value: 'r$i'),
          ),
          playerCharacter: PlayerCharacter(
            id: PlayerCharacterIdentifier(value: 'p$i'),
            characterName: 'Spieler $i',
          ),
          username: 'user$i',
        ),
      ),
    );
  }
}
