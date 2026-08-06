import 'package:flutter/material.dart';

/// Asset paths for Arcane Ledger hybrid decorations (skin-07).
abstract final class ArcaneLedgerAssets {
  static const waxSeal =
      'assets/images/character_sheet_skins/arcane_ledger_wax_seal.png';
  static const parchment =
      'assets/images/character_sheet_skins/arcane_ledger_parchment.png';
}

/// Illustrated wax seal with dynamic level text overlaid in the empty center.
///
/// Level is never baked into the raster — always passed from character data.
class CharacterSheetLevelSeal extends StatelessWidget {
  final int level;
  final String levelAbbr;
  final double size;
  final Color? textColor;

  const CharacterSheetLevelSeal({
    super.key,
    required this.level,
    required this.levelAbbr,
    this.size = 72,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final ink = textColor ?? const Color(0xFFF5E6D3);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            ArcaneLedgerAssets.waxSeal,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          // Keep text inside the recessed center disc (~50% of seal diameter).
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
                        color: Color(0x66000000),
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
                        color: Color(0x66000000),
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
