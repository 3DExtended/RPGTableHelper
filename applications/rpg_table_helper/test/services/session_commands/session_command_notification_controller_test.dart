import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/services/session_commands/session_command_notification_controller.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

void main() {
  group('SessionCommandNotificationController', () {
    late StreamController<List<int>> sseBody;
    late EventsClient eventsClient;

    setUp(() {
      sseBody = StreamController<List<int>>();
      eventsClient = EventsClient(
        getJwt: () async => 'jwt',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async =>
            http.ByteStream(sseBody.stream),
        sleep: (_) async {},
      );
    });

    tearDown(() async {
      await eventsClient.dispose();
      if (!sseBody.isClosed) {
        await sseBody.close();
      }
    });

    test(
        'playersAreAskedForRolls SSE invokes onPlayersAreAskedForRolls with the parsed fight sequence',
        () async {
      FightSequenceNotification? received;
      final sut = SessionCommandNotificationController(
        eventsClient: eventsClient,
        onPlayersAreAskedForRolls: (event) => received = event,
        onDmReceivedFightSequenceAnswer: (_) {},
        onItemsGranted: (_) {},
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: playersAreAskedForRolls\n'
          'data: ${jsonEncode({
            'fightUuid': 'fight-1',
            'sequence': [
              {'characterId': 'pc-1', 'characterName': 'Frodo', 'roll': 12},
              {'characterId': null, 'characterName': 'Goblin', 'roll': 4},
            ],
          })}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, isNotNull);
      expect(received!.fightUuid, 'fight-1');
      expect(received!.sequence, hasLength(2));
      expect(received!.sequence[0].$1, 'pc-1');
      expect(received!.sequence[0].$2, 'Frodo');
      expect(received!.sequence[0].$3, 12);
      expect(received!.sequence[1].$1, isNull);
      expect(received!.sequence[1].$2, 'Goblin');
      expect(received!.sequence[1].$3, 4);

      await sut.stop();
    });

    test(
        'dmReceivedFightSequenceAnswer SSE invokes onDmReceivedFightSequenceAnswer with the parsed fight sequence',
        () async {
      FightSequenceNotification? received;
      final sut = SessionCommandNotificationController(
        eventsClient: eventsClient,
        onPlayersAreAskedForRolls: (_) {},
        onDmReceivedFightSequenceAnswer: (event) => received = event,
        onItemsGranted: (_) {},
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: dmReceivedFightSequenceAnswer\n'
          'data: ${jsonEncode({
            'fightUuid': 'fight-1',
            'sequence': [
              {'characterId': 'pc-1', 'characterName': 'Frodo', 'roll': 9},
            ],
          })}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, isNotNull);
      expect(received!.fightUuid, 'fight-1');
      expect(received!.sequence, hasLength(1));

      await sut.stop();
    });

    test(
        'itemsGranted SSE invokes onItemsGranted with the granted player character id and items',
        () async {
      ItemsGrantedNotification? received;
      final sut = SessionCommandNotificationController(
        eventsClient: eventsClient,
        onPlayersAreAskedForRolls: (_) {},
        onDmReceivedFightSequenceAnswer: (_) {},
        onItemsGranted: (event) => received = event,
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: itemsGranted\n'
          'data: ${jsonEncode({
            'playerCharacterId': 'pc-1',
            'items': [
              {'itemUuid': 'item-1', 'amount': 3},
              {'itemUuid': 'item-2', 'amount': -1},
            ],
          })}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, isNotNull);
      expect(received!.playerCharacterId, 'pc-1');
      expect(received!.items, hasLength(2));
      expect(received!.items[0].itemUuid, 'item-1');
      expect(received!.items[0].amount, 3);
      expect(received!.items[1].itemUuid, 'item-2');
      expect(received!.items[1].amount, -1);

      await sut.stop();
    });

    test('ignores unrelated SSE event types', () async {
      var askedCalls = 0;
      var answerCalls = 0;
      var grantedCalls = 0;
      final sut = SessionCommandNotificationController(
        eventsClient: eventsClient,
        onPlayersAreAskedForRolls: (_) => askedCalls++,
        onDmReceivedFightSequenceAnswer: (_) => answerCalls++,
        onItemsGranted: (_) => grantedCalls++,
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: characterConfigChanged\ndata: {"id":"pc-1","revision":1}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(askedCalls, 0);
      expect(answerCalls, 0);
      expect(grantedCalls, 0);

      await sut.stop();
    });
  });
}
