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
    test('connected fires on the first open and on every reconnect', () async {
      StreamController<List<int>>? current;
      final client = EventsClient(
        getJwt: () async => 't',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async {
          current = StreamController<List<int>>();
          return http.ByteStream(current!.stream);
        },
        sleep: (_) async {},
      );
      var connectedCount = 0;
      final sub = client.connected.listen((_) => connectedCount++);

      await client.start();
      await Future<void>.delayed(Duration.zero);
      expect(connectedCount, 1);

      await current!.close();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(connectedCount, 2);

      await sub.cancel();
      await client.dispose();
    });

    test('ensureConnected replaces a stream that went silent', () async {
      var opens = 0;
      var clock = DateTime(2026, 10, 3, 12);
      final client = EventsClient(
        getJwt: () async => 't',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async {
          opens++;
          return http.ByteStream(StreamController<List<int>>().stream);
        },
        sleep: (_) async {},
        now: () => clock,
      );

      await client.start();
      expect(opens, 1);

      clock = clock.add(const Duration(seconds: 10));
      await client.ensureConnected();
      expect(opens, 1, reason: 'a fresh stream is kept');

      clock = clock.add(const Duration(minutes: 5));
      await client.ensureConnected();
      expect(
        opens,
        2,
        reason: 'no keepalive for minutes means the stream is dead',
      );

      await client.dispose();
    });
  });

  group('EventsClient while the server is down', () {
    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 20));

    test('keeps retrying past 8 attempts until the server is back', () async {
      var opens = 0;
      final delays = <Duration>[];
      final body = StreamController<List<int>>();
      final client = EventsClient(
        getJwt: () async => 't',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async {
          opens++;
          if (opens <= 20) {
            throw Exception('server down');
          }
          return http.ByteStream(body.stream);
        },
        sleep: (delay) async => delays.add(delay),
      );

      await client.start();
      await settle();

      expect(opens, 21);
      expect(client.isConnected, isTrue);
      expect(client.status.value, EventsConnectionStatus.connected);
      expect(
        delays.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b),
        lessThanOrEqualTo(16000),
        reason: 'the backoff is capped, so recovery is noticed quickly',
      );

      await client.dispose();
      await body.close();
    });

    test('start returns after the first attempt instead of waiting for the '
        'server', () async {
      final client = EventsClient(
        getJwt: () async => 't',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async =>
            throw Exception('server down'),
        // A retry that never wakes up: start must not wait for it.
        sleep: (_) => Completer<void>().future,
      );

      await client.start().timeout(const Duration(seconds: 1));

      await client.dispose();
    });

    test(
      'reports unreachable after repeated failures and connected once back',
      () async {
        var serverUp = false;
        final sleeps = <Completer<void>>[];
        final body = StreamController<List<int>>();
        final client = EventsClient(
          getJwt: () async => 't',
          baseUrl: 'http://example.test/',
          openStream: ({required uri, required jwt}) async {
            if (!serverUp) {
              throw Exception('server down');
            }
            return http.ByteStream(body.stream);
          },
          sleep: (_) {
            final c = Completer<void>();
            sleeps.add(c);
            return c.future;
          },
        );
        final seen = <EventsConnectionStatus>[];
        client.status.addListener(() => seen.add(client.status.value));

        await client.start();
        await settle();
        expect(
          client.status.value,
          EventsConnectionStatus.reconnecting,
          reason: 'one failure is not worth alarming anyone',
        );

        sleeps.last.complete();
        await settle();
        expect(
          client.status.value,
          EventsConnectionStatus.reconnecting,
          reason: 'an app resume may need a moment for the network',
        );

        sleeps.last.complete();
        await settle();
        expect(client.status.value, EventsConnectionStatus.unreachable);

        serverUp = true;
        sleeps.last.complete();
        await settle();
        expect(client.status.value, EventsConnectionStatus.connected);
        expect(seen, [
          EventsConnectionStatus.connecting,
          EventsConnectionStatus.reconnecting,
          EventsConnectionStatus.unreachable,
          EventsConnectionStatus.connected,
        ]);

        await client.dispose();
        await body.close();
      },
    );

    test('a dropped stream reports reconnecting, not unreachable', () async {
      StreamController<List<int>>? current;
      final sleeps = <Completer<void>>[];
      final client = EventsClient(
        getJwt: () async => 't',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async {
          current = StreamController<List<int>>();
          return http.ByteStream(current!.stream);
        },
        sleep: (_) {
          final c = Completer<void>();
          sleeps.add(c);
          return c.future;
        },
      );

      await client.start();
      await current!.close();
      await settle();

      expect(client.status.value, EventsConnectionStatus.reconnecting);

      sleeps.last.complete();
      await settle();
      expect(client.status.value, EventsConnectionStatus.connected);

      await client.dispose();
    });

    test('stop ends the retry loop', () async {
      var opens = 0;
      final sleeps = <Completer<void>>[];
      final client = EventsClient(
        getJwt: () async => 't',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async {
          opens++;
          throw Exception('server down');
        },
        sleep: (_) {
          final c = Completer<void>();
          sleeps.add(c);
          return c.future;
        },
      );

      await client.start();
      await settle();
      expect(opens, 1);

      await client.stop();
      expect(client.status.value, EventsConnectionStatus.idle);

      sleeps.last.complete();
      await settle();
      expect(opens, 1);

      await client.dispose();
    });

    test('ensureConnected during a pending retry does not start a second '
        'retry chain', () async {
      var opens = 0;
      final sleeps = <Completer<void>>[];
      final client = EventsClient(
        getJwt: () async => 't',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async {
          opens++;
          throw Exception('server down');
        },
        sleep: (_) {
          final c = Completer<void>();
          sleeps.add(c);
          return c.future;
        },
      );

      await client.start();
      await settle();
      await client.ensureConnected();
      await settle();
      expect(opens, 2);
      expect(sleeps, hasLength(2));

      sleeps[0].complete();
      await settle();
      expect(opens, 2, reason: 'the superseded retry must not fire');

      sleeps[1].complete();
      await settle();
      expect(opens, 3);

      await client.dispose();
    });

    test('stop while the stream is still opening drops it', () async {
      final opening = Completer<http.ByteStream>();
      var listened = false;
      final body = StreamController<List<int>>(onListen: () => listened = true);
      final client = EventsClient(
        getJwt: () async => 't',
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) => opening.future,
        sleep: (_) async {},
      );

      final started = client.start();
      await settle();
      await client.stop();
      opening.complete(http.ByteStream(body.stream));
      await started;
      await settle();

      expect(client.isConnected, isFalse);
      expect(client.status.value, EventsConnectionStatus.idle);
      expect(body.hasListener, isFalse, reason: 'the request is cancelled');
      expect(listened, isTrue);

      await client.dispose();
      await body.close();
    });

    test('no signed-in user means idle, not retrying', () async {
      var opens = 0;
      final client = EventsClient(
        getJwt: () async => null,
        baseUrl: 'http://example.test/',
        openStream: ({required uri, required jwt}) async {
          opens++;
          return http.ByteStream(const Stream.empty());
        },
        sleep: (_) async {},
      );

      await client.start();
      await settle();

      expect(opens, 0);
      expect(client.status.value, EventsConnectionStatus.idle);

      await client.dispose();
    });
  });

  group('EventsClient stale watchdog', () {
    test(
      'replaces a silent stream without waiting for an app resume',
      () async {
        var opens = 0;
        var clock = DateTime(2026, 11, 16, 12);
        final client = EventsClient(
          getJwt: () async => 't',
          baseUrl: 'http://example.test/',
          openStream: ({required uri, required jwt}) async {
            opens++;
            return http.ByteStream(StreamController<List<int>>().stream);
          },
          sleep: (_) async {},
          now: () => clock,
          staleCheckInterval: const Duration(milliseconds: 5),
        );

        await client.start();
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(opens, 1, reason: 'a fresh stream is kept');

        clock = clock.add(const Duration(minutes: 1));
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(opens, 2);

        await client.stop();
        clock = clock.add(const Duration(minutes: 5));
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(opens, 2, reason: 'a stopped client stays stopped');

        await client.dispose();
      },
    );
  });
}
