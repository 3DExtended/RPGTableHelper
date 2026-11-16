import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/modal_content_wrapper.dart';
import 'package:quest_keeper/components/pick_tile.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/template_update.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_template_choice.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// The uuids of the properties whose change the game master takes over,
/// null when cancelled. Everything is ticked at first.
Future<Set<String>?> showTemplateUpdatePicker({
  required BuildContext context,
  required TemplateUpdate update,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) {
  return customShowCupertinoModalBottomSheet<Set<String>>(
    isDismissible: true,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    context: context,
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
    overrideNavigatorKey: overrideNavigatorKey,
    builder: (context) => TemplateUpdatePicker(
      navigatorKey: overrideNavigatorKey ?? navigatorKey,
      update: update,
    ),
  );
}

/// What changes for [change], in a line.
String describeTemplateStatChange(S s, TemplateStatChange change) {
  if (change.kind == TemplateStatChangeKind.added) {
    return s.templateUpdateAdded(change.templateTabName);
  }
  return [
    if (change.nameChanged) s.templateUpdateNewName(change.updated.name),
    if (change.helperTextChanged) s.templateUpdateNewHelperText,
    if (change.newEntries > 0) s.templateUpdateNewEntries(change.newEntries),
    if (change.entriesRevised) s.templateUpdateEntriesRevised,
    if (change.otherSettingsChanged) s.templateUpdateOtherSettings,
  ].join(' · ');
}

class TemplateUpdatePicker extends StatefulWidget {
  const TemplateUpdatePicker({
    super.key,
    required this.navigatorKey,
    required this.update,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final TemplateUpdate update;

  static ValueKey<String> keyFor(String statUuid) =>
      ValueKey('templateUpdate-$statUuid');

  @override
  State<TemplateUpdatePicker> createState() => _TemplateUpdatePickerState();
}

class _TemplateUpdatePickerState extends State<TemplateUpdatePicker> {
  late final Set<String> _selected = {
    for (final c in widget.update.changes) c.updated.statUuid,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;

    return ModalContentWrapper<Set<String>>(
      isFullscreen: true,
      title: s.templateUpdateTitle,
      saveButtonLabel: _selected.isEmpty
          ? s.templateUpdateApply
          : s.templateUpdateApplyCount(_selected.length),
      navigatorKey: widget.navigatorKey,
      onCancel: () async {},
      onSave: _selected.isEmpty ? null : () async => {..._selected},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomFaIcon(
                icon: rpgTemplateIconOf(widget.update.template),
                size: 18,
                color: theme.accentColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rpgTemplateTitleOf(s, widget.update.template),
                  style: textTheme.titleMedium!.copyWith(
                    color: theme.darkTextColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            s.templateUpdateHint,
            style: textTheme.bodyMedium!.copyWith(
              color: theme.darkTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          for (final change in widget.update.changes)
            PickTile(
              key: TemplateUpdatePicker.keyFor(change.updated.statUuid),
              title: change.current?.name ?? change.updated.name,
              subtitle: describeTemplateStatChange(s, change),
              isSelected: _selected.contains(change.updated.statUuid),
              disabledReason: null,
              onTap: () => setState(() {
                if (!_selected.remove(change.updated.statUuid)) {
                  _selected.add(change.updated.statUuid);
                }
              }),
            ),
        ],
      ),
    );
  }
}

/// The note above the sheet that the template has something new.
class TemplateUpdateBanner extends StatelessWidget {
  const TemplateUpdateBanner({
    super.key,
    required this.update,
    required this.onReview,
    required this.onDismiss,
  });

  final TemplateUpdate update;
  final VoidCallback onReview;
  final VoidCallback onDismiss;

  static const reviewKey = ValueKey('templateUpdateReview');
  static const dismissKey = ValueKey('templateUpdateDismiss');

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.accentColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: CustomFaIcon(
                  icon: FontAwesomeIcons.arrowsRotate,
                  size: 18,
                  color: theme.accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.templateUpdateBannerTitle(
                        rpgTemplateTitleOf(s, update.template),
                      ),
                      style: textTheme.titleSmall!.copyWith(
                        color: theme.darkTextColor,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.templateUpdateBannerText(update.changes.length),
                      style: textTheme.bodySmall!.copyWith(
                        color: theme.darkTextColor.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 4,
            children: [
              CustomButton(
                key: dismissKey,
                isSubbutton: true,
                variant: CustomButtonVariant.FlatButton,
                label: s.templateUpdateDismiss,
                onPressed: onDismiss,
              ),
              CustomButton(
                key: reviewKey,
                isSubbutton: true,
                label: s.templateUpdateReview,
                onPressed: onReview,
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }
}
