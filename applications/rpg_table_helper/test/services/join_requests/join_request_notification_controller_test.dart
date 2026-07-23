import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/services/join_requests/join_request_notification_controller.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

void main() {
  group('JoinRequestNotificationController', () {
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
        'joinRequestCreated SSE invokes onJoinRequestCreated with the request identity and player display info',
        () async {
      JoinRequestCreatedEvent? received;
      final sut = JoinRequestNotificationController(
        eventsClient: eventsClient,
        onJoinRequestCreated: (event) => received = event,
        onJoinRequestResolved: (_) {},
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: joinRequestCreated\n'
          'data: ${jsonEncode({
            'requestId': 'req-1',
            'campagneId': 'campagne-1',
            'playerCharacterId': 'pc-1',
            'playerName': 'Hero',
            'username': 'player1',
          })}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, isNotNull);
      expect(received!.requestId, 'req-1');
      expect(received!.campagneId, 'campagne-1');
      expect(received!.playerCharacterId, 'pc-1');
      expect(received!.playerName, 'Hero');
      expect(received!.username, 'player1');

      await sut.stop();
    });

    test(
        'joinRequestResolved SSE invokes onJoinRequestResolved with accepted=true for Accept',
        () async {
      JoinRequestResolvedEvent? received;
      final sut = JoinRequestNotificationController(
        eventsClient: eventsClient,
        onJoinRequestCreated: (_) {},
        onJoinRequestResolved: (event) => received = event,
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: joinRequestResolved\n'
          'data: ${jsonEncode({
            'requestId': 'req-1',
            'campagneId': 'campagne-1',
            'type': 'Accept',
          })}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, isNotNull);
      expect(received!.requestId, 'req-1');
      expect(received!.campagneId, 'campagne-1');
      expect(received!.accepted, isTrue);

      await sut.stop();
    });

    test(
        'joinRequestResolved SSE invokes onJoinRequestResolved with accepted=false for Deny',
        () async {
      JoinRequestResolvedEvent? received;
      final sut = JoinRequestNotificationController(
        eventsClient: eventsClient,
        onJoinRequestCreated: (_) {},
        onJoinRequestResolved: (event) => received = event,
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: joinRequestResolved\n'
          'data: ${jsonEncode({
            'requestId': 'req-1',
            'campagneId': 'campagne-1',
            'type': 'Deny',
          })}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, isNotNull);
      expect(received!.accepted, isFalse);

      await sut.stop();
    });

    test('ignores unrelated SSE event types', () async {
      var createdCalls = 0;
      var resolvedCalls = 0;
      final sut = JoinRequestNotificationController(
        eventsClient: eventsClient,
        onJoinRequestCreated: (_) => createdCalls++,
        onJoinRequestResolved: (_) => resolvedCalls++,
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: campagneConfigChanged\ndata: {"id":"campagne-1","revision":1}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(createdCalls, 0);
      expect(resolvedCalls, 0);

      await sut.stop();
    });
  });

  group('JoinRequestCreatedEvent', () {
    test('converts to a PlayerJoinRequests model', () {
      const event = JoinRequestCreatedEvent(
        requestId: 'req-1',
        campagneId: 'campagne-1',
        playerCharacterId: 'pc-1',
        playerName: 'Hero',
        username: 'player1',
      );

      final playerJoinRequest = event.toPlayerJoinRequest();

      expect(playerJoinRequest.campagneJoinRequestId, 'req-1');
      expect(playerJoinRequest.playerCharacterId, 'pc-1');
      expect(playerJoinRequest.playerName, 'Hero');
      expect(playerJoinRequest.username, 'player1');
    });
  });
}
