import 'package:flutter/material.dart';
import 'package:quest_keeper/components/stat_types/stat_type_title.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/character_stats/multiselect_option_list_text.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// A single select on the sheet.
///
/// With [showAllOptions] false only the chosen option is shown (with its
/// summary or description); with true every option is listed as a radio row
/// and, given [onSelect], a tap picks it (replacing the previous choice).
class SingleSelectView extends StatelessWidget {
  const SingleSelectView({
    super.key,
    required this.title,
    required this.options,
    required this.selectedUuid,
    required this.showAllOptions,
    this.hideTitle = false,
    this.onSelect,
  });

  final String title;
  final bool hideTitle;
  final List<SelectOption> options;
  final String? selectedUuid;
  final bool showAllOptions;
  final void Function(String optionUuid)? onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = options.where((o) => o.uuid == selectedUuid).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!hideTitle && title.trim().isNotEmpty) ...[
          StatTypeTitle(title: title),
          const SizedBox(height: 8),
        ],
        if (showAllOptions)
          ...options.map(
            (option) => SingleSelectOptionTile(
              option: option,
              isSelected: option.uuid == selectedUuid,
              showDescription: option.uuid == selectedUuid,
              onTap: onSelect == null ? null : () => onSelect!(option.uuid),
            ),
          )
        else if (selected == null)
          Text(
            S.of(context).singleSelectNothingChosen,
            style: statTypeBodyStyle(context, fontSize: 15, alpha: 0.5),
          )
        else
          _SelectedOption(option: selected),
        const StatTypeClosingRule(),
      ],
    );
  }
}

class _SelectedOption extends StatelessWidget {
  const _SelectedOption({required this.option});

  final SelectOption option;

  @override
  Widget build(BuildContext context) {
    final text = resolveMultiselectListText(
      summary: option.summary,
      description: option.description,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          option.label,
          style: statTypeBodyStyle(
            context,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: statTypeBodyStyle(context, fontSize: 14, alpha: 0.78),
            ),
          ),
      ],
    );
  }
}

/// One option as a radio row: indicator, label and (optionally) the
/// summary or description. Used on the sheet and in the character form.
class SingleSelectOptionTile extends StatelessWidget {
  const SingleSelectOptionTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.showDescription = true,
    this.showFullDescription = false,
  });

  final SelectOption option;
  final bool isSelected;

  /// Shows the summary (or a short blurb of the description) below the label.
  final bool showDescription;

  /// Shows the whole description instead (character form).
  final bool showFullDescription;
  final VoidCallback? onTap;

  static ValueKey<String> keyFor(String optionUuid) =>
      ValueKey('single-select-option-$optionUuid');

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final decorated = isDecoratedSheetSkinActive(context);
    final text = showFullDescription
        ? option.description.trim()
        : showDescription
        ? resolveMultiselectListText(
            summary: option.summary,
            description: option.description,
          )
        : '';
    return Semantics(
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      button: onTap != null,
      child: GestureDetector(
        key: keyFor(option.uuid),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 10),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: decorated ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: decorated ? BorderRadius.circular(2) : null,
                    border: Border.all(color: theme.darkColor, width: 1.6),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: isSelected
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.darkColor,
                            shape: decorated
                                ? BoxShape.rectangle
                                : BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.label,
                      style: statTypeBodyStyle(
                        context,
                        fontSize: 16,
                        alpha: isSelected ? 1 : 0.8,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    if (text.isNotEmpty)
                      Text(
                        text,
                        style: statTypeBodyStyle(
                          context,
                          fontSize: 13,
                          alpha: 0.72,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
