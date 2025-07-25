import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_character_card.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../test_configuration.dart';

void main() {
  group('CustomCharacterCard rendering', () {
    var itemCards = [
      // display placeholder image
      CustomCharacterCard(
        characterName: "Frodo",
        isGreyscale: false,
        imageUrl: null,
        isLoading: false,
        characterSingleNumberStats: [],
        characterStatWithMaxValueForBarVisuals: null,
      ),

      CustomCharacterCard(
        characterName: "Frodo",
        isGreyscale: false,
        isLoading: false,
        characterSingleNumberStats: [],
        characterStatWithMaxValueForBarVisuals: null,
        imageUrl: "assets/images/itemhealingpotion.png",
      ),

      CustomCharacterCard(
        characterName: "Frodo",
        isGreyscale: true,
        imageUrl: null,
        isLoading: false,
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
            hideLabelOfStat: false,
            variant: null,
            statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
            serializedValue: '{"value": 12, "maxValue": 17}',
          )
        ),
      ),

      CustomCharacterCard(
        characterName: "Frodo",
        isGreyscale: true,
        isLoading: false,
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
            hideLabelOfStat: false,
            variant: null,
            statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
            serializedValue: '{"value": 12, "maxValue": 17}',
          )
        ),
        imageUrl: "assets/images/itemhealingpotion.png",
      ),

      CustomCharacterCard(
        characterName: "Frodo",
        isGreyscale: true,
        isLoading: false,
        characterSingleNumberStats: [
          (
            label: "AC",
            value: 12,
          ),
          (
            label: "SP",
            value: 7,
          ),
          (
            label: "Temp HP",
            value: 2,
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
            hideLabelOfStat: false,
            variant: null,
            statUuid: "803f55cb-5d7e-425d-8054-0cb293620481",
            serializedValue: '{"value": 12, "maxValue": 17}',
          )
        ),
        imageUrl: "assets/images/itemhealingpotion.png",
      ),

      CustomCharacterCard(
        characterName: "Frodo",
        isGreyscale: true,
        isLoading: false,
        characterSingleNumberStats: [
          (
            label: "AC",
            value: 12,
          ),
          (
            label: "SP",
            value: 7,
          ),
          (
            label: "Temp HP",
            value: 2,
          ),
          (
            label: "AC",
            value: 12,
          ),
          (
            label: "SP",
            value: 7,
          ),
          (
            label: "Temp HP",
            value: 2,
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
            hideLabelOfStat: false,
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
        screenFactory: (Locale locale, Brightness brightnessToTest) =>
            CustomThemeProvider(
          overrideBrightness: brightnessToTest,
          child: SizedBox(
            width: 300,
            height: 600,
            child: itemcard,
          ),
        ),
        getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
            Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: CustomThemeProvider(
                overrideBrightness: brightness,
                child: Center(
                    child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      itemcard,
                    ],
                  ),
                )),
              ),
            ),
          ),
        ]),
      );
    }
  });
}
