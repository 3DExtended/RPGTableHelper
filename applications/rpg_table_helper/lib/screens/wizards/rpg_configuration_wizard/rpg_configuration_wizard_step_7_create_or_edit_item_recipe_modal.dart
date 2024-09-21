import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_dropdown_menu_with_search.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/helpers/iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

import '../../../helpers/modal_helpers.dart';

Future<CraftingRecipe?> showCreateOrEditCraftingRecipeModal(
    BuildContext context, CraftingRecipe itemToEdit,
    {GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<CraftingRecipe>(
    isDismissible: false,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    backgroundColor: const Color.fromARGB(158, 49, 49, 49),
    context: context,
    // barrierColor: const Color.fromARGB(20, 201, 201, 201),
    builder: (context) =>
        CreateOrEditCraftingRecipeModalContent(itemToEdit: itemToEdit),
    overrideNavigatorKey: overrideNavigatorKey,
  );
}

class CreateOrEditCraftingRecipeModalContent extends ConsumerStatefulWidget {
  final CraftingRecipe itemToEdit;

  const CreateOrEditCraftingRecipeModalContent(
      {super.key, required this.itemToEdit});

  @override
  ConsumerState<CreateOrEditCraftingRecipeModalContent> createState() =>
      _CreateOrEditCraftingRecipeModalContentState();
}

class _CreateOrEditCraftingRecipeModalContentState
    extends ConsumerState<CreateOrEditCraftingRecipeModalContent> {
  List<String?> requiredItemIdsSelected = [];
  List<(String? selectedItemId, TextEditingController quantityController)>
      selectedIngredient = [];

  (
    String? selectedItemId,
    TextEditingController quantityController
  ) selectedCreatingItem = (null, TextEditingController(text: "1"));

  bool hasDataLoaded = false;

  List<ItemCategory> _allItemCategories = [];
  List<RpgItem> _allItems = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        requiredItemIdsSelected = widget.itemToEdit.requiredItemIds;
        selectedIngredient = widget.itemToEdit.ingredients
            .map((e) => (
                  e.itemUuid,
                  TextEditingController(text: e.amountOfUsedItem.toString())
                ))
            .toList();

        selectedCreatingItem = (
          widget.itemToEdit.createdItem.itemUuid == ""
              ? null
              : widget.itemToEdit.createdItem.itemUuid,
          selectedCreatingItem.$2
        );
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
                            "Rezept bearbeiten", // TODO localize/ switch text between add and edit
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
                                  child: CustomDropdownMenuWithSearch(
                                      selectedValueTemp:
                                          selectedCreatingItem.$1,
                                      setter: (newValue) {
                                        setState(() {
                                          selectedCreatingItem = (
                                            newValue,
                                            selectedCreatingItem.$2
                                          );
                                        });
                                      },
                                      label:
                                          'Herzustellendes Item', // TODO localize
                                      items: _allItems.map((item) {
                                        return DropdownMenuEntry<String?>(
                                          value: item.uuid == ""
                                              ? null
                                              : item.uuid,
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
                                    textEditingController:
                                        selectedCreatingItem.$2,
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
                            const Text("Voraussetzungen:"),
                            const SizedBox(
                              height: 10,
                            ),
                            ...requiredItemIdsSelected.asMap().entries.map(
                                  (tuple) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: CustomDropdownMenuWithSearch(
                                              selectedValueTemp:
                                                  tuple.value == ""
                                                      ? null
                                                      : tuple.value,
                                              setter: (newValue) {
                                                setState(() {
                                                  requiredItemIdsSelected[
                                                      tuple.key] = newValue;
                                                });
                                              },
                                              label:
                                                  'Voraussetzung #${tuple.key + 1}', // TODO localize
                                              items: _allItems
                                                  .sortBy((p) => p.name)
                                                  .map((item) {
                                                return DropdownMenuEntry<
                                                    String?>(
                                                  value: item.uuid == ""
                                                      ? null
                                                      : item.uuid,
                                                  label: item.name,
                                                );
                                              }).toList()),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          height: 50,
                                          width: 70,
                                          clipBehavior: Clip.none,
                                          child: CustomButton(
                                            onPressed: () {
                                              // remove this pair from list
                                              setState(() {
                                                requiredItemIdsSelected
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
                                        requiredItemIdsSelected.add("");
                                      });
                                    },
                                    label: "Weitere Voraussetzung",
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
                            const SizedBox(
                              height: 20,
                            ),
                            const HorizontalLine(),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text("Zutaten:"),
                            const SizedBox(
                              height: 10,
                            ),
                            ...selectedIngredient.asMap().entries.map(
                                  (tuple) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: CustomDropdownMenuWithSearch(
                                              selectedValueTemp:
                                                  tuple.value.$1 == ""
                                                      ? null
                                                      : tuple.value.$1,
                                              setter: (newValue) {
                                                setState(() {
                                                  selectedIngredient[
                                                      tuple.key] = (
                                                    newValue,
                                                    selectedIngredient[
                                                            tuple.key]
                                                        .$2
                                                  );
                                                });
                                              },
                                              label:
                                                  'Zutat #${tuple.key + 1}', // TODO localize
                                              items: _allItems
                                                  .sortBy((p) => p.name)
                                                  .map((item) {
                                                return DropdownMenuEntry<
                                                    String?>(
                                                  value: item.uuid == ""
                                                      ? null
                                                      : item.uuid,
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
                                            labelText:
                                                "Anzahl", // TODO localize
                                            textEditingController:
                                                tuple.value.$2,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          height: 50,
                                          width: 70,
                                          clipBehavior: Clip.none,
                                          child: CustomButton(
                                            onPressed: () {
                                              // remove this pair from list
                                              setState(() {
                                                selectedIngredient
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
                                        selectedIngredient.add((
                                          "",
                                          TextEditingController(text: "1")
                                        ));
                                      });
                                    },
                                    label: "Weitere Zutat",
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
                            const SizedBox(
                              height: 10,
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
                              try {
                                navigatorKey.currentState!.pop(
                                  CraftingRecipe(
                                    recipeUuid: widget.itemToEdit.recipeUuid,
                                    requiredItemIds: requiredItemIdsSelected
                                        .where((str) => str != null)
                                        .map((str) => str!)
                                        .toList(),
                                    ingredients: selectedIngredient
                                        .map(
                                          (pair) =>
                                              CraftingRecipeIngredientPair(
                                            itemUuid: pair.$1!,
                                            amountOfUsedItem:
                                                int.tryParse(pair.$2.text) ?? 1,
                                          ),
                                        )
                                        .toList(),
                                    createdItem: CraftingRecipeIngredientPair(
                                        itemUuid: selectedCreatingItem.$1!,
                                        amountOfUsedItem: int.tryParse(
                                                selectedCreatingItem.$2.text) ??
                                            1),
                                  ),
                                );
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
          ),
        ),
      ),
    );
  }
}
