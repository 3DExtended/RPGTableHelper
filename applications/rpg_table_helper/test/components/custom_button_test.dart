import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('CustomButton rendering', () {
    var buttonsToTest = [
      CustomButton(
        onPressed: () {},
        icon: Container(
          height: 20,
          width: 20,
          color: Colors.green,
        ),
      ),
      CustomButton(
        onPressed: () {},
        label: "Ich bin ein Label",
        isSubbutton: true,
      ),
      CustomButton(
        onPressed: () {},
        label: "GO",
      ),
      CustomButton(
        onPressed: () {},
        label: "GO",
        icon: Container(
          height: 20,
          width: 20,
          color: Colors.green,
        ),
      )
    ];

    for (var i = 0; i < buttonsToTest.length; i++) {
      var button = buttonsToTest[i];
      testConfigurations(
        disableLocals: true,
        widgetName: 'CustomButton$i',
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => button,
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widgetToTest,
                  ],
                ),
              ),
            ),
          ),
          MapEntry(
            'expanded',
            DependencyProvider.getMockedDependecyProvider(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: widgetToTest),
                  ],
                ),
              ),
            ),
          ),
        ]),
      );
    }
  });
}
