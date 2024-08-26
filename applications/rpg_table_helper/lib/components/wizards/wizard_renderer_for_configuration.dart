import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/wizards/wizard_manager.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';

class WizardConfiguration {
  final List<WizardStepBase Function(void Function(), void Function())>
      stepBuilders;

  WizardConfiguration({required this.stepBuilders});
}

class WizardRendererForConfiguration extends StatelessWidget {
  final WizardConfiguration configuration;
  const WizardRendererForConfiguration({
    super.key,
    required this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WizardManager(
        stepBuilders: configuration.stepBuilders,
        onFinish: () {
          // Pop the wizard route off the stack when finished
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
