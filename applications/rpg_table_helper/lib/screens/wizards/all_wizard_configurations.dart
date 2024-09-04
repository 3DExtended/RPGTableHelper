import 'package:rpg_table_helper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard_step_1_campagne_name.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard_step_2_character_configurations_preset.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard_step_3_currency_definition.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard_step_4_item_locations.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard_step_5_item_categories.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard_step_6_items.dart';

Map<String, WizardConfiguration> allWizardConfigurations = {
  "/rpgconfigurationwizard": WizardConfiguration(
    stepBuilders: [
      (moveToPrevious, moveToNext) => RpgConfigurationWizardStep1CampagneName(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
          ),
      (moveToPrevious, moveToNext) =>
          RpgConfigurationWizardStep2CharacterConfigurationsPreset(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
          ),
      (moveToPrevious, moveToNext) =>
          RpgConfigurationWizardStep3CurrencyDefinition(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
          ),
      (moveToPrevious, moveToNext) => RpgConfigurationWizardStep4ItemLocations(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
          ),
      (moveToPrevious, moveToNext) => RpgConfigurationWizardStep5ItemCategories(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
          ),
      (moveToPrevious, moveToNext) => RpgConfigurationWizardStep6Items(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
          ),
    ],
  )
};
