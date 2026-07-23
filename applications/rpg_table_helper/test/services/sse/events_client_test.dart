import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/services/sse/events_client.dart';
import 'package:quest_keeper/services/sse/sse_parser.dart';

void main() {
  group('SseParser', () {
    test('parses event and data lines', () {
      final parser = SseParser();
      final events = parser.addChunk(
        'event: hello\ndata: {"userId":"abc"}\n\n',
      );
      expect(events, hasLength(1));
      expect(events.single.type, 'hello');
      expect(events.single.data, '{"userId":"abc"}');
    });

    test('ignores comments and handles chunked input', () {
      final parser = SseParser();
      expect(parser.addChunk('event: test\n'), isEmpty);
      expect(parser.addChunk('data: x\n'), isEmpty);
      final events = parser.addChunk('\n');
      expect(events.single.type, 'test');
      expect(events.single.data, 'x');
    });
  });

  group('EventsClient', () {
    test('emits parsed events from opened stream', () async {
      final body = StreamController<List<int>>();
      final client = EventsClient(
        getJwt: () async => 'token',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async {
          expect(uri.path, endsWith('events'));
          expect(jwt, 'token');
          return http.ByteStream(body.stream);
        },
        sleep: (_) async {},
      );

      final received = <SseEvent>[];
      final sub = client.events.listen(received.add);
      await client.start();

      body.add(utf8.encode('event: hello\ndata: {"ok":1}\n\n'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(received, hasLength(1));
      expect(received.single.type, 'hello');

      await sub.cancel();
      await client.dispose();
      await body.close();
    });

    test('on SseAuthFailure refreshes jwt and reconnects', () async {
      var openCount = 0;
      var refreshed = false;
      final body = StreamController<List<int>>();
      final client = EventsClient(
        getJwt: () async => refreshed ? 'new' : 'old',
        refreshJwt: () async {
          refreshed = true;
          return 'new';
        },
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async {
          openCount++;
          if (!refreshed) {
            throw SseAuthFailure();
          }
          expect(jwt, 'new');
          return http.ByteStream(body.stream);
        },
        sleep: (_) async {},
        maxReconnectAttempts: 3,
      );

      await client.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(refreshed, isTrue);
      expect(openCount, greaterThanOrEqualTo(2));

      await client.dispose();
      await body.close();
    });

    test('ensureConnected reopens after stop of subscription', () async {
      var opens = 0;
      StreamController<List<int>>? current;
      final client = EventsClient(
        getJwt: () async => 't',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async {
          opens++;
          current = StreamController<List<int>>();
          return http.ByteStream(current!.stream);
        },
        sleep: (_) async {},
      );

      await client.start();
      expect(opens, 1);
      await current!.close();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      // onDone schedules reconnect
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(opens, greaterThanOrEqualTo(2));

      await client.dispose();
    });
  });
}
