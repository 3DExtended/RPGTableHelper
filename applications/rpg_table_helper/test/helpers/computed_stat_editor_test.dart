import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/computed_stat_formula.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

const skillsUuid = "44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3";
const wisdom = "167b94e6-d674-43a4-a25b-fca1309a12b0";

/// The modal's shadow draws its content a second time; use the real one.
Finder real(Finder finder) => finder.last;

void main() {
  final availableStats = StatNumbers.statsWithTabs(
    RpgConfigurationModel.getBaseConfiguration(),
  );

  Future<Future<CharacterStatDefinition?> Function()> pumpModal(
    WidgetTester tester,
    CharacterStatDefinition stat,
  ) async {
    CharacterStatDefinition? saved;
    var done = false;
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: CustomThemeProvider(
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale("de"),
              supportedLocales: AppLocalizations.supportedLocales,
              home: CustomThemeProvider(
                child: DependencyProvider.getMockedDependecyProvider(
                  child: Scaffold(
                    body: Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: () async {
                          saved = await showGetDmConfigurationModal(
                            context: context,
                            predefinedConfiguration: stat,
                            availableStats: availableStats,
                          );
                          done = true;
                        },
                        child: const Text("open"),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return () async {
      expect(done, isTrue);
      return saved;
    };
  }

  Future<void> pickFromDropdown(
    WidgetTester tester,
    Finder dropdown,
    String item,
  ) async {
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(item).last);
    await tester.pumpAndSettle();
  }

  testWidgets('the DM builds "10 + Mod(Weisheit)" for a number property', (
    tester,
  ) async {
    var result = await pumpModal(
      tester,
      CharacterStatDefinition(
        statUuid: "passive",
        name: "Passive Wahrnehmung",
        groupId: null,
        helperText: "",
        valueType: CharacterStatValueType.int,
        editType: CharacterStatEditType.static,
        isOptionalForAlternateForms: false,
        isOptionalForCompanionCharacters: false,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();

    var toggle = real(find.byKey(const ValueKey("computedValueToggle")));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: toggle, matching: find.byType(CustomButton)),
    );
    await tester.pumpAndSettle();

    // Start value defaults to 10.
    var addTerm = real(find.byKey(const ValueKey("computedAddTerm")));
    await tester.ensureVisible(addTerm);
    await tester.pumpAndSettle();
    await tester.tap(addTerm);
    await tester.pumpAndSettle();

    await pickFromDropdown(
      tester,
      real(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith(
                "computedTerm0-source-",
              ),
        ),
      ),
      "Weisheit · Skills",
    );
    await pickFromDropdown(
      tester,
      real(find.byKey(const ValueKey("computedTerm0-mode-value"))),
      "Modifikator (x−10)/2",
    );

    expect(
      tester
          .widget<Text>(real(find.byKey(const ValueKey("computedPreview"))))
          .data,
      "Formel: 10 + Mod(Weisheit)",
    );

    var save = real(find.text("Speichern"));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    var saved = await result();
    expect(saved!.statUuid, "passive");
    expect(
      ComputedStatFormula.of(saved),
      const ComputedStatFormula(
        base: 10,
        terms: [
          ComputedStatTerm(
            source: StatNumberRef(statUuid: skillsUuid, entryUuid: wisdom),
            mode: ComputedTermMode.modifier,
          ),
        ],
      ),
    );
  });

  testWidgets('a preset fills the builder and names the new property', (
    tester,
  ) async {
    var result = await pumpModal(
      tester,
      CharacterStatDefinition(
        statUuid: "passive",
        name: "",
        groupId: null,
        helperText: "",
        valueType: CharacterStatValueType.int,
        editType: CharacterStatEditType.static,
        isOptionalForAlternateForms: false,
        isOptionalForCompanionCharacters: false,
        jsonSerializedAdditionalData: const ComputedStatFormula(base: 3)
            .toAdditionalData(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();

    await pickFromDropdown(
      tester,
      real(find.byKey(const ValueKey("computedPreset-none"))),
      "Passive Wahrnehmung",
    );

    expect(
      tester
          .widget<Text>(real(find.byKey(const ValueKey("computedPreview"))))
          .data,
      "Formel: 10 + Mod(Weisheit) + ÜB (wenn Fertigkeiten: Wahrnehmung (Wei))",
    );
    expect(
      find.byKey(const ValueKey("computedPresetIncomplete")),
      findsNothing,
    );

    var save = real(find.text("Speichern"));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    var saved = await result();
    expect(saved!.name, "Passive Wahrnehmung");
    expect(ComputedStatFormula.of(saved)!.terms, hasLength(2));
    expect(ComputedStatFormula.of(saved)!.base, 10);
  });

  testWidgets('switching "compute" off saves a plain number again', (
    tester,
  ) async {
    var result = await pumpModal(
      tester,
      CharacterStatDefinition(
        statUuid: "passive",
        name: "Passive Wahrnehmung",
        groupId: null,
        helperText: "",
        valueType: CharacterStatValueType.int,
        editType: CharacterStatEditType.static,
        isOptionalForAlternateForms: false,
        isOptionalForCompanionCharacters: false,
        jsonSerializedAdditionalData: const ComputedStatFormula(base: 10)
            .toAdditionalData(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();

    expect(real(find.byKey(const ValueKey("computedPreview"))), findsOneWidget);
    var toggle = real(find.byKey(const ValueKey("computedValueToggle")));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: toggle, matching: find.byType(CustomButton)),
    );
    await tester.pumpAndSettle();

    var save = real(find.text("Speichern"));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    var saved = await result();
    expect(StatNumbers.isComputed(saved!), isFalse);
  });
}
