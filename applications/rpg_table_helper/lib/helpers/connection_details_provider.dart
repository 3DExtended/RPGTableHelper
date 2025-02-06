import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/models/connection_details.dart';

final connectionDetailsProvider = StateNotifierProvider<
    ConnectionDetailsNotifier, AsyncValue<ConnectionDetails>>((ref) {
  return ConnectionDetailsNotifier(
    initState: AsyncValue.data(ConnectionDetails.defaultValue()),
    ref: ref,
    runningInTests: false,
  );
});

class ConnectionDetailsNotifier
    extends StateNotifier<AsyncValue<ConnectionDetails>> {
  final StateNotifierProviderRef<ConnectionDetailsNotifier,
      AsyncValue<ConnectionDetails>> ref;
  bool runningInTests;
  ConnectionDetailsNotifier({
    required AsyncValue<ConnectionDetails> initState,
    required this.runningInTests,
    required this.ref,
  }) : super(initState);

  AsyncValue<ConnectionDetails> getState() {
    return state;
  }

  void updateConfiguration(ConnectionDetails config) {
    state = AsyncValue.data(config);
  }
}
