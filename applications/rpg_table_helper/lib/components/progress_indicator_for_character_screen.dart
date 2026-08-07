import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class ProgressIndicatorForCharacterScreen extends StatelessWidget {
  const ProgressIndicatorForCharacterScreen({
    super.key,
    required this.progressPercentage,
    required this.value,
    required this.maxValue,
    required this.title,
    required this.color,
  });

  final double progressPercentage;
  final int value;
  final int maxValue;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ledger = isArcaneLedgerActive(context);
    return LayoutBuilder(builder: (context, constraints) {
      var width = max(350, min(constraints.maxWidth, constraints.maxHeight)) -
          2.0 * 60.0;
      var strokeWidth = width * (ledger ? .07 : .1);

      var containerWidth = width - 2.5 * strokeWidth;
      var fontSize = containerWidth * 0.2;
      final theme = CustomThemeProvider.of(context).theme;

      if (ledger) {
        return Center(
          child: SizedBox(
            width: width,
            height: width,
            child: CustomPaint(
              painter: _LedgerHpDialPainter(
                progress: progressPercentage.clamp(0.0, 1.0),
                ink: theme.darkColor,
                fill: theme.middleBgColor,
                accent: color,
              ),
              child: Center(
                child: SizedBox(
                  width: containerWidth * 0.72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$value/$maxValue',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: theme.darkTextColor,
                              fontSize: fontSize * 0.95,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Ruwudu',
                              height: 1.0,
                            ),
                      ),
                      const SizedBox(height: 4),
                      AutoSizeText(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        minFontSize: 10,
                        softWrap: true,
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: theme.darkTextColor,
                              fontSize: fontSize * 0.55,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Ruwudu',
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return CustomShadowWidget(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  color: theme.darkColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: containerWidth,
                height: containerWidth,
                child: CircularProgressIndicator(
                  value: progressPercentage,
                  strokeWidth: strokeWidth,
                  color: color,
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(
                width: containerWidth,
                height: containerWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$value/$maxValue',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: theme.textColor,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: strokeWidth * 0.5),
                    AutoSizeText(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      minFontSize: 10,
                      softWrap: true,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: theme.textColor,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Manuscript HP dial: parchment fill, ink double rings, tick marks, green arc.
class _LedgerHpDialPainter extends CustomPainter {
  final double progress;
  final Color ink;
  final Color fill;
  final Color accent;

  _LedgerHpDialPainter({
    required this.progress,
    required this.ink,
    required this.fill,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    canvas.drawCircle(
      c,
      r - 2,
      Paint()
        ..color = fill.withValues(alpha: 0.92)
        ..style = PaintingStyle.fill,
    );

    // Outer double rings
    canvas.drawCircle(
      c,
      r - 3,
      Paint()
        ..color = ink.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    canvas.drawCircle(
      c,
      r - 8,
      Paint()
        ..color = ink.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Compass tick marks
    final tickPaint = Paint()
      ..color = ink.withValues(alpha: 0.45)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 60; i++) {
      final a = -pi / 2 + i * (2 * pi / 60);
      final major = i % 5 == 0;
      final inner = r - (major ? 18 : 12);
      final outer = r - 9;
      canvas.drawLine(
        Offset(c.dx + cos(a) * inner, c.dy + sin(a) * inner),
        Offset(c.dx + cos(a) * outer, c.dy + sin(a) * outer),
        tickPaint..strokeWidth = major ? 1.6 : 1.0,
      );
    }

    // Progress arc
    if (progress > 0) {
      final arcR = r - 22;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: arcR),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LedgerHpDialPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ink != ink ||
      oldDelegate.fill != fill ||
      oldDelegate.accent != accent;
}
