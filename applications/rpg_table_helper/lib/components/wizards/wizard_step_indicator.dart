import 'package:flutter/material.dart';

class WizardStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const WizardStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= currentStep ? Colors.blue : Colors.grey,
          ),
        );
      }),
    );
  }
}
