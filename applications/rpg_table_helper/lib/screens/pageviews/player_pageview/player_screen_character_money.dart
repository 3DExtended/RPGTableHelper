import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_int_edit_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

enum MoneyChangeMode {
  addMoney,
  spendMoney,
}

class PlayerScreenCharacterMoney extends ConsumerStatefulWidget {
  final RpgConfigurationModel rpgConfig;
  final RpgCharacterConfiguration charToRender;
  const PlayerScreenCharacterMoney({
    super.key,
    required this.rpgConfig,
    required this.charToRender,
  });

  @override
  ConsumerState<PlayerScreenCharacterMoney> createState() =>
      _PlayerScreenCharacterMoneyState();
}

class _PlayerScreenCharacterMoneyState
    extends ConsumerState<PlayerScreenCharacterMoney> {
  var _selectedMoneyChangeMode = MoneyChangeMode.addMoney;
  List<({String label, int currentValue, int? multiplier})> _currencyValues =
      [];

  RpgCharacterConfiguration? charToRender;

  @override
  void initState() {
    _currencyValues = widget.rpgConfig.currencyDefinition.currencyTypes
        .map((e) => (
              label: e.name,
              currentValue: 0,
              multiplier: e.multipleOfPreviousValue
            ))
        .toList()
        .reversed
        .toList();
    charToRender = widget.charToRender;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          color: bgColor,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              CustomFaIcon(
                icon: FontAwesomeIcons.sackDollar,
                size: 48,
                color: darkColor,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                charToRender == null
                    ? "0 Gold"
                    : buildTextForCurrencyComparison(
                        widget.rpgConfig, charToRender!.moneyInBaseType ?? 0),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: darkTextColor, fontSize: 24),
              ),
              Text(
                "Aktuelles Guthaben",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: darkTextColor, fontSize: 16),
              ),
              SizedBox(
                height: 20,
              ),
              HorizontalLine(),
              SizedBox(
                height: 20,
              ),
              CupertinoSlidingSegmentedControl<MoneyChangeMode>(
                backgroundColor: middleBgColor,
                thumbColor: darkColor,
                // This represents the currently selected segmented control.
                groupValue: _selectedMoneyChangeMode,
                // Callback that sets the selected segmented control.
                onValueChanged: (MoneyChangeMode? value) {
                  if (value != null) {
                    setState(() {
                      _selectedMoneyChangeMode = value;
                    });
                  }
                },
                children: <MoneyChangeMode, Widget>{
                  MoneyChangeMode.addMoney: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Guthaben hinzufügen', // TODO localize
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontSize: 16,
                          color: _selectedMoneyChangeMode ==
                                  MoneyChangeMode.addMoney
                              ? textColor
                              : darkTextColor),
                    ),
                  ),
                  MoneyChangeMode.spendMoney: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Guthaben abziehen', // TODO localize
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontSize: 16,
                          color: _selectedMoneyChangeMode ==
                                  MoneyChangeMode.spendMoney
                              ? textColor
                              : darkTextColor),
                    ),
                  ),
                },
              ),
              SizedBox(
                height: 20,
              ),
              Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                children: _currencyValues
                    .asMap()
                    .entries
                    .map((cv) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomFaIcon(
                                icon: FontAwesomeIcons.sackDollar,
                                size: 40,
                                // TODO those colors should be configurable by the dm
                                color: cv.value.label == "Platin"
                                    ? const Color.fromARGB(255, 108, 171,
                                        143) // const Color.fromARGB(255, 103, 138, 138)
                                    : cv.value.label == "Gold"
                                        ? const Color.fromARGB(
                                            255, 237, 202, 47)
                                        : cv.value.label == "Silber"
                                            ? const Color.fromARGB(
                                                255, 184, 189, 190)
                                            : const Color.fromARGB(
                                                255, 212, 126, 22),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              CustomIntEditField(
                                minValue: 0,
                                maxValue: 9999,
                                onValueChange: (newValue) {
                                  // TODO make me
                                  setState(() {
                                    _currencyValues[cv.key] = (
                                      label: _currencyValues[cv.key].label,
                                      multiplier:
                                          _currencyValues[cv.key].multiplier,
                                      currentValue: newValue,
                                    );
                                  });
                                },
                                label: cv.value.label,
                                startValue: cv.value.currentValue,
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                charToRender == null
                    ? "0 Gold"
                    : buildTextForCurrencyComparisonAfterAdjustment(
                        widget.rpgConfig, charToRender!),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: darkTextColor, fontSize: 24),
              ),
              Text(
                "Neues Guthaben",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: darkTextColor, fontSize: 16),
              ),
              SizedBox(
                height: 40,
              ),
              CustomButtonNewdesign(
                onPressed: getCurrentlyTypedBasePrice() == 0 ||
                        getNewCalculatedBasePrice(
                                widget.rpgConfig, charToRender) <
                            0
                    ? null
                    : () {
                        var newestConfig = ref
                            .read(rpgCharacterConfigurationProvider)
                            .requireValue;

                        var updatedChar = newestConfig.copyWith(
                            moneyInBaseType: getNewCalculatedBasePrice(
                                widget.rpgConfig, newestConfig));
                        ref
                            .read(rpgCharacterConfigurationProvider.notifier)
                            .updateConfiguration(updatedChar);

                        setState(() {
                          charToRender = updatedChar;

                          for (int i = 0; i < _currencyValues.length; i++) {
                            _currencyValues[i] = (
                              label: _currencyValues[i].label,
                              multiplier: _currencyValues[i].multiplier,
                              currentValue: 0,
                            );
                          }
                        });
                      },
                variant: CustomButtonNewdesignVariant.AccentButton,
                label: _selectedMoneyChangeMode == MoneyChangeMode.addMoney
                    ? "Geld hinzufügen" // TODO localize
                    : "Geld abziehen", // TODO localize
              )
            ],
          )),
    );
  }

  String buildTextForCurrencyComparison(
      RpgConfigurationModel rpgConfig, int moneyToVisualize) {
    var currentPlayerMoney = moneyToVisualize;

    var valueSplitInCurrency = CurrencyDefinition.valueOfItemForDefinition(
        rpgConfig.currencyDefinition, currentPlayerMoney);

    var result = "";

    var reversedCurrencyNames =
        rpgConfig.currencyDefinition.currencyTypes.reversed.toList();
    for (var i = 0; i < valueSplitInCurrency.length; i++) {
      var value = valueSplitInCurrency[i];
      if (value != 0) {
        var nameOfCurrencyValue = reversedCurrencyNames[i].name;
        result += " $value $nameOfCurrencyValue";
      }
    }

    if (result.isEmpty) {
      return "0 ${rpgConfig.currencyDefinition.currencyTypes.first.name}";
    }

    return result.trim();
  }

  String buildTextForCurrencyComparisonAfterAdjustment(
      RpgConfigurationModel rpgConfig, RpgCharacterConfiguration charToRender) {
    var updatedMoneyValue = getNewCalculatedBasePrice(rpgConfig, charToRender);

    if (_selectedMoneyChangeMode == MoneyChangeMode.addMoney) {
      return buildTextForCurrencyComparison(rpgConfig, updatedMoneyValue);
    } else {
      var updatedMoney = updatedMoneyValue;

      if (updatedMoney < 0) {
        return "Zu wenig Geld für diese Ausgabe"; // TODO localize
      }
      return buildTextForCurrencyComparison(rpgConfig, max(0, updatedMoney));
    }
  }

  int getNewCalculatedBasePrice(RpgConfigurationModel rpgConfig,
      RpgCharacterConfiguration? charToRender) {
    var currentlyTypedInBasePrice = getCurrentlyTypedBasePrice();

    if (_selectedMoneyChangeMode == MoneyChangeMode.addMoney) {
      return currentlyTypedInBasePrice + (charToRender?.moneyInBaseType ?? 0);
    } else {
      var updatedMoney =
          (charToRender?.moneyInBaseType ?? 0) - currentlyTypedInBasePrice;

      return updatedMoney;
    }
  }

  int getCurrentlyTypedBasePrice() {
    var result = 0;
    var currentMultiplier = 1;
    for (var i = (_currencyValues.length - 1); i >= 0; i--) {
      var tuple = _currencyValues[i];
      if (tuple.multiplier != null) {
        currentMultiplier *= tuple.multiplier!;
      }
      result += tuple.currentValue * currentMultiplier;
    }

    return result;
  }
}
