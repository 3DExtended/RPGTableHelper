import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:rpg_table_helper/screens/wizards/all_wizard_configurations.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../../test_configuration.dart';

void main() {
  for (var config in allWizardConfigurations.entries) {
    group('${config.key} renderings', () {
      // for each step in config add new testConfig
      for (var i = 0; i < config.value.stepBuilders.length; i++) {
        var stepBuilder = config.value.stepBuilders[i];

        testConfigurations(
          disableLocals: true,
          widgetName: '${config.key}-step-$i',
          useMaterialAppWrapper: true,
          screenFactory: (Locale locale) => WizardRendererForConfiguration(
            configuration: config.value,
            startStepIndex: i,
          ),
          getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
            MapEntry(
              'default',
              DependencyProvider.getMockedDependecyProvider(
                child: Center(
                  child: widgetToTest,
                ),
              ),
            ),
          ]),
        );
      }
    });
  }
}
