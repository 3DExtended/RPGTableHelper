import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/config_sync/config_sync_coordinator.dart';
import 'package:quest_keeper/services/config_sync/config_sync_models.dart';

void main() {
  group('ConfigSyncCoordinator', () {
    test('hydrate() seeds revision and applies the full document', () async {
      final coordinator = ConfigSyncCoordinator(
        write: (fromRevision, json) async => fail('write should not be called'),
        read: (sinceRevision) async {
          expect(sinceRevision, isNull);
          return HRResponse.fromResult(
            const ConfigSnapshot(
              kind: 'full',
              revision: 3,
              fullConfig: '{"name":"old"}',
            ),
          );
        },
        applyFull: (json, revision) {},
        applyPatch: (ops, revision) => fail('applyPatch should not be called'),
      );

      await coordinator.hydrate();

      expect(coordinator.revision, 3);
    });

    test('notifyLocalEdit debounces and coalesces to the latest desired doc',
        () async {
      final writeCalls = <String>[];
      final coordinator = ConfigSyncCoordinator(
        write: (fromRevision, json) async {
          writeCalls.add(json);
          return HRResponse.fromResult(const ConfigWriteResult(revision: 2));
        },
        read: (sinceRevision) async =>
            HRResponse.error('unused', 'unused-code'),
        applyFull: (json, revision) {},
        applyPatch: (ops, revision) {},
        debounceDuration: const Duration(milliseconds: 20),
      );
      coordinator.seed(revision: 1);

      coordinator.notifyLocalEdit('{"v":1}');
      coordinator.notifyLocalEdit('{"v":2}');
      coordinator.notifyLocalEdit('{"v":3}');

      expect(coordinator.hasPendingLocalEdit, isTrue);
      expect(writeCalls, isEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(writeCalls, ['{"v":3}']);
      expect(coordinator.revision, 2);
    });

    test('flushNow() sends only one write while another is in flight',
        () async {
      var inFlightCount = 0;
      var maxConcurrent = 0;
      final coordinator = ConfigSyncCoordinator(
        write: (fromRevision, json) async {
          inFlightCount++;
          maxConcurrent =
              inFlightCount > maxConcurrent ? inFlightCount : maxConcurrent;
          await Future<void>.delayed(const Duration(milliseconds: 30));
          inFlightCount--;
          return HRResponse.fromResult(const ConfigWriteResult(revision: 2));
        },
        read: (sinceRevision) async =>
            HRResponse.error('unused', 'unused-code'),
        applyFull: (json, revision) {},
        applyPatch: (ops, revision) {},
      );
      coordinator.seed(revision: 1);

      coordinator.notifyLocalEdit('{"v":1}');
      final firstFlush = coordinator.flushNow();
      // A second local edit arrives while the first write is in flight; it
      // must not start a second concurrent write (single in-flight write).
      coordinator.notifyLocalEdit('{"v":2}');
      final secondFlush = coordinator.flushNow();

      await Future.wait([firstFlush, secondFlush]);

      expect(maxConcurrent, 1);
      expect(coordinator.revision, 2);
    });

    test('on 409 it GETs, rebases, and retries the same desired edit',
        () async {
      final writeAttempts = <int?>[];
      var getCalls = 0;
      final coordinator = ConfigSyncCoordinator(
        write: (fromRevision, json) async {
          writeAttempts.add(fromRevision);
          if (fromRevision == 1) {
            return HRResponse.error<ConfigWriteResult>(
              'stale',
              'stale-code',
              statusCode: 409,
            );
          }
          return HRResponse.fromResult(const ConfigWriteResult(revision: 5));
        },
        read: (sinceRevision) async {
          getCalls++;
          return HRResponse.fromResult(
            const ConfigSnapshot(
              kind: 'full',
              revision: 4,
              fullConfig: '{"name":"fromServer"}',
            ),
          );
        },
        applyFull: (json, revision) {},
        applyPatch: (ops, revision) => fail('applyPatch should not be called'),
      );
      coordinator.seed(revision: 1);

      coordinator.notifyLocalEdit('{"name":"local"}');
      await coordinator.flushNow();

      expect(writeAttempts, [1, 4]);
      expect(getCalls, 1);
      expect(coordinator.revision, 5);
    });

    test('gives up retrying after maxConflictRetriesPerFlush consecutive 409s',
        () async {
      var writeCount = 0;
      var getCount = 0;
      final coordinator = ConfigSyncCoordinator(
        write: (fromRevision, json) async {
          writeCount++;
          return HRResponse.error<ConfigWriteResult>(
            'stale',
            'stale-code',
            statusCode: 409,
          );
        },
        read: (sinceRevision) async {
          getCount++;
          return HRResponse.fromResult(
            ConfigSnapshot(
                kind: 'full', revision: getCount + 1, fullConfig: '{}'),
          );
        },
        applyFull: (json, revision) {},
        applyPatch: (ops, revision) {},
        maxConflictRetriesPerFlush: 2,
      );
      coordinator.seed(revision: 1);

      coordinator.notifyLocalEdit('{"name":"local"}');
      await coordinator.flushNow();

      // initial attempt + 2 retries = 3 write calls, then it stops.
      expect(writeCount, 3);
      expect(coordinator.hasPendingLocalEdit, isFalse);
    });

    test('onRemoteChanged applies a returned patch via applyPatch', () async {
      List<dynamic>? appliedOps;
      int? appliedRevision;
      final coordinator = ConfigSyncCoordinator(
        write: (fromRevision, json) async => fail('write should not be called'),
        read: (sinceRevision) async {
          expect(sinceRevision, 3);
          return HRResponse.fromResult(
            const ConfigSnapshot(
              kind: 'patch',
              revision: 4,
              fromRevision: 3,
              patch: '[{"op":"replace","path":"/hp","value":5}]',
            ),
          );
        },
        applyFull: (json, revision) => fail('applyFull should not be called'),
        applyPatch: (ops, revision) {
          appliedOps = ops;
          appliedRevision = revision;
        },
      );
      coordinator.seed(revision: 3);

      await coordinator.onRemoteChanged(4);

      expect(appliedRevision, 4);
      expect(appliedOps, [
        {'op': 'replace', 'path': '/hp', 'value': 5}
      ]);
      expect(coordinator.revision, 4);
    });

    test(
        'onRemoteChanged applies a full document via applyFull when kind is full',
        () async {
      String? appliedJson;
      final coordinator = ConfigSyncCoordinator(
        write: (fromRevision, json) async => fail('write should not be called'),
        read: (sinceRevision) async => HRResponse.fromResult(
          const ConfigSnapshot(
            kind: 'full',
            revision: 9,
            fullConfig: '{"name":"fresh"}',
          ),
        ),
        applyFull: (json, revision) => appliedJson = json,
        applyPatch: (ops, revision) => fail('applyPatch should not be called'),
      );
      coordinator.seed(revision: 1);

      await coordinator.onRemoteChanged(9);

      expect(appliedJson, '{"name":"fresh"}');
      expect(coordinator.revision, 9);
    });

    test('onRemoteChanged is a no-op when the notified revision is stale',
        () async {
      var readCalls = 0;
      final coordinator = ConfigSyncCoordinator(
        write: (fromRevision, json) async => fail('write should not be called'),
        read: (sinceRevision) async {
          readCalls++;
          return HRResponse.error('unused', 'unused-code');
        },
        applyFull: (json, revision) {},
        applyPatch: (ops, revision) {},
      );
      coordinator.seed(revision: 5);

      await coordinator.onRemoteChanged(5);
      await coordinator.onRemoteChanged(3);

      expect(readCalls, 0);
    });

    test('onRemoteChanged is skipped while a write is in flight', () async {
      var readCalls = 0;
      final coordinator = ConfigSyncCoordinator(
        write: (fromRevision, json) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return HRResponse.fromResult(const ConfigWriteResult(revision: 2));
        },
        read: (sinceRevision) async {
          readCalls++;
          return HRResponse.error('unused', 'unused-code');
        },
        applyFull: (json, revision) {},
        applyPatch: (ops, revision) {},
      );
      coordinator.seed(revision: 1);

      coordinator.notifyLocalEdit('{"v":1}');
      final flush = coordinator.flushNow();

      await coordinator.onRemoteChanged(2);
      expect(readCalls, 0);

      await flush;
    });

    test('dispose() cancels a pending debounced flush', () async {
      var writeCalls = 0;
      final coordinator = ConfigSyncCoordinator(
        write: (fromRevision, json) async {
          writeCalls++;
          return HRResponse.fromResult(const ConfigWriteResult(revision: 2));
        },
        read: (sinceRevision) async => HRResponse.error('unused', 'unused'),
        applyFull: (json, revision) {},
        applyPatch: (ops, revision) {},
        debounceDuration: const Duration(milliseconds: 10),
      );
      coordinator.seed(revision: 1);

      coordinator.notifyLocalEdit('{"v":1}');
      coordinator.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(writeCalls, 0);
    });
  });
}
