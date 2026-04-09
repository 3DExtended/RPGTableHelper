import 'package:quest_keeper/constants.dart';

/// One pending hub method invocation (in-memory only).
class PendingHubInvoke {
  PendingHubInvoke({
    required this.functionName,
    required this.args,
    required this.enqueuedAt,
  });

  final String functionName;
  final List<Object>? args;
  final DateTime enqueuedAt;
}

/// In-memory queue for critical SignalR invokes when the connection drops mid-action.
class HubInvokeQueue {
  HubInvokeQueue();

  final List<PendingHubInvoke> _items = [];

  int get length => _items.length;

  void enqueue(String functionName, List<Object>? args) {
    _coalesceBeforeEnqueue(functionName, args);
    if (_items.length >= hubInvokeQueueMaxItems) {
      _items.removeAt(0);
    }
    _items.add(PendingHubInvoke(
      functionName: functionName,
      args: args,
      enqueuedAt: DateTime.now(),
    ));
  }

  void _coalesceBeforeEnqueue(String functionName, List<Object>? args) {
    if (functionName == 'SendUpdatedRpgConfig' && args != null && args.isNotEmpty) {
      final campagneId = args[0].toString();
      _items.removeWhere(
        (p) => p.functionName == 'SendUpdatedRpgConfig' && p.args != null && p.args!.isNotEmpty && p.args![0].toString() == campagneId,
      );
    } else if (functionName == 'SendUpdatedRpgCharacterConfigToDm' &&
        args != null &&
        args.isNotEmpty) {
      final playerId = args[0].toString();
      _items.removeWhere(
        (p) =>
            p.functionName == 'SendUpdatedRpgCharacterConfigToDm' &&
            p.args != null &&
            p.args!.isNotEmpty &&
            p.args![0].toString() == playerId,
      );
    }
  }

  /// Removes and returns the next item, or null if empty.
  PendingHubInvoke? dequeue() {
    if (_items.isEmpty) return null;
    return _items.removeAt(0);
  }

  /// Put back a failed item at the front (drain retry).
  void unshift(PendingHubInvoke item) {
    _items.insert(0, item);
  }

  void clear() => _items.clear();
}
