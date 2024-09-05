import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_dropdown_menu.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/helpers/iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

import '../../../helpers/modal_helpers.dart';

Future<RpgItem?> showCreateOrEditItemModal(
  BuildContext context,
  RpgItem itemToEdit,
) async {
  // show error to user
  await customShowCupertinoModalBottomSheet<RpgItem>(
    isDismissible: false,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: true,
    backgroundColor: const Color.fromARGB(158, 49, 49, 49),
    context: context,
    // barrierColor: const Color.fromARGB(20, 201, 201, 201),
    builder: (context) => CreateOrEditItemModalContent(itemToEdit: itemToEdit),
  );
  return null;
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
  TextEditingController descriptionController = TextEditingController();
  List<TextEditingController> currencyControllers = [];

  String? selectedItemCategoryId;

  bool hasDataLoaded = false;

  List<ItemCategory> _allItemCategories = [];
  CurrencyDefinition? _currencyDefinition;
  List<ItemCategory> _allPlacesOfFindings = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        nameController.text = widget.itemToEdit.name;
        descriptionController.text = widget.itemToEdit.description;
        selectedItemCategoryId = widget.itemToEdit.categoryId;
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
          _allPlacesOfFindings = data.itemCategories;
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
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5),
            child: StyledBox(
              borderThickness: 1,
              child: Padding(
                padding: const EdgeInsets.all(21.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            keyboardType: TextInputType.text,
                            labelText: "Name des Items:", // TODO localize
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
                                ...(ItemCategory.flattenCategoriesRecursive(
                                        categories: _allItemCategories,
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
                                  child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(category.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ))),
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
                        children: _currencyDefinition!.currencyTypes.reversed
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
                                keyboardType: TextInputType.text,
                                labelText: "${e.value.name}:", // TODO localize
                                textEditingController:
                                    currencyControllers[e.key],
                              ),
                            ),
                          );
                        }).toList(),
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
                            label: "Weiter", // TODO localize
                            onPressed: () {
                              navigatorKey.currentState!.pop(RpgItem(
                                uuid: widget.itemToEdit.uuid,
                                name: nameController.text,
                                categoryId: selectedItemCategoryId,
                                description: descriptionController.text,
                                baseCurrencyPrice: getBaseCurrencyPrice(),
                                placeOfFindings: [], // TODO fix me and return list of placesOfFindings
                              ));
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
    // TODO write me!
    return 100;
  }
}
