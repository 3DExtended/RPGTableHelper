import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/player_stats_configuration_visuals.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// Behaviour of the interactive "test" preview in the player stat-value
/// configuration screen: players can drive a widget's controls (e.g. the
/// health bar's +/- buttons) in the preview, but that is a throwaway sandbox
/// that never leaks into the saved character value.
void main() {
  CharacterStatDefinition hpStat({
    CharacterStatEditType editType = CharacterStatEditType.oneTap,
  }) =>
      CharacterStatDefinition(
        groupId: null,
        isOptionalForAlternateForms: false,
        isOptionalForCompanionCharacters: null,
        valueType: CharacterStatValueType.intWithMaxValue,
        editType: editType,
        name: "HP",
        statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
        helperText: "How many health points do you have?",
        jsonSerializedAdditionalData: null,
      );

  RpgCharacterStatValue hpValue({required int value, required int maxValue}) =>
      RpgCharacterStatValue(
        hideFromCharacterScreen: false,
        hideLabelOfStat: false,
        variant: 0,
        statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
        serializedValue: jsonEncode({"value": value, "maxValue": maxValue}),
      );

  CharacterStatDefinition textStat() => CharacterStatDefinition(
        groupId: null,
        isOptionalForAlternateForms: false,
        isOptionalForCompanionCharacters: null,
        valueType: CharacterStatValueType.singleLineText,
        editType: CharacterStatEditType.static,
        name: "Background",
        statUuid: "057ab833-ce74-4feb-9b0d-4f53a83b3c21",
        helperText: "What is your tragic background story?",
        jsonSerializedAdditionalData: null,
      );

  Widget harness({
    required CharacterStatDefinition statConfiguration,
    RpgCharacterStatValue? characterValue,
    required void Function(RpgCharacterStatValue) onNewStatValue,
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
              decks: AsyncValue.data(
                RpgConfigurationModel.getBaseConfiguration(),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: DependencyProvider.getMockedDependecyProvider(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: SingleChildScrollView(
                child: PlayerStatsConfigurationVisuals(
                  statConfiguration: statConfiguration,
                  characterValue: characterValue,
                  characterName: "Frodo",
                  characterToRenderStatFor:
                      RpgCharacterConfiguration.getBaseConfiguration(
                          RpgConfigurationModel.getBaseConfiguration()),
                  onNewStatValue: onNewStatValue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // The interactive controls live inside the preview PageView; scope finds to
  // it so nothing else in the config form can be mistaken for a preview button.
  Finder previewPlus() => find.descendant(
        of: find.byType(PageView),
        matching: find.byIcon(FontAwesomeIcons.plus),
      );

  int savedValueOf(RpgCharacterStatValue? v) =>
      int.tryParse((jsonDecode(v!.serializedValue)["value"]).toString()) ?? -1;

  testWidgets(
    'tapping + in the preview updates the preview but does NOT change the '
    'saved value (ephemeral sandbox)',
    (tester) async {
      RpgCharacterStatValue? saved;
      await tester.pumpWidget(harness(
        statConfiguration: hpStat(),
        characterValue: hpValue(value: 5, maxValue: 10),
        onNewStatValue: (v) => saved = v,
      ));
      await tester.pumpAndSettle();

      // Baseline the enclosing modal would persist on Save.
      expect(savedValueOf(saved), 5);

      // The Reset control only appears once the sandbox is dirty.
      expect(find.text(S.current.previewTestReset), findsNothing);

      await tester.ensureVisible(previewPlus());
      await tester.tap(previewPlus());
      await tester.pumpAndSettle();

      // Saved value is untouched: a test tap must never leak into the
      // character. The reset affordance is now offered.
      expect(savedValueOf(saved), 5,
          reason: 'preview interaction must not change the saved value');
      expect(find.text(S.current.previewTestReset), findsOneWidget);
    },
  );

  testWidgets('Reset discards the sandbox and hides itself', (tester) async {
    await tester.pumpWidget(harness(
      statConfiguration: hpStat(),
      characterValue: hpValue(value: 5, maxValue: 10),
      onNewStatValue: (_) {},
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(previewPlus());
    await tester.tap(previewPlus());
    await tester.pumpAndSettle();
    expect(find.text(S.current.previewTestReset), findsOneWidget);

    await tester.tap(find.text(S.current.previewTestReset));
    await tester.pumpAndSettle();

    expect(find.text(S.current.previewTestReset), findsNothing,
        reason: 'after reset the sandbox is clean again');
  });

  testWidgets(
      'editing the configured value clears a dirty sandbox '
      '(preview reflects the new baseline, not a stale tap)', (tester) async {
    await tester.pumpWidget(harness(
      statConfiguration: hpStat(),
      characterValue: hpValue(value: 5, maxValue: 10),
      onNewStatValue: (_) {},
    ));
    await tester.pumpAndSettle();

    // Dirty the sandbox.
    await tester.ensureVisible(previewPlus());
    await tester.tap(previewPlus());
    await tester.pumpAndSettle();
    expect(find.text(S.current.previewTestReset), findsOneWidget);

    // Change the configured "current value" field (first editable field).
    await tester.enterText(find.byType(EditableText).first, "8");
    await tester.pumpAndSettle();

    expect(find.text(S.current.previewTestReset), findsNothing,
        reason: 'a config edit must reset the throwaway preview state');
  });

  testWidgets('the tested value carries across variant switches', (tester) async {
    await tester.pumpWidget(harness(
      statConfiguration: hpStat(),
      characterValue: hpValue(value: 5, maxValue: 10),
      onNewStatValue: (_) {},
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(previewPlus());
    await tester.tap(previewPlus());
    await tester.pumpAndSettle();

    // Swipe the preview carousel to the next variant.
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // The shared tested value survives, so the reset affordance stays.
    expect(find.text(S.current.previewTestReset), findsOneWidget,
        reason: 'the tested value is shared across variants, not per-page');
  });

  testWidgets(
      'a static (non-interactive) stat never shows the reset affordance',
      (tester) async {
    await tester.pumpWidget(harness(
      statConfiguration: textStat(),
      characterValue: null,
      onNewStatValue: (_) {},
    ));
    await tester.pumpAndSettle();

    // There is a preview, but nothing in it can be tested, so Reset never
    // appears and no sandbox state can exist.
    expect(find.text(S.current.previewTestReset), findsNothing);
    expect(previewPlus(), findsNothing);
  });
}
