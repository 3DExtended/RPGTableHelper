import 'package:connectivity_plus/connectivity_plus.dart';

/// What the `/events` stream needs after the device's network changed.
enum NetworkChangeReaction {
  /// Nothing: no network, or the same network reported again. While there is
  /// no network the client's retry loop keeps trying on its own.
  none,

  /// The network is back after none: make sure the stream is up, without
  /// waiting for the next retry.
  ensure,

  /// Switched networks, e.g. Wi-Fi to mobile data: the open connection may
  /// hang on the previous interface until the stale watchdog notices, so
  /// replace it at once.
  reconnect,
}

NetworkChangeReaction reactionToNetworkChange(
  List<ConnectivityResult> previous,
  List<ConnectivityResult> current,
) {
  final hasNetwork = current.any((r) => r != ConnectivityResult.none);
  if (!hasNetwork) {
    return NetworkChangeReaction.none;
  }
  final hadNetwork = previous.any((r) => r != ConnectivityResult.none);
  if (!hadNetwork) {
    return NetworkChangeReaction.ensure;
  }
  final same =
      previous.toSet().containsAll(current) &&
      current.toSet().containsAll(previous);
  return same ? NetworkChangeReaction.none : NetworkChangeReaction.reconnect;
}
