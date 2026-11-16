import 'package:flutter/widgets.dart';
import 'package:quest_keeper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_0_character_sheet_skin.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_1_campagne_name.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_2_character_configurations_preset.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_2b_fight_initiative.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_3_currency_definition.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_4_item_locations.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_5_item_categories.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_6_items.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_8_summary.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_template_choice.dart';

/// Steps run top to bottom. Optional steps (crafting) can be skipped in one
/// go; the summary at the end closes the wizard. New steps can be inserted
/// anywhere, nothing depends on step indices. The template choice comes
/// first, but only for a new campaign (see [openSetupWizardForNewCampagne]).
Map<String, WizardConfiguration> allWizardConfigurations = {
  "/rpgconfigurationwizard": WizardConfiguration(
    steps: [
      WizardStepDefinition(
        // Replaces the whole configuration, so never when editing.
        onlyForNewSetup: true,
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStepTemplateChoice(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
      WizardStepDefinition(
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStep0CharacterSheetSkin(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
      WizardStepDefinition(
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStep1CampagneName(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
      WizardStepDefinition(
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStep2CharacterConfigurationsPreset(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
      WizardStepDefinition(
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStep2bFightInitiative(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
      WizardStepDefinition(
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStep3CurrencyDefinition(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
      WizardStepDefinition(
        isOptional: true,
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStep4ItemLocations(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
      WizardStepDefinition(
        isOptional: true,
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStep5ItemCategories(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
      WizardStepDefinition(
        isOptional: true,
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStep6Items(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
      WizardStepDefinition(
        isOptional: true,
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStep7CraftingRecipes(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
      WizardStepDefinition(
        builder: (moveToPrevious, moveToNext, setTitle) =>
            RpgConfigurationWizardStep8Summary(
          onPreviousBtnPressed: moveToPrevious,
          onNextBtnPressed: moveToNext,
          setWizardTitle: setTitle,
        ),
      ),
    ],
  )
};

/// Opens the setup assistant right after a campaign was created, with the
/// steps only a new campaign gets (the template choice first). The gear icon
/// on the DM page opens the same route without arguments, to edit.
Future<Object?> openSetupWizardForNewCampagne(NavigatorState navigator) =>
    navigator.pushNamed(
      allWizardConfigurations.entries.first.key,
      arguments: const WizardRouteArguments(isNewSetup: true),
    );
