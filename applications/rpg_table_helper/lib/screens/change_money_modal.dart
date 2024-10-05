import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

Future<int?> showChangeMoneyModal(BuildContext context,
    {GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<int>(
    isDismissible: true,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    backgroundColor: const Color.fromARGB(158, 49, 49, 49),
    context: context,
    // barrierColor: const Color.fromARGB(20, 201, 201, 201),
    builder: (context) => const ChangeMoneyModalContent(),
    overrideNavigatorKey: overrideNavigatorKey,
  );
}

class ChangeMoneyModalContent extends ConsumerStatefulWidget {
  const ChangeMoneyModalContent({
    super.key,
  });

  @override
  ConsumerState<ChangeMoneyModalContent> createState() =>
      _ChangeMoneyModalContentState();
}

class _ChangeMoneyModalContentState
    extends ConsumerState<ChangeMoneyModalContent> {
  CurrencyDefinition? _currencyDefinition;
  bool hasRpgConfigLoaded = false;
  bool hasRpgCharacterConfigLoaded = false;

  int initBaseValueOfPlayerMoney = 0;

  final List<(String, TextEditingController)> _controllers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasRpgConfigLoaded) {
        setState(() {
          hasRpgConfigLoaded = true;
          _currencyDefinition = data.currencyDefinition;
          initTextEditControllers();
        });
      }
    });
    ref.watch(rpgCharacterConfigurationProvider).whenData((data) {
      if (!hasRpgCharacterConfigLoaded) {
        setState(() {
          hasRpgCharacterConfigLoaded = true;
          initBaseValueOfPlayerMoney = data.moneyInBaseType ?? 0;

          initTextEditControllers();
        });
      }
    });

    var modalPadding = 80.0;
    if (MediaQuery.of(context).size.width < 800) {
      modalPadding = 20.0;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: modalPadding,
          vertical: modalPadding), // TODO maybe percentage of total width?
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBox(
                  borderThickness: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(21.0),
                    child: !hasRpgConfigLoaded
                        ? Container()
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Geld pflegen", // TODO localize/ switch text between add and edit
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 32),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  ..._controllers
                                      .map((controllerTuple) => Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: CustomTextField(
                                                  labelText: controllerTuple.$1,
                                                  textEditingController:
                                                      controllerTuple.$2,
                                                  keyboardType:
                                                      TextInputType.number),
                                            ),
                                          ))
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                                child: Row(
                                  children: [
                                    CustomButton(
                                      label: "Abbrechen", // TODO localize
                                      onPressed: () {
                                        navigatorKey.currentState!.pop(null);
                                      },
                                    ),
                                    const Spacer(),
                                    CustomButton(
                                      label: "Speichern", // TODO localize
                                      onPressed: () {
                                        // TODO make me
                                        navigatorKey.currentState!
                                            .pop(getBaseCurrencyPrice());
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
      ),
    );
  }

  int getBaseCurrencyPrice() {
    int result = 0;

    for (var i = 0; i < _controllers.length; i++) {
      var controller = _controllers[i];
      var currencyType =
          _currencyDefinition!.currencyTypes.reversed.toList()[i];

      var parsedUserInput = int.tryParse(controller.$2.text) ?? 0;

      result += parsedUserInput;

      if (i != _controllers.length - 1) {
        assert(currencyType.multipleOfPreviousValue != null,
            "Required for all entries but the last (base) one");

        result *= currencyType.multipleOfPreviousValue!;
      }
    }

    return result;
  }

  void initTextEditControllers() {
    if (hasRpgCharacterConfigLoaded && hasRpgConfigLoaded) {
      var money = CurrencyDefinition.valueOfItemForDefinition(
          _currencyDefinition!, initBaseValueOfPlayerMoney);
      for (var i = 0; i < _currencyDefinition!.currencyTypes.length; i++) {
        var controller = TextEditingController();

        if (money[i] != 0) {
          controller.text = money[i].toString();
        }

        _controllers.add((
          _currencyDefinition!.currencyTypes.reversed.toList()[i].name,
          controller
        ));
      }
    }
  }
}
