import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Shared building blocks for new (and reused) player-stat visualization variants.
class StatVizTheme {
  static Color dark(BuildContext c) =>
      CustomThemeProvider.of(c).theme.darkColor;
  static Color bg(BuildContext c) => CustomThemeProvider.of(c).theme.bgColor;
  static Color darkText(BuildContext c) =>
      CustomThemeProvider.of(c).theme.darkTextColor;
  static Color text(BuildContext c) => CustomThemeProvider.of(c).theme.textColor;
  static Color accent(BuildContext c) =>
      CustomThemeProvider.of(c).theme.accentColor;
  static Color lightGreen(BuildContext c) =>
      CustomThemeProvider.of(c).theme.lightGreen;
  static Color lightYellow(BuildContext c) =>
      CustomThemeProvider.of(c).theme.lightYellow;
  static Color lightRed(BuildContext c) =>
      CustomThemeProvider.of(c).theme.lightRed;
  static Color middle(BuildContext c) =>
      CustomThemeProvider.of(c).theme.middleBgColor;
}

Widget statVizPlusMinusRow({
  required BuildContext context,
  required int value,
  required int maxValue,
  required void Function(int) onValueChanged,
  required Widget child,
  bool flat = true,
}) {
  final variant =
      flat ? CustomButtonVariant.FlatButton : CustomButtonVariant.DarkButton;
  final iconColor = flat ? StatVizTheme.dark(context) : StatVizTheme.text(context);
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CustomButton(
        isSubbutton: true,
        variant: variant,
        onPressed: value <= 0
            ? null
            : () => onValueChanged(max(0, value - 1)),
        icon: CustomFaIcon(
          icon: FontAwesomeIcons.minus,
          size: iconSizeInlineButtons,
          color: iconColor,
        ),
      ),
      SizedBox(width: 10),
      child,
      SizedBox(width: 10),
      CustomButton(
        isSubbutton: true,
        variant: variant,
        onPressed: maxValue == value
            ? null
            : () => onValueChanged(min(value + 1, maxValue)),
        icon: CustomFaIcon(
          icon: FontAwesomeIcons.plus,
          size: iconSizeInlineButtons,
          color: iconColor,
        ),
      ),
    ],
  );
}

// --- Resource silhouettes ----------------------------------------------------

class HeartReservoir extends StatelessWidget {
  const HeartReservoir({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
  });

  final int value;
  final int maxValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    final fill = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    final fillColor = fill > 0.5
        ? StatVizTheme.lightRed(context)
        : (fill > 0.15
            ? StatVizTheme.lightYellow(context)
            : StatVizTheme.dark(context));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomShadowWidget(
          child: SizedBox(
            width: 110,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(110, 100),
                  painter: _HeartPainter(
                    outline: StatVizTheme.dark(context),
                    fill: fillColor,
                    fillFraction: fill,
                    empty: StatVizTheme.bg(context),
                  ),
                ),
                Text(
                  '$value/$maxValue',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: StatVizTheme.text(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: StatVizTheme.darkText(context),
                fontSize: 16,
              ),
        ),
      ],
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({
    required this.outline,
    required this.fill,
    required this.fillFraction,
    required this.empty,
  });

  final Color outline;
  final Color fill;
  final double fillFraction;
  final Color empty;

  Path _heart(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w * 0.5, h * 0.28);
    path.cubicTo(w * 0.5, h * 0.08, w * 0.1, h * 0.08, w * 0.1, h * 0.35);
    path.cubicTo(w * 0.1, h * 0.55, w * 0.5, h * 0.78, w * 0.5, h * 0.92);
    path.cubicTo(w * 0.5, h * 0.78, w * 0.9, h * 0.55, w * 0.9, h * 0.35);
    path.cubicTo(w * 0.9, h * 0.08, w * 0.5, h * 0.08, w * 0.5, h * 0.28);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _heart(size);
    canvas.drawPath(path, Paint()..color = empty);
    canvas.save();
    canvas.clipPath(path);
    final fillTop = size.height * (1 - fillFraction);
    canvas.drawRect(
      Rect.fromLTRB(0, fillTop, size.width, size.height),
      Paint()..color = fill,
    );
    canvas.restore();
    canvas.drawPath(
      path,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) =>
      oldDelegate.fillFraction != fillFraction ||
      oldDelegate.fill != fill ||
      oldDelegate.outline != outline;
}

class GemReservoir extends StatelessWidget {
  const GemReservoir({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
  });

  final int value;
  final int maxValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    final fill = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomShadowWidget(
          child: SizedBox(
            width: 90,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(90, 120),
                  painter: _GemPainter(
                    outline: StatVizTheme.dark(context),
                    fill: StatVizTheme.accent(context),
                    fillFraction: fill,
                    empty: StatVizTheme.middle(context),
                  ),
                ),
                Text(
                  '$value/$maxValue',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: StatVizTheme.text(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: StatVizTheme.darkText(context),
                fontSize: 16,
              ),
        ),
      ],
    );
  }
}

class _GemPainter extends CustomPainter {
  _GemPainter({
    required this.outline,
    required this.fill,
    required this.fillFraction,
    required this.empty,
  });

  final Color outline;
  final Color fill;
  final double fillFraction;
  final Color empty;

  Path _gem(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.35)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.35)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _gem(size);
    canvas.drawPath(path, Paint()..color = empty);
    canvas.save();
    canvas.clipPath(path);
    final fillTop = size.height * (1 - fillFraction);
    canvas.drawRect(
      Rect.fromLTRB(0, fillTop, size.width, size.height),
      Paint()..color = fill,
    );
    canvas.restore();
    canvas.drawPath(
      path,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _GemPainter oldDelegate) =>
      oldDelegate.fillFraction != fillFraction;
}

class SegmentedResourceTrack extends StatelessWidget {
  const SegmentedResourceTrack({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
  });

  final int value;
  final int maxValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    final segments = max(1, min(maxValue, 20));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          child: Row(
            children: List.generate(segments, (i) {
              final filled = i < value;
              return Expanded(
                child: Container(
                  height: 28,
                  margin: EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: filled
                        ? StatVizTheme.dark(context)
                        : StatVizTheme.bg(context),
                    border: Border.all(
                      color: StatVizTheme.dark(context),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '$value / $maxValue',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: StatVizTheme.darkText(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: StatVizTheme.darkText(context),
                fontSize: 16,
              ),
        ),
      ],
    );
  }
}

class WoundRings extends StatelessWidget {
  const WoundRings({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
  });

  final int value;
  final int maxValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    final fill = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomShadowWidget(
          child: SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(130, 130),
                  painter: _WoundRingsPainter(
                    fraction: fill,
                    ringColor: StatVizTheme.dark(context),
                    woundColor: StatVizTheme.lightRed(context),
                    bg: StatVizTheme.bg(context),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$value/$maxValue',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: StatVizTheme.darkText(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: StatVizTheme.darkText(context),
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WoundRingsPainter extends CustomPainter {
  _WoundRingsPainter({
    required this.fraction,
    required this.ringColor,
    required this.woundColor,
    required this.bg,
  });

  final double fraction;
  final Color ringColor;
  final Color woundColor;
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2, Paint()..color = bg);
    const rings = 4;
    for (var i = 0; i < rings; i++) {
      final radius = size.width * 0.42 - i * (size.width * 0.08);
      final ringFillThreshold = 1 - (i / rings);
      final isIntact = fraction >= ringFillThreshold - 0.01;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = isIntact ? ringColor : woundColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WoundRingsPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}

class CompactCombatChip extends StatelessWidget {
  const CompactCombatChip({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
  });

  final int value;
  final int maxValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: StatVizTheme.middle(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StatVizTheme.dark(context), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value/$maxValue',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: StatVizTheme.darkText(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
          SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: StatVizTheme.darkText(context),
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }
}

// --- Ability / calculated ----------------------------------------------------

class ModifierFirstBlock extends StatelessWidget {
  const ModifierFirstBlock({
    super.key,
    required this.score,
    required this.modifier,
    required this.label,
    this.width = 90,
  });

  final int score;
  final int modifier;
  final String label;
  final double width;

  String get _modText => modifier >= 0 ? '+$modifier' : '$modifier';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _modText,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: StatVizTheme.darkText(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: StatVizTheme.darkText(context),
                  fontSize: 13,
                ),
          ),
          Text(
            '$score',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: StatVizTheme.darkText(context).withValues(alpha: 0.55),
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }
}

class ClassicAbilityBlock extends StatelessWidget {
  const ClassicAbilityBlock({
    super.key,
    required this.score,
    required this.modifier,
    required this.label,
  });

  final int score;
  final int modifier;
  final String label;

  String get _modText => modifier >= 0 ? '+$modifier' : '$modifier';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: StatVizTheme.darkText(context),
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
          ),
          SizedBox(height: 4),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              border: Border.all(color: StatVizTheme.dark(context), width: 2),
              color: StatVizTheme.bg(context),
            ),
            child: Center(
              child: Text(
                _modText,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: StatVizTheme.darkText(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: StatVizTheme.dark(context),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$score',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: StatVizTheme.text(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HexAbilityTile extends StatelessWidget {
  const HexAbilityTile({
    super.key,
    required this.score,
    required this.modifier,
    required this.label,
  });

  final int score;
  final int modifier;
  final String label;

  String get _modText => modifier >= 0 ? '+$modifier' : '$modifier';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomShadowWidget(
            child: ClipPath(
              clipper: _HexClipper(),
              child: Container(
                width: 84,
                height: 92,
                color: StatVizTheme.dark(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _modText,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: StatVizTheme.text(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                    ),
                    Text(
                      '$score',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: StatVizTheme.text(context)
                                .withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          AutoSizeText(
            label,
            maxLines: 1,
            minFontSize: 10,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: StatVizTheme.darkText(context),
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}

class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class AbilityRadarChart extends StatelessWidget {
  const AbilityRadarChart({
    super.key,
    required this.items,
  });

  final List<({String label, int score, int modifier})> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: _RadarPainter(
              values: items.map((e) => e.score.toDouble()).toList(),
              labels: items.map((e) => e.label).toList(),
              lineColor: StatVizTheme.dark(context),
              fillColor: StatVizTheme.accent(context).withValues(alpha: 0.35),
              labelColor: StatVizTheme.darkText(context),
            ),
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: items
              .map(
                (e) => Text(
                  '${e.label}: ${e.modifier >= 0 ? '+${e.modifier}' : e.modifier} (${e.score})',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: StatVizTheme.darkText(context),
                        fontSize: 12,
                      ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.fillColor,
    required this.labelColor,
  });

  final List<double> values;
  final List<String> labels;
  final Color lineColor;
  final Color fillColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final n = values.length;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.36;
    final maxVal = values.reduce(max).clamp(1.0, double.infinity);

    Offset pointFor(int i, double frac) {
      final angle = -pi / 2 + (2 * pi * i / n);
      return Offset(
        center.dx + cos(angle) * radius * frac,
        center.dy + sin(angle) * radius * frac,
      );
    }

    for (final ring in [0.33, 0.66, 1.0]) {
      final grid = Path();
      for (var i = 0; i < n; i++) {
        final p = pointFor(i, ring);
        if (i == 0) {
          grid.moveTo(p.dx, p.dy);
        } else {
          grid.lineTo(p.dx, p.dy);
        }
      }
      grid.close();
      canvas.drawPath(
        grid,
        Paint()
          ..color = lineColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final data = Path();
    for (var i = 0; i < n; i++) {
      final p = pointFor(i, (values[i] / maxVal).clamp(0.05, 1.0));
      if (i == 0) {
        data.moveTo(p.dx, p.dy);
      } else {
        data.lineTo(p.dx, p.dy);
      }
    }
    data.close();
    canvas.drawPath(data, Paint()..color = fillColor);
    canvas.drawPath(
      data,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < n; i++) {
      final p = pointFor(i, 1.18);
      final short = labels[i].length <= 4
          ? labels[i]
          : labels[i].substring(0, min(3, labels[i].length));
      tp.text = TextSpan(
        text: short,
        style: TextStyle(color: labelColor, fontSize: 11),
      );
      tp.layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}

// --- Icon list variants ------------------------------------------------------

class IconMedallion extends StatelessWidget {
  const IconMedallion({
    super.key,
    required this.iconName,
    required this.label,
    required this.value,
    this.size = 88,
  });

  final String iconName;
  final String label;
  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomShadowWidget(
            child: Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StatVizTheme.dark(context),
                border: Border.all(
                  color: StatVizTheme.accent(context),
                  width: 3,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.25,
                    child: getIconForIdentifier(
                      name: iconName,
                      color: StatVizTheme.text(context),
                      size: size * 0.45,
                    ).$2,
                  ),
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: StatVizTheme.text(context),
                          fontWeight: FontWeight.bold,
                          fontSize: size * 0.28,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: StatVizTheme.darkText(context),
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

class IconStatRibbon extends StatelessWidget {
  const IconStatRibbon({
    super.key,
    required this.items,
  });

  final List<({String iconName, String label, int value})> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: StatVizTheme.middle(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: StatVizTheme.dark(context), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 28,
                margin: EdgeInsets.symmetric(horizontal: 8),
                color: StatVizTheme.dark(context).withValues(alpha: 0.35),
              ),
            getIconForIdentifier(
              name: items[i].iconName,
              color: StatVizTheme.dark(context),
              size: 18,
            ).$2,
            SizedBox(width: 4),
            Text(
              '${items[i].value}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: StatVizTheme.darkText(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class IconPrimaryHeroRow extends StatelessWidget {
  const IconPrimaryHeroRow({
    super.key,
    required this.items,
  });

  final List<({String iconName, String label, int value})> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return SizedBox.shrink();
    final primary = items.first;
    final rest = items.skip(1).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconMedallion(
          iconName: primary.iconName,
          label: primary.label,
          value: primary.value,
          size: 110,
        ),
        SizedBox(width: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: rest
              .map(
                (e) => IconMedallion(
                  iconName: e.iconName,
                  label: e.label,
                  value: e.value,
                  size: 64,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// --- Multiselect variants ----------------------------------------------------

class MultiselectChips extends StatelessWidget {
  const MultiselectChips({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<({String label, String description, int count})> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: StatVizTheme.darkText(context),
                fontSize: 24,
              ),
        ),
        SizedBox(height: 10),
        if (items.where((e) => e.count > 0).isEmpty)
          Text(
            '—',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.grey,
                  fontSize: 16,
                ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.where((e) => e.count > 0).map((e) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: StatVizTheme.dark(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.label,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: StatVizTheme.text(context),
                          fontSize: 14,
                        ),
                  ),
                  if (e.count > 1) ...[
                    SizedBox(width: 6),
                    Icon(Icons.star, size: 14, color: StatVizTheme.accent(context)),
                    Text(
                      '×${e.count}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: StatVizTheme.text(context),
                            fontSize: 12,
                          ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class MultiselectChecklist extends StatelessWidget {
  const MultiselectChecklist({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<({String label, String description, int count})> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: StatVizTheme.darkText(context),
                fontSize: 24,
              ),
        ),
        SizedBox(height: 10),
        LayoutBuilder(builder: (context, constraints) {
          final colWidth = (constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : 320) /
              2;
          return Wrap(
            children: items.map((e) {
              final selected = e.count > 0;
              return SizedBox(
                width: max(140, colWidth),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 6, right: 8),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                        color: StatVizTheme.dark(context),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          e.label,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: StatVizTheme.darkText(context),
                                    fontSize: 14,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class MultiselectTileGrid extends StatelessWidget {
  const MultiselectTileGrid({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<({String label, String description, int count})> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: StatVizTheme.darkText(context),
                fontSize: 24,
              ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((e) {
            final selected = e.count > 0;
            return Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: selected
                    ? StatVizTheme.dark(context)
                    : StatVizTheme.bg(context),
                border: Border.all(
                  color: StatVizTheme.dark(context),
                  width: selected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    e.label,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: selected
                              ? StatVizTheme.text(context)
                              : StatVizTheme.darkText(context)
                                  .withValues(alpha: 0.45),
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class MultiselectGrouped extends StatelessWidget {
  const MultiselectGrouped({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<({String label, String description, int count})> items;

  static final _groupRe = RegExp(r'\(([^)]+)\)\s*$');

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<({String label, String description, int count})>>{};
    for (final item in items) {
      final match = _groupRe.firstMatch(item.label);
      final key = match?.group(1)?.trim() ?? item.label;
      groups.putIfAbsent(key, () => []).add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: StatVizTheme.darkText(context),
                fontSize: 24,
              ),
        ),
        SizedBox(height: 10),
        ...groups.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: StatVizTheme.darkText(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.value.map((e) {
                    final selected = e.count > 0;
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected
                            ? StatVizTheme.dark(context)
                            : Colors.transparent,
                        border: Border.all(color: StatVizTheme.dark(context)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        e.label.replaceAll(_groupRe, '').trim(),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: selected
                                  ? StatVizTheme.text(context)
                                  : StatVizTheme.darkText(context),
                              fontSize: 13,
                            ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// --- Identity ----------------------------------------------------------------

class IdentityBanner extends StatelessWidget {
  const IdentityBanner({
    super.key,
    required this.characterName,
    required this.level,
    required this.details,
    required this.levelAbbr,
  });

  final String characterName;
  final int level;
  final List<({String label, String value})> details;
  final String levelAbbr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: StatVizTheme.middle(context),
        border: Border(
          left: BorderSide(color: StatVizTheme.accent(context), width: 5),
          top: BorderSide(color: StatVizTheme.dark(context), width: 1),
          right: BorderSide(color: StatVizTheme.dark(context), width: 1),
          bottom: BorderSide(color: StatVizTheme.dark(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  characterName,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: StatVizTheme.darkText(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  details.map((d) => d.value).where((v) => v.isNotEmpty).join(' · '),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: StatVizTheme.darkText(context),
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StatVizTheme.dark(context),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$level',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: StatVizTheme.text(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                Text(
                  levelAbbr,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: StatVizTheme.text(context),
                        fontSize: 10,
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

class IdentityPortraitCard extends StatelessWidget {
  const IdentityPortraitCard({
    super.key,
    required this.characterName,
    required this.level,
    required this.details,
    required this.levelAbbr,
    this.imageUrl,
  });

  final String characterName;
  final int level;
  final List<({String label, String value})> details;
  final String levelAbbr;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StatVizTheme.middle(context),
                  border:
                      Border.all(color: StatVizTheme.dark(context), width: 3),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? CustomImage(
                        imageUrl: imageUrl,
                        isGreyscale: false,
                        isLoading: false,
                        aspectRatio: 1,
                      )
                    : Icon(
                        Icons.person,
                        size: 72,
                        color:
                            StatVizTheme.dark(context).withValues(alpha: 0.45),
                      ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StatVizTheme.dark(context),
                  border: Border.all(color: StatVizTheme.bg(context), width: 3),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: StatVizTheme.text(context),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            characterName,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: StatVizTheme.darkText(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
          ),
          Text(
            details.map((d) => '${d.label}: ${d.value}').join(' · '),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: StatVizTheme.darkText(context),
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}

class IdentityMinimalLine extends StatelessWidget {
  const IdentityMinimalLine({
    super.key,
    required this.characterName,
    required this.level,
    required this.details,
    required this.levelAbbr,
  });

  final String characterName;
  final int level;
  final List<({String label, String value})> details;
  final String levelAbbr;

  @override
  Widget build(BuildContext context) {
    final parts = [
      characterName,
      '$levelAbbr $level',
      ...details.map((d) => d.value).where((v) => v.isNotEmpty),
    ];
    return Text(
      parts.join(' · '),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: StatVizTheme.darkText(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

// --- Text / image ------------------------------------------------------------

class CollapsibleLorePanel extends StatefulWidget {
  const CollapsibleLorePanel({
    super.key,
    required this.title,
    required this.body,
    this.hideTitle = false,
  });

  final String title;
  final String body;
  final bool hideTitle;

  @override
  State<CollapsibleLorePanel> createState() => _CollapsibleLorePanelState();
}

class _CollapsibleLorePanelState extends State<CollapsibleLorePanel> {
  // Start expanded so the lore body is visible (needed for review / first paint).
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: StatVizTheme.dark(context),
              ),
              if (!widget.hideTitle)
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: StatVizTheme.darkText(context),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
            ],
          ),
        ),
        if (expanded) ...[
          SizedBox(height: 8),
          CustomMarkdownBody(text: widget.body),
        ],
      ],
    );
  }
}

class ParchmentQuoteFrame extends StatelessWidget {
  const ParchmentQuoteFrame({
    super.key,
    required this.title,
    required this.body,
    this.hideTitle = false,
  });

  final String title;
  final String body;
  final bool hideTitle;

  @override
  Widget build(BuildContext context) {
    // Left accent bar replaces a decorative quote glyph that rendered poorly
    // with the app font (was a large “ character).
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14, 16, 16, 16),
      decoration: BoxDecoration(
        color: StatVizTheme.middle(context),
        border: Border(
          left: BorderSide(color: StatVizTheme.dark(context), width: 4),
          top: BorderSide(color: StatVizTheme.dark(context), width: 1.5),
          right: BorderSide(color: StatVizTheme.dark(context), width: 1.5),
          bottom: BorderSide(color: StatVizTheme.dark(context), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hideTitle) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: StatVizTheme.darkText(context),
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            SizedBox(height: 8),
          ],
          CustomMarkdownBody(text: body),
        ],
      ),
    );
  }
}

class SilhouetteImageFrame extends StatelessWidget {
  const SilhouetteImageFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: StatVizTheme.dark(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: StatVizTheme.middle(context), width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class PolaroidImageFrame extends StatelessWidget {
  const PolaroidImageFrame({
    super.key,
    required this.child,
    this.caption,
  });

  final Widget child;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final shortCaption = caption == null
        ? null
        : (caption!.length > 48 ? '${caption!.substring(0, 48)}…' : caption);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 280, maxWidth: 280),
            child: child,
          ),
          if (shortCaption != null && shortCaption.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              shortCaption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.black87,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class FullBleedImageTile extends StatelessWidget {
  const FullBleedImageTile({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: child,
    );
  }
}

class LargeNumeralTile extends StatelessWidget {
  const LargeNumeralTile({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: StatVizTheme.dark(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: StatVizTheme.text(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: StatVizTheme.text(context),
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}

class CompanionMiniCard extends StatelessWidget {
  const CompanionMiniCard({
    super.key,
    required this.name,
    required this.onTap,
  });

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 110,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: StatVizTheme.middle(context),
          border: Border.all(color: StatVizTheme.dark(context), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StatVizTheme.dark(context),
              ),
              child: Icon(
                Icons.pets,
                color: StatVizTheme.text(context),
                size: 28,
              ),
            ),
            SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: StatVizTheme.darkText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveFormBanner extends StatelessWidget {
  const ActiveFormBanner({
    super.key,
    required this.transformButton,
  });

  final Widget transformButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StatVizTheme.accent(context).withValues(alpha: 0.2),
        border: Border.all(color: StatVizTheme.accent(context), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: StatVizTheme.dark(context)),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Alternate form',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: StatVizTheme.darkText(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          transformButton,
        ],
      ),
    );
  }
}
