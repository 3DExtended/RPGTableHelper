import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_dropdown_menu.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/components/wizards/wizard_step_save_registry.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/initiative_bonus_resolver.dart';
import 'package:quest_keeper/helpers/initiative_bonus_wizard_draft_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Sample bonus used for the DM-facing preview sentence. Purely illustrative,
/// never persisted.
const _previewSampleBonus = 2;

class RpgConfigurationWizardStep2bFightInitiative extends WizardStepBase {
  const RpgConfigurationWizardStep2bFightInitiative({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
    required super.setWizardTitle,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep2bFightInitiative> createState() =>
      _RpgConfigurationWizardStep2bFightInitiativeState();
}

class _RpgConfigurationWizardStep2bFightInitiativeState
    extends ConsumerState<RpgConfigurationWizardStep2bFightInitiative> {
  bool hasDataLoaded = false;

  List<CharacterStatDefinition> eligibleStats = [];

  String? selectedStatUuid;
  String? selectedListEntryUuid;
  InitiativeBonusField? selectedField;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.setWizardTitle(S.of(context).fightInitiativeStepTitle);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    registerWizardStepSave(_persistToProviderIfReady);
  }

  @override
  void dispose() {
    registerWizardStepSave(null);
    super.dispose();
  }

  /// Called by [WizardManager] before swapping steps (sidebar / flush).
  /// Incomplete selections keep campaign config untouched and stash a draft
  /// so Back → return restores the in-progress pickers.
  void _persistToProviderIfReady() {
    if (!hasDataLoaded) return;
    if (_isIncompleteSelection()) {
      _writeDraft();
      return;
    }
    saveChanges();
    _clearDraft();
  }

  CharacterStatDefinition? _selectedDefinition() {
    if (selectedStatUuid == null) return null;
    return eligibleStats.firstWhereOrNull((s) => s.statUuid == selectedStatUuid);
  }

  bool _isIncompleteSelection() {
    final definition = _selectedDefinition();
    if (definition == null) return false;
    if (!isListInitiativeBonusStatType(definition.valueType)) return false;
    return selectedListEntryUuid == null;
  }

  bool _isSelectionComplete() {
    final definition = _selectedDefinition();
    if (definition == null) return true; // None is a complete choice
    if (!isListInitiativeBonusStatType(definition.valueType)) return true;
    return selectedListEntryUuid != null;
  }

  void _writeDraft() {
    ref.read(initiativeBonusWizardDraftProvider.notifier).state =
        InitiativeBonusWizardDraft(
      selectedStatUuid: selectedStatUuid,
      selectedListEntryUuid: selectedListEntryUuid,
      selectedField: selectedField,
    );
  }

  void _clearDraft() {
    ref.read(initiativeBonusWizardDraftProvider.notifier).state = null;
  }

  void _applyDraft(InitiativeBonusWizardDraft draft) {
    selectedStatUuid = draft.selectedStatUuid;
    selectedListEntryUuid = draft.selectedListEntryUuid;
    selectedField = draft.selectedField;
  }

  /// Loads persisted refs into local UI state, soft-invalidating (showing
  /// None) whenever the stored refs no longer resolve against the current
  /// character-stat definitions. An in-memory draft (from Back) wins.
  void _populateFromConfig(RpgConfigurationModel data) {
    eligibleStats = [
      for (final tab in data.characterStatTabsDefinition ?? const [])
        for (final stat in tab.statsInTab)
          if (eligibleInitiativeBonusStatTypes.contains(stat.valueType)) stat,
    ];

    final draft = ref.read(initiativeBonusWizardDraftProvider);
    if (draft != null) {
      _applyDraft(draft);
      return;
    }

    final statUuid = data.initiativeBonusStatUuid;
    if (statUuid == null || statUuid.isEmpty) {
      _resetSelectionToNone();
      return;
    }

    final definition =
        eligibleStats.firstWhereOrNull((s) => s.statUuid == statUuid);
    if (definition == null) {
      _resetSelectionToNone();
      return;
    }

    if (isListInitiativeBonusStatType(definition.valueType)) {
      final entryUuid = data.initiativeBonusListEntryUuid;
      final entry = entryUuid == null || entryUuid.isEmpty
          ? null
          : initiativeBonusListEntriesFor(definition)
              .firstWhereOrNull((e) => e.uuid == entryUuid);
      if (entry == null) {
        _resetSelectionToNone();
        return;
      }
      selectedListEntryUuid = entry.uuid;
    } else {
      selectedListEntryUuid = null;
    }

    selectedStatUuid = statUuid;
    selectedField = hasFieldPickerForInitiativeBonusStatType(definition.valueType)
        ? (data.initiativeBonusField ??
            defaultInitiativeBonusFieldFor(definition.valueType))
        : null;
  }

  void _resetSelectionToNone() {
    selectedStatUuid = null;
    selectedListEntryUuid = null;
    selectedField = null;
  }

  Future<bool?> _confirmIncompleteLeave() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDecoratedSheetSkinActive(dialogContext)
            ? CustomThemeProvider.of(dialogContext).theme.middleBgColor
            : CustomThemeProvider.of(dialogContext).theme.bgColor,
        title: Text(
          S.of(dialogContext).initiativeBonusIncompleteWarningTitle,
          style: Theme.of(dialogContext).textTheme.titleLarge!.copyWith(
                color:
                    CustomThemeProvider.of(dialogContext).theme.darkTextColor,
              ),
        ),
        content: Text(
          S.of(dialogContext).initiativeBonusIncompleteWarningBody,
          style: Theme.of(dialogContext).textTheme.bodyMedium!.copyWith(
                color:
                    CustomThemeProvider.of(dialogContext).theme.darkTextColor,
              ),
        ),
        actions: [
          TextButton(
            key: const Key('initiativeBonusIncompleteStay'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(S.of(dialogContext).initiativeBonusIncompleteStay),
          ),
          TextButton(
            key: const Key('initiativeBonusIncompleteLeave'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(S.of(dialogContext).initiativeBonusIncompleteLeave),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || hasDataLoaded) return;
          setState(() {
            if (hasDataLoaded) return;
            hasDataLoaded = true;
            _populateFromConfig(data);
          });
        });
      }
    });

    if (!hasDataLoaded) {
      return const SizedBox.shrink();
    }

    final selectedDefinition = _selectedDefinition();
    final showListEntryPicker = selectedDefinition != null &&
        isListInitiativeBonusStatType(selectedDefinition.valueType);
    final showFieldPicker = selectedDefinition != null &&
        hasFieldPickerForInitiativeBonusStatType(selectedDefinition.valueType);
    final listEntries = selectedDefinition == null
        ? const <InitiativeBonusListEntry>[]
        : initiativeBonusListEntriesFor(selectedDefinition);

    final previewHint = _buildPreviewHint(selectedDefinition, listEntries);

    return TwoPartWizardStepBody(
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepHelperText: S.of(context).fightInitiativeStepTutorial,
      onNextBtnPressed: () async {
        if (_isIncompleteSelection()) {
          final leave = await _confirmIncompleteLeave();
          if (!mounted) return;
          if (leave != true) {
            return; // Stay — keep draft in widget state
          }
          _resetSelectionToNone();
          saveChanges();
          _clearDraft();
          widget.onNextBtnPressed();
          return;
        }
        saveChanges();
        _clearDraft();
        widget.onNextBtnPressed();
      },
      onPreviousBtnPressed: () {
        if (_isIncompleteSelection()) {
          _writeDraft();
        } else {
          saveChanges();
          _clearDraft();
        }
        widget.onPreviousBtnPressed();
      },
      sideBarFlex: 1,
      contentFlex: 2,
      contentChildren: [
        CustomDropdownMenu(
          key: const Key('initiativeBonusStatDropdown'),
          label: S.of(context).initiativeBonusStatPickerLabel,
          selectedValueTemp: selectedStatUuid,
          setter: (newValue) {
            setState(() {
              selectedStatUuid = newValue;
              selectedListEntryUuid = null;

              final newDefinition = newValue == null
                  ? null
                  : eligibleStats
                      .firstWhereOrNull((s) => s.statUuid == newValue);
              selectedField = newDefinition != null &&
                      hasFieldPickerForInitiativeBonusStatType(
                          newDefinition.valueType)
                  ? defaultInitiativeBonusFieldFor(newDefinition.valueType)
                  : null;
            });
          },
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(S.of(context).initiativeBonusNoneOption),
            ),
            ...eligibleStats.map(
              (stat) => DropdownMenuItem<String?>(
                value: stat.statUuid,
                child: Text(stat.name),
              ),
            ),
          ],
        ),
        if (showListEntryPicker) ...[
          const SizedBox(height: 15),
          CustomDropdownMenu(
            key: const Key('initiativeBonusListEntryDropdown'),
            label: S.of(context).initiativeBonusListEntryPickerLabel,
            selectedValueTemp: selectedListEntryUuid,
            setter: (newValue) {
              setState(() {
                selectedListEntryUuid = newValue;
              });
            },
            items: listEntries
                .map(
                  (entry) => DropdownMenuItem<String?>(
                    value: entry.uuid,
                    child: Text(entry.label),
                  ),
                )
                .toList(),
          ),
        ],
        if (showFieldPicker) ...[
          const SizedBox(height: 15),
          CustomDropdownMenu(
            key: const Key('initiativeBonusFieldDropdown'),
            label: S.of(context).initiativeBonusFieldPickerLabel,
            selectedValueTemp: selectedField?.name,
            setter: (newValue) {
              setState(() {
                selectedField = InitiativeBonusField.values
                    .firstWhereOrNull((f) => f.name == newValue);
              });
            },
            items: _fieldOptionsFor(selectedDefinition.valueType, context),
          ),
        ],
        if (previewHint != null) ...[
          const SizedBox(height: 25),
          Text(
            S.of(context).preview,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: CustomThemeProvider.of(context).theme.darkTextColor,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            S.of(context).initiativeBonusHelperSentence(
                  previewHint.label,
                  formatInitiativeBonus(previewHint.bonus),
                ),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: CustomThemeProvider.of(context).theme.darkTextColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  /// Only shown once the selection resolves to a concrete label; hidden for
  /// None and for incomplete list selections.
  InitiativeBonusHint? _buildPreviewHint(
    CharacterStatDefinition? definition,
    List<InitiativeBonusListEntry> listEntries,
  ) {
    if (definition == null) return null;

    if (isListInitiativeBonusStatType(definition.valueType)) {
      if (selectedListEntryUuid == null) return null;
      final entry =
          listEntries.firstWhereOrNull((e) => e.uuid == selectedListEntryUuid);
      if (entry == null || entry.label.isEmpty) return null;
      return InitiativeBonusHint(label: entry.label, bonus: _previewSampleBonus);
    }

    return InitiativeBonusHint(
        label: definition.name, bonus: _previewSampleBonus);
  }

  void saveChanges() {
    final notifier = ref.read(rpgConfigurationProvider.notifier);
    final current = ref.read(rpgConfigurationProvider).valueOrNull ??
        RpgConfigurationModel.getBaseConfiguration();

    if (!_isSelectionComplete() || selectedStatUuid == null) {
      notifier.updateConfiguration(
        current
            .copyWith
            .initiativeBonusStatUuid(null)
            .copyWith
            .initiativeBonusListEntryUuid(null)
            .copyWith
            .initiativeBonusField(null),
      );
      return;
    }

    final definition = _selectedDefinition();
    if (definition == null) {
      notifier.updateConfiguration(
        current
            .copyWith
            .initiativeBonusStatUuid(null)
            .copyWith
            .initiativeBonusListEntryUuid(null)
            .copyWith
            .initiativeBonusField(null),
      );
      return;
    }

    final isListType = isListInitiativeBonusStatType(definition.valueType);
    final field = hasFieldPickerForInitiativeBonusStatType(definition.valueType)
        ? (selectedField ?? defaultInitiativeBonusFieldFor(definition.valueType))
        : InitiativeBonusField.value;

    notifier.updateConfiguration(current.copyWith(
      initiativeBonusStatUuid: selectedStatUuid,
      initiativeBonusListEntryUuid: isListType ? selectedListEntryUuid : null,
      initiativeBonusField: field,
    ));
  }

  List<DropdownMenuItem<String?>> _fieldOptionsFor(
    CharacterStatValueType type,
    BuildContext context,
  ) {
    if (type == CharacterStatValueType.intWithMaxValue) {
      return [
        DropdownMenuItem<String?>(
          value: InitiativeBonusField.value.name,
          child: Text(S.of(context).currentValue),
        ),
        DropdownMenuItem<String?>(
          value: InitiativeBonusField.maxValue.name,
          child: Text(S.of(context).maxValue),
        ),
      ];
    }

    return [
      DropdownMenuItem<String?>(
        value: InitiativeBonusField.value.name,
        child: Text(S.of(context).firstValue),
      ),
      DropdownMenuItem<String?>(
        value: InitiativeBonusField.otherValue.name,
        child: Text(S.of(context).calculatedValue),
      ),
    ];
  }
}
