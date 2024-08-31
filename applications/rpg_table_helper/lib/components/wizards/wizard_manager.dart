import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/main_two_block_layout.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';

class WizardManager extends StatefulWidget {
  final List<WizardStepBase Function(void Function(), void Function())>
      stepBuilders;
  final VoidCallback onFinish;

  final int? startStepIndex;

  const WizardManager({
    super.key,
    required this.stepBuilders,
    required this.onFinish,
    this.startStepIndex,
  });

  @override
  State<WizardManager> createState() => _WizardManagerState();
}

class _WizardManagerState extends State<WizardManager> {
  int _currentStep = 0;

  @override
  void initState() {
    _currentStep = widget.startStepIndex ?? 0;
    super.initState();
  }

  void _goToNextStep() {
    if (_currentStep < widget.stepBuilders.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onFinish();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _goToStepId(int id) {
    if (id < 0 || id >= widget.stepBuilders.length) {
      throw ArgumentError('Invalid step index');
    }
    setState(() {
      _currentStep = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainTwoBlockLayout(
      showIsConnectedButton: false,
      selectedNavbarButton: _currentStep,
      navbarButtons: widget.stepBuilders
          .asMap()
          .entries
          .map(
            (e) => NavbarButton(
              onPressed: (tabItem) {
                _goToStepId(e.key);
              },
              icon: Container(
                width: 24,
                alignment: Alignment.center,
                child: Text(
                  (e.key + 1).toString(),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 16,
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
        color: const Color.fromARGB(35, 29, 22, 22),
        child: widget.stepBuilders[_currentStep](
          _goToPreviousStep,
          _goToNextStep,
        ),
      ),
    );
  }
}
