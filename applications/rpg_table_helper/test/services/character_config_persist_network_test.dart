import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/save_rpg_character_configuration_to_storage_observer.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/navigation_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/server_communication_service.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:quest_keeper/services/snack_bar_service.dart';
import 'package:signalr_netcore/signalr_client.dart';

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
}

class _RecordingSnackBar extends ISnackBarService {
  _RecordingSnackBar() : super(isMock: true);
  final List<String> shownIds = [];

  @override
  void showSnackBar({required SnackBar snack, required String uniqueId}) {
    shownIds.add(uniqueId);
  }

  @override
  void hideSnackBar(String uniqueId) {}
}

class _ControllableComm extends IServerCommunicationService {
  _ControllableComm({
    required WidgetRef widgetRef,
    this.hubSucceeds = true,
  }) : super(
            isMock: true,
            apiConnectorService: _FakeApi(),
            widgetRef: widgetRef);

  bool hubSucceeds;
  final List<String> invokes = [];
  final List<String> clearedCharacterQueues = [];

  @override
  Future startConnection() async {}

  @override
  Future stopConnection() async {}

  @override
  HubConnectionState? get hubConnectionState => hubSucceeds
      ? HubConnectionState.Connected
      : HubConnectionState.Disconnected;

  @override
  Future<void> ensureConnectionReadyForSession() async {}

  @override
  void registerCallbackWithoutParameters(
      {required void Function() function, required String functionName}) {}

  @override
  void completeFunctionRegistration() {}

  @override
  void registerCallbackSingleString(
      {required void Function(String parameter) function,
      required String functionName}) {}

  @override
  void registerCallbackTwoStrings(
      {required void Function(String param1, String param2) function,
      required String functionName}) {}

  @override
  void registerCallbackSingleDateTime(
      {required void Function(DateTime parameter) function,
      required String functionName}) {}

  @override
  void registerCallbackSingleDateTimeAndOneString(
      {required void Function(DateTime param1, String param2) function,
      required String functionName}) {}

  @override
  void registerCallbackThreeStrings(
      {required void Function(String param1, String param2, String param3)
              function,
      required String functionName}) {}

  @override
  void registerCallbackFourStrings(
      {required void Function(
              String param1, String param2, String param3, String param4)
          function,
      required String functionName}) {}

  @override
  Future executeServerFunction(String functionName,
      {List<Object>? args, int maxInvokeRetries = 1}) async {}

  @override
  Future<bool> executeCriticalServerFunction(String functionName,
      {List<Object>? args, int maxInvokeRetries = 3}) async {
    invokes.add(functionName);
    return hubSucceeds;
  }

  @override
  void seedRpgConfigSliceCacheFromFull(RpgConfigurationModel config) {}

  @override
  Future<void> flushPendingCampagneConfig({String? campagneId}) async {}

  @override
  Future<void> drainHubInvokeQueue() async {}

  @override
  void clearQueuedCampagneConfigInvokes(String campagneId) {}

  @override
  void clearQueuedCharacterConfigInvokes(String playerCharacterId) {
    clearedCharacterQueues.add(playerCharacterId);
  }

  @override
  String? get lastHubInvokeError =>
      hubSucceeds ? null : 'simulated hub failure';

  @override
  int get pendingHubInvokeCount => hubSucceeds ? 0 : invokes.length;
}

class _CaptureSendMethods extends ServerMethodsService {
  _CaptureSendMethods({
    required super.serverCommunicationService,
    required super.navigationService,
    required super.widgetRef,
  });

  final List<String> sentPlayerIds = [];

  @override
  Future sendUpdatedRpgCharacterConfig(
      {required RpgCharacterConfiguration charConfig,
      required String playercharacterid}) async {
    sentPlayerIds.add(playercharacterid);
  }
}

class _CountingRpgEntity extends MockRpgEntityService {
  _CountingRpgEntity({
    required super.apiConnectorService,
    required this.restResult,
    required this.restCalls,
  }) : super(updatePlayerCharacterRpgConfigurationOverride: restResult);

  final HRResponse<bool> restResult;
  final List<String> restCalls;

  @override
  Future<HRResponse<bool>> updatePlayerCharacterRpgConfiguration({
    required PlayerCharacterIdentifier playerCharacterId,
    required String rpgCharacterConfigurationJson,
  }) async {
    restCalls.add(playerCharacterId.$value ?? '');
    return restResult;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('character config persist — network availability', () {
    testWidgets('observer sends when disconnected but in session',
        (tester) async {
      late WidgetRef ref;
      late _CaptureSendMethods capture;

      await tester.pumpWidget(
        ProviderScope(
          observers: [SaveRpgCharacterConfigurationToStorageObserver()],
          child: Consumer(builder: (context, r, _) {
            ref = r;
            return const SizedBox.shrink();
          }),
        ),
      );

      final fakeComm = _ControllableComm(widgetRef: ref, hubSucceeds: false);
      capture = _CaptureSendMethods(
        serverCommunicationService: fakeComm,
        navigationService: _FakeNav(),
        widgetRef: ref,
      );
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<IServerMethodsService>(capture);

      ref.read(connectionDetailsProvider.notifier).updateConfiguration(
            ConnectionDetails.defaultValue().copyWith(
              isDm: false,
              isInSession: true,
              isConnected: false,
              playerCharacterId: 'player-1',
            ),
          );

      final base = RpgCharacterConfiguration.getBaseConfiguration(null);
      ref.read(rpgCharacterConfigurationProvider.notifier).updateConfiguration(
            base.copyWith.characterName('OfflineEdit'),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(capture.sentPlayerIds, ['player-1']);
    });

    testWidgets('observer does not send when not in session', (tester) async {
      late WidgetRef ref;
      late _CaptureSendMethods capture;

      await tester.pumpWidget(
        ProviderScope(
          observers: [SaveRpgCharacterConfigurationToStorageObserver()],
          child: Consumer(builder: (context, r, _) {
            ref = r;
            return const SizedBox.shrink();
          }),
        ),
      );

      final fakeComm = _ControllableComm(widgetRef: ref);
      capture = _CaptureSendMethods(
        serverCommunicationService: fakeComm,
        navigationService: _FakeNav(),
        widgetRef: ref,
      );
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<IServerMethodsService>(capture);

      ref.read(connectionDetailsProvider.notifier).updateConfiguration(
            ConnectionDetails.defaultValue().copyWith(
              isDm: false,
              isInSession: false,
              isConnected: true,
              playerCharacterId: 'player-1',
            ),
          );

      ref.read(rpgCharacterConfigurationProvider.notifier).updateConfiguration(
            RpgCharacterConfiguration.getBaseConfiguration(null)
                .copyWith
                .characterName('NotInSession'),
          );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(capture.sentPlayerIds, isEmpty);
    });

    testWidgets('hub online: character flush persists via SignalR',
        (tester) async {
      late WidgetRef ref;
      await tester.pumpWidget(ProviderScope(
        child: Consumer(builder: (context, r, _) {
          ref = r;
          return const MaterialApp(home: SizedBox.shrink());
        }),
      ));

      final fakeComm = _ControllableComm(widgetRef: ref, hubSucceeds: true);
      final svc = ServerMethodsService(
        serverCommunicationService: fakeComm,
        navigationService: _FakeNav(),
        widgetRef: ref,
      );

      final cfg = RpgCharacterConfiguration.getBaseConfiguration(null)
          .copyWith
          .characterName('Online');
      await svc.sendUpdatedRpgCharacterConfig(
          charConfig: cfg, playercharacterid: 'p-online');
      await tester.pump(const Duration(milliseconds: 900));

      expect(
        fakeComm.invokes.where((e) =>
            e == 'SendUpdatedRpgCharacterConfigToDm' ||
            e == 'SendUpdatedRpgCharacterConfigToDmV3'),
        isNotEmpty,
      );
    });

    testWidgets('hub down + REST ok: persists via REST and clears hub queue',
        (tester) async {
      late WidgetRef ref;
      await tester.pumpWidget(ProviderScope(
        child: Consumer(builder: (context, r, _) {
          ref = r;
          return const MaterialApp(home: SizedBox.shrink());
        }),
      ));

      final fakeComm = _ControllableComm(widgetRef: ref, hubSucceeds: false);
      final restCalls = <String>[];
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<IRpgEntityService>(
          _CountingRpgEntity(
            apiConnectorService: _FakeApi(),
            restResult: HRResponse.fromResult(true),
            restCalls: restCalls,
          ),
        );

      final svc = ServerMethodsService(
        serverCommunicationService: fakeComm,
        navigationService: _FakeNav(),
        widgetRef: ref,
      );

      final cfg = RpgCharacterConfiguration.getBaseConfiguration(null)
          .copyWith
          .characterName('RestFallback');
      await svc.sendUpdatedRpgCharacterConfig(
          charConfig: cfg, playercharacterid: 'p-rest');
      await tester.pump(const Duration(milliseconds: 900));

      expect(fakeComm.invokes, isNotEmpty);
      expect(restCalls, contains('p-rest'));
      expect(fakeComm.clearedCharacterQueues, contains('p-rest'));
    });

    testWidgets('hub down + REST fail: user is informed nothing was saved',
        (tester) async {
      late WidgetRef ref;
      final snack = _RecordingSnackBar();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: ProviderScope(
            child: Consumer(builder: (context, r, _) {
              ref = r;
              return const SizedBox.shrink();
            }),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fakeComm = _ControllableComm(widgetRef: ref, hubSucceeds: false);
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<IRpgEntityService>(
          _CountingRpgEntity(
            apiConnectorService: _FakeApi(),
            restResult: HRResponse.error(
              'offline',
              'test-rest-fail',
              statusCode: 503,
            ),
            restCalls: [],
          ),
        )
        ..registerSingleton<ISnackBarService>(snack);

      final svc = ServerMethodsService(
        serverCommunicationService: fakeComm,
        navigationService: _FakeNav(),
        widgetRef: ref,
      );

      final cfg = RpgCharacterConfiguration.getBaseConfiguration(null)
          .copyWith
          .characterName('TotalFail');
      await svc.sendUpdatedRpgCharacterConfig(
          charConfig: cfg, playercharacterid: 'p-fail');
      await tester.pump(const Duration(milliseconds: 900));

      expect(
        snack.shownIds.any((id) => id.contains('characterConfigSaveFailed')),
        isTrue,
        reason: 'user must be informed when nothing was saved',
      );
    });

    testWidgets('failed flush stays dirty and retries after hub recovers',
        (tester) async {
      late WidgetRef ref;
      await tester.pumpWidget(ProviderScope(
        child: Consumer(builder: (context, r, _) {
          ref = r;
          return const MaterialApp(home: SizedBox.shrink());
        }),
      ));

      final fakeComm = _ControllableComm(widgetRef: ref, hubSucceeds: false);
      DependencyProvider.getIt = GetIt.asNewInstance()
        ..registerSingleton<IRpgEntityService>(
          _CountingRpgEntity(
            apiConnectorService: _FakeApi(),
            restResult: HRResponse.error(
              'offline',
              'test-rest-fail',
              statusCode: 503,
            ),
            restCalls: [],
          ),
        )
        ..registerSingleton<ISnackBarService>(_RecordingSnackBar());

      final svc = ServerMethodsService(
        serverCommunicationService: fakeComm,
        navigationService: _FakeNav(),
        widgetRef: ref,
      );

      final cfg = RpgCharacterConfiguration.getBaseConfiguration(null)
          .copyWith
          .characterName('RetryMe');
      await svc.sendUpdatedRpgCharacterConfig(
          charConfig: cfg, playercharacterid: 'p-retry');
      await tester.pump(const Duration(milliseconds: 900));
      final invokesAfterFail = fakeComm.invokes.length;
      expect(invokesAfterFail, greaterThan(0));

      fakeComm.hubSucceeds = true;
      await svc.flushPendingCharacterConfig(playerCharacterId: 'p-retry');
      await tester.pump();

      expect(fakeComm.invokes.length, greaterThan(invokesAfterFail));
    });
  });
}
