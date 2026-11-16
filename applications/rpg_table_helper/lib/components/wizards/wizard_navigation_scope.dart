import 'package:flutter/widgets.dart';

/// Gives wizard step bodies access to the wizard's position and navigation
/// without threading it through every step's constructor.
///
/// Provided by `WizardManager`. Step bodies rendered outside a wizard (for
/// example in isolated widget tests) find no scope and fall back to showing
/// plain previous/next controls.
class WizardNavigationScope extends InheritedWidget {
  const WizardNavigationScope({
    super.key,
    required super.child,
    required this.currentStepIndex,
    required this.stepCount,
    required this.isCurrentStepOptional,
    required this.onSkipOptionalSteps,
    required this.helperTextExpanded,
  });

  final int currentStepIndex;
  final int stepCount;

  /// Whether the visible step can be skipped (crafting steps and the like).
  final bool isCurrentStepOptional;

  /// Jumps over this and all directly following optional steps. Null when the
  /// current step is not optional.
  final VoidCallback? onSkipOptionalSteps;

  /// Whether the step explanation is expanded on narrow (portrait) layouts.
  /// Shared across steps so the choice sticks while the wizard is open.
  final ValueNotifier<bool> helperTextExpanded;

  bool get isFirstStep => currentStepIndex == 0;
  bool get isLastStep => currentStepIndex == stepCount - 1;

  static WizardNavigationScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WizardNavigationScope>();
  }

  @override
  bool updateShouldNotify(WizardNavigationScope oldWidget) {
    return currentStepIndex != oldWidget.currentStepIndex ||
        stepCount != oldWidget.stepCount ||
        isCurrentStepOptional != oldWidget.isCurrentStepOptional ||
        onSkipOptionalSteps != oldWidget.onSkipOptionalSteps ||
        helperTextExpanded != oldWidget.helperTextExpanded;
  }
}
