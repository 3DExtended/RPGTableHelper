import 'package:flutter/cupertino.dart';

class PreventSwipeNavigation extends StatelessWidget {
  const PreventSwipeNavigation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        bool value = !(Navigator.of(context).userGestureInProgress);
        if (value) {
          navigator.pop(result);
        }
      },
      child: child,
    );
  }
}
