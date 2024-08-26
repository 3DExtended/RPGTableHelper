import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/main_two_block_layout.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';

class WizardManager extends StatefulWidget {
  final List<WizardStepBase> steps; // The list of steps (each step is a widget)
  final VoidCallback onFinish; // Callback when the wizard is finished

  const WizardManager({super.key, required this.steps, required this.onFinish});

  @override
  State<WizardManager> createState() => _WizardManagerState();
}

class _WizardManagerState extends State<WizardManager> {
  int _currentStep = 0;

  void _goToNextStep() {
    _notifyStepOnLeave();
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onFinish();
    }
  }

  void _goToPreviousStep() {
    _notifyStepOnLeave();
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _goToStepId(int id) {
    setState(() {
      _currentStep = id;
    });
  }

  void _notifyStepOnLeave() {
    var currentStepDisplayed = widget.steps[_currentStep];
    currentStepDisplayed.onStepLeave();
  }

  @override
  Widget build(BuildContext context) {
    return MainTwoBlockLayout(
        showIsConnectedButton: false,
        selectedNavbarButton: _currentStep,
        navbarButtons: widget.steps
            .asMap()
            .entries
            .map(
              (e) => NavbarButton(
                onPressed: (tabItem) {
                  _goToStepId(e.key);
                },
                icon: Container(
                  width: 28,
                  alignment: Alignment.center,
                  child: Text(
                    e.key.toString(),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 24,
                        color: e.key == _currentStep
                            ? Colors.white
                            : const Color.fromARGB(255, 141, 141, 141)),
                  ),
                ),
                tabItem: null,
              ),
            )
            .toList(),
        content: Container(
            color: const Color.fromARGB(35, 29, 22, 22), child: Container()));
  }
}
