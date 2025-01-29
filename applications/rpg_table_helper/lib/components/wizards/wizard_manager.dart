import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/navbar.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/constants.dart';

class WizardManager extends StatefulWidget {
  final List<
          WizardStepBase Function(
              void Function(), void Function(), void Function(String newTitle))>
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
  String? _currentTitleOverride;

  @override
  void initState() {
    _currentStep = widget.startStepIndex ?? 0;
    super.initState();
  }

  void _setStepTitle(String newTitle) {
    setState(() {
      _currentTitleOverride = newTitle;
    });
  }

  void _goToNextStep() {
    if (_currentStep < widget.stepBuilders.length - 1) {
      setState(() {
        _currentStep++;
        _currentTitleOverride = null;
      });
    } else {
      widget.onFinish();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _currentTitleOverride = null;
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
          return Navbar(
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
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _goToStepId(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Transform.rotate(
                        alignment: Alignment.center,
                        angle: math.pi / 4, // 45 deg
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
                  child: Stack(children: [
                    AnimatedOpacity(
                      opacity: _currentTitleOverride != null ? 1 : 0,
                      duration: Durations.short2,
                      child: Text(
                        _currentTitleOverride ?? "",
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
                  ]),
                ),
                ...List.generate(
                  widget.stepBuilders.length - (_currentStep + 1),
                  (index) => CupertinoButton(
                    minSize: 0,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _goToStepId(index + _currentStep + 1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Transform.rotate(
                        alignment: Alignment.center,
                        angle: pi / 4, // 45 deg
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
              _setStepTitle,
            ),
          ),
        ),
      ],
    );
  }
}
