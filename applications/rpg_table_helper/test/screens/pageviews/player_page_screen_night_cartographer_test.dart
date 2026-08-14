import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/note_documents_service.dart';

import '../../custom_font_loader.dart';
import '../../test_configuration.dart';

/// Spell tab values matching `night-cartographer-mock-spells.png` for Ledger goldens.
/// Skills (Fertigkeiten) use multiselect variant 1 so the Stats golden shows
/// the full proficiency list, not only selected rows.
RpgCharacterConfiguration _cartographerCharacterWithSpells() {
  final base = RpgCharacterConfiguration.getBaseConfiguration(
    RpgConfigurationModel.getBaseConfiguration(),
    variant: 0,
  );
  return base.copyWith(
    skinId: CharacterSheetSkinIds.nightCartographer,
    characterStats: [
      ...base.characterStats.map((stat) {
        if (stat.statUuid == 'c5ef782a-8d8b-4a88-98b2-be277f741e4c') {
          return stat.copyWith(variant: 1);
        }
        return stat;
      }),
      RpgCharacterStatValue(
        statUuid: '2438aac8-4a67-41ca-aad9-3c838b7c5cf3', // Zauberpunkte
        serializedValue: jsonEncode({'value': 4, 'maxValue': 8}),
        hideFromCharacterScreen: false,
        hideLabelOfStat: false,
        variant: 0,
      ),
      RpgCharacterStatValue(
        statUuid: 'c1b7a131-c239-4d56-8008-b3d4b654189d', // Zaubertricks
        serializedValue: jsonEncode({
          'values': [
            '1e720492-1520-4bf3-86a3-98c4f61be329', // Botschaft
            'bc6ddcc2-ccf5-4a70-9b0f-afbf17c7be47', // Magierhand
            '4ee11bf7-1f97-4209-b2e4-d05346b04ed9', // Flammen erzeugen
          ],
        }),
        hideFromCharacterScreen: false,
        hideLabelOfStat: false,
        variant: 4,
      ),
      RpgCharacterStatValue(
        statUuid: '31a52ed2-3e7b-42ac-8f3e-490b3a04027a', // Zauber 1. Stufe
        serializedValue: jsonEncode({
          'values': [
            'f28e6faa-1cce-4f99-8f4f-30e9b89defd7', // Magisches Geschoss
            'e79adcb9-4d57-45e6-9d05-29aeb2bbfe1a', // Brennende Hände
          ],
        }),
        hideFromCharacterScreen: false,
        hideLabelOfStat: false,
        variant: 4,
      ),
    ],
  );
}

/// iPad-landscape goldens for the Night Cartographer skin (skin-09).
/// English only — Cartographer is a dark night-atlas pack.
void main() {
  const testCases = [
    (0, "playerbackgroundscreen"),
    (1, "playerstatsscreen"),
    (2, "playerfeaturesscreen"),
    (3, "playerattacksscreen"),
    (4, "playerspellsscreen"),
    (5, "playermoneyscreen"),
    (6, "playerinventoryscreen"),
    (7, "playerrecipesscreen"),
    (8, "playerlorescreen"),
  ];

  group('night cartographer playerpagescreens', () {
    final navigatorKey = GlobalKey<NavigatorState>();

    setUp(() {
      MockNoteDocumentService.preferArcaneLedgerLoreFixtures = true;
    });
    tearDown(() {
      MockNoteDocumentService.preferArcaneLedgerLoreFixtures = false;
    });

    for (final testcase in testCases) {
      testConfigurations(
        disableLocals: true,
        disableDarkMode: true,
        pathPrefix: "../",
        overrideSkinId: CharacterSheetSkinIds.nightCartographer,
        // Lore screen also gets an iPad mini pass — its collapsible sidebar
        // is the one place on this screen prone to overflow at narrower
        // tablet widths.
        devices: testcase.$1 == 8
            ? [...testDevicesLedger, ...testDevicesIpadMiniLedger]
            : testDevicesLedger,
        widgetName:
            'night-cartographer-playerpagescreens${testcase.$1}-${testcase.$2}',
        useMaterialAppWrapper: true,
        testerInteractions: (tester, local) async {
          await tester.pumpAndSettle();
          await customLoadAppFonts();
          await customLoadAppFonts();
          await tester.pumpAndSettle();
          await customLoadAppFonts();
          await tester.pumpAndSettle();
        },
        screenFactory: (Locale locale, Brightness brightnessToTest) =>
            ProviderScope(
          overrides: [
            rpgConfigurationProvider.overrideWith((ref) {
              return RpgConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgConfigurationModel.getBaseConfiguration().copyWith(
                    defaultSkinId: CharacterSheetSkinIds.nightCartographer,
                  ),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
            rpgCharacterConfigurationProvider.overrideWith((ref) {
              return RpgCharacterConfigurationNotifier(
                decks: AsyncValue.data(_cartographerCharacterWithSpells()),
                ref: ref,
                runningInTests: true,
              );
            }),
            connectionDetailsProvider.overrideWith((ref) {
              return ConnectionDetailsNotifier(
                initState: AsyncValue.data(
                  ConnectionDetails.defaultValue().copyWith(
                    fightSequence: FightSequence(
                      fightUuid: "f10526be-c69a-46be-8802-df9421e6187b",
                      sequence: [
                        ("575fb9d9-c2a0-47df-bec4-5de1b3d5ca4d", "Frodo", 17),
                        ("0eff8827-14f1-46a1-8695-ef7dc5323137", "Gandalf", 17),
                      ],
                    ),
                    isConnected: true,
                    isConnecting: true,
                    isDm: true,
                    campagneId: "51f263bc-37cf-44d4-90f3-87d656ae29df",
                    isInSession: true,
                    sessionConnectionNumberForPlayers: "123-321",
                    lastGrantedItems: [
                      GrantedItemsForPlayer(
                        characterName: "Frodo",
                        playerId: "fghjkl",
                        grantedItems: [],
                      ),
                      GrantedItemsForPlayer(
                        characterName: "Gandalf",
                        playerId: "ghjiuhjkiujhn",
                        grantedItems: [
                          RpgCharacterOwnedItemPair(
                            itemUuid: RpgConfigurationModel.getBaseConfiguration()
                                .allItems
                                .first
                                .uuid,
                            amount: 2,
                          ),
                          RpgCharacterOwnedItemPair(
                            itemUuid: RpgConfigurationModel.getBaseConfiguration()
                                .allItems[2]
                                .uuid,
                            amount: 12,
                          ),
                        ],
                      ),
                    ],
                    connectedPlayers: [
                      OpenPlayerConnection(
                        lastPing: DateTime(2025, 02, 26, 12, 00),
                        userId: UserIdentifier(
                          $value: "9a709402-5620-479c-85b7-718ae01e0a83",
                        ),
                        playerCharacterId: PlayerCharacterIdentifier(
                          $value: "575fb9d9-c2a0-47df-bec4-5de1b3d5ca4d",
                        ),
                        configuration: _cartographerCharacterWithSpells()
                            .copyWith(characterName: 'Gandalf'),
                      ),
                    ],
                  ),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
          ],
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              darkTheme: ThemeData.dark(),
              themeMode: ThemeMode.dark,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
                fontFamily: 'Ruwudu',
                useMaterial3: true,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 16,
                ),
              ),
              home: ThemeConfigurationForApp(
                child: CustomThemeProvider(
                  overrideBrightness: Brightness.dark,
                  overrideSkinId: CharacterSheetSkinIds.nightCartographer,
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: Builder(builder: (context) {
                      return PlayerPageScreen(
                        startScreenOverride: testcase.$1,
                        routeSettings: PlayerPageScreenRouteSettings(
                          characterConfigurationOverride: null,
                          showInventory: true,
                          showRecipes: true,
                          showMoney: true,
                          showLore: true,
                          disableEdit: false,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
        getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
            Map.fromEntries([
          MapEntry(
            'night_cartographer',
            CustomThemeProvider(
              overrideBrightness: Brightness.dark,
              overrideSkinId: CharacterSheetSkinIds.nightCartographer,
              child: DependencyProvider.getMockedDependecyProvider(
                child: Center(child: widgetToTest),
              ),
            ),
          ),
        ]),
      );
    }
  });
}
