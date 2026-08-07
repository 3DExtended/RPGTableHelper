import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/night_cartographer_ornaments.dart';

/// Asset paths for Arcane Ledger hybrid decorations (skin-07).
abstract final class ArcaneLedgerAssets {
  static const waxSeal =
      'assets/images/character_sheet_skins/arcane_ledger_wax_seal.png';
  static const parchment =
      'assets/images/character_sheet_skins/arcane_ledger_parchment.png';
  static const cornerFlourish =
      'assets/images/character_sheet_skins/arcane_ledger_corner_flourish.png';
  static const navbarLeather =
      'assets/images/character_sheet_skins/arcane_ledger_navbar_leather.png';
  static const moneyBagHero =
      'assets/images/character_sheet_skins/arcane_ledger_money_bag_hero.png';
  static const moneyBagPlatin =
      'assets/images/character_sheet_skins/arcane_ledger_money_bag_platin.png';
  static const moneyBagGold =
      'assets/images/character_sheet_skins/arcane_ledger_money_bag_gold.png';
  static const moneyBagSilber =
      'assets/images/character_sheet_skins/arcane_ledger_money_bag_silber.png';
  static const moneyBagKupfer =
      'assets/images/character_sheet_skins/arcane_ledger_money_bag_kupfer.png';

  /// Illustrated denomination bag for Ledger currency columns.
  static String moneyBagForLabel(String label) {
    switch (label) {
      case 'Platin':
        return moneyBagPlatin;
      case 'Gold':
        return moneyBagGold;
      case 'Silber':
        return moneyBagSilber;
      case 'Kupfer':
        return moneyBagKupfer;
      default:
        return moneyBagHero;
    }
  }
}

/// Asset paths for Night Cartographer hybrid decorations (skin-09).
///
/// Level seal + corners are drawn (see [night_cartographer_ornaments]).
abstract final class NightCartographerAssets {
  static const constellation =
      'assets/images/character_sheet_skins/night_cartographer_constellation.png';
}

/// Illustrated level badge with dynamic level text.
///
/// Ledger uses the wax-seal raster. Cartographer uses [CartographerLevelBadge]
/// (CustomPainter rings — no seal image).
class CharacterSheetLevelSeal extends StatelessWidget {
  final int level;
  final String levelAbbr;
  final double size;
  final Color? textColor;
  final String assetPath;
  final bool drawCartographerCompass;

  const CharacterSheetLevelSeal({
    super.key,
    required this.level,
    required this.levelAbbr,
    this.size = 72,
    this.textColor,
    this.assetPath = ArcaneLedgerAssets.waxSeal,
    this.drawCartographerCompass = false,
  });

  factory CharacterSheetLevelSeal.forSkin({
    required bool nightCartographer,
    required int level,
    required String levelAbbr,
    double size = 72,
    Color? textColor,
  }) {
    return CharacterSheetLevelSeal(
      level: level,
      levelAbbr: levelAbbr,
      size: size,
      textColor: textColor ??
          (nightCartographer
              ? const Color(0xFFF0E6D4)
              : const Color(0xFFF5E6D3)),
      assetPath: ArcaneLedgerAssets.waxSeal,
      drawCartographerCompass: nightCartographer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ink = textColor ?? const Color(0xFFF5E6D3);
    if (drawCartographerCompass) {
      return CartographerLevelBadge(
        level: level,
        levelAbbr: levelAbbr,
        size: size,
        textColor: ink,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(
            width: size * 0.52,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$level',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.28,
                    height: 1.0,
                    fontFamily: 'Ruwudu',
                    shadows: const [
                      Shadow(
                        color: Color(0x88000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                Text(
                  levelAbbr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ink.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                    fontSize: size * 0.14,
                    height: 1.05,
                    fontFamily: 'Ruwudu',
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(
                        color: Color(0x88000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
