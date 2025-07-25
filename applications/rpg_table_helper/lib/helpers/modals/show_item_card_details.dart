// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_int_edit_field.dart';
import 'package:quest_keeper/components/custom_item_card.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/components/static_grid.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/color_extension.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// returns number to adjust the rpg character inventory
Future<int?> showItemCardDetails(BuildContext context,
    {required RpgItem item,
    required RpgConfigurationModel rpgConfig,
    required int? currentlyOwned, // null if not relevant.
    GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  return await customShowCupertinoModalBottomSheet<int>(
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

        return ItemCardDetailsModalContent(
          modalPadding: modalPadding,
          item: item,
          rpgConfig: rpgConfig,
          currentlyOwned: currentlyOwned,
        );
      });
}

class ItemCardDetailsModalContent extends StatefulWidget {
  const ItemCardDetailsModalContent({
    super.key,
    required this.modalPadding,
    required this.item,
    required this.currentlyOwned,
    required this.rpgConfig,
  });
  final int? currentlyOwned;
  final RpgItem item;
  final double modalPadding;
  final RpgConfigurationModel rpgConfig;

  @override
  State<ItemCardDetailsModalContent> createState() =>
      _ItemCardDetailsModalContentState();
}

class _ItemCardDetailsModalContentState
    extends State<ItemCardDetailsModalContent> {
  int currentlyOwned = 0;

  @override
  void initState() {
    currentlyOwned = widget.currentlyOwned ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var flattenedCategories = ItemCategory.flattenCategoriesRecursive(
        categories: widget.rpgConfig.itemCategories);

    var categoryForItem = flattenedCategories
        .firstWhereOrNull((e) => e.uuid == widget.item.categoryId);

    var parentCategoryOfItem = categoryForItem != null
        ? flattenedCategories.firstWhereOrNull((fc) => fc.subCategories
                .any((sub) => sub.uuid == categoryForItem.uuid)) ??
            categoryForItem
        : categoryForItem;

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
                color: CustomThemeProvider.of(context).theme.bgColor,
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
                        "${S.of(context).itemDetailsForPrefix} ${widget.item.name}",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: CustomThemeProvider.of(context)
                                        .brightnessNotifier
                                        .value ==
                                    Brightness.light
                                ? CustomThemeProvider.of(context)
                                    .theme
                                    .textColor
                                : CustomThemeProvider.of(context)
                                    .theme
                                    .darkTextColor,
                            fontSize: 24),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Column(
                                children: [
                                  CustomItemCard(
                                    scalarOverride: 1,
                                    imageUrl:
                                        widget.item.imageUrlWithoutBasePath,
                                    title: widget.item.name,
                                    description: widget.item.description,
                                    categoryIconColor: parentCategoryOfItem
                                        ?.colorCode
                                        ?.parseHexColorRepresentation(),
                                    categoryIconName:
                                        parentCategoryOfItem?.iconName,
                                  ),
                                ],
                              )),
                              Expanded(
                                child: StaticGrid(
                                  rowGap: 20,
                                  colGap: 10,
                                  expandedFlexValues: [1, 2],
                                  columnMainAxisAlignment:
                                      MainAxisAlignment.start,
                                  rowCrossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      S
                                          .of(context)
                                          .itemDetailsDescriptionHeader,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color:
                                                CustomThemeProvider.of(context)
                                                    .theme
                                                    .darkTextColor,
                                            fontSize: 16,
                                          ),
                                    ),
                                    Text(
                                      widget.item.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color:
                                                CustomThemeProvider.of(context)
                                                    .theme
                                                    .darkTextColor,
                                            fontSize: 16,
                                          ),
                                    ),
                                    Text(
                                      S.of(context).itemDetailsPriceHeader,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color:
                                                CustomThemeProvider.of(context)
                                                    .theme
                                                    .darkTextColor,
                                            fontSize: 16,
                                          ),
                                    ),
                                    Text(
                                      buildTextForCurrencyComparison(
                                          widget.rpgConfig,
                                          widget.item.baseCurrencyPrice),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color:
                                                CustomThemeProvider.of(context)
                                                    .theme
                                                    .darkTextColor,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomIntEditField(
                      minValue: -999,
                      maxValue: 999,
                      onValueChange: (newValue) {
                        setState(() {
                          currentlyOwned = newValue;
                        });
                      },
                      label: S.of(context).amount,
                      startValue: currentlyOwned,
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
                            label: S.of(context).cancel,
                            onPressed: () {
                              navigatorKey.currentState!.pop(null);
                            },
                          ),
                          const Spacer(),
                          CustomButton(
                            label: S.of(context).save,
                            onPressed: () {
                              navigatorKey.currentState!.pop(currentlyOwned -
                                  (widget.currentlyOwned ?? 0));
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
