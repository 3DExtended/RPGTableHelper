import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/stat_types/option_card.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/player_stats_configuration_visuals.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Choices in the character form are cards with what they mean.
void main() {
  final longText = List.filled(12, 'Ein Lichtblitz blendet alle in der Nähe.')
      .join(' ');

  CharacterStatDefinition stat(CharacterStatValueType type) =>
      CharacterStatDefinition(
        statUuid: 'spells',
        name: 'Zaubertricks',
        helperText: 'Welche Zaubertricks kennst du?',
        groupId: null,
        valueType: type,
        editType: CharacterStatEditType.static,
        isOptionalForAlternateForms: false,
        isOptionalForCompanionCharacters: false,
        jsonSerializedAdditionalData: jsonEncode({
          'options': [
            {'uuid': 'light', 'label': 'Licht', 'description': 'Ein Licht.'},
            {'uuid': 'flash', 'label': 'Blitz', 'description': longText},
          ],
          'multiselectIsAllowedToBeSelectedMultipleTimes': false,
        }),
      );

  Future<List<RpgCharacterStatValue>> pump(
    WidgetTester tester,
    CharacterStatDefinition definition,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final values = <RpgCharacterStatValue>[];

    await tester.pumpWidget(
      CustomThemeProvider(
        overrideBrightness: Brightness.light,
        child: ProviderScope(
          overrides: [
            rpgCharacterConfigurationProvider.overrideWith((ref) =>
                RpgCharacterConfigurationNotifier(
                  decks: AsyncValue.data(
                      RpgCharacterConfiguration.getBaseConfiguration(null)),
                  ref: ref,
                  runningInTests: true,
                )),
          ],
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              locale: const Locale('de'),
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: PlayerStatsConfigurationVisuals(
                    statConfiguration: definition,
                    characterName: 'Mira',
                    characterToRenderStatFor: null,
                    collapsiblePreview: true,
                    onNewStatValue: values.add,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return values;
  }

  bool isSelected(WidgetTester tester, String uuid) => tester
      .widget<OptionCard>(find.byKey(OptionCard.keyFor(uuid)))
      .isSelected;

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('several can be ticked and unticked', (tester) async {
    final values = await pump(tester, stat(CharacterStatValueType.multiselect));
    expect(tester.widget<OptionCard>(find.byKey(OptionCard.keyFor('light'))).multiple,
        isTrue);

    await tap(tester, find.byKey(OptionCard.keyFor('light')));
    await tap(tester, find.byKey(OptionCard.keyFor('flash')));
    expect(isSelected(tester, 'light'), isTrue);
    expect(isSelected(tester, 'flash'), isTrue);

    await tap(tester, find.byKey(OptionCard.keyFor('light')));
    expect(isSelected(tester, 'light'), isFalse);
    expect(values.last.serializedValue, contains('flash'));
    expect(values.last.serializedValue, isNot(contains('light')));
  });

  testWidgets('one of a single select', (tester) async {
    await pump(tester, stat(CharacterStatValueType.singleSelect));

    await tap(tester, find.byKey(OptionCard.keyFor('light')));
    await tap(tester, find.byKey(OptionCard.keyFor('flash')));
    expect(isSelected(tester, 'light'), isFalse);
    expect(isSelected(tester, 'flash'), isTrue);
  });

  testWidgets('a long description opens with "Mehr"', (tester) async {
    await pump(tester, stat(CharacterStatValueType.multiselect));
    Text description() => tester.widget<Text>(find.text(longText));

    expect(find.byKey(OptionCard.moreKeyFor('light')), findsNothing);
    expect(description().maxLines, OptionCard.collapsedLines);

    await tap(tester, find.byKey(OptionCard.moreKeyFor('flash')));
    expect(description().maxLines, isNull);
    expect(find.text('Weniger'), findsOneWidget);
    expect(isSelected(tester, 'flash'), isFalse, reason: '"Mehr" only opens');
  });
}
