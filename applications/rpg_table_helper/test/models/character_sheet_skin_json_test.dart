import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

void main() {
  group('sheet skin JSON fields', () {
    test('campaign defaultSkinId absent stays null and is omitted when null', () {
      final base = RpgConfigurationModel.getBaseConfiguration();
      final decoded = RpgConfigurationModel.fromJson(
        jsonDecode(jsonEncode(base)) as Map<String, dynamic>,
      );
      expect(decoded.defaultSkinId, isNull);
      expect(jsonEncode(base).contains('defaultSkinId'), isFalse);
    });

    test('campaign defaultSkinId round-trips when set', () {
      final withSkin = RpgConfigurationModel.getBaseConfiguration()
          .copyWith(defaultSkinId: CharacterSheetSkinIds.arcaneLedger);
      final json = jsonDecode(jsonEncode(withSkin)) as Map<String, dynamic>;
      expect(json['defaultSkinId'], CharacterSheetSkinIds.arcaneLedger);
      final decoded = RpgConfigurationModel.fromJson(json);
      expect(decoded.defaultSkinId, CharacterSheetSkinIds.arcaneLedger);
    });

    test('character skinId absent stays null and is omitted when null', () {
      final base = RpgCharacterConfiguration.getBaseConfiguration(null);
      expect(base.skinId, isNull);
      expect(jsonEncode(base).contains('skinId'), isFalse);
    });

    test('character skinId round-trips when set', () {
      final withSkin = RpgCharacterConfiguration.getBaseConfiguration(null)
          .copyWith(skinId: CharacterSheetSkinIds.nightCartographer);
      final json = jsonDecode(jsonEncode(withSkin)) as Map<String, dynamic>;
      expect(json['skinId'], CharacterSheetSkinIds.nightCartographer);
      final decoded = RpgCharacterConfiguration.fromJson(json);
      expect(decoded.skinId, CharacterSheetSkinIds.nightCartographer);
    });
  });
}
