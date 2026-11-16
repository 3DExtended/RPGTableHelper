import 'package:flutter/material.dart';
import 'package:quest_keeper/components/stat_types/stat_type_title.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// One choice of a list in the character form (class, background, skill,
/// spell, ...): a card with the name and what it means. Long descriptions
/// show their start and open with "Mehr".
class OptionCard extends StatefulWidget {
  OptionCard({
    required this.optionUuid,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.multiple,
    required this.onTap,
  }) : super(key: keyFor(optionUuid));

  final String optionUuid;
  final String label;
  final String description;
  final bool isSelected;

  /// A box to tick (several may be chosen) instead of a radio mark.
  final bool multiple;
  final VoidCallback? onTap;

  /// Longer descriptions are cut to [collapsedLines] until opened.
  static const collapsedLines = 3;
  static const _longDescription = 160;

  static ValueKey<String> keyFor(String optionUuid) =>
      ValueKey('option-card-$optionUuid');

  static ValueKey<String> moreKeyFor(String optionUuid) =>
      ValueKey('option-card-more-$optionUuid');

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final decorated = isDecoratedSheetSkinActive(context);
    final radius = BorderRadius.circular(decorated ? 2 : 8);
    final selected = widget.isSelected;
    final description = widget.description.trim();
    final isLong = description.length > OptionCard._longDescription ||
        '\n'.allMatches(description).length >= OptionCard.collapsedLines;

    return Semantics(
      selected: selected,
      checked: widget.multiple ? selected : null,
      inMutuallyExclusiveGroup: !widget.multiple,
      button: widget.onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: Durations.short3,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: selected
                  ? theme.accentColor.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: radius,
              border: Border.all(
                color: selected
                    ? theme.accentColor
                    : theme.darkTextColor.withValues(alpha: 0.3),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 10),
                  child: _Mark(
                    selected: selected,
                    round: !widget.multiple && !decorated,
                    color: selected ? theme.accentColor : theme.darkColor,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: statTypeBodyStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          description,
                          maxLines: _expanded || !isLong
                              ? null
                              : OptionCard.collapsedLines,
                          overflow: _expanded || !isLong
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: statTypeBodyStyle(
                            context,
                            fontSize: 13,
                            alpha: 0.8,
                          ),
                        ),
                      ],
                      if (isLong)
                        GestureDetector(
                          key: OptionCard.moreKeyFor(widget.optionUuid),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _expanded = !_expanded),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _expanded
                                  ? S.of(context).optionCardLess
                                  : S.of(context).optionCardMore,
                              style: statTypeBodyStyle(
                                context,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ).copyWith(color: theme.accentColor),
                            ),
                          ),
                        ),
                    ],
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

class _Mark extends StatelessWidget {
  const _Mark({
    required this.selected,
    required this.round,
    required this.color,
  });

  final bool selected;
  final bool round;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: round ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: round ? null : BorderRadius.circular(3),
        border: Border.all(color: color, width: 1.6),
      ),
      padding: const EdgeInsets.all(3),
      child: selected
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: round ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: round ? null : BorderRadius.circular(1),
              ),
            )
          : null,
    );
  }
}

/// [cards] below each other on phones, in two columns where there is room.
class OptionCardGrid extends StatelessWidget {
  const OptionCardGrid({super.key, required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 8.0;
      final columns = constraints.maxWidth >= 640 ? 2 : 1;
      final width =
          (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        ),
      );
    });
  }
}
