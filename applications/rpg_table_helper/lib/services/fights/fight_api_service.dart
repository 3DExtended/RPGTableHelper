import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/models/fight_state.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';

/// REST client for fights kept on the server (`/Fight/*`). Only use it when
/// the backend advertises `persisted-fights`.
abstract class IFightApiService {
  final bool isMock;

  const IFightApiService({required this.isMock});

  /// The open fight of the campagne, or a null result if there is none.
  Future<HRResponse<FightState?>> getCurrentFight({required String campagneId});

  Future<HRResponse<FightState>> startFight({
    required String campagneId,
    required List<FightStartParticipant> participants,
  });

  Future<HRResponse<FightState>> submitRolls({
    required String fightId,
    required List<(String characterUuid, int roll)> rolls,
  });

  Future<HRResponse<FightState>> addEnemies({
    required String fightId,
    required List<(String name, int roll)> enemies,
  });

  Future<HRResponse<FightState>> reorder({
    required String fightId,
    required List<String> participantIds,
  });

  Future<HRResponse<FightState>> removeParticipant({
    required String fightId,
    required String participantId,
  });

  Future<HRResponse<FightState>> endFight({required String fightId});
}

class FightApiService extends IFightApiService {
  final IApiConnectorService apiConnectorService;
  final http.Client _client;

  FightApiService({required this.apiConnectorService, http.Client? client})
      : _client = client ?? http.Client(),
        super(isMock: false);

  @override
  Future<HRResponse<FightState?>> getCurrentFight(
      {required String campagneId}) async {
    final response = await _send(
      'GET',
      'Fight/current/$campagneId',
      errorMessage: 'Could not load the current fight.',
      errorCode: '1f0c2b6e-7d3a-4c51-9e8b-fight-current',
    );
    if (!response.isSuccessful) {
      return HRResponse.error(
        response.humanReadableError ?? '',
        response.errorCode ?? '',
        statusCode: response.statusCode,
        errorFromServer: response.errorFromServer,
        caughtException: response.caughtException,
      );
    }
    final fight = response.result!['fight'];
    return HRResponse.fromResult(
      fight is Map<String, dynamic> ? FightState.fromJson(fight) : null,
      statusCode: response.statusCode,
    );
  }

  @override
  Future<HRResponse<FightState>> startFight({
    required String campagneId,
    required List<FightStartParticipant> participants,
  }) {
    return _sendForFight(
      'POST',
      'Fight/start/$campagneId',
      body: {
        'participants': participants
            .map((p) => {
                  'characterUuid': p.characterUuid,
                  'playerCharacterId': p.playerCharacterId,
                  'name': p.name,
                })
            .toList(),
        'enemies': const [],
      },
      errorMessage: 'Could not start the fight.',
      errorCode: '2a1d3c7f-8e4b-4d62-af9c-fight-start',
    );
  }

  @override
  Future<HRResponse<FightState>> submitRolls({
    required String fightId,
    required List<(String characterUuid, int roll)> rolls,
  }) {
    return _sendForFight(
      'POST',
      'Fight/$fightId/rolls',
      body: {
        'rolls':
            rolls.map((r) => {'characterUuid': r.$1, 'roll': r.$2}).toList(),
      },
      errorMessage: 'Could not send your initiative roll.',
      errorCode: '3b2e4d8a-9f5c-4e73-b0ad-fight-rolls',
    );
  }

  @override
  Future<HRResponse<FightState>> addEnemies({
    required String fightId,
    required List<(String name, int roll)> enemies,
  }) {
    return _sendForFight(
      'POST',
      'Fight/$fightId/enemies',
      body: {
        'enemies': enemies.map((e) => {'name': e.$1, 'roll': e.$2}).toList(),
      },
      errorMessage: 'Could not add the enemies.',
      errorCode: '4c3f5e9b-a06d-4f84-c1be-fight-enemies',
    );
  }

  @override
  Future<HRResponse<FightState>> reorder({
    required String fightId,
    required List<String> participantIds,
  }) {
    return _sendForFight(
      'PUT',
      'Fight/$fightId/order',
      body: {'participantIds': participantIds},
      errorMessage: 'Could not change the order.',
      errorCode: '5d4a6fac-b17e-4a95-d2cf-fight-order',
    );
  }

  @override
  Future<HRResponse<FightState>> removeParticipant({
    required String fightId,
    required String participantId,
  }) {
    return _sendForFight(
      'DELETE',
      'Fight/$fightId/participants/$participantId',
      errorMessage: 'Could not remove the participant.',
      errorCode: '6e5b7abd-c28f-4ba6-e3d0-fight-remove',
    );
  }

  @override
  Future<HRResponse<FightState>> endFight({required String fightId}) {
    return _sendForFight(
      'POST',
      'Fight/$fightId/end',
      errorMessage: 'Could not end the fight.',
      errorCode: '7f6c8bce-d390-4cb7-f4e1-fight-end',
    );
  }

  Future<HRResponse<FightState>> _sendForFight(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required String errorMessage,
    required String errorCode,
  }) async {
    final response = await _send(
      method,
      path,
      body: body,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
    if (!response.isSuccessful) {
      return HRResponse.error(
        response.humanReadableError ?? errorMessage,
        response.errorCode ?? errorCode,
        statusCode: response.statusCode,
        errorFromServer: response.errorFromServer,
        caughtException: response.caughtException,
      );
    }
    return HRResponse.fromResult(
      FightState.fromJson(response.result!),
      statusCode: response.statusCode,
    );
  }

  Future<HRResponse<Map<String, dynamic>>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required String errorMessage,
    required String errorCode,
  }) async {
    final jwt = await apiConnectorService.getJwt();
    if (jwt == null) {
      return HRResponse.error('Could not load api connector.', errorCode);
    }

    final request = http.Request(method, Uri.parse('$apiBaseUrl$path'))
      ..headers['Authorization'] = 'Bearer $jwt';
    if (body != null) {
      request.headers['content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    try {
      final response = await http.Response.fromStream(
        await _client.send(request),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return HRResponse.error(
          errorMessage,
          errorCode,
          statusCode: response.statusCode,
          errorFromServer: response.body,
        );
      }
      return HRResponse.fromResult(
        jsonDecode(response.body) as Map<String, dynamic>,
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      return HRResponse.error(errorMessage, errorCode, caughtException: e);
    }
  }
}

/// No server: there is never a fight, and starting one fails, so the app
/// stays on the old fight flow.
class MockFightApiService extends IFightApiService {
  const MockFightApiService() : super(isMock: true);

  static HRResponse<FightState> _unavailable() => HRResponse.error(
        'Fights are not available.',
        'mock-fight-api',
        statusCode: 404,
      );

  @override
  Future<HRResponse<FightState?>> getCurrentFight(
          {required String campagneId}) async =>
      HRResponse.fromResult(null);

  @override
  Future<HRResponse<FightState>> startFight({
    required String campagneId,
    required List<FightStartParticipant> participants,
  }) async =>
      _unavailable();

  @override
  Future<HRResponse<FightState>> submitRolls({
    required String fightId,
    required List<(String, int)> rolls,
  }) async =>
      _unavailable();

  @override
  Future<HRResponse<FightState>> addEnemies({
    required String fightId,
    required List<(String, int)> enemies,
  }) async =>
      _unavailable();

  @override
  Future<HRResponse<FightState>> reorder({
    required String fightId,
    required List<String> participantIds,
  }) async =>
      _unavailable();

  @override
  Future<HRResponse<FightState>> removeParticipant({
    required String fightId,
    required String participantId,
  }) async =>
      _unavailable();

  @override
  Future<HRResponse<FightState>> endFight({required String fightId}) async =>
      _unavailable();
}
