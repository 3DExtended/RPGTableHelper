import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';

class RpgConfigurationWizardStep2CharacterConfigurationsPreset
    extends WizardStepBase {
  const RpgConfigurationWizardStep2CharacterConfigurationsPreset({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep2CharacterConfigurationsPreset>
      createState() =>
          _RpgConfigurationWizardStep2CharacterConfigurationsPresetState();
}

class _RpgConfigurationWizardStep2CharacterConfigurationsPresetState
    extends ConsumerState<
        RpgConfigurationWizardStep2CharacterConfigurationsPreset> {
  bool hasDataLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      setState(() {
        hasDataLoaded = true;
      });
    });

    var stepHelperText = '''

Nun kommen wir zu den Character Sheets.

Jedes RPG hat unterschiedliche charakterisierende Eigenschaften für die Spieler (bspw. wieviele Lebenspunkte ein Spieler hat).

Für jede Eigenschaft muss du, also der DM, definieren, wie die Spieler mit dieser Eigenschaft interagieren können. Hierbei brauchen wir je Eigenschaft drei Infos von dir:

1. Name der Eigenschaft: Wie soll dieser Stat auf dem Character Sheet heißen? (bspw. “HP”, “SP”, “Name”, etc.)
2. Werteart der Eigenschaft: Handelt es sich bspw. nur um einen Text, welchen der Spieler anpassen kann (bspw. Hintergrund Story zum Character) oder doch um einen Zahlenwert (bspw. den Lebenspunkten).
3. Änderungsart: Manche von diesen Eigenschaften werden regelmäßig angepasst (bspw. die aktuellen Lebenspunkte), manche hingegen werden nur selten verändert (bspw. die maximalen Lebenspunkte). Damit das bei der Erstellung der Charactersheets berücksichtig werden kann, musst du uns diese Information mitgeben.

Falls du mehr Erklärung brauchst, kannst du hier eine Beispielseite mit allen Konfigurationen und entsprechendem Aussehen auf den Character Sheets finden:'''; // TODO localize

    return TwoPartWizardStepBody(
      wizardTitle: "RPG Configuration", // TODO localize
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepTitle: "Character Stats", // TODO Localize,
      stepHelperText: stepHelperText,
      onNextBtnPressed: widget.onNextBtnPressed,
      onPreviousBtnPressed: widget.onPreviousBtnPressed,
      sideBarFlex: 1,
      contentFlex: 2,
      contentChildren: const [],
    );
  }
}
