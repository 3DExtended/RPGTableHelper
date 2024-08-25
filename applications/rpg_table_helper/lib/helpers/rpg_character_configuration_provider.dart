import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rpgCharacterConfigurationProvider = StateNotifierProvider<
    RpgCharacterConfigurationNotifier,
    AsyncValue<RpgCharacterConfiguration>>((ref) {
  return RpgCharacterConfigurationNotifier(
    decks: const AsyncValue.loading(),
    ref: ref,
  );
});

class RpgCharacterConfigurationNotifier
    extends StateNotifier<AsyncValue<RpgCharacterConfiguration>> {
  final StateNotifierProviderRef<RpgCharacterConfigurationNotifier,
      AsyncValue<RpgCharacterConfiguration>> ref;
  RpgCharacterConfigurationNotifier({
    required AsyncValue<RpgCharacterConfiguration> decks,
    required this.ref,
  }) : super(decks) {
    init();
  }

  AsyncValue<RpgCharacterConfiguration> getState() {
    return state;
  }

  Future<void> init() async {
    state = const AsyncValue.loading();

    var prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(sharedPrefsKeyRpgCharacterConfigJson)) {
      var loadedJsonForRpgConfig =
          prefs.getString(sharedPrefsKeyRpgCharacterConfigJson);
      var parsedJson = RpgCharacterConfiguration.fromJson(
          jsonDecode(loadedJsonForRpgConfig!));
      state = AsyncValue.data(parsedJson);
    } else {
      state = AsyncValue.data(RpgCharacterConfiguration.getBaseConfiguration(
        null,
      ));
    }
  }

  // void addNewDeck(Deck deck) {
  //   state = AsyncValue.data([...state.requireValue, deck]);
  // }
}
