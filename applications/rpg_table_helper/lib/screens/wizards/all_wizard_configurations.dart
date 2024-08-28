import 'package:rpg_table_helper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard_step_campagne_name.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard_step_character_configurations_preset.dart';

Map<String, WizardConfiguration> allWizardConfigurations = {
  "/rpgconfigurationwizard": WizardConfiguration(
    stepBuilders: [
      (moveToPrevious, moveToNext) => RpgConfigurationWizardStepCampagneName(
          onPreviousBtnPressed: moveToPrevious, onNextBtnPressed: moveToNext),
      (moveToPrevious, moveToNext) =>
          RpgConfigurationWizardStepCharacterConfigurationsPreset(
              onPreviousBtnPressed: moveToPrevious,
              onNextBtnPressed: moveToNext),
    ],
  )
};
