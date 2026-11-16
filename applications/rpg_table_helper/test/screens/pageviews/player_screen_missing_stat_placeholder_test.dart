import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/missing_stat_placeholder.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_stats_for_tab.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// "Später ausfüllen" in the character form leaves properties without a
/// value. The sheet must still show them, or the player has no way back.
void main() {
  final rpgConfig = RpgConfigurationModel.getBaseConfiguration();
  final baseCharacter = RpgCharacterConfiguration.getBaseConfiguration(
    rpgConfig,
  );
  bool hasValue(String statUuid) =>
      baseCharacter.characterStats.any((v) => v.statUuid == statUuid);
  // A tab with a named, non-computed property the base character has filled in.
  final tab = rpgConfig.characterStatTabsDefinition!.firstWhere(
    (t) => t.statsInTab.any(
      (s) =>
          !StatNumbers.isComputed(s) &&
          s.name.trim().isNotEmpty &&
          hasValue(s.statUuid),
    ),
  );
  final missingStat = tab.statsInTab.firstWhere(
    (s) =>
        !StatNumbers.isComputed(s) &&
        s.name.trim().isNotEmpty &&
        hasValue(s.statUuid),
  );

  RpgCharacterConfiguration characterWithout(String statUuid) {
    final base = baseCharacter;
    return base.copyWith(
      characterStats: base.characterStats
          .where((s) => s.statUuid != statUuid)
          .toList(),
    );
  }

  Future<void> pumpTab(
    WidgetTester tester, {
    required bool isDm,
    required bool isInSession,
    required RpgCharacterConfiguration character,
  }) async {
    final container = ProviderContainer(
      overrides: [
        rpgConfigurationProvider.overrideWith(
          (ref) => RpgConfigurationNotifier(
            decks: AsyncValue.data(rpgConfig),
            ref: ref,
            runningInTests: true,
          ),
        ),
        rpgCharacterConfigurationProvider.overrideWith(
          (ref) => RpgCharacterConfigurationNotifier(
            decks: AsyncValue.data(character),
            ref: ref,
            runningInTests: true,
          ),
        ),
        connectionDetailsProvider.overrideWith(
          (ref) => ConnectionDetailsNotifier(
            initState: AsyncValue.data(
              ConnectionDetails.defaultValue().copyWith(
                isDm: isDm,
                isInSession: isInSession,
              ),
            ),
            ref: ref,
            runningInTests: true,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      CustomThemeProvider(
        child: UncontrolledProviderScope(
          container: container,
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale('de'),
              supportedLocales: AppLocalizations.supportedLocales,
              home: DependencyProvider.getMockedDependecyProvider(
                child: Scaffold(
                  body: PlayerScreenCharacterStatsForTab(
                    tabDef: tab,
                    rpgConfig: rpgConfig,
                    charToRender: character,
                    onStatValueChanged: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Flush the debounce timer DynamicHeightColumnLayout schedules.
    await tester.pump(const Duration(milliseconds: 50));
  }

  Finder placeholderFor(String name) => find.ancestor(
    of: find.text(name),
    matching: find.byType(MissingStatPlaceholder),
  );

  testWidgets('a property without a value shows a placeholder in the session', (
    tester,
  ) async {
    await pumpTab(
      tester,
      isDm: false,
      isInSession: true,
      character: characterWithout(missingStat.statUuid),
    );

    expect(placeholderFor(missingStat.name), findsOneWidget);
    expect(find.text('Noch leer – tippen zum Ausfüllen'), findsWidgets);
  });

  testWidgets('a filled-in property shows no placeholder', (tester) async {
    await pumpTab(
      tester,
      isDm: false,
      isInSession: true,
      character: baseCharacter,
    );

    expect(placeholderFor(missingStat.name), findsNothing);
  });

  testWidgets('the game master sees no placeholder for a missing property', (
    tester,
  ) async {
    await pumpTab(
      tester,
      isDm: true,
      isInSession: true,
      character: characterWithout(missingStat.statUuid),
    );

    expect(find.byType(MissingStatPlaceholder), findsNothing);
  });

  testWidgets('outside a session there is no placeholder', (tester) async {
    await pumpTab(
      tester,
      isDm: false,
      isInSession: false,
      character: characterWithout(missingStat.statUuid),
    );

    expect(find.byType(MissingStatPlaceholder), findsNothing);
  });
}
