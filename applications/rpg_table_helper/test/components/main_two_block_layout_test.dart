import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/main_two_block_layout.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/navigation_service.dart';

import '../test_configuration.dart';

void main() {
  var connectionDetailList = [
    ConnectionDetails(
      isConnected: false,
      isConnecting: false,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
    ),
    ConnectionDetails(
      isConnected: true,
      isConnecting: false,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
    ),
    ConnectionDetails(
      isConnected: true,
      isConnecting: true,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
    ),
    ConnectionDetails(
      isConnected: false,
      isConnecting: true,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
    ),
    ConnectionDetails(
      isConnected: false,
      isConnecting: false,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
    ),
    ConnectionDetails(
      isConnected: true,
      isConnecting: false,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
    ),
    ConnectionDetails(
      isConnected: true,
      isConnecting: true,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
    ),
    ConnectionDetails(
      isConnected: false,
      isConnecting: true,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
    ),
  ];

  group('MainTwoBlockLayout rendering', () {
    for (int i = 0; i < connectionDetailList.length; i++) {
      var connectionDetails = connectionDetailList[i];
      testConfigurations(
        disableLocals: true,
        widgetName: 'MainTwoBlockLayout${i + 1}',
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => ProviderScope(
          overrides: [
            connectionDetailsProvider.overrideWith((ref) {
              return ConnectionDetailsNotifier(
                initState: AsyncValue.data(connectionDetails),
                ref: ref,
                runningInTests: true,
              );
            }),
          ],
          child: MainTwoBlockLayout(
            showIsConnectedButton: true,
            selectedNavbarButton: 1,
            content: Container(color: const Color.fromARGB(102, 0, 0, 0)),
            navbarButtons: [
              NavbarButton(
                tabItem: TabItem.search,
                onPressed: (_) {},
                icon: Container(
                  width: 20,
                  height: 20,
                  color: Colors.green,
                ),
              ),
              NavbarButton(
                tabItem: TabItem.character,
                onPressed: (_) {},
                icon: Container(
                  width: 20,
                  height: 20,
                  color: const Color.fromARGB(255, 76, 84, 175),
                ),
              ),
              NavbarButton(
                tabItem: TabItem.inventory,
                onPressed: (_) {},
                icon: Container(
                  width: 20,
                  height: 20,
                  color: const Color.fromARGB(255, 175, 76, 165),
                ),
              ),
              NavbarButton(
                tabItem: TabItem.crafting,
                onPressed: (_) {},
                icon: Container(
                  width: 20,
                  height: 20,
                  color: const Color.fromARGB(255, 175, 76, 76),
                ),
              ),
              NavbarButton(
                tabItem: TabItem.lore,
                onPressed: (_) {},
                icon: Container(
                  width: 20,
                  height: 20,
                  color: const Color.fromARGB(255, 175, 165, 76),
                ),
              )
            ],
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
