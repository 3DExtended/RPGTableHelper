import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/custom_shadow_widget.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/components/newdesign/navbar_new_design.dart';
import 'package:rpg_table_helper/constants.dart';

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
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(
              bottom: 20, top: 20, left: modalPadding, right: modalPadding),
          child: Center(
            child: CustomShadowWidget(
                child: Container(
              color: bgColor,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  NavbarNewDesign(
                    backInsteadOfCloseIcon: false,
                    closeFunction: () {
                      navigatorKey.currentState!.pop(null);
                    },
                    menuOpen: null,
                    useTopSafePadding: false,
                    titleWidget: Text(
                      title, // TODO localize/ switch text between add and edit
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: textColor, fontSize: 24),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(child: child),
                  )),
                  const SizedBox(
                    height: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                    child: Row(
                      children: [
                        CustomButtonNewdesign(
                          label: "Abbrechen", // TODO localize
                          onPressed: () async {
                            await onCancel();
                            navigatorKey.currentState!.pop(null);
                          },
                        ),
                        const Spacer(),
                        CustomButtonNewdesign(
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
            )),
          ),
        ),
      );
    });
  }
}
