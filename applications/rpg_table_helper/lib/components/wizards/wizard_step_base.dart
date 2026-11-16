import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class WizardStepBase extends ConsumerStatefulWidget {
  final void Function() onNextBtnPressed;
  final void Function() onPreviousBtnPressed;
  final void Function(String newTitle) setWizardTitle;

  const WizardStepBase({
    super.key,
    required this.onNextBtnPressed,
    required this.onPreviousBtnPressed,
    required this.setWizardTitle,
  });
}

typedef WizardStepBuilder = WizardStepBase Function(
    void Function() moveToPrevious,
    void Function() moveToNext,
    void Function(String newTitle) setTitle);

class WizardStepDefinition {
  final WizardStepBuilder builder;

  /// Optional steps show a "skip" control that jumps over this and all
  /// directly following optional steps.
  final bool isOptional;

  const WizardStepDefinition({
    required this.builder,
    this.isOptional = false,
  });
}
