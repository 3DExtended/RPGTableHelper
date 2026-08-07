import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_level_seal.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Soft parchment atmosphere + optional double-rule frame for Ledger chrome.
class CharacterSheetSkinChrome extends StatelessWidget {
  final Widget child;
  final bool showFrame;

  /// When true (pages), fills the parent. When false (modal cards), sizes to
  /// [child] so shrink-wrapped dialogs keep their intrinsic height.
  final bool expand;

  const CharacterSheetSkinChrome({
    super.key,
    required this.child,
    this.showFrame = true,
    this.expand = true,
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

    final ink = CustomThemeProvider.of(context).theme.darkColor;

    return Stack(
      fit: expand ? StackFit.expand : StackFit.passthrough,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.82,
              child: Image.asset(
                ArcaneLedgerAssets.parchment,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
        // Content first so opaque chrome (e.g. modal navbar) does not cover
        // the double-rule frame / corner flourishes.
        child,
        if (showFrame)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _LedgerDoubleRuleFramePainter(ink: ink),
              ),
            ),
          ),
        if (showFrame) ..._pageCornerFlourishes(),
      ],
    );
  }

  List<Widget> _pageCornerFlourishes() {
    const size = 72.0;
    Widget flourish({
      required double? left,
      required double? top,
      required double? right,
      required double? bottom,
      required int turns,
    }) {
      return Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        child: IgnorePointer(
          child: RotatedBox(
            quarterTurns: turns,
            child: Opacity(
              opacity: 0.88,
              child: Image.asset(
                ArcaneLedgerAssets.cornerFlourish,
                width: size,
                height: size,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      );
    }

    return [
      flourish(left: 2, top: 2, right: null, bottom: null, turns: 0),
      flourish(left: null, top: 2, right: 2, bottom: null, turns: 1),
      flourish(left: null, top: null, right: 2, bottom: 2, turns: 2),
      flourish(left: 2, top: null, right: null, bottom: 2, turns: 3),
    ];
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

/// Background for tab surfaces: transparent under Ledger so parchment shows.
Color characterSheetSurfaceColor(BuildContext context) {
  if (isArcaneLedgerActive(context)) return Colors.transparent;
  return CustomThemeProvider.of(context).theme.bgColor;
}

/// Modal card shell: classic solid panel, or Ledger parchment + frame.
class SkinnedModalPanel extends StatelessWidget {
  final Widget child;
  final bool showFrame;

  const SkinnedModalPanel({
    super.key,
    required this.child,
    this.showFrame = true,
  });

  @override
  Widget build(BuildContext context) {
    return CharacterSheetSkinChrome(
      expand: false,
      showFrame: showFrame,
      child: ColoredBox(
        color: characterSheetSurfaceColor(context),
        child: child,
      ),
    );
  }
}

/// Bottom inset for modal action rows. Extra clearance only under Ledger so
/// buttons clear the parchment frame without shifting classic chrome.
double modalFooterBottomPadding(BuildContext context, {double classic = 10}) {
  return isArcaneLedgerActive(context) ? 24.0 : classic;
}
