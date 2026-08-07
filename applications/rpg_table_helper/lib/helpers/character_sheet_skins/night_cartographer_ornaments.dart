import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Champagne-gold L-bracket corner for Night Cartographer chrome.
///
/// Drawn (not a raster) so corners stay sharp and never show sprite-sheet
/// artifacts from generative plates.
class CartographerCornerBracket extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final int quarterTurns;

  const CartographerCornerBracket({
    super.key,
    this.size = 56,
    this.color = const Color(0xffD4AF77),
    this.opacity = 0.9,
    this.quarterTurns = 0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: Opacity(
          opacity: opacity,
          child: CustomPaint(
            size: Size(size, size),
            painter: CartographerCornerPainter(color: color),
          ),
        ),
      ),
    );
  }
}

class CartographerCornerPainter extends CustomPainter {
  final Color color;

  CartographerCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.shortestSide;
    final ink = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.028)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final thin = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.7, w * 0.016)
      ..strokeCap = StrokeCap.round;

    final inset = w * 0.12;
    final arm = w * 0.78;

    // Outer L
    final outer = Path()
      ..moveTo(inset, inset + arm)
      ..lineTo(inset, inset)
      ..lineTo(inset + arm, inset);
    canvas.drawPath(outer, ink);

    // Inner parallel L
    final gap = w * 0.08;
    final inner = Path()
      ..moveTo(inset + gap, inset + arm)
      ..lineTo(inset + gap, inset + gap)
      ..lineTo(inset + arm, inset + gap);
    canvas.drawPath(inner, thin);

    // End ticks
    final tick = w * 0.07;
    canvas.drawLine(
      Offset(inset + arm, inset),
      Offset(inset + arm, inset + tick),
      ink,
    );
    canvas.drawLine(
      Offset(inset, inset + arm),
      Offset(inset + tick, inset + arm),
      ink,
    );

    // Corner diamond / star knot
    final c = Offset(inset + gap * 0.35, inset + gap * 0.35);
    final r = w * 0.07;
    final star = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final rad = i.isEven ? r : r * 0.4;
      final p = Offset(c.dx + math.cos(a) * rad, c.dy + math.sin(a) * rad);
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    canvas.drawPath(
      star,
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CartographerCornerPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Concentric compass / astrolabe rings for the Cartographer level badge.
class CartographerCompassRings extends StatelessWidget {
  final double size;
  final Color color;

  const CartographerCompassRings({
    super.key,
    required this.size,
    this.color = const Color(0xffD4AF77),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CartographerCompassRingsPainter(color: color),
    );
  }
}

/// Level number + abbr over drawn compass rings (no raster seal).
class CartographerLevelBadge extends StatelessWidget {
  final int level;
  final String levelAbbr;
  final double size;
  final Color ringColor;
  final Color textColor;

  const CartographerLevelBadge({
    super.key,
    required this.level,
    required this.levelAbbr,
    required this.size,
    this.ringColor = const Color(0xffD4AF77),
    this.textColor = const Color(0xffF0E6D4),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CartographerCompassRingsPainter(color: ringColor),
        child: Center(
          child: SizedBox(
            width: size * 0.52,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$level',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.28,
                    height: 1.0,
                    fontFamily: 'Ruwudu',
                  ),
                ),
                Text(
                  levelAbbr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                    fontSize: size * 0.14,
                    height: 1.05,
                    fontFamily: 'Ruwudu',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CartographerCompassRingsPainter extends CustomPainter {
  final Color color;

  CartographerCompassRingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = size.shortestSide / 2;

    final outer = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, size.width * 0.02);

    final mid = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, size.width * 0.012);

    final inner = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, size.width * 0.022);

    // Double outer rule (astrolabe plate).
    canvas.drawCircle(c, maxR * 0.96, outer);
    canvas.drawCircle(c, maxR * 0.90, mid);
    // Tick band
    canvas.drawCircle(c, maxR * 0.78, mid);
    // Inner ring framing the level text.
    canvas.drawCircle(c, maxR * 0.58, inner);

    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 60; i++) {
      final a = i * math.pi / 30;
      final major = i % 5 == 0;
      final r0 = maxR * (major ? 0.80 : 0.84);
      final r1 = maxR * 0.90;
      tickPaint.strokeWidth = math.max(
        major ? 1.1 : 0.7,
        size.width * (major ? 0.012 : 0.008),
      );
      canvas.drawLine(
        Offset(c.dx + math.cos(a) * r0, c.dy + math.sin(a) * r0),
        Offset(c.dx + math.cos(a) * r1, c.dy + math.sin(a) * r1),
        tickPaint,
      );
    }

    // Cardinal diamonds on the outer rim.
    final diamondPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 4; i++) {
      final a = -math.pi / 2 + i * math.pi / 2;
      final tip = Offset(
        c.dx + math.cos(a) * maxR * 0.98,
        c.dy + math.sin(a) * maxR * 0.98,
      );
      final d = maxR * 0.04;
      final path = Path()
        ..moveTo(tip.dx, tip.dy - d)
        ..lineTo(tip.dx + d * 0.65, tip.dy)
        ..lineTo(tip.dx, tip.dy + d)
        ..lineTo(tip.dx - d * 0.65, tip.dy)
        ..close();
      canvas.drawPath(path, diamondPaint);
    }

    // Small secondary ticks at intercardinals.
    final softDot = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 4; i++) {
      final a = -math.pi / 4 + i * math.pi / 2;
      final p = Offset(
        c.dx + math.cos(a) * maxR * 0.84,
        c.dy + math.sin(a) * maxR * 0.84,
      );
      canvas.drawCircle(p, math.max(1.0, maxR * 0.018), softDot);
    }
  }

  @override
  bool shouldRepaint(covariant CartographerCompassRingsPainter oldDelegate) =>
      oldDelegate.color != color;
}

List<Widget> cartographerPageCorners({
  required Color color,
  double size = 56,
  double opacity = 0.9,
  double inset = 4,
}) {
  Widget corner({
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
      child: CartographerCornerBracket(
        size: size,
        color: color,
        opacity: opacity,
        quarterTurns: turns,
      ),
    );
  }

  return [
    corner(left: inset, top: inset, right: null, bottom: null, turns: 0),
    corner(left: null, top: inset, right: inset, bottom: null, turns: 1),
    corner(left: null, top: null, right: inset, bottom: inset, turns: 2),
    corner(left: inset, top: null, right: null, bottom: inset, turns: 3),
  ];
}
