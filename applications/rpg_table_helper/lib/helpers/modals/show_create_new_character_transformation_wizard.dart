// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/player_stats_configuration_visuals.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:uuid/v7.dart';

Future<TransformationComponent?> showCreateNewCharacterTransformationWizard(
    BuildContext context,
    {GlobalKey<NavigatorState>? overrideNavigatorKey,
    int? overrideStartScreen,
    TransformationComponent? existingTransformationComponents}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<TransformationComponent>(
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

        return CreateNewCharacterTransformationWizardModalContent(
          modalPadding: modalPadding,
          overrideStartScreen: overrideStartScreen,
          existingTransformationComponents: existingTransformationComponents,
        );
      });
}

class CreateNewCharacterTransformationWizardModalContent
    extends ConsumerStatefulWidget {
  const CreateNewCharacterTransformationWizardModalContent({
    super.key,
    required this.modalPadding,
    this.overrideStartScreen,
    this.existingTransformationComponents,
  });

  final TransformationComponent? existingTransformationComponents;
  final double modalPadding;
  final int? overrideStartScreen;

  @override
  ConsumerState<CreateNewCharacterTransformationWizardModalContent>
      createState() =>
          _CreateNewCharacterTransformationWizardModalContentState();
}

class _CreateNewCharacterTransformationWizardModalContentState
    extends ConsumerState<CreateNewCharacterTransformationWizardModalContent> {
  bool hasDataLoaded = false;
  var labelEditingController = TextEditingController(text: "");
  var descriptionEditingController = TextEditingController(text: "");
  int _currentStep = 0;
  final int _stepCount = 2;
  List<
      ({
        String statHelperText,
        String statName,
        CharacterStatValueType statType,
        String statUuid,
        CharacterStatDefinition stat
      })> _statsToBeSelected = [];

  List<({String statUuid})> _selectedStats = [];
  Map<String, RpgCharacterStatValue> _newestStatValues = {};

  @override
  void initState() {
    _currentStep = widget.overrideStartScreen ?? 0;

    if (widget.existingTransformationComponents != null) {
      labelEditingController.text =
          widget.existingTransformationComponents!.transformationName;
      descriptionEditingController.text =
          widget.existingTransformationComponents!.transformationDescription ??
              "";
      _selectedStats = widget
          .existingTransformationComponents!.transformationStats
          .map((e) => (statUuid: e.statUuid))
          .toList();

      _newestStatValues = Map.fromEntries(widget
          .existingTransformationComponents!.transformationStats
          .map((e) => MapEntry(e.statUuid, e)));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        setState(() {
          hasDataLoaded = true;

          _statsToBeSelected = data.characterStatTabsDefinition!
              .expand((l) => l.statsInTab)

              // we do not allow the transformed character to have a companion selector or a transform into alternate form button
              .where((e) =>
                  e.valueType != CharacterStatValueType.companionSelector &&
                  e.valueType !=
                      CharacterStatValueType.transformIntoAlternateFormBtn)
              .map((e) {
            var statName = e.name;
            if ((statName == "") &&
                e.valueType == CharacterStatValueType.listOfIntsWithIcons) {
              statName = (jsonDecode(e.jsonSerializedAdditionalData!)["values"]
                      as List<dynamic>)
                  .map((e) => e as Map<String, dynamic>)
                  .map((e) => e["label"] as String)
                  .sortedBy((e) => e)
                  .join(", ");
            }
            return (
              statUuid: e.statUuid,
              statName: statName,
              statHelperText: e.helperText,
              statType: e.valueType,
              stat: e
            );
          }).toList();
        });
      } else {
        setState(() {
          _statsToBeSelected.addAll(data.characterStatTabsDefinition!
              .expand((l) => l.statsInTab)
              .where((e) => !_statsToBeSelected
                  .map((e) => e.statUuid)
                  .contains(e.statUuid))
              .map((e) => (
                    statUuid: e.statUuid,
                    statName: e.name,
                    statHelperText: e.helperText,
                    statType: e.valueType,
                    stat: e
                  ))
              .toList());
        });
      }
    });

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
              color: CustomThemeProvider.of(context).theme.bgColor,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  getNavbarWithStepVisualization(context),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (_currentStep == 0) ...getStep0Content(context),
                            if (_currentStep == 1) ...getStep1Content(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                  getNavigationButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding getNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
      child: Row(
        children: [
          const Spacer(flex: 1),
          CustomButton(
            label: S.of(context).back,
            onPressed: () {
              if (_currentStep != 0) {
                setState(() {
                  _currentStep--;
                });
                return;
              }
            },
          ),
          Spacer(
            flex: 3,
          ),
          CustomButton(
            label: (_currentStep + 1 == _stepCount)
                ? S.of(context).send
                : S.of(context).next,
            onPressed: () {
              if (_currentStep + 1 != _stepCount) {
                setState(() {
                  _currentStep++;
                });
                return;
              } else {
                // save transformation
                navigatorKey.currentState!.pop(TransformationComponent(
                  transformationUuid: widget.existingTransformationComponents
                          ?.transformationUuid ??
                      UuidV7().generate(),
                  transformationName: labelEditingController.text,
                  transformationDescription: descriptionEditingController.text,
                  transformationStats: _selectedStats
                      .map((e) => _newestStatValues[e.statUuid])
                      .where((e) => e != null)
                      .map((e) => _newestStatValues[e!.statUuid]!)
                      .toList(),
                ));
              }
            },
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Navbar getNavbarWithStepVisualization(BuildContext context) {
    return Navbar(
      backInsteadOfCloseIcon: false,
      closeFunction: () {
        navigatorKey.currentState!.pop(null);
      },
      menuOpen: null,
      useTopSafePadding: false,
      titleWidget: Text(
        S.of(context).createNewTransformationTitle,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: CustomThemeProvider.of(context).brightnessNotifier.value ==
                    Brightness.light
                ? CustomThemeProvider.of(context).theme.textColor
                : CustomThemeProvider.of(context).theme.darkTextColor,
            fontSize: 24),
      ),
      subTitle: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          ...List.generate(
            _stepCount,
            (index) => CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _currentStep = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Transform.rotate(
                  alignment: Alignment.center,
                  angle: math.pi / 4, // 45 deg
                  child: CustomFaIcon(
                      icon: index == _currentStep
                          ? FontAwesomeIcons.solidSquare
                          : FontAwesomeIcons.square,
                      color: index == _currentStep
                          ? CustomThemeProvider.of(context).theme.accentColor
                          : CustomThemeProvider.of(context)
                              .theme
                              .middleBgColor),
                ),
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  List<Widget> getStep0Content(BuildContext context) {
    return [
      CustomTextField(
        labelText: S.of(context).transformationName,
        textEditingController: labelEditingController,
        keyboardType: TextInputType.name,
      ),
      SizedBox(
        height: 20,
      ),
      CustomTextField(
        labelText: S.of(context).transformationDescription,
        textEditingController: descriptionEditingController,
        keyboardType: TextInputType.text,
      ),
      SizedBox(
        height: 20,
      ),
      Text(
        S.of(context).createTransformationHelperText,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: CustomThemeProvider.of(context).theme.darkTextColor,
              fontSize: 16,
            ),
      ),
      SizedBox(
        height: 10,
      ),
      ..._statsToBeSelected.map(
        (e) => CheckboxListTile.adaptive(
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          splashRadius: 0,
          dense: true,
          checkColor: const Color.fromARGB(255, 57, 245, 88),
          activeColor: CustomThemeProvider.of(context).theme.darkColor,
          visualDensity: VisualDensity(vertical: -2),
          title: Text(
            e.statName,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 16),
          ),
          subtitle: e.statHelperText.isNotEmpty
              ? Text(
                  e.statHelperText,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color:
                          CustomThemeProvider.of(context).theme.darkTextColor),
                )
              : null,
          value: _selectedStats.map((e) => e.statUuid).contains(e.statUuid),
          onChanged: (val) {
            if (val == null) return;

            setState(() {
              if (_selectedStats.map((e) => e.statUuid).contains(e.statUuid)) {
                // remove from list
                setState(() {
                  _selectedStats = _selectedStats
                      .where((element) => element.statUuid != e.statUuid)
                      .toList();
                });
              } else {
                // add to list
                setState(() {
                  _selectedStats.add((statUuid: e.statUuid));
                });
              }
            });
          },
        ),
      )
    ];
  }

  List<Widget> getStep1Content(BuildContext context) {
    return [
      // TODO add step 1 content
      ..._selectedStats.map((e) {
        var asdf = _statsToBeSelected.singleWhere(
            (element) => element.statUuid == e.statUuid,
            orElse: () => throw Exception("Stat not found"));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Konfiguration für ${asdf.statName}", // TODO localize
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: CustomThemeProvider.of(context).theme.darkTextColor,
                    fontSize: 24,
                  ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: PlayerStatsConfigurationVisuals(
                statConfiguration: asdf.stat,
                characterName: null,
                characterValue: _newestStatValues[e.statUuid],
                characterToRenderStatFor:
                    null, // TODO this should get passed the current transformation
                onNewStatValue: (newValue) {
                  setState(() {
                    _newestStatValues[e.statUuid] = newValue;
                  });
                },
                hideAdditionalSetting: false,
                hideVariantSelection: true,
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        );
      })
    ];
  }
}
