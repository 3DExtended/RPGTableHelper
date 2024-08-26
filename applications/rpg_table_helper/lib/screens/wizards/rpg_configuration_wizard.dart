import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';

class RpgConfigurationWizardStepCampagneName extends WizardStepBase {
  const RpgConfigurationWizardStepCampagneName({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
  });

  @override
  ConsumerState<RpgConfigurationWizardStepCampagneName> createState() =>
      _RpgConfigurationWizardStepCampagneNameState();
}

class _RpgConfigurationWizardStepCampagneNameState
    extends ConsumerState<RpgConfigurationWizardStepCampagneName> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color.fromARGB(33, 210, 191, 221),
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "RPG Configuration", // TODO localize
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
              )
            ],
          ),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: const Color.fromARGB(78, 255, 255, 255),
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                    color: const Color.fromARGB(33, 210, 191, 221),
                    child: const Column()),
              ),
              Expanded(
                child: Container(
                  color: const Color.fromARGB(65, 39, 39, 39),
                  child: Column(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Row(
                          children: [
                            CustomButton(
                              label: "Zurück",
                              onPressed: () {
                                widget.onPreviousBtnPressed();
                              },
                            ),
                            const Spacer(),
                            CustomButton(
                              label: "Weiter",
                              onPressed: () {
                                widget.onNextBtnPressed();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
