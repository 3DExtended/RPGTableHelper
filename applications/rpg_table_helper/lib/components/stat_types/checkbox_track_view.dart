import 'package:flutter/material.dart';
import 'package:quest_keeper/components/stat_types/stat_type_title.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// A row of boxes (e.g. stress) the player ticks with one tap, no dialog.
///
/// Used on the sheet and in the character form. Boxes wrap onto further
/// lines when the column is narrow. Without [onToggle] the boxes are shown
/// read-only.
class CheckboxTrackView extends StatelessWidget {
  const CheckboxTrackView({
    super.key,
    required this.title,
    required this.config,
    required this.checked,
    required this.onToggle,
    this.hideTitle = false,
  });

  final String title;
  final bool hideTitle;
  final CheckboxTrackConfig config;

  /// 0-based indices of the ticked boxes.
  final Set<int> checked;

  /// Called with the index of the tapped box.
  final void Function(int index)? onToggle;

  static ValueKey<String> boxKey(int index) =>
      ValueKey('checkbox-track-box-$index');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!hideTitle && title.trim().isNotEmpty) ...[
          StatTypeTitle(title: title),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(config.boxCount, (index) {
            final label = config.labels[index];
            final isChecked = checked.contains(index);
            return Semantics(
              checked: isChecked,
              button: onToggle != null,
              label: label.isEmpty ? '${index + 1}' : label,
              child: GestureDetector(
                key: boxKey(index),
                behavior: HitTestBehavior.opaque,
                onTap: onToggle == null ? null : () => onToggle!(index),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 44, maxWidth: 76),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TrackBox(isChecked: isChecked),
                        if (label.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: statTypeBodyStyle(
                              context,
                              fontSize: 12,
                              alpha: 0.85,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const StatTypeClosingRule(),
      ],
    );
  }
}

class _TrackBox extends StatelessWidget {
  const _TrackBox({required this.isChecked});

  final bool isChecked;

  static const double size = 32;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    if (isDecoratedSheetSkinActive(context)) {
      // Ink-drawn box with a hand-crossed X (Ledger: brown ink on
      // parchment, Cartographer: gold ink on the night atlas).
      return CustomPaint(
        painter: _InkBoxPainter(ink: theme.darkColor, isChecked: isChecked),
        child: const SizedBox(width: size, height: size),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isChecked ? theme.darkColor : theme.bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.darkColor, width: 2),
      ),
      child: isChecked
          ? Icon(Icons.close, size: 24, color: theme.textColor)
          : null,
    );
  }
}

class _InkBoxPainter extends CustomPainter {
  _InkBoxPainter({required this.ink, required this.isChecked});

  final Color ink;
  final bool isChecked;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = ink.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final inner = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        const Radius.circular(2),
      ),
      outer,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
        const Radius.circular(1.5),
      ),
      inner,
    );
    if (!isChecked) return;
    final cross = Paint()
      ..color = ink.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6;
    const inset = 7.0;
    canvas.drawLine(
      const Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      cross,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      cross,
    );
  }

  @override
  bool shouldRepaint(covariant _InkBoxPainter oldDelegate) =>
      oldDelegate.ink != ink || oldDelegate.isChecked != isChecked;
}
