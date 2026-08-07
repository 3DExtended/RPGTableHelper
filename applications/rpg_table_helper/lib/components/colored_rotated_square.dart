import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';

class ColoredRotatedSquare extends StatelessWidget {
  const ColoredRotatedSquare({
    super.key,
    required this.isSolidSquare,
    required this.color,
  });

  final bool isSolidSquare;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (isDecoratedSheetSkinActive(context)) {
      final diamondColor =
          isSolidSquare ? ledgerNavbarAccent(context) : color;
      // Mock: tight, delicate diamonds.
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 2.0),
        child: CustomPaint(
          size: const Size(13, 13),
          painter: _LedgerNavDiamondPainter(
            color: diamondColor,
            filled: isSolidSquare,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Transform.rotate(
        alignment: Alignment.center,
        angle: pi / 4,
        child: CustomFaIcon(
          icon: isSolidSquare
              ? FontAwesomeIcons.solidSquare
              : FontAwesomeIcons.square,
          color: color,
        ),
      ),
    );
  }
}

class _LedgerNavDiamondPainter extends CustomPainter {
  final Color color;
  final bool filled;

  _LedgerNavDiamondPainter({required this.color, required this.filled});

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
          ..color = color
          ..style = PaintingStyle.fill,
      );
      // Mock active diamond has a faint darker inset edge (stamped look).
      canvas.drawPath(
        _diamond(c, r - 1.2),
        Paint()
          ..color = const Color(0x55201008)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
    } else {
      canvas.drawPath(
        _diamond(c, r),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.25,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LedgerNavDiamondPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.filled != filled;
}
