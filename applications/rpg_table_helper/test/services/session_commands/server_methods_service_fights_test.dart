import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/current_fight_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/fight_state.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/backend_capabilities_service.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/fights/fight_api_service.dart';
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

class _RecordingRpgEntity extends MockRpgEntityService {
  _RecordingRpgEntity() : super(apiConnectorService: _FakeApi());

  final List<FightSequence> askPlayersForRollsCalls = [];
  final List<FightSequence> sendFightSequenceRollsToDmCalls = [];

  @override
  Future<HRResponse<bool>> askPlayersForRolls({
    required CampagneIdentifier campagneId,
    required FightSequence fightSequence,
  }) async {
    askPlayersForRollsCalls.add(fightSequence);
    return HRResponse.fromResult(true);
  }

  @override
  Future<HRResponse<bool>> sendFightSequenceRollsToDm({
    required PlayerCharacterIdentifier playerCharacterId,
    required FightSequence fightSequence,
  }) async {
    sendFightSequenceRollsToDmCalls.add(fightSequence);
    return HRResponse.fromResult(true);
  }
}

/// The server's fight, kept in memory; every call is recorded.
class _FakeFightApi extends IFightApiService {
  _FakeFightApi() : super(isMock: true);

  FightState? fight;
  int? failWith;
  final List<String> calls = [];
  final List<List<FightStartParticipant>> starts = [];
  final List<List<(String, int)>> submittedRolls = [];
  final List<List<String>> reorders = [];

  HRResponse<FightState> _answer(String call) {
    calls.add(call);
    if (failWith != null) {
      return HRResponse.error('failed', 'fake', statusCode: failWith);
    }
    return HRResponse.fromResult(fight!);
  }

  @override
  Future<HRResponse<FightState?>> getCurrentFight(
      {required String campagneId}) async {
    calls.add('current');
    return HRResponse.fromResult(fight);
  }

  @override
  Future<HRResponse<FightState>> startFight({
    required String campagneId,
    required List<FightStartParticipant> participants,
  }) async {
    starts.add(participants);
    return _answer('start');
  }

  @override
  Future<HRResponse<FightState>> submitRolls({
    required String fightId,
    required List<(String, int)> rolls,
  }) async {
    submittedRolls.add(rolls);
    return _answer('rolls');
  }

  @override
  Future<HRResponse<FightState>> addEnemies({
    required String fightId,
    required List<(String, int)> enemies,
  }) async =>
      _answer('enemies');

  @override
  Future<HRResponse<FightState>> reorder({
    required String fightId,
    required List<String> participantIds,
  }) async {
    reorders.add(participantIds);
    return _answer('order');
  }

  @override
  Future<HRResponse<FightState>> removeParticipant({
    required String fightId,
    required String participantId,
  }) async =>
      _answer('remove $participantId');

  @override
  Future<HRResponse<FightState>> endFight({required String fightId}) async =>
      _answer('end');
}

FightParticipantState _participant(
  String id,
  String name, {
  String? uuid,
  String? playerCharacterId,
  FightParticipantKind kind = FightParticipantKind.character,
  int? roll,
  int? position,
}) =>
    FightParticipantState(
      id: id,
      kind: kind,
      characterUuid: uuid,
      playerCharacterId: playerCharacterId,
      name: name,
      roll: roll,
      position: position,
      isPending: roll == null && kind != FightParticipantKind.enemy,
    );

FightState _fight(List<FightParticipantState> participants,
        {String id = 'fight-1', bool isOpen = true}) =>
    FightState(
      id: id,
      campagneId: 'camp-1',
      isOpen: isOpen,
      isDmView: true,
      revision: 1,
      participants: participants,
    );

class _Harness {
  _Harness(this.ref, this.svc, this.fightApi, this.rpgEntity, this.asked);

  final WidgetRef ref;
  final ServerMethodsService svc;
  final _FakeFightApi fightApi;
  final _RecordingRpgEntity rpgEntity;

  /// Names the player was asked to roll for, in order.
  final List<String> asked;

  /// Roll the player enters per name; a missing name dismisses the prompt.
  final Map<String, int> rolls = {};

  /// Names whose prompt stays open until the app no longer needs the roll.
  final Set<String> keepOpen = {};

  /// Names whose prompt the app closed because the roll was no longer needed.
  final List<String> closed = [];

  FightState? get currentFight => ref.read(currentFightProvider);

  FightSequence? get fightSequence =>
      ref.read(connectionDetailsProvider).requireValue.fightSequence;
}

Future<_Harness> _setup(
  WidgetTester tester, {
  required bool isDm,
  bool backendKeepsFights = true,
}) async {
  late WidgetRef ref;
  await tester.pumpWidget(ProviderScope(
    child: Consumer(builder: (context, r, _) {
      ref = r;
      return const MaterialApp(home: SizedBox.shrink());
    }),
  ));

  final asked = <String>[];
  late _Harness harness;
  final svc = ServerMethodsService(
    navigationService: _FakeNav(),
    widgetRef: ref,
    initiativeRollPrompt: (name, hint, noLongerNeeded) async {
      asked.add(name);
      if (harness.keepOpen.contains(name)) {
        await noLongerNeeded;
        harness.closed.add(name);
        return null;
      }
      return harness.rolls[name];
    },
  );
  final fightApi = _FakeFightApi();
  final rpgEntity = _RecordingRpgEntity();
  DependencyProvider.getIt = GetIt.asNewInstance()
    ..registerSingleton<IRpgEntityService>(rpgEntity)
    ..registerSingleton<IFightApiService>(fightApi)
    ..registerSingleton<IBackendCapabilitiesService>(
      MockBackendCapabilitiesService(
        apiConnectorService: _FakeApi(),
        capabilitiesOverride: {
          ...kBaselineBackendCapabilities,
          if (backendKeepsFights) BackendCapability.persistedFights,
        },
      ),
    );

  final rpgConfig = RpgConfigurationModel.getBaseConfiguration();
  ref.read(rpgConfigurationProvider.notifier).updateConfiguration(rpgConfig);
  ref.read(rpgCharacterConfigurationProvider.notifier).updateConfiguration(
      RpgCharacterConfiguration.getBaseConfiguration(rpgConfig)
          .copyWith(uuid: 'aria', characterName: 'Aria'));
  ref.read(connectionDetailsProvider.notifier).updateConfiguration(
      ConnectionDetails.defaultValue().copyWith(
          isDm: isDm,
          isInSession: true,
          campagneId: 'camp-1',
          playerCharacterId: isDm ? null : 'pc-aria'));

  harness = _Harness(ref, svc, fightApi, rpgEntity, asked);
  return harness;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
}

const _participants = [
  FightStartParticipant(
      characterUuid: 'aria', playerCharacterId: 'pc-aria', name: 'Aria'),
  FightStartParticipant(
      characterUuid: 'borin', playerCharacterId: 'pc-borin', name: 'Borin'),
];

void main() {
  group('DM', () {
    testWidgets('starts the fight on the server and waits for every roll',
        (tester) async {
      final h = await _setup(tester, isDm: true);
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria', uuid: 'aria'),
        _participant('p-borin', 'Borin', uuid: 'borin'),
      ]);

      final response = await h.svc
          .startFight(campagneId: 'camp-1', participants: _participants);

      expect(response.isSuccessful, isTrue);
      expect(h.fightApi.starts.single.map((p) => p.playerCharacterId),
          ['pc-aria', 'pc-borin']);
      expect(h.rpgEntity.askPlayersForRollsCalls, isEmpty);
      expect(h.currentFight!.pending.map((p) => p.name), ['Aria', 'Borin']);
      expect(h.fightSequence!.fightUuid, 'fight-1');
      expect(h.fightSequence!.sequence, isEmpty);
    });

    testWidgets('uses the old flow when the backend does not keep fights',
        (tester) async {
      final h = await _setup(tester, isDm: true, backendKeepsFights: false);

      final response = await h.svc
          .startFight(campagneId: 'camp-1', participants: _participants);

      expect(response.isSuccessful, isTrue);
      expect(h.fightApi.starts, isEmpty);
      expect(h.currentFight, isNull);
      final asked = h.rpgEntity.askPlayersForRollsCalls.single;
      expect(asked.fightUuid, h.fightSequence!.fightUuid);
      expect(asked.sequence, [('aria', 'Aria', -1), ('borin', 'Borin', -1)]);
    });

    testWidgets('falls back to the old flow when /Fight is missing (404)',
        (tester) async {
      final h = await _setup(tester, isDm: true);
      h.fightApi.failWith = 404;

      final response = await h.svc
          .startFight(campagneId: 'camp-1', participants: _participants);

      expect(response.isSuccessful, isTrue);
      expect(h.rpgEntity.askPlayersForRollsCalls, hasLength(1));
      expect(h.currentFight, isNull);
    });

    testWidgets('reports other errors and starts nothing', (tester) async {
      final h = await _setup(tester, isDm: true);
      h.fightApi.failWith = 400;

      final response = await h.svc
          .startFight(campagneId: 'camp-1', participants: _participants);

      expect(response.isSuccessful, isFalse);
      expect(response.statusCode, 400);
      expect(h.rpgEntity.askPlayersForRollsCalls, isEmpty);
      expect(h.fightSequence, isNull);
    });

    testWidgets('reloads the fight when a player rolled', (tester) async {
      final h = await _setup(tester, isDm: true);
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria', uuid: 'aria'),
      ]);
      await h.svc.startFight(campagneId: 'camp-1', participants: _participants);
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria', uuid: 'aria', roll: 15, position: 0),
      ]);

      h.svc.fightUpdated('FIGHT-1');
      await _settle(tester);

      expect(h.fightSequence!.sequence, [('aria', 'Aria', 15)]);
      expect(h.currentFight!.pending, isEmpty);
    });

    testWidgets('ignores the old roll event for a stored fight',
        (tester) async {
      final h = await _setup(tester, isDm: true);
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria', uuid: 'aria'),
      ]);
      await h.svc.startFight(campagneId: 'camp-1', participants: _participants);

      h.svc.dmReceivedFightSequenceAnswer(jsonEncode(FightSequence(
          fightUuid: 'fight-1', sequence: [('aria', 'Aria', 15)])));

      expect(h.fightSequence!.sequence, isEmpty);
    });

    testWidgets('moves an entry by sending the new order', (tester) async {
      final h = await _setup(tester, isDm: true);
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria', uuid: 'aria', roll: 18, position: 0),
        _participant('p-gob', 'Goblin',
            kind: FightParticipantKind.enemy, roll: 14, position: 1),
      ]);
      await h.svc.catchUpOnFight();

      await h.svc.moveFightEntry(index: 0, offset: 1);
      final ignored = await h.svc.moveFightEntry(index: 0, offset: -1);

      expect(h.fightApi.reorders, [
        ['p-gob', 'p-aria'],
      ]);
      expect(ignored.result, isFalse);
    });

    testWidgets('reloads the fight when the order was outdated (409)',
        (tester) async {
      final h = await _setup(tester, isDm: true);
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria', uuid: 'aria', roll: 18, position: 0),
        _participant('p-gob', 'Goblin',
            kind: FightParticipantKind.enemy, roll: 14, position: 1),
      ]);
      await h.svc.catchUpOnFight();
      h.fightApi.calls.clear();
      h.fightApi.failWith = 409;

      final response = await h.svc.moveFightEntry(index: 0, offset: 1);

      expect(response.statusCode, 409);
      expect(h.fightApi.calls, ['order', 'current']);
    });

    testWidgets('removes entries and pending participants on the server',
        (tester) async {
      final h = await _setup(tester, isDm: true);
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria', uuid: 'aria', roll: 18, position: 0),
        _participant('p-borin', 'Borin', uuid: 'borin'),
      ]);
      await h.svc.catchUpOnFight();
      h.fightApi.calls.clear();

      await h.svc.removeFightEntry(index: 0);
      await h.svc.removePendingFightParticipant('p-borin');

      expect(h.fightApi.calls, ['remove p-aria', 'remove p-borin']);
    });

    testWidgets('ends the fight', (tester) async {
      final h = await _setup(tester, isDm: true);
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria', uuid: 'aria'),
      ]);
      await h.svc.catchUpOnFight();
      h.fightApi.fight = _fight([], isOpen: false);

      final response = await h.svc.endFight();

      expect(response.isSuccessful, isTrue);
      expect(h.fightApi.calls.last, 'end');
      expect(h.currentFight, isNull);
      expect(h.fightSequence, isNull);
    });

    testWidgets('clears a fight that ended elsewhere', (tester) async {
      final h = await _setup(tester, isDm: true);
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria', uuid: 'aria'),
      ]);
      await h.svc.catchUpOnFight();

      h.svc.fightEnded('fight-1');

      expect(h.currentFight, isNull);
      expect(h.fightSequence, isNull);
    });

    testWidgets('adds enemies locally in the old flow', (tester) async {
      final h = await _setup(tester, isDm: true, backendKeepsFights: false);
      await h.svc.startFight(campagneId: 'camp-1', participants: const []);
      h.svc.dmReceivedFightSequenceAnswer(jsonEncode(FightSequence(
          fightUuid: h.fightSequence!.fightUuid,
          sequence: [('aria', 'Aria', 12)])));

      await h.svc.addEnemiesToFight(const [('Goblin', 15), ('Rat', 3)]);

      expect(h.fightSequence!.sequence, [
        (null, 'Goblin', 15),
        ('aria', 'Aria', 12),
        (null, 'Rat', 3),
      ]);
    });
  });

  group('player', () {
    testWidgets('rolls for own pending characters when asked', (tester) async {
      final h = await _setup(tester, isDm: false);
      h.fightApi.fight = _fight([]);
      h.rolls['Aria'] = 17;
      h.rolls['Fang'] = 9;

      h.svc.initiativeRequested(InitiativeRequest(
        fightId: 'fight-1',
        campagneId: 'CAMP-1',
        participants: [
          _participant('p-aria', 'Aria',
              uuid: 'aria', playerCharacterId: 'pc-aria'),
          _participant('p-fang', 'Fang',
              uuid: 'fang',
              playerCharacterId: 'PC-ARIA',
              kind: FightParticipantKind.companion),
          // another character of the same user, played elsewhere
          _participant('p-zed', 'Zed',
              uuid: 'zed', playerCharacterId: 'pc-zed'),
        ],
      ));
      await _settle(tester);

      expect(h.asked, ['Aria', 'Fang']);
      expect(h.fightApi.submittedRolls, [
        [('aria', 17), ('fang', 9)],
      ]);
      expect(h.rpgEntity.sendFightSequenceRollsToDmCalls, isEmpty);
    });

    testWidgets('is not asked twice when the old event follows',
        (tester) async {
      final h = await _setup(tester, isDm: false);
      final pendingAria = _participant('p-aria', 'Aria',
          uuid: 'aria', playerCharacterId: 'pc-aria');
      h.fightApi.fight = _fight([pendingAria]);
      h.rolls['Aria'] = 17;

      h.svc.initiativeRequested(InitiativeRequest(
          fightId: 'fight-1',
          campagneId: 'camp-1',
          participants: [pendingAria]));
      h.svc.playersAreAskedForRolls(jsonEncode(FightSequence(
          fightUuid: 'fight-1', sequence: [('aria', 'Aria', -1)])));
      await _settle(tester);

      expect(h.asked, ['Aria']);
      expect(h.fightApi.submittedRolls, hasLength(1));
      expect(h.rpgEntity.sendFightSequenceRollsToDmCalls, isEmpty);
    });

    testWidgets('is asked on return for a fight started while away',
        (tester) async {
      final h = await _setup(tester, isDm: false);
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria',
            uuid: 'aria', playerCharacterId: 'pc-aria'),
      ]);

      // dismissed: asked again on the next catch-up
      await h.svc.catchUpOnFight();
      h.rolls['Aria'] = 11;
      await h.svc.catchUpOnFight();
      await h.svc.catchUpOnFight();

      expect(h.asked, ['Aria', 'Aria']);
      expect(h.fightApi.submittedRolls, [
        [('aria', 11)],
      ]);
    });

    testWidgets('stops asking once the roll was made in another app',
        (tester) async {
      final h = await _setup(tester, isDm: false);
      h.keepOpen.add('Aria');
      h.rolls['Fang'] = 9;

      h.svc.initiativeRequested(InitiativeRequest(
        fightId: 'fight-1',
        campagneId: 'camp-1',
        participants: [
          _participant('p-aria', 'Aria',
              uuid: 'aria', playerCharacterId: 'pc-aria'),
          _participant('p-fang', 'Fang',
              uuid: 'fang',
              playerCharacterId: 'pc-aria',
              kind: FightParticipantKind.companion),
        ],
      ));
      await _settle(tester);
      h.svc.initiativeSettled(const InitiativeSettlement(
          fightId: 'fight-2', campagneId: 'camp-1', characterUuids: ['aria']));
      await _settle(tester);
      expect(h.closed, isEmpty, reason: 'another fight');

      // both rolled in the web app while Aria's prompt was open here
      h.svc.initiativeSettled(const InitiativeSettlement(
          fightId: 'FIGHT-1',
          campagneId: 'camp-1',
          characterUuids: ['aria', 'fang']));
      await _settle(tester);

      expect(h.closed, ['Aria']);
      expect(h.asked, ['Aria'], reason: 'Fang was settled before its turn');
      expect(h.fightApi.submittedRolls, isEmpty);
    });

    testWidgets('stops asking when the DM ends the fight', (tester) async {
      final h = await _setup(tester, isDm: false);
      h.keepOpen.add('Aria');

      h.svc.initiativeRequested(InitiativeRequest(
        fightId: 'fight-1',
        campagneId: 'camp-1',
        participants: [
          _participant('p-aria', 'Aria',
              uuid: 'aria', playerCharacterId: 'pc-aria'),
        ],
      ));
      await _settle(tester);
      h.svc.fightEnded('FIGHT-1');
      await _settle(tester);

      expect(h.closed, ['Aria']);
      expect(h.fightApi.submittedRolls, isEmpty);
    });

    testWidgets(
        'stops asking on reconnect when the roll was made while disconnected',
        (tester) async {
      final h = await _setup(tester, isDm: false);
      h.keepOpen.add('Aria');
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria',
            uuid: 'aria', playerCharacterId: 'pc-aria'),
      ]);
      final firstCatchUp = h.svc.catchUpOnFight();
      await _settle(tester);
      expect(h.asked, ['Aria']);

      // still pending: the prompt stays open
      await h.svc.catchUpOnFight();
      await _settle(tester);
      expect(h.closed, isEmpty);

      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria',
            uuid: 'aria', playerCharacterId: 'pc-aria', roll: 12, position: 0),
      ]);
      await h.svc.catchUpOnFight();
      await firstCatchUp;

      expect(h.closed, ['Aria']);
      expect(h.asked, ['Aria']);
      expect(h.fightApi.submittedRolls, isEmpty);
    });

    testWidgets('stops asking on reconnect when the fight is over',
        (tester) async {
      final h = await _setup(tester, isDm: false);
      h.keepOpen.add('Aria');
      h.fightApi.fight = _fight([
        _participant('p-aria', 'Aria',
            uuid: 'aria', playerCharacterId: 'pc-aria'),
      ]);
      final firstCatchUp = h.svc.catchUpOnFight();
      await _settle(tester);

      h.fightApi.fight = null;
      await h.svc.catchUpOnFight();
      await firstCatchUp;

      expect(h.closed, ['Aria']);
      expect(h.fightApi.submittedRolls, isEmpty);
    });

    testWidgets('is not asked for a fight in another campagne', (tester) async {
      final h = await _setup(tester, isDm: false);

      h.svc.initiativeRequested(InitiativeRequest(
        fightId: 'fight-9',
        campagneId: 'camp-2',
        participants: [
          _participant('p-aria', 'Aria',
              uuid: 'aria', playerCharacterId: 'pc-aria'),
        ],
      ));
      await _settle(tester);

      expect(h.asked, isEmpty);
    });

    testWidgets('keeps the old flow when the backend does not keep fights',
        (tester) async {
      final h = await _setup(tester, isDm: false, backendKeepsFights: false);
      h.rolls['Aria'] = 14;

      h.svc.playersAreAskedForRolls(jsonEncode(FightSequence(
          fightUuid: 'fight-legacy', sequence: [('aria', 'Aria', -1)])));
      await _settle(tester);

      expect(h.asked, ['Aria']);
      expect(h.fightApi.calls, isEmpty);
      expect(h.rpgEntity.sendFightSequenceRollsToDmCalls.single.sequence,
          [('aria', 'Aria', 14)]);
    });

    testWidgets('uses the old flow for a fight the server does not know',
        (tester) async {
      final h = await _setup(tester, isDm: false);
      h.fightApi.fight = null;
      h.rolls['Aria'] = 6;

      h.svc.playersAreAskedForRolls(jsonEncode(FightSequence(
          fightUuid: 'fight-old', sequence: [('aria', 'Aria', -1)])));
      await _settle(tester);

      expect(h.asked, ['Aria']);
      expect(h.rpgEntity.sendFightSequenceRollsToDmCalls, hasLength(1));
    });
  });
}
