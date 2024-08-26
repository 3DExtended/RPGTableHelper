import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/wizards/wizard_manager.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';

class RpgConfigurationWizard extends StatelessWidget {
  static const String route = "/rpgconfigurationwizard";
  const RpgConfigurationWizard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WizardManager(
        steps: const [
          _RpgConfigurationWizardStepCampagneName(),
          _RpgConfigurationWizardStepCampagneName(),
        ],
        onFinish: () {
          // Pop the wizard route off the stack when finished
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _RpgConfigurationWizardStepCampagneName extends ConsumerStatefulWidget
    implements WizardStepBase {
  const _RpgConfigurationWizardStepCampagneName({super.key});

  @override
  ConsumerState<_RpgConfigurationWizardStepCampagneName> createState() =>
      _RpgConfigurationWizardStepCampagneNameState();

  @override
  void onStepLeave() {
    // TODO: implement onStepLeave
  }
}

class _RpgConfigurationWizardStepCampagneNameState
    extends ConsumerState<_RpgConfigurationWizardStepCampagneName> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
