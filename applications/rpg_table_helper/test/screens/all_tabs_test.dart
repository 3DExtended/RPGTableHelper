import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rpg_table_helper/components/tab_handler.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/navigation_service.dart';

import '../test_configuration.dart';

void main() {
  group('allTabsTest renderings', () {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    List<Override> connectionDetailsOverrides = [
      connectionDetailsProvider.overrideWith((ref) {
        return ConnectionDetailsNotifier(
            initState: AsyncValue.data(ConnectionDetails.defaultValue()),
            runningInTests: true,
            ref: ref);
      }),
      connectionDetailsProvider.overrideWith((ref) {
        return ConnectionDetailsNotifier(
            initState:
                AsyncValue.data(ConnectionDetails.defaultValue().copyWith(
              isConnected: true,
              isConnecting: false,
              isDm: true,
              isInSession: true,
              sessionConnectionNumberForPlayers: "123-123",
            )),
            runningInTests: true,
            ref: ref);
      }),
      connectionDetailsProvider.overrideWith((ref) {
        return ConnectionDetailsNotifier(
            initState:
                AsyncValue.data(ConnectionDetails.defaultValue().copyWith(
              isConnected: true,
              isConnecting: false,
              isDm: true,
              isInSession: true,
              sessionConnectionNumberForPlayers: "123-123",
              openPlayerRequests: [
                PlayerJoinRequests(
                  playerName: "Bilbo",
                  campagneJoinRequestId: "e330ad74-2769-47bc-8320-02d451ea46c8",
                  playerCharacterId: "1ec467ee-54e3-4ab4-977b-0a617bc489d6",
                  username: "petefdr",
                ),
                PlayerJoinRequests(
                  playerName: "Frodo",
                  campagneJoinRequestId: "e330ad74-2769-47bc-8320-02d451ea46c8",
                  playerCharacterId: "1ec467ee-54e3-4ab4-977b-0a617bc489d6",
                  username: "peteffeeefer",
                ),
              ],
            )),
            runningInTests: true,
            ref: ref);
      }),
      connectionDetailsProvider.overrideWith((ref) {
        return ConnectionDetailsNotifier(
          initState: AsyncValue.data(ConnectionDetails.defaultValue().copyWith(
            isConnected: true,
            isConnecting: false,
            isDm: true,
            isInSession: true,
            sessionConnectionNumberForPlayers: "123-123",
            openPlayerRequests: [
              PlayerJoinRequests(
                playerName: "Bilbo",
                campagneJoinRequestId: "e330ad74-2769-47bc-8320-02d451ea46c8",
                playerCharacterId: "1ec467ee-54e3-4ab4-977b-0a617bc489d6",
                username: "peteasr",
              ),
              PlayerJoinRequests(
                playerName: "Frodo",
                campagneJoinRequestId: "e330ad74-2769-47bc-8320-02d451ea46c8",
                playerCharacterId: "1ec467ee-54e3-4ab4-977b-0a617bc489d6",
                username: "petersss",
              ),
            ],
            connectedPlayers: [
              OpenPlayerConnection(
                userId: UserIdentifier(
                    $value: "73216e0e-bb87-49e6-88cf-7037ae0189c2"),
                playerCharacterId: PlayerCharacterIdentifier(
                    $value: "f525cd7f-0ae6-4f96-8cb6-3a106341e69d"),
                configuration:
                    RpgCharacterConfiguration.getBaseConfiguration(null),
              ),
              OpenPlayerConnection(
                userId: UserIdentifier(
                    $value: "76d50e3e-66eb-4342-9c33-f31a946b16b0"),
                playerCharacterId: PlayerCharacterIdentifier(
                    $value: "902135d6-0a69-4572-a6a5-a7e0aa93bd8e"),
                configuration:
                    RpgCharacterConfiguration.getBaseConfiguration(null)
                        .copyWith(
                  characterName: "Frodo",
                  inventory: [],
                ),
              )
            ],
            lastGrantedItems: [
              GrantedItemsForPlayer(
                  characterName: "Frodo", playerId: "fghjkl", grantedItems: []),
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
          )),
          runningInTests: true,
          ref: ref,
        );
      }),
    ];

    for (int i = 0; i < connectionDetailsOverrides.length; i++) {
      var connectionDetailsOverride = connectionDetailsOverrides[i];

      for (var tabItem in TabItem.values) {
        testConfigurations(
          disableLocals: true,
          pathPrefix: "",
          widgetName: 'allTabsTest$tabItem$i',
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
              connectionDetailsOverride,
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
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                darkTheme: ThemeData.dark(),
                themeMode: ThemeMode.dark,
                theme: ThemeData(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  fontFamily: 'Roboto',
                  useMaterial3: true,
                  iconTheme: const IconThemeData(
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                home: AuthorizedScreenWrapper(
                  initTab: tabItem,
                )),
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
    }
  });
}
