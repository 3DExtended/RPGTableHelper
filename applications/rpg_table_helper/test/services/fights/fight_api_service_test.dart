import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/models/fight_state.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/fights/fight_api_service.dart';

class _FakeApi extends IApiConnectorService {
  _FakeApi({this.jwt = 'jwt'}) : super(isMock: true);

  final String? jwt;

  @override
  Future<Swagger?> getApiConnector({bool requiresJwt = true}) async => null;

  @override
  Future<String?> getJwt() async => jwt;

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

const _fightJson = {
  'id': 'fight-1',
  'campagneId': 'camp-1',
  'isOpen': true,
  'isDmView': true,
  'revision': 1,
  'participants': [
    {
      'id': 'p-1',
      'kind': 'Character',
      'characterUuid': 'aria',
      'name': 'Aria',
      'isPending': true,
    },
  ],
};

void main() {
  late List<http.Request> requests;
  late int status;
  late Object? responseBody;

  FightApiService createSut({String? jwt = 'jwt'}) {
    requests = [];
    return FightApiService(
      apiConnectorService: _FakeApi(jwt: jwt),
      client: MockClient((request) async {
        requests.add(request);
        return http.Response(
          responseBody is String
              ? responseBody as String
              : jsonEncode(responseBody),
          status,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
  }

  setUp(() {
    status = 200;
    responseBody = _fightJson;
  });

  test('getCurrentFight returns the open fight', () async {
    responseBody = {'fight': _fightJson};
    final sut = createSut();

    final response = await sut.getCurrentFight(campagneId: 'camp-1');

    expect(response.isSuccessful, isTrue);
    expect(response.result!.id, 'fight-1');
    expect(requests.single.method, 'GET');
    expect(requests.single.url.toString(), '${apiBaseUrl}Fight/current/camp-1');
    expect(requests.single.headers['Authorization'], 'Bearer jwt');
  });

  test('getCurrentFight returns null when there is no fight', () async {
    responseBody = {'fight': null};
    final sut = createSut();

    final response = await sut.getCurrentFight(campagneId: 'camp-1');

    expect(response.isSuccessful, isTrue);
    expect(response.result, isNull);
  });

  test('startFight sends the participants without enemies', () async {
    final sut = createSut();

    final response = await sut.startFight(
      campagneId: 'camp-1',
      participants: const [
        FightStartParticipant(
            characterUuid: 'aria', playerCharacterId: 'pc-1', name: 'Aria'),
      ],
    );

    expect(response.result!.pending.single.name, 'Aria');
    expect(requests.single.method, 'POST');
    expect(requests.single.url.path, endsWith('/Fight/start/camp-1'));
    expect(jsonDecode(requests.single.body), {
      'participants': [
        {'characterUuid': 'aria', 'playerCharacterId': 'pc-1', 'name': 'Aria'},
      ],
      'enemies': [],
    });
  });

  test('every DM action calls its endpoint', () async {
    final sut = createSut();

    await sut.submitRolls(fightId: 'f', rolls: const [('aria', 12)]);
    await sut.addEnemies(fightId: 'f', enemies: const [('Goblin', 14)]);
    await sut.reorder(fightId: 'f', participantIds: const ['b', 'a']);
    await sut.removeParticipant(fightId: 'f', participantId: 'p-1');
    await sut.endFight(fightId: 'f');

    expect(requests.map((r) => '${r.method} ${r.url.path}'), [
      'POST ${Uri.parse(apiBaseUrl).path}Fight/f/rolls',
      'POST ${Uri.parse(apiBaseUrl).path}Fight/f/enemies',
      'PUT ${Uri.parse(apiBaseUrl).path}Fight/f/order',
      'DELETE ${Uri.parse(apiBaseUrl).path}Fight/f/participants/p-1',
      'POST ${Uri.parse(apiBaseUrl).path}Fight/f/end',
    ]);
    expect(jsonDecode(requests[0].body), {
      'rolls': [
        {'characterUuid': 'aria', 'roll': 12},
      ],
    });
    expect(jsonDecode(requests[1].body), {
      'enemies': [
        {'name': 'Goblin', 'roll': 14},
      ],
    });
    expect(jsonDecode(requests[2].body), {
      'participantIds': ['b', 'a'],
    });
  });

  test('an error keeps the status code, so callers can fall back on 404',
      () async {
    status = 404;
    responseBody = 'Not Found';
    final sut = createSut();

    final response = await sut.startFight(
      campagneId: 'camp-1',
      participants: const [],
    );

    expect(response.isSuccessful, isFalse);
    expect(response.statusCode, 404);
    expect(response.errorFromServer, 'Not Found');
  });

  test('does not call the server without a session', () async {
    final sut = createSut(jwt: null);

    final response = await sut.endFight(fightId: 'f');

    expect(response.isSuccessful, isFalse);
    expect(requests, isEmpty);
  });
}
