import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/custom_int_edit_field.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('CustomIntEditField rendering', () {
    testConfigurations(
      disableLocals: true,
      widgetName: 'CustomIntEditField',
      useMaterialAppWrapper: true,
      screenFactory: (Locale locale) => CustomIntEditField(
        label: "Some Number Field",
        onValueChange: (newValue) {},
        startValue: 17,
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
