import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/hub_invoke_retry.dart';
import 'package:signalr_netcore/signalr_client.dart';

void main() {
  group('waitWhileHubConnectingOrReconnecting', () {
    test('runs sleep while transient then stops', () async {
      var transient = true;
      final delays = <Duration>[];
      Future<void> fakeSleep(Duration d) async {
        delays.add(d);
        transient = false;
      }

      await waitWhileHubConnectingOrReconnecting(
        isConnectingOrReconnecting: () => transient,
        sleep: fakeSleep,
        maxWaitIterations: 5,
      );

      expect(delays.length, 1);
      expect(delays.first, const Duration(seconds: 2));
    });
  });

  group('runHubInvokeWithRetries', () {
    test('returns false when hub missing', () async {
      final logs = <String>[];
      final r = await runHubInvokeWithRetries(
        hubMissing: true,
        hubState: () => null,
        invoke: (_, {args}) => Future.value(null),
        tryOpenConnection: () async => true,
        functionName: 'Echo',
        logSkippedNoHub: logs.add,
        logNotConnected: logs.add,
        logInvokeOk: logs.add,
        logInvokeFailed: (m, e, st) => logs.add(m),
        logGaveUp: (m, e, st) => logs.add(m),
      );
      expect(r, false);
      expect(logs.first, contains('skipped (no hub)'));
    });

    test('invokes once when connected', () async {
      var invocations = 0;
      final r = await runHubInvokeWithRetries(
        hubMissing: false,
        hubState: () => HubConnectionState.Connected,
        invoke: (name, {args}) {
          invocations++;
          return Future.value(null);
        },
        tryOpenConnection: () async => true,
        functionName: 'Echo',
        logSkippedNoHub: (_) {},
        logNotConnected: (_) {},
        logInvokeOk: (_) {},
        logInvokeFailed: (_, __, ___) {},
        logGaveUp: (_, __, ___) {},
      );
      expect(r, true);
      expect(invocations, 1);
    });

    test('retries after failed invoke', () async {
      var n = 0;
      final r = await runHubInvokeWithRetries(
        hubMissing: false,
        hubState: () => HubConnectionState.Connected,
        invoke: (name, {args}) {
          n++;
          if (n == 1) {
            return Future.error(Exception('fail'), StackTrace.current);
          }
          return Future.value(null);
        },
        tryOpenConnection: () async => true,
        functionName: 'Echo',
        maxInvokeRetries: 2,
        logSkippedNoHub: (_) {},
        logNotConnected: (_) {},
        logInvokeOk: (_) {},
        logInvokeFailed: (_, __, ___) {},
        logGaveUp: (_, __, ___) {},
      );
      expect(r, true);
      expect(n, 2);
    });
  });
}
