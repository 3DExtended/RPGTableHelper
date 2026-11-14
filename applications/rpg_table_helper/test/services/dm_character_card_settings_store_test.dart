import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/models/dm_character_card_settings.dart';
import 'package:quest_keeper/services/dm_character_card_settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DmCharacterCardSettings json', () {
    test('round-trips', () {
      var settings = DmCharacterCardSettings(
        hiddenCharacterUuids: {"kylo", "pet"},
        useCustomStats: true,
        barStatUuid: "hp",
        numberStats: [
          StatNumberRef(statUuid: "icons", entryUuid: "ac"),
          StatNumberRef(statUuid: "skills", field: StatNumberField.otherValue),
        ],
      );

      expect(DmCharacterCardSettings.fromJson(settings.toJson()), settings);
    });

    test('ignores broken parts instead of failing', () {
      var parsed = DmCharacterCardSettings.fromJson({
        "hiddenCharacterUuids": ["a", 3],
        "useCustomStats": "yes",
        "barStatUuid": 12,
        "numberStats": ["only-one-part", "s||value", "s|e|unknownField"],
      });

      expect(parsed.hiddenCharacterUuids, {"a"});
      expect(parsed.useCustomStats, isFalse);
      expect(parsed.barStatUuid, isNull);
      expect(parsed.numberStats, [StatNumberRef(statUuid: "s")]);
    });
  });

  group('SharedPreferencesDmCharacterCardSettingsStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('keeps settings per campaign', () async {
      const store = SharedPreferencesDmCharacterCardSettingsStore();
      await store.save(
        "c1",
        DmCharacterCardSettings(hiddenCharacterUuids: {"kylo"}),
      );

      expect((await store.load("c1")).hiddenCharacterUuids, {"kylo"});
      expect(await store.load("c2"), DmCharacterCardSettings.empty);
    });

    test('hidden cards survive a restart of the app', () async {
      var first = ProviderContainer();
      await Future<void>.delayed(Duration.zero);
      await first
          .read(dmCharacterCardSettingsProvider("c1").notifier)
          .setHidden("kylo", true);
      first.dispose();

      var second = ProviderContainer();
      addTearDown(second.dispose);
      second.read(dmCharacterCardSettingsProvider("c1"));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        second.read(dmCharacterCardSettingsProvider("c1")).isHidden("kylo"),
        isTrue,
      );
      expect(
        second.read(dmCharacterCardSettingsProvider("c2")).isHidden("kylo"),
        isFalse,
      );
    });
  });
}
