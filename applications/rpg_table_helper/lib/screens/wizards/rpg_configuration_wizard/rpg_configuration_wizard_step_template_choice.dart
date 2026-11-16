import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/initiative_bonus_wizard_draft_provider.dart';
import 'package:quest_keeper/helpers/modals/show_confirm_delete_dialog.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';

/// The icon of template [id], as the template choice shows it.
FaIconData rpgTemplateIconOf(RpgConfigurationTemplateId id) => switch (id) {
  RpgConfigurationTemplateId.empty => FontAwesomeIcons.file,
  RpgConfigurationTemplateId.fantasySrd => FontAwesomeIcons.dragon,
  RpgConfigurationTemplateId.narrative => FontAwesomeIcons.featherPointed,
};

/// The name of template [id], as the template choice shows it.
String rpgTemplateTitleOf(S s, RpgConfigurationTemplateId id) => switch (id) {
  RpgConfigurationTemplateId.empty => s.wizardTemplateEmptyName,
  RpgConfigurationTemplateId.fantasySrd => s.wizardTemplateFantasyName,
  RpgConfigurationTemplateId.narrative => s.wizardTemplateNarrativeName,
};

/// What the template step remembers while a new campaign is set up: the
/// template picked last and the configuration it gave (name and sheet skin
/// left out), to tell whether the game master changed something since.
class RpgTemplateChoice {
  final String? campagneId;

  /// The template picked, or null when [copiedFromCampagneId] is set.
  final RpgConfigurationTemplateId? templateId;

  /// Another campaign of the game master whose configuration was taken over.
  final String? copiedFromCampagneId;
  final String comparableJson;

  const RpgTemplateChoice({
    required this.campagneId,
    required this.templateId,
    required this.comparableJson,
    this.copiedFromCampagneId,
  });
}

/// Another campaign of the game master and its configuration.
typedef OwnCampagneConfiguration = ({
  Campagne campagne,
  RpgConfigurationModel config,
});

/// The game master's campaigns other than [currentCampagneId] that have a
/// configuration to take over, most recently changed first.
List<OwnCampagneConfiguration> ownCampagneConfigurations(
  Iterable<Campagne> campagnes,
  String? currentCampagneId,
) {
  final result = <OwnCampagneConfiguration>[];
  for (final campagne in campagnes) {
    if (campagne.id?.value == currentCampagneId) continue;
    final json = campagne.rpgConfiguration;
    if (json == null || json.trim().isEmpty) continue;
    try {
      result.add((
        campagne: campagne,
        config: RpgConfigurationModel.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        ),
      ));
    } catch (_) {
      // Unreadable: nothing to take over.
    }
  }
  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  result.sort(
    (a, b) => (b.campagne.lastModifiedAt ?? epoch).compareTo(
      a.campagne.lastModifiedAt ?? epoch,
    ),
  );
  return result;
}

/// [source] as the configuration of the campaign [current]: everything but
/// the name. The sheet skin comes along unless [source] has none.
RpgConfigurationModel configurationCopiedFrom(
  RpgConfigurationModel source,
  RpgConfigurationModel current,
) => source.copyWith(
  rpgName: current.rpgName,
  defaultSkinId: source.defaultSkinId ?? current.defaultSkinId,
);

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

  /// Set instead of [_selected] when another campaign was taken over.
  String? _selectedCampagneId;
  List<OwnCampagneConfiguration> _ownCampagnes = const [];
  bool _loaded = false;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.setWizardTitle(S.of(context).wizardTemplateStepTitle);
      _loadOwnCampagnes();
    });
  }

  Future<void> _loadOwnCampagnes() async {
    final IRpgEntityService service;
    try {
      service = DependencyProvider.of(context).getService<IRpgEntityService>();
    } catch (_) {
      return;
    }
    final response = await service.getCampagnesWithPlayerAsDm();
    // Without the list there is just nothing to take over.
    if (!mounted || !response.isSuccessful) return;
    setState(() {
      _ownCampagnes = ownCampagneConfigurations(
        response.result ?? const [],
        _campagneId(),
      );
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
      _selectedCampagneId = choice.copiedFromCampagneId;
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
    if (id == _selected) return;
    if (!await _mayReplace()) return;
    _apply(
      RpgConfigurationTemplates.applyTo(
        id,
        ref.read(rpgConfigurationProvider).requireValue,
      ),
      templateId: id,
    );
  }

  Future<void> _onCampagneTapped(OwnCampagneConfiguration own) async {
    final id = own.campagne.id?.value;
    if (id == null || id == _selectedCampagneId) return;
    if (!await _mayReplace()) return;
    _apply(
      configurationCopiedFrom(
        own.config,
        ref.read(rpgConfigurationProvider).requireValue,
      ),
      copiedFromCampagneId: id,
    );
  }

  /// Whether the configuration may be replaced: right away when nothing
  /// changed since the last choice, else after asking.
  Future<bool> _mayReplace() async {
    if (_asking || !_loaded) return false;
    final current = ref.read(rpgConfigurationProvider).value;
    if (current == null) return false;
    if (!_changedSinceLastChoice(current)) return true;

    _asking = true;
    final s = S.of(context);
    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: s.wizardTemplateReplaceTitle,
      message: s.wizardTemplateReplaceMessage,
      confirmLabel: s.wizardTemplateReplaceConfirm,
    );
    _asking = false;
    return confirmed && mounted;
  }

  void _apply(
    RpgConfigurationModel next, {
    RpgConfigurationTemplateId? templateId,
    String? copiedFromCampagneId,
  }) {
    ref.read(rpgConfigurationProvider.notifier).updateConfiguration(next);
    // A half-picked initiative stat belongs to the old configuration.
    ref.read(initiativeBonusWizardDraftProvider.notifier).state = null;
    ref.read(rpgTemplateChoiceProvider.notifier).state = RpgTemplateChoice(
      campagneId: _campagneId(),
      templateId: templateId,
      copiedFromCampagneId: copiedFromCampagneId,
      comparableJson: RpgConfigurationTemplates.comparableJson(next),
    );
    setState(() {
      _selected = templateId;
      _selectedCampagneId = copiedFromCampagneId;
    });
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
      onNextBtnPressed: _selected == null && _selectedCampagneId == null
          ? null
          : widget.onNextBtnPressed,
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
        if (_ownCampagnes.isNotEmpty) ..._ownCampagneSection(s),
      ],
    );
  }

  List<Widget> _ownCampagneSection(S s) {
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(
          s.wizardTemplateFromCampagneHeader,
          textAlign: TextAlign.start,
          style: textTheme.titleMedium!.copyWith(
            color: theme.darkTextColor,
            fontSize: 20,
          ),
        ),
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          s.wizardTemplateFromCampagneHint,
          style: textTheme.bodyMedium!.copyWith(
            color: theme.darkTextColor.withValues(alpha: 0.85),
            fontSize: 14,
          ),
        ),
      ),
      for (final own in _ownCampagnes)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RpgTemplateCard(
            key: RpgTemplateCard.keyForCampagne(own.campagne.id?.value ?? ''),
            icon: FontAwesomeIcons.copy,
            title: own.campagne.campagneName ?? own.config.rpgName,
            description: s.wizardTemplateFromCampagneDescription(
              [
                for (final tab in own.config.characterStatTabsDefinition ??
                    const <CharacterStatsTabDefinition>[])
                  tab.tabName,
              ].join(', '),
            ),
            contents: [
              s.wizardTemplateFromCampagneProperties(
                StatNumbers.allStats(own.config).length,
              ),
              s.wizardTemplateFromCampagneItems(own.config.allItems.length),
              s.wizardTemplateFromCampagneRecipes(
                own.config.craftingRecipes.length,
              ),
            ].join(', '),
            isSelected: own.campagne.id?.value == _selectedCampagneId,
            onTap: () => _onCampagneTapped(own),
          ),
        ),
    ];
  }

  static FaIconData _iconOf(RpgConfigurationTemplateId id) =>
      rpgTemplateIconOf(id);

  static String _titleOf(S s, RpgConfigurationTemplateId id) =>
      rpgTemplateTitleOf(s, id);

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

  static ValueKey<String> keyForCampagne(String campagneId) =>
      ValueKey('wizard-template-campagne-$campagneId');

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
