import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

final rpgConfigurationProvider = StateNotifierProvider<RpgConfigurationNotifier,
    AsyncValue<RpgConfigurationModel>>((ref) {
  return RpgConfigurationNotifier(
    decks: const AsyncValue.loading(),
    ref: ref,
    runningInTests: false,
  );
});

class RpgConfigurationNotifier
    extends StateNotifier<AsyncValue<RpgConfigurationModel>> {
  final StateNotifierProviderRef<RpgConfigurationNotifier,
      AsyncValue<RpgConfigurationModel>> ref;
  bool runningInTests;
  RpgConfigurationNotifier({
    required AsyncValue<RpgConfigurationModel> decks,
    required this.runningInTests,
    required this.ref,
  }) : super(decks) {
    init();
  }

  AsyncValue<RpgConfigurationModel> getState() {
    return state;
  }

  Future<void> init() async {
    if (runningInTests) return;

    state = const AsyncValue.loading();

    // await Future.delayed(Duration.zero, () async {
    //   var prefs = await SharedPreferences.getInstance();

    //   if (prefs.containsKey(sharedPrefsKeyRpgConfigJson)) {
    //     var loadedJsonForRpgConfig =
    //         prefs.getString(sharedPrefsKeyRpgConfigJson);
    //     var parsedJson =
    //         RpgConfigurationModel.fromJson(jsonDecode(loadedJsonForRpgConfig!));
    //     state = AsyncValue.data(parsedJson);
    //   } else {
    //     state = AsyncValue.data(RpgConfigurationModel.getBaseConfiguration());
    //   }
    // });
  }

  void updateRpgName(String newRpgName) {
    state = AsyncValue.data(state.requireValue.copyWith(rpgName: newRpgName));
  }

  void updateCurrency(CurrencyDefinition newCurrencyMapping) {
    state = AsyncValue.data(
        state.requireValue.copyWith(currencyDefinition: newCurrencyMapping));
  }

  void updateLocations(List<PlaceOfFinding> newLocations) {
    state = AsyncValue.data(
        state.requireValue.copyWith(placesOfFindings: newLocations));
  }

  void updateItemCategories(List<ItemCategory> newItemCategories) {
    state = AsyncValue.data(
        state.requireValue.copyWith(itemCategories: newItemCategories));
  }

  void updateItems(List<RpgItem> items) {
    state = AsyncValue.data(state.requireValue.copyWith(allItems: items));
  }

  void updateRecipes(List<CraftingRecipe> recipes) {
    state =
        AsyncValue.data(state.requireValue.copyWith(craftingRecipes: recipes));
  }

  void updateConfiguration(RpgConfigurationModel config) {
    if (state.hasValue) {
      var jsonEncodingOfNewConfig = jsonEncode(config);
      var jsonEncodingOfState = jsonEncode(state.requireValue);

      if (jsonEncodingOfState == jsonEncodingOfNewConfig) {
        return;
      }
    }

    state = AsyncValue.data(config);
  }

  void updateCharacterScreenStatsTabs(
      List<CharacterStatsTabDefinition> tabsToEdit) {
    state = AsyncValue.data(
        state.requireValue.copyWith(characterStatTabsDefinition: tabsToEdit));
  }
}
