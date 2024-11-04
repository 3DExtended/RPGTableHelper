import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/icons_helper.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('AllCategoryIcons rendering', () {
    for (var i = 0; i < allIconNames.length; i++) {
      var iconNameToTest = allIconNames[i];
      testConfigurations(
        disableLocals: true,
        widgetName: 'AllCategoryIcons_$iconNameToTest',
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => getIconForIdentifier(
          name: iconNameToTest,
          color: darkColor,
          size: 32,
        ).$2,
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: Container(
                color: bgColor,
                child: Center(
                  child: widgetToTest,
                ),
              ),
            ),
          ),
        ]),
      );
    }

    testConfigurations(
      disableLocals: true,
      widgetName: 'AllCategoryIconsWrapped',
      useMaterialAppWrapper: true,
      screenFactory: (Locale locale) => Wrap(
        children: allIconNames
            .map((name) => getIconForIdentifier(
                  name: name,
                  color: darkColor,
                  size: 32,
                ).$2)
            .toList(),
      ),
      getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
        MapEntry(
          'default',
          DependencyProvider.getMockedDependecyProvider(
            child: Container(
              color: bgColor,
              child: Center(
                child: widgetToTest,
              ),
            ),
          ),
        ),
      ]),
    );
  });
}
