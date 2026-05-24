import 'package:quest_keeper/models/rpg_configuration_model.dart';

enum ItemInventorySortMode {
  nameAscending,
  valueAscending,
  valueDescending,
}

typedef InventoryItemEntry = MapEntry<int, ({int amount, RpgItem item})>;

ItemInventorySortMode nextItemInventorySortMode(ItemInventorySortMode current) {
  switch (current) {
    case ItemInventorySortMode.nameAscending:
      return ItemInventorySortMode.valueAscending;
    case ItemInventorySortMode.valueAscending:
      return ItemInventorySortMode.valueDescending;
    case ItemInventorySortMode.valueDescending:
      return ItemInventorySortMode.nameAscending;
  }
}

List<InventoryItemEntry> sortInventoryItemEntries(
  List<InventoryItemEntry> entries,
  ItemInventorySortMode mode,
) {
  final sorted = List<InventoryItemEntry>.from(entries);
  switch (mode) {
    case ItemInventorySortMode.nameAscending:
      sorted.sort(
        (a, b) => a.value.item.name.compareTo(b.value.item.name),
      );
    case ItemInventorySortMode.valueAscending:
      sorted.sort((a, b) {
        final priceCompare = a.value.item.baseCurrencyPrice
            .compareTo(b.value.item.baseCurrencyPrice);
        if (priceCompare != 0) {
          return priceCompare;
        }
        return a.value.item.name.compareTo(b.value.item.name);
      });
    case ItemInventorySortMode.valueDescending:
      sorted.sort((a, b) {
        final priceCompare = b.value.item.baseCurrencyPrice
            .compareTo(a.value.item.baseCurrencyPrice);
        if (priceCompare != 0) {
          return priceCompare;
        }
        return a.value.item.name.compareTo(b.value.item.name);
      });
  }
  return sorted;
}
