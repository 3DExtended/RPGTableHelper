import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../test_configuration.dart';

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

  group('playerpagescreens renderings', () {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    for (var testcase in testCases) {
      testConfigurations(
        disableLocals: false,
        pathPrefix: "../",
        widgetName: 'playerpagescreens${testcase.$1}-${testcase.$2}',
        useMaterialAppWrapper: true,
        testerInteractions: (tester, local) async {
          await tester.pumpAndSettle();
          await loadAppFonts();
          await loadAppFonts();
          await tester.pumpAndSettle();
          await loadAppFonts();
          await tester.pumpAndSettle();
        },
        screenFactory: (Locale locale) => ProviderScope(
          overrides: [
            rpgConfigurationProvider.overrideWith((ref) {
              return RpgConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgConfigurationModel.getBaseConfiguration(),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
            rpgCharacterConfigurationProvider.overrideWith((ref) {
              return RpgCharacterConfigurationNotifier(
                decks: AsyncValue.data(
                  RpgCharacterConfiguration.getBaseConfiguration(
                      RpgConfigurationModel.getBaseConfiguration(),
                      variant: 0),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
            connectionDetailsProvider.overrideWith((ref) {
              return ConnectionDetailsNotifier(
                initState: AsyncValue.data(ConnectionDetails.defaultValue()
                    .copyWith(
                        fightSequence: FightSequence(
                            fightUuid: "f10526be-c69a-46be-8802-df9421e6187b",
                            sequence: [
                              (
                                "575fb9d9-c2a0-47df-bec4-5de1b3d5ca4d",
                                "Frodo",
                                17
                              ),
                              (
                                "0eff8827-14f1-46a1-8695-ef7dc5323137",
                                "Gandalf",
                                17
                              ),
                            ]),
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
                          grantedItems: []),
                      GrantedItemsForPlayer(
                        characterName: "Gandalf",
                        playerId: "ghjiuhjkiujhn",
                        grantedItems: [
                          RpgCharacterOwnedItemPair(
                            itemUuid:
                                RpgConfigurationModel.getBaseConfiguration()
                                    .allItems
                                    .first
                                    .uuid,
                            amount: 2,
                          ),
                          RpgCharacterOwnedItemPair(
                            itemUuid:
                                RpgConfigurationModel.getBaseConfiguration()
                                    .allItems[2]
                                    .uuid,
                            amount: 12,
                          ),
                        ],
                      ),
                    ],
                        connectedPlayers: [
                      OpenPlayerConnection(
                        userId: UserIdentifier(
                            $value: "9a709402-5620-479c-85b7-718ae01e0a83"),
                        playerCharacterId: PlayerCharacterIdentifier(
                            $value: "575fb9d9-c2a0-47df-bec4-5de1b3d5ca4d"),
                        configuration:
                            RpgCharacterConfiguration.getBaseConfiguration(
                                    RpgConfigurationModel
                                        .getBaseConfiguration(),
                                    variant: 0)
                                .copyWith(characterName: "Gandalf"),
                      ),
                    ])),
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
                  S.delegate
                ],
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                darkTheme: ThemeData.dark(),
                themeMode: ThemeMode.dark,
                theme: ThemeData(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  fontFamily: 'Ruwudu',
                  useMaterial3: true,
                  iconTheme: const IconThemeData(
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                home: ThemeConfigurationForApp(
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
                            disableEdit: false),
                      );
                    }),
                  ),
                )),
          ),
        ),
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: Center(
                child: widgetToTest,
              ),
            ),
          ),
        ]),
      );
    }
  });
}
