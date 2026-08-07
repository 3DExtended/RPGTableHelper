import 'package:flutter/material.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Stable skin ids stored in campaign/character JSON (never localized).
abstract final class CharacterSheetSkinIds {
  static const classicLight = 'classic_light';
  static const classicDark = 'classic_dark';
  static const arcaneLedger = 'arcane_ledger';
  static const nightCartographer = 'night_cartographer';

  static const fallback = classicDark;

  static const all = <String>{
    classicLight,
    classicDark,
    arcaneLedger,
    nightCartographer,
  };
}

class ResolvedCharacterSheetSkin {
  final String storedSkinId;
  final String renderSkinId;
  final bool isUnknown;

  const ResolvedCharacterSheetSkin({
    required this.storedSkinId,
    required this.renderSkinId,
    required this.isUnknown,
  });
}

/// Prefer character override, then campaign default, then [CharacterSheetSkinIds.fallback].
String resolveCharacterSheetSkinId({
  required String? characterSkinId,
  required String? campaignDefaultSkinId,
}) {
  return resolveCharacterSheetSkin(
    characterSkinId: characterSkinId,
    campaignDefaultSkinId: campaignDefaultSkinId,
  ).renderSkinId;
}

ResolvedCharacterSheetSkin resolveCharacterSheetSkin({
  required String? characterSkinId,
  required String? campaignDefaultSkinId,
}) {
  final stored =
      characterSkinId ?? campaignDefaultSkinId ?? CharacterSheetSkinIds.fallback;
  final known = CharacterSheetSkinIds.all.contains(stored);
  return ResolvedCharacterSheetSkin(
    storedSkinId: stored,
    renderSkinId: known ? stored : CharacterSheetSkinIds.fallback,
    isUnknown: !known,
  );
}

/// Named sheet look: tokens today; chrome/decorations grow in later slices.
class CharacterSheetSkin {
  final String id;
  final CustomTheme theme;
  final Brightness brightness;

  const CharacterSheetSkin({
    required this.id,
    required this.theme,
    required this.brightness,
  });

  static final Map<String, CharacterSheetSkin> registry = {
    CharacterSheetSkinIds.classicLight: CharacterSheetSkin(
      id: CharacterSheetSkinIds.classicLight,
      theme: CustomTheme.lightTheme,
      brightness: Brightness.light,
    ),
    CharacterSheetSkinIds.classicDark: CharacterSheetSkin(
      id: CharacterSheetSkinIds.classicDark,
      theme: CustomTheme.darkTheme,
      brightness: Brightness.dark,
    ),
    // Arcane Ledger — distinct manuscript tokens (Classic Light is warmer cream).
    CharacterSheetSkinIds.arcaneLedger: CharacterSheetSkin(
      id: CharacterSheetSkinIds.arcaneLedger,
      theme: CustomTheme.arcaneLedgerTheme,
      brightness: Brightness.light,
    ),
    CharacterSheetSkinIds.nightCartographer: CharacterSheetSkin(
      id: CharacterSheetSkinIds.nightCartographer,
      theme: CustomTheme.nightCartographerTheme,
      brightness: Brightness.dark,
    ),
  };

  static CharacterSheetSkin forRenderId(String renderSkinId) {
    return registry[renderSkinId] ??
        registry[CharacterSheetSkinIds.fallback]!;
  }
}
