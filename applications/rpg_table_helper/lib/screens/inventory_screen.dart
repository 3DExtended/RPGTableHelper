import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/categorized_item_layout.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/item_visualization.dart';
import 'package:rpg_table_helper/components/static_grid.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

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
    var characterConfig =
        ref.watch(rpgCharacterConfigurationProvider).valueOrNull;
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;
    var categories = getAllCategoriesWithItemsWithin(rpgConfig);

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
                  .where((sc) => getSubcategoryHasItems(rpgConfig, sc))
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

    var contentChildren = [
      Row(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 9.0),
            child: Text(
              "Inventar",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: Colors.white, fontSize: 32),
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
                  onPressed: () {
                    // TODO add modal to add new item
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: StaticGrid(
              colGap: 20,
              rowGap: 20,
              columnCount: isLandscape ? 3 : 2,
              children: [
                ...itemsForSelectedCategory
                    .map((it) => (
                          it,
                          getItemCountInCharacterInventory(
                              characterConfig, it.uuid)
                        ))
                    .sortBy((t) => t.$1.name.toLowerCase())
                    // TODO this creates an issue with sorting i dont understand...
                    // .sortByDescending<int>((t) => t.$2)
                    .map(
                      (item) => ItemVisualization(
                          itemToRender: item.$1,
                          renderRecipeRelatedThings: false,
                          itemNameSuffix: null,
                          numberOfItemsInInventory: item.$2,
                          numberOfCreateableInstances: null,
                          craftItem: () {
                            // ref
                            //     .read(rpgCharacterConfigurationProvider
                            //         .notifier)
                            //     .tryCraftItem(rpgConfig, rece.$1);
                          }),
                    ),
              ],
            ),
          ),
        ),
      )
    ];

    return CategorizedItemLayout(
        categoryColumns: categoryColumns, contentChildren: contentChildren);
  }

  RpgItem getItemForId(RpgConfigurationModel rpgConfig, String id) {
    return rpgConfig.allItems.singleWhere((it) => it.uuid == id);
  }

  List<ItemCategory> getAllCategoriesWithItemsWithin(
      RpgConfigurationModel? rpgConfig) {
    if (rpgConfig == null) return [];

    var allItemCategories = [...rpgConfig.itemCategories];

    List<ItemCategory> result = [];

    for (var cat in allItemCategories) {
      if (rpgConfig.allItems.any((it) => it.categoryId == cat.uuid)) {
        result.add(cat);
      } else if (rpgConfig.allItems.any((it) => cat.subCategories
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

  bool getSubcategoryHasItems(
      RpgConfigurationModel? rpgConfig, ItemCategory sc) {
    if (rpgConfig == null) return false;

    return rpgConfig.allItems.any((cr) => cr.categoryId == sc.uuid);
  }
}
