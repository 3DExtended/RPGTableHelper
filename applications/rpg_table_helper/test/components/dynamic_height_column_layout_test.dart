import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rpg_table_helper/components/dynamic_height_column_layout.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('DynamicHeightColumnLayout rendering', () {
    testConfigurations(
      disableLocals: false,
      widgetName: 'DynamicHeightColumnLayout',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) async {
        await tester.pumpAndSettle();
        await loadAppFonts();
        await loadAppFonts();
        await tester.pumpAndSettle();
        await loadAppFonts();
        await tester.pumpAndSettle();
      },
      screenFactory: (Locale locale) => SingleChildScrollView(
        child: DynamicHeightColumnLayout(
          numberOfColumns: 3,
          children: [
            Container(
              height: 100,
              width: 100,
              color: Colors.red,
            ),
            Container(
              height: 90,
              width: 100,
              color: Colors.green,
            ),
            Container(
              height: 80,
              width: 100,
              color: Colors.orange,
            ),
            Container(
              height: 100,
              width: 100,
              color: Colors.black,
            ),
            Container(
              height: 100,
              width: 100,
              color: Colors.blue,
            ),
            Container(
              height: 100,
              width: 100,
              color: Colors.pink,
            ),
          ],
        ),
      ),
      getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
        MapEntry(
          'default',
          DependencyProvider.getMockedDependecyProvider(
              child: Center(child: widgetToTest)),
        ),
      ]),
    );
  });
}
