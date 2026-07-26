import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/config_sync/config_sync_session_controller.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/navigation_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

class _FakeNav extends INavigationService {
  _FakeNav() : super(isMock: true);

  @override
  TabItem getCurrentTabItem() => TabItem.character;

  @override
  void setCurrentTabItem(TabItem value) {}

  @override
  Map<TabItem, GlobalKey<NavigatorState>> getNavigationKeys() => {
        TabItem.character: const GlobalObjectKey<NavigatorState>('character'),
      };
}

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

class _RecordingRpgEntity extends MockRpgEntityService {
  _RecordingRpgEntity({required super.apiConnectorService});

  final List<String> legacyCampagneCalls = [];
  final List<String> legacyCharacterCalls = [];

  @override
  Future<HRResponse<bool>> updateCampagneRpgConfiguration({
    required CampagneIdentifier campagneId,
    required String rpgConfigurationJson,
  }) async {
    legacyCampagneCalls.add(campagneId.$value!);
    return HRResponse.fromResult(true);
  }

  @override
  Future<HRResponse<bool>> updatePlayerCharacterRpgConfiguration({
    required PlayerCharacterIdentifier playerCharacterId,
    required String rpgCharacterConfigurationJson,
  }) async {
    legacyCharacterCalls.add(playerCharacterId.$value!);
    return HRResponse.fromResult(true);
  }
}

/// Records delegation without opening the SSE stream (no `startForX`, so no
/// `EventsClient` subscription is created).
class _SpyConfigSyncSessionController extends ConfigSyncSessionController {
  _SpyConfigSyncSessionController({
    required super.rpgEntityService,
    required super.eventsClient,
  }) : super(
          applyCampagneConfig: (_) {},
          readCampagneConfig: RpgConfigurationModel.getBaseConfiguration,
          applyCharacterConfig: (_) {},
          readCharacterConfig: () =>
              RpgCharacterConfiguration.getBaseConfiguration(null),
        );

  final List<String> campagneEdits = [];
  final List<String> characterEdits = [];

  @override
  Future<void> notifyLocalCampagneEdit(RpgConfigurationModel config) async {
    campagneEdits.add(config.rpgName);
  }

  @override
  Future<void> notifyLocalCharacterEdit(
      RpgCharacterConfiguration config) async {
    characterEdits.add(config.characterName);
  }
}

EventsClient _silentEventsClient() => EventsClient(
      getJwt: () async => 'jwt',
      openStream: ({required uri, required jwt}) async =>
          http.ByteStream(const Stream.empty()),
      sleep: (_) async {},
    );

void main() {
  group('ServerMethodsService config write path (sse-08)', () {
    testWidgets(
        'routes campagne + character edits through the active ConfigSync controller',
        (tester) async {
      late WidgetRef ref;
      await tester.pumpWidget(ProviderScope(
        child: Consumer(builder: (context, r, _) {
          ref = r;
          return const MaterialApp(home: SizedBox.shrink());
        }),
      ));

      final rpgEntity = _RecordingRpgEntity(apiConnectorService: _FakeApi());
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<IRpgEntityService>(rpgEntity);

      final spyController = _SpyConfigSyncSessionController(
        rpgEntityService: rpgEntity,
        eventsClient: _silentEventsClient(),
      );

      final svc = ServerMethodsService(
        navigationService: _FakeNav(),
        widgetRef: ref,
      );
      svc.activeConfigSyncSessionController = spyController;

      await svc.sendUpdatedRpgConfig(
        rpgConfig: RpgConfigurationModel.getBaseConfiguration()
            .copyWith(rpgName: 'Edited'),
        campagneId: 'campagne-1',
      );
      await svc.sendUpdatedRpgCharacterConfig(
        charConfig: RpgCharacterConfiguration.getBaseConfiguration(null)
            .copyWith(characterName: 'EditedChar'),
        playercharacterid: 'pc-1',
      );

      expect(spyController.campagneEdits, contains('Edited'));
      expect(spyController.characterEdits, contains('EditedChar'));
      // Must NOT fall back to the legacy full PUT while a controller is active.
      expect(rpgEntity.legacyCampagneCalls, isEmpty);
      expect(rpgEntity.legacyCharacterCalls, isEmpty);
    });

    testWidgets(
        'falls back to direct REST PUT when no ConfigSync controller is active',
        (tester) async {
      late WidgetRef ref;
      await tester.pumpWidget(ProviderScope(
        child: Consumer(builder: (context, r, _) {
          ref = r;
          return const MaterialApp(home: SizedBox.shrink());
        }),
      ));

      final rpgEntity = _RecordingRpgEntity(apiConnectorService: _FakeApi());
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<IRpgEntityService>(rpgEntity);

      final svc = ServerMethodsService(
        navigationService: _FakeNav(),
        widgetRef: ref,
      );

      await svc.sendUpdatedRpgConfig(
        rpgConfig: RpgConfigurationModel.getBaseConfiguration(),
        campagneId: 'campagne-2',
      );
      await svc.sendUpdatedRpgCharacterConfig(
        charConfig: RpgCharacterConfiguration.getBaseConfiguration(null),
        playercharacterid: 'pc-2',
      );

      expect(rpgEntity.legacyCampagneCalls, contains('campagne-2'));
      expect(rpgEntity.legacyCharacterCalls, contains('pc-2'));
    });
  });
}
