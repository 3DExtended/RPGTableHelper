import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// A row to tick in a list of choices: box, title and a line of detail.
/// With [disabledReason] it shows a plain check and cannot be ticked.
class PickTile extends StatelessWidget {
  const PickTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.disabledReason,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;

  /// Why it cannot be ticked, or null.
  final String? disabledReason;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;
    final enabled = disabledReason == null;
    final color = enabled
        ? theme.darkTextColor
        : theme.darkTextColor.withValues(alpha: 0.45);
    final subtitle = [
      ?disabledReason,
      if (this.subtitle.trim().isNotEmpty) this.subtitle.trim(),
    ].join(' · ');

    return Semantics(
      checked: isSelected,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: CustomFaIcon(
                      icon: !enabled
                          ? FontAwesomeIcons.check
                          : isSelected
                              ? FontAwesomeIcons.solidSquareCheck
                              : FontAwesomeIcons.square,
                      size: 18,
                      color: isSelected ? theme.accentColor : color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall!.copyWith(
                          color: color,
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall!.copyWith(
                            color: color.withValues(
                                alpha: enabled ? 0.8 : 0.45),
                            fontSize: 13,
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
