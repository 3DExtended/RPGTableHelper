import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/session/session_entry_coordinator.dart';

class _FakeApi extends IApiConnectorService {
  _FakeApi() : super(isMock: true);

  @override
  Future<Swagger?> getApiConnector({bool requiresJwt = true}) async => null;

  @override
  Future<String?> getJwt() async => 'jwt';

  @override
  Future<bool> setJwt(String jwt) async => true;

  @override
  Future<bool> deleteJwt() async => true;

  @override
  Future<ChopperClient?> getChopperClient({bool requiresJwt = true}) async =>
      null;

  @override
  void clearCache() {}

  @override
  void configureAuthenticator(Authenticator authenticator) {}
}

class _RecordingRpgEntityService extends MockRpgEntityService {
  _RecordingRpgEntityService({
    super.enterSessionOverride,
    this.getCampagneByIdOverride,
    this.getAllCharactersOverride,
    super.getPlayerCharacterByIdOverride,
  }) : super(apiConnectorService: _FakeApi());

  final HRResponse<Campagne>? getCampagneByIdOverride;
  final HRResponse<List<PlayerCharacter>>? getAllCharactersOverride;

  final List<String> calls = [];

  @override
  Future<HRResponse<List<String>>> enterSession({
    required CampagneIdentifier campagneId,
  }) {
    calls.add('enterSession:${campagneId.$value}');
    return super.enterSession(campagneId: campagneId);
  }

  @override
  Future<HRResponse<bool>> leaveSession({
    required CampagneIdentifier campagneId,
  }) {
    calls.add('leaveSession:${campagneId.$value}');
    return super.leaveSession(campagneId: campagneId);
  }

  @override
  Future<HRResponse<Campagne>> getCampagneById({
    required CampagneIdentifier campagneId,
  }) {
    calls.add('getCampagneById:${campagneId.$value}');
    return Future.value(
      getCampagneByIdOverride ??
          HRResponse.fromResult(Campagne(
            id: campagneId,
            campagneName: 'Test Campagne',
            rpgConfiguration: '{}',
          )),
    );
  }

  @override
  Future<HRResponse<List<PlayerCharacter>>> getPlayerCharactersForCampagne({
    required CampagneIdentifier campagneId,
  }) {
    calls.add('getPlayerCharactersForCampagne:${campagneId.$value}');
    return Future.value(
      getAllCharactersOverride ?? HRResponse.fromResult(<PlayerCharacter>[]),
    );
  }

  @override
  Future<HRResponse<PlayerCharacter>> getPlayerCharacterById({
    required PlayerCharacterIdentifier playerCharacterId,
  }) {
    calls.add('getPlayerCharacterById:${playerCharacterId.$value}');
    return super.getPlayerCharacterById(playerCharacterId: playerCharacterId);
  }
}

void main() {
  group('SessionEntryCoordinator', () {
    test('enterAsDm calls enterSession then hydrates campagne + all characters',
        () async {
      final characters = [
        PlayerCharacter(
          id: PlayerCharacterIdentifier($value: 'pc-1'),
          characterName: 'Frodo',
        ),
      ];
      final rpgEntityService = _RecordingRpgEntityService(
        getAllCharactersOverride: HRResponse.fromResult(characters),
      );
      final sut = SessionEntryCoordinator(rpgEntityService: rpgEntityService);
      final campagneId = CampagneIdentifier($value: 'campagne-1');

      final result = await sut.enterAsDm(campagneId: campagneId);

      expect(result.isSuccessful, isTrue);
      expect(result.result!.campagne.id!.$value, 'campagne-1');
      expect(result.result!.allCharacters, characters);
      expect(result.result!.ownCharacter, isNull);
      expect(result.result!.onlineUserIds, isEmpty);
      expect(rpgEntityService.calls, [
        'enterSession:campagne-1',
        'getCampagneById:campagne-1',
        'getPlayerCharactersForCampagne:campagne-1',
      ]);
    });

    test('enterAsDm forwards onlineUserIds from SessionEnter snapshot',
        () async {
      final rpgEntityService = _RecordingRpgEntityService(
        enterSessionOverride:
            HRResponse.fromResult(const ['user-online-1', 'user-online-2']),
        getAllCharactersOverride: HRResponse.fromResult(<PlayerCharacter>[]),
      );
      final sut = SessionEntryCoordinator(rpgEntityService: rpgEntityService);

      final result = await sut.enterAsDm(
        campagneId: CampagneIdentifier($value: 'campagne-1'),
      );

      expect(result.isSuccessful, isTrue);
      expect(result.result!.onlineUserIds, ['user-online-1', 'user-online-2']);
    });

    test('enterAsDm propagates error and skips hydration when enter fails',
        () async {
      final rpgEntityService = _RecordingRpgEntityService(
        enterSessionOverride: HRResponse.error('nope', 'test-enter-fail'),
      );
      final sut = SessionEntryCoordinator(rpgEntityService: rpgEntityService);
      final campagneId = CampagneIdentifier($value: 'campagne-1');

      final result = await sut.enterAsDm(campagneId: campagneId);

      expect(result.isSuccessful, isFalse);
      expect(rpgEntityService.calls, ['enterSession:campagne-1']);
    });

    test(
        'enterAsPlayer calls enterSession then hydrates campagne + own character',
        () async {
      final ownCharacter = PlayerCharacter(
        id: PlayerCharacterIdentifier($value: 'pc-1'),
        characterName: 'Frodo',
      );
      final rpgEntityService = _RecordingRpgEntityService(
        getPlayerCharacterByIdOverride: HRResponse.fromResult(ownCharacter),
      );
      final sut = SessionEntryCoordinator(rpgEntityService: rpgEntityService);
      final campagneId = CampagneIdentifier($value: 'campagne-1');
      final playerCharacterId = PlayerCharacterIdentifier($value: 'pc-1');

      final result = await sut.enterAsPlayer(
        campagneId: campagneId,
        playerCharacterId: playerCharacterId,
      );

      expect(result.isSuccessful, isTrue);
      expect(result.result!.campagne.id!.$value, 'campagne-1');
      expect(result.result!.ownCharacter, ownCharacter);
      expect(result.result!.allCharacters, isNull);
      expect(rpgEntityService.calls, [
        'enterSession:campagne-1',
        'getCampagneById:campagne-1',
        'getPlayerCharacterById:pc-1',
      ]);
    });

    test('enterAsPlayer propagates error and skips hydration when enter fails',
        () async {
      final rpgEntityService = _RecordingRpgEntityService(
        enterSessionOverride: HRResponse.error('nope', 'test-enter-fail'),
      );
      final sut = SessionEntryCoordinator(rpgEntityService: rpgEntityService);
      final campagneId = CampagneIdentifier($value: 'campagne-1');
      final playerCharacterId = PlayerCharacterIdentifier($value: 'pc-1');

      final result = await sut.enterAsPlayer(
        campagneId: campagneId,
        playerCharacterId: playerCharacterId,
      );

      expect(result.isSuccessful, isFalse);
      expect(rpgEntityService.calls, ['enterSession:campagne-1']);
    });

    test('leave calls leaveSession on the rpg entity service', () async {
      final rpgEntityService = _RecordingRpgEntityService();
      final sut = SessionEntryCoordinator(rpgEntityService: rpgEntityService);
      final campagneId = CampagneIdentifier($value: 'campagne-1');

      await sut.leave(campagneId: campagneId);

      expect(rpgEntityService.calls, ['leaveSession:campagne-1']);
    });
  });
}
