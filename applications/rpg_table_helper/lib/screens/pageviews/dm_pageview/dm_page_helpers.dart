import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:rpg_table_helper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class DmPageHelpers {
  static Future<String?> askDmForNameOfCampagne(
      {required BuildContext context, String? currentCampagneName}) async {
    var characterNameStat = CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: false,
      statUuid: "00000000-0000-0000-0000-000000000000",
      name: "Name",
      helperText: "Wie soll die Kampagne heißen?",
      valueType: CharacterStatValueType.singleLineText,
      editType: CharacterStatEditType.static,
    );

    var result = await showGetPlayerConfigurationModal(
        context: context,
        statConfiguration: characterNameStat,
        characterToRenderStatFor: null,
        characterName: "Neue Kampagne",
        hideAdditionalSetting: true,
        hideVariantSelection: true,
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
