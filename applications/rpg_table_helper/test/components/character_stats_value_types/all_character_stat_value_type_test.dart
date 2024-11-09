import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rpg_table_helper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:rpg_table_helper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:rpg_table_helper/helpers/character_stats/show_get_player_configuration_modal.dart';
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
      variant: null,
      statUuid: "1aa3ef8a-6b18-4131-8b43-810dcceba9a5",
      serializedValue: '{"value": "Peter"}',
    )
  ),
  (
    "multiselect, static",
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
      variant: null,
      statUuid: "1b3b65c3-b58f-4b00-8616-c229b103c311",
      serializedValue:
          '{"imageUrl":"assets/images/drawffortest.png", "value": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum.\\nStet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.\\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."}',
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
        disableLocals: true,
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
        screenFactory: (Locale locale) => MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
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
        disableLocals: true,
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
        screenFactory: (Locale locale) => MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
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
                          context: context,
                          statConfiguration: testConfiguration.$2,
                          characterValue: testConfiguration.$3,
                          overrideNavigatorKey: navigatorKey);
                    },
                    child: const Text("Click me"));
              }),
            )),
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
        disableLocals: true,
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
        screenFactory: (Locale locale) => MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
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
                          context: context,
                          statConfiguration: testConfiguration.$2,
                          characterValue: null,
                          characterName: "Frodo",
                          overrideNavigatorKey: navigatorKey);
                    },
                    child: const Text("Click me"));
              }),
            )),
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
        disableLocals: true,
        pathPrefix: "../",
        widgetName:
            'CharacterStatValueType_PlayerStatsScreenWidget_${testConfiguration.$1}',
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => Container(
          color: Colors.black,
          child: Builder(builder: (context) {
            return Center(
              child: getPlayerVisualizationWidget(
                context: context,
                statConfiguration: testConfiguration.$2,
                characterValue: testConfiguration.$3,
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
