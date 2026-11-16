import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/colored_rotated_square.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/components/wizards/wizard_navigation_scope.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/components/wizards/wizard_step_save_registry.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/context_extension.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Index of the first non-optional step after [currentIndex], or null when
/// only optional steps follow.
int? firstRequiredStepAfter(List<WizardStepDefinition> steps, int currentIndex) {
  for (var i = currentIndex + 1; i < steps.length; i++) {
    if (!steps[i].isOptional) {
      return i;
    }
  }
  return null;
}

class WizardManager extends StatefulWidget {
  final List<WizardStepDefinition> steps;

  /// Called by "next" on the last step.
  final VoidCallback onFinish;

  /// Called by the close button. Defaults to popping the wizard route.
  final VoidCallback? onClose;

  final int? startStepIndex;

  const WizardManager({
    super.key,
    required this.steps,
    required this.onFinish,
    this.onClose,
    this.startStepIndex,
  });

  @override
  State<WizardManager> createState() => _WizardManagerState();
}

class _WizardManagerState extends State<WizardManager> {
  int _currentStep = 0;
  String? _currentTitleOverride;
  bool _savedForClose = false;
  final ValueNotifier<bool> _helperTextExpanded = ValueNotifier(false);

  @override
  void initState() {
    _currentStep = widget.startStepIndex ?? 0;
    super.initState();
  }

  @override
  void dispose() {
    _helperTextExpanded.dispose();
    super.dispose();
  }

  void _setStepTitle(String newTitle) {
    setState(() {
      _currentTitleOverride = newTitle;
    });
  }

  void _goToNextStep() {
    flushActiveWizardStepSave();
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
        _currentTitleOverride = null;
      });
    } else {
      _savedForClose = true;
      widget.onFinish();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      flushActiveWizardStepSave();
      setState(() {
        _currentStep--;
        _currentTitleOverride = null;
      });
    } else {
      _close();
    }
  }

  void _goToStepId(int id) {
    if (id < 0 || id >= widget.steps.length) {
      throw ArgumentError('Invalid step index');
    }
    if (id == _currentStep) {
      return;
    }
    flushActiveWizardStepSave();
    setState(() {
      _currentStep = id;
      _currentTitleOverride = null;
    });
  }

  /// Jumps over the current and all directly following optional steps. Data
  /// already entered in the skipped steps stays as it is.
  void _skipOptionalSteps() {
    flushActiveWizardStepSave();
    final target = firstRequiredStepAfter(widget.steps, _currentStep);
    if (target == null) {
      _savedForClose = true;
      widget.onFinish();
      return;
    }
    setState(() {
      _currentStep = target;
      _currentTitleOverride = null;
    });
  }

  /// Saves the visible step and leaves the wizard, from any step.
  void _close() {
    flushActiveWizardStepSave();
    _savedForClose = true;
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];

    // System back (Android) or the iOS swipe leave the wizard without the
    // close button; save the visible step there as well.
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_savedForClose) {
          flushActiveWizardStepSave();
        }
      },
      child: ValueListenableBuilder<String>(
        valueListenable: CustomThemeProvider.of(context).skinIdNotifier,
        builder: (context, _, _) {
          return Column(
            children: [
              Navbar(
                backInsteadOfCloseIcon: false,
                useTopSafePadding: true,
                closeFunction: _close,
                menuOpen: null,
                titleWidget: Builder(builder: _buildStepIndicator),
              ),
              Expanded(
                child: CharacterSheetSkinChrome(
                  child: Padding(
                    padding: characterSheetContentInsets(context),
                    child: Container(
                      color: characterSheetSurfaceColor(context),
                      child: WizardNavigationScope(
                        currentStepIndex: _currentStep,
                        stepCount: widget.steps.length,
                        isCurrentStepOptional: step.isOptional,
                        onSkipOptionalSteps:
                            step.isOptional ? _skipOptionalSteps : null,
                        helperTextExpanded: _helperTextExpanded,
                        child: KeyedSubtree(
                          key: ValueKey(_currentStep),
                          child: step.builder(
                            _goToPreviousStep,
                            _goToNextStep,
                            _setStepTitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final ledger = isDecoratedSheetSkinActive(context);
    var selectedIconColor = ledger
        ? ledgerNavbarAccent(context)
        : CustomThemeProvider.of(context).theme.accentColor;
    var unselectedIconColor = ledger
        ? const Color(0xffEDE3D4)
        : (CustomThemeProvider.of(context).brightnessNotifier.value ==
                Brightness.light
            ? CustomThemeProvider.of(context).theme.textColor
            : CustomThemeProvider.of(context).theme.darkTextColor);
    var textColor = CustomThemeProvider.of(context).brightnessNotifier.value ==
            Brightness.light
        ? CustomThemeProvider.of(context).theme.textColor
        : CustomThemeProvider.of(context).theme.darkTextColor;
    final titleColor = ledger ? ledgerNavbarAccent(context) : textColor;

    Widget diamond(int index) {
      return CupertinoButton(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        onPressed: () {
          _goToStepId(index);
        },
        child: ColoredRotatedSquare(
          isSolidSquare: index == _currentStep,
          color: index == _currentStep ? selectedIconColor : unselectedIconColor,
        ),
      );
    }

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i <= _currentStep; i++) diamond(i),
        if (context.isTablet)
          Padding(
            padding: EdgeInsets.only(
              left: ledger ? 10.0 : 4.0,
              right: ledger ? 14.0 : 20.0,
            ),
            child: AnimatedOpacity(
              opacity: _currentTitleOverride != null ? 1 : 0,
              duration: Durations.short2,
              child: Text(
                _currentTitleOverride ?? "",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: titleColor,
                      fontSize: ledger ? 26 : 24,
                      fontFamily: ledger ? 'Ruwudu' : null,
                      fontWeight: FontWeight.w400,
                      letterSpacing: ledger ? 0.4 : null,
                      height: 1.0,
                    ),
              ),
            ),
          ),
        for (var i = _currentStep + 1; i < widget.steps.length; i++)
          diamond(i),
      ],
    );

    // Ten steps do not fit next to the close button on a phone; shrink the
    // row instead of overflowing.
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: row,
      ),
    );
  }
}
