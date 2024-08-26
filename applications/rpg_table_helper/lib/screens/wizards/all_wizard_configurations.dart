import 'package:rpg_table_helper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard.dart';

Map<String, WizardConfiguration> allWizardConfigurations = {
  "/rpgconfigurationwizard": WizardConfiguration(
    stepBuilders: [
      (moveToPrevious, moveToNext) => RpgConfigurationWizardStepCampagneName(
          onPreviousBtnPressed: moveToPrevious, onNextBtnPressed: moveToNext),
      (moveToPrevious, moveToNext) => RpgConfigurationWizardStepCampagneName(
          onPreviousBtnPressed: moveToPrevious, onNextBtnPressed: moveToNext),
    ],
  )
};
