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
  final List<({String uuid, SnackBar snack})> _scheduledSnacks = [];
  String? _currentlyShowingSnackUuid;

  SnackBarService() : super(isMock: false);

  static BuildContext? get context => navigatorKey.currentContext;

  @override
  void showSnackBar({
    required SnackBar snack,
    required String uniqueId,
  }) {
    if (_currentlyShowingSnackUuid == uniqueId) {
      // we dont want to show the same snack bar twice in a row
      return;
    }

    if (_scheduledSnacks.isNotEmpty && _scheduledSnacks.last.uuid == uniqueId) {
      // we dont want to show the same snack bar twice in a row
      return;
    }

    if (_currentlyShowingSnackUuid != null) {
      _scheduledSnacks.add((
        uuid: uniqueId,
        snack: snack,
      ));
      return;
    }

    _currentlyShowingSnackUuid = uniqueId;

    ScaffoldMessenger.of(context!)
        .showSnackBar(snack)
        .closed
        .then((SnackBarClosedReason reason) {
      _currentlyShowingSnackUuid = null;
      if (_scheduledSnacks.isNotEmpty) {
        var nextSnack = _scheduledSnacks.removeAt(0);
        showSnackBar(
          snack: nextSnack.snack,
          uniqueId: nextSnack.uuid,
        );
      }
    });
  }
}
