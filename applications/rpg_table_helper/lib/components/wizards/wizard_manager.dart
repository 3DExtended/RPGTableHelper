import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/main_two_block_layout.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
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
        Container(
          height: MediaQuery.of(context).padding.top,
          color: darkColor,
        ),
        Container(
          height: 50,
          color: darkColor,
          child: Row(
            children: [
              CustomButtonNewdesign(
                variant: CustomButtonNewdesignVariant.FlatButton,
                onPressed: () {
                  _goToPreviousStep();
                },
                icon: CustomFaIcon(icon: FontAwesomeIcons.chevronLeft),
              ),
              Expanded(
                child: Row(
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
                                icon: FontAwesomeIcons.square,
                                color: index == _currentStep
                                    ? accentColor
                                    : middleBgColor),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        (_currentStep + 1)
                            .toString(), // TODO get wizard step title
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
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
              ),
              CustomButtonNewdesign(
                variant: CustomButtonNewdesignVariant.FlatButton,
                onPressed: () {
                  // TODO make me
                },
                icon: CustomFaIcon(icon: FontAwesomeIcons.bars),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: _currentStep == 5
                ? bgColor
                : const Color.fromARGB(35, 29, 22, 22),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: widget.stepBuilders[_currentStep](
                _goToPreviousStep,
                _goToNextStep,
              ),
            ),
          ),
        ),
      ],
    );

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
