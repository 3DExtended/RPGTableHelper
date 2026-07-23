import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/services/notes/note_access_notification_controller.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

void main() {
  group('NoteAccessNotificationController', () {
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
        'noteAccessChanged SSE with changeKind granted invokes onNoteAccessChanged with parsed fields',
        () async {
      NoteAccessChangedEvent? received;
      final sut = NoteAccessNotificationController(
        eventsClient: eventsClient,
        onNoteAccessChanged: (event) => received = event,
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: noteAccessChanged\n'
          'data: ${jsonEncode({
            'campagneId': 'campagne-1',
            'documentId': 'doc-1',
            'blockId': 'block-1',
            'changeKind': 'granted',
          })}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, isNotNull);
      expect(received!.campagneId, 'campagne-1');
      expect(received!.documentId, 'doc-1');
      expect(received!.blockId, 'block-1');
      expect(received!.changeKind, NoteAccessChangeKind.granted);

      await sut.stop();
    });

    test(
        'noteAccessChanged SSE with a null blockId (document-level change) parses blockId as null',
        () async {
      NoteAccessChangedEvent? received;
      final sut = NoteAccessNotificationController(
        eventsClient: eventsClient,
        onNoteAccessChanged: (event) => received = event,
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: noteAccessChanged\n'
          'data: ${jsonEncode({
            'campagneId': 'campagne-1',
            'documentId': 'doc-1',
            'blockId': null,
            'changeKind': 'revoked',
          })}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received, isNotNull);
      expect(received!.blockId, isNull);
      expect(received!.changeKind, NoteAccessChangeKind.revoked);

      await sut.stop();
    });

    test('ignores unrelated SSE event types', () async {
      var calls = 0;
      final sut = NoteAccessNotificationController(
        eventsClient: eventsClient,
        onNoteAccessChanged: (_) => calls++,
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: characterConfigChanged\ndata: {"id":"pc-1","revision":1}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(calls, 0);

      await sut.stop();
    });

    test('ignores noteAccessChanged SSE with an unknown changeKind', () async {
      var calls = 0;
      final sut = NoteAccessNotificationController(
        eventsClient: eventsClient,
        onNoteAccessChanged: (_) => calls++,
      );
      await eventsClient.start();
      sut.start();

      sseBody.add(
        utf8.encode(
          'event: noteAccessChanged\n'
          'data: ${jsonEncode({
            'campagneId': 'campagne-1',
            'documentId': 'doc-1',
            'blockId': null,
            'changeKind': 'somethingUnexpected',
          })}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(calls, 0);

      await sut.stop();
    });
  });
}
