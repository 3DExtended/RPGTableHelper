import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:quest_keeper/constants.dart';
import 'package:signalr_netcore/msgpack_hub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SignalR Echo against local E2ETest API (MessagePack)', (tester) async {
    const fromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    expect(
      fromDefine,
      isNotEmpty,
      reason:
          'Run via scripts/run_flutter_signalr_e2e.sh or pass '
          '--dart-define=API_BASE_URL=http://127.0.0.1:5012/',
    );

    final jwtUri = Uri.parse('${apiBaseUrl}e2e/signalr-test-jwt');
    final res = await http.get(jwtUri);
    expect(res.statusCode, 200, reason: res.body);
    final jwt = res.body.trim();
    expect(jwt.isNotEmpty, true);

    final echoDone = Completer<String>();

    final hub = HubConnectionBuilder()
        .withUrl(
          serverUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => jwt,
            logMessageContent: false,
          ),
        )
        .withHubProtocol(MessagePackHubProtocol())
        .build();

    hub.on('Echo', (List<Object?>? args) {
      if (args != null && args.isNotEmpty && args[0] != null) {
        if (!echoDone.isCompleted) {
          echoDone.complete(args[0]! as String);
        }
      }
    });

    await hub.start();
    expect(hub.state, HubConnectionState.Connected);

    const payload = 'integration_test_echo';
    await hub.invoke('Echo', args: <Object>[payload]);

    final echoed = await echoDone.future
        .timeout(const Duration(seconds: 30), onTimeout: () => '');
    expect(echoed, payload);

    await hub.stop();
  });
}
