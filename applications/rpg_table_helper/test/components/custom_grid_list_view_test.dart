import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/custom_grid_list_view.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('CustomGridListView rendering', () {
    var tests = List.generate(9, (index) => index);

    for (var test in tests) {
      testConfigurations(
        disableLocals: false,
        widgetName: 'CustomGridListView$test',
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => CustomGridListView(
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
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
                child: Center(child: widgetToTest)),
          ),
        ]),
      );
    }
  });
}
