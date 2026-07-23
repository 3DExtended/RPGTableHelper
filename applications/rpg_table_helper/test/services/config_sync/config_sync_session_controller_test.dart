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
}

class _RecordingRpgEntityService extends MockRpgEntityService {
  _RecordingRpgEntityService({
    super.saveCampagneRpgConfigOverride,
    super.getCampagneRpgConfigSnapshotOverride,
    super.saveCharacterRpgConfigOverride,
    super.getCharacterRpgConfigSnapshotOverride,
  }) : super(apiConnectorService: _FakeApi());

  final List<String> calls = [];

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
      sut.notifyLocalCampagneEdit(edited);
      await Future<void>.delayed(const Duration(milliseconds: 600));

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
  });
}
