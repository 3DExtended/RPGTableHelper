import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/modal_content_wrapper.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/sheet_building_blocks.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_template_choice.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// The template properties the game master ticked, in template order; null
/// when cancelled. [existingStats] are on the sheet already and cannot be
/// ticked.
Future<List<CharacterStatDefinition>?> showBuildingBlockPicker({
  required BuildContext context,
  required List<CharacterStatDefinition> existingStats,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) {
  return customShowCupertinoModalBottomSheet<List<CharacterStatDefinition>>(
    isDismissible: true,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    context: context,
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
    overrideNavigatorKey: overrideNavigatorKey,
    builder: (context) => BuildingBlockPicker(
      navigatorKey: overrideNavigatorKey ?? navigatorKey,
      existingStats: existingStats,
    ),
  );
}

class BuildingBlockPicker extends StatefulWidget {
  const BuildingBlockPicker({
    super.key,
    required this.navigatorKey,
    required this.existingStats,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final List<CharacterStatDefinition> existingStats;

  static ValueKey<String> keyFor(String statUuid) =>
      ValueKey('buildingBlock-$statUuid');

  @override
  State<BuildingBlockPicker> createState() => _BuildingBlockPickerState();
}

class _BuildingBlockPickerState extends State<BuildingBlockPicker> {
  final _blocks = sheetBuildingBlocks();
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;

    final children = <Widget>[
      Text(
        s.buildingBlocksHint,
        style: textTheme.bodyMedium!.copyWith(
          color: theme.darkTextColor,
          fontSize: 14,
        ),
      ),
    ];
    RpgConfigurationTemplateId? lastTemplate;
    String? lastTab;
    for (final block in _blocks) {
      if (block.template != lastTemplate) {
        lastTemplate = block.template;
        lastTab = null;
        children.add(Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 4),
          child: Row(
            children: [
              CustomFaIcon(
                icon: rpgTemplateIconOf(block.template),
                size: 18,
                color: theme.accentColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rpgTemplateTitleOf(s, block.template),
                  style: textTheme.titleMedium!.copyWith(
                    color: theme.darkTextColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ));
      }
      if (block.tabName != lastTab) {
        lastTab = block.tabName;
        children.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4, left: 28),
          child: Text(
            s.buildingBlocksTabLabel(block.tabName),
            style: textTheme.labelMedium!.copyWith(
              color: theme.darkTextColor.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ));
      }
      final onSheet = block.isOn(widget.existingStats);
      children.add(_BlockTile(
        key: BuildingBlockPicker.keyFor(block.stat.statUuid),
        title: block.stat.name,
        kind: block.kind(s),
        description: block.stat.helperText,
        isSelected: _selected.contains(block.stat.statUuid),
        disabledReason: onSheet ? s.buildingBlocksAlreadyOnSheet : null,
        onTap: onSheet
            ? null
            : () => setState(() {
                  if (!_selected.remove(block.stat.statUuid)) {
                    _selected.add(block.stat.statUuid);
                  }
                }),
      ));
    }

    return ModalContentWrapper<List<CharacterStatDefinition>>(
      isFullscreen: true,
      title: s.buildingBlocksTitle,
      saveButtonLabel: _selected.isEmpty
          ? s.buildingBlocksAdd
          : s.buildingBlocksAddCount(_selected.length),
      navigatorKey: widget.navigatorKey,
      onCancel: () async {},
      onSave: _selected.isEmpty
          ? null
          : () async => [
                for (final block in _blocks)
                  if (_selected.contains(block.stat.statUuid)) block.stat,
              ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({
    super.key,
    required this.title,
    required this.kind,
    required this.description,
    required this.isSelected,
    required this.disabledReason,
    required this.onTap,
  });

  final String title;
  final String kind;
  final String description;
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
      if (disabledReason != null) disabledReason!,
      if (kind.isNotEmpty) kind,
      if (description.trim().isNotEmpty) description.trim(),
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
