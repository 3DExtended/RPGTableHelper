import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/item_inventory_sort.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

void main() {
  RpgItem item({
    required String uuid,
    required String name,
    required int baseCurrencyPrice,
  }) {
    return RpgItem(
      uuid: uuid,
      name: name,
      description: '',
      categoryId: 'cat',
      imageUrlWithoutBasePath: null,
      imageDescription: null,
      placeOfFindings: [],
      patchSize: null,
      baseCurrencyPrice: baseCurrencyPrice,
    );
  }

  List<InventoryItemEntry> entriesFromNamesAndPrices(
    List<(String name, int price)> specs,
  ) {
    return specs
        .asMap()
        .entries
        .map(
          (e) => MapEntry(
            e.key,
            (
              amount: 1,
              item: item(
                uuid: 'id-${e.key}',
                name: e.value.$1,
                baseCurrencyPrice: e.value.$2,
              ),
            ),
          ),
        )
        .toList();
  }

  group('nextItemInventorySortMode', () {
    test('cycles name -> value ascending -> value descending -> name', () {
      expect(
        nextItemInventorySortMode(ItemInventorySortMode.nameAscending),
        ItemInventorySortMode.valueAscending,
      );
      expect(
        nextItemInventorySortMode(ItemInventorySortMode.valueAscending),
        ItemInventorySortMode.valueDescending,
      );
      expect(
        nextItemInventorySortMode(ItemInventorySortMode.valueDescending),
        ItemInventorySortMode.nameAscending,
      );
    });
  });

  group('sortInventoryItemEntries', () {
    test('sorts by name ascending', () {
      final entries = entriesFromNamesAndPrices([
        ('Zebra', 100),
        ('Apple', 50),
        ('Mango', 200),
      ]);

      final sorted = sortInventoryItemEntries(
        entries,
        ItemInventorySortMode.nameAscending,
      );

      expect(
        sorted.map((e) => e.value.item.name).toList(),
        ['Apple', 'Mango', 'Zebra'],
      );
    });

    test('sorts by base currency price ascending with name tiebreaker', () {
      final entries = entriesFromNamesAndPrices([
        ('Expensive', 500),
        ('Cheap', 10),
        ('Mid', 100),
        ('AlsoMid', 100),
      ]);

      final sorted = sortInventoryItemEntries(
        entries,
        ItemInventorySortMode.valueAscending,
      );

      expect(
        sorted.map((e) => e.value.item.name).toList(),
        ['Cheap', 'AlsoMid', 'Mid', 'Expensive'],
      );
      expect(
        sorted.map((e) => e.value.item.baseCurrencyPrice).toList(),
        [10, 100, 100, 500],
      );
    });

    test('sorts by base currency price descending with name tiebreaker', () {
      final entries = entriesFromNamesAndPrices([
        ('Cheap', 10),
        ('Expensive', 500),
        ('Mid', 100),
        ('AlsoMid', 100),
      ]);

      final sorted = sortInventoryItemEntries(
        entries,
        ItemInventorySortMode.valueDescending,
      );

      expect(
        sorted.map((e) => e.value.item.name).toList(),
        ['Expensive', 'AlsoMid', 'Mid', 'Cheap'],
      );
      expect(
        sorted.map((e) => e.value.item.baseCurrencyPrice).toList(),
        [500, 100, 100, 10],
      );
    });

    test('does not mutate the input list', () {
      final entries = entriesFromNamesAndPrices([
        ('B', 2),
        ('A', 1),
      ]);
      final originalOrder = entries.map((e) => e.value.item.name).toList();

      sortInventoryItemEntries(entries, ItemInventorySortMode.valueAscending);

      expect(entries.map((e) => e.value.item.name).toList(), originalOrder);
    });
  });
}
