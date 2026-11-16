import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/services/sse/sse_parser.dart';

typedef JwtGetter = Future<String?> Function();
typedef JwtRefresher = Future<String?> Function();
typedef EventsStreamOpener = Future<http.ByteStream> Function({
  required Uri uri,
  required String? jwt,
});

/// State of the `/events` stream, for showing the user whether live updates
/// are flowing.
enum EventsConnectionStatus {
  /// Not started, stopped, or nobody is signed in.
  idle,

  /// Opening the stream for the first time since [EventsClient.start].
  connecting,

  /// The stream is open.
  connected,

  /// The stream dropped and a reconnect is under way. Usually over within a
  /// second or two, so not worth alarming anyone.
  reconnecting,

  /// Several reconnects in a row failed: the server is unreachable. The
  /// client keeps retrying, but live updates are missing until it is back.
  unreachable,
}

/// Long-lived SSE client for `GET /events`.
class EventsClient {
  EventsClient({
    required this.getJwt,
    this.refreshJwt,
    this.baseUrl,
    this.openStream,
    this.sleep,
    this.maxReconnectAttempts,
    this.unreachableAfterFailures = 3,
    this.staleCheckInterval,
    this.now,
  });

  final JwtGetter getJwt;
  final JwtRefresher? refreshJwt;
  final String? baseUrl;
  final EventsStreamOpener? openStream;
  final Future<void> Function(Duration delay)? sleep;

  /// Gives up after this many reconnects in a row; `null` keeps retrying for
  /// as long as the stream is wanted. A table session has to come back on its
  /// own after a server restart or a longer network gap, so the app leaves
  /// this unlimited.
  final int? maxReconnectAttempts;

  /// Consecutive failed connects before [status] turns
  /// [EventsConnectionStatus.unreachable]. With the backoff that is about
  /// 3.5 s, enough for the network to wake up after an app resume without
  /// flashing the hint.
  final int unreachableAfterFailures;

  /// How often to check for a stream that looks open but has gone silent
  /// (see [staleAfter]). `null` checks only on [ensureConnected], e.g. app
  /// resume; tests leave it off so no periodic timer outlives them.
  final Duration? staleCheckInterval;
  final DateTime Function()? now;

  /// Longest wait between two reconnects.
  static const maxReconnectDelay = Duration(seconds: 16);

  /// The backend writes a keepalive comment every 15s; a stream that has been
  /// silent for much longer than that is dead even if it was never closed
  /// (typical after the iPad was locked or the proxy dropped the connection).
  static const staleAfter = Duration(seconds: 45);

  final _controller = StreamController<SseEvent>.broadcast();
  final _connectedController = StreamController<void>.broadcast();
  final _parser = SseParser();

  final _status = ValueNotifier(EventsConnectionStatus.idle);

  StreamSubscription<List<int>>? _subscription;
  bool _wanted = false;
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempt = 0;
  int _consecutiveFailures = 0;

  /// Bumped whenever a new reconnect is scheduled or an explicit connect
  /// starts, so a retry that is still sleeping knows it has been superseded.
  int _retryGeneration = 0;
  Timer? _staleWatchdog;

  Stream<SseEvent> get events => _controller.stream;

  /// Whether live updates are flowing; drives the "no connection" hint.
  ValueListenable<EventsConnectionStatus> get status => _status;

  /// Fires every time the `/events` stream has been (re)opened. The backend
  /// drops table-session presence after a longer disconnect, so session
  /// owners listen to this to re-enter their session.
  Stream<void> get connected => _connectedController.stream;
  bool get isConnected => _subscription != null;

  /// Last time any SSE bytes (including keepalive comments) were received.
  DateTime? lastActivityAt;

  /// Opens the stream. Returns after the first attempt; if that fails, the
  /// client keeps retrying in the background.
  Future<void> start() async {
    _wanted = true;
    _startStaleWatchdog();
    _retryGeneration++;
    await _connect();
  }

  Future<void> stop() async {
    _wanted = false;
    _retryGeneration++;
    _staleWatchdog?.cancel();
    _staleWatchdog = null;
    await _subscription?.cancel();
    _subscription = null;
    _consecutiveFailures = 0;
    _setStatus(EventsConnectionStatus.idle);
  }

  /// Drop the current stream and open a fresh one with the current JWT.
  /// Use after login or when the proxy may have silently dropped the connection
  /// while the client still thinks it is connected.
  Future<void> forceReconnect() async {
    _wanted = true;
    _startStaleWatchdog();
    _retryGeneration++;
    await _subscription?.cancel();
    _subscription = null;
    _reconnectAttempt = 0;
    await _connect();
  }

  /// Re-open after app resume or when the network comes back. Also replaces
  /// a stream that still looks open but has gone silent (see [staleAfter]),
  /// and retries even if the automatic reconnects had already given up.
  Future<void> ensureConnected() async {
    if (!_wanted) {
      await start();
      return;
    }
    _reconnectAttempt = 0;
    if (_subscription != null && !_connecting && _isStale) {
      await forceReconnect();
      return;
    }
    if (_subscription == null && !_connecting) {
      _retryGeneration++;
      await _connect();
    }
  }

  /// Replaces the stream right away after the device switched networks (e.g.
  /// Wi-Fi to mobile data), when the open connection may hang on the previous
  /// interface. Does nothing while the stream is not wanted, e.g. signed out.
  Future<void> reconnectAfterNetworkChange() async {
    if (_wanted) {
      await forceReconnect();
    }
  }

  /// Replaces a stream that looks open but has been silent for longer than
  /// [staleAfter]. Runs every [staleCheckInterval] while the stream is wanted.
  Future<void> reconnectIfStale() async {
    if (_wanted && _subscription != null && !_connecting && _isStale) {
      await forceReconnect();
    }
  }

  void _startStaleWatchdog() {
    final interval = staleCheckInterval;
    if (interval == null || _staleWatchdog != null) {
      return;
    }
    _staleWatchdog = Timer.periodic(
      interval,
      (_) => unawaited(reconnectIfStale()),
    );
  }

  void _setStatus(EventsConnectionStatus value) {
    if (!_disposed) {
      _status.value = value;
    }
  }

  bool get _isStale {
    final last = lastActivityAt;
    if (last == null) return false;
    return (now ?? DateTime.now)().difference(last) > staleAfter;
  }

  Future<void> dispose() async {
    await stop();
    _disposed = true;
    _status.dispose();
    await _controller.close();
    await _connectedController.close();
  }

  /// One attempt to open the stream. On failure it schedules the next retry
  /// in the background instead of waiting for it, so callers that await
  /// [start] or [ensureConnected] are not held up while the server is down.
  Future<void> _connect() async {
    if (!_wanted || _connecting) {
      return;
    }
    _connecting = true;
    if (_status.value == EventsConnectionStatus.idle) {
      _setStatus(EventsConnectionStatus.connecting);
    }
    var shouldReconnect = false;
    var reconnectImmediate = false;
    try {
      var jwt = await getJwt();
      if (jwt == null || jwt.isEmpty) {
        // Nobody signed in (or the session was just cleared): nothing to
        // retry until a login calls forceReconnect.
        _setStatus(EventsConnectionStatus.idle);
        return;
      }

      final uri = Uri.parse('${_resolvedBaseUrl()}events');
      try {
        final stream = await (openStream ?? _defaultOpenStream)(
          uri: uri,
          jwt: jwt,
        );
        if (!_wanted) {
          // Stopped while the request was in flight.
          unawaited(stream.listen(null).cancel());
          return;
        }
        _reconnectAttempt = 0;
        _consecutiveFailures = 0;
        await _subscription?.cancel();
        lastActivityAt = (now ?? DateTime.now)();
        late final StreamSubscription<List<int>> subscription;
        void onLost() {
          // Only the current stream may trigger a reconnect; one replaced by
          // forceReconnect was cancelled on purpose.
          if (identical(_subscription, subscription)) {
            unawaited(_scheduleReconnect());
          }
        }

        subscription = stream.listen(
          (bytes) {
            lastActivityAt = (now ?? DateTime.now)();
            final chunk = utf8.decode(bytes);
            for (final event in _parser.addChunk(chunk)) {
              if (!_controller.isClosed) {
                _controller.add(event);
              }
            }
          },
          onError: (_) => onLost(),
          onDone: onLost,
          cancelOnError: true,
        );
        _subscription = subscription;
        _setStatus(EventsConnectionStatus.connected);
        if (!_connectedController.isClosed) {
          _connectedController.add(null);
        }
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
      _consecutiveFailures++;
      unawaited(_scheduleReconnect(immediate: reconnectImmediate));
    }
  }

  Future<void> _scheduleReconnect({bool immediate = false}) async {
    final generation = ++_retryGeneration;
    final lost = _subscription;
    _subscription = null;
    if (!_wanted) {
      await lost?.cancel();
      return;
    }
    final max = maxReconnectAttempts;
    final givingUp = max != null && _reconnectAttempt >= max;
    // Set before the first await, so listeners see it right away.
    _setStatus(
      givingUp || _consecutiveFailures >= unreachableAfterFailures
          ? EventsConnectionStatus.unreachable
          : EventsConnectionStatus.reconnecting,
    );
    await lost?.cancel();
    if (givingUp) {
      return;
    }
    final attempt = _reconnectAttempt++;
    final delay = immediate
        ? Duration.zero
        : Duration(
            milliseconds: (500 * (1 << attempt.clamp(0, 5))).clamp(
              0,
              maxReconnectDelay.inMilliseconds,
            ),
          );
    final sleeper = sleep ?? Future<void>.delayed;
    await sleeper(delay);
    if (_wanted && generation == _retryGeneration && _subscription == null) {
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
