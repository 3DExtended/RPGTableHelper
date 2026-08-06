import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_0_character_sheet_skin.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

Future<ProviderContainer> _pumpSkinStep(
  WidgetTester tester,
  RpgConfigurationModel initialConfig,
) async {
  final container = ProviderContainer(overrides: [
    rpgConfigurationProvider.overrideWith((ref) {
      return RpgConfigurationNotifier(
        decks: AsyncValue.data(initialConfig),
        ref: ref,
        runningInTests: true,
      );
    }),
  ]);
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: CustomThemeProvider(
        overrideBrightness: Brightness.dark,
        child: MaterialApp(
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: RpgConfigurationWizardStep0CharacterSheetSkin(
              onPreviousBtnPressed: () {},
              onNextBtnPressed: () {},
              setWizardTitle: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  test('rpg configuration wizard lists skin step first', () {
    final steps =
        allWizardConfigurations['/rpgconfigurationwizard']!.stepBuilders;
    final widget = steps.first(
      () {},
      () {},
      (_) {},
    );
    expect(widget, isA<RpgConfigurationWizardStep0CharacterSheetSkin>());
  });

  testWidgets('selecting a skin persists campaign defaultSkinId',
      (tester) async {
    final container = await _pumpSkinStep(
      tester,
      RpgConfigurationModel.getBaseConfiguration(),
    );

    expect(
      container.read(rpgConfigurationProvider).requireValue.defaultSkinId,
      CharacterSheetSkinIds.classicDark,
    );

    await tester.tap(find.text('Classic Light'));
    await tester.pumpAndSettle();

    expect(
      container.read(rpgConfigurationProvider).requireValue.defaultSkinId,
      CharacterSheetSkinIds.classicLight,
    );
  });
}
