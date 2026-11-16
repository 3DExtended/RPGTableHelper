import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_0_character_sheet_skin.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_template_choice.dart';

import '../../custom_font_loader.dart';

/// The app's own routing: the template choice appears when the wizard opens
/// right after a campaign was created (what `createNewCampagne` calls), and
/// not on the plain route the gear icon on the DM page pushes.
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    // The login screen's fixed-width buttons overflow with the test font.
    await customLoadAppFonts();
    tester.view.physicalSize = const Size(2732, 2048);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rpgConfigurationProvider.overrideWith(
            (ref) => RpgConfigurationNotifier(
              decks: AsyncValue.data(
                RpgConfigurationTemplates.fantasySrd().copyWith(
                  rpgName: "Die Klingen von Varn",
                ),
              ),
              ref: ref,
              runningInTests: true,
            ),
          ),
        ],
        child: const AppRoutingShell(
          widget: MyApp(initialRoute: LoginScreen.route),
          useMockedServices: true,
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('a new campagne starts the wizard with the template choice', (
    tester,
  ) async {
    await pumpApp(tester);

    openSetupWizardForNewCampagne(navigatorKey.currentState!);
    await settle(tester);

    expect(
      find.byType(RpgConfigurationWizardStepTemplateChoice),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the gear icon route opens the wizard without it', (
    tester,
  ) async {
    await pumpApp(tester);

    navigatorKey.currentState!.pushNamed(
      allWizardConfigurations.entries.first.key,
    );
    await settle(tester);

    expect(
      find.byType(RpgConfigurationWizardStep0CharacterSheetSkin),
      findsOneWidget,
    );
    expect(find.byType(RpgConfigurationWizardStepTemplateChoice), findsNothing);
  });
}
