import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rpg_table_helper/helpers/character_stat_edit_types_helper.dart';
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
      valueType: CharacterStatValueType.multiLineText,
      editType: CharacterStatEditType.static,
      name: "Background",
      statUuid: "057ab833-ce74-4feb-9b0d-4f53a83b3c21",
      helperText: "What is your tragic background story?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      statUuid: "057ab833-ce74-4feb-9b0d-4f53a83b3c21",
      serializedValue:
          '{"value": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum.\\nStet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.\\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.\\nAt vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."}',
    )
  ),
  (
    "singleLineText, static",
    CharacterStatDefinition(
      valueType: CharacterStatValueType.singleLineText,
      editType: CharacterStatEditType.static,
      name: "Charactername",
      statUuid: "1aa3ef8a-6b18-4131-8b43-810dcceba9a5",
      helperText: "What is your name?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      statUuid: "1aa3ef8a-6b18-4131-8b43-810dcceba9a5",
      serializedValue: '{"value": "Peter"}',
    )
  ),
  (
    "int, static",
    CharacterStatDefinition(
      valueType: CharacterStatValueType.int,
      editType: CharacterStatEditType.static,
      name: "Alter",
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      helperText: "How old is your character?",
      jsonSerializedAdditionalData: null,
    ),
    RpgCharacterStatValue(
      statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
      serializedValue: '{"value": 17}',
    )
  ),
];

void main() {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  group('CharacterStatValueType renderings', () {
    for (var testConfiguration in allConfigurationPairs) {
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
