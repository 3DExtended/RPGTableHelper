import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/constants.dart';

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
                                      isNewDesign: true, text: stepHelperText),
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
                            CustomButtonNewdesign(
                              icon: CustomFaIcon(
                                  color: darkColor,
                                  icon: FontAwesomeIcons.chevronLeft),
                              onPressed: onPreviousBtnPressed,
                            ),
                            Spacer(),
                            CustomButtonNewdesign(
                              icon: CustomFaIcon(
                                  color: darkColor,
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
