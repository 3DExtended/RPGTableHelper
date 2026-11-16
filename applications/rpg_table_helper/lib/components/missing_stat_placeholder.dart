import 'package:flutter/material.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Stands in on the character sheet for a property the player has not
/// filled in yet ("Später ausfüllen" in the character form, or a property
/// the game master added later). Tapping it opens the input for it.
class MissingStatPlaceholder extends StatelessWidget {
  const MissingStatPlaceholder({
    super.key,
    required this.statName,
    required this.onTap,
  });

  final String statName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final ink = theme.darkTextColor;

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ink.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statName.trim().isEmpty
                          ? S.of(context).missingStatUnnamed
                          : statName,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      S.of(context).missingStatTapToFill,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: ink.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, color: ink.withValues(alpha: 0.75)),
            ],
          ),
        ),
      ),
    );
  }
}
