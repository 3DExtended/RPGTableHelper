import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/newdesign/navbar_new_design.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/constants.dart';

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
    } else {
      Navigator.of(context).pop();
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
    return Column(
      children: [
        Builder(builder: (context) {
          return NavbarNewDesign(
            backInsteadOfCloseIcon: true,
            useTopSafePadding: true,
            closeFunction: () {
              _goToPreviousStep();
            },
            menuOpen: () {
              // TODO make me
            },
            titleWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                ...List.generate(
                  _currentStep + 1,
                  (index) => CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      _goToStepId(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Transform.rotate(
                        alignment: Alignment.center,
                        angle: 0.785398163, // 45 deg
                        child: CustomFaIcon(
                            icon: index == _currentStep
                                ? FontAwesomeIcons.solidSquare
                                : FontAwesomeIcons.square,
                            color: index == _currentStep
                                ? accentColor
                                : middleBgColor),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 20.0),
                  child: Text(
                    (_currentStep + 1).toString(), // TODO get wizard step title
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: textColor,
                          fontSize: 24,
                        ),
                  ),
                ),
                ...List.generate(
                  widget.stepBuilders.length - (_currentStep + 1),
                  (index) => CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      _goToStepId(index + _currentStep + 1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Transform.rotate(
                        alignment: Alignment.center,
                        angle: 0.785398163, // 45 deg
                        child: CustomFaIcon(
                            icon: FontAwesomeIcons.square,
                            color: middleBgColor),
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          );
        }),
        Expanded(
          child: Container(
            color: bgColor,
            child: widget.stepBuilders[_currentStep](
              _goToPreviousStep,
              _goToNextStep,
            ),
          ),
        ),
      ],
    );
  }
}
