import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/config_sync/config_sync_models.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/navigation_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/server_methods_service.dart';

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

  final svc = ServerMethodsService(
    navigationService: _FakeNav(),
    widgetRef: ref,
  );

  final rpgEntity =
      _RecordingRpgEntityForSessionCommands(apiConnectorService: _FakeApi());
  DependencyProvider.getIt = GetIt.asNewInstance()
    ..registerSingleton<IRpgEntityService>(rpgEntity);

  return (ref: ref, svc: svc, rpgEntity: rpgEntity);
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
  });
}
