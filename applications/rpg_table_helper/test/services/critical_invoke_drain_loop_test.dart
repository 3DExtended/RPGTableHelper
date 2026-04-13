import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/services/hub_invoke_queue.dart';

/// Mirrors [ServerCommunicationService.drainHubInvokeQueue]: dequeue, invoke with
/// maxRetries 1, unshift + break on failure; a later drain pass can succeed.
void main() {
  group('drain loop (matches ServerCommunicationService.drainHubInvokeQueue)', () {
    Future<void> drainOnce(
      HubInvokeQueue q,
      Future<bool> Function(String name, List<Object>? args) invoke,
    ) async {
      var guard = 0;
      while (q.length > 0 && guard < hubInvokeQueueMaxItems * 2) {
        guard++;
        final next = q.dequeue();
        if (next == null) {
          break;
        }
        final ok = await invoke(next.functionName, next.args);
        if (!ok) {
          q.unshift(next);
          break;
        }
      }
    }

    test('single item succeeds on second drain after invoke fails once', () async {
      final q = HubInvokeQueue();
      q.enqueue('SendUpdatedRpgConfig', <Object>['c1', '{}']);
      var attempts = 0;
      Future<bool> invoke(String name, List<Object>? args) async {
        attempts++;
        return attempts >= 2;
      }

      await drainOnce(q, invoke);
      expect(q.length, 1);
      await drainOnce(q, invoke);
      expect(q.length, 0);
      expect(attempts, 2);
    });

    test('processes multiple enqueued items in order when invoke always succeeds', () async {
      final q = HubInvokeQueue();
      q.enqueue('A', <Object>['1']);
      q.enqueue('B', <Object>['2']);
      final seen = <String>[];
      Future<bool> invoke(String name, List<Object>? args) async {
        seen.add(name);
        return true;
      }

      await drainOnce(q, invoke);
      expect(q.length, 0);
      expect(seen, ['A', 'B']);
    });
  });
}
