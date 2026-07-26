import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_2b_fight_initiative.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

const _skillsStatUuid = '44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3';
const _geschicklichkeitEntryUuid = 'a7aa4151-8c7c-41d4-91d2-2ff0a3d084a4';

Future<ProviderContainer> _pumpStep(
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
        overrideBrightness: Brightness.light,
        child: MaterialApp(
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: RpgConfigurationWizardStep2bFightInitiative(
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

Future<void> _selectDropdownValue(
  WidgetTester tester,
  Key dropdownKey,
  String optionText,
) async {
  await tester.tap(find.byKey(dropdownKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text(optionText).last);
  await tester.pumpAndSettle();
}

Future<void> _tapNext(WidgetTester tester) async {
  // TwoPartWizardStepBody renders [Previous, Spacer, Next] as the only two
  // CustomButtons in this step; Next is the last one.
  await tester.tap(find.byType(CustomButton).last);
  await tester.pumpAndSettle();
}

void main() {
  group('RpgConfigurationWizardStep2bFightInitiative', () {
    testWidgets('selecting None clears all initiative fields', (tester) async {
      final baseConfig = RpgConfigurationModel.getBaseConfiguration();
      expect(baseConfig.initiativeBonusStatUuid, isNotNull);

      final container = await _pumpStep(tester, baseConfig);

      await _selectDropdownValue(
        tester,
        const Key('initiativeBonusStatDropdown'),
        S.current.initiativeBonusNoneOption,
      );

      await _tapNext(tester);

      final saved = container.read(rpgConfigurationProvider).value!;
      expect(saved.initiativeBonusStatUuid, isNull);
      expect(saved.initiativeBonusListEntryUuid, isNull);
      expect(saved.initiativeBonusField, isNull);
    });

    testWidgets('selecting list stat + entry + field persists all three refs',
        (tester) async {
      final startConfig = RpgConfigurationModel.getBaseConfiguration().copyWith(
        initiativeBonusStatUuid: null,
        initiativeBonusListEntryUuid: null,
        initiativeBonusField: null,
      );

      final container = await _pumpStep(tester, startConfig);

      await _selectDropdownValue(
          tester, const Key('initiativeBonusStatDropdown'), 'Skills');
      await _selectDropdownValue(tester,
          const Key('initiativeBonusListEntryDropdown'), 'Geschicklichkeit');

      // Field defaults to "Calculated value" for list-of-calculated stats;
      // explicitly switch it to exercise the field dropdown too.
      await _selectDropdownValue(
          tester, const Key('initiativeBonusFieldDropdown'), S.current.firstValue);

      await _tapNext(tester);

      final saved = container.read(rpgConfigurationProvider).value!;
      expect(saved.initiativeBonusStatUuid, _skillsStatUuid);
      expect(saved.initiativeBonusListEntryUuid, _geschicklichkeitEntryUuid);
      expect(saved.initiativeBonusField, InitiativeBonusField.value);
    });

    testWidgets('broken stored stat ref displays as None', (tester) async {
      final brokenConfig = RpgConfigurationModel.getBaseConfiguration().copyWith(
        initiativeBonusStatUuid: 'does-not-exist-anymore',
      );

      final container = await _pumpStep(tester, brokenConfig);

      // Shown as None: no list entry/field pickers, no preview sentence.
      expect(find.text(S.current.initiativeBonusNoneOption), findsOneWidget);
      expect(find.byKey(const Key('initiativeBonusListEntryDropdown')),
          findsNothing);
      expect(find.byKey(const Key('initiativeBonusFieldDropdown')), findsNothing);
      expect(find.textContaining('to your roll'), findsNothing);

      await _tapNext(tester);

      final saved = container.read(rpgConfigurationProvider).value!;
      expect(saved.initiativeBonusStatUuid, isNull);
      expect(saved.initiativeBonusListEntryUuid, isNull);
      expect(saved.initiativeBonusField, isNull);
    });

    testWidgets('preview sentence is visible when selected, hidden for None',
        (tester) async {
      final baseConfig = RpgConfigurationModel.getBaseConfiguration();

      await _pumpStep(tester, baseConfig);

      expect(
        find.text('Add Geschicklichkeit (+2) to your roll'),
        findsOneWidget,
      );

      await _selectDropdownValue(
        tester,
        const Key('initiativeBonusStatDropdown'),
        S.current.initiativeBonusNoneOption,
      );

      expect(
        find.text('Add Geschicklichkeit (+2) to your roll'),
        findsNothing,
      );
    });
  });
}
