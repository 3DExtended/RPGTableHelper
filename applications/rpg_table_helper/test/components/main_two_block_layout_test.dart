import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/main_two_block_layout.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/navigation_service.dart';

import '../test_configuration.dart';

void main() {
  group('MainTwoBlockLayout rendering', () {
    testConfigurations(
      disableLocals: true,
      widgetName: 'MainTwoBlockLayout',
      useMaterialAppWrapper: true,
      screenFactory: (Locale locale) => MainTwoBlockLayout(
        content: Container(color: const Color.fromARGB(102, 0, 0, 0)),
        navbarButtons: [
          NavbarButton(
            tabItem: TabItem.search,
            onPressed: () {},
            icon: Container(
              width: 20,
              height: 20,
              color: Colors.green,
            ),
          ),
          NavbarButton(
            tabItem: TabItem.character,
            onPressed: () {},
            icon: Container(
              width: 20,
              height: 20,
              color: const Color.fromARGB(255, 76, 84, 175),
            ),
          ),
          NavbarButton(
            tabItem: TabItem.inventory,
            onPressed: () {},
            icon: Container(
              width: 20,
              height: 20,
              color: const Color.fromARGB(255, 175, 76, 165),
            ),
          ),
          NavbarButton(
            tabItem: TabItem.crafting,
            onPressed: () {},
            icon: Container(
              width: 20,
              height: 20,
              color: const Color.fromARGB(255, 175, 76, 76),
            ),
          ),
          NavbarButton(
            tabItem: TabItem.lore,
            onPressed: () {},
            icon: Container(
              width: 20,
              height: 20,
              color: const Color.fromARGB(255, 175, 165, 76),
            ),
          )
        ],
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
  });
}
