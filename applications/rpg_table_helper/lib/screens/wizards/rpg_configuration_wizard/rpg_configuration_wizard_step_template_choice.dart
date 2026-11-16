import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/initiative_bonus_wizard_draft_provider.dart';
import 'package:quest_keeper/helpers/modals/show_confirm_delete_dialog.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// What the template step remembers while a new campaign is set up: the
/// template picked last and the configuration it gave (name and sheet skin
/// left out), to tell whether the game master changed something since.
class RpgTemplateChoice {
  final String? campagneId;
  final RpgConfigurationTemplateId templateId;
  final String comparableJson;

  const RpgTemplateChoice({
    required this.campagneId,
    required this.templateId,
    required this.comparableJson,
  });
}

/// Survives the step's dispose (next step and back again). Belongs to one
/// campaign; a choice for another campaign is ignored.
final rpgTemplateChoiceProvider = StateProvider<RpgTemplateChoice?>(
  (ref) => null,
);

/// First step for a new campaign: start blank, with Fantasy 5E (SRD) or with
/// the narrative template. Picking one replaces the campaign's configuration
/// (name and sheet skin stay). Only shown right after creating a campaign,
/// never when the wizard edits an existing one.
///
/// The choice is written to [rpgConfigurationProvider] right away and saved
/// like every other change; nothing is left to save when the step is left.
class RpgConfigurationWizardStepTemplateChoice extends WizardStepBase {
  const RpgConfigurationWizardStepTemplateChoice({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    required super.setWizardTitle,
    super.key,
  });

  @override
  ConsumerState<RpgConfigurationWizardStepTemplateChoice> createState() =>
      _RpgConfigurationWizardStepTemplateChoiceState();
}

class _RpgConfigurationWizardStepTemplateChoiceState
    extends ConsumerState<RpgConfigurationWizardStepTemplateChoice> {
  RpgConfigurationTemplateId? _selected;
  bool _loaded = false;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.setWizardTitle(S.of(context).wizardTemplateStepTitle);
    });
  }

  String? _campagneId() =>
      ref.read(connectionDetailsProvider).value?.campagneId;

  void _load(RpgConfigurationModel config) {
    final campagneId = _campagneId();
    var choice = ref.read(rpgTemplateChoiceProvider);
    if (choice == null || choice.campagneId != campagneId) {
      // First visit: the campaign still holds the template it was created
      // with (Fantasy 5E (SRD)), so that one is preselected.
      choice = RpgTemplateChoice(
        campagneId: campagneId,
        templateId:
            RpgConfigurationTemplates.matchingTemplateOf(config) ??
            RpgConfigurationTemplates.defaultId,
        comparableJson: RpgConfigurationTemplates.comparableJson(config),
      );
      ref.read(rpgTemplateChoiceProvider.notifier).state = choice;
    }
    setState(() {
      _loaded = true;
      _selected = choice!.templateId;
    });
  }

  /// Whether the configuration changed since the last template was picked
  /// (a new name or sheet skin does not count, both are kept).
  bool _changedSinceLastChoice(RpgConfigurationModel current) {
    final choice = ref.read(rpgTemplateChoiceProvider);
    if (choice == null) return true;
    return RpgConfigurationTemplates.comparableJson(current) !=
        choice.comparableJson;
  }

  Future<void> _onTemplateTapped(RpgConfigurationTemplateId id) async {
    if (_asking || !_loaded || id == _selected) return;
    final current = ref.read(rpgConfigurationProvider).value;
    if (current == null) return;

    if (_changedSinceLastChoice(current)) {
      _asking = true;
      final s = S.of(context);
      final confirmed = await showConfirmDeleteDialog(
        context: context,
        title: s.wizardTemplateReplaceTitle,
        message: s.wizardTemplateReplaceMessage,
        confirmLabel: s.wizardTemplateReplaceConfirm,
      );
      _asking = false;
      if (!confirmed || !mounted) return;
    }
    _apply(id);
  }

  void _apply(RpgConfigurationTemplateId id) {
    final current = ref.read(rpgConfigurationProvider).requireValue;
    final next = RpgConfigurationTemplates.applyTo(id, current);
    ref.read(rpgConfigurationProvider.notifier).updateConfiguration(next);
    // A half-picked initiative stat belongs to the old configuration.
    ref.read(initiativeBonusWizardDraftProvider.notifier).state = null;
    ref.read(rpgTemplateChoiceProvider.notifier).state = RpgTemplateChoice(
      campagneId: _campagneId(),
      templateId: id,
      comparableJson: RpgConfigurationTemplates.comparableJson(next),
    );
    setState(() => _selected = id);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!_loaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _loaded) return;
          _load(data);
        });
      }
    });

    final s = S.of(context);

    return TwoPartWizardStepBody(
      isLandscapeMode:
          MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepHelperText: s.wizardTemplateStepHelper,
      onPreviousBtnPressed: widget.onPreviousBtnPressed,
      onNextBtnPressed: _selected == null ? null : widget.onNextBtnPressed,
      sideBarFlex: 1,
      contentFlex: 2,
      contentChildren: [
        for (final id in RpgConfigurationTemplates.ids)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RpgTemplateCard(
              key: RpgTemplateCard.keyFor(id),
              icon: _iconOf(id),
              title: _titleOf(s, id),
              description: _descriptionOf(s, id),
              contents: _contentsOf(s, id),
              isSelected: id == _selected,
              onTap: () => _onTemplateTapped(id),
            ),
          ),
      ],
    );
  }

  static FaIconData _iconOf(RpgConfigurationTemplateId id) => switch (id) {
    RpgConfigurationTemplateId.empty => FontAwesomeIcons.file,
    RpgConfigurationTemplateId.fantasySrd => FontAwesomeIcons.dragon,
    RpgConfigurationTemplateId.narrative => FontAwesomeIcons.featherPointed,
  };

  static String _titleOf(S s, RpgConfigurationTemplateId id) => switch (id) {
    RpgConfigurationTemplateId.empty => s.wizardTemplateEmptyName,
    RpgConfigurationTemplateId.fantasySrd => s.wizardTemplateFantasyName,
    RpgConfigurationTemplateId.narrative => s.wizardTemplateNarrativeName,
  };

  static String _descriptionOf(S s, RpgConfigurationTemplateId id) =>
      switch (id) {
        RpgConfigurationTemplateId.empty => s.wizardTemplateEmptyDescription,
        RpgConfigurationTemplateId.fantasySrd =>
          s.wizardTemplateFantasyDescription,
        RpgConfigurationTemplateId.narrative =>
          s.wizardTemplateNarrativeDescription,
      };

  static String _contentsOf(S s, RpgConfigurationTemplateId id) => switch (id) {
    RpgConfigurationTemplateId.empty => s.wizardTemplateEmptyContents,
    RpgConfigurationTemplateId.fantasySrd => s.wizardTemplateFantasyContents,
    RpgConfigurationTemplateId.narrative => s.wizardTemplateNarrativeContents,
  };
}

/// One selectable template: icon, name, one sentence and what it includes.
/// Square corners and Ruwudu headings under the decorated skins, rounded
/// under Classic.
class RpgTemplateCard extends StatelessWidget {
  const RpgTemplateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.contents,
    required this.isSelected,
    required this.onTap,
  });

  final FaIconData icon;
  final String title;
  final String description;
  final String contents;
  final bool isSelected;
  final VoidCallback onTap;

  static ValueKey<String> keyFor(RpgConfigurationTemplateId id) =>
      ValueKey('wizard-template-${id.name}');

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final decorated = isDecoratedSheetSkinActive(context);
    final ink = theme.darkTextColor;
    final accent = theme.accentColor;
    final radius = BorderRadius.circular(decorated ? 2 : 8);
    final fontFamily = decorated ? 'Ruwudu' : null;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: Durations.short3,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? accent.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: radius,
              border: Border.all(
                color: isSelected ? accent : ink.withValues(alpha: 0.35),
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CustomFaIcon(
                    icon: icon,
                    size: 26,
                    color: isSelected ? accent : ink.withValues(alpha: 0.8),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: textTheme.titleMedium!.copyWith(
                                color: ink,
                                fontSize: decorated ? 20 : 18,
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: _SelectionMark(
                              isSelected: isSelected,
                              decorated: decorated,
                              color: isSelected ? accent : theme.darkColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: textTheme.bodyMedium!.copyWith(
                          color: ink.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontFamily: fontFamily,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${S.of(context).wizardTemplateContentsLabel}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: contents),
                          ],
                        ),
                        style: textTheme.bodySmall!.copyWith(
                          color: ink.withValues(alpha: 0.72),
                          fontSize: 13,
                          fontFamily: fontFamily,
                          height: 1.3,
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

/// Radio mark: a circle under Classic, an inked square under the decorated
/// skins (like the single select on the sheet).
class _SelectionMark extends StatelessWidget {
  const _SelectionMark({
    required this.isSelected,
    required this.decorated,
    required this.color,
  });

  final bool isSelected;
  final bool decorated;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final shape = decorated ? BoxShape.rectangle : BoxShape.circle;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: decorated ? BorderRadius.circular(2) : null,
        border: Border.all(color: color, width: 1.8),
      ),
      padding: const EdgeInsets.all(3.5),
      child: isSelected
          ? DecoratedBox(
              decoration: BoxDecoration(color: color, shape: shape),
            )
          : null,
    );
  }
}
