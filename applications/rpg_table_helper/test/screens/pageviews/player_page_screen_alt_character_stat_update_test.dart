import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_stats_for_tab.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// HP stat on the default "Stats" tab of the base rpg configuration.
const _hpStatUuid = '803f55cb-5d7e-425d-8054-0cb293620481';

RpgCharacterStatValue _hpStatOf(RpgCharacterConfigurationBase char) =>
    char.characterStats.firstWhere((s) => s.statUuid == _hpStatUuid);

int _hpValueOf(RpgCharacterStatValue stat) =>
    (jsonDecode(stat.serializedValue) as Map<String, dynamic>)['value'] as int;

RpgCharacterStatValue _incrementedHp(RpgCharacterStatValue stat) {
  final decoded = jsonDecode(stat.serializedValue) as Map<String, dynamic>;
  decoded['value'] = (decoded['value'] as int) + 1;
  return stat.copyWith(serializedValue: jsonEncode(decoded));
}

void main() {
  testWidgets(
    'editing a stat on an alternate-form character persists every edit, not just the first',
    (tester) async {
      final rpgConfig = RpgConfigurationModel.getBaseConfiguration();

      final altForm = RpgAlternateCharacterConfiguration(
        uuid: 'alt-form-uuid',
        characterName: 'Wolf Form',
        characterStats:
            RpgCharacterConfiguration.getDefaultStats(rpgConfig, false, null),
        transformationComponents: null,
        alternateForm: null,
        isAlternateFormActive: null,
      );

      final mainCharacter =
          RpgCharacterConfiguration.getBaseConfiguration(rpgConfig)
              .copyWith(alternateForm: altForm, isAlternateFormActive: true);

      final container = ProviderContainer(overrides: [
        rpgConfigurationProvider.overrideWith((ref) => RpgConfigurationNotifier(
              decks: AsyncValue.data(rpgConfig),
              ref: ref,
              runningInTests: true,
            )),
        rpgCharacterConfigurationProvider.overrideWith(
          (ref) => RpgCharacterConfigurationNotifier(
            decks: AsyncValue.data(mainCharacter),
            ref: ref,
            runningInTests: true,
          ),
        ),
        connectionDetailsProvider.overrideWith(
          (ref) => ConnectionDetailsNotifier(
            initState: AsyncValue.data(ConnectionDetails.defaultValue()),
            ref: ref,
            runningInTests: true,
          ),
        ),
      ]);
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
                supportedLocales: AppLocalizations.supportedLocales,
                home: DependencyProvider.getMockedDependecyProvider(
                  child: Scaffold(
                    body: PlayerPageScreen(
                      startScreenOverride: 1,
                      routeSettings: PlayerPageScreenRouteSettings(
                        characterConfigurationOverride: altForm,
                        showInventory: false,
                        showRecipes: false,
                        showMoney: false,
                        showLore: false,
                        disableEdit: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The tab exposing the HP stat — may not be the first
      // PlayerScreenCharacterStatsForTab built, so search for it explicitly.
      PlayerScreenCharacterStatsForTab statsTabWithHp() {
        final matches =
            tester.widgetList<PlayerScreenCharacterStatsForTab>(
                find.byType(PlayerScreenCharacterStatsForTab));
        return matches.firstWhere(
          (w) => w.charToRender?.characterStats
                  .any((s) => s.statUuid == _hpStatUuid) ??
              false,
        );
      }

      final initialHp = _hpValueOf(_hpStatOf(statsTabWithHp().charToRender!));

      // First edit ("tap +") — mirrors the real UI reading the currently
      // rendered stat value off charToRender to compute the new value.
      statsTabWithHp()
          .onStatValueChanged(_incrementedHp(_hpStatOf(statsTabWithHp().charToRender!)));
      await tester.pump();

      // Second edit from the freshly rebuilt widget instance — this is the
      // exact step that silently no-oped before the fix, because the stale
      // frozen charToRender kept recomputing the same target value.
      statsTabWithHp()
          .onStatValueChanged(_incrementedHp(_hpStatOf(statsTabWithHp().charToRender!)));
      await tester.pump();
      // Flush the debounce timer DynamicHeightColumnLayout schedules on
      // layout changes so the framework doesn't flag it as leaked at teardown.
      await tester.pump(const Duration(milliseconds: 50));

      final persistedAltForm =
          container.read(rpgCharacterConfigurationProvider).value!.alternateForm!;
      final finalHp = _hpValueOf(_hpStatOf(persistedAltForm));

      expect(finalHp, initialHp + 2,
          reason:
              'both stat edits on the alternate-form character should be persisted, not just the first');
    },
  );
}
