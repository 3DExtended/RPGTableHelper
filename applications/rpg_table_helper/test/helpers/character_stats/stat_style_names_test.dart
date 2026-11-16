import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/get_player_visualization_widget.dart';
import 'package:quest_keeper/helpers/character_stats/player_stats_configuration_visuals.dart';
import 'package:quest_keeper/helpers/character_stats/stat_style_names.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// The style picker names each style instead of showing bare dots.
void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    test('every style has a name ($locale)', () async {
      final s = await S.load(locale);
      for (final type in CharacterStatValueType.values) {
        final names = statStyleNames(s, type);
        expect(names, hasLength(numberOfVariantsForValueTypes(type)),
            reason: '$type');
        expect(names.toSet(), hasLength(names.length),
            reason: 'two styles of $type share a name');
        expect(names.every((n) => n.trim().isNotEmpty), isTrue);
      }
    });
  }

  testWidgets('the picker names the style and steps through them',
      (tester) async {
    tester.view.physicalSize = const Size(2048, 2732);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

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
                    statConfiguration: CharacterStatDefinition(
                      statUuid: 'hp',
                      name: 'TP',
                      helperText: '',
                      groupId: null,
                      valueType: CharacterStatValueType.intWithMaxValue,
                      editType: CharacterStatEditType.oneTap,
                      isOptionalForAlternateForms: false,
                      isOptionalForCompanionCharacters: false,
                    ),
                    characterName: 'Mira',
                    characterToRenderStatFor: null,
                    onNewStatValue: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    String shownName() =>
        tester.widget<Text>(find.byKey(const ValueKey('statStyleName'))).data!;

    expect(shownName(), 'Zahl und Maximum');
    expect(find.text('1 von 9'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('statStyleNext')));
    await tester.pumpAndSettle();
    expect(shownName(), 'Ring');
    expect(find.text('2 von 9'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('statStylePrevious')));
    await tester.pumpAndSettle();
    expect(shownName(), 'Zahl und Maximum');
  });
}
