import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_page_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../test_configuration.dart';

void main() {
  const testCases = [
    (0, "dmcampagnemanagmentscreen"),
    (1, "dmplayeroverviewscreen"),
    (2, "dminitiativescreen"),
    (3, "dmgrantitemsscreen"),
    (4, "dmlorescreen"),
    (5, "dmallgeneratedimagesscreen"),
  ];

  group('dmpagescreens renderings', () {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    for (var testcase in testCases) {
      testConfigurations(
        disableLocals: false,
        pathPrefix: "../",
        widgetName: 'dmpagescreens${testcase.$2}',
        useMaterialAppWrapper: true,
        testerInteractions: (tester, local) async {
          await tester.pumpAndSettle();
          await loadAppFonts();
          await loadAppFonts();
          await tester.pumpAndSettle();
          await loadAppFonts();
          await tester.pumpAndSettle();
        },
        screenFactory: (Locale locale, Brightness brightnessToTest) =>
            ProviderScope(
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
                                21
                              ),
                              (null, "Gegner #2", 17),
                              (
                                "0eff8827-14f1-46a1-8695-ef7dc5323137",
                                "Gandalf",
                                16
                              ),
                              (null, "Gegner #1", 15),
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
                        openPlayerRequests: [
                      PlayerJoinRequests(
                          playerName: "Thamior",
                          username: "Tobias",
                          campagneJoinRequestId: "asdf2",
                          playerCharacterId: "asdf"),
                      PlayerJoinRequests(
                          playerName: "Kardan",
                          username: "Peter",
                          campagneJoinRequestId: "asdf2",
                          playerCharacterId: "asdf"),
                      PlayerJoinRequests(
                          playerName: "Faugar",
                          username: "Lukas",
                          campagneJoinRequestId: "asdf2",
                          playerCharacterId: "asdf"),
                      PlayerJoinRequests(
                          playerName: "Shava",
                          username: "Rachel",
                          campagneJoinRequestId: "asdf2",
                          playerCharacterId: "asdf"),
                    ],
                        connectedPlayers: [
                      OpenPlayerConnection(
                        lastPing: DateTime(2025, 02, 26, 12, 00),
                        userId: UserIdentifier(
                            $value: "9a709402-5620-479c-85b7-718ae01e0a83"),
                        playerCharacterId: PlayerCharacterIdentifier(
                            $value: "575fb9d9-c2a0-47df-bec4-5de1b3d5ca4d"),
                        configuration:
                            RpgCharacterConfiguration.getBaseConfiguration(
                                    variant: 0,
                                    RpgConfigurationModel
                                        .getBaseConfiguration())
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
                  child: CustomThemeProvider(
                    overrideBrightness: brightnessToTest,
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: Builder(builder: (context) {
                        return DmPageScreen(
                          startScreenOverride: testcase.$1,
                        );
                      }),
                    ),
                  ),
                )),
          ),
        ),
        getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
            Map.fromEntries([
          MapEntry(
            'default',
            CustomThemeProvider(
              overrideBrightness: brightness,
              child: DependencyProvider.getMockedDependecyProvider(
                child: Center(
                  child: widgetToTest,
                ),
              ),
            ),
          ),
        ]),
      );
    }
  });
}
