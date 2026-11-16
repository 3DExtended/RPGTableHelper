import 'package:flutter/material.dart';
import 'package:quest_keeper/components/app_style_dialog.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/stat_types/stat_type_title.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// A text list on the sheet: the fixed slots with their labels (e.g.
/// "Hauptaspekt", "Leicht (2)"), then the player's own entries.
///
/// With [onEditRow] a tap on a row edits it; with [onAddEntry] an "Add
/// entry" action is shown below the rows. Without both it is read-only.
class TextListView extends StatelessWidget {
  const TextListView({
    super.key,
    required this.title,
    required this.rows,
    this.hideTitle = false,
    this.onEditRow,
    this.onAddEntry,
  });

  final String title;
  final bool hideTitle;
  final List<TextListRow> rows;
  final void Function(TextListRow row)? onEditRow;
  final VoidCallback? onAddEntry;

  static ValueKey<String> rowKey(String uuid) =>
      ValueKey('text-list-row-$uuid');
  static const addEntryKey = ValueKey('text-list-add-entry');

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final decorated = isDecoratedSheetSkinActive(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!hideTitle && title.trim().isNotEmpty) ...[
          StatTypeTitle(title: title),
          const SizedBox(height: 8),
        ],
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              S.of(context).textListEmpty,
              style: statTypeBodyStyle(context, fontSize: 15, alpha: 0.5),
            ),
          ),
        ...rows.map((row) {
          final hasValue = row.value.trim().isNotEmpty;
          final slotLabel = row.slotLabel?.trim() ?? '';
          final content = Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!row.isSlot)
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 8),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.darkColor,
                        shape: decorated ? BoxShape.rectangle : BoxShape.circle,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (row.isSlot && slotLabel.isNotEmpty)
                        Text(
                          slotLabel,
                          style: statTypeBodyStyle(
                            context,
                            fontSize: 12,
                            alpha: 0.7,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        hasValue ? row.value : '—',
                        style: statTypeBodyStyle(
                          context,
                          fontSize: 16,
                          alpha: hasValue ? 1 : 0.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          final withRule = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              content,
              // Lined paper: a thin rule under every row.
              Container(
                height: 1,
                color: theme.darkTextColor.withValues(alpha: 0.18),
              ),
            ],
          );
          if (onEditRow == null) return withRule;
          return Semantics(
            button: true,
            child: GestureDetector(
              key: rowKey(row.uuid),
              behavior: HitTestBehavior.opaque,
              onTap: () => onEditRow!(row),
              child: withRule,
            ),
          );
        }),
        if (onAddEntry != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: addEntryKey,
              onPressed: onAddEntry,
              style: TextButton.styleFrom(
                foregroundColor: theme.darkTextColor,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              icon: Icon(Icons.add, size: 18, color: theme.darkColor),
              label: Text(
                S.of(context).textListAddEntry,
                style: statTypeBodyStyle(context, fontSize: 15),
              ),
            ),
          ),
        const StatTypeClosingRule(),
      ],
    );
  }
}

/// Result of [showTextListEntryDialog].
class TextListEntryEdit {
  const TextListEntryEdit.save(this.value) : delete = false;
  const TextListEntryEdit.delete() : value = '', delete = true;

  final String value;
  final bool delete;
}

/// Asks for the text of one text list entry. [canDelete] adds a delete
/// action (own entries only). Returns null when cancelled.
Future<TextListEntryEdit?> showTextListEntryDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String initialValue,
  required bool canDelete,
}) {
  return showDialog<TextListEntryEdit>(
    context: context,
    builder: (_) => _TextListEntryDialog(
      title: title,
      label: label,
      initialValue: initialValue,
      canDelete: canDelete,
    ),
  );
}

class _TextListEntryDialog extends StatefulWidget {
  const _TextListEntryDialog({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.canDelete,
  });

  final String title;
  final String label;
  final String initialValue;
  final bool canDelete;

  @override
  State<_TextListEntryDialog> createState() => _TextListEntryDialogState();
}

class _TextListEntryDialogState extends State<_TextListEntryDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStyleDialog(
      title: widget.title,
      onClose: () => Navigator.of(context).pop(),
      actions: [
        if (widget.canDelete)
          CustomButton(
            variant: CustomButtonVariant.FlatButton,
            label: S.of(context).textListDeleteEntry,
            onPressed: () =>
                Navigator.of(context).pop(const TextListEntryEdit.delete()),
          ),
        CustomButton(
          variant: CustomButtonVariant.FlatButton,
          label: S.of(context).cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        CustomButton(
          variant: CustomButtonVariant.AccentButton,
          label: S.of(context).save,
          onPressed: () =>
              Navigator.of(context)
                  .pop(TextListEntryEdit.save(_controller.text.trim())),
        ),
      ],
      child: CustomTextField(
        labelText: widget.label,
        textEditingController: _controller,
        keyboardType: TextInputType.text,
      ),
    );
  }
}
