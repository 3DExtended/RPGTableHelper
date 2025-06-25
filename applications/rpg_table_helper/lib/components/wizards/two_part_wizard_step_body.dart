import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/row_column_flipper.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

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
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 20.0),
                        child: Row(
                          children: [
                            CustomButton(
                              icon: CustomFaIcon(
                                  color: CustomThemeProvider.of(context)
                                      .theme
                                      .darkColor,
                                  icon: FontAwesomeIcons.chevronLeft),
                              onPressed: onPreviousBtnPressed,
                            ),
                            Spacer(),
                            CustomButton(
                              icon: CustomFaIcon(
                                  color: CustomThemeProvider.of(context)
                                      .theme
                                      .darkColor,
                                  icon: FontAwesomeIcons.chevronRight),
                              onPressed: onNextBtnPressed,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
              if (!isLandscapeMode) const HorizontalLine(),
              Expanded(
                flex: contentFlex ?? 1,
                child: Column(
                  children: [
                    Expanded(
                        child: LayoutBuilder(builder: (context, constraints) {
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
                    if (footerWidget != null) footerWidget!,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
