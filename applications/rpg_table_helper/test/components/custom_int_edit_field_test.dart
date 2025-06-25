import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_int_edit_field.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('CustomIntEditField rendering', () {
    testConfigurations(
      disableLocals: true,
      widgetName: 'CustomIntEditField',
      useMaterialAppWrapper: true,
      screenFactory: (Locale locale) => CustomIntEditField(
        minValue: -10,
        maxValue: 10,
        label: "Some Number Field",
        onValueChange: (newValue) {},
        startValue: 17,
      ),
      getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
          Map.fromEntries([
        MapEntry(
          'default',
          CustomThemeProvider(
            overrideBrightness: brightness,
            child: DependencyProvider.getMockedDependecyProvider(
                child: Center(child: widgetToTest)),
          ),
        ),
      ]),
    );
  });
}
