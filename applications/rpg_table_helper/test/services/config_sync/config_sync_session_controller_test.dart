import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/config_sync/config_sync_models.dart';
import 'package:quest_keeper/services/config_sync/config_sync_session_controller.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

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
    super.saveCampagneRpgConfigOverride,
    super.getCampagneRpgConfigSnapshotOverride,
    super.saveCharacterRpgConfigOverride,
    super.getCharacterRpgConfigSnapshotOverride,
    super.getPlayerCharacterByIdOverride,
    super.getPlayerCharactersForCampagneOverride,
  }) : super(apiConnectorService: _FakeApi());

  final List<String> calls = [];

  @override
  Future<HRResponse<PlayerCharacter>> getPlayerCharacterById({
    required PlayerCharacterIdentifier playerCharacterId,
  }) {
    calls.add('getPlayerCharacterById:${playerCharacterId.$value}');
    return super.getPlayerCharacterById(playerCharacterId: playerCharacterId);
  }

  @override
  Future<HRResponse<List<PlayerCharacter>>> getPlayerCharactersForCampagne(
      {required CampagneIdentifier campagneId}) {
    calls.add('getPlayerCharactersForCampagne:${campagneId.$value}');
    return super.getPlayerCharactersForCampagne(campagneId: campagneId);
  }

  @override
  Future<HRResponse<ConfigWriteResult>> saveCampagneRpgConfig({
    required CampagneIdentifier campagneId,
    required String rpgConfigurationJson,
    int? fromRevision,
  }) {
    calls.add('saveCampagneRpgConfig:$fromRevision:$rpgConfigurationJson');
    return super.saveCampagneRpgConfig(
      campagneId: campagneId,
      rpgConfigurationJson: rpgConfigurationJson,
      fromRevision: fromRevision,
    );
  }

  @override
  Future<HRResponse<ConfigSnapshot>> getCampagneRpgConfigSnapshot({
    required CampagneIdentifier campagneId,
    int? sinceRevision,
  }) {
    calls.add('getCampagneRpgConfigSnapshot:$sinceRevision');
    return super.getCampagneRpgConfigSnapshot(
      campagneId: campagneId,
      sinceRevision: sinceRevision,
    );
  }

  @override
  Future<HRResponse<ConfigWriteResult>> saveCharacterRpgConfig({
    required PlayerCharacterIdentifier playerCharacterId,
    required String rpgCharacterConfigurationJson,
    int? fromRevision,
  }) {
    calls.add(
      'saveCharacterRpgConfig:$fromRevision:$rpgCharacterConfigurationJson',
    );
    return super.saveCharacterRpgConfig(
      playerCharacterId: playerCharacterId,
      rpgCharacterConfigurationJson: rpgCharacterConfigurationJson,
      fromRevision: fromRevision,
    );
  }

  @override
  Future<HRResponse<ConfigSnapshot>> getCharacterRpgConfigSnapshot({
    required PlayerCharacterIdentifier playerCharacterId,
    int? sinceRevision,
  }) {
    calls.add('getCharacterRpgConfigSnapshot:$sinceRevision');
    return super.getCharacterRpgConfigSnapshot(
      playerCharacterId: playerCharacterId,
      sinceRevision: sinceRevision,
    );
  }
}

void main() {
  group('ConfigSyncSessionController', () {
    late StreamController<List<int>> sseBody;
    late EventsClient eventsClient;

    setUp(() {
      sseBody = StreamController<List<int>>();
      eventsClient = EventsClient(
        getJwt: () async => 'jwt',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async =>
            http.ByteStream(sseBody.stream),
        sleep: (_) async {},
      );
    });

    tearDown(() async {
      await eventsClient.dispose();
      if (!sseBody.isClosed) {
        await sseBody.close();
      }
    });

    test(
        'notifyLocalCampagneEdit flows through to saveCampagneRpgConfig with the seeded revision',
        () async {
      final rpgEntityService = _RecordingRpgEntityService(
        saveCampagneRpgConfigOverride:
            HRResponse.fromResult(const ConfigWriteResult(revision: 2)),
      );
      RpgConfigurationModel? applied;
      final sut = ConfigSyncSessionController(
        rpgEntityService: rpgEntityService,
        eventsClient: eventsClient,
        applyCampagneConfig: (c) => applied = c,
        readCampagneConfig: () => RpgConfigurationModel.getBaseConfiguration(),
        applyCharacterConfig: (_) {},
        readCharacterConfig: () =>
            RpgCharacterConfiguration.getBaseConfiguration(null),
      );
      await eventsClient.start();

      final campagneId = CampagneIdentifier($value: 'campagne-1');
      sut.startForCampagne(campagneId: campagneId, initialRevision: 1);

      final edited =
          RpgConfigurationModel.getBaseConfiguration().copyWith(rpgName: 'x');
      await sut.notifyLocalCampagneEdit(edited);

      expect(
        rpgEntityService.calls.single,
        startsWith('saveCampagneRpgConfig:1:'),
      );
      expect(applied, isNull, reason: 'writes do not self-apply');

      await sut.stop();
    });

    test(
        'campagneConfigChanged SSE for the started campagne triggers a catch-up GET and applies the full doc',
        () async {
      final serverConfig = RpgConfigurationModel.getBaseConfiguration()
          .copyWith(rpgName: 'fromServer');
      final rpgEntityService = _RecordingRpgEntityService(
        getCampagneRpgConfigSnapshotOverride: HRResponse.fromResult(
          ConfigSnapshot(
            kind: 'full',
            revision: 5,
            fullConfig: jsonEncode(serverConfig),
          ),
        ),
      );
      RpgConfigurationModel? applied;
      final sut = ConfigSyncSessionController(
        rpgEntityService: rpgEntityService,
        eventsClient: eventsClient,
        applyCampagneConfig: (c) => applied = c,
        readCampagneConfig: () => RpgConfigurationModel.getBaseConfiguration(),
        applyCharacterConfig: (_) {},
        readCharacterConfig: () =>
            RpgCharacterConfiguration.getBaseConfiguration(null),
      );
      await eventsClient.start();

      final campagneId = CampagneIdentifier($value: 'campagne-1');
      sut.startForCampagne(campagneId: campagneId, initialRevision: 1);

      sseBody.add(
        utf8.encode(
          'event: campagneConfigChanged\ndata: {"id":"campagne-1","revision":5}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(rpgEntityService.calls, ['getCampagneRpgConfigSnapshot:1']);
      expect(applied?.rpgName, 'fromServer');

      await sut.stop();
    });

    test('ignores campagneConfigChanged notifications for a different campagne id',
        () async {
      final rpgEntityService = _RecordingRpgEntityService();
      final sut = ConfigSyncSessionController(
        rpgEntityService: rpgEntityService,
        eventsClient: eventsClient,
        applyCampagneConfig: (_) {},
        readCampagneConfig: () => RpgConfigurationModel.getBaseConfiguration(),
        applyCharacterConfig: (_) {},
        readCharacterConfig: () =>
            RpgCharacterConfiguration.getBaseConfiguration(null),
      );
      await eventsClient.start();

      sut.startForCampagne(
        campagneId: CampagneIdentifier($value: 'campagne-1'),
        initialRevision: 1,
      );

      sseBody.add(
        utf8.encode(
          'event: campagneConfigChanged\ndata: {"id":"some-other-campagne","revision":9}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(rpgEntityService.calls, isEmpty);

      await sut.stop();
    });

    test(
        'characterConfigChanged SSE applies a JSON Patch onto the current character doc',
        () async {
      final rpgEntityService = _RecordingRpgEntityService(
        getCharacterRpgConfigSnapshotOverride: HRResponse.fromResult(
          const ConfigSnapshot(
            kind: 'patch',
            revision: 3,
            fromRevision: 2,
            patch: '[{"op":"replace","path":"/characterName","value":"Renamed"}]',
          ),
        ),
      );
      RpgCharacterConfiguration? applied;
      final baseCharacter = RpgCharacterConfiguration.getBaseConfiguration(
        RpgConfigurationModel.getBaseConfiguration(),
      );
      final sut = ConfigSyncSessionController(
        rpgEntityService: rpgEntityService,
        eventsClient: eventsClient,
        applyCampagneConfig: (_) {},
        readCampagneConfig: () => RpgConfigurationModel.getBaseConfiguration(),
        applyCharacterConfig: (c) => applied = c,
        readCharacterConfig: () => baseCharacter,
      );
      await eventsClient.start();

      final playerCharacterId = PlayerCharacterIdentifier($value: 'pc-1');
      sut.startForCharacter(
        playerCharacterId: playerCharacterId,
        initialRevision: 2,
      );

      sseBody.add(
        utf8.encode(
          'event: characterConfigChanged\ndata: {"id":"pc-1","revision":3}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(rpgEntityService.calls, ['getCharacterRpgConfigSnapshot:2']);
      expect(applied?.characterName, 'Renamed');

      await sut.stop();
    });

    test(
        'characterConfigChanged for a character other than "our own" GETs it and forwards to onRemoteCharacterConfig (DM path)',
        () async {
      final remoteCharacter = PlayerCharacter(
        id: PlayerCharacterIdentifier($value: 'pc-other'),
        playerUserId: UserIdentifier($value: 'user-other'),
        characterName: 'Sam',
        rpgCharacterConfiguration: jsonEncode(
          RpgCharacterConfiguration.getBaseConfiguration(null)
              .copyWith(characterName: 'Sam'),
        ),
      );
      final rpgEntityService = _RecordingRpgEntityService(
        getPlayerCharactersForCampagneOverride:
            HRResponse.fromResult([remoteCharacter]),
      );
      String? forwardedId;
      RpgCharacterConfiguration? forwardedConfig;
      final sut = ConfigSyncSessionController(
        rpgEntityService: rpgEntityService,
        eventsClient: eventsClient,
        applyCampagneConfig: (_) {},
        readCampagneConfig: () => RpgConfigurationModel.getBaseConfiguration(),
        applyCharacterConfig: (_) {},
        readCharacterConfig: () =>
            RpgCharacterConfiguration.getBaseConfiguration(null),
        onRemoteCharacterConfig: (id, config) {
          forwardedId = id;
          forwardedConfig = config;
        },
      );
      await eventsClient.start();

      // DM path: no startForCharacter, only startForCampagne.
      sut.startForCampagne(
        campagneId: CampagneIdentifier($value: 'campagne-1'),
        initialRevision: 1,
      );

      sseBody.add(
        utf8.encode(
          'event: characterConfigChanged\ndata: {"id":"pc-other","revision":9}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(rpgEntityService.calls,
          ['getPlayerCharactersForCampagne:campagne-1']);
      expect(forwardedId, 'pc-other');
      expect(forwardedConfig?.characterName, 'Sam');

      await sut.stop();
    });

    test(
        'characterConfigChanged for our own character does not call onRemoteCharacterConfig',
        () async {
      final rpgEntityService = _RecordingRpgEntityService(
        getCharacterRpgConfigSnapshotOverride: HRResponse.fromResult(
          ConfigSnapshot(
            kind: 'full',
            revision: 2,
            fullConfig: jsonEncode(
              RpgCharacterConfiguration.getBaseConfiguration(null),
            ),
          ),
        ),
      );
      var onRemoteCharacterConfigCalled = false;
      final sut = ConfigSyncSessionController(
        rpgEntityService: rpgEntityService,
        eventsClient: eventsClient,
        applyCampagneConfig: (_) {},
        readCampagneConfig: () => RpgConfigurationModel.getBaseConfiguration(),
        applyCharacterConfig: (_) {},
        readCharacterConfig: () =>
            RpgCharacterConfiguration.getBaseConfiguration(null),
        onRemoteCharacterConfig: (_, __) => onRemoteCharacterConfigCalled = true,
      );
      await eventsClient.start();

      sut.startForCharacter(
        playerCharacterId: PlayerCharacterIdentifier($value: 'pc-own'),
        initialRevision: 1,
      );

      sseBody.add(
        utf8.encode(
          'event: characterConfigChanged\ndata: {"id":"pc-own","revision":2}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(rpgEntityService.calls, ['getCharacterRpgConfigSnapshot:1']);
      expect(onRemoteCharacterConfigCalled, isFalse);

      await sut.stop();
    });

    test('does not GET a remote character config when no callback is set',
        () async {
      final rpgEntityService = _RecordingRpgEntityService();
      final sut = ConfigSyncSessionController(
        rpgEntityService: rpgEntityService,
        eventsClient: eventsClient,
        applyCampagneConfig: (_) {},
        readCampagneConfig: () => RpgConfigurationModel.getBaseConfiguration(),
        applyCharacterConfig: (_) {},
        readCharacterConfig: () =>
            RpgCharacterConfiguration.getBaseConfiguration(null),
      );
      await eventsClient.start();

      sut.startForCampagne(
        campagneId: CampagneIdentifier($value: 'campagne-1'),
        initialRevision: 1,
      );

      sseBody.add(
        utf8.encode(
          'event: characterConfigChanged\ndata: {"id":"pc-other","revision":9}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(rpgEntityService.calls, isEmpty);

      await sut.stop();
    });

    test('participantOnline SSE for the active campagne forwards the userId',
        () async {
      final rpgEntityService = _RecordingRpgEntityService();
      String? onlineUserId;
      final sut = ConfigSyncSessionController(
        rpgEntityService: rpgEntityService,
        eventsClient: eventsClient,
        applyCampagneConfig: (_) {},
        readCampagneConfig: () => RpgConfigurationModel.getBaseConfiguration(),
        applyCharacterConfig: (_) {},
        readCharacterConfig: () =>
            RpgCharacterConfiguration.getBaseConfiguration(null),
        onParticipantOnline: (userId) => onlineUserId = userId,
      );
      await eventsClient.start();

      sut.startForCampagne(
        campagneId: CampagneIdentifier($value: 'campagne-1'),
        initialRevision: 1,
      );

      sseBody.add(
        utf8.encode(
          'event: participantOnline\ndata: {"campagneId":"campagne-1","userId":"user-1"}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(onlineUserId, 'user-1');

      await sut.stop();
    });

    test(
        'participantOffline SSE for the active campagne forwards the userId',
        () async {
      final rpgEntityService = _RecordingRpgEntityService();
      String? offlineUserId;
      final sut = ConfigSyncSessionController(
        rpgEntityService: rpgEntityService,
        eventsClient: eventsClient,
        applyCampagneConfig: (_) {},
        readCampagneConfig: () => RpgConfigurationModel.getBaseConfiguration(),
        applyCharacterConfig: (_) {},
        readCharacterConfig: () =>
            RpgCharacterConfiguration.getBaseConfiguration(null),
        onParticipantOffline: (userId) => offlineUserId = userId,
      );
      await eventsClient.start();

      sut.startForCampagne(
        campagneId: CampagneIdentifier($value: 'campagne-1'),
        initialRevision: 1,
      );

      sseBody.add(
        utf8.encode(
          'event: participantOffline\ndata: {"campagneId":"campagne-1","userId":"user-1"}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(offlineUserId, 'user-1');

      await sut.stop();
    });

    test('ignores presence notifications for a different campagne', () async {
      final rpgEntityService = _RecordingRpgEntityService();
      var callbackInvoked = false;
      final sut = ConfigSyncSessionController(
        rpgEntityService: rpgEntityService,
        eventsClient: eventsClient,
        applyCampagneConfig: (_) {},
        readCampagneConfig: () => RpgConfigurationModel.getBaseConfiguration(),
        applyCharacterConfig: (_) {},
        readCharacterConfig: () =>
            RpgCharacterConfiguration.getBaseConfiguration(null),
        onParticipantOnline: (_) => callbackInvoked = true,
      );
      await eventsClient.start();

      sut.startForCampagne(
        campagneId: CampagneIdentifier($value: 'campagne-1'),
        initialRevision: 1,
      );

      sseBody.add(
        utf8.encode(
          'event: participantOnline\ndata: {"campagneId":"some-other-campagne","userId":"user-1"}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(callbackInvoked, isFalse);

      await sut.stop();
    });
  });
}
