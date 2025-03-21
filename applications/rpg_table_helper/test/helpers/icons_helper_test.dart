import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('AllCategoryIcons rendering', () {
    testConfigurations(
      disableLocals: false,
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

    testConfigurations(
      disableLocals: false,
      widgetName: 'AllCategoryIconsWrapped_colored',
      useMaterialAppWrapper: true,
      screenFactory: (Locale locale) => Wrap(
        children: allIconNames
            .map((name) => Container(
                  color: Colors.red,
                  padding: EdgeInsets.all(2),
                  width: 4 + 32,
                  height: 4 + 32,
                  child: Container(
                    color: Colors.orange,
                    width: 32,
                    height: 32,
                    child: getIconForIdentifier(
                      name: name,
                      color: darkColor,
                      size: 32,
                    ).$2,
                  ),
                ))
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
