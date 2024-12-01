// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_int_edit_field.dart';
import 'package:rpg_table_helper/components/custom_recipe_card.dart';
import 'package:rpg_table_helper/components/custom_shadow_widget.dart';
import 'package:rpg_table_helper/components/navbar_new_design.dart';
import 'package:rpg_table_helper/components/static_grid.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/pageviews/player_pageview/player_screen_recepies.dart';

Future<
        ({
          List<CraftingRecipeIngredientPair> removedItems,
          List<CraftingRecipeIngredientPair> addedItems
        })?>
    showRecipeCardDetails(BuildContext context,
        {required CraftingRecipeWithRpgItemDetails recipe,
        required RpgConfigurationModel rpgConfig,
        required RpgCharacterConfiguration currentInventory,
        GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  return await customShowCupertinoModalBottomSheet<
          ({
            List<CraftingRecipeIngredientPair> removedItems,
            List<CraftingRecipeIngredientPair> addedItems
          })>(
      isDismissible: true,
      expand: true,
      closeProgressThreshold: -50000,
      enableDrag: false,
      context: context,
      backgroundColor: const Color.fromARGB(192, 21, 21, 21),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        return RecipeCardDetailsModalContent(
          modalPadding: modalPadding,
          recipe: recipe,
          rpgConfig: rpgConfig,
          currentInventory: currentInventory,
        );
      });
}

class RecipeCardDetailsModalContent extends StatefulWidget {
  const RecipeCardDetailsModalContent({
    super.key,
    required this.modalPadding,
    required this.recipe,
    required this.rpgConfig,
    required this.currentInventory,
  });
  final CraftingRecipeWithRpgItemDetails recipe;
  final double modalPadding;
  final RpgConfigurationModel rpgConfig;
  final RpgCharacterConfiguration currentInventory;

  @override
  State<RecipeCardDetailsModalContent> createState() =>
      _RecipeCardDetailsModalContentState();
}

class _RecipeCardDetailsModalContentState
    extends State<RecipeCardDetailsModalContent> {
  int currentlyCrafted = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var creatableItem = widget.recipe.createdItem.item;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
            bottom: 20,
            top: 20,
            left: widget.modalPadding,
            right: widget.modalPadding),
        child: Center(
          child: CustomShadowWidget(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1000, maxHeight: 700),
              child: Container(
                color: bgColor,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Navbar(
                      backInsteadOfCloseIcon: false,
                      closeFunction: () {
                        navigatorKey.currentState!.pop(null);
                      },
                      menuOpen: null,
                      useTopSafePadding: false,
                      titleWidget: Text(
                        "Rezept für ${creatableItem.name}", // TODO localize/ switch text between add and edit
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: textColor, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                            child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomRecipeCard(
                                  imageUrl: widget.recipe.createdItem.item
                                      .imageUrlWithoutBasePath,
                                  title: widget.recipe.createdItem.item.name,
                                  requirements: widget.recipe.requiredItems
                                      .map((req) => CustomRecipeCardItemPair(
                                            amount: 1,
                                            itemName: req.name,
                                          ))
                                      .toList(),
                                  ingedients: widget.recipe.ingredients
                                      .map((ing) => CustomRecipeCardItemPair(
                                            amount: ing.amountOfUsedItem,
                                            itemName: ing.item.name,
                                          ))
                                      .toList(),
                                ),
                              ],
                            )),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 2,
                              child: StaticGrid(
                                rowGap: 20,
                                colGap: 10,
                                columnCount: 2,
                                expandedFlexValues: [1 * 3, 2 * 3],
                                columnMainAxisAlignment:
                                    MainAxisAlignment.start,
                                rowCrossAxisAlignment: CrossAxisAlignment.start,
                                columnCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                rowMainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Beschreibung:",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: darkTextColor,
                                          fontSize: 16,
                                        ),
                                  ),
                                  Text(
                                    widget.recipe.createdItem.item.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: darkTextColor,
                                          fontSize: 16,
                                        ),
                                  ),
                                  Text(
                                    "Voraussetzungen:",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: darkTextColor,
                                          fontSize: 16,
                                        ),
                                  ),
                                  Row(
                                    children: [
                                      areRecipeRequirementsMet()
                                          ? CustomFaIcon(
                                              icon: FontAwesomeIcons.check,
                                              color: darkGreen,
                                              size: 18,
                                            )
                                          : CustomFaIcon(
                                              icon: FontAwesomeIcons.xmark,
                                              color: darkRed,
                                              size: 18,
                                            ),
                                      Text(
                                        widget.recipe.requiredItems
                                            .map((i) => "${i.name} (1x)")
                                            .join(", "),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: darkTextColor,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Zutaten:",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: darkTextColor,
                                          fontSize: 16,
                                        ),
                                  ),
                                  Container(),
                                  ...widget.recipe.ingredients
                                      .map((i) => [
                                            // Ingredient present checkmark + name
                                            Row(
                                              children: [
                                                doesInventoryHaveEnoughItemsOfIngredient(
                                                        i)
                                                    ? CustomFaIcon(
                                                        icon: FontAwesomeIcons
                                                            .check,
                                                        color: darkGreen,
                                                        size: 18,
                                                      )
                                                    : CustomFaIcon(
                                                        icon: FontAwesomeIcons
                                                            .xmark,
                                                        color: darkRed,
                                                        size: 18,
                                                      ),
                                                Expanded(
                                                  child: Text(
                                                    i.item.name,
                                                    maxLines: 2,
                                                    softWrap: true,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                          color: darkTextColor,
                                                          fontSize: 16,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Number of required items for current multiplier
                                            Text(
                                              "Benötigt: ${i.amountOfUsedItem * currentlyCrafted}, in Besitz: ${getNumberOfItemInInventory(i.item.uuid)}",
                                              maxLines: 2,
                                              softWrap: true,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: darkTextColor,
                                                    fontSize: 16,
                                                  ),
                                            ),
                                          ])
                                      .expand((i) => i)
                                ],
                              ),
                            ),
                          ],
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomIntEditField(
                      minValue: 1,
                      maxValue: 99,
                      onValueChange: (newValue) {
                        setState(() {
                          currentlyCrafted = newValue;
                        });
                      },
                      label: "Anzahl",
                      startValue: currentlyCrafted,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                      child: Row(
                        children: [
                          const Spacer(),
                          CustomButton(
                            label: "Abbrechen", // TODO localize
                            onPressed: () {
                              navigatorKey.currentState!.pop(null);
                            },
                          ),
                          const Spacer(),
                          CustomButton(
                            variant: CustomButtonVariant.AccentButton,
                            label: "Herstellen", // TODO localize
                            onPressed: isCraftButtonDisabled()
                                ? null
                                : () {
                                    List<CraftingRecipeIngredientPair>
                                        removedItems = [];

                                    removedItems = widget.recipe.ingredients
                                        .map((ing) =>
                                            CraftingRecipeIngredientPair(
                                                itemUuid: ing.item.uuid,
                                                amountOfUsedItem:
                                                    ing.amountOfUsedItem *
                                                        currentlyCrafted))
                                        .toList();

                                    List<CraftingRecipeIngredientPair>
                                        addedItems = [];

                                    addedItems.add(CraftingRecipeIngredientPair(
                                        itemUuid:
                                            widget.recipe.createdItem.item.uuid,
                                        amountOfUsedItem: widget.recipe
                                                .createdItem.amountOfUsedItem *
                                            currentlyCrafted));

                                    var result = (
                                      removedItems: removedItems,
                                      addedItems: addedItems,
                                    );

                                    navigatorKey.currentState!.pop(result);
                                  },
                          ),
                          const Spacer(),
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

  bool areRecipeRequirementsMet() {
    for (var req in widget.recipe.requiredItems) {
      if (!widget.currentInventory.inventory
          .any((e) => e.itemUuid == req.uuid && e.amount > 0)) {
        return false;
      }
    }

    return true;
  }

  bool doesInventoryHaveEnoughItemsOfIngredient(
      CraftingRecipeIngredientPairWithRpgItemDetails i) {
    var requiredNumberOfItems = currentlyCrafted * i.amountOfUsedItem;

    return (widget.currentInventory.inventory.any(
        (e) => e.itemUuid == i.item.uuid && e.amount >= requiredNumberOfItems));
  }

  int getNumberOfItemInInventory(String uuid) {
    var result = (widget.currentInventory.inventory
        .firstWhereOrNull((e) => e.itemUuid == uuid));

    return result?.amount ?? 0;
  }

  bool isCraftButtonDisabled() {
    if (!areRecipeRequirementsMet()) return true;
    if (widget.recipe.ingredients
        .any((i) => !doesInventoryHaveEnoughItemsOfIngredient(i))) return true;

    return false;
  }
}

String buildTextForCurrencyComparison(
    RpgConfigurationModel rpgConfig, int basePriceOfItem) {
  var valueSplitInCurrency = CurrencyDefinition.valueOfItemForDefinition(
      rpgConfig.currencyDefinition, basePriceOfItem);

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
