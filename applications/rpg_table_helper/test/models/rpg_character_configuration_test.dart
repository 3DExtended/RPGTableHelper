import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';

void main() {
  group('RpgCharacterConfiguration tests', () {
    test('RpgCharacterConfiguration - json serializes correctly', () {
      // arrange
      final model = RpgCharacterConfiguration(
        characterName: "Kardan",
        moneyCoinCount: [10, 11, 12, 13, 14],
        characterStats: [
          RpgCharacterStatValue(
            statUuid: "5251c0bb-02ee-405b-b697-8e6ff0482983",
            serializedValue: '{"value": 24, "maxValue":27}',
          ),
          RpgCharacterStatValue(
            statUuid: "d728a934-6b3d-4548-9fe9-53a42e88712b",
            serializedValue: '{"value": 14}',
          ),
          RpgCharacterStatValue(
            statUuid: "8882935f-a3e8-42b3-9b38-0d87aa71df73",
            serializedValue: '{"value": 7}',
          ),
          RpgCharacterStatValue(
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
      expect(serializedText != null, true);

      // debugLog(serializedText, "uuidErrorCode");
      expect(serializedText,
          '{"characterName":"Kardan","moneyCoinCount":[10,11,12,13,14],"characterStats":[{"statUuid":"5251c0bb-02ee-405b-b697-8e6ff0482983","serializedValue":"{\\"value\\": 24, \\"maxValue\\":27}"},{"statUuid":"d728a934-6b3d-4548-9fe9-53a42e88712b","serializedValue":"{\\"value\\": 14}"},{"statUuid":"8882935f-a3e8-42b3-9b38-0d87aa71df73","serializedValue":"{\\"value\\": 7}"},{"statUuid":"9ff51b8e-59a2-427f-8236-3ab6933ded5b","serializedValue":"{\\"value\\": \\"Barbar\\"}"}],"inventory":[{"itemUuid":"asdf","amount":17}]}');
    });
  });
}
