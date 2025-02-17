// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

Future<RpgAlternateCharacterConfiguration?>
    showSelectTransformationComponentsForTransformation(
  BuildContext context, {
  GlobalKey<NavigatorState>? overrideNavigatorKey,
  required RpgCharacterConfiguration rpgCharConfig,
  required RpgConfigurationModel rpgConfig,
}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<
          RpgAlternateCharacterConfiguration>(
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

        return _SelectTransformationComponentsForTransformationModalContent(
          modalPadding: modalPadding,
          rpgCharConfig: rpgCharConfig,
          rpgConfig: rpgConfig,
        );
      });
}

class _SelectTransformationComponentsForTransformationModalContent
    extends ConsumerStatefulWidget {
  const _SelectTransformationComponentsForTransformationModalContent({
    required this.modalPadding,
    required this.rpgConfig,
    required this.rpgCharConfig,
  });

  final double modalPadding;
  final RpgConfigurationModel rpgConfig;
  final RpgCharacterConfiguration rpgCharConfig;

  @override
  ConsumerState<_SelectTransformationComponentsForTransformationModalContent>
      createState() =>
          _SelectTransformationComponentsForTransformationModalContentState();
}

class _SelectTransformationComponentsForTransformationModalContentState
    extends ConsumerState<
        _SelectTransformationComponentsForTransformationModalContent> {
  final List<({String transformationUuid})> _selectedTransformationUuid = [];

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
            child: Container(
              color: bgColor,
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
                              "Wähle die Komponenten/Verwandlungen aus, die du für die Verwandlung verwenden möchtest.", // TODO localize
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: darkTextColor,
                                    fontSize: 16,
                                  ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (widget.rpgCharConfig.transformationComponents
                                    ?.isNotEmpty !=
                                true)
                              Text(
                                  "Keine Komponenten/Verwandlungen vorhanden. Bitte gehe zurück und konfiguriere die Verwandlungen in den Charakter Einstellungen", // TODO localize
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: darkTextColor,
                                        fontSize: 16,
                                      )),
                            if (widget.rpgCharConfig.transformationComponents
                                    ?.isNotEmpty ==
                                true)
                              ...widget.rpgCharConfig.transformationComponents
                                      ?.map(
                                    (e) => CheckboxListTile.adaptive(
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                      splashRadius: 0,
                                      dense: true,
                                      checkColor: const Color.fromARGB(
                                          255, 57, 245, 88),
                                      activeColor: darkColor,
                                      visualDensity:
                                          VisualDensity(vertical: -2),
                                      title: Text(
                                        e.transformationName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(
                                                color: darkTextColor,
                                                fontSize: 16),
                                      ),
                                      subtitle: e.transformationDescription
                                                  ?.isNotEmpty ==
                                              true
                                          ? Text(
                                              e.transformationDescription ?? "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                      color: darkTextColor,
                                                      fontSize: 12),
                                            )
                                          : null,
                                      value: _selectedTransformationUuid.any(
                                          (element) =>
                                              element.transformationUuid ==
                                              e.transformationUuid),
                                      onChanged: (val) {
                                        if (_selectedTransformationUuid.any(
                                            (element) =>
                                                element.transformationUuid ==
                                                e.transformationUuid)) {
                                          setState(() {
                                            _selectedTransformationUuid
                                                .removeWhere((element) =>
                                                    element
                                                        .transformationUuid ==
                                                    e.transformationUuid);
                                          });
                                        } else {
                                          setState(() {
                                            _selectedTransformationUuid.add((
                                              transformationUuid:
                                                  e.transformationUuid
                                            ));
                                          });
                                        }
                                      },
                                    ),
                                  ) ??
                                  [],

                            // TODO add additional settings (like "show non overwritten stats")
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                    child: Row(
                      children: [
                        const Spacer(flex: 1),
                        CustomButton(
                          label: S.of(context).cancel,
                          onPressed: () {
                            navigatorKey.currentState!.pop(null);
                          },
                        ),
                        Spacer(
                          flex: 3,
                        ),
                        CustomButton(
                          label: S.of(context).tranformToAlternateForm,
                          onPressed: widget
                                          .rpgCharConfig
                                          .transformationComponents
                                          ?.isNotEmpty ==
                                      true &&
                                  _selectedTransformationUuid.isNotEmpty
                              ? () {
                                  // save transformation
                                  navigatorKey.currentState!.pop(
                                      // TODO create result object

                                      // RpgAlternateCharacterConfiguration(
                                      //   uuid: UuidV7().generate(),
                                      //   characterName: widget
                                      //       .characterToRenderStatFor!
                                      //       .transformationComponents!
                                      //       .first
                                      //       .transformationName,
                                      //   characterStats: widget
                                      //       .characterToRenderStatFor!
                                      //       .transformationComponents!
                                      //       .first
                                      //       .transformationStats,
                                      //   transformationComponents: null,
                                      //   alternateForm: null,
                                      //   isAlternateFormActive: null,
                                      // ),
                                      );
                                }
                              : null,
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
        "Verwandlung auswählen", // TODO localize
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: textColor, fontSize: 24),
      ),
    );
  }
}
