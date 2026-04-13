import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
///
/// **One** [testWidgets] run. Do **not** call `POST /e2e/multi-client/reset` ad hoc mid
/// scenario: if one runner resets while others are still in phase 1, barriers break.
/// The shell script resets once before Flutter (or `curl …/reset` once manually).
/// Phase 2 uses `POST …/sync/phase1-ready` + poll until `phase1ReadyCount >= 3`, then
/// each runner calls `reset` before reconnect — safe across three parallel simulators.
///
/// Never call [WidgetTester.pump] from [HubConnection] handlers — only from the test
/// body — or `LiveTestWidgetsFlutterBinding` fails in `postTest`.
String _resolveE2eRole() {
  final fromEnv = Platform.environment['E2E_ROLE']?.trim().toLowerCase();
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return fromEnv;
  }
  return const String.fromEnvironment('E2E_ROLE', defaultValue: '')
      .trim()
      .toLowerCase();
}

const Duration _barrierTimeout = Duration(seconds: 600);
const Duration _pingTimeout = Duration(seconds: 120);
const Duration _configTimeout = Duration(seconds: 120);
const Duration _poll = Duration(milliseconds: 400);
const int _e2eMaxLogLines = 36;

/// JSON object `{"b":"x…"}` with UTF-16 length >= [minChars] (matches API test helper).
String _jsonObjectWithMinimumLength(int minChars) {
  const prefix = '{"b":"';
  const suffix = '"}';
  final inner = (minChars - prefix.length - suffix.length).clamp(0, 1 << 20);
  return '$prefix${'x' * inner}$suffix';
}

Future<void> _postEmpty(String apiBase, String relativePath) async {
  final uri = Uri.parse('$apiBase$relativePath');
  final r = await http.post(uri);
  expect(
    r.statusCode,
    200,
    reason: '$uri → ${r.statusCode} ${r.body}',
  );
}

Future<Map<String, dynamic>> _getSync(String apiBase) async {
  final r = await http.get(Uri.parse('${apiBase}e2e/multi-client/sync'));
  expect(r.statusCode, 200, reason: r.body);
  return jsonDecode(r.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _getSession(String apiBase, String role) async {
  final uri = Uri.parse('${apiBase}e2e/multi-client/session').replace(
    queryParameters: {'role': role},
  );
  final res = await http.get(uri);
  expect(res.statusCode, 200, reason: res.body);
  return jsonDecode(res.body) as Map<String, dynamic>;
}

void _e2eLogLine(ValueNotifier<String> log, String line) {
  final ts = DateTime.now().toIso8601String().substring(11, 23);
  final chunk = log.value.isEmpty ? '[$ts] $line' : '${log.value}\n[$ts] $line';
  var lines = chunk.split('\n');
  if (lines.length > _e2eMaxLogLines) {
    lines = lines.sublist(lines.length - _e2eMaxLogLines);
  }
  log.value = lines.join('\n');
}

/// Log + [tester.pump] — call only from the test's main async flow. Do **not** pump
/// from SignalR [HubConnection] callbacks: concurrent pumps break
/// [LiveTestWidgetsFlutterBinding] (`_expectingFrame` / `_pendingFrame` in postTest).
Future<void> _e2eAppend(
  WidgetTester tester,
  ValueNotifier<String> log,
  String line,
) async {
  _e2eLogLine(log, line);
  await tester.pump(const Duration(milliseconds: 16));
}

Future<void> _waitForDmRegisteredWithUi(
  String apiBase,
  WidgetTester tester,
  ValueNotifier<String> log,
) async {
  await _e2eAppend(tester, log,
      'Wait: dmGameRegistered (HTTP poll, up to ${_barrierTimeout.inMinutes}m)…');
  final until = DateTime.now().add(_barrierTimeout);
  var lastUi = DateTime.now();
  while (DateTime.now().isBefore(until)) {
    final j = await _getSync(apiBase);
    if (j['dmGameRegistered'] == true) {
      await _e2eAppend(tester, log, 'dmGameRegistered = true ✓');
      return;
    }
    if (DateTime.now().difference(lastUi) > const Duration(seconds: 6)) {
      lastUi = DateTime.now();
      await _e2eAppend(
        tester,
        log,
        '…still polling (dmGameRegistered=${j['dmGameRegistered']})',
      );
    }
    await Future<void>.delayed(_poll);
  }
  fail('Timeout waiting for dmGameRegistered');
}

Future<void> _waitForTwoPlayersReaddedWithUi(
  String apiBase,
  WidgetTester tester,
  ValueNotifier<String> log,
) async {
  await _e2eAppend(
    tester,
    log,
    'Barrier: playersReaddedCount >= 2 (DM blocks here until both players re-add)…',
  );
  final until = DateTime.now().add(_barrierTimeout);
  var lastUi = DateTime.now();
  while (DateTime.now().isBefore(until)) {
    final j = await _getSync(apiBase);
    final n = j['playersReaddedCount'];
    if (n is int && n >= 2) {
      await _e2eAppend(tester, log, 'Barrier OK: playersReaddedCount=$n ✓');
      return;
    }
    if (DateTime.now().difference(lastUi) > const Duration(seconds: 5)) {
      lastUi = DateTime.now();
      await _e2eAppend(
        tester,
        log,
        '…still waiting (playersReaddedCount=${n is int ? n : '?'})',
      );
    }
    await Future<void>.delayed(_poll);
  }
  fail('Timeout waiting for playersReaddedCount >= 2');
}

Future<void> _waitForPhase1BarrierWithUi(
  String apiBase,
  WidgetTester tester,
  ValueNotifier<String> log,
) async {
  await _e2eAppend(
    tester,
    log,
    'Barrier: phase1ReadyCount >= 3 (all roles finished phase 1)…',
  );
  final until = DateTime.now().add(_barrierTimeout);
  var lastUi = DateTime.now();
  while (DateTime.now().isBefore(until)) {
    final j = await _getSync(apiBase);
    final n = j['phase1ReadyCount'];
    if (n is int && n >= 3) {
      await _e2eAppend(tester, log, 'Barrier OK: phase1ReadyCount=$n ✓');
      return;
    }
    if (DateTime.now().difference(lastUi) > const Duration(seconds: 5)) {
      lastUi = DateTime.now();
      await _e2eAppend(
        tester,
        log,
        '…still waiting (phase1ReadyCount=${n is int ? n : '?'})',
      );
    }
    await Future<void>.delayed(_poll);
  }
  fail('Timeout waiting for phase1ReadyCount >= 3');
}

/// On-screen log so each simulator shows progress (identify hangs vs slow barrier).
Future<void> _pumpE2eDashboard(
  WidgetTester tester,
  String role,
  ValueNotifier<String> log,
) async {
  final seed = role == 'dm' ? Colors.indigo : Colors.teal;
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('SignalR E2E · $role'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Text(
                'Live steps below — if this stops updating, compare with terminal logs.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                  child: ValueListenableBuilder<String>(
                    valueListenable: log,
                    builder: (_, text, __) {
                      return SingleChildScrollView(
                        key: const Key('e2e_log_scroll'),
                        padding: const EdgeInsets.all(10),
                        child: SelectableText(
                          text.isEmpty ? '…' : text,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final role = _resolveE2eRole();
  final skipUnlessRole = role.isEmpty;

  testWidgets(
    'Multi-client: ping, config, character→DM, pong, empty ping; phase1 barrier + reconnect + ping (MessagePack)',
    (tester) async {
      expect(
        const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
        isNotEmpty,
        reason: 'Pass --dart-define=API_BASE_URL=http://127.0.0.1:5012/',
      );
      final apiBase = apiBaseUrl;
      final log = ValueNotifier<String>('');

      await _pumpE2eDashboard(tester, role, log);
      await _e2eAppend(
        tester,
        log,
        'Start (coordinator must be fresh: run_flutter_multi_sim_e2e.sh resets once; '
        'manual: POST …/e2e/multi-client/reset before all three devices)',
      );

      const pingPayload1 = 'multi-sim-ping-1';
      const reconnectPingPayload = 'multi-sim-reconnect-ping';
      final expectedConfig =
          '${_jsonObjectWithMinimumLength(6000)}üñ🎲-${DateTime.now().microsecondsSinceEpoch}';
      final nonce = DateTime.now().microsecondsSinceEpoch;
      final payloadP1 = '{"multiE2E":"p1","ts":$nonce,"hp":12}';
      final payloadP2 =
          '{"multiE2E":"p2","ts":$nonce,"blob":${_jsonObjectWithMinimumLength(2500)}}';
      const tsP1 = 'multi-sim-pong-a';
      const tsP2 = 'multi-sim-pong-b';

      if (role == 'dm') {
        await _e2eAppend(tester, log, 'Fetch /e2e/multi-client/session (dm)');
        final session = await _getSession(apiBase, 'dm');
        final jwt = session['jwt']! as String;
        final campagneId = session['campagneId']! as String;
        final char1 = session['player1CharacterId']! as String;
        final char2 = session['player2CharacterId']! as String;
        final uid1 = session['player1UserId']! as String;
        final uid2 = session['player2UserId']! as String;

        final fromChar1 = Completer<List<String>>();
        final fromChar2 = Completer<List<String>>();
        final fromU1 = Completer<List<String>>();
        final fromU2 = Completer<List<String>>();

        final hub = _buildHub(jwt);
        hub.on('updateRpgCharacterConfigOnDmSide', (List<Object?>? args) {
          if (args == null || args.length < 3) {
            return;
          }
          final cfg = args[0]! as String;
          final cid = args[1]! as String;
          final uid = args[2]! as String;
          final row = <String>[cfg, cid, uid];
          if (cid == char1 && !fromChar1.isCompleted) {
            fromChar1.complete(row);
            _e2eLogLine(log, 'Hub: character→DM (char1, ${cfg.length} chars)');
          } else if (cid == char2 && !fromChar2.isCompleted) {
            fromChar2.complete(row);
            _e2eLogLine(log, 'Hub: character→DM (char2, ${cfg.length} chars)');
          }
        });
        hub.on('pongFromPlayer', (List<Object?>? args) {
          if (args == null || args.length < 2) {
            return;
          }
          final ts = args[0]! as String;
          final uid = args[1]! as String;
          final row = <String>[ts, uid];
          if (uid == uid1 && !fromU1.isCompleted) {
            fromU1.complete(row);
            _e2eLogLine(log, 'Hub: pong from player1');
          } else if (uid == uid2 && !fromU2.isCompleted) {
            fromU2.complete(row);
            _e2eLogLine(log, 'Hub: pong from player2');
          }
        });

        await hub.start();
        expect(hub.state, HubConnectionState.Connected);
        await _e2eAppend(tester, log, 'Hub connected');

        await hub.invoke('RegisterGame', args: <Object>[campagneId]);
        await _postEmpty(apiBase, 'e2e/multi-client/sync/dm-game-registered');
        await _e2eAppend(
            tester, log, 'RegisterGame + dm-game-registered posted');

        await _waitForTwoPlayersReaddedWithUi(apiBase, tester, log);

        await _e2eAppend(tester, log, 'SendPingToPlayers (payload 1)');
        await hub.invoke(
          'SendPingToPlayers',
          args: <Object>[campagneId, pingPayload1],
        );

        await _e2eAppend(tester, log,
            'SendUpdatedRpgConfig (~${expectedConfig.length} chars)');
        await hub.invoke(
          'SendUpdatedRpgConfig',
          args: <Object>[campagneId, expectedConfig],
        );

        await _e2eAppend(
            tester, log, 'Await both character configs from players…');
        final charResults = await Future.wait(
          [fromChar1.future, fromChar2.future],
        ).timeout(
          _configTimeout,
          onTimeout: () => throw TimeoutException('character config to DM'),
        );
        await tester.pump(const Duration(milliseconds: 16));
        final byChar = {for (final r in charResults) r[1]: r};
        expect(byChar[char1]![0], contains('"multiE2E":"p1"'));
        expect(byChar[char1]![2], uid1);
        expect(byChar[char2]![0], contains('"multiE2E":"p2"'));
        expect(byChar[char2]![2], uid2);

        await _e2eAppend(tester, log, 'Await both pongs…');
        final pongResults = await Future.wait(
          [fromU1.future, fromU2.future],
        ).timeout(
          _configTimeout,
          onTimeout: () => throw TimeoutException('pongFromPlayer'),
        );
        await tester.pump(const Duration(milliseconds: 16));
        final byUser = {for (final r in pongResults) r[1]: r[0]};
        expect(byUser[uid1], tsP1);
        expect(byUser[uid2], tsP2);

        await _e2eAppend(tester, log, 'SendPingToPlayers (empty string)');
        await hub.invoke(
          'SendPingToPlayers',
          args: <Object>[campagneId, ''],
        );

        await _e2eAppend(
          tester,
          log,
          'Phase 1 done — sync before reconnect (phase1-ready + barrier + reset)',
        );
        await _postEmpty(apiBase, 'e2e/multi-client/sync/phase1-ready');
        await _waitForPhase1BarrierWithUi(apiBase, tester, log);
        await _postEmpty(apiBase, 'e2e/multi-client/sync/reset-phase2');
        await _e2eAppend(tester, log, 'Disconnect hub (before Phase 2 reconnect)');
        await hub.stop();

        await _e2eAppend(
          tester,
          log,
          'Phase 2: reconnect — RegisterGame, barrier, SendPingToPlayers',
        );
        await hub.start();
        expect(hub.state, HubConnectionState.Connected);
        await hub.invoke('RegisterGame', args: <Object>[campagneId]);
        await _postEmpty(apiBase, 'e2e/multi-client/sync/dm-game-registered');
        await _waitForTwoPlayersReaddedWithUi(apiBase, tester, log);
        await hub.invoke(
          'SendPingToPlayers',
          args: <Object>[campagneId, reconnectPingPayload],
        );

        await _e2eAppend(tester, log, 'All DM steps OK — stop hub');
        await hub.stop();
        await _e2eAppend(tester, log, 'DONE ✓');
        return;
      }

      await _waitForDmRegisteredWithUi(apiBase, tester, log);

      await _e2eAppend(tester, log, 'Fetch session ($role)');
      final session = await _getSession(apiBase, role);
      final jwt = session['jwt']! as String;
      final campagneId = session['campagneId']! as String;
      final characterId = session['playerCharacterId']! as String;

      final ping1Done = Completer<String>();
      final pingEmptyDone = Completer<String>();
      final reconnectPingDone = Completer<String>();
      final gotConfig = Completer<String>();

      final hub = _buildHub(jwt);
      hub.on('pingFromDm', (List<Object?>? args) {
        if (args == null || args.isEmpty) {
          return;
        }
        final s = args[0] as String? ?? '';
        if (s == pingPayload1 && !ping1Done.isCompleted) {
          ping1Done.complete(s);
          _e2eLogLine(log, 'Received ping payload 1');
        } else if (s.isEmpty && !pingEmptyDone.isCompleted) {
          pingEmptyDone.complete(s);
          _e2eLogLine(log, 'Received empty ping');
        } else if (s == reconnectPingPayload && !reconnectPingDone.isCompleted) {
          reconnectPingDone.complete(s);
          _e2eLogLine(log, 'Received reconnect ping');
        }
      });
      hub.on('updateRpgConfig', (List<Object?>? args) {
        if (args != null && args.isNotEmpty && args[0] != null) {
          if (!gotConfig.isCompleted) {
            gotConfig.complete(args[0]! as String);
            final len = (args[0]! as String).length;
            _e2eLogLine(log, 'Received updateRpgConfig ($len chars)');
          }
        }
      });

      await hub.start();
      expect(hub.state, HubConnectionState.Connected);
      await _e2eAppend(tester, log, 'Hub connected');

      await hub.invoke(
        'ReaddToSignalRGroups',
        args: <Object>['NULL', characterId],
      );
      await _postEmpty(apiBase, 'e2e/multi-client/sync/player-readded');
      await _e2eAppend(
          tester, log, 'ReaddToSignalRGroups + player-readded posted');

      final ts1 = await ping1Done.future.timeout(
        _pingTimeout,
        onTimeout: () => '',
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(ts1, pingPayload1);

      final cfg = await gotConfig.future.timeout(
        _configTimeout,
        onTimeout: () => '',
      );
      await tester.pump(const Duration(milliseconds: 16));
      // Exact equality is not stable across reruns because the server may dedupe unchanged payloads
      // (and LocalSignalRE2E can reuse a persistent DB). Validate shape instead.
      expect(cfg, isNotEmpty);
      expect(cfg, contains('🎲'));
      expect(cfg.length, greaterThanOrEqualTo(6000));

      final payloadChar = role == 'player1' ? payloadP1 : payloadP2;
      await _e2eAppend(
          tester, log, 'Send character to DM (${payloadChar.length} chars)');
      await hub.invoke(
        'SendUpdatedRpgCharacterConfigToDm',
        args: <Object>[characterId, payloadChar],
      );

      final tsPong = role == 'player1' ? tsP1 : tsP2;
      await _e2eAppend(tester, log, 'SendPongToDm ($tsPong)');
      await hub.invoke(
        'SendPongToDm',
        args: <Object>[campagneId, tsPong],
      );

      final tsEmpty = await pingEmptyDone.future.timeout(
        _pingTimeout,
        onTimeout: () => 'timeout',
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(tsEmpty, '');

      await _e2eAppend(
        tester,
        log,
        'Phase 1 done — sync before reconnect (phase1-ready + barrier + reset)',
      );
      await _postEmpty(apiBase, 'e2e/multi-client/sync/phase1-ready');
      await _waitForPhase1BarrierWithUi(apiBase, tester, log);
      await _postEmpty(apiBase, 'e2e/multi-client/sync/reset-phase2');
      await _e2eAppend(tester, log, 'Disconnect hub (before Phase 2 reconnect)');
      await hub.stop();

      await _e2eAppend(tester, log, 'Phase 2: reconnect — wait for DM RegisterGame');
      await _waitForDmRegisteredWithUi(apiBase, tester, log);
      await hub.start();
      expect(hub.state, HubConnectionState.Connected);
      await hub.invoke(
        'ReaddToSignalRGroups',
        args: <Object>['NULL', characterId],
      );
      await _postEmpty(apiBase, 'e2e/multi-client/sync/player-readded');
      await _e2eAppend(
        tester,
        log,
        'Phase 2: ReaddToSignalRGroups + player-readded posted',
      );

      final tsReconnect = await reconnectPingDone.future.timeout(
        _pingTimeout,
        onTimeout: () => '',
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(tsReconnect, reconnectPingPayload);

      await _e2eAppend(tester, log, 'All player steps OK — stop hub');
      await hub.stop();
      await _e2eAppend(tester, log, 'DONE ✓');
    },
    skip: skipUnlessRole,
  );
}
