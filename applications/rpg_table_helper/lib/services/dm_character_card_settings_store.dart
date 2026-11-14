import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quest_keeper/models/dm_character_card_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the DM's card choices ([DmCharacterCardSettings]) on this device,
/// one entry per campaign.
abstract class IDmCharacterCardSettingsStore {
  Future<DmCharacterCardSettings> load(String campagneId);
  Future<void> save(String campagneId, DmCharacterCardSettings settings);
}

class SharedPreferencesDmCharacterCardSettingsStore
    implements IDmCharacterCardSettingsStore {
  const SharedPreferencesDmCharacterCardSettingsStore();

  static String keyFor(String campagneId) =>
      "dmCharacterCardSettings_$campagneId";

  @override
  Future<DmCharacterCardSettings> load(String campagneId) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var raw = prefs.getString(keyFor(campagneId));
      if (raw == null) return DmCharacterCardSettings.empty;
      var decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return DmCharacterCardSettings.empty;
      }
      return DmCharacterCardSettings.fromJson(decoded);
    } catch (e) {
      debugPrint("Could not load DM card settings: $e");
      return DmCharacterCardSettings.empty;
    }
  }

  @override
  Future<void> save(String campagneId, DmCharacterCardSettings settings) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyFor(campagneId), jsonEncode(settings.toJson()));
    } catch (e) {
      debugPrint("Could not save DM card settings: $e");
    }
  }
}

/// In-memory store for tests.
class InMemoryDmCharacterCardSettingsStore
    implements IDmCharacterCardSettingsStore {
  final Map<String, DmCharacterCardSettings> entries;

  InMemoryDmCharacterCardSettingsStore([
    Map<String, DmCharacterCardSettings>? entries,
  ]) : entries = entries ?? {};

  @override
  Future<DmCharacterCardSettings> load(String campagneId) async =>
      entries[campagneId] ?? DmCharacterCardSettings.empty;

  @override
  Future<void> save(String campagneId, DmCharacterCardSettings settings) async {
    entries[campagneId] = settings;
  }
}

final dmCharacterCardSettingsStoreProvider =
    Provider<IDmCharacterCardSettingsStore>(
      (ref) => const SharedPreferencesDmCharacterCardSettingsStore(),
    );

/// The DM's card choices for one campaign (key: campaign id; `""` when the
/// session has no campaign id yet).
final dmCharacterCardSettingsProvider =
    StateNotifierProvider.family<
      DmCharacterCardSettingsNotifier,
      DmCharacterCardSettings,
      String
    >(
      (ref, campagneId) => DmCharacterCardSettingsNotifier(
        store: ref.watch(dmCharacterCardSettingsStoreProvider),
        campagneId: campagneId,
      ),
    );

class DmCharacterCardSettingsNotifier
    extends StateNotifier<DmCharacterCardSettings> {
  final IDmCharacterCardSettingsStore store;
  final String campagneId;
  bool _changedBeforeLoad = false;

  DmCharacterCardSettingsNotifier({
    required this.store,
    required this.campagneId,
  }) : super(DmCharacterCardSettings.empty) {
    _load();
  }

  Future<void> _load() async {
    var loaded = await store.load(campagneId);
    // A change the DM made while loading wins over the stored value.
    if (!mounted || _changedBeforeLoad) return;
    state = loaded;
  }

  Future<void> update(DmCharacterCardSettings settings) async {
    _changedBeforeLoad = true;
    state = settings;
    await store.save(campagneId, settings);
  }

  Future<void> setHidden(String characterUuid, bool hidden) =>
      update(state.withHidden(characterUuid, hidden));
}
