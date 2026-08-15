import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class PentagonWithLabel extends StatelessWidget {
  const PentagonWithLabel({
    super.key,
    required this.value,
    required this.otherValue,
    required this.label,
  });

  final int value;
  final int otherValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (isNightCartographerActive(context)) {
      return _cartographerHouseStamp(context);
    }
    if (isArcaneLedgerActive(context)) {
      return _ledgerHexStamp(context);
    }
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          CustomShadowWidget(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: _PentagonClipper(),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: CustomThemeProvider.of(context).theme.darkColor,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 18,
                            color:
                                CustomThemeProvider.of(context).theme.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      otherValue.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 14,
                            color:
                                CustomThemeProvider.of(context).theme.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                fontSize: 14,
                color: CustomThemeProvider.of(context).theme.darkTextColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            maxFontSize: 14,
            minFontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Night Cartographer: gold-outline house/pentagon stamp on navy fill.
  Widget _cartographerHouseStamp(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final mod = otherValue >= 0 ? '+$otherValue' : '$otherValue';
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: CustomPaint(
              painter: _CartographerHouseStampPainter(
                fill: theme.bgColor,
                gold: theme.accentColor,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 22,
                            color: theme.darkTextColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Ruwudu',
                            height: 1.0,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mod,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 13,
                            color: theme.darkTextColor.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Ruwudu',
                            height: 1.1,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontSize: 12,
                  color: theme.darkTextColor,
                  fontFamily: 'Ruwudu',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            maxFontSize: 12,
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Arcane Ledger: hexagonal manuscript stamp (mock-close).
  Widget _ledgerHexStamp(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final mod = otherValue >= 0 ? '+$otherValue' : '$otherValue';
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: CustomPaint(
              painter: _LedgerHexStampPainter(
                fill: theme.bgColor,
                ink: theme.darkColor,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 22,
                            color: theme.darkTextColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Ruwudu',
                            height: 1.0,
                          ),
                    ),
                    Text(
                      mod,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 13,
                            color: theme.darkTextColor.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Ruwudu',
                            height: 1.1,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontSize: 12,
                  color: theme.darkTextColor,
                  fontFamily: 'Ruwudu',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            maxFontSize: 12,
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PentagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    path.moveTo(width * 0.5, 0);
    path.lineTo(width, height * 0.4);
    path.lineTo(width * 0.8, height);
    path.lineTo(width * 0.2, height);
    path.lineTo(0, height * 0.4);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

Path _housePentagonPath(Size size, {double inset = 0}) {
  final w = size.width;
  final h = size.height;
  final path = Path();
  path.moveTo(w * 0.5, inset);
  path.lineTo(w - inset, h * 0.38);
  path.lineTo(w * 0.82 - inset * 0.3, h - inset);
  path.lineTo(w * 0.18 + inset * 0.3, h - inset);
  path.lineTo(inset, h * 0.38);
  path.close();
  return path;
}

class _CartographerHouseStampPainter extends CustomPainter {
  final Color fill;
  final Color gold;

  _CartographerHouseStampPainter({required this.fill, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _housePentagonPath(size, inset: 2);
    final mid = _housePentagonPath(size, inset: 5.5);
    final inner = _housePentagonPath(size, inset: 9);
    canvas.drawPath(
      outer.shift(const Offset(1.5, 2)),
      Paint()
        ..color = const Color(0x33000000)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      outer,
      Paint()
        ..color = gold.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    canvas.drawPath(
      mid,
      Paint()
        ..color = gold.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawPath(
      inner,
      Paint()
        ..color = gold.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant _CartographerHouseStampPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.gold != gold;
}

class _LedgerHexStampPainter extends CustomPainter {
  final Color fill;
  final Color ink;

  _LedgerHexStampPainter({required this.fill, required this.ink});

  Path _hex(Size size, {double inset = 0}) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) / 2 - inset;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      // Pointy-top hex.
      final angle = -math.pi / 2 + i * math.pi / 3;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _hex(size, inset: 1);
    final mid = _hex(size, inset: 3.5);
    final inner = _hex(size, inset: 6.5);
    // Soft drop shadow
    canvas.drawPath(
      outer.shift(const Offset(1.5, 2)),
      Paint()
        ..color = const Color(0x33000000)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      outer,
      Paint()
        ..color = ink.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    canvas.drawPath(
      mid,
      Paint()
        ..color = ink.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawPath(
      inner,
      Paint()
        ..color = ink.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant _LedgerHexStampPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.ink != ink;
}
