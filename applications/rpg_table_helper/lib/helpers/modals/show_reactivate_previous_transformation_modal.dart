// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

Future<bool?> showReactivatePreviousTransformationModal(
  BuildContext context, {
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<bool>(
      isDismissible: true,
      expand: true,
      closeProgressThreshold: -50000,
      enableDrag: false,
      context: context,
      backgroundColor: const Color.fromARGB(192, 21, 21, 21),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        return _ShowReactivatePreviousTransformationModalContent(
          modalPadding: modalPadding,
        );
      });
}

class _ShowReactivatePreviousTransformationModalContent
    extends ConsumerStatefulWidget {
  const _ShowReactivatePreviousTransformationModalContent({
    required this.modalPadding,
  });

  final double modalPadding;

  @override
  ConsumerState<_ShowReactivatePreviousTransformationModalContent>
      createState() => _ShowReactivatePreviousTransformationModalContentState();
}

class _ShowReactivatePreviousTransformationModalContentState
    extends ConsumerState<_ShowReactivatePreviousTransformationModalContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
            bottom: 20,
            top: 20,
            left: widget.modalPadding,
            right: widget.modalPadding),
        child: Center(
          child: CustomShadowWidget(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600, maxHeight: 400),
              child: Container(
                color: CustomThemeProvider.of(context).theme.bgColor,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    getNavbar(context),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                "Möchtest du deine letzte Verwandlung wieder aufgreifen oder eine neue Gestalt annehmen?", // TODO localize
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: CustomThemeProvider.of(context)
                                          .theme
                                          .darkTextColor,
                                      fontSize: 16,
                                    ),
                              ),
                              SizedBox(height: 20),
                              WarningBox(
                                warningTitle:
                                    "Alte Verwandlungen werden gelöscht",
                                warningText:
                                    "Beim Erstellen einer neuen Verwandlung werden alle alten Verwandlungen gelöscht.",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 0, 30, 10),
                      child: Row(
                        children: [
                          const Spacer(flex: 1),
                          CustomButton(
                            label: S.of(context).newTransformationSelectionBtn,
                            onPressed: () {
                              navigatorKey.currentState!.pop(false);
                            },
                          ),
                          Spacer(
                            flex: 3,
                          ),
                          CustomButton(
                            variant: CustomButtonVariant.AccentButton,
                            label: S
                                .of(context)
                                .previousTransformationSelectionBtn,
                            onPressed: () {
                              navigatorKey.currentState!.pop(true);
                            },
                          ),
                          const Spacer(flex: 1),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Navbar getNavbar(BuildContext context) {
    return Navbar(
      backInsteadOfCloseIcon: false,
      closeFunction: () {
        navigatorKey.currentState!.pop(null);
      },
      menuOpen: null,
      useTopSafePadding: false,
      titleWidget: Text(
        "Alte Verwandlung reaktivieren", // TODO localize
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: CustomThemeProvider.of(context).brightnessNotifier.value ==
                    Brightness.light
                ? CustomThemeProvider.of(context).theme.textColor
                : CustomThemeProvider.of(context).theme.darkTextColor,
            fontSize: 24),
      ),
    );
  }
}
