import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../test_configuration.dart';

void main() {
  for (var config in allWizardConfigurations.entries) {
    var routeNameWithoutSlashes = config.key.replaceAll("/", "");
    group('$routeNameWithoutSlashes renderings', () {
      // for each step in config add new testConfig
      for (var i = 0; i < config.value.stepBuilders.length; i++) {
        testConfigurations(
          disableLocals: false,
          pathPrefix: "../",
          widgetName: '$routeNameWithoutSlashes-step-${i + 1}',
          useMaterialAppWrapper: true,
          screenFactory: (Locale locale) => ProviderScope(
            overrides: [
              rpgCharacterConfigurationProvider.overrideWith((ref) {
                return RpgCharacterConfigurationNotifier(
                  decks: AsyncValue.data(
                    RpgCharacterConfiguration.getBaseConfiguration(null),
                  ),
                  ref: ref,
                  runningInTests: true,
                );
              }),
              rpgConfigurationProvider.overrideWith((ref) {
                return RpgConfigurationNotifier(
                  decks: AsyncValue.data(
                    RpgConfigurationModel.getBaseConfiguration(),
                  ),
                  ref: ref,
                  runningInTests: true,
                );
              }),
            ],
            child: WizardRendererForConfiguration(
              configuration: config.value,
              startStepIndex: i,
            ),
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
