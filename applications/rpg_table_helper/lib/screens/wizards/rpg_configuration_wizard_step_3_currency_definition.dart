import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';

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

    if (newIsFormValid != isFormValid) {
      setState(() {
        isFormValid = newIsFormValid;
      });
    }
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
                var temp1 = TextEditingController(
                    text: loadedCurrencyDef.currencyTypes[i].name);
                var temp2 = TextEditingController(
                    text: loadedCurrencyDef
                        .currencyTypes[i].multipleOfPreviousValue!
                        .toString());

                temp1.addListener(() {
                  setState(() {});
                });
                temp2.addListener(() {
                  setState(() {});
                });

                currencyControllerPairs.add((temp1, temp2));
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
            padding: const EdgeInsets.only(top: 20),
            child: Text(buildTextForCurrencyComparison()),
          ),
        ],
      ),
      contentChildren: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
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
          return Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        labelText:
                            "Name der nächst größeren Währung:", // TODO localize
                        textEditingController: e.value.$1,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CustomButton(
                        onPressed: () {
                          // TODO remove this pair from list
                        },
                        icon: Theme(
                            data: ThemeData(
                              iconTheme: const IconThemeData(
                                color: Colors.white,
                                size: 24,
                              ),
                              textTheme: const TextTheme(
                                bodyMedium: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            child: Container(
                                width: 30,
                                height: 30,
                                alignment: AlignmentDirectional.center,
                                child:
                                    const FaIcon(FontAwesomeIcons.trashCan))),
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
                if (e.key != currencyControllerPairs.length - 1)
                  const HorizontalLine(),
                if (e.key != currencyControllerPairs.length - 1)
                  const SizedBox(
                    height: 20,
                  ),
              ],
            ),
          );

          // return _CurrencyPairBlock(
          //     index: e.key,
          //     controllers: e.value,
          //     onDelete: () {
          //       // TODO make me
          //     });
        }),
      ],
    );
  }

  void saveChanges() {
    // TODO change me
    ref
        .read(rpgConfigurationProvider.notifier)
        .updateRpgName(smallestCurrencyNameTextEditingController.text);
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
