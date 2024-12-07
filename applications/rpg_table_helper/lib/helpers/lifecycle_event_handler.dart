import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget binding observer that handles application lifecycle state changes.
///
/// This class provides callbacks for two main lifecycle events:
/// * When the app resumes from background ([resumeCallBack])
/// * When the app is suspended ([suspendingCallBack])
class LifecycleEventHandler extends WidgetsBindingObserver {
  /// Called when the application resumes from background
  final AsyncCallback? resumeCallBack;

  /// Called when the application is suspended (inactive, hidden, paused, or detached)
  final AsyncCallback? suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack!();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack!();
        }
        break;
    }
  }
}
