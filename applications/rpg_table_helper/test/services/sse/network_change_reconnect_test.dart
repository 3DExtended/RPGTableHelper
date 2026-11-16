import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/sse/network_change_reconnect.dart';

void main() {
  const wifi = [ConnectivityResult.wifi];
  const mobile = [ConnectivityResult.mobile];
  const none = [ConnectivityResult.none];

  test('network back after none: make sure the stream is up', () {
    expect(reactionToNetworkChange(none, wifi), NetworkChangeReaction.ensure);
  });

  test('switch from wifi to mobile data: replace the stream at once', () {
    expect(
      reactionToNetworkChange(wifi, mobile),
      NetworkChangeReaction.reconnect,
      reason: 'the old connection may hang on the previous interface',
    );
  });

  test('network gone: nothing to do, the retry loop takes over', () {
    expect(reactionToNetworkChange(wifi, none), NetworkChangeReaction.none);
  });

  test('same network reported again: nothing to do', () {
    expect(
      reactionToNetworkChange(wifi, [ConnectivityResult.wifi]),
      NetworkChangeReaction.none,
    );
    expect(
      reactionToNetworkChange(
        [ConnectivityResult.wifi, ConnectivityResult.vpn],
        [ConnectivityResult.vpn, ConnectivityResult.wifi],
      ),
      NetworkChangeReaction.none,
    );
  });
}
