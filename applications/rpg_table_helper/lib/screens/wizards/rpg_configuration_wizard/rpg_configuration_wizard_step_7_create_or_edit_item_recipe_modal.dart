import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_dropdown_menu_with_search.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/custom_iterator_extensions.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

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
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
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
          _allItems = data.allItems;
        });
      }
    });

    var modalPadding = 80.0;
    if (MediaQuery.of(context).size.width < 800) {
      modalPadding = 20.0;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: true,
        bottom: true,
        right: false,
        left: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: 20, top: 20, left: modalPadding, right: modalPadding),
            child: Center(
              child: CustomShadowWidget(
                child: Container(
                  color: bgColor,
                  child: Column(
                    children: [
                      Navbar(
                        backInsteadOfCloseIcon: false,
                        closeFunction: () {
                          navigatorKey.currentState!.pop(null);
                        },
                        menuOpen: null,
                        useTopSafePadding: false,
                        titleWidget: Text(
                          "Rezept bearbeiten", // TODO localize/ switch text between add and edit
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: textColor, fontSize: 24),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      // TODO make into new design
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
                                Text(
                                  "Voraussetzungen:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color: darkColor,
                                        fontSize: 16,
                                      ),
                                ),
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
                                              child:
                                                  // TODO make into new design

                                                  CustomDropdownMenuWithSearch(
                                                      selectedValueTemp:
                                                          tuple.value == ""
                                                              ? null
                                                              : tuple.value,
                                                      setter: (newValue) {
                                                        setState(() {
                                                          requiredItemIdsSelected[
                                                                  tuple.key] =
                                                              newValue;
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
                                              width: 60,
                                              clipBehavior: Clip.none,
                                              child: CustomButton(
                                                variant: CustomButtonVariant
                                                    .FlatButton,
                                                onPressed: () {
                                                  // remove this pair from list
                                                  setState(() {
                                                    requiredItemIdsSelected
                                                        .removeAt(tuple.key);
                                                  });
                                                },
                                                icon: const CustomFaIcon(
                                                    size: 24,
                                                    color: darkColor,
                                                    icon: FontAwesomeIcons
                                                        .trashCan),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 0, 0),
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
                                              fontFamily: "Ruwudu",
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
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 0, 5, 0),
                                              child: const CustomFaIcon(
                                                  color: darkColor,
                                                  size: 16,
                                                  icon: FontAwesomeIcons.plus),
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
                                Text(
                                  "Zutaten:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color: darkColor,
                                        fontSize: 16,
                                      ),
                                ),
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
                                              child:
                                                  // TODO update with new design
                                                  CustomDropdownMenuWithSearch(
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
                                                keyboardType:
                                                    TextInputType.number,
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
                                              width: 60,
                                              clipBehavior: Clip.none,
                                              child: CustomButton(
                                                variant: CustomButtonVariant
                                                    .FlatButton,
                                                onPressed: () {
                                                  // remove this pair from list
                                                  setState(() {
                                                    selectedIngredient
                                                        .removeAt(tuple.key);
                                                  });
                                                },
                                                icon: const CustomFaIcon(
                                                    size: 24,
                                                    color: darkColor,
                                                    icon: FontAwesomeIcons
                                                        .trashCan),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 0, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      CustomButton(
                                        variant: CustomButtonVariant.Default,
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
                                        icon: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 5, 0),
                                          child: Container(
                                              width: 16,
                                              height: 16,
                                              alignment:
                                                  AlignmentDirectional.center,
                                              child: const CustomFaIcon(
                                                  color: darkColor,
                                                  size: 16,
                                                  icon: FontAwesomeIcons.plus)),
                                        ),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                        child: Row(
                          children: [
                            CustomButton(
                              label: S.of(context).cancel,
                              onPressed: () {
                                navigatorKey.currentState!.pop(null);
                              },
                            ),
                            const Spacer(),
                            CustomButton(
                              label: S.of(context).save,
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
                                                  int.tryParse(pair.$2.text) ??
                                                      1,
                                            ),
                                          )
                                          .toList(),
                                      createdItem: CraftingRecipeIngredientPair(
                                          itemUuid: selectedCreatingItem.$1!,
                                          amountOfUsedItem: int.tryParse(
                                                  selectedCreatingItem
                                                      .$2.text) ??
                                              1),
                                    ),
                                  );
                                } catch (e) {
                                  log(e.toString());
                                }
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
      ),
    );
  }
}
