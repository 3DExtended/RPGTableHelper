import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';

class TwoPartWizardStepBody extends StatelessWidget {
  const TwoPartWizardStepBody({
    super.key,
    required this.wizardTitle,
    required this.isLandscapeMode,
    required this.stepTitle,
    required this.stepHelperText,
    required this.onPreviousBtnPressed,
    required this.onNextBtnPressed,
    required this.contentChildren,
    this.footerWidget,
  });

  final String wizardTitle;
  final bool isLandscapeMode;
  final String stepTitle;
  final String stepHelperText;
  final void Function()? onPreviousBtnPressed;
  final void Function()? onNextBtnPressed;
  final List<Widget> contentChildren;
  final Widget? footerWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color.fromARGB(33, 210, 191, 221),
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                wizardTitle,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const HorizontalLine(),
        Expanded(
          child: RowColumnFlipper(
            isLandscapeMode: isLandscapeMode,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                    color: const Color.fromARGB(33, 210, 191, 221),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              children: [
                                Theme(
                                  data: ThemeData(
                                    textTheme:
                                        Theme.of(context).textTheme.copyWith(
                                              bodySmall: const TextStyle(
                                                  color: Colors.white),
                                              bodyMedium: const TextStyle(
                                                  color: Colors.white),
                                              bodyLarge: const TextStyle(
                                                  color: Colors.white),
                                              labelSmall: const TextStyle(
                                                  color: Colors.white),
                                              labelMedium: const TextStyle(
                                                  color: Colors.white),
                                              labelLarge: const TextStyle(
                                                  color: Colors.white),
                                              displaySmall: const TextStyle(
                                                  color: Colors.white),
                                              displayMedium: const TextStyle(
                                                  color: Colors.white),
                                              displayLarge: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                  ),
                                  child: MarkdownBody(
                                    data: "# $stepTitle\n\n$stepHelperText",
                                  ),
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
                      );
                    })),
              ),
              if (!isLandscapeMode) const HorizontalLine(),
              Expanded(
                child: Container(
                  color: const Color.fromARGB(65, 39, 39, 39),
                  child: Column(
                    children: [
                      Expanded(
                          child: LayoutBuilder(builder: (context, constraints) {
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
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 50.0),
                        child: Row(
                          children: [
                            CustomButton(
                              label: "Zurück", // TODO localize
                              onPressed: onPreviousBtnPressed,
                            ),
                            const Spacer(),
                            CustomButton(
                              label: "Weiter", // TODO localize
                              onPressed: onNextBtnPressed,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
