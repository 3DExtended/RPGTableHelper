import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:quest_keeper/constants.dart';
import 'package:signalr_netcore/msgpack_hub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// Multi-simulator E2E: `E2E_ROLE` must be `dm`, `player1`, or `player2`.
///
/// Prefer `Platform.environment['E2E_ROLE']` (set by the shell script) so each
/// simulator run does not depend on compile-time `--dart-define` only — parallel
/// `flutter test` invocations can otherwise share one kernel and embed the wrong role.
/// `--dart-define=E2E_ROLE=...` is still passed as a fallback.
/// (see scripts/run_flutter_multi_sim_e2e.sh).
String _resolveE2eRole() {
  final fromEnv = Platform.environment['E2E_ROLE']?.trim().toLowerCase();
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return fromEnv;
  }
  return const String.fromEnvironment('E2E_ROLE', defaultValue: '')
      .trim()
      .toLowerCase();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Skipped unless E2E_ROLE is set (see run_flutter_multi_sim_e2e.sh).
  // `flutter test integration_test/` would otherwise pick up this file.
  testWidgets(
    'Multi-client DM ping reaches two iPad simulators (MessagePack)',
    (tester) async {
    final role = _resolveE2eRole();
    expect(
      const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
      isNotEmpty,
      reason: 'Pass --dart-define=API_BASE_URL=http://127.0.0.1:5012/',
    );

    // Generous: staggered Xcode builds can take minutes before players join.
    const barrierTimeout = Duration(seconds: 600);
    const pingTimeout = Duration(seconds: 120);
    const poll = Duration(milliseconds: 400);

    Future<Map<String, dynamic>> getSync() async {
      final r = await http.get(Uri.parse('${apiBaseUrl}e2e/multi-client/sync'));
      expect(r.statusCode, 200, reason: r.body);
      return jsonDecode(r.body) as Map<String, dynamic>;
    }

    Future<void> postEmpty(String relativePath) async {
      final r = await http.post(Uri.parse('$apiBaseUrl$relativePath'));
      expect(r.statusCode, 200, reason: r.body);
    }

    Future<Map<String, dynamic>> getSession(String r) async {
      final uri = Uri.parse('${apiBaseUrl}e2e/multi-client/session').replace(
        queryParameters: {'role': r},
      );
      final res = await http.get(uri);
      expect(res.statusCode, 200, reason: res.body);
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    Future<void> waitForDmRegistered() async {
      final until = DateTime.now().add(barrierTimeout);
      while (DateTime.now().isBefore(until)) {
        final j = await getSync();
        if (j['dmGameRegistered'] == true) {
          return;
        }
        await Future<void>.delayed(poll);
      }
      fail('Timeout waiting for dmGameRegistered');
    }

    Future<void> waitForTwoPlayersReadded() async {
      final until = DateTime.now().add(barrierTimeout);
      while (DateTime.now().isBefore(until)) {
        final j = await getSync();
        final n = j['playersReaddedCount'];
        if (n is int && n >= 2) {
          return;
        }
        await Future<void>.delayed(poll);
      }
      fail('Timeout waiting for playersReaddedCount >= 2');
    }

    HubConnection buildHub(String jwt) {
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

    if (role == 'dm') {
      final session = await getSession('dm');
      final jwt = session['jwt']! as String;
      final campagneId = session['campagneId']! as String;

      final hub = buildHub(jwt);
      await hub.start();
      expect(hub.state, HubConnectionState.Connected);

      await hub.invoke('RegisterGame', args: <Object>[campagneId]);
      await postEmpty('e2e/multi-client/sync/dm-game-registered');

      await waitForTwoPlayersReadded();

      const pingPayload = 'multi-sim-ping-1';
      await hub.invoke(
        'SendPingToPlayers',
        args: <Object>[campagneId, pingPayload],
      );

      await hub.stop();
      return;
    }

    // player1 or player2
    await waitForDmRegistered();

    final session = await getSession(role);
    final jwt = session['jwt']! as String;
    final characterId = session['playerCharacterId']! as String;

    final pingDone = Completer<String>();

    final hub = buildHub(jwt);
    hub.on('pingFromDm', (List<Object?>? args) {
      if (args != null && args.isNotEmpty && args[0] != null) {
        if (!pingDone.isCompleted) {
          pingDone.complete(args[0]! as String);
        }
      }
    });

    await hub.start();
    expect(hub.state, HubConnectionState.Connected);

    await hub.invoke(
      'ReaddToSignalRGroups',
      args: <Object>['NULL', characterId],
    );
    await postEmpty('e2e/multi-client/sync/player-readded');

    final ts = await pingDone.future.timeout(
      pingTimeout,
      onTimeout: () => '',
    );
    expect(ts, 'multi-sim-ping-1');

    await hub.stop();
  },
    skip: _resolveE2eRole().isEmpty,
  );
}
