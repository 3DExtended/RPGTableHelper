import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';

class RpgConfigurationWizardStepCampagneName extends WizardStepBase {
  const RpgConfigurationWizardStepCampagneName({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
  });

  @override
  ConsumerState<RpgConfigurationWizardStepCampagneName> createState() =>
      _RpgConfigurationWizardStepCampagneNameState();
}

class _RpgConfigurationWizardStepCampagneNameState
    extends ConsumerState<RpgConfigurationWizardStepCampagneName> {
  @override
  Widget build(BuildContext context) {
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
    );
  }
}

class TwoPartWizardStepBody extends StatelessWidget {
  const TwoPartWizardStepBody({
    super.key,
    required this.wizardTitle,
    required this.isLandscapeMode,
    required this.stepTitle,
    required this.stepHelperText,
    required this.onPreviousBtnPressed,
    required this.onNextBtnPressed,
  });

  final String wizardTitle;
  final bool isLandscapeMode;
  final String stepTitle;
  final String stepHelperText;
  final void Function() onPreviousBtnPressed;
  final void Function() onNextBtnPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color.fromARGB(33, 210, 191, 221),
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                wizardTitle,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: const Color.fromARGB(78, 255, 255, 255),
        ),
        Expanded(
          child: RowColumnFlipper(
            isLandscapeMode: isLandscapeMode,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                    color: const Color.fromARGB(33, 210, 191, 221),
                    padding: const EdgeInsets.all(20),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    stepTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: Colors.white,
                                          fontSize: 24,
                                        ),
                                  ),
                                ],
                              ),
                              Text(
                                stepHelperText,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })),
              ),
              if (!isLandscapeMode)
                Container(
                  height: 1,
                  width: double.infinity,
                  color: const Color.fromARGB(78, 255, 255, 255),
                ),
              Expanded(
                child: Container(
                  color: const Color.fromARGB(65, 39, 39, 39),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Row(
                          children: [
                            CustomButton(
                              label: "Zurück",
                              onPressed: () {
                                onPreviousBtnPressed();
                              },
                            ),
                            const Spacer(),
                            CustomButton(
                              label: "Weiter",
                              onPressed: () {
                                onNextBtnPressed();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
