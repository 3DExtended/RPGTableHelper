import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/newdesign/custom_item_card.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../../test_configuration.dart';

void main() {
  group('CustomCharacterCard rendering', () {
    var itemCards = [
      // display placeholder image
      CustomCharacterCard(
        characterName: "Frodo",
        greyScale: false,
        imageUrl: null,
        isLoadingNewImage: false,
        characterSingleNumberStats: [],
        characterStatWithMaxValueForBarVisuals: null,
      ),

      CustomCharacterCard(
        characterName: "Frodo",
        greyScale: false,
        isLoadingNewImage: false,
        characterSingleNumberStats: [],
        characterStatWithMaxValueForBarVisuals: null,
        imageUrl: "assets/images/itemhealingpotion.png",
      ),

      CustomCharacterCard(
        characterName: "Frodo",
        greyScale: true,
        imageUrl: null,
        isLoadingNewImage: false,
        characterSingleNumberStats: [],
        characterStatWithMaxValueForBarVisuals: (
          CharacterStatDefinition(
              groupId: null,
              isOptionalForAlternateForms: false,
              isOptionalForCompanionCharacters: false,
              statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
              name: "HP",
              helperText: "Lebenspunkte",
              valueType: CharacterStatValueType.intWithMaxValue,
              editType: CharacterStatEditType.oneTap),
          RpgCharacterStatValue(
            hideFromCharacterScreen: false,
            variant: null,
            statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
            serializedValue: '{"value": 12, "maxValue": 17}',
          )
        ),
      ),

      CustomCharacterCard(
        characterName: "Frodo",
        greyScale: true,
        isLoadingNewImage: false,
        characterSingleNumberStats: [],
        characterStatWithMaxValueForBarVisuals: (
          CharacterStatDefinition(
              groupId: null,
              isOptionalForAlternateForms: false,
              isOptionalForCompanionCharacters: false,
              statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
              name: "HP",
              helperText: "Lebenspunkte",
              valueType: CharacterStatValueType.intWithMaxValue,
              editType: CharacterStatEditType.oneTap),
          RpgCharacterStatValue(
            hideFromCharacterScreen: false,
            variant: null,
            statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
            serializedValue: '{"value": 12, "maxValue": 17}',
          )
        ),
        imageUrl: "assets/images/itemhealingpotion.png",
      ),

      CustomCharacterCard(
        characterName: "Frodo",
        greyScale: true,
        isLoadingNewImage: false,
        characterSingleNumberStats: [
          (
            CharacterStatDefinition(
                groupId: null,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
                statUuid: "4282d516-f806-464f-8888-a1a21dca18f6",
                name: "AC",
                helperText: "Rüstungsklasse",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.oneTap),
            RpgCharacterStatValue(
              hideFromCharacterScreen: false,
              variant: null,
              statUuid: "4282d516-f806-464f-8888-a1a21dca18f6",
              serializedValue: '{"value": 12}',
            )
          ),
          (
            CharacterStatDefinition(
                groupId: null,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
                statUuid: "1d65ffd7-5053-42bd-be81-e97cfd521ec0",
                name: "SP",
                helperText: "Geschwindigkeit",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.oneTap),
            RpgCharacterStatValue(
              hideFromCharacterScreen: false,
              variant: null,
              statUuid: "1d65ffd7-5053-42bd-be81-e97cfd521ec0",
              serializedValue: '{"value": 7}',
            )
          ),
          (
            CharacterStatDefinition(
                groupId: null,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
                statUuid: "874ca279-fdd9-4a03-81b5-4e157d5d4f4d",
                name: "Temp HP",
                helperText: "Temporäre HP",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.oneTap),
            RpgCharacterStatValue(
              hideFromCharacterScreen: false,
              variant: null,
              statUuid: "874ca279-fdd9-4a03-81b5-4e157d5d4f4d",
              serializedValue: '{"value": 2}',
            )
          )
        ],
        characterStatWithMaxValueForBarVisuals: (
          CharacterStatDefinition(
              groupId: null,
              isOptionalForAlternateForms: false,
              isOptionalForCompanionCharacters: false,
              statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
              name: "HP",
              helperText: "Lebenspunkte",
              valueType: CharacterStatValueType.intWithMaxValue,
              editType: CharacterStatEditType.oneTap),
          RpgCharacterStatValue(
            hideFromCharacterScreen: false,
            variant: null,
            statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
            serializedValue: '{"value": 12, "maxValue": 17}',
          )
        ),
        imageUrl: "assets/images/itemhealingpotion.png",
      ),

      CustomCharacterCard(
        characterName: "Frodo",
        greyScale: true,
        isLoadingNewImage: false,
        characterSingleNumberStats: [
          (
            CharacterStatDefinition(
                groupId: null,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
                statUuid: "4282d516-f806-464f-8888-a1a21dca18f6",
                name: "AC",
                helperText: "Rüstungsklasse",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.oneTap),
            RpgCharacterStatValue(
              hideFromCharacterScreen: false,
              variant: null,
              statUuid: "4282d516-f806-464f-8888-a1a21dca18f6",
              serializedValue: '{"value": 12}',
            )
          ),
          (
            CharacterStatDefinition(
                groupId: null,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
                statUuid: "1d65ffd7-5053-42bd-be81-e97cfd521ec0",
                name: "SP",
                helperText: "Geschwindigkeit",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.oneTap),
            RpgCharacterStatValue(
              hideFromCharacterScreen: false,
              variant: null,
              statUuid: "1d65ffd7-5053-42bd-be81-e97cfd521ec0",
              serializedValue: '{"value": 7}',
            )
          ),
          (
            CharacterStatDefinition(
                groupId: null,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
                statUuid: "874ca279-fdd9-4a03-81b5-4e157d5d4f4d",
                name: "Temp HP",
                helperText: "Temporäre HP",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.oneTap),
            RpgCharacterStatValue(
              hideFromCharacterScreen: false,
              variant: null,
              statUuid: "874ca279-fdd9-4a03-81b5-4e157d5d4f4d",
              serializedValue: '{"value": 2}',
            )
          ),
          (
            CharacterStatDefinition(
                groupId: null,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
                statUuid: "4282d516-f806-464f-8888-a1a21dca18f6",
                name: "AC",
                helperText: "Rüstungsklasse",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.oneTap),
            RpgCharacterStatValue(
              hideFromCharacterScreen: false,
              variant: null,
              statUuid: "4282d516-f806-464f-8888-a1a21dca18f6",
              serializedValue: '{"value": 12}',
            )
          ),
          (
            CharacterStatDefinition(
                groupId: null,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
                statUuid: "1d65ffd7-5053-42bd-be81-e97cfd521ec0",
                name: "SP",
                helperText: "Geschwindigkeit",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.oneTap),
            RpgCharacterStatValue(
              hideFromCharacterScreen: false,
              variant: null,
              statUuid: "1d65ffd7-5053-42bd-be81-e97cfd521ec0",
              serializedValue: '{"value": 7}',
            )
          ),
          (
            CharacterStatDefinition(
                groupId: null,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
                statUuid: "874ca279-fdd9-4a03-81b5-4e157d5d4f4d",
                name: "Temp HP",
                helperText: "Temporäre HP",
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.oneTap),
            RpgCharacterStatValue(
              hideFromCharacterScreen: false,
              variant: null,
              statUuid: "874ca279-fdd9-4a03-81b5-4e157d5d4f4d",
              serializedValue: '{"value": 2}',
            )
          ),
        ],
        characterStatWithMaxValueForBarVisuals: (
          CharacterStatDefinition(
              groupId: null,
              isOptionalForAlternateForms: false,
              isOptionalForCompanionCharacters: false,
              statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
              name: "HP",
              helperText: "Lebenspunkte",
              valueType: CharacterStatValueType.intWithMaxValue,
              editType: CharacterStatEditType.oneTap),
          RpgCharacterStatValue(
            hideFromCharacterScreen: false,
            variant: null,
            statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
            serializedValue: '{"value": 12, "maxValue": 17}',
          )
        ),
        imageUrl: "assets/images/itemhealingpotion.png",
      ),
    ];

    for (var i = 0; i < itemCards.length; i++) {
      var itemcard = itemCards[i];
      testConfigurations(
        disableLocals: true,
        widgetName: 'CustomCharacterCard$i',
        pathPrefix: "../",
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => SizedBox(
          width: 300,
          height: 600,
          child: itemcard,
        ),
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  itemcard,
                ],
              )),
            ),
          ),
        ]),
      );
    }
  });
}
