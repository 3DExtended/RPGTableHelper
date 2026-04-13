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
const Duration _poll = Duration(milliseconds: 400);
const int _e2eMaxLogLines = 32;

Future<Map<String, dynamic>> _getSession(String apiBase, String role) async {
  final uri = Uri.parse('${apiBase}e2e/multi-client/session').replace(
    queryParameters: {'role': role},
  );
  final res = await http.get(uri);
  expect(res.statusCode, 200, reason: res.body);
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _getSync(String apiBase) async {
  final r = await http.get(Uri.parse('${apiBase}e2e/multi-client/sync'));
  expect(r.statusCode, 200, reason: r.body);
  return jsonDecode(r.body) as Map<String, dynamic>;
}

Future<void> _postEmpty(String apiBase, String relativePath) async {
  final uri = Uri.parse('$apiBase$relativePath');
  final r = await http.post(uri);
  expect(r.statusCode, 200, reason: '$uri → ${r.statusCode} ${r.body}');
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

Future<void> _e2eAppend(
  WidgetTester tester,
  ValueNotifier<String> log,
  String line,
) async {
  _e2eLogLine(log, line);
  await tester.pump(const Duration(milliseconds: 16));
}

Future<void> _waitFor(
  String apiBase,
  WidgetTester tester,
  ValueNotifier<String> log,
  bool Function(Map<String, dynamic> j) predicate,
  String label,
) async {
  final until = DateTime.now().add(_barrierTimeout);
  await _e2eAppend(tester, log, 'Wait: $label…');
  while (DateTime.now().isBefore(until)) {
    final j = await _getSync(apiBase);
    if (predicate(j)) {
      await _e2eAppend(tester, log, 'OK: $label ✓');
      return;
    }
    await Future<void>.delayed(_poll);
  }
  fail('Timeout waiting for $label');
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

Future<void> _pumpDashboard(
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
        appBar: AppBar(title: Text('SignalR Mixed Protocol · $role')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: ValueListenableBuilder<String>(
            valueListenable: log,
            builder: (_, v, __) => SingleChildScrollView(
              child: Text(v, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Mixed old/new clients: v1 gets full, v2 gets cold+hot', (tester) async {
    final role = _resolveE2eRole();
    expect(role, anyOf('dm', 'player1', 'player2'));

    expect(
      const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
      isNotEmpty,
      reason: 'Pass --dart-define=API_BASE_URL=http://127.0.0.1:5012/',
    );

    final apiBase = apiBaseUrl;
    final log = ValueNotifier<String>('');
    await _pumpDashboard(tester, role, log);

    final session = await _getSession(apiBase, role);
    final jwt = session['jwt']! as String;
    final campagneId = session['campagneId']! as String;
    final playerCharacterId = session['playerCharacterId'] as String?;

    final hub = _buildHub(jwt);

    final gotLegacyFull = Completer<String>();
    final gotCold = Completer<String>();
    final gotHot = Completer<String>();

    if (role == 'player1') {
      hub.on('updateRpgConfig', (args) {
        final s = args?.first as String?;
        if (s != null &&
            s.contains('"allItems"') &&
            s.contains('"rpgName"') &&
            !gotLegacyFull.isCompleted) {
          gotLegacyFull.complete(s);
        }
      });
    }

    if (role == 'player2') {
      hub.on('updateRpgConfigCold', (args) {
        final s = args?.first as String?;
        if (s != null && !gotCold.isCompleted) gotCold.complete(s);
      });
      hub.on('updateRpgConfigHot', (args) {
        final s = args?.first as String?;
        if (s != null && !gotHot.isCompleted) gotHot.complete(s);
      });
    }

    await hub.start();
    await _e2eAppend(tester, log, 'Hub connected: state=${hub.state}');

    if (role == 'dm') {
      await hub.invoke('RegisterGame', args: [campagneId]);
      await _postEmpty(apiBase, 'e2e/multi-client/sync/dm-game-registered');
      await _e2eAppend(tester, log, 'DM registered game ✓');

      await _waitFor(
        apiBase,
        tester,
        log,
        (j) => (j['playersReaddedCount'] as int? ?? 0) >= 2,
        'playersReaddedCount >= 2',
      );

      const cold = '{"allItems":[{"uuid":"i1"}],"placesOfFindings":[],"itemCategories":[],"characterStatTabsDefinition":null,"craftingRecipes":[],"currencyDefinition":{"currencyTypes":[]}}';
      const hot = '{"rpgName":"MixedProtocolGame"}';
      await hub.invoke('SendUpdatedRpgConfigCold', args: [campagneId, cold]);
      await hub.invoke('SendUpdatedRpgConfigHot', args: [campagneId, hot]);
      await _e2eAppend(tester, log, 'DM sent cold+hot ✓');
    } else {
      await _waitFor(
        apiBase,
        tester,
        log,
        (j) => j['dmGameRegistered'] == true,
        'dmGameRegistered == true',
      );

      expect(playerCharacterId, isNotNull, reason: 'playerCharacterId must be present for players');
      await hub.invoke('ReaddToSignalRGroups', args: ['NULL', playerCharacterId!]);

      if (role == 'player2') {
        // New client: declare protocol v2.
        await hub.invoke('RegisterClientProtocol', args: [2]);
      }

      await _postEmpty(apiBase, 'e2e/multi-client/sync/player-readded');
      await _e2eAppend(tester, log, 'Player readded ✓ (role=$role)');

      if (role == 'player1') {
        final full = await gotLegacyFull.future.timeout(_barrierTimeout);
        full.shouldContain('"rpgName"');
        await _e2eAppend(tester, log, 'Player1 got legacy full ✓');
      } else {
        final cold = await gotCold.future.timeout(_barrierTimeout);
        final hot = await gotHot.future.timeout(_barrierTimeout);
        cold.shouldContain('"allItems"');
        hot.shouldContain('"rpgName"');
        await _e2eAppend(tester, log, 'Player2 got cold+hot ✓');
      }
    }

    await _postEmpty(apiBase, 'e2e/multi-client/sync/phase1-ready');
    await _waitFor(
      apiBase,
      tester,
      log,
      (j) => (j['phase1ReadyCount'] as int? ?? 0) >= 3,
      'phase1ReadyCount >= 3',
    );

    await hub.stop();
  });
}

extension _StrExpect on String {
  void shouldContain(String needle) => expect(this, contains(needle));
}

