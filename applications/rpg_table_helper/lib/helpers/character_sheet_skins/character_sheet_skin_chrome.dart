import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_level_seal.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/night_cartographer_ornaments.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Soft atmosphere + optional double-rule frame for hybrid skins.
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
    final renderId = activeRenderSkinId(context);

    if (renderId == CharacterSheetSkinIds.arcaneLedger) {
      return _ledgerChrome(context);
    }
    if (renderId == CharacterSheetSkinIds.nightCartographer) {
      return _cartographerChrome(context);
    }
    return child;
  }

  Widget _ledgerChrome(BuildContext context) {
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
        child,
        if (showFrame)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DoubleRuleFramePainter(ink: ink),
              ),
            ),
          ),
        if (showFrame)
          ..._pageCornerAssets(
            ArcaneLedgerAssets.cornerFlourish,
            size: 72,
            opacity: 0.88,
          ),
      ],
    );
  }

  Widget _cartographerChrome(BuildContext context) {
    final gold = CustomThemeProvider.of(context).theme.accentColor;

    return Stack(
      fit: expand ? StackFit.expand : StackFit.passthrough,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(
              color: CustomThemeProvider.of(context).theme.bgColor,
              child: Opacity(
                opacity: 0.55,
                child: Image.asset(
                  NightCartographerAssets.constellation,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
        child,
        if (showFrame)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DoubleRuleFramePainter(ink: gold),
              ),
            ),
          ),
        if (showFrame)
          ...cartographerPageCorners(
            color: gold,
            size: 56,
            opacity: 0.92,
            inset: 4,
          ),
      ],
    );
  }

  List<Widget> _pageCornerAssets(
    String asset, {
    required double size,
    required double opacity,
  }) {
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
              opacity: opacity,
              child: Image.asset(
                asset,
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

class _DoubleRuleFramePainter extends CustomPainter {
  final Color ink;

  _DoubleRuleFramePainter({required this.ink});

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
  bool shouldRepaint(covariant _DoubleRuleFramePainter oldDelegate) =>
      oldDelegate.ink != ink;
}

String activeRenderSkinId(BuildContext context) {
  final skinId = CustomThemeProvider.of(context).skinIdNotifier.value;
  return resolveCharacterSheetSkin(
    characterSkinId: skinId,
    campaignDefaultSkinId: null,
  ).renderSkinId;
}

/// True when the active theme skin renders as Arcane Ledger.
bool isArcaneLedgerActive(BuildContext context) =>
    activeRenderSkinId(context) == CharacterSheetSkinIds.arcaneLedger;

/// True when the active theme skin renders as Night Cartographer.
bool isNightCartographerActive(BuildContext context) =>
    activeRenderSkinId(context) == CharacterSheetSkinIds.nightCartographer;

/// Ledger or Cartographer — shared decorated-sheet layout (not Classic).
bool isDecoratedSheetSkinActive(BuildContext context) =>
    isArcaneLedgerActive(context) || isNightCartographerActive(context);

/// Background for tab surfaces: transparent under decorated skins so chrome shows.
Color characterSheetSurfaceColor(BuildContext context) {
  if (isDecoratedSheetSkinActive(context)) return Colors.transparent;
  return CustomThemeProvider.of(context).theme.bgColor;
}

/// Inset so content clears the double-rule frame + corner ornaments.
///
/// Applied for Night Cartographer only — Ledger already cleared the frame via
/// per-tab padding tuned against parchment chrome.
EdgeInsets characterSheetContentInsets(
  BuildContext context, {
  bool forModal = false,
}) {
  if (!isNightCartographerActive(context)) return EdgeInsets.zero;
  // Frame outer rule sits at ~10px; corner L-arms extend ~40–50px along edges.
  if (forModal) {
    return const EdgeInsets.all(12);
  }
  return const EdgeInsets.fromLTRB(28, 24, 28, 28);
}

/// Modal card shell: classic solid panel, or decorated parchment/atlas + frame.
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
        child: Padding(
          padding: characterSheetContentInsets(context, forModal: true),
          child: child,
        ),
      ),
    );
  }
}

/// Bottom inset for modal action rows. Extra clearance under decorated skins.
double modalFooterBottomPadding(BuildContext context, {double classic = 10}) {
  return isDecoratedSheetSkinActive(context) ? 24.0 : classic;
}

/// Content-box constraints for use **inside** [SkinnedModalPanel].
///
/// Frame/modal insets live outside this box (via [SkinnedModalPanel] padding),
/// so the panel grows with the skin instead of cropping children. Decorated
/// skins also get a taller footer; that delta is added to [maxHeight] so the
/// body keeps the same budget as classic.
BoxConstraints skinnedModalContentConstraints(
  BuildContext context, {
  double? maxWidth,
  double? maxHeight,
  double classicFooterPadding = 10,
}) {
  final footerPad = modalFooterBottomPadding(
    context,
    classic: classicFooterPadding,
  );
  final footerExtra = (footerPad - classicFooterPadding).clamp(0.0, 64.0);
  return BoxConstraints(
    maxWidth: maxWidth ?? double.infinity,
    maxHeight:
        maxHeight == null ? double.infinity : maxHeight + footerExtra,
  );
}
