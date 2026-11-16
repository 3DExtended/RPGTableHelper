import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Heading of a stat block on the sheet, in the look of the active skin:
/// plain text under Classic, a Ruwudu heading with an ink rule under the
/// decorated skins (Arcane Ledger, Night Cartographer).
class StatTypeTitle extends StatelessWidget {
  const StatTypeTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ink = CustomThemeProvider.of(context).theme.darkTextColor;
    if (!isDecoratedSheetSkinActive(context)) {
      return Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium!
            .copyWith(color: ink, fontSize: 20),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: ink,
            fontSize: 20,
            fontFamily: 'Ruwudu',
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.only(top: 4),
          color: ink.withValues(alpha: 0.55),
        ),
      ],
    );
  }
}

/// The ink rule with a small star that closes a stat block under the
/// decorated skins; nothing under Classic.
class StatTypeClosingRule extends StatelessWidget {
  const StatTypeClosingRule({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isDecoratedSheetSkinActive(context)) return const SizedBox.shrink();
    return CustomPaint(
      painter: _StarRulePainter(
        ink: CustomThemeProvider.of(context).theme.darkColor,
      ),
      child: const SizedBox(width: double.infinity, height: 18),
    );
  }
}

class _StarRulePainter extends CustomPainter {
  _StarRulePainter({required this.ink});

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = ink.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    final midY = size.height / 2;
    canvas.drawLine(Offset(8, midY), Offset(size.width / 2 - 14, midY), line);
    canvas.drawLine(
      Offset(size.width / 2 + 14, midY),
      Offset(size.width - 8, midY),
      line,
    );
    final star = Paint()
      ..color = ink.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final c = Offset(size.width / 2, midY);
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -pi / 2 + i * pi / 4;
      final radius = i.isEven ? 5.0 : 2.0;
      final p = Offset(c.dx + cos(angle) * radius, c.dy + sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, star);
  }

  @override
  bool shouldRepaint(covariant _StarRulePainter oldDelegate) =>
      oldDelegate.ink != ink;
}

/// Body text style of the new stat blocks, matching the skin.
TextStyle statTypeBodyStyle(
  BuildContext context, {
  double fontSize = 16,
  double alpha = 1,
  FontWeight? fontWeight,
}) {
  final decorated = isDecoratedSheetSkinActive(context);
  return Theme.of(context).textTheme.bodyMedium!.copyWith(
    color: CustomThemeProvider.of(context).theme.darkTextColor
        .withValues(alpha: alpha),
    fontSize: fontSize,
    fontFamily: decorated ? 'Ruwudu' : null,
    fontWeight: fontWeight,
    height: 1.3,
  );
}
