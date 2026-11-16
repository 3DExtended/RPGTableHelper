import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_manager.dart';
import 'package:quest_keeper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/components/wizards/wizard_step_save_registry.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_8_summary.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// Labels of the steps whose registered save ran, in order.
final _saved = <String>[];

class _FakeStep extends WizardStepBase {
  const _FakeStep({
    required this.label,
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    required super.setWizardTitle,
  });

  final String label;

  @override
  ConsumerState<_FakeStep> createState() => _FakeStepState();
}

class _FakeStepState extends ConsumerState<_FakeStep> {
  @override
  void initState() {
    super.initState();
    registerWizardStepSave(_save);
  }

  void _save() => _saved.add(widget.label);

  @override
  void dispose() {
    unregisterWizardStepSave(_save);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TwoPartWizardStepBody(
      isLandscapeMode: true,
      stepHelperText: 'Help ${widget.label}',
      onPreviousBtnPressed: widget.onPreviousBtnPressed,
      onNextBtnPressed: widget.onNextBtnPressed,
      contentChildren: [Text('Content ${widget.label}')],
    );
  }
}

WizardStepDefinition _step(String label, {bool optional = false}) {
  return WizardStepDefinition(
    isOptional: optional,
    builder: (previous, next, setTitle) => _FakeStep(
      label: label,
      onPreviousBtnPressed: previous,
      onNextBtnPressed: next,
      setWizardTitle: setTitle,
    ),
  );
}

final _steps = [
  _step('A'),
  _step('B'),
  _step('C', optional: true),
  _step('D', optional: true),
  _step('E'),
];

/// Pumps a home page and pushes the wizard on top, like the DM screen does.
Future<ProviderContainer> _pumpWizard(
  WidgetTester tester, {
  required Widget Function(BuildContext context) wizard,
  RpgConfigurationModel? config,
}) async {
  final container = ProviderContainer(
    overrides: [
      rpgConfigurationProvider.overrideWith((ref) {
        return RpgConfigurationNotifier(
          decks: AsyncValue.data(
            config ?? RpgConfigurationModel.getBaseConfiguration(),
          ),
          ref: ref,
          runningInTests: true,
        );
      }),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: CustomThemeProvider(
        overrideBrightness: Brightness.dark,
        child: DependencyProvider.getMockedDependecyProvider(
          child: MaterialApp(
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('de'),
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: wizard)),
                      child: const Text('Home'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Home'));
  await tester.pumpAndSettle();
  return container;
}

Widget Function(BuildContext) _managerAt(
  int startStep, {
  VoidCallback? onFinish,
}) {
  return (context) => Scaffold(
    body: WizardManager(
      steps: _steps,
      startStepIndex: startStep,
      onFinish: onFinish ?? () {},
    ),
  );
}

Finder get _closeButton => find
    .descendant(of: find.byType(Navbar), matching: find.byType(CustomButton))
    .first;

void main() {
  setUp(_saved.clear);

  test(
    'firstRequiredStepAfter skips all directly following optional steps',
    () {
      expect(firstRequiredStepAfter(_steps, 0), 1);
      expect(firstRequiredStepAfter(_steps, 1), 4);
      expect(firstRequiredStepAfter(_steps, 2), 4);
      expect(firstRequiredStepAfter(_steps, 3), 4);
      expect(firstRequiredStepAfter(_steps, 4), isNull);
    },
  );

  for (final start in [0, 2, 4]) {
    testWidgets('close button saves and leaves the wizard from step $start', (
      tester,
    ) async {
      await _pumpWizard(tester, wizard: _managerAt(start));
      final label = ['A', 'B', 'C', 'D', 'E'][start];
      expect(find.text('Content $label'), findsOneWidget);

      await tester.tap(_closeButton);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Content $label'), findsNothing);
      expect(_saved, [label]);
    });
  }

  testWidgets('system back saves the visible step', (tester) async {
    await _pumpWizard(tester, wizard: _managerAt(1));

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(_saved, ['B']);
  });

  testWidgets('first step has no back button, later steps have one', (
    tester,
  ) async {
    await _pumpWizard(tester, wizard: _managerAt(0));
    expect(find.byKey(wizardPreviousButtonKey), findsNothing);
    expect(find.byKey(wizardNextButtonKey), findsOneWidget);

    await tester.tap(find.byKey(wizardNextButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('Content B'), findsOneWidget);
    expect(find.byKey(wizardPreviousButtonKey), findsOneWidget);

    await tester.tap(find.byKey(wizardPreviousButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('Content A'), findsOneWidget);
    expect(_saved, ['A', 'B']);
  });

  testWidgets('skip is offered only on optional steps', (tester) async {
    // Wide enough for the "optional step" hint next to the skip button.
    tester.view.physicalSize = const Size(2400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpWizard(tester, wizard: _managerAt(1));
    expect(find.byKey(wizardSkipButtonKey), findsNothing);

    await tester.tap(find.byKey(wizardNextButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('Content C'), findsOneWidget);
    expect(find.byKey(wizardSkipButtonKey), findsOneWidget);
    expect(find.text('Optionaler Schritt'), findsOneWidget);
  });

  testWidgets('skip jumps over all following optional steps', (tester) async {
    await _pumpWizard(tester, wizard: _managerAt(2));

    await tester.tap(find.byKey(wizardSkipButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('Content E'), findsOneWidget);
    expect(find.text('Content D'), findsNothing);
    expect(_saved, ['C']);
  });

  testWidgets('last step shows "Fertig" and finishes the wizard', (
    tester,
  ) async {
    var finished = 0;
    await _pumpWizard(
      tester,
      wizard: _managerAt(4, onFinish: () => finished++),
    );

    expect(
      find.descendant(
        of: find.byKey(wizardNextButtonKey),
        matching: find.text('Fertig'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(wizardNextButtonKey));
    await tester.pumpAndSettle();

    expect(finished, 1);
    expect(_saved, ['E']);
  });

  testWidgets('"Fertig" closes the wizard and confirms the save', (
    tester,
  ) async {
    await _pumpWizard(
      tester,
      wizard: (context) => WizardRendererForConfiguration(
        configuration: WizardConfiguration(steps: [_step('A')]),
      ),
    );

    await tester.tap(find.byKey(wizardNextButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Einrichtung gespeichert'), findsOneWidget);
  });

  group('rpg configuration wizard', () {
    final config = allWizardConfigurations['/rpgconfigurationwizard']!;
    final firstOptional = config.steps.indexWhere((s) => s.isOptional);

    test('crafting steps are optional and the summary comes last', () {
      expect(firstOptional, greaterThan(0));
      expect(config.steps.where((s) => s.isOptional).length, 4);
      expect(config.steps.last.isOptional, isFalse);
      expect(
        config.steps.last.builder(() {}, () {}, (_) {}),
        isA<RpgConfigurationWizardStep8Summary>(),
      );
    });

    testWidgets(
      'skip on places of finding goes to the summary and keeps data',
      (tester) async {
        final base = RpgConfigurationModel.getBaseConfiguration();
        final container = await _pumpWizard(
          tester,
          config: base,
          wizard: (context) => WizardRendererForConfiguration(
            configuration: config,
            startStepIndex: firstOptional,
          ),
        );

        await tester.tap(find.byKey(wizardSkipButtonKey));
        await tester.pumpAndSettle();

        expect(find.byType(RpgConfigurationWizardStep8Summary), findsOneWidget);
        final after = container.read(rpgConfigurationProvider).requireValue;
        expect(
          after.placesOfFindings.map((p) => p.name),
          base.placesOfFindings.map((p) => p.name),
        );
        expect(after.itemCategories.length, base.itemCategories.length);
        expect(after.allItems.length, base.allItems.length);
        expect(after.craftingRecipes.length, base.craftingRecipes.length);

        // The summary shows what is set up.
        expect(find.text(base.rpgName), findsOneWidget);
        expect(find.text('${base.allItems.length} Items'), findsOneWidget);
      },
    );
  });
}
