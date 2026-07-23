import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/config_sync/config_sync_models.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/navigation_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/server_communication_service.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
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

class _NoopComm extends IServerCommunicationService {
  _NoopComm({required WidgetRef widgetRef})
      : super(isMock: true, apiConnectorService: _FakeApi(), widgetRef: widgetRef);

  final List<String> invokes = [];

  @override
  Future startConnection() async {}

  @override
  Future stopConnection() async {}

  @override
  HubConnectionState? get hubConnectionState => null;

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
    return true;
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
  void clearQueuedCharacterConfigInvokes(String playerCharacterId) {}

  @override
  String? get lastHubInvokeError => null;

  @override
  int get pendingHubInvokeCount => 0;
}

class _RecordingRpgEntityForSessionCommands extends MockRpgEntityService {
  _RecordingRpgEntityForSessionCommands({required super.apiConnectorService});

  final List<(String campagneId, FightSequence fightSequence)>
      askPlayersForRollsCalls = [];
  final List<(String playerCharacterId, FightSequence fightSequence)>
      sendFightSequenceRollsToDmCalls = [];
  final List<(String playerCharacterId, List<RpgCharacterOwnedItemPair> items)>
      grantItemsToCharacterCalls = [];

  @override
  Future<HRResponse<bool>> askPlayersForRolls({
    required CampagneIdentifier campagneId,
    required FightSequence fightSequence,
  }) async {
    askPlayersForRollsCalls.add((campagneId.$value!, fightSequence));
    return HRResponse.fromResult(true);
  }

  @override
  Future<HRResponse<bool>> sendFightSequenceRollsToDm({
    required PlayerCharacterIdentifier playerCharacterId,
    required FightSequence fightSequence,
  }) async {
    sendFightSequenceRollsToDmCalls
        .add((playerCharacterId.$value!, fightSequence));
    return HRResponse.fromResult(true);
  }

  @override
  Future<HRResponse<ConfigWriteResult>> grantItemsToCharacter({
    required PlayerCharacterIdentifier playerCharacterId,
    required List<RpgCharacterOwnedItemPair> items,
  }) async {
    grantItemsToCharacterCalls.add((playerCharacterId.$value!, items));
    return HRResponse.fromResult(const ConfigWriteResult(revision: 2));
  }
}

Future<
    ({
      WidgetRef ref,
      _NoopComm comm,
      ServerMethodsService svc,
      _RecordingRpgEntityForSessionCommands rpgEntity,
    })> _setup(WidgetTester tester) async {
  late WidgetRef ref;
  await tester.pumpWidget(ProviderScope(
    child: Consumer(builder: (context, r, _) {
      ref = r;
      return const MaterialApp(home: SizedBox.shrink());
    }),
  ));

  final comm = _NoopComm(widgetRef: ref);
  final svc = ServerMethodsService(
    serverCommunicationService: comm,
    navigationService: _FakeNav(),
    widgetRef: ref,
  );

  final rpgEntity =
      _RecordingRpgEntityForSessionCommands(apiConnectorService: _FakeApi());
  DependencyProvider.getIt = GetIt.asNewInstance()
    ..registerSingleton<IRpgEntityService>(rpgEntity);

  return (ref: ref, comm: comm, svc: svc, rpgEntity: rpgEntity);
}

void main() {
  testWidgets('askPlayersForRolls calls the REST session command endpoint',
      (tester) async {
    final h = await _setup(tester);

    final fightSequence = FightSequence(
      fightUuid: 'fight-1',
      sequence: [('pc-1', 'Frodo', 12)],
    );

    await h.svc.askPlayersForRolls(
      campagneId: 'campagne-1',
      fightSequence: fightSequence,
    );

    expect(h.rpgEntity.askPlayersForRollsCalls, hasLength(1));
    expect(h.rpgEntity.askPlayersForRollsCalls.single.$1, 'campagne-1');
    expect(
      h.rpgEntity.askPlayersForRollsCalls.single.$2.fightUuid,
      'fight-1',
    );
    expect(h.comm.invokes, isNot(contains('AskPlayersForRolls')));
  });

  testWidgets(
      'sendFightSequenceRollsToDm calls the REST session command endpoint',
      (tester) async {
    final h = await _setup(tester);

    final fightSequence = FightSequence(
      fightUuid: 'fight-1',
      sequence: [('pc-1', 'Frodo', 12)],
    );

    await h.svc.sendFightSequenceRollsToDm(
      playerId: 'pc-1',
      fightSequence: fightSequence,
    );

    expect(h.rpgEntity.sendFightSequenceRollsToDmCalls, hasLength(1));
    expect(h.rpgEntity.sendFightSequenceRollsToDmCalls.single.$1, 'pc-1');
    expect(h.comm.invokes, isNot(contains('SendFightSequenceRollsToDm')));
  });

  testWidgets(
      'sendGrantedItemsToPlayers calls the REST grant-items endpoint once per player',
      (tester) async {
    final h = await _setup(tester);

    final grantedItems = [
      GrantedItemsForPlayer(
        characterName: 'Frodo',
        playerId: 'pc-1',
        grantedItems: [
          RpgCharacterOwnedItemPair(itemUuid: 'item-1', amount: 2),
        ],
      ),
      GrantedItemsForPlayer(
        characterName: 'Gandalf',
        playerId: 'pc-2',
        grantedItems: [
          RpgCharacterOwnedItemPair(itemUuid: 'item-2', amount: 1),
        ],
      ),
    ];

    await h.svc.sendGrantedItemsToPlayers(
      campagneId: 'campagne-1',
      grantedItems: grantedItems,
    );

    expect(h.rpgEntity.grantItemsToCharacterCalls, hasLength(2));
    expect(
      h.rpgEntity.grantItemsToCharacterCalls.map((c) => c.$1),
      containsAll(['pc-1', 'pc-2']),
    );
    expect(h.comm.invokes, isNot(contains('SendGrantedItemsToPlayers')));
  });
}
