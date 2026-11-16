import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/components/wizards/wizard_step_save_registry.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/number_input.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class RpgConfigurationWizardStep3CurrencyDefinition extends WizardStepBase {
  const RpgConfigurationWizardStep3CurrencyDefinition({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
    required super.setWizardTitle,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep3CurrencyDefinition> createState() =>
      _RpgConfigurationWizardStep3CurrencyDefinition();
}

class _RpgConfigurationWizardStep3CurrencyDefinition
    extends ConsumerState<RpgConfigurationWizardStep3CurrencyDefinition> {
  bool hasDataLoaded = false;
  bool isFormValid = false;

  TextEditingController smallestCurrencyNameTextEditingController =
      TextEditingController();

  List<(TextEditingController, TextEditingController)> currencyControllerPairs =
      [];

  void _updateStateForFormValidation() {
    var newIsFormValid = getIsFormValid();

    setState(() {
      if (newIsFormValid != isFormValid) {
        isFormValid = newIsFormValid;
      }
    });
  }

  @override
  void initState() {
    smallestCurrencyNameTextEditingController
        .addListener(_updateStateForFormValidation);

    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      widget.setWizardTitle(S.of(context).wizardCurrencyStepTitle);
    });
    registerWizardStepSave(_saveIfValid);

    super.initState();
  }

  @override
  void dispose() {
    unregisterWizardStepSave(_saveIfValid);
    smallestCurrencyNameTextEditingController
        .removeListener(_updateStateForFormValidation);
    super.dispose();
  }

  /// Called by the wizard when the step is left in any way. Incomplete
  /// currencies are not saved.
  void _saveIfValid() {
    if (getIsFormValid()) {
      saveChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        setState(() {
          hasDataLoaded = true;

          var loadedCurrencyDef = data.currencyDefinition;
          if (loadedCurrencyDef.currencyTypes.isNotEmpty) {
            smallestCurrencyNameTextEditingController.text =
                loadedCurrencyDef.currencyTypes[0].name;

            if (loadedCurrencyDef.currencyTypes.length > 1) {
              for (var i = 1; i < loadedCurrencyDef.currencyTypes.length; i++) {
                var newCurrencyName = loadedCurrencyDef.currencyTypes[i].name;
                var newCurrencyValue = loadedCurrencyDef
                    .currencyTypes[i].multipleOfPreviousValue!
                    .toString();

                addNewCurrencyPair(newCurrencyName, newCurrencyValue);
              }
            }
          }
        });
      }
    });

    var stepHelperText = S.of(context).wizardCurrencyStepHelper;

    return TwoPartWizardStepBody(
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepHelperText: stepHelperText,
      onNextBtnPressed: !isFormValid
          ? null
          : () {
              saveChanges();
              widget.onNextBtnPressed();
            },
      // Leaving the step saves valid currencies through the registered save.
      onPreviousBtnPressed: widget.onPreviousBtnPressed,
      sideBarFlex: 1,
      contentFlex: 2,
      footerWidget: Column(
        children: [
          HorizontalLine(),
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 30),
            child: Text(
              buildTextForCurrencyComparison(),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: CustomThemeProvider.of(context).theme.darkTextColor,
                  ),
            ),
          ),
        ],
      ),
      contentChildren: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                keyboardType: TextInputType.text,
                labelText: S.of(context).wizardSmallestCurrencyLabel,
                textEditingController:
                    smallestCurrencyNameTextEditingController,
              ),
            ),
            SizedBox(
              height: 50,
              width: 50,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        HorizontalLine(),
        SizedBox(
          height: 20,
        ),
        ...currencyControllerPairs.asMap().entries.map((e) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      keyboardType: TextInputType.text,
                      labelText: S.of(context).wizardNextCurrencyLabel,
                      textEditingController: e.value.$1,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 40,
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: CustomButton(
                      isSubbutton: true,
                      variant: CustomButtonVariant.FlatButton,
                      onPressed: () {
                        // remove this pair from list
                        setState(() {
                          currencyControllerPairs.removeAt(e.key);
                        });
                      },
                      icon: CustomFaIcon(
                        icon: FontAwesomeIcons.trashCan,
                        color: CustomThemeProvider.of(context).theme.darkColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: CustomTextField(
                      // Signed keyboard: on iOS it has a return key, so the
                      // keyboard can be closed.
                      keyboardType: signedIntKeyboardType,
                      labelText: S.of(context).wizardCurrencyMultipleLabel,
                      textEditingController: e.value.$2,
                      errorText: parseCurrencyMultiple(e.value.$2.text) == null
                          ? S.of(context).invalidCurrencyMultiple
                          : null,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 40,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              HorizontalLine(),
              SizedBox(
                height: 20,
              ),
            ],
          );
        }),
        CustomButton(
          variant: CustomButtonVariant.Default,
          isSubbutton: true,
          onPressed: () {
            setState(() {
              addNewCurrencyPair(S.of(context).wizardNewEntryDefaultName, "10");
            });
          },
          icon: Theme(
              data: ThemeData(
                fontFamily: "Ruwudu",
                iconTheme: IconThemeData(
                  color: CustomThemeProvider.of(context).theme.darkColor,
                  size: 16,
                ),
                textTheme: TextTheme(
                  bodyMedium: TextStyle(
                    color: CustomThemeProvider.of(context).theme.darkColor,
                  ),
                ),
              ),
              child: Container(
                  width: 24,
                  height: 24,
                  alignment: AlignmentDirectional.center,
                  child: FaIcon(FontAwesomeIcons.plus))),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void addNewCurrencyPair(String newCurrencyName, String newCurrencyValue) {
    var temp1 = TextEditingController(text: newCurrencyName);
    var temp2 = TextEditingController(text: newCurrencyValue);

    temp1.addListener(() {
      _updateStateForFormValidation();
    });
    temp2.addListener(() {
      _updateStateForFormValidation();
    });

    currencyControllerPairs.add((temp1, temp2));
  }

  void saveChanges() {
    var newCurrencyMapping = CurrencyDefinition(currencyTypes: []);
    newCurrencyMapping.currencyTypes.add(CurrencyType(
        name: smallestCurrencyNameTextEditingController.text,
        multipleOfPreviousValue: null));

    for (var pair in currencyControllerPairs) {
      newCurrencyMapping.currencyTypes.add(CurrencyType(
          name: pair.$1.text,
          multipleOfPreviousValue: parseCurrencyMultiple(pair.$2.text)!));
    }

    ref
        .read(rpgConfigurationProvider.notifier)
        .updateCurrency(newCurrencyMapping);
  }

  bool getIsFormValid() {
    const currencyNameMinLenght = 1;
    if (hasDataLoaded != true ||
        smallestCurrencyNameTextEditingController.text.isEmpty ||
        smallestCurrencyNameTextEditingController.text.length <
            currencyNameMinLenght) {
      return false;
    }

    for (var editPair in currencyControllerPairs) {
      // first entry is name
      if (editPair.$1.text.isEmpty ||
          editPair.$1.text.length < currencyNameMinLenght) {
        return false;
      }

      // second entry is the multiple of the previous currency
      if (parseCurrencyMultiple(editPair.$2.text) == null) {
        return false;
      }
    }

    return true;
  }

  String buildTextForCurrencyComparison() {
    var numberFormat = NumberFormat('#,###');

    var result = "";
    var currentMultiple = 1;
    for (var i = currencyControllerPairs.length - 1; i >= 0; i--) {
      if (i != currencyControllerPairs.length - 1) result += " = ";

      result += "${numberFormat.format(currentMultiple)} ";
      result += currencyControllerPairs[i].$1.text;

      var parseInt = int.tryParse(currencyControllerPairs[i].$2.text);

      if (parseInt == null || parseInt < 1) parseInt = 0;
      currentMultiple *= parseInt;
    }

    if (currencyControllerPairs.isNotEmpty) result += " = ";

    result += "${numberFormat.format(currentMultiple)} ";
    result += smallestCurrencyNameTextEditingController.text;

    return result;
  }
}

/// How many of the previous currency one unit is worth: a whole number
/// greater than 1. Null for anything else, including an empty field.
int? parseCurrencyMultiple(String? text) {
  final value = parseSignedInt(text);
  if (value == null || value <= 1) return null;
  return value;
}
