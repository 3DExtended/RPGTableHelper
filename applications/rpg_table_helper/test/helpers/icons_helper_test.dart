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
        widgetName: 'AllCategoryIcons$i',
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
  });
}
