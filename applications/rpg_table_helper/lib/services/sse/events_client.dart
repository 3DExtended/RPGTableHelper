import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/services/sse/sse_parser.dart';

typedef JwtGetter = Future<String?> Function();
typedef JwtRefresher = Future<String?> Function();
typedef EventsStreamOpener = Future<http.ByteStream> Function({
  required Uri uri,
  required String? jwt,
});

/// Long-lived SSE client for `GET /events`.
class EventsClient {
  EventsClient({
    required this.getJwt,
    this.refreshJwt,
    this.baseUrl,
    this.openStream,
    this.sleep,
    this.maxReconnectAttempts = 8,
  });

  final JwtGetter getJwt;
  final JwtRefresher? refreshJwt;
  final String? baseUrl;
  final EventsStreamOpener? openStream;
  final Future<void> Function(Duration delay)? sleep;
  final int maxReconnectAttempts;

  final _controller = StreamController<SseEvent>.broadcast();
  final _parser = SseParser();

  StreamSubscription<List<int>>? _subscription;
  bool _wanted = false;
  bool _connecting = false;
  int _reconnectAttempt = 0;

  Stream<SseEvent> get events => _controller.stream;
  bool get isConnected => _subscription != null;

  /// Last time any SSE bytes (including keepalive comments) were received.
  DateTime? lastActivityAt;

  Future<void> start() async {
    _wanted = true;
    await _connect();
  }

  Future<void> stop() async {
    _wanted = false;
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Drop the current stream and open a fresh one with the current JWT.
  /// Use after login or when the proxy may have silently dropped the connection
  /// while the client still thinks it is connected.
  Future<void> forceReconnect() async {
    _wanted = true;
    await _subscription?.cancel();
    _subscription = null;
    _reconnectAttempt = 0;
    await _connect();
  }

  /// Re-open after app resume (no-op if stop() was called).
  Future<void> ensureConnected() async {
    if (!_wanted) {
      await start();
      return;
    }
    if (_subscription == null && !_connecting) {
      await _connect();
    }
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  Future<void> _connect() async {
    if (!_wanted || _connecting) {
      return;
    }
    _connecting = true;
    var shouldReconnect = false;
    var reconnectImmediate = false;
    try {
      var jwt = await getJwt();
      if (jwt == null || jwt.isEmpty) {
        return;
      }

      final uri = Uri.parse('${_resolvedBaseUrl()}events');
      try {
        final stream = await (openStream ?? _defaultOpenStream)(
          uri: uri,
          jwt: jwt,
        );
        _reconnectAttempt = 0;
        await _subscription?.cancel();
        _subscription = stream.listen(
          (bytes) {
            lastActivityAt = DateTime.now();
            final chunk = utf8.decode(bytes);
            for (final event in _parser.addChunk(chunk)) {
              if (!_controller.isClosed) {
                _controller.add(event);
              }
            }
          },
          onError: (_) {
            unawaited(_scheduleReconnect());
          },
          onDone: () {
            unawaited(_scheduleReconnect());
          },
          cancelOnError: true,
        );
      } on SseAuthFailure {
        final refreshed = refreshJwt == null ? null : await refreshJwt!();
        shouldReconnect = true;
        reconnectImmediate = refreshed != null && refreshed.isNotEmpty;
      } catch (_) {
        shouldReconnect = true;
      }
    } finally {
      _connecting = false;
    }

    if (shouldReconnect) {
      await _scheduleReconnect(immediate: reconnectImmediate);
    }
  }

  Future<void> _scheduleReconnect({bool immediate = false}) async {
    await _subscription?.cancel();
    _subscription = null;
    if (!_wanted) {
      return;
    }
    if (_reconnectAttempt >= maxReconnectAttempts) {
      return;
    }
    final attempt = _reconnectAttempt++;
    final delay = immediate
        ? Duration.zero
        : Duration(milliseconds: (500 * (1 << attempt.clamp(0, 5))).toInt());
    final sleeper = sleep ?? Future<void>.delayed;
    await sleeper(delay);
    if (_wanted) {
      await _connect();
    }
  }

  String _resolvedBaseUrl() {
    final b = baseUrl ?? apiBaseUrl;
    return b.endsWith('/') ? b : '$b/';
  }

  static Future<http.ByteStream> _defaultOpenStream({
    required Uri uri,
    required String? jwt,
  }) async {
    final client = http.Client();
    final request = http.Request('GET', uri);
    if (jwt != null) {
      request.headers['Authorization'] = 'Bearer $jwt';
    }
    request.headers['Accept'] = 'text/event-stream';
    final response = await client.send(request);
    if (response.statusCode == 401 || response.statusCode == 403) {
      client.close();
      throw SseAuthFailure();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      client.close();
      throw Exception('SSE connect failed: ${response.statusCode}');
    }
    final controller = StreamController<List<int>>();
    response.stream.listen(
      controller.add,
      onError: (Object e, StackTrace st) {
        controller.addError(e, st);
        client.close();
      },
      onDone: () {
        controller.close();
        client.close();
      },
      cancelOnError: true,
    );
    return http.ByteStream(controller.stream);
  }
}

class SseAuthFailure implements Exception {}
