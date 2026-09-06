import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// Direct coverage of the one stat widget that mutates its value in place: the
/// `intWithMaxValue` health bar. Its +/- buttons are what the configuration
/// preview lets players "test", so the mechanics are pinned here per variant.
void main() {
  // The health bar renders 9 visual variants (indices 0-8); every one of them
  // draws the +/- controls via CustomFaIcon(plus/minus) when editable.
  const variants = [0, 1, 2, 3, 4, 5, 6, 7, 8];

  CharacterStatDefinition hpStat(CharacterStatEditType editType) =>
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

  RpgCharacterStatValue hpValue({
    required int value,
    required int maxValue,
    required int variant,
  }) =>
      RpgCharacterStatValue(
        hideFromCharacterScreen: false,
        hideLabelOfStat: false,
        variant: variant,
        statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
        serializedValue: jsonEncode({"value": value, "maxValue": maxValue}),
      );

  Widget harness({
    required CharacterStatDefinition statConfiguration,
    required RpgCharacterStatValue characterValue,
    required void Function(String newSerializedValue) onNewStatValue,
  }) {
    return ProviderScope(
      child: CustomThemeProvider(
        overrideBrightness: Brightness.light,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: DependencyProvider.getMockedDependecyProvider(
            child: Scaffold(
              body: Center(
                child: Builder(builder: (context) {
                  return getPlayerVisualizationWidget(
                    context: context,
                    statConfiguration: statConfiguration,
                    characterValue: characterValue,
                    characterName: "Frodo",
                    onNewStatValue: onNewStatValue,
                    characterToRenderStatFor:
                        RpgCharacterConfiguration.getBaseConfiguration(
                            RpgConfigurationModel.getBaseConfiguration()),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int? decodeValue(String serialized) =>
      int.tryParse((jsonDecode(serialized)["value"]).toString());

  for (final variant in variants) {
    testWidgets(
      'oneTap variant $variant: tapping + emits value+1, - emits value-1',
      (tester) async {
        String? captured;
        await tester.pumpWidget(harness(
          statConfiguration: hpStat(CharacterStatEditType.oneTap),
          characterValue: hpValue(value: 5, maxValue: 10, variant: variant),
          onNewStatValue: (v) => captured = v,
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(FontAwesomeIcons.plus), findsOneWidget,
            reason: 'variant $variant should render a + control when editable');
        expect(find.byIcon(FontAwesomeIcons.minus), findsOneWidget);

        await tester.tap(find.byIcon(FontAwesomeIcons.plus));
        await tester.pump();
        expect(decodeValue(captured!), 6,
            reason: 'variant $variant + should increment the value');

        captured = null;
        await tester.tap(find.byIcon(FontAwesomeIcons.minus));
        await tester.pump();
        expect(decodeValue(captured!), 4,
            reason: 'variant $variant - should decrement the value');
      },
    );
  }

  testWidgets('static edit type renders no +/- controls (nothing to test)',
      (tester) async {
    var emitted = false;
    await tester.pumpWidget(harness(
      statConfiguration: hpStat(CharacterStatEditType.static),
      characterValue: hpValue(value: 5, maxValue: 10, variant: 0),
      onNewStatValue: (_) => emitted = true,
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(FontAwesomeIcons.plus), findsNothing);
    expect(find.byIcon(FontAwesomeIcons.minus), findsNothing);
    expect(emitted, isFalse);
  });

  testWidgets('+ is disabled at the maximum (value cannot exceed maxValue)',
      (tester) async {
    String? captured;
    await tester.pumpWidget(harness(
      statConfiguration: hpStat(CharacterStatEditType.oneTap),
      characterValue: hpValue(value: 10, maxValue: 10, variant: 0),
      onNewStatValue: (v) => captured = v,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(FontAwesomeIcons.plus));
    await tester.pump();
    expect(captured, isNull, reason: '+ at max must not emit a change');
  });

  testWidgets('- is disabled at zero (value cannot go negative)',
      (tester) async {
    String? captured;
    await tester.pumpWidget(harness(
      statConfiguration: hpStat(CharacterStatEditType.oneTap),
      characterValue: hpValue(value: 0, maxValue: 10, variant: 0),
      onNewStatValue: (v) => captured = v,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(FontAwesomeIcons.minus));
    await tester.pump();
    expect(captured, isNull, reason: '- at zero must not emit a change');
  });
}
