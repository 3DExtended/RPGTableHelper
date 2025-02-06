import 'package:quest_keeper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_1_campagne_name.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_2_character_configurations_preset.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_3_currency_definition.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_4_item_locations.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_5_item_categories.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_6_items.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';

Map<String, WizardConfiguration> allWizardConfigurations = {
  "/rpgconfigurationwizard": WizardConfiguration(
    stepBuilders: [
      (moveToPrevious, moveToNext, setTitle) =>
          RpgConfigurationWizardStep1CampagneName(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
            setWizardTitle: setTitle,
          ),
      (moveToPrevious, moveToNext, setTitle) =>
          RpgConfigurationWizardStep2CharacterConfigurationsPreset(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
            setWizardTitle: setTitle,
          ),
      (moveToPrevious, moveToNext, setTitle) =>
          RpgConfigurationWizardStep3CurrencyDefinition(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
            setWizardTitle: setTitle,
          ),
      (moveToPrevious, moveToNext, setTitle) =>
          RpgConfigurationWizardStep4ItemLocations(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
            setWizardTitle: setTitle,
          ),
      (moveToPrevious, moveToNext, setTitle) =>
          RpgConfigurationWizardStep5ItemCategories(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
            setWizardTitle: setTitle,
          ),
      (moveToPrevious, moveToNext, setTitle) =>
          RpgConfigurationWizardStep6Items(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
            setWizardTitle: setTitle,
          ),
      (moveToPrevious, moveToNext, setTitle) =>
          RpgConfigurationWizardStep7CraftingRecipes(
            onPreviousBtnPressed: moveToPrevious,
            onNextBtnPressed: moveToNext,
            setWizardTitle: setTitle,
          ),
    ],
  )
};
