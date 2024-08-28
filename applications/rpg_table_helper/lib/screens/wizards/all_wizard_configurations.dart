import 'package:rpg_table_helper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard_step_1_campagne_name.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard_step_2_character_configurations_preset.dart';

Map<String, WizardConfiguration> allWizardConfigurations = {
  "/rpgconfigurationwizard": WizardConfiguration(
    stepBuilders: [
      (moveToPrevious, moveToNext) => RpgConfigurationWizardStep1CampagneName(
          onPreviousBtnPressed: moveToPrevious, onNextBtnPressed: moveToNext),
      (moveToPrevious, moveToNext) =>
          RpgConfigurationWizardStep2CharacterConfigurationsPreset(
              onPreviousBtnPressed: moveToPrevious,
              onNextBtnPressed: moveToNext),
    ],
  )
};
