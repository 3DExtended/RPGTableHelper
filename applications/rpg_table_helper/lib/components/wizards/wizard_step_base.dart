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
