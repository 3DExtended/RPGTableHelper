import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/components/wizards/wizard_step_save_registry.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';

class RpgConfigurationWizardStep1CampagneName extends WizardStepBase {
  const RpgConfigurationWizardStep1CampagneName({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    required super.setWizardTitle,
    super.key,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep1CampagneName> createState() =>
      _RpgConfigurationWizardStep1CampagneNameState();
}

class _RpgConfigurationWizardStep1CampagneNameState
    extends ConsumerState<RpgConfigurationWizardStep1CampagneName> {
  bool hasDataLoaded = false;
  TextEditingController textEditingController = TextEditingController();
  bool isFormValid = false;

  void _updateStateForFormValidation() {
    var newIsFormValid = getIsFormValid();

    if (newIsFormValid != isFormValid) {
      setState(() {
        isFormValid = newIsFormValid;
      });
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      widget.setWizardTitle(S.of(context).campaignName);
    });
    textEditingController.addListener(_updateStateForFormValidation);
    registerWizardStepSave(_saveIfValid);
    super.initState();
  }

  @override
  void dispose() {
    unregisterWizardStepSave(_saveIfValid);
    textEditingController.removeListener(_updateStateForFormValidation);
    super.dispose();
  }

  /// Called by the wizard when the step is left in any way (close, back,
  /// step indicator). An invalid name is not saved.
  void _saveIfValid() {
    if (getIsFormValid()) {
      saveChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        setState(() {
          hasDataLoaded = true;
          textEditingController.text = data.rpgName;
        });
      }
    });

    var stepHelperText = S.of(context).wizardCampaignNameStepHelper;

    return TwoPartWizardStepBody(
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepHelperText: stepHelperText,
      onNextBtnPressed: !isFormValid
          ? null
          : () {
              saveChanges();
              widget.onNextBtnPressed();
            },
      // Leaving the step saves a valid name through the registered save.
      onPreviousBtnPressed: widget.onPreviousBtnPressed,
      sideBarFlex: 1,
      contentFlex: 2,
      contentChildren: [
        CustomTextField(
            labelText: "${S.of(context).campaignName}:",
            keyboardType: TextInputType.text,
            textEditingController: textEditingController),
      ],
    );
  }

  void saveChanges() {
    ref
        .read(rpgConfigurationProvider.notifier)
        .updateRpgName(textEditingController.text);
  }

  bool getIsFormValid() {
    return hasDataLoaded == true &&
        textEditingController.text.isNotEmpty &&
        textEditingController.text.length > 3;
  }
}
