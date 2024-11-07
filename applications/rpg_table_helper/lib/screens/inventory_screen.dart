import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/categorized_item_layout.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_grid_list_view.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/item_visualization.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/custom_iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/add_new_item_modal.dart';
import 'package:rpg_table_helper/screens/change_money_modal.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  static String route = "inventory";

  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String? selectedCategory;
  String? selectedParentCategory;

  @override
  Widget build(BuildContext context) {
    var connectionDetails = ref.watch(connectionDetailsProvider).valueOrNull;

    return contentForPlayer(context);
  }

  Widget contentForPlayer(BuildContext context) {
    var characterConfig =
        ref.watch(rpgCharacterConfigurationProvider).valueOrNull;
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;
    var categories =
        getAllCategoriesWithItemsWithin(rpgConfig, characterConfig);

    if (selectedCategory == null && categories.isNotEmpty) {
      selectedParentCategory = categories.first.uuid;
      if (categories.first.subCategories.isEmpty) {
        selectedCategory = categories.first.uuid;
      } else {
        selectedCategory = categories.first.subCategories.first.uuid;
      }
    }

    var itemsForSelectedCategory = getItemsForSelectedCategory(
        rpgConfig, selectedParentCategory, selectedCategory);

    var isLandscape =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    var categoryColumns = [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: CustomMarkdownBody(
            text:
                "# ${characterConfig?.characterName == null || characterConfig!.characterName.isEmpty ? "Player Name" : characterConfig.characterName}"),
      ),
      const HorizontalLine(),
      ...categories.map(
        (category) => Column(
          children: [
            CupertinoButton(
              onPressed: () {
                setState(() {
                  selectedCategory = category.uuid;
                  selectedParentCategory = category.uuid;
                });
              },
              minSize: 0,
              padding: const EdgeInsets.all(0),
              child: Container(
                color: category.uuid == selectedParentCategory
                    ? whiteBgTint
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      // show chevron if subcategories
                      if (category.subCategories.isNotEmpty)
                        CustomFaIcon(
                          size: 20,
                          icon: selectedParentCategory == category.uuid
                              ? FontAwesomeIcons.chevronUp
                              : FontAwesomeIcons.chevronDown,
                        )
                    ],
                  ),
                ),
              ),
            ),
            if (category.subCategories.isNotEmpty &&
                category.uuid == selectedParentCategory)
              ...category.subCategories
                  .where((sc) =>
                      getSubcategoryHasItems(rpgConfig, characterConfig, sc))
                  .map((subCategory) => CupertinoButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = subCategory.uuid;
                            selectedParentCategory = category.uuid;
                          });
                        },
                        minSize: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 30),
                              child: Row(
                                children: [
                                  StyledBox(
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      color:
                                          selectedCategory == subCategory.uuid
                                              ? Colors.white
                                              : Colors.transparent,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    subCategory.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                            color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
          ],
        ),
      ),
    ];

    var normalizedScreenWidth = MediaQuery.of(context).devicePixelRatio *
        MediaQuery.of(context).size.width;

    if (isLandscape) {
      normalizedScreenWidth = MediaQuery.of(context).devicePixelRatio *
          MediaQuery.of(context).size.height;
    }
    var numberOfColumnsInMainContent = 1;
    if (normalizedScreenWidth > 1300) {
      numberOfColumnsInMainContent = 2;
    }
    if (normalizedScreenWidth > 1600) {
      numberOfColumnsInMainContent = 3;
    }

    var contentChildren = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 3.0),
            child: Column(
              children: [
                Text(
                  "Inventar",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Colors.white, fontSize: 32),
                ),
                CupertinoButton(
                  onPressed: () async {
                    // open edit money modal
                    await showChangeMoneyModal(context).then((value) {
                      if (value == null) return;

                      ref
                          .read(rpgCharacterConfigurationProvider.notifier)
                          .updateConfiguration(ref
                              .read(rpgCharacterConfigurationProvider)
                              .requireValue
                              .copyWith(moneyInBaseType: value));
                    });
                  },
                  minSize: 0,
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    rpgConfig == null || characterConfig == null
                        ? "0 Gold"
                        : buildTextForCurrencyComparison(
                            rpgConfig, characterConfig),
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: CustomButton(
                  isSubbutton: true,
                  onPressed: () async {
                    await showAddNewItemModal(
                      context,
                      itemCategoryFilter: selectedCategory,
                    ).then(
                      (value) {
                        if (value == null) return;

                        ref
                            .read(rpgCharacterConfigurationProvider.notifier)
                            .grantItem(itemId: value.$1, amount: value.$2);
                      },
                    );
                  },
                  icon: const CustomFaIcon(icon: FontAwesomeIcons.plus),
                ),
              ),
            ],
          ))
        ],
      ),
      const HorizontalLine(),
      Expanded(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Builder(builder: (context) {
              var itemsToRender = itemsForSelectedCategory
                  .map((it) => (
                        it,
                        getItemCountInCharacterInventory(
                            characterConfig, it.uuid)
                      ))
                  .where((it) => it.$2 > 0)
                  .sortBy((t) => t.$1.name.toLowerCase())
                  .toList();
              return CustomGridListView(
                numberOfColumns: numberOfColumnsInMainContent,
                horizontalSpacing: 20,
                verticalSpacing: 20,
                itemCount: itemsToRender.length,
                itemBuilder: (context, index) {
                  var item = itemsToRender[index];

                  return ItemVisualization(
                      itemToRender: item.$1,
                      renderRecipeRelatedThings: false,
                      itemNameSuffix: null,
                      numberOfItemsInInventory: item.$2,
                      numberOfCreateableInstances: null,
                      useItem: () {
                        ref
                            .read(rpgCharacterConfigurationProvider.notifier)
                            .useItem(item.$1.uuid);
                      },
                      craftItem: () {
                        // ref
                        //     .read(rpgCharacterConfigurationProvider
                        //         .notifier)
                        //     .tryCraftItem(rpgConfig, rece.$1);
                      });
                },
              );
            })),
      )
    ];

    return CategorizedItemLayout(
        categoryColumns: categoryColumns, contentChildren: contentChildren);
  }

  String buildTextForCurrencyComparison(RpgConfigurationModel rpgConfig,
      RpgCharacterConfiguration characterConfig) {
    var currentPlayerMoney = characterConfig.moneyInBaseType ?? 0;

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

  RpgItem getItemForId(RpgConfigurationModel rpgConfig, String id) {
    return rpgConfig.allItems.singleWhere((it) => it.uuid == id);
  }

  List<ItemCategory> getAllCategoriesWithItemsWithin(
      RpgConfigurationModel? rpgConfig,
      RpgCharacterConfiguration? characterConfig) {
    if (rpgConfig == null) return [];
    if (characterConfig == null) return [];

    var allItemCategories = [...rpgConfig.itemCategories];

    List<ItemCategory> result = [];

    var allItemsForGivenPlayerConfig = characterConfig.inventory
        .map((it) => it.itemUuid)
        .map((it) =>
            rpgConfig.allItems.where((ait) => ait.uuid == it).singleOrNull)
        .where((it) => it != null)
        .map((it) => it!)
        .toList();

    for (var cat in allItemCategories) {
      if (allItemsForGivenPlayerConfig.any((it) => it.categoryId == cat.uuid)) {
        result.add(cat);
      } else if (allItemsForGivenPlayerConfig.any((it) => cat.subCategories
          .map((sc) => sc.uuid)
          .any((sc) => sc == it.categoryId))) {
        result.add(cat);
      }
    }

    return result;
  }

  List<RpgItem> getItemsForSelectedCategory(RpgConfigurationModel? rpgConfig,
      String? selectedParentCategory, String? selectedCategory) {
    if (rpgConfig == null) return [];

    var filteredItems = rpgConfig.allItems
        .where((i) =>
            i.categoryId == selectedCategory ||
            getParentCategoryOfCategory(rpgConfig, i.categoryId) ==
                selectedCategory)
        .toList();
    return filteredItems;
  }

  String? getParentCategoryOfCategory(
      RpgConfigurationModel? rpgConfig, String? categoryId) {
    if (rpgConfig == null) return null;
    if (categoryId == null) return null;

    var parentCategory = rpgConfig.itemCategories.singleWhere((c) =>
        c.uuid == categoryId ||
        c.subCategories.any((sc) => sc.uuid == categoryId));

    return parentCategory.uuid;
  }

  int getItemCountInCharacterInventory(
      RpgCharacterConfiguration? characterConfig, String itemUuid) {
    if (characterConfig == null) return 0;

    var res = characterConfig.inventory
        .where((i) => i.itemUuid == itemUuid)
        .singleOrNull;

    if (res == null) return 0;

    return res.amount;
  }

  bool getSubcategoryHasItems(RpgConfigurationModel? rpgConfig,
      RpgCharacterConfiguration? characterConfig, ItemCategory sc) {
    if (rpgConfig == null) return false;
    if (characterConfig == null) return false;

    var allItemsForGivenPlayerConfig = characterConfig.inventory
        .map((it) => it.itemUuid)
        .map((it) =>
            rpgConfig.allItems.where((ait) => ait.uuid == it).singleOrNull)
        .where((it) => it != null)
        .map((it) => it!)
        .toList();

    return allItemsForGivenPlayerConfig.any((cr) => cr.categoryId == sc.uuid);
  }
}
