import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_grid_list_view.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('CustomGridListView rendering', () {
    var tests = List.generate(9, (index) => index);

    for (var test in tests) {
      testConfigurations(
        disableLocals: true,
        widgetName: 'CustomGridListView$test',
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale, Brightness brightnessToTest) =>
            CustomThemeProvider(
          overrideBrightness: brightnessToTest,
          child: CustomGridListView(
            itemCount: test,
            numberOfColumns: 3,
            horizontalSpacing: 20,
            verticalSpacing: 20,
            itemBuilder: (context, index) {
              assert(index < test);
              return Container(
                width: 100,
                height: 100,
                color: Colors.red,
              );
            },
          ),
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
    }
  });
}
