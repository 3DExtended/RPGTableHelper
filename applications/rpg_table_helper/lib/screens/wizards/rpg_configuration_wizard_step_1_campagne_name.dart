import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';

class RpgConfigurationWizardStep1CampagneName extends WizardStepBase {
  const RpgConfigurationWizardStep1CampagneName({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      setState(() {
        hasDataLoaded = true;
        textEditingController.text = data.rpgName;
      });
    });

    var stepHelperText = '''

Willkommen beim RPG Helper!

Du wirst auf den nächsten Schritten die App für dich und deine Party konfigurieren. Hierzu wirst du die Character Sheets erstellen, Item Kategorien, Fundorte, Items und Crafting Rezepte anlegen. Alle diese Einstellungen können später noch ergänzt werden, jedoch lohnt es sich am Anfang etwas Zeit zu investieren, damit deine Spieler die App bestens für sich nutzen können.

Wir beginnen mit der wohl schwierigsten Frage überhaupt:

Wie heißt deine Kampagne?'''; // TODO localize

    return TwoPartWizardStepBody(
      wizardTitle: "RPG Configuration", // TODO localize
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepTitle: "Kampangen Name", // TODO Localize,
      stepHelperText: stepHelperText,
      onNextBtnPressed: widget.onNextBtnPressed,
      onPreviousBtnPressed: widget.onPreviousBtnPressed,
      contentChildren: [
        TextField(
          decoration: InputDecoration(
            labelText: "Campagne Name:", // TODO localize
            border: const OutlineInputBorder(),
            hintStyle: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: Colors.white),
            labelStyle: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: Colors.white),
          ),
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: Colors.white),
          controller: textEditingController,
        ),
      ],
    );
  }
}
