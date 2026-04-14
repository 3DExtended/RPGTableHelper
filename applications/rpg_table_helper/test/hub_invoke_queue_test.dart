import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/hub_invoke_queue.dart';

void main() {
  group('HubInvokeQueue', () {
    test('coalesces SendUpdatedRpgConfig per campagneId', () {
      final q = HubInvokeQueue();
      q.enqueue('SendUpdatedRpgConfig', ['c1', 'old']);
      expect(q.length, 1);
      q.enqueue('SendUpdatedRpgConfig', ['c1', 'new']);
      expect(q.length, 1);
      final next = q.dequeue();
      expect(next?.args?[1], 'new');
    });

    test('coalesces SendUpdatedRpgCharacterConfigToDm per player id', () {
      final q = HubInvokeQueue();
      q.enqueue('SendUpdatedRpgCharacterConfigToDm', ['p1', 'a']);
      q.enqueue('SendUpdatedRpgCharacterConfigToDm', ['p1', 'b']);
      expect(q.length, 1);
      expect(q.dequeue()?.args?[1], 'b');
    });

    test('coalesces SendUpdatedRpgConfigCold and SendUpdatedRpgConfigColdV3 per campagneId',
        () {
      final q = HubInvokeQueue();
      q.enqueue('SendUpdatedRpgConfigCold', ['c1', '{}']);
      q.enqueue('SendUpdatedRpgConfigColdV3', ['c1', '{"kind":"full"}']);
      expect(q.length, 1);
      expect(q.dequeue()?.functionName, 'SendUpdatedRpgConfigColdV3');
    });

    test('coalesces SendUpdatedRpgCharacterConfigToDm and SendUpdatedRpgCharacterConfigToDmV3',
        () {
      final q = HubInvokeQueue();
      q.enqueue('SendUpdatedRpgCharacterConfigToDm', ['p1', 'a']);
      q.enqueue('SendUpdatedRpgCharacterConfigToDmV3', ['p1', 'b']);
      expect(q.length, 1);
      expect(q.dequeue()?.args?[1], 'b');
    });

    test('unshift preserves order for retry', () {
      final q = HubInvokeQueue();
      q.enqueue('AskPlayersForRolls', ['x', 'y']);
      final item = q.dequeue()!;
      q.unshift(item);
      expect(q.dequeue()?.functionName, 'AskPlayersForRolls');
    });
  });
}
