import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/character_stats_form_pages.dart';
import 'package:quest_keeper/helpers/character_stats/show_character_stats_form.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

class PlayerPageHelpers {
  static Future<String?> askPlayerForCharacterName(
      {required BuildContext context, String? currentCharacterName}) async {
    var characterNameStat = CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: false,
      statUuid: "00000000-0000-0000-0000-000000000000",
      name: S.of(context).characterName,
      helperText: S.of(context).nameOfCharacterHelperText,
      valueType: CharacterStatValueType.singleLineText,
      editType: CharacterStatEditType.static,
    );

    var result = await showGetPlayerConfigurationModal(
        context: context,
        statConfiguration: characterNameStat,
        hideAdditionalSetting: true,
        hideVariantSelection: true,
        isEditingAlternateForm: false,
        characterToRenderStatFor: null,
        characterName:
            currentCharacterName ?? S.of(context).characterNameDefault,
        characterValue: currentCharacterName == null
            ? null
            : RpgCharacterStatValue(
                hideLabelOfStat: false,
                hideFromCharacterScreen: false,
                statUuid: characterNameStat.statUuid,
                serializedValue: '{"value": "$currentCharacterName"}',
                variant: null,
              ));

    if (result == null) return null;
    var parsedValue = jsonDecode(result.serializedValue)["value"];

    return parsedValue;
  }

  /// Asks the player for character fields.
  ///
  /// - Without filters (first setup, or resuming it): the per-tab form with
  ///   one page per tab that still has fields without a value. Nothing opens
  ///   when nothing is missing.
  /// - [filterTabId] (sheet menu "Configure properties"): the form with every
  ///   field of that tab.
  /// - [filterStatUuid] (long press on a stat): the dialog for that one field.
  static void handlePossiblyMissingCharacterStats({
    required WidgetRef ref,
    required BuildContext context,
    required RpgConfigurationModel rpgConfig,
    required RpgCharacterConfigurationBase selectedCharacter,
    String? filterTabId,
    String? filterStatUuid,
  }) {
    if (DependencyProvider.of(context).isMocked) {
      return;
    }

    Future.delayed(Duration.zero, () async {
      final characterAsync = ref.read(rpgCharacterConfigurationProvider);
      // DM (and other) views use characterConfigurationOverride and may never
      // hydrate rpgCharacterConfigurationProvider — do not crash on loading.
      if (!characterAsync.hasValue) {
        return;
      }
      var tempLoadedCharacterConfig = characterAsync.requireValue;

      var selectedCharacterId = selectedCharacter.uuid;
      var isUpdatingCompanionCharacter =
          (tempLoadedCharacterConfig.companionCharacters ?? [])
              .any((e) => e.uuid == selectedCharacterId);

      var isEditingAlternateForm = tempLoadedCharacterConfig.alternateForm !=
              null &&
          tempLoadedCharacterConfig.alternateForm!.uuid == selectedCharacterId;

      if (!context.mounted) return;

      if (filterStatUuid != null) {
        await _editSingleStat(
          ref: ref,
          context: context,
          rpgConfig: rpgConfig,
          selectedCharacter: selectedCharacter,
          filterTabId: filterTabId,
          filterStatUuid: filterStatUuid,
          isUpdatingCompanionCharacter: isUpdatingCompanionCharacter,
          isEditingAlternateForm: isEditingAlternateForm,
        );
        return;
      }

      final pages = buildCharacterStatsFormPages(
        rpgConfig: rpgConfig,
        character: selectedCharacter,
        isCompanion: isUpdatingCompanionCharacter,
        filterTabId: filterTabId,
      );
      if (pages.isEmpty) return;

      await showCharacterStatsForm(
        context: context,
        pages: pages,
        mode: filterTabId == null
            ? CharacterStatsFormMode.setup
            : CharacterStatsFormMode.editTab,
        characterName: selectedCharacter.characterName,
        initialValues: {
          for (final stat in selectedCharacter.characterStats)
            stat.statUuid: stat,
        },
        characterToRenderStatFor: selectedCharacter is RpgCharacterConfiguration
            ? selectedCharacter
            : null,
        isEditingAlternateForm: isEditingAlternateForm,
        onPersist: (stats, characterName) => persistCharacterStats(
          ref: ref,
          characterId: selectedCharacterId,
          stats: stats,
          characterName: characterName,
        ),
      );
    });
  }

  static Future<void> _editSingleStat({
    required WidgetRef ref,
    required BuildContext context,
    required RpgConfigurationModel rpgConfig,
    required RpgCharacterConfigurationBase selectedCharacter,
    required String? filterTabId,
    required String filterStatUuid,
    required bool isUpdatingCompanionCharacter,
    required bool isEditingAlternateForm,
  }) async {
    final statToFill = (rpgConfig.characterStatTabsDefinition ?? [])
        .where((tab) => filterTabId == null || tab.uuid == filterTabId)
        .expand((tab) => tab.statsInTab)
        .where((s) => s.statUuid == filterStatUuid)
        // Computed stats are never typed in.
        .where((s) => !StatNumbers.isComputed(s))
        // we are not allowing the companionSelector stat on companions
        .where((s) =>
            !isUpdatingCompanionCharacter ||
            s.valueType != CharacterStatValueType.companionSelector)
        .firstOrNull;
    if (statToFill == null) return;

    String? updatedCharacterName = selectedCharacter.characterName;
    if (updatedCharacterName.trim().isEmpty) {
      updatedCharacterName = await askPlayerForCharacterName(
          context: context,
          currentCharacterName: selectedCharacter.characterName);
      if (updatedCharacterName == null) return;
    }
    if (!context.mounted) return;

    final modalResult = await showGetPlayerConfigurationModal(
      characterToRenderStatFor: selectedCharacter is RpgCharacterConfiguration
          ? selectedCharacter
          : null,
      context: context,
      statConfiguration: statToFill,
      characterValue: selectedCharacter.characterStats
          .firstWhereOrNull((s) => s.statUuid == statToFill.statUuid),
      characterName: updatedCharacterName,
      isEditingAlternateForm: isEditingAlternateForm,
    );

    final nameChanged = updatedCharacterName != selectedCharacter.characterName;
    if (modalResult == null && !nameChanged) return;

    persistCharacterStats(
      ref: ref,
      characterId: selectedCharacter.uuid,
      stats: modalResult == null ? const [] : [modalResult],
      characterName: nameChanged ? updatedCharacterName : null,
    );
  }

  /// Merges [stats] (and a new [characterName], if given) into the character
  /// with [characterId]: the player's main character, one of its companions
  /// or its alternate form.
  ///
  /// Reads the newest provider state on every call, so the per-tab form can
  /// store page after page without dropping earlier pages.
  static void persistCharacterStats({
    required WidgetRef ref,
    required String characterId,
    required List<RpgCharacterStatValue> stats,
    String? characterName,
  }) {
    final newestCharacterConfig =
        ref.read(rpgCharacterConfigurationProvider).requireValue;
    final notifier = ref.read(rpgCharacterConfigurationProvider.notifier);

    // Copy before merge — mutating the stored characterStats in place would
    // also mutate the provider's current state list, so updateConfiguration's
    // json-equality guard would skip the notify and ConfigSync would never
    // persist the edit.
    List<RpgCharacterStatValue> merge(List<RpgCharacterStatValue> existing) {
      final merged = List<RpgCharacterStatValue>.from(existing);
      merged.removeWhere(
          (st) => stats.any((upst) => upst.statUuid == st.statUuid));
      merged.addAll(stats);
      return merged;
    }

    if (newestCharacterConfig.uuid == characterId) {
      notifier.updateConfiguration(newestCharacterConfig.copyWith(
        characterName: characterName ?? newestCharacterConfig.characterName,
        characterStats: merge(newestCharacterConfig.characterStats),
      ));
      return;
    }

    final companionCharactersCopy = [
      ...(newestCharacterConfig.companionCharacters ??
          <RpgAlternateCharacterConfiguration>[])
    ];
    final indexOfSelectedCompChar =
        companionCharactersCopy.indexWhere((e) => e.uuid == characterId);
    if (indexOfSelectedCompChar != -1) {
      final companion = companionCharactersCopy[indexOfSelectedCompChar];
      companionCharactersCopy[indexOfSelectedCompChar] = companion.copyWith(
        characterName: characterName ?? companion.characterName,
        characterStats: merge(companion.characterStats),
      );
      notifier.updateConfiguration(newestCharacterConfig.copyWith(
          companionCharacters: companionCharactersCopy));
      return;
    }

    final alternateForm = newestCharacterConfig.alternateForm;
    if (alternateForm != null && alternateForm.uuid == characterId) {
      notifier.updateConfiguration(newestCharacterConfig.copyWith(
        alternateForm: alternateForm.copyWith(
          characterName: characterName ?? alternateForm.characterName,
          characterStats: merge(alternateForm.characterStats),
        ),
      ));
    }
  }
}
