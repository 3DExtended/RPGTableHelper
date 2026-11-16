import 'package:flutter/material.dart';
import 'package:quest_keeper/components/stat_types/stat_type_title.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Stands in for a stat whose type this app version does not know (it was
/// created with a newer version). Shows the name and asks for an update
/// instead of failing the whole sheet.
class UnsupportedStatView extends StatelessWidget {
  const UnsupportedStatView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.darkColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.trim().isNotEmpty) ...[
            StatTypeTitle(title: title),
            const SizedBox(height: 6),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1, right: 8),
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.darkColor,
                ),
              ),
              Expanded(
                child: Text(
                  S.of(context).statTypeUnsupportedHint,
                  style: statTypeBodyStyle(context, fontSize: 14, alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
