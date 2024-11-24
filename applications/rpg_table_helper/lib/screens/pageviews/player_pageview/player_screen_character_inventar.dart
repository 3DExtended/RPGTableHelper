import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/item_card_rendering_with_filtering.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/modals/show_item_card_details.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/add_new_item_modal.dart';

class PlayerScreenCharacterInventory extends ConsumerStatefulWidget {
  const PlayerScreenCharacterInventory({
    super.key,
    required this.rpgConfig,
    required this.charToRender,
  });

  final RpgConfigurationModel rpgConfig;
  final RpgCharacterConfigurationBase? charToRender;

  @override
  ConsumerState<PlayerScreenCharacterInventory> createState() =>
      _PlayerScreenCharacterInventoryState();
}

class _PlayerScreenCharacterInventoryState
    extends ConsumerState<PlayerScreenCharacterInventory> {
  String? selectedItemCategoryId;

  List<RpgItem> _items = [];
  List<ItemCategory> _allItemCategories = [];

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      setState(() {
        _items = data.allItems;
        _allItemCategories = data.itemCategories;
      });
    });

    var isCharToRenderEqualToRpgCharacterConfig = widget.charToRender != null &&
        ref.read(rpgCharacterConfigurationProvider).hasValue &&
        ref.read(rpgCharacterConfigurationProvider).requireValue.uuid ==
            widget.charToRender!.uuid;

    var incentoryToUse = isCharToRenderEqualToRpgCharacterConfig
        ? ref.watch(rpgCharacterConfigurationProvider).requireValue.inventory
        : (widget.charToRender is RpgCharacterConfiguration &&
                (widget.charToRender as RpgCharacterConfiguration)
                    .inventory
                    .isNotEmpty
            ? (widget.charToRender as RpgCharacterConfiguration).inventory
            : List<RpgCharacterOwnedItemPair>.empty());

    List<({int amount, RpgItem item})> currentItems = incentoryToUse
        .map((inventoryPair) => (
              item:
                  _items.firstWhere((it) => it.uuid == inventoryPair.itemUuid),
              amount: inventoryPair.amount
            ))
        .toList();

    return Container(
      padding: EdgeInsets.all(0),
      clipBehavior: Clip.none,
      color: bgColor,
      child: ItemCardRenderingWithFiltering(
        isSearchFieldShowingOnStart: false,
        allItemCategories: _allItemCategories,
        hideAmount: false,
        items: currentItems,
        onEditItemAmount: null,
        onAddNewItemPressed: () async {
          await showAddNewItemModal(
            itemCategoryFilter: selectedItemCategoryId,
            context,
          ).then(
            (value) {
              if (value == null) return;

              ref.read(rpgCharacterConfigurationProvider.notifier).grantItems(
                  value
                      .map((i) => RpgCharacterOwnedItemPair(
                          itemUuid: i.$1, amount: i.$2))
                      .toList());
            },
          );
        },
        onSelectNewFilterCategory: (ItemCategory e) {
          setState(() {
            selectedItemCategoryId = e.uuid == "" ? null : e.uuid;
          });
        },
        renderCreateButton: true,
        selectedItemCategoryId: selectedItemCategoryId,
        onItemCardPressed:
            (MapEntry<int, ({int amount, RpgItem item})> details) async {
          await showItemCardDetails(
            context,
            item: details.value.item,
            currentlyOwned: details.value.amount,
            rpgConfig: widget.rpgConfig,
          ).then((valueToAdjustAmountBy) {
            if (valueToAdjustAmountBy == null || valueToAdjustAmountBy == 0) {
              return;
            }

            ref.read(rpgCharacterConfigurationProvider.notifier).grantItem(
                itemId: details.value.item.uuid, amount: valueToAdjustAmountBy);
            setState(() {});
          });
        },
      ),
    );
  }
}
