import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:quest_keeper/main.dart';

abstract class ISnackBarService {
  final bool isMock;
  const ISnackBarService({required this.isMock});

  void showSnackBar({
    required SnackBar snack,
    required String uniqueId,
  });
}

class SnackBarService extends ISnackBarService {
  final Queue<({String uuid, SnackBar snack})> _scheduledSnacks = Queue();
  String? _currentlyShowingSnackUuid;

  SnackBarService() : super(isMock: false);

  static BuildContext? get _context {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      debugPrint("SnackBarService: Context is null!");
    }
    return ctx;
  }

  @override
  void showSnackBar({
    required SnackBar snack,
    required String uniqueId,
  }) {
    if (_context == null) return;

    if (_currentlyShowingSnackUuid == uniqueId ||
        (_scheduledSnacks.isNotEmpty &&
            _scheduledSnacks.last.uuid == uniqueId)) {
      return; // Prevent duplicate consecutive snack bars
    }

    if (_currentlyShowingSnackUuid != null) {
      _scheduledSnacks.add((uuid: uniqueId, snack: snack));
      return;
    }

    _displaySnackBar(snack, uniqueId);
  }

  void _displaySnackBar(SnackBar snack, String uniqueId) {
    final ctx = _context;
    if (ctx == null) return;

    _currentlyShowingSnackUuid = uniqueId;
    ScaffoldMessenger.of(ctx).showSnackBar(snack).closed.then((_) {
      _currentlyShowingSnackUuid = null;
      if (_scheduledSnacks.isNotEmpty) {
        var nextSnack = _scheduledSnacks.removeFirst();
        _displaySnackBar(nextSnack.snack, nextSnack.uuid);
      }
    });
  }
}
