import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rpgCharacterConfigurationProvider = StateNotifierProvider<
    RpgCharacterConfigurationNotifier,
    AsyncValue<RpgCharacterConfiguration>>((ref) {
  return RpgCharacterConfigurationNotifier(
    decks: const AsyncValue.loading(),
    ref: ref,
    runningInTests: false,
  );
});

class RpgCharacterConfigurationNotifier
    extends StateNotifier<AsyncValue<RpgCharacterConfiguration>> {
  final StateNotifierProviderRef<RpgCharacterConfigurationNotifier,
      AsyncValue<RpgCharacterConfiguration>> ref;
  bool runningInTests;

  RpgCharacterConfigurationNotifier({
    required AsyncValue<RpgCharacterConfiguration> decks,
    required this.ref,
    required this.runningInTests,
  }) : super(decks) {
    init();
  }

  AsyncValue<RpgCharacterConfiguration> getState() {
    return state;
  }

  Future<void> init() async {
    if (runningInTests) {
      return;
    }

    state = const AsyncValue.loading();

    String? loadedJson;
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(sharedPrefsKeyRpgCharacterConfigJson)) {
      loadedJson = prefs.getString(sharedPrefsKeyRpgCharacterConfigJson);
    }

    if (loadedJson != null) {
      var parsedJson =
          RpgCharacterConfiguration.fromJson(jsonDecode(loadedJson));
      state = AsyncValue.data(parsedJson);
    } else {
      state = AsyncValue.data(RpgCharacterConfiguration.getBaseConfiguration(
        null,
      ));
    }
  }

  void updateConfiguration(RpgCharacterConfiguration config) {
    state = AsyncValue.data(config);
  }

  int getItemCountInCharacterInventory(String itemUuid) {
    if (!state.hasValue) return 0;
    if (state.hasError) return 0;

    var res = state.requireValue.inventory
        .where((i) => i.itemUuid == itemUuid)
        .singleOrNull;

    if (res == null) return 0;

    return res.amount;
  }

  bool tryCraftItem(
      RpgConfigurationModel rpgConfigurationModel, CraftingRecipe r) {
    if (!state.hasValue) return false;
    if (state.hasError) return false;

    // check if requirements are met
    for (var requirement in r.requiredItemIds) {
      var ingredientsInInventory =
          getItemCountInCharacterInventory(requirement);

      if (ingredientsInInventory == 0) {
        return false;
      }
    }

    // check if items for recipe are present
    for (var ingredientPair in r.ingredients) {
      var ingredientsInInventory =
          getItemCountInCharacterInventory(ingredientPair.itemUuid);

      if (ingredientsInInventory < ingredientPair.amountOfUsedItem) {
        return false;
      }
    }

    // create copy of state
    var tempInventoryState = [...state.requireValue.inventory];

    // delete ingredients from state
    for (var ingredientPair in r.ingredients) {
      var indexOfItemInInventory = tempInventoryState
          .indexWhere((e) => e.itemUuid == ingredientPair.itemUuid);

      tempInventoryState[indexOfItemInInventory] =
          tempInventoryState[indexOfItemInInventory].copyWith(
              amount: tempInventoryState[indexOfItemInInventory].amount -
                  ingredientPair.amountOfUsedItem);
    }

    // add crafted item to state
    var isItemInInventory = tempInventoryState
        .where((e) => e.itemUuid == r.createdItem.itemUuid)
        .singleOrNull;

    // check if itemId is in inventory
    if (isItemInInventory == null) {
      tempInventoryState.add(RpgCharacterOwnedItemPair(
          itemUuid: r.createdItem.itemUuid,
          amount: r.createdItem.amountOfUsedItem));
    } else {
      var indexOfItemInInventory = tempInventoryState
          .indexWhere((e) => e.itemUuid == r.createdItem.itemUuid);
      tempInventoryState[indexOfItemInInventory] =
          tempInventoryState[indexOfItemInInventory].copyWith(
              amount: tempInventoryState[indexOfItemInInventory].amount +
                  r.createdItem.amountOfUsedItem);
    }

    state = AsyncValue.data(
        state.requireValue.copyWith(inventory: tempInventoryState));
    return true;
  }
}
