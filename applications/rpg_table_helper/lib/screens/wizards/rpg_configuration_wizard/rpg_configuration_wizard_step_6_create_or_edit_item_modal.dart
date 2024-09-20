import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_dropdown_menu.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/helpers/iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

import '../../../helpers/modal_helpers.dart';

Future<RpgItem?> showCreateOrEditItemModal(
    BuildContext context, RpgItem itemToEdit,
    {GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<RpgItem>(
    isDismissible: false,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    backgroundColor: const Color.fromARGB(158, 49, 49, 49),
    context: context,
    // barrierColor: const Color.fromARGB(20, 201, 201, 201),
    builder: (context) => CreateOrEditItemModalContent(itemToEdit: itemToEdit),
    overrideNavigatorKey: overrideNavigatorKey,
  );
}

class CreateOrEditItemModalContent extends ConsumerStatefulWidget {
  final RpgItem itemToEdit;

  const CreateOrEditItemModalContent({super.key, required this.itemToEdit});

  @override
  ConsumerState<CreateOrEditItemModalContent> createState() =>
      _CreateOrEditItemModalContentState();
}

class _CreateOrEditItemModalContentState
    extends ConsumerState<CreateOrEditItemModalContent> {
  TextEditingController nameController = TextEditingController();
  TextEditingController patchSizeTextController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<TextEditingController> currencyControllers = [];

  String? selectedItemCategoryId;

  bool hasDataLoaded = false;

  List<ItemCategory> _allItemCategories = [];
  CurrencyDefinition? _currencyDefinition;
  List<PlaceOfFinding> _allPlacesOfFindings = [];

  List<(String? id, TextEditingController)> _placesOfFinding = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        nameController.text = widget.itemToEdit.name;
        descriptionController.text = widget.itemToEdit.description;
        selectedItemCategoryId = widget.itemToEdit.categoryId;
        patchSizeTextController.text =
            widget.itemToEdit.patchSize?.toString() ?? "1D4+1";

        _placesOfFinding = widget.itemToEdit.placeOfFindings
            .map((pair) => (
                  pair.placeOfFindingId,
                  TextEditingController(text: pair.diceChallenge.toString())
                ))
            .toList();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        setState(() {
          hasDataLoaded = true;
          _allItemCategories = data.itemCategories;
          _allPlacesOfFindings = data.placesOfFindings;
          _currencyDefinition = data.currencyDefinition;

          if (widget.itemToEdit.baseCurrencyPrice != 0) {
            currencyControllers = CurrencyDefinition.valueOfItemForDefinition(
                    _currencyDefinition!, widget.itemToEdit.baseCurrencyPrice)
                .map((e) => TextEditingController(text: e.toString()))
                .toList();
          } else {
            // get price in currency values
            currencyControllers = List.generate(
                _currencyDefinition!.currencyTypes.length,
                (i) => TextEditingController());
          }
        });
      }
    });
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 80.0,
          vertical: 80.0), // TODO maybe percentage of total width?
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: min(MediaQuery.of(context).size.width * 0.5, 800)),
            child: StyledBox(
              borderThickness: 1,
              child: Padding(
                padding: const EdgeInsets.all(21.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Item bearbeiten", // TODO localize/ switch text between add and edit
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: Colors.white, fontSize: 32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    keyboardType: TextInputType.text,
                                    labelText:
                                        "Name des Items:", // TODO localize
                                    textEditingController: nameController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomDropdownMenu(
                                      selectedValueTemp: selectedItemCategoryId,
                                      setter: (newValue) {
                                        setState(() {
                                          selectedItemCategoryId = newValue;
                                        });
                                      },
                                      label: 'Kategorie', // TODO localize
                                      items: [
                                        ...(ItemCategory
                                                .flattenCategoriesRecursive(
                                                    categories:
                                                        _allItemCategories,
                                                    combineCategoryNames: true)
                                            .sortBy((e) => e.name)),
                                        ItemCategory(
                                            name: "Sonstiges (Keine Kategorie)",
                                            uuid: "",
                                            subCategories: [],
                                            hideInInventoryFilters: true),
                                      ].map((category) {
                                        return DropdownMenuItem<String?>(
                                          value: category.uuid == ""
                                              ? null
                                              : category.uuid,
                                          child: Text(category.name),
                                        );
                                      }).toList()),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // Currency value
                            if (_currencyDefinition != null &&
                                currencyControllers.length ==
                                    _currencyDefinition!.currencyTypes.length)
                              Row(
                                children: _currencyDefinition!
                                    .currencyTypes.reversed
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        e.key == 0 ? 0 : 10,
                                        0,
                                        e.key ==
                                                _currencyDefinition!
                                                        .currencyTypes.length -
                                                    1
                                            ? 0
                                            : 10,
                                        0,
                                      ),
                                      child: CustomTextField(
                                        keyboardType: TextInputType.number,
                                        labelText:
                                            "${e.value.name}:", // TODO localize
                                        textEditingController:
                                            currencyControllers[e.key],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    keyboardType: TextInputType.text,
                                    labelText:
                                        "Fundgröße: (optional)", // TODO localize
                                    textEditingController:
                                        patchSizeTextController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    keyboardType: TextInputType.multiline,
                                    labelText: "Beschreibung:", // TODO localize
                                    textEditingController:
                                        descriptionController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const HorizontalLine(),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text("Fundorte:"),
                            const SizedBox(
                              height: 10,
                            ),
                            ..._placesOfFinding.asMap().entries.map(
                                  (tuple) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: CustomDropdownMenu(
                                              selectedValueTemp: tuple.value.$1,
                                              setter: (newValue) {
                                                setState(() {
                                                  _placesOfFinding[tuple.key] =
                                                      (
                                                    newValue,
                                                    _placesOfFinding[tuple.key]
                                                        .$2
                                                  );
                                                });
                                              },
                                              label:
                                                  'Fundort #${tuple.key + 1}', // TODO localize
                                              items: _allPlacesOfFindings
                                                  .sortBy((p) => p.name)
                                                  .map((placeOfFinding) {
                                                return DropdownMenuItem<
                                                    String?>(
                                                  value:
                                                      placeOfFinding.uuid == ""
                                                          ? null
                                                          : placeOfFinding.uuid,
                                                  child:
                                                      Text(placeOfFinding.name),
                                                );
                                              }).toList()),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          width: 75,
                                          child: CustomTextField(
                                            keyboardType: TextInputType.text,
                                            labelText: "DC:", // TODO localize
                                            textEditingController:
                                                tuple.value.$2,
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
                                                _placesOfFinding
                                                    .removeAt(tuple.key);
                                              });
                                            },
                                            icon: const CustomFaIcon(
                                                icon:
                                                    FontAwesomeIcons.trashCan),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  CustomButton(
                                    isSubbutton: true,
                                    onPressed: () {
                                      setState(() {
                                        _placesOfFinding.add((
                                          _allPlacesOfFindings.isNotEmpty
                                              ? _allPlacesOfFindings[0].uuid
                                              : "",
                                          TextEditingController(text: "10")
                                        ));
                                      });
                                    },
                                    label: "Neuer Fundort",
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
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 5, 0),
                                          child: Container(
                                              width: 16,
                                              height: 16,
                                              alignment:
                                                  AlignmentDirectional.center,
                                              child: const FaIcon(
                                                  FontAwesomeIcons.plus)),
                                        )),
                                  ),
                                ],
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
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
                              navigatorKey.currentState!.pop(RpgItem(
                                  uuid: widget.itemToEdit.uuid,
                                  name: nameController.text,
                                  categoryId: selectedItemCategoryId,
                                  description: descriptionController.text,
                                  patchSize: getPatchSize(),
                                  baseCurrencyPrice: getBaseCurrencyPrice(),
                                  placeOfFindings: _placesOfFinding
                                      .map((pair) => RpgItemRarity(
                                          placeOfFindingId: pair.$1!,
                                          diceChallenge:
                                              int.parse(pair.$2.text)))
                                      .toList()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int getBaseCurrencyPrice() {
    int result = 0;

    for (var i = 0; i < currencyControllers.length; i++) {
      var controller = currencyControllers[i];
      var currencyType =
          _currencyDefinition!.currencyTypes.reversed.toList()[i];

      var parsedUserInput = int.tryParse(controller.text) ?? 0;

      result += parsedUserInput;

      if (i != currencyControllers.length - 1) {
        assert(currencyType.multipleOfPreviousValue != null,
            "Required for all entries but the last (base) one");

        result *= currencyType.multipleOfPreviousValue!;
      }
    }

    return result;
  }

  DiceRoll? getPatchSize() {
    var userInput = patchSizeTextController.text;
    if (userInput.isEmpty) {
      return null;
    }

    try {
      return DiceRoll.parse(userInput);
    } catch (e) {
      return null;
    }
  }
}
