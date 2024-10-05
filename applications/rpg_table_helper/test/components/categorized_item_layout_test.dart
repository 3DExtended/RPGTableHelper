import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/categorized_item_layout.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('CategorizedItemLayout rendering', () {
    testConfigurations(
      disableLocals: true,
      widgetName: 'CategorizedItemLayout solo',
      useMaterialAppWrapper: true,
      screenFactory: (Locale locale) => CategorizedItemLayout(categoryColumns: [
        Container(
          height: 20,
          width: 20,
          color: Colors.green,
        ),
        Container(
          height: 20,
          width: 20,
          color: Colors.red,
        ),
        Container(
          height: 20,
          width: 20,
          color: Colors.blue,
        ),
      ], contentChildren: [
        Container(
          height: 20,
          width: 20,
          color: Colors.green,
        ),
        Container(
          height: 20,
          width: 20,
          color: Colors.red,
        ),
        Container(
          height: 20,
          width: 20,
          color: Colors.blue,
        ),
      ]),
      getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
        MapEntry(
          'default',
          DependencyProvider.getMockedDependecyProvider(
            child: widgetToTest,
          ),
        ),
      ]),
    );
  });
}
