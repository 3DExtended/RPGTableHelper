import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_level_seal.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Soft parchment atmosphere + optional double-rule frame for Ledger chrome.
class CharacterSheetSkinChrome extends StatelessWidget {
  final Widget child;
  final bool showFrame;

  const CharacterSheetSkinChrome({
    super.key,
    required this.child,
    this.showFrame = true,
  });

  @override
  Widget build(BuildContext context) {
    final skinId = CustomThemeProvider.of(context).skinIdNotifier.value;
    final renderId = resolveCharacterSheetSkin(
      characterSkinId: skinId,
      campaignDefaultSkinId: null,
    ).renderSkinId;

    if (renderId != CharacterSheetSkinIds.arcaneLedger) {
      return child;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.55,
              child: Image.asset(
                ArcaneLedgerAssets.parchment,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
        if (showFrame)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _LedgerDoubleRuleFramePainter(
                  ink: CustomThemeProvider.of(context).theme.darkColor,
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}

class _LedgerDoubleRuleFramePainter extends CustomPainter {
  final Color ink;

  _LedgerDoubleRuleFramePainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = ink.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final inner = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const inset = 10.0;
    final outerR = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
      const Radius.circular(2),
    );
    final innerR = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset + 4,
        inset + 4,
        size.width - (inset + 4) * 2,
        size.height - (inset + 4) * 2,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(outerR, outer);
    canvas.drawRRect(innerR, inner);
  }

  @override
  bool shouldRepaint(covariant _LedgerDoubleRuleFramePainter oldDelegate) =>
      oldDelegate.ink != ink;
}

/// True when the active theme skin renders as Arcane Ledger.
bool isArcaneLedgerActive(BuildContext context) {
  final skinId = CustomThemeProvider.of(context).skinIdNotifier.value;
  return resolveCharacterSheetSkin(
        characterSkinId: skinId,
        campaignDefaultSkinId: null,
      ).renderSkinId ==
      CharacterSheetSkinIds.arcaneLedger;
}
