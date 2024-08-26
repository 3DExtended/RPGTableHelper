import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/wizards/wizard_manager.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';

class RpgConfigurationWizard extends StatelessWidget {
  static const String route = "/rpgconfigurationwizard";
  const RpgConfigurationWizard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WizardManager(
        stepBuilders: [
          (moveToPrevious, moveToNext) =>
              _RpgConfigurationWizardStepCampagneName(
                  title: "asdf1",
                  onPreviousBtnPressed: moveToPrevious,
                  onNextBtnPressed: moveToNext),
          (moveToPrevious, moveToNext) =>
              _RpgConfigurationWizardStepCampagneName(
                  title: "asdf2",
                  onPreviousBtnPressed: moveToPrevious,
                  onNextBtnPressed: moveToNext),
        ],
        onFinish: () {
          // Pop the wizard route off the stack when finished
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _RpgConfigurationWizardStepCampagneName extends WizardStepBase {
  final String title;

  const _RpgConfigurationWizardStepCampagneName({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
    required this.title,
  });

  @override
  ConsumerState<_RpgConfigurationWizardStepCampagneName> createState() =>
      _RpgConfigurationWizardStepCampagneNameState();
}

class _RpgConfigurationWizardStepCampagneNameState
    extends ConsumerState<_RpgConfigurationWizardStepCampagneName> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "asdf${widget.title}",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
        ),
        Row(
          children: [
            CustomButton(
              label: "Zurück",
              onPressed: () {
                widget.onPreviousBtnPressed();
              },
            ),
            CustomButton(
              label: "Weiter",
              onPressed: () {
                widget.onNextBtnPressed();
              },
            ),
          ],
        )
      ],
    );
  }
}
