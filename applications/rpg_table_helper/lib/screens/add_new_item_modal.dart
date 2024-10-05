import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_dropdown_menu.dart';
import 'package:rpg_table_helper/components/custom_dropdown_menu_with_search.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/helpers/iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

Future<(String itemId, int amount)?> showAddNewItemModal(BuildContext context,
    {String? itemCategoryFilter,
    GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<(String itemId, int amount)>(
    isDismissible: true,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    backgroundColor: const Color.fromARGB(158, 49, 49, 49),
    context: context,
    // barrierColor: const Color.fromARGB(20, 201, 201, 201),
    builder: (context) =>
        AddNewItemModalContent(itemCategoryFilter: itemCategoryFilter),
    overrideNavigatorKey: overrideNavigatorKey,
  );
}

class AddNewItemModalContent extends ConsumerStatefulWidget {
  final String? itemCategoryFilter;
  const AddNewItemModalContent({
    super.key,
    this.itemCategoryFilter,
  });

  @override
  ConsumerState<AddNewItemModalContent> createState() =>
      _AddNewItemModalContentState();
}

class _AddNewItemModalContentState
    extends ConsumerState<AddNewItemModalContent> {
  TextEditingController amountController = TextEditingController();

  String? selectedItemCategoryId;
  String? selectedItemId;
  bool hasDataLoaded = false;
  List<ItemCategory> _allItemCategories = [];
  List<RpgItem> _allItems = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        selectedItemCategoryId = widget.itemCategoryFilter;
        amountController.text = "1";
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
          _allItems = data.allItems;
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
                    child: !hasDataLoaded
                        ? Container()
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Item hinzufügen", // TODO localize/ switch text between add and edit
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
                                  Expanded(
                                    child: CustomDropdownMenu(
                                        selectedValueTemp:
                                            selectedItemCategoryId,
                                        setter: (newValue) {
                                          setState(() {
                                            selectedItemCategoryId = newValue;
                                            selectedItemId = null;
                                          });
                                        },
                                        label:
                                            'Kategorie Filter', // TODO localize
                                        items: [
                                          ...(ItemCategory
                                                  .flattenCategoriesRecursive(
                                                      categories:
                                                          _allItemCategories,
                                                      combineCategoryNames:
                                                          true)
                                              .sortBy((e) => e.name)),
                                        ].map((category) {
                                          return DropdownMenuItem<String?>(
                                            value: category.uuid,
                                            child: Text(category.name),
                                          );
                                        }).toList()),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomDropdownMenuWithSearch(
                                        selectedValueTemp: selectedItemId,
                                        setter: (newValue) {
                                          setState(() {
                                            selectedItemId = newValue;
                                          });
                                        },
                                        label: 'Item Auswahl', // TODO localize
                                        items: _allItems.where((it) {
                                          if (selectedItemCategoryId == null) {
                                            return true;
                                          }

                                          if (it.categoryId ==
                                              selectedItemCategoryId) {
                                            return true;
                                          }

                                          // check if selectedItemCategoryId is a parent category. if so, we must return true for the case the current item (it) is in any of its subCategory
                                          var index = _allItemCategories
                                              .indexWhere((ic) =>
                                                  ic.uuid ==
                                                  selectedItemCategoryId);
                                          if (index != -1) {
                                            var category =
                                                _allItemCategories[index];
                                            return category.subCategories.any(
                                                (sc) =>
                                                    sc.uuid == it.categoryId);
                                          }

                                          return false;
                                        }).map((item) {
                                          return DropdownMenuEntry<String?>(
                                            value: item.uuid,
                                            label: item.name,
                                          );
                                        }).toList()),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: CustomTextField(
                                      keyboardType: TextInputType.number,
                                      labelText: "Anzahl", // TODO localize
                                      textEditingController: amountController,
                                    ),
                                  ),
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
                                        try {
                                          navigatorKey.currentState!.pop((
                                            selectedItemId,
                                            int.parse(amountController.text)
                                          ));
                                        } catch (e) {}
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
}
