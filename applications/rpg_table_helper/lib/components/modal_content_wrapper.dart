import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class ModalContentWrapper<T> extends StatelessWidget {
  const ModalContentWrapper({
    super.key,
    required this.title,
    required this.child,
    required this.navigatorKey,
    required this.onSave,
    required this.onCancel,
    required this.isFullscreen,
  });

  final String title;
  final Widget child;
  final bool isFullscreen;
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
                child: ConditionalWidgetWrapper(
              condition: !isFullscreen,
              wrapper: (context, child) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: child,
                );
              },
              child: Container(
                color: CustomThemeProvider.of(context).theme.bgColor,
                child: Column(
                  mainAxisSize:
                      isFullscreen ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    Navbar(
                      backInsteadOfCloseIcon: false,
                      closeFunction: () {
                        navigatorKey.currentState!.pop(null);
                      },
                      menuOpen: null,
                      useTopSafePadding: false,
                      titleWidget: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color:
                                CustomThemeProvider.of(context).theme.textColor,
                            fontSize: 24),
                      ),
                    ),
                    if (isFullscreen)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SingleChildScrollView(child: child),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(child: child),
                      ),
                    const SizedBox(
                      height: 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 20),
                      child: Row(
                        children: [
                          CustomButton(
                            label: S.of(context).cancel,
                            onPressed: () async {
                              await onCancel();
                              navigatorKey.currentState!.pop(null);
                            },
                          ),
                          const Spacer(),
                          CustomButton(
                            label: S.of(context).save,
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
            )),
          ),
        ),
      );
    });
  }
}
