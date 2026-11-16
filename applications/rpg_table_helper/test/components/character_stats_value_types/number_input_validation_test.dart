import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_int_edit_field.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:quest_keeper/helpers/number_input.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// B3 / SP-3: the level only takes numbers and never stores text as 0.
/// B14 / SP-4: number fields take negative values (signed keyboard).
///
/// Modals draw their content twice (shadow copy behind the real one), so
/// taps and text entry go to the last (top) match.
void main() {
  final config = RpgConfigurationModel.getBaseConfiguration();
  final summaryStat = config.characterStatTabsDefinition!
      .expand((t) => t.statsInTab)
      .firstWhere(
        (s) =>
            s.valueType ==
            CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
      );

  CharacterStatDefinition intStat() => CharacterStatDefinition(
    groupId: null,
    isOptionalForAlternateForms: false,
    isOptionalForCompanionCharacters: false,
    valueType: CharacterStatValueType.int,
    editType: CharacterStatEditType.static,
    name: "Initiative",
    statUuid: "5a0e6d0b-6c5e-4c58-a3a8-0d3c7c5a4d11",
    helperText: "Dein Initiative-Bonus",
  );

  CharacterStatDefinition modifierStat() => CharacterStatDefinition(
    groupId: null,
    isOptionalForAlternateForms: false,
    isOptionalForCompanionCharacters: false,
    valueType: CharacterStatValueType.listOfIntWithCalculatedValues,
    editType: CharacterStatEditType.static,
    name: "Attribute",
    statUuid: "7d3c0b52-2f7a-4d1f-9a55-3c1bf2f2b6a1",
    helperText: "",
    jsonSerializedAdditionalData:
        '{"values":[{"uuid":"dex","label":"Geschicklichkeit"}]}',
  );

  Widget buildHarness({
    required GlobalKey<NavigatorState> navigatorKey,
    required Future<void> Function(BuildContext context) onPressed,
  }) {
    return CustomThemeProvider(
      overrideBrightness: Brightness.light,
      child: ProviderScope(
        overrides: [
          rpgCharacterConfigurationProvider.overrideWith((ref) {
            return RpgCharacterConfigurationNotifier(
              decks: AsyncValue.data(
                RpgCharacterConfiguration.getBaseConfiguration(null),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
          rpgConfigurationProvider.overrideWith((ref) {
            return RpgConfigurationNotifier(
              decks: AsyncValue.data(config),
              ref: ref,
              runningInTests: true,
            );
          }),
        ],
        child: ThemeConfigurationForApp(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: DependencyProvider.getMockedDependecyProvider(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () => onPressed(context),
                      child: const Text("open"),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Opens the single-field dialog; returns a getter for its result.
  Future<({RpgCharacterStatValue? Function() result, bool Function() closed})>
  openDialog(
    WidgetTester tester,
    CharacterStatDefinition stat, {
    RpgCharacterStatValue? value,
  }) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    RpgCharacterStatValue? result;
    var closed = false;

    await tester.pumpWidget(
      buildHarness(
        navigatorKey: navigatorKey,
        onPressed: (context) async {
          result = await showGetPlayerConfigurationModal(
            context: context,
            statConfiguration: stat,
            characterValue: value,
            characterName: "Mira Dornwald",
            isEditingAlternateForm: false,
            hideVariantSelection: true,
            characterToRenderStatFor: null,
            overrideNavigatorKey: navigatorKey,
          );
          closed = true;
        },
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
    return (result: () => result, closed: () => closed);
  }

  Finder fieldLabelled(String label) =>
      find.widgetWithText(TextField, label).last;

  group('Level (B3)', () {
    testWidgets('text in the level shows an error and is never saved as 0', (
      tester,
    ) async {
      final dialog = await openDialog(tester, summaryStat);

      // A new character starts at level 1, visibly.
      expect(
        tester
            .widget<TextField>(fieldLabelled(S.current.level))
            .controller!
            .text,
        '1',
      );

      await tester.enterText(fieldLabelled(S.current.level), 'Waldläuferin');
      await tester.pumpAndSettle();

      expect(find.text(S.current.invalidLevelInput), findsWidgets);

      // Save is disabled while the level is invalid.
      await tester.tap(find.text(S.current.save).last);
      await tester.pumpAndSettle();
      expect(
        dialog.closed(),
        isFalse,
        reason: 'Save must not close the dialog with an invalid level',
      );

      await tester.enterText(fieldLabelled(S.current.level), '7');
      await tester.pumpAndSettle();
      expect(find.text(S.current.invalidLevelInput), findsNothing);

      await tester.tap(find.text(S.current.save).last);
      await tester.pumpAndSettle();

      expect(dialog.closed(), isTrue);
      final decoded = jsonDecode(dialog.result()!.serializedValue);
      expect(decoded['level'], 7);
    });

    testWidgets('the level field uses a number keyboard', (tester) async {
      await openDialog(tester, summaryStat);
      expect(
        tester.widget<TextField>(fieldLabelled(S.current.level)).keyboardType,
        signedIntKeyboardType,
      );
    });

    testWidgets('an empty level is an error, too', (tester) async {
      final dialog = await openDialog(tester, summaryStat);
      await tester.enterText(fieldLabelled(S.current.level), '');
      await tester.pumpAndSettle();

      expect(find.text(S.current.invalidLevelInput), findsWidgets);
      await tester.tap(find.text(S.current.save).last);
      await tester.pumpAndSettle();
      expect(dialog.closed(), isFalse);
    });
  });

  group('Signed numbers (B14)', () {
    testWidgets('-1 is stored in an int field', (tester) async {
      final dialog = await openDialog(tester, intStat());

      final field = fieldLabelled('Initiative');
      expect(
        tester.widget<TextField>(field).keyboardType,
        signedIntKeyboardType,
      );

      await tester.enterText(field, '-1');
      await tester.pumpAndSettle();
      expect(find.text(S.current.invalidWholeNumberInput), findsNothing);

      await tester.tap(find.text(S.current.save).last);
      await tester.pumpAndSettle();

      expect(jsonDecode(dialog.result()!.serializedValue)['value'], -1);
    });

    testWidgets('a negative modifier is stored', (tester) async {
      final dialog = await openDialog(tester, modifierStat());

      await tester.enterText(fieldLabelled(S.current.firstValue), '8');
      await tester.enterText(fieldLabelled(S.current.secondValue), '−1');
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.current.save).last);
      await tester.pumpAndSettle();

      final values =
          jsonDecode(dialog.result()!.serializedValue)['values'] as List;
      expect(values.single['value'], 8);
      expect(values.single['otherValue'], -1);
    });

    testWidgets('text in a number field shows an error and blocks Save', (
      tester,
    ) async {
      final dialog = await openDialog(tester, intStat());

      await tester.enterText(fieldLabelled('Initiative'), 'abc');
      await tester.pumpAndSettle();

      expect(find.text(S.current.invalidWholeNumberInput), findsWidgets);
      await tester.tap(find.text(S.current.save).last);
      await tester.pumpAndSettle();
      expect(dialog.closed(), isFalse);
    });

    testWidgets('CustomIntEditField reports -1', (tester) async {
      int? reported;
      await tester.pumpWidget(
        CustomThemeProvider(
          overrideBrightness: Brightness.light,
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: CustomIntEditField(
                  onValueChange: (v) => reported = v,
                  label: 'Wert',
                  startValue: 0,
                ),
              ),
            ),
          ),
        ),
      );

      final field = find.byType(TextField);
      expect(
        tester.widget<TextField>(field).keyboardType,
        signedIntKeyboardType,
      );

      await tester.enterText(field, '-1');
      await tester.pump();
      expect(reported, -1);
    });
  });
}
