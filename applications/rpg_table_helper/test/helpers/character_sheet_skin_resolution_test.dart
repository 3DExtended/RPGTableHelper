import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';

void main() {
  group('resolveCharacterSheetSkinId', () {
    test('uses character override when set', () {
      expect(
        resolveCharacterSheetSkinId(
          characterSkinId: CharacterSheetSkinIds.arcaneLedger,
          campaignDefaultSkinId: CharacterSheetSkinIds.classicLight,
        ),
        CharacterSheetSkinIds.arcaneLedger,
      );
    });

    test('inherits campaign default when character skin is null', () {
      expect(
        resolveCharacterSheetSkinId(
          characterSkinId: null,
          campaignDefaultSkinId: CharacterSheetSkinIds.classicLight,
        ),
        CharacterSheetSkinIds.classicLight,
      );
    });

    test('falls back to classic_dark when both null', () {
      expect(
        resolveCharacterSheetSkinId(
          characterSkinId: null,
          campaignDefaultSkinId: null,
        ),
        CharacterSheetSkinIds.classicDark,
      );
    });

    test('unknown stored id resolves render id to classic_dark but keeps stored',
        () {
      const stored = 'future_skin_from_newer_client';
      final result = resolveCharacterSheetSkin(
        characterSkinId: stored,
        campaignDefaultSkinId: CharacterSheetSkinIds.classicLight,
      );
      expect(result.storedSkinId, stored);
      expect(result.renderSkinId, CharacterSheetSkinIds.classicDark);
      expect(result.isUnknown, isTrue);
    });

    test('known override is not unknown', () {
      final result = resolveCharacterSheetSkin(
        characterSkinId: CharacterSheetSkinIds.nightCartographer,
        campaignDefaultSkinId: null,
      );
      expect(result.storedSkinId, CharacterSheetSkinIds.nightCartographer);
      expect(result.renderSkinId, CharacterSheetSkinIds.nightCartographer);
      expect(result.isUnknown, isFalse);
    });
  });

  group('CharacterSheetSkin registry', () {
    test('contains the four v1 skins', () {
      expect(
        CharacterSheetSkin.registry.keys.toSet(),
        {
          CharacterSheetSkinIds.classicLight,
          CharacterSheetSkinIds.classicDark,
          CharacterSheetSkinIds.arcaneLedger,
          CharacterSheetSkinIds.nightCartographer,
        },
      );
    });

    test('classic packs expose theme tokens', () {
      final light = CharacterSheetSkin.registry[CharacterSheetSkinIds.classicLight]!;
      final dark = CharacterSheetSkin.registry[CharacterSheetSkinIds.classicDark]!;
      expect(light.theme.bgColor, isNot(dark.theme.bgColor));
      expect(light.theme.accentColor, isNotNull);
    });
  });
}
