import 'package:signalr_netcore/signalr_client.dart';

/// Waits while the hub is connecting or reconnecting (bounded), matching [ServerCommunicationService] behavior.
Future<void> waitWhileHubConnectingOrReconnecting({
  required bool Function() isConnectingOrReconnecting,
  Future<void> Function(Duration duration) sleep = Future.delayed,
  int maxWaitIterations = 5,
}) async {
  var waitCounter = 0;
  while (waitCounter < maxWaitIterations && isConnectingOrReconnecting()) {
    waitCounter++;
    await sleep(Duration(seconds: waitCounter + 1));
  }
}

typedef HubInvokeFn = Future<Object?> Function(String name, {List<Object>? args});
typedef HubStateFn = HubConnectionState? Function();
typedef TryOpenConnectionFn = Future<bool> Function();
typedef LogInfoFn = void Function(String message);
typedef LogErrorFn = void Function(String message, Object error, StackTrace st);
typedef LogGiveUpFn = void Function(
    String message, Object? lastError, StackTrace? lastStack);

/// Core invoke/retry loop extracted for unit testing.
Future<bool> runHubInvokeWithRetries({
  required bool hubMissing,
  required HubStateFn hubState,
  required HubInvokeFn invoke,
  required TryOpenConnectionFn tryOpenConnection,
  required String functionName,
  List<Object>? args,
  int maxInvokeRetries = 1,
  required LogInfoFn logSkippedNoHub,
  required LogInfoFn logNotConnected,
  required LogInfoFn logInvokeOk,
  required LogErrorFn logInvokeFailed,
  required LogGiveUpFn logGaveUp,
}) async {
  if (hubMissing) {
    logSkippedNoHub(
        'SignalR executeServerFunction skipped (no hub): $functionName');
    return false;
  }

  await waitWhileHubConnectingOrReconnecting(
    isConnectingOrReconnecting: () {
      final s = hubState();
      return s == HubConnectionState.Connecting ||
          s == HubConnectionState.Reconnecting;
    },
  );

  final attempts = maxInvokeRetries < 1 ? 1 : maxInvokeRetries;
  Object? lastError;
  StackTrace? lastStack;
  for (var attempt = 0; attempt < attempts; attempt++) {
    final state = hubState();
    if (state != HubConnectionState.Connected) {
      logNotConnected(
        'SignalR invoke not connected (attempt ${attempt + 1}/$attempts): $functionName state=$state',
      );
      if (attempt < attempts - 1) {
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        await tryOpenConnection();
      }
      continue;
    }
    try {
      final result = await invoke(functionName, args: args);
      logInvokeOk('SignalR invoke ok: $functionName result=$result');
      return true;
    } catch (e, st) {
      lastError = e;
      lastStack = st;
      logInvokeFailed(
        'SignalR invoke failed (attempt ${attempt + 1}/$attempts): $functionName — $e',
        e,
        st,
      );
      if (attempt < attempts - 1) {
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        await tryOpenConnection();
      }
    }
  }
  if (lastError != null) {
    logGaveUp(
      'SignalR invoke gave up after $attempts attempts: $functionName',
      lastError,
      lastStack,
    );
  }
  return false;
}
