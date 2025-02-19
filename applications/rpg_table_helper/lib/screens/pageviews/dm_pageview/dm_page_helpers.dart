import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

class DmPageHelpers {
  static Future<String?> askDmForNameOfCampagne(
      {required BuildContext context, String? currentCampagneName}) async {
    var characterNameStat = CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: false,
      statUuid: "00000000-0000-0000-0000-000000000000",
      name: S.of(context).campaigneName,
      helperText: S.of(context).helperTextForNameOfCampaign,
      valueType: CharacterStatValueType.singleLineText,
      editType: CharacterStatEditType.static,
    );

    var result = await showGetPlayerConfigurationModal(
        context: context,
        statConfiguration: characterNameStat,
        characterToRenderStatFor: null,
        characterName: S.of(context).newCampaign,
        hideAdditionalSetting: true,
        hideVariantSelection: true,
        isEditingAlternateForm: false,
        characterValue: currentCampagneName == null
            ? null
            : RpgCharacterStatValue(
                hideLabelOfStat: false,
                hideFromCharacterScreen: false,
                statUuid: characterNameStat.statUuid,
                serializedValue: '{"value": "$currentCampagneName"}',
                variant: null,
              ));

    if (result == null) return null;
    var parsedValue = jsonDecode(result.serializedValue)["value"];

    return parsedValue;
  }
}
