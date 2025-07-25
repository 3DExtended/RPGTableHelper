import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';

void main() {
  group('RpgCharacterConfiguration tests', () {
    test('RpgCharacterConfiguration - json serializes correctly', () {
      // arrange
      final model = RpgCharacterConfiguration(
        tabConfigurations: null,
        alternateForm: null,
        isAlternateFormActive: null,
        transformationComponents: null,
        alternateForms: [],
        companionCharacters: [],
        uuid: "06bf8d3b-679b-4820-ad47-c74d8895b5d0",
        characterName: "Kardan",
        moneyInBaseType: 0,
        characterStats: [
          RpgCharacterStatValue(
            hideFromCharacterScreen: false,
            hideLabelOfStat: false,
            variant: null,
            statUuid: "5251c0bb-02ee-405b-b697-8e6ff0482983",
            serializedValue: '{"value": 24, "maxValue":27}',
          ),
          RpgCharacterStatValue(
            hideFromCharacterScreen: false,
            hideLabelOfStat: false,
            variant: null,
            statUuid: "d728a934-6b3d-4548-9fe9-53a42e88712b",
            serializedValue: '{"value": 14}',
          ),
          RpgCharacterStatValue(
            hideFromCharacterScreen: false,
            hideLabelOfStat: false,
            variant: null,
            statUuid: "8882935f-a3e8-42b3-9b38-0d87aa71df73",
            serializedValue: '{"value": 7}',
          ),
          RpgCharacterStatValue(
            hideFromCharacterScreen: false,
            hideLabelOfStat: false,
            variant: null,
            statUuid: "9ff51b8e-59a2-427f-8236-3ab6933ded5b",
            serializedValue: '{"value": "Barbar"}',
          )
        ],
        inventory: [
          RpgCharacterOwnedItemPair(
            itemUuid: "asdf",
            amount: 17,
          )
        ],
      );

      // act
      var serializedText = jsonEncode(model);

      // assert
      expect(serializedText,
          '{"uuid":"06bf8d3b-679b-4820-ad47-c74d8895b5d0","characterName":"Kardan","characterStats":[{"statUuid":"5251c0bb-02ee-405b-b697-8e6ff0482983","serializedValue":"{\\"value\\": 24, \\"maxValue\\":27}","hideFromCharacterScreen":false,"hideLabelOfStat":false,"variant":null,"isCopy":false},{"statUuid":"d728a934-6b3d-4548-9fe9-53a42e88712b","serializedValue":"{\\"value\\": 14}","hideFromCharacterScreen":false,"hideLabelOfStat":false,"variant":null,"isCopy":false},{"statUuid":"8882935f-a3e8-42b3-9b38-0d87aa71df73","serializedValue":"{\\"value\\": 7}","hideFromCharacterScreen":false,"hideLabelOfStat":false,"variant":null,"isCopy":false},{"statUuid":"9ff51b8e-59a2-427f-8236-3ab6933ded5b","serializedValue":"{\\"value\\": \\"Barbar\\"}","hideFromCharacterScreen":false,"hideLabelOfStat":false,"variant":null,"isCopy":false}],"isAlternateFormActive":null,"alternateForm":null,"transformationComponents":null,"moneyInBaseType":0,"tabConfigurations":null,"inventory":[{"itemUuid":"asdf","amount":17}],"companionCharacters":[],"alternateForms":[]}');
    });
  });
}
