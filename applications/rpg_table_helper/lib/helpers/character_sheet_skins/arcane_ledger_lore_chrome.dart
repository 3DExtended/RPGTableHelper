import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Thin horizontal rule with centered 8-point star (Ledger manuscript chrome).
class LedgerStarRule extends StatelessWidget {
  final Color? ink;
  final double height;
  final double horizontalInset;

  const LedgerStarRule({
    super.key,
    this.ink,
    this.height = 18,
    this.horizontalInset = 8,
  });

  @override
  Widget build(BuildContext context) {
    final color = ink ?? CustomThemeProvider.of(context).theme.darkColor;
    return CustomPaint(
      painter: LedgerStarRulePainter(ink: color, inset: horizontalInset),
      child: SizedBox(width: double.infinity, height: height),
    );
  }
}

/// Ink-outlined / filled parchment filter chip used on inventory & crafting.
class LedgerFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const LedgerFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final cartographer = isNightCartographerActive(context);
    // Ledger: dark ink on parchment. Cartographer: champagne gold on navy.
    final ink = cartographer ? theme.accentColor : theme.darkTextColor;
    final selectedText = theme.bgColor;
    final unselectedText =
        cartographer ? theme.darkTextColor : ink;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: CustomPaint(
        painter: _LedgerChipBorderPainter(
          ink: selected ? ink : ink.withValues(alpha: 0.7),
          fill: selected ? ink : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: selected ? selectedText : unselectedText,
                  fontFamily: 'Ruwudu',
                  fontSize: 14,
                ),
          ),
        ),
      ),
    );
  }
}

class _LedgerChipBorderPainter extends CustomPainter {
  final Color ink;
  final Color? fill;

  _LedgerChipBorderPainter({required this.ink, this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      const Radius.circular(3),
    );
    if (fill != null) {
      canvas.drawRRect(r, Paint()..color = fill!);
    }
    canvas.drawRRect(
      r,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    if (fill == null) {
      final inner = RRect.fromRectAndRadius(
        Rect.fromLTWH(2.5, 2.5, size.width - 5, size.height - 5),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        inner,
        Paint()
          ..color = ink.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LedgerChipBorderPainter oldDelegate) =>
      oldDelegate.ink != ink || oldDelegate.fill != fill;
}

class LedgerStarRulePainter extends CustomPainter {
  final Color ink;
  final double inset;

  LedgerStarRulePainter({required this.ink, this.inset = 8});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.45)
      ..strokeWidth = 1.0;
    final midY = size.height / 2;
    final star = Paint()
      ..color = ink.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    final c = Offset(size.width / 2, midY);
    final path = Path();
    // Clear 8-point compass star (mock section dividers).
    for (var i = 0; i < 8; i++) {
      final angle = -pi / 2 + i * pi / 4;
      final radius = i.isEven ? 6.0 : 2.4;
      final p = Offset(c.dx + cos(angle) * radius, c.dy + sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, star);
    canvas.drawLine(
      Offset(inset, midY),
      Offset(size.width / 2 - 14, midY),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2 + 14, midY),
      Offset(size.width - inset, midY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant LedgerStarRulePainter oldDelegate) =>
      oldDelegate.ink != ink || oldDelegate.inset != inset;
}

/// Double hairline rule used between lore blocks / under headers.
class LedgerDoubleRule extends StatelessWidget {
  final Color? ink;

  const LedgerDoubleRule({super.key, this.ink});

  @override
  Widget build(BuildContext context) {
    final color = ink ?? CustomThemeProvider.of(context).theme.darkColor;
    return CustomPaint(
      painter: _LedgerDoubleRulePainter(ink: color),
      child: const SizedBox(width: double.infinity, height: 10),
    );
  }
}

class _LedgerDoubleRulePainter extends CustomPainter {
  final Color ink;

  _LedgerDoubleRulePainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final thick = Paint()
      ..color = ink.withValues(alpha: 0.55)
      ..strokeWidth = 1.4;
    final thin = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..strokeWidth = 0.9;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y - 1.5), Offset(size.width, y - 1.5), thick);
    canvas.drawLine(Offset(0, y + 1.5), Offset(size.width, y + 1.5), thin);
  }

  @override
  bool shouldRepaint(covariant _LedgerDoubleRulePainter oldDelegate) =>
      oldDelegate.ink != ink;
}

/// Small diamond bullet for lore document list.
/// Selected = filled manuscript ink (not navbar copper).
class LedgerLoreListDiamond extends StatelessWidget {
  final bool selected;

  const LedgerLoreListDiamond({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    final ink = CustomThemeProvider.of(context).theme.darkColor;
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 2),
      child: CustomPaint(
        size: const Size(12, 12),
        painter: _LedgerLoreDiamondPainter(
          color: ink,
          filled: selected,
        ),
      ),
    );
  }
}

class _LedgerLoreDiamondPainter extends CustomPainter {
  final Color color;
  final bool filled;

  _LedgerLoreDiamondPainter({required this.color, required this.filled});

  Path _diamond(Offset c, double r) {
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r, c.dy)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = min(size.width, size.height) / 2 - 0.5;
    if (filled) {
      canvas.drawPath(
        _diamond(c, r),
        Paint()
          ..color = color.withValues(alpha: 0.92)
          ..style = PaintingStyle.fill,
      );
    } else {
      canvas.drawPath(
        _diamond(c, r),
        Paint()
          ..color = color.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.25,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LedgerLoreDiamondPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.filled != filled;
}

/// Soft manuscript binder gutter between lore index and content pages.
///
/// Drawn in theme ink on the live parchment (no pasted mock spine plate —
/// those always mismatched color and sat as a foreign strip).
class LedgerBinderSpine extends StatelessWidget {
  final int ringCount;

  const LedgerBinderSpine({super.key, this.ringCount = 5});

  @override
  Widget build(BuildContext context) {
    final ink = CustomThemeProvider.of(context).theme.darkColor;
    return SizedBox(
      width: 44,
      child: CustomPaint(
        painter: _LedgerBinderSpinePainter(ink: ink, ringCount: ringCount),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LedgerBinderSpinePainter extends CustomPainter {
  final Color ink;
  final int ringCount;

  _LedgerBinderSpinePainter({required this.ink, required this.ringCount});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Soft page-curl into the gutter.
    final leftShade = Paint()
      ..shader = LinearGradient(
        colors: [
          ink.withValues(alpha: 0.0),
          ink.withValues(alpha: 0.10),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width * 0.45, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * 0.45, size.height),
      leftShade,
    );
    final rightShade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          ink.withValues(alpha: 0.0),
          ink.withValues(alpha: 0.10),
        ],
      ).createShader(
        Rect.fromLTWH(size.width * 0.55, 0, size.width * 0.45, size.height),
      );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, 0, size.width * 0.45, size.height),
      rightShade,
    );

    // Thin crease lines (manuscript fold).
    final crease = Paint()
      ..color = ink.withValues(alpha: 0.28)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 2.5, 6), Offset(cx - 2.5, size.height - 6), crease);
    canvas.drawLine(Offset(cx + 2.5, 6), Offset(cx + 2.5, size.height - 6), crease);
    canvas.drawLine(
      Offset(cx, 6),
      Offset(cx, size.height - 6),
      Paint()
        ..color = ink.withValues(alpha: 0.14)
        ..strokeWidth = 0.8,
    );

    final top = size.height * 0.12;
    final bottom = size.height * 0.88;
    final span = bottom - top;
    for (var i = 0; i < ringCount; i++) {
      final cy = top + span * (i + 0.5) / ringCount;
      _drawRing(canvas, Offset(cx, cy), size.width);
    }
  }

  void _drawRing(Canvas canvas, Offset c, double width) {
    final holeR = 4.2;
    final holePaint = Paint()..color = ink.withValues(alpha: 0.55);
    final holeStroke = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final leftHole = Offset(c.dx - width * 0.28, c.dy);
    final rightHole = Offset(c.dx + width * 0.28, c.dy);
    canvas.drawCircle(leftHole, holeR, holePaint);
    canvas.drawCircle(rightHole, holeR, holePaint);
    canvas.drawCircle(leftHole, holeR, holeStroke);
    canvas.drawCircle(rightHole, holeR, holeStroke);

    // Soft contact shadow under the cord.
    final shadow = Paint()
      ..color = ink.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final cordRect = Rect.fromCenter(
      center: c.translate(0, 1.2),
      width: width * 0.62,
      height: 7,
    );
    canvas.drawOval(cordRect, shadow);

    // Cord / thong — layered strokes in theme ink (no foreign parchment tint).
    final outer = Paint()
      ..color = ink.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    final mid = Paint()
      ..color = ink.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final hi = Paint()
      ..color = const Color(0xFFF0E2CC).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final oval = Rect.fromCenter(center: c, width: width * 0.62, height: 7.5);
    canvas.drawOval(oval, outer);
    canvas.drawOval(oval.deflate(0.6), mid);
    canvas.drawArc(oval.deflate(1.0), -2.6, 1.2, false, hi);
  }

  @override
  bool shouldRepaint(covariant _LedgerBinderSpinePainter oldDelegate) =>
      oldDelegate.ink != ink || oldDelegate.ringCount != ringCount;
}

/// Night Cartographer lore divider: thin gold rule with star caps (mock atlas
/// separator — not the Ledger binder rings).
class CartographerLoreDivider extends StatelessWidget {
  const CartographerLoreDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = CustomThemeProvider.of(context).theme.accentColor;
    return SizedBox(
      width: 28,
      child: CustomPaint(
        painter: _CartographerLoreDividerPainter(ink: gold),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CartographerLoreDividerPainter extends CustomPainter {
  final Color ink;

  _CartographerLoreDividerPainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final top = 10.0;
    final bottom = size.height - 10.0;

    final rule = Paint()
      ..color = ink.withValues(alpha: 0.75)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Leave gaps for the end ornaments.
    const ornamentGap = 14.0;
    canvas.drawLine(
      Offset(cx, top + ornamentGap),
      Offset(cx, bottom - ornamentGap),
      rule,
    );

    _drawStarCap(canvas, Offset(cx, top + 6), ink);
    _drawStarCap(canvas, Offset(cx, bottom - 6), ink);
  }

  void _drawStarCap(Canvas canvas, Offset c, Color color) {
    final fill = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final path = Path();
    const points = 8;
    const outer = 5.5;
    const inner = 2.2;
    for (var i = 0; i < points * 2; i++) {
      final a = -pi / 2 + i * pi / points;
      final r = i.isEven ? outer : inner;
      final p = Offset(c.dx + cos(a) * r, c.dy + sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    // Tiny center diamond node.
    canvas.drawCircle(
      c,
      1.4,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _CartographerLoreDividerPainter oldDelegate) =>
      oldDelegate.ink != ink;
}

/// Outlined manuscript "+ New" — dark ink for readability on parchment.
class LedgerOutlinedAccentButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;

  const LedgerOutlinedAccentButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ink = CustomThemeProvider.of(context).theme.darkColor;
    return CupertinoButton(
      onPressed: onPressed,
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      child: CustomPaint(
        painter: _LedgerOutlinedRectPainter(ink: ink),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: ink,
                      fontSize: 16,
                      fontFamily: 'Ruwudu',
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LedgerOutlinedRectPainter extends CustomPainter {
  final Color ink;

  _LedgerOutlinedRectPainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      const Radius.circular(2),
    );
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      const Radius.circular(1),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawRRect(
      inner,
      Paint()
        ..color = ink.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
  }

  @override
  bool shouldRepaint(covariant _LedgerOutlinedRectPainter oldDelegate) =>
      oldDelegate.ink != ink;
}

/// Circular floral medallion with flanking rules — lore page footer.
class LedgerLorePageFooter extends StatelessWidget {
  const LedgerLorePageFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final ink = CustomThemeProvider.of(context).theme.darkColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: CustomPaint(
        painter: _LedgerLoreFooterPainter(ink: ink),
        child: const SizedBox(width: double.infinity, height: 56),
      ),
    );
  }
}

class _LedgerLoreFooterPainter extends CustomPainter {
  final Color ink;

  _LedgerLoreFooterPainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final line = Paint()
      ..color = ink.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Flanking rules with diamond terminals.
    const medallionR = 18.0;
    canvas.drawLine(
      Offset(24, c.dy),
      Offset(c.dx - medallionR - 10, c.dy),
      line,
    );
    canvas.drawLine(
      Offset(c.dx + medallionR + 10, c.dy),
      Offset(size.width - 24, c.dy),
      line,
    );
    _drawLozenge(canvas, Offset(40, c.dy), 3.5, ink);
    _drawLozenge(canvas, Offset(size.width - 40, c.dy), 3.5, ink);

    // Concentric medallion.
    canvas.drawCircle(
      c,
      medallionR,
      Paint()
        ..color = ink.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      c,
      medallionR - 3,
      Paint()
        ..color = ink.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Six-petal floral / sunburst.
    final petal = Paint()
      ..color = ink.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (var i = 0; i < 6; i++) {
      final angle = -pi / 2 + i * pi / 3;
      final outer = Offset(
        c.dx + cos(angle) * (medallionR - 6),
        c.dy + sin(angle) * (medallionR - 6),
      );
      final ctrl1 = Offset(
        c.dx + cos(angle - 0.35) * 7,
        c.dy + sin(angle - 0.35) * 7,
      );
      final ctrl2 = Offset(
        c.dx + cos(angle + 0.35) * 7,
        c.dy + sin(angle + 0.35) * 7,
      );
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..quadraticBezierTo(ctrl1.dx, ctrl1.dy, outer.dx, outer.dy)
        ..quadraticBezierTo(ctrl2.dx, ctrl2.dy, c.dx, c.dy);
      canvas.drawPath(path, petal);
    }
    canvas.drawCircle(
      c,
      2.2,
      Paint()
        ..color = ink.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawLozenge(Canvas canvas, Offset c, double r, Color ink) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r, c.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = ink.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _LedgerLoreFooterPainter oldDelegate) =>
      oldDelegate.ink != ink;
}
