import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class WizardStepBase extends ConsumerStatefulWidget {
  final void Function() onNextBtnPressed;
  final void Function() onPreviousBtnPressed;

  const WizardStepBase({
    super.key,
    required this.onNextBtnPressed,
    required this.onPreviousBtnPressed,
  });
}
