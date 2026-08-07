import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/colored_rotated_square.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/components/wizards/wizard_step_save_registry.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/context_extension.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

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
    flushActiveWizardStepSave();
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
    flushActiveWizardStepSave();
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
    if (id != _currentStep) {
      flushActiveWizardStepSave();
    }
    setState(() {
      _currentStep = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: CustomThemeProvider.of(context).skinIdNotifier,
      builder: (context, _, __) {
        return Column(
          children: [
            Navbar(
              backInsteadOfCloseIcon: true,
              useTopSafePadding: true,
              closeFunction: () {
                _goToPreviousStep();
              },
              menuOpen: () {
                // TODO make me
              },
              titleWidget: Builder(builder: (context) {
                final ledger = isDecoratedSheetSkinActive(context);
                var selectedIconColor = ledger
                    ? ledgerNavbarAccent(context)
                    : CustomThemeProvider.of(context).theme.accentColor;
                var unselectedIconColor = ledger
                    ? const Color(0xffEDE3D4)
                    : (CustomThemeProvider.of(context)
                                .brightnessNotifier
                                .value ==
                            Brightness.light
                        ? CustomThemeProvider.of(context).theme.textColor
                        : CustomThemeProvider.of(context).theme.darkTextColor);
                var textColor = CustomThemeProvider.of(context)
                            .brightnessNotifier
                            .value ==
                        Brightness.light
                    ? CustomThemeProvider.of(context).theme.textColor
                    : CustomThemeProvider.of(context).theme.darkTextColor;
                final titleColor =
                    ledger ? ledgerNavbarAccent(context) : textColor;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    ...List.generate(
                      _currentStep + 1,
                      (index) => CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _goToStepId(index);
                        },
                        child: ColoredRotatedSquare(
                          isSolidSquare: index == _currentStep,
                          color: index == _currentStep
                              ? selectedIconColor
                              : unselectedIconColor,
                        ),
                      ),
                    ),
                    if (context.isTablet)
                      Padding(
                        padding: EdgeInsets.only(
                          left: ledger ? 10.0 : 4.0,
                          right: ledger ? 14.0 : 20.0,
                        ),
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
                                    color: titleColor,
                                    fontSize: ledger ? 26 : 24,
                                    fontFamily: ledger ? 'Ruwudu' : null,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: ledger ? 0.4 : null,
                                    height: 1.0,
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
                        child: ColoredRotatedSquare(
                          isSolidSquare: false,
                          color: unselectedIconColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                );
              }),
            ),
            Expanded(
              child: CharacterSheetSkinChrome(
                child: Padding(
                  padding: characterSheetContentInsets(context),
                  child: Container(
                    color: characterSheetSurfaceColor(context),
                    child: widget.stepBuilders[_currentStep](
                      _goToPreviousStep,
                      _goToNextStep,
                      _setStepTitle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
