import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/generated/l10n.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';

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
      widget.setWizardTitle(S.of(context).campaignName);
    });
    textEditingController.addListener(_updateStateForFormValidation);
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.removeListener(_updateStateForFormValidation);
    super.dispose();
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

    var stepHelperText = '''

Willkommen beim RPG Helper!

Du wirst auf den nächsten Schritten die App für dich und deine Party konfigurieren. Hierzu wirst du die Character Sheets erstellen, Item Kategorien, Fundorte, Items und Crafting Rezepte anlegen. Alle diese Einstellungen können später noch ergänzt werden, jedoch lohnt es sich am Anfang etwas Zeit zu investieren, damit deine Spieler die App bestens für sich nutzen können.

Wir beginnen mit der wohl schwierigsten Frage überhaupt:

Wie heißt deine Kampagne?'''; // TODO localize

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
      onPreviousBtnPressed: () {
        // TODO as we dont validate the state of this form we are not saving changes. hence we should inform the user that their changes are revoked.
        widget.onPreviousBtnPressed();
      },
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
