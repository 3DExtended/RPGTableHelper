import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/services/hub_invoke_queue.dart';
import 'package:quest_keeper/services/hub_invoke_retry.dart';
import 'package:signalr_netcore/msgpack_hub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// Single-process E2E: player transport reconnect + [HubInvokeQueue] drain (MessagePack).
///
/// Does **not** use `E2E_ROLE` or `POST …/multi-client/sync/*` barriers — call
/// `POST …/e2e/multi-client/reset` once at the start so coordinator state is clean
/// if you run other multi-sim tests in sequence.

Future<void> _postReset(String apiBase) async {
  final r = await http.post(Uri.parse('${apiBase}e2e/multi-client/reset'));
  expect(r.statusCode, 200, reason: r.body);
}

Future<Map<String, dynamic>> _getSession(String apiBase, String role) async {
  final uri = Uri.parse('${apiBase}e2e/multi-client/session').replace(
    queryParameters: {'role': role},
  );
  final res = await http.get(uri);
  expect(res.statusCode, 200, reason: res.body);
  return jsonDecode(res.body) as Map<String, dynamic>;
}

HubConnection _buildHub(String jwt) {
  return HubConnectionBuilder()
      .withUrl(
        serverUrl,
        options: HttpConnectionOptions(
          accessTokenFactory: () async => jwt,
          logMessageContent: false,
        ),
      )
      .withHubProtocol(MessagePackHubProtocol())
      .build();
}

Future<void> _e2eDrainHubInvokeQueue({
  required HubInvokeQueue queue,
  required HubConnection hub,
}) async {
  Future<bool> tryOpenConnection() async {
    if (hub.state == HubConnectionState.Disconnected ||
        hub.state == HubConnectionState.Disconnecting) {
      await hub.start();
    }
    return hub.state == HubConnectionState.Connected;
  }

  if (hub.state != HubConnectionState.Connected) {
    await tryOpenConnection();
  }
  if (hub.state != HubConnectionState.Connected) {
    return;
  }

  var guard = 0;
  while (hub.state == HubConnectionState.Connected &&
      queue.length > 0 &&
      guard < hubInvokeQueueMaxItems * 2) {
    guard++;
    final next = queue.dequeue();
    if (next == null) {
      break;
    }
    final ok = await runHubInvokeWithRetries(
      hubMissing: false,
      hubState: () => hub.state,
      invoke: (name, {args}) => hub.invoke(name, args: args),
      tryOpenConnection: tryOpenConnection,
      functionName: next.functionName,
      args: next.args,
      maxInvokeRetries: 1,
      logSkippedNoHub: (_) {},
      logNotConnected: (_) {},
      logInvokeOk: (_) {},
      logInvokeFailed: (_, __, ___) {},
      logGaveUp: (_, __, ___) {},
    );
    if (!ok) {
      queue.unshift(next);
      break;
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'After player stop/start + ReaddToSignalRGroups, DM ping reaches player (MessagePack)',
    (_) async {
      expect(
        const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
        isNotEmpty,
        reason:
            'Pass --dart-define=API_BASE_URL=http://127.0.0.1:5012/ (see run_flutter_signalr_e2e.sh)',
      );
      final apiBase = apiBaseUrl;
      await _postReset(apiBase);

      final dmSession = await _getSession(apiBase, 'dm');
      final p1Session = await _getSession(apiBase, 'player1');

      final dmJwt = dmSession['jwt']! as String;
      final campagneId = dmSession['campagneId']! as String;
      final char1 = dmSession['player1CharacterId']! as String;

      final playerJwt = p1Session['jwt']! as String;
      final characterId = p1Session['playerCharacterId']! as String;
      expect(characterId, char1);

      const pingPayload = 'ping-after-reconnect-dart-e2e';

      final pingReceived = Completer<String>();
      final dmHub = _buildHub(dmJwt);
      final playerHub = _buildHub(playerJwt);

      playerHub.on('pingFromDm', (List<Object?>? args) {
        if (args == null || args.isEmpty) {
          return;
        }
        final s = args[0] as String? ?? '';
        if (!pingReceived.isCompleted && s == pingPayload) {
          pingReceived.complete(s);
        }
      });

      await dmHub.start();
      await playerHub.start();
      expect(dmHub.state, HubConnectionState.Connected);
      expect(playerHub.state, HubConnectionState.Connected);

      await dmHub.invoke('RegisterGame', args: <Object>[campagneId]);
      await playerHub.invoke(
        'ReaddToSignalRGroups',
        args: <Object>['NULL', characterId],
      );

      await playerHub.stop();
      await playerHub.start();
      await playerHub.invoke(
        'ReaddToSignalRGroups',
        args: <Object>['NULL', characterId],
      );

      await dmHub.invoke(
        'SendPingToPlayers',
        args: <Object>[campagneId, pingPayload],
      );

      final got = await pingReceived.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => '',
      );
      expect(got, pingPayload);

      await dmHub.stop();
      await playerHub.stop();
    },
  );

  testWidgets(
    'HubInvokeQueue: enqueue while player hub down, drain after reconnect + Readd (MessagePack)',
    (_) async {
      expect(
        const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
        isNotEmpty,
        reason:
            'Pass --dart-define=API_BASE_URL=http://127.0.0.1:5012/ (see run_flutter_signalr_e2e.sh)',
      );
      final apiBase = apiBaseUrl;
      await _postReset(apiBase);

      final dmSession = await _getSession(apiBase, 'dm');
      final p1Session = await _getSession(apiBase, 'player1');

      final dmJwt = dmSession['jwt']! as String;
      final campagneId = dmSession['campagneId']! as String;
      final char1 = dmSession['player1CharacterId']! as String;
      final uid1 = dmSession['player1UserId']! as String;

      final playerJwt = p1Session['jwt']! as String;
      final characterId = p1Session['playerCharacterId']! as String;
      expect(characterId, char1);

      const queuedPayload = '{"queueE2E":true,"n":42}';

      final fromDm = Completer<List<String>>();
      final dmHub = _buildHub(dmJwt);
      final playerHub = _buildHub(playerJwt);

      dmHub.on('updateRpgCharacterConfigOnDmSide', (List<Object?>? args) {
        if (args == null || args.length < 3) {
          return;
        }
        final cfg = args[0]! as String;
        final cid = args[1]! as String;
        final uid = args[2]! as String;
        if (!fromDm.isCompleted && cid == characterId) {
          fromDm.complete(<String>[cfg, cid, uid]);
        }
      });

      await dmHub.start();
      await playerHub.start();

      await dmHub.invoke('RegisterGame', args: <Object>[campagneId]);
      await playerHub.invoke(
        'ReaddToSignalRGroups',
        args: <Object>['NULL', characterId],
      );

      await playerHub.stop();

      final queue = HubInvokeQueue();
      queue.enqueue(
        'SendUpdatedRpgCharacterConfigToDm',
        <Object>[characterId, queuedPayload],
      );
      expect(queue.length, 1);

      await playerHub.start();
      await playerHub.invoke(
        'ReaddToSignalRGroups',
        args: <Object>['NULL', characterId],
      );

      await _e2eDrainHubInvokeQueue(queue: queue, hub: playerHub);
      expect(queue.length, 0);

      final row = await fromDm.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => <String>[],
      );
      expect(row.length, 3);
      expect(row[0], queuedPayload);
      expect(row[1], characterId);
      expect(row[2], uid1);

      await dmHub.stop();
      await playerHub.stop();
    },
  );
}
