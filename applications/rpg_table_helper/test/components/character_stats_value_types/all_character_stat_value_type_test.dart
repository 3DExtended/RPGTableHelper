import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/l10n.dart';
import 'package:rpg_table_helper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:rpg_table_helper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:rpg_table_helper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../../test_configuration.dart';

List<
    (
      String name,
      CharacterStatDefinition def,
      RpgCharacterStatValue playerVal
    )> allConfigurationPairs = [
  (
    "multiLineText, static",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.multiLineText,
      editType: CharacterStatEditType.static,
      name: "Background",
      statUuid: "057ab833-ce74-4feb-9b0d-4f53a83b3c21",
      helperText: "What is your tragic background story?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "057ab833-ce74-4feb-9b0d-4f53a83b3c21",
      serializedValue:
          '{"value": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum.\\nStet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.\\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."}',
    )
  ),
  (
    "singleLineText, static",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.singleLineText,
      editType: CharacterStatEditType.static,
      name: "Charactername",
      statUuid: "1aa3ef8a-6b18-4131-8b43-810dcceba9a5",
      helperText: "What is your name?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "1aa3ef8a-6b18-4131-8b43-810dcceba9a5",
      serializedValue: '{"value": "Peter"}',
    )
  ),
  (
    "multiselect, static", // multiselectIsAllowedToBeSelectedMultipleTimes = false
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.multiselect,
      editType: CharacterStatEditType.static,
      name: "Saving Throws",
      statUuid: "2cd0b55d-d1b4-4817-9a21-1b4a46de0962",
      helperText: "Where is your character proficient?",
      jsonSerializedAdditionalData:
          '{"multiselectIsAllowedToBeSelectedMultipleTimes":false,"options":[{"uuid":"4d07fc3c-daed-4a69-9f5b-76d0bea09059","label": "DEX", "description": "Dexterity"}, {"uuid":"7df3a676-7138-4435-a109-15052405181d","label": "WIS", "description": "Wisdom"}, {"uuid":"10290fd4-3842-49a4-83cb-87939129c44a","label": "INT", "description": "Intelligence"}]}',
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "2cd0b55d-d1b4-4817-9a21-1b4a46de0962",
      serializedValue:
          '{"values": ["4d07fc3c-daed-4a69-9f5b-76d0bea09059", "7df3a676-7138-4435-a109-15052405181d"]}',
    )
  ),
  (
    "int, static",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.int,
      editType: CharacterStatEditType.static,
      name: "Alter",
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      helperText: "How old is your character?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      serializedValue: '{"value": 17}',
    )
  ),
  (
    "intWithMaxValue, static",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.intWithMaxValue,
      editType: CharacterStatEditType.static,
      name: "HP",
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      helperText: "How many health points do you have?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      serializedValue: '{"value": 17, "maxValue": 23}',
    )
  ),
  (
    "intWithCalculatedValue, static",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.intWithCalculatedValue,
      editType: CharacterStatEditType.static,
      name: "Stärke",
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      helperText: "How many health points do you have?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      serializedValue: '{"value": 17, "otherValue": 2}',
    )
  ),
  (
    "singleImage, static",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.singleImage,
      editType: CharacterStatEditType.static,
      name: "Aussehen",
      statUuid: "1b3b65c3-b58f-4b00-8616-c229b103c311",
      helperText: "Wie sieht dein Charakter aus?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "1b3b65c3-b58f-4b00-8616-c229b103c311",
      serializedValue:
          '{"imageUrl":"assets/images/drawffortest.png", "value": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum.\\nStet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.\\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."}',
    ),
  ),
  (
    "listOfIntWithCalculatedValues, static",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.listOfIntWithCalculatedValues,
      editType: CharacterStatEditType.static,
      name: "Skills",
      statUuid: "24ebc00c-7024-485f-8633-9cdc1560543f",
      helperText: "What are your skill values?",
      jsonSerializedAdditionalData:
          '{"values":[{"uuid":"76183b57-d6f3-4414-962c-837488ed0384", "label": "Charisma"}, {"uuid":"529d0912-e1ae-41e2-beea-55bd194bfb20", "label": "Stärke"}, {"uuid":"0f6557a8-c3b6-4832-a673-a8903f87ff24", "label": "Intelligenz"}, {"uuid":"a7aa4151-8c7c-41d4-91d2-2ff0a3d084a4", "label": "Geschicklichkeit"}, {"uuid":"81ffc65e-156a-4042-8bd6-5ed4d400e4bc", "label": "Konstitution"}, {"uuid":"167b94e6-d674-43a4-a25b-fca1309a12b0", "label": "Weisheit"}]}',
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "24ebc00c-7024-485f-8633-9cdc1560543f",
      serializedValue:
          '{"values": [{"value":12, "otherValue": 2, "uuid": "76183b57-d6f3-4414-962c-837488ed0384"},{"value":33, "otherValue": 23, "uuid": "529d0912-e1ae-41e2-beea-55bd194bfb20"},{"value":17, "otherValue": 23, "uuid": "0f6557a8-c3b6-4832-a673-a8903f87ff24"},{"value":17, "otherValue": 23, "uuid": "a7aa4151-8c7c-41d4-91d2-2ff0a3d084a4"},{"value":17, "otherValue": 23, "uuid": "81ffc65e-156a-4042-8bd6-5ed4d400e4bc"},{"value":17, "otherValue": 23, "uuid": "167b94e6-d674-43a4-a25b-fca1309a12b0"}]}',
    )
  ),
  (
    "characterNameWithLevelAndAdditionalDetails, static",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType:
          CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
      editType: CharacterStatEditType.static,
      name: "Charakter Vorstellung",
      statUuid: "24ebc00c-7024-485f-8633-9cdc1560543f",
      helperText: "What are your skill values?",
      jsonSerializedAdditionalData:
          '{"values":[{"uuid":"76183b57-d6f3-4414-962c-837488ed0384", "label": "Volk"}, {"uuid":"529d0912-e1ae-41e2-beea-55bd194bfb20", "label": "Klasse"}]}',
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "24ebc00c-7024-485f-8633-9cdc1560543f",
      serializedValue:
          '{"level": 5, "values": [{"value":"Zwerg", "uuid": "76183b57-d6f3-4414-962c-837488ed0384"}, {"value":"Magier", "uuid": "529d0912-e1ae-41e2-beea-55bd194bfb20"}]}',
    )
  ),
  (
    "listOfIntsWithIcons, static",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.listOfIntsWithIcons,
      editType: CharacterStatEditType.static,
      name: "Charakter Vorstellung",
      statUuid: "24ebc00c-7024-485f-8633-9cdc1560543f",
      helperText: "What are your skill values?",
      jsonSerializedAdditionalData:
          '{"values":[{"uuid":"76183b57-d6f3-4414-962c-837488ed0384", "label": "Volk", "iconName": "backpack-svgrepo-com-2"}, {"uuid":"529d0912-e1ae-41e2-beea-55bd194bfb20", "label": "Klasse", "iconName": "book-open"}, {"uuid":"bcc4995c-2976-4015-b6b8-7a211c69c59a", "label": "Test", "iconName": "shield"},{"uuid":"0499a51e-fab7-4641-9d2b-07a79f55e918", "label": "Test", "iconName": "shield"},{"uuid":"d1c2006a-2d43-4b19-9b75-38577c3c6b58", "label": "Test", "iconName": "shield"},{"uuid":"2eca2a8d-2fa3-4a6a-8145-3db5cb24b0b1", "label": "Test", "iconName": "shield"},{"uuid":"fc671291-fab4-4253-a4c8-c5a66f89f84c", "label": "Test", "iconName": "shield"},{"uuid":"2f744d23-8ff6-4d75-8426-a1ca3e682e7b", "label": "Test", "iconName": "shield"},{"uuid":"a1f6fa06-0b68-4067-8671-ec5c85966828", "label": "Test", "iconName": "shield"}]}',
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "24ebc00c-7024-485f-8633-9cdc1560543f",
      serializedValue:
          '{"values": [{"value":5, "uuid": "76183b57-d6f3-4414-962c-837488ed0384"}, {"value":17, "uuid": "529d0912-e1ae-41e2-beea-55bd194bfb20"}]}',
    )
  ),
  (
    "multiselect, static, multiselectIsAllowedToBeSelectedMultipleTimes", // multiselectIsAllowedToBeSelectedMultipleTimes = true
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.multiselect,
      editType: CharacterStatEditType.static,
      name: "Saving Throws",
      statUuid: "2cd0b55d-d1b4-4817-9a21-1b4a46de0962",
      helperText: "Where is your character proficient?",
      jsonSerializedAdditionalData:
          '{"multiselectIsAllowedToBeSelectedMultipleTimes":true,"options":[{"uuid":"4d07fc3c-daed-4a69-9f5b-76d0bea09059","label": "DEX", "description": "Dexterity"}, {"uuid":"7df3a676-7138-4435-a109-15052405181d","label": "WIS", "description": "Wisdom"}, {"uuid":"10290fd4-3842-49a4-83cb-87939129c44a","label": "INT", "description": "Intelligence"}]}',
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "2cd0b55d-d1b4-4817-9a21-1b4a46de0962",
      serializedValue:
          '{"values": ["4d07fc3c-daed-4a69-9f5b-76d0bea09059","4d07fc3c-daed-4a69-9f5b-76d0bea09059","4d07fc3c-daed-4a69-9f5b-76d0bea09059", "7df3a676-7138-4435-a109-15052405181d"]}',
    )
  ),
  (
    "multiselect, static, migrationcheck", // multiselectIsAllowedToBeSelectedMultipleTimes = false
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.multiselect,
      editType: CharacterStatEditType.static,
      name: "Saving Throws",
      statUuid: "2cd0b55d-d1b4-4817-9a21-1b4a46de0962",
      helperText: "Where is your character proficient?",
      jsonSerializedAdditionalData:
          '[{"uuid":"4d07fc3c-daed-4a69-9f5b-76d0bea09059","label": "DEX", "description": "Dexterity"}, {"uuid":"7df3a676-7138-4435-a109-15052405181d","label": "WIS", "description": "Wisdom"}, {"uuid":"10290fd4-3842-49a4-83cb-87939129c44a","label": "INT", "description": "Intelligence"}]',
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "2cd0b55d-d1b4-4817-9a21-1b4a46de0962",
      serializedValue:
          '{"values": ["4d07fc3c-daed-4a69-9f5b-76d0bea09059", "7df3a676-7138-4435-a109-15052405181d"]}',
    )
  ),
  (
    "intWithMaxValue, fastEdit",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.intWithMaxValue,
      editType: CharacterStatEditType.oneTap,
      name: "HP",
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      helperText: "How many health points do you have?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      serializedValue: '{"value": 17, "maxValue": 23}',
    )
  ),
  (
    "companionSelector, static",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.companionSelector,
      editType: CharacterStatEditType.static,
      name: "HP",
      statUuid: "e60fa814-80ff-4e1a-bb66-10b8a3235c7a",
      helperText: "How many health points do you have?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "e60fa814-80ff-4e1a-bb66-10b8a3235c7a",
      serializedValue:
          '{"values": [{"uuid":"${RpgCharacterConfiguration.getBaseConfiguration(null).companionCharacters!.first.uuid}"}]}',
    )
  ),
  (
    "intWithMaxValue, fastEdit, 40percent",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.intWithMaxValue,
      editType: CharacterStatEditType.oneTap,
      name: "HP",
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      helperText: "How many health points do you have?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      serializedValue: '{"value": 4, "maxValue": 10}',
    )
  ),
  (
    "intWithMaxValue, fastEdit, 10percent",
    CharacterStatDefinition(
      groupId: null,
      isOptionalForAlternateForms: false,
      isOptionalForCompanionCharacters: null,
      valueType: CharacterStatValueType.intWithMaxValue,
      editType: CharacterStatEditType.oneTap,
      name: "HP",
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      helperText: "How many health points do you have?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      hideFromCharacterScreen: false,
      hideLabelOfStat: false,
      variant: null,
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      serializedValue: '{"value": 1, "maxValue": 10}',
    )
  ),
];

void main() {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  group('CharacterStatValueType renderings', () {
    // expand allConfigurationPairs for all viable widget variants
    var enrichedallConfigurationPairs = allConfigurationPairs
        .map((el) {
          var numberOfVariantsForConfig =
              numberOfVariantsForValueTypes(el.$2.valueType);
          return List.generate(
              numberOfVariantsForConfig,
              (index) => (
                    "${el.$1}variant$index",
                    el.$2,
                    el.$3.copyWith(variant: index)
                  ));
        })
        .expand((i) => i)
        .toList();

    for (var testConfiguration in enrichedallConfigurationPairs) {
      testConfigurations(
        disableLocals: false,
        pathPrefix: "../",
        widgetName: 'CharacterStatValueType_DMConfig_${testConfiguration.$1}',
        useMaterialAppWrapper: false,
        testerInteractions: (tester, local) async {
          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();
          await loadAppFonts();
          await loadAppFonts();
          await tester.pumpAndSettle();
          await loadAppFonts();
          await tester.pumpAndSettle();
        },
        screenFactory: (Locale locale) => ProviderScope(
          overrides: [
            rpgCharacterConfigurationProvider.overrideWith((ref) {
              return RpgCharacterConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgCharacterConfiguration.getBaseConfiguration(null),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
            rpgConfigurationProvider.overrideWith((ref) {
              return RpgConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgConfigurationModel.getBaseConfiguration(),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
          ],
          child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate
              ],
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              darkTheme: ThemeData.dark(),
              themeMode: ThemeMode.dark,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                fontFamily: 'Roboto',
                useMaterial3: true,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 16,
                ),
              ),
              home: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Builder(builder: (context) {
                  return ElevatedButton(
                      onPressed: () async {
                        await showGetDmConfigurationModal(
                            context: context,
                            predefinedConfiguration: testConfiguration.$2,
                            overrideNavigatorKey: navigatorKey);
                      },
                      child: const Text("Click me"));
                }),
              )),
        ),
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: widgetToTest,
            ),
          ),
        ]),
      );

      testConfigurations(
        disableLocals: false,
        pathPrefix: "../",
        widgetName:
            'CharacterStatValueType_PlayerConfig_${testConfiguration.$1}',
        useMaterialAppWrapper: false,
        testerInteractions: (tester, local) async {
          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();
          await loadAppFonts();
          await loadAppFonts();
          await tester.pumpAndSettle();
          await loadAppFonts();
          await tester.pumpAndSettle();
        },
        screenFactory: (Locale locale) => ProviderScope(
          overrides: [
            rpgCharacterConfigurationProvider.overrideWith((ref) {
              return RpgCharacterConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgCharacterConfiguration.getBaseConfiguration(null),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
            rpgConfigurationProvider.overrideWith((ref) {
              return RpgConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgConfigurationModel.getBaseConfiguration(),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
          ],
          child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate
              ],
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              darkTheme: ThemeData.dark(),
              themeMode: ThemeMode.dark,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                fontFamily: 'Roboto',
                useMaterial3: true,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 16,
                ),
              ),
              home: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Builder(builder: (context) {
                  return ElevatedButton(
                      onPressed: () async {
                        await showGetPlayerConfigurationModal(
                            characterToRenderStatFor:
                                RpgCharacterConfiguration.getBaseConfiguration(
                                    RpgConfigurationModel
                                        .getBaseConfiguration()),
                            context: context,
                            statConfiguration: testConfiguration.$2,
                            characterValue: testConfiguration.$3,
                            characterName: "Frodo",
                            overrideNavigatorKey: navigatorKey);
                      },
                      child: const Text("Click me"));
                }),
              )),
        ),
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: widgetToTest,
            ),
          ),
        ]),
      );

      testConfigurations(
        disableLocals: false,
        pathPrefix: "../",
        widgetName:
            'CharacterStatValueType_PlayerConfigEmpty_${testConfiguration.$1}',
        useMaterialAppWrapper: false,
        testerInteractions: (tester, local) async {
          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();
          await loadAppFonts();
          await loadAppFonts();
          await tester.pumpAndSettle();
          await loadAppFonts();
          await tester.pumpAndSettle();
        },
        screenFactory: (Locale locale) => ProviderScope(
          overrides: [
            rpgCharacterConfigurationProvider.overrideWith((ref) {
              return RpgCharacterConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgCharacterConfiguration.getBaseConfiguration(null),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
            rpgConfigurationProvider.overrideWith((ref) {
              return RpgConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgConfigurationModel.getBaseConfiguration(),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
          ],
          child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate
              ],
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              darkTheme: ThemeData.dark(),
              themeMode: ThemeMode.dark,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                fontFamily: 'Roboto',
                useMaterial3: true,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 16,
                ),
              ),
              home: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Builder(builder: (context) {
                  return ElevatedButton(
                      onPressed: () async {
                        await showGetPlayerConfigurationModal(
                            characterToRenderStatFor:
                                RpgCharacterConfiguration.getBaseConfiguration(
                                    RpgConfigurationModel
                                        .getBaseConfiguration()),
                            context: context,
                            statConfiguration: testConfiguration.$2,
                            characterValue: null,
                            characterName: "Frodo",
                            overrideNavigatorKey: navigatorKey);
                      },
                      child: const Text("Click me"));
                }),
              )),
        ),
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: widgetToTest,
            ),
          ),
        ]),
      );

      testConfigurations(
        disableLocals: false,
        pathPrefix: "../",
        widgetName:
            'CharacterStatValueType_PlayerStatsScreenWidget_${testConfiguration.$1}',
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => Container(
          color: bgColor,
          child: Builder(builder: (context) {
            return Localizations(
              locale: locale,
              delegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate
              ],
              child: Center(
                child: getPlayerVisualizationWidget(
                  characterToRenderStatFor:
                      RpgCharacterConfiguration.getBaseConfiguration(
                          RpgConfigurationModel.getBaseConfiguration()),
                  context: context,
                  onNewStatValue: (newSerializedValue) {},
                  statConfiguration: testConfiguration.$2,
                  characterValue: testConfiguration.$3,
                  characterName: "Frodo",
                ),
              ),
            );
          }),
        ),
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: widgetToTest,
            ),
          ),
        ]),
      );
    }
  });
}
