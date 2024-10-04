import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rpg_table_helper/components/tab_handler.dart';
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
                  gameCode: "123-123",
                  connectionId: "asdf234easdf",
                ),
                PlayerJoinRequests(
                  playerName: "Frodo",
                  gameCode: "123-123",
                  connectionId: "fghjkweiee",
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
                gameCode: "123-123",
                connectionId: "asdf234easdf",
              ),
              PlayerJoinRequests(
                playerName: "Frodo",
                gameCode: "123-123",
                connectionId: "fghjkweiee",
              ),
            ],
            playerProfiles: [
              RpgCharacterConfiguration.getBaseConfiguration(null),
              RpgCharacterConfiguration.getBaseConfiguration(null).copyWith(
                characterName: "Frodo",
                inventory: [],
              ),
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
