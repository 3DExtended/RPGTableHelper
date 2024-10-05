import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class RpgConfigurationWizardStep3CurrencyDefinition extends WizardStepBase {
  const RpgConfigurationWizardStep3CurrencyDefinition({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
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
    super.initState();
  }

  @override
  void dispose() {
    smallestCurrencyNameTextEditingController
        .removeListener(_updateStateForFormValidation);
    super.dispose();
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

    var stepHelperText = '''

Als nächstes kommen wir zu den Items der Welt!

Lass uns anfangen indem du einstellst, welche Währung in dem RPG genutzt wird und welcher Umrechnungskurs zwischen denen herrscht.

Fang bitte mit der kleinsten Einheit an und arbeite dich hoch bis zur größten Währung!
'''; // TODO localize

    return TwoPartWizardStepBody(
      wizardTitle: "RPG Configuration", // TODO localize
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepTitle: "Währungen", // TODO Localize,
      stepHelperText: stepHelperText,
      onNextBtnPressed: !isFormValid
          ? null
          : () {
              saveChanges();
              widget.onNextBtnPressed();
            },
      onPreviousBtnPressed: () {
        // TODO as we dont validate the state of this form we are not saving changes. hence we should inform the user that their changes are revoked.
        widget.onPreviousBtnPressed();
      },
      footerWidget: Column(
        children: [
          const HorizontalLine(),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 30),
            child: Text(buildTextForCurrencyComparison()),
          ),
        ],
      ),
      contentChildren: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                keyboardType: TextInputType.text,
                labelText: "Name der kleinsten Währung:", // TODO localize
                textEditingController:
                    smallestCurrencyNameTextEditingController,
              ),
            ),
            const SizedBox(
              height: 50,
              width: 50,
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const HorizontalLine(),
        const SizedBox(
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

                      labelText:
                          "Name der nächst größeren Währung:", // TODO localize
                      textEditingController: e.value.$1,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 70,
                    clipBehavior: Clip.none,
                    child: CustomButton(
                      onPressed: () {
                        // remove this pair from list
                        setState(() {
                          currencyControllerPairs.removeAt(e.key);
                        });
                      },
                      icon: const CustomFaIcon(icon: FontAwesomeIcons.trashCan),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      keyboardType: TextInputType.number,

                      labelText:
                          "Gleichwertige Anzahl an vorheriger Währung:", // TODO localize
                      textEditingController: e.value.$2,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const SizedBox(
                    height: 50,
                    width: 50,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const HorizontalLine(),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        }),
        CustomButton(
          onPressed: () {
            setState(() {
              addNewCurrencyPair("New", "10");
            });
          },
          icon: Theme(
              data: ThemeData(
                iconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 16,
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              child: Container(
                  width: 24,
                  height: 24,
                  alignment: AlignmentDirectional.center,
                  child: const FaIcon(FontAwesomeIcons.plus))),
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
    // TODO change me

    var newCurrencyMapping = CurrencyDefinition(currencyTypes: []);
    newCurrencyMapping.currencyTypes.add(CurrencyType(
        name: smallestCurrencyNameTextEditingController.text,
        multipleOfPreviousValue: null));

    for (var pair in currencyControllerPairs) {
      newCurrencyMapping.currencyTypes.add(CurrencyType(
          name: pair.$1.text,
          multipleOfPreviousValue: int.parse(pair.$2.text)));
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

      // second entry is value
      if (editPair.$2.text.isEmpty || editPair.$2.text.isEmpty) {
        return false;
      }

      // check if editPair.$2 contains int > 1
      var value = editPair.$2.text;
      var parsedInt = int.tryParse(value);
      if (parsedInt == null || parsedInt <= 1) {
        return false;
      }
    }

    return true;
  }

  String buildTextForCurrencyComparison() {
    var result = "";
    var currentMultiple = 1;
    for (var i = currencyControllerPairs.length - 1; i >= 0; i--) {
      if (i != currencyControllerPairs.length - 1) result += " = ";

      result += "$currentMultiple ";
      result += currencyControllerPairs[i].$1.text;

      var parseInt = int.tryParse(currencyControllerPairs[i].$2.text);

      if (parseInt == null || parseInt < 1) parseInt = 0;
      currentMultiple *= parseInt;
    }

    if (currencyControllerPairs.isNotEmpty) result += " = ";

    result += "$currentMultiple ";
    result += smallestCurrencyNameTextEditingController.text;

    return result;
  }
}
