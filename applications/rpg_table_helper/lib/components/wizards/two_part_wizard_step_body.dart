import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/keyboard_visibility_builder.dart';
import 'package:quest_keeper/components/row_column_flipper.dart';
import 'package:quest_keeper/components/wizards/wizard_navigation_scope.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

const wizardPreviousButtonKey = ValueKey('wizardPreviousButton');
const wizardNextButtonKey = ValueKey('wizardNextButton');
const wizardSkipButtonKey = ValueKey('wizardSkipButton');
const wizardHelperToggleKey = ValueKey('wizardHelperToggle');

class TwoPartWizardStepBody extends StatelessWidget {
  const TwoPartWizardStepBody({
    super.key,
    required this.isLandscapeMode,
    required this.stepHelperText,
    required this.onPreviousBtnPressed,
    required this.onNextBtnPressed,
    required this.contentChildren,
    this.titleWidgetRight,
    this.contentWidget,
    this.footerWidget,
    this.sideBarFlex = 1,
    this.contentFlex = 1,
  });

  final int? sideBarFlex;
  final int? contentFlex;
  final bool isLandscapeMode;
  final String stepHelperText;
  final void Function()? onPreviousBtnPressed;
  final void Function()? onNextBtnPressed;
  final List<Widget> contentChildren;
  final Widget? footerWidget;
  final Widget? contentWidget;
  final Widget? titleWidgetRight;

  @override
  Widget build(BuildContext context) {
    // Night Cartographer content insets shrink the sidebar; keep footer
    // buttons from overflowing the padded row.
    final footerHorizontal =
        isNightCartographerActive(context) ? 24.0 : 50.0;

    final navigation = _WizardStepNavigation(
      horizontalPadding: isLandscapeMode ? footerHorizontal : 20.0,
      onPreviousBtnPressed: onPreviousBtnPressed,
      onNextBtnPressed: onNextBtnPressed,
    );

    if (!isLandscapeMode) {
      // Portrait / narrow: a compact, collapsible explanation on top so the
      // editor gets most of the screen, navigation at the bottom.
      return Column(
        children: [
          KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
            if (isKeyboardVisible) {
              return const SizedBox.shrink();
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CollapsibleStepHelperText(text: stepHelperText),
                const HorizontalLine(),
              ],
            );
          }),
          Expanded(child: _buildContent(context)),
          const HorizontalLine(),
          navigation,
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: RowColumnFlipper(
            isLandscapeMode: isLandscapeMode,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: sideBarFlex ?? 1,
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                children: [
                                  CustomMarkdownBody(
                                    text: stepHelperText,
                                  ),
                                  SizedBox(
                                      height: EdgeInsets.fromViewPadding(
                                              View.of(context).viewInsets,
                                              View.of(context).devicePixelRatio)
                                          .bottom),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const HorizontalLine(),
                      navigation,
                    ],
                  );
                }),
              ),
              Expanded(
                flex: contentFlex ?? 1,
                child: _buildContent(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          if (contentWidget != null) {
            return contentWidget!;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    ...contentChildren,
                    SizedBox(
                        height: EdgeInsets.fromViewPadding(
                                View.of(context).viewInsets,
                                View.of(context).devicePixelRatio)
                            .bottom),
                  ],
                ),
              ),
            ),
          );
        })),
        ?footerWidget,
      ],
    );
  }
}

/// Back / next (or "done" on the last step) and, on optional steps, "skip".
class _WizardStepNavigation extends StatelessWidget {
  const _WizardStepNavigation({
    required this.horizontalPadding,
    required this.onPreviousBtnPressed,
    required this.onNextBtnPressed,
  });

  final double horizontalPadding;
  final void Function()? onPreviousBtnPressed;
  final void Function()? onNextBtnPressed;

  static const _iconSize = 16.0;

  /// Width of a [CustomButton] with [label] (and an icon), using the same
  /// label style as the button.
  double _buttonWidth(BuildContext context, String label,
      {required bool withIcon}) {
    final decorated = isDecoratedSheetSkinActive(context);
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
              fontSize: 16,
              fontFamily: decorated ? 'Ruwudu' : null,
              fontWeight: decorated ? FontWeight.w500 : FontWeight.normal,
            ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    // Label padding (2 * 5), button padding (2 * 10), border.
    return width + 10 + 20 + 2 + (withIcon ? _iconSize : 0);
  }

  @override
  Widget build(BuildContext context) {
    final scope = WizardNavigationScope.maybeOf(context);
    final iconColor = CustomThemeProvider.of(context).theme.darkColor;
    final isFirstStep = scope?.isFirstStep ?? false;
    final isLastStep = scope?.isLastStep ?? false;
    final onSkip = scope?.onSkipOptionalSteps;

    final previousLabel = S.of(context).back;
    final nextLabel = isLastStep
        ? S.of(context).wizardFinishBtnLabel
        : S.of(context).next;

    return LayoutBuilder(builder: (context, constraints) {
      // Narrow sidebars (phone landscape) get less padding and, if the
      // labels still do not fit, icon-only back / next as before.
      final padding =
          constraints.maxWidth >= 360 ? horizontalPadding : 16.0;
      final innerWidth = constraints.maxWidth - 2 * padding;
      final labelsFit = (isFirstStep
                  ? 0
                  : _buttonWidth(context, previousLabel, withIcon: true)) +
              _buttonWidth(context, nextLabel, withIcon: !isLastStep) +
              16 <=
          innerWidth;
      final skipWithHint = _buttonWidth(
                  context, S.of(context).wizardSkipBtnLabel,
                  withIcon: true) +
              120 <=
          innerWidth;

      final previousButton = CustomButton(
        key: wizardPreviousButtonKey,
        label: labelsFit ? previousLabel : null,
        icon: CustomFaIcon(
          color: iconColor,
          size: _iconSize,
          icon: FontAwesomeIcons.chevronLeft,
        ),
        onPressed: onPreviousBtnPressed,
      );

      final nextButton = _TrailingIcon(
        child: CustomButton(
          key: wizardNextButtonKey,
          variant: isLastStep
              ? CustomButtonVariant.AccentButton
              : CustomButtonVariant.Default,
          // "Done" always keeps its label; it ends the wizard.
          label: labelsFit || isLastStep ? nextLabel : null,
          icon: isLastStep
              ? null
              : CustomFaIcon(
                  color: iconColor,
                  size: _iconSize,
                  icon: FontAwesomeIcons.chevronRight,
                ),
          onPressed: onNextBtnPressed,
        ),
      );

      final skipButton = _TrailingIcon(
        child: CustomButton(
          key: wizardSkipButtonKey,
          variant: CustomButtonVariant.FlatButton,
          label: S.of(context).wizardSkipBtnLabel,
          icon: CustomFaIcon(
            color: iconColor,
            size: _iconSize,
            icon: FontAwesomeIcons.forwardStep,
          ),
          onPressed: onSkip,
        ),
      );

      return Padding(
        padding: EdgeInsets.fromLTRB(padding, 14.0, padding, 14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onSkip != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: skipWithHint
                    ? Row(
                        children: [
                          Expanded(
                            child: Text(
                              S.of(context).wizardOptionalStepLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: CustomThemeProvider.of(context)
                                        .theme
                                        .darkTextColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                          skipButton,
                        ],
                      )
                    : Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: skipButton,
                        ),
                      ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // The close button in the header leaves the wizard; there
                // is nothing to go back to from the first step.
                if (isFirstStep)
                  const SizedBox.shrink()
                else
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: previousButton,
                    ),
                  ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: nextButton,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// [CustomButton] puts its icon before the label. Laying the button out
/// right-to-left moves a forward icon after the label ("Weiter ›").
class _TrailingIcon extends StatelessWidget {
  const _TrailingIcon({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: child);
  }
}

/// On narrow screens the explanation starts as a short preview that can be
/// expanded. The choice is shared across the wizard's steps.
class _CollapsibleStepHelperText extends StatefulWidget {
  const _CollapsibleStepHelperText({required this.text});

  final String text;

  @override
  State<_CollapsibleStepHelperText> createState() =>
      _CollapsibleStepHelperTextState();
}

class _CollapsibleStepHelperTextState
    extends State<_CollapsibleStepHelperText> {
  static const _collapsedHeight = 92.0;

  /// Used when the step is shown outside a wizard (no shared state).
  bool _localExpanded = false;

  bool get _isShort {
    final trimmed = widget.text.trim();
    return trimmed.length <= 140 && '\n'.allMatches(trimmed).length <= 2;
  }

  @override
  Widget build(BuildContext context) {
    final sharedExpanded =
        WizardNavigationScope.maybeOf(context)?.helperTextExpanded;

    if (_isShort) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: SizedBox(
          width: double.infinity,
          child: CustomMarkdownBody(text: widget.text),
        ),
      );
    }

    if (sharedExpanded == null) {
      return _build(context, _localExpanded, (value) {
        setState(() => _localExpanded = value);
      });
    }

    return ValueListenableBuilder<bool>(
      valueListenable: sharedExpanded,
      builder: (context, expanded, _) {
        return _build(context, expanded, (value) {
          sharedExpanded.value = value;
        });
      },
    );
  }

  Widget _build(
    BuildContext context,
    bool expanded,
    void Function(bool) setExpanded,
  ) {
    final maxExpandedHeight = MediaQuery.of(context).size.height * 0.4;
    final textColor = CustomThemeProvider.of(context).theme.darkTextColor;

    final markdown = SizedBox(
      width: double.infinity,
      child: CustomMarkdownBody(text: widget.text),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: Durations.short4,
            alignment: Alignment.topCenter,
            child: expanded
                ? ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxExpandedHeight),
                    child: SingleChildScrollView(child: markdown),
                  )
                : ShaderMask(
                    // Fade the preview out instead of cutting a line in half;
                    // works on every skin background.
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.black, Colors.transparent],
                      stops: [0.0, 0.6, 1.0],
                    ).createShader(bounds),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: _collapsedHeight),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: markdown,
                      ),
                    ),
                  ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _TrailingIcon(
              child: CustomButton(
                key: wizardHelperToggleKey,
                variant: CustomButtonVariant.FlatButton,
                isSubbutton: true,
                label: expanded
                    ? S.of(context).wizardHideExplanation
                    : S.of(context).wizardShowExplanation,
                icon: CustomFaIcon(
                  color: textColor,
                  size: 14,
                  icon: expanded
                      ? FontAwesomeIcons.chevronUp
                      : FontAwesomeIcons.chevronDown,
                ),
                onPressed: () => setExpanded(!expanded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
