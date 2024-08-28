import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    await Future.delayed(Duration.zero, () async {
      var prefs = await SharedPreferences.getInstance();

      if (prefs.containsKey(sharedPrefsKeyRpgConfigJson)) {
        var loadedJsonForRpgConfig =
            prefs.getString(sharedPrefsKeyRpgConfigJson);
        var parsedJson =
            RpgConfigurationModel.fromJson(jsonDecode(loadedJsonForRpgConfig!));
        state = AsyncValue.data(parsedJson);
      } else {
        state = AsyncValue.data(RpgConfigurationModel.getBaseConfiguration());
      }
    });
  }

  // void addNewDeck(Deck deck) {
  //   state = AsyncValue.data([...state.requireValue, deck]);
  // }
}
