import 'package:flutter/material.dart';
import 'package:quest_keeper/components/wizards/wizard_manager.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';

class WizardConfiguration {
  final List<
          WizardStepBase Function(
              void Function(), void Function(), void Function(String newTitle))>
      stepBuilders;

  WizardConfiguration({required this.stepBuilders});
}

class WizardRendererForConfiguration extends StatelessWidget {
  final WizardConfiguration configuration;
  final int? startStepIndex;
  const WizardRendererForConfiguration({
    super.key,
    required this.configuration,
    this.startStepIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: WizardManager(
        startStepIndex: startStepIndex,
        stepBuilders: configuration.stepBuilders,
        onFinish: () {
          // Pop the wizard route off the stack when finished
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
