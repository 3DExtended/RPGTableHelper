import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';

class ModalContentWrapper<T> extends StatelessWidget {
  const ModalContentWrapper({
    super.key,
    required this.title,
    required this.child,
    required this.navigatorKey,
    required this.onSave,
    required this.onCancel,
  });

  final String title;
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  final Future<T?> Function()? onSave;
  final Future Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var modalPadding = 80.0;
      if (MediaQuery.of(context).size.width < 800) {
        modalPadding = 20.0;
      }
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: modalPadding, vertical: modalPadding),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBox(
                  borderThickness: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(21.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: CustomMarkdownBody(text: "# $title"))
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        child,
                        const SizedBox(
                          height: 0,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                          child: Row(
                            children: [
                              CustomButton(
                                label: "Abbrechen", // TODO localize
                                onPressed: () async {
                                  await onCancel();
                                  navigatorKey.currentState!.pop(null);
                                },
                              ),
                              const Spacer(),
                              CustomButton(
                                label: "Speichern", // TODO localize
                                onPressed: onSave == null
                                    ? null
                                    : () async {
                                        var result = await onSave!();

                                        navigatorKey.currentState!.pop(result);
                                      },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
    });
  }
}
