import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/dm_character_card_settings.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_screen_character_overview.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/dm_character_card_settings_store.dart';

const _campagneId = "campagne-1";

OpenPlayerConnection _player(
  RpgCharacterConfiguration character, {
  required bool online,
}) => OpenPlayerConnection(
  lastPing: online ? DateTime(2026, 11, 14, 9) : null,
  userId: UserIdentifier(value: "user-${character.uuid}"),
  playerCharacterId: PlayerCharacterIdentifier(value: character.uuid),
  configuration: character,
);

ConnectionDetails _details(List<OpenPlayerConnection> players) =>
    ConnectionDetails.defaultValue().copyWith(
      isDm: true,
      isInSession: true,
      campagneId: _campagneId,
      connectedPlayers: players,
    );

/// The modal's shadow draws its content a second time; tap the real one.
Finder _inModal(Finder finder) => finder.last;

void main() {
  final config = RpgConfigurationModel.getBaseConfiguration();
  // Comes with the companion "Lucky".
  final kardan = RpgCharacterConfiguration.getBaseConfiguration(config)
      .copyWith(uuid: "kardan", characterName: "Kardan");

  Future<(ProviderContainer, InMemoryDmCharacterCardSettingsStore)> pump(
    WidgetTester tester, {
    Map<String, DmCharacterCardSettings>? stored,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var store = InMemoryDmCharacterCardSettingsStore(stored);
    var container = ProviderContainer(
      overrides: [
        dmCharacterCardSettingsStoreProvider.overrideWithValue(store),
        rpgConfigurationProvider.overrideWith(
          (ref) => RpgConfigurationNotifier(
            decks: AsyncValue.data(config),
            ref: ref,
            runningInTests: true,
          ),
        ),
        connectionDetailsProvider.overrideWith(
          (ref) => ConnectionDetailsNotifier(
            initState: AsyncValue.data(
              _details([_player(kardan, online: true)]),
            ),
            ref: ref,
            runningInTests: true,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
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
                  child: const Scaffold(body: DmScreenCharacterOverview()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (container, store);
  }

  void setOnline(ProviderContainer container, bool online) {
    container
        .read(connectionDetailsProvider.notifier)
        .updateConfiguration(_details([_player(kardan, online: online)]));
  }

  testWidgets('shows the character and its companion by default', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text("Kardan"), findsOneWidget);
    expect(find.text("Lucky"), findsOneWidget);
    expect(find.byKey(const ValueKey("dmHiddenCardsCount")), findsNothing);
  });

  testWidgets('a stored hidden companion stays hidden after going offline', (
    tester,
  ) async {
    var (container, _) = await pump(
      tester,
      stored: {
        _campagneId: DmCharacterCardSettings(
          hiddenCharacterUuids: {"f6af1852-e928-4a4f-8d07-93ce87b879e8"},
        ),
      },
    );

    expect(find.text("Kardan"), findsOneWidget);
    expect(find.text("Lucky"), findsNothing);
    expect(find.text("Ausgeblendet: 1"), findsOneWidget);

    setOnline(container, false);
    await tester.pumpAndSettle();
    expect(find.text("Aktuell keine Spieler online"), findsOneWidget);

    setOnline(container, true);
    await tester.pumpAndSettle();
    expect(find.text("Kardan"), findsOneWidget);
    expect(find.text("Lucky"), findsNothing);
  });

  testWidgets('hiding every card says so', (tester) async {
    await pump(
      tester,
      stored: {
        _campagneId: DmCharacterCardSettings(
          hiddenCharacterUuids: {
            "kardan",
            "f6af1852-e928-4a4f-8d07-93ce87b879e8",
          },
        ),
      },
    );

    expect(find.text("Alle Karten sind ausgeblendet"), findsOneWidget);
    expect(find.text("Ausgeblendet: 2"), findsOneWidget);
  });

  testWidgets('the DM hides a card and picks the card stats in the dialog', (
    tester,
  ) async {
    var (_, store) = await pump(tester);

    await tester.tap(find.byKey(const ValueKey("dmCustomizeCardsButton")));
    await tester.pumpAndSettle();
    // Hide the companion.
    await tester.tap(
      _inModal(
        find.byKey(
          const ValueKey("dmCardVisible_f6af1852-e928-4a4f-8d07-93ce87b879e8"),
        ),
      ),
    );
    // Choose the stats: starts from the automatic ones (AC, SP, Temp HP, ÜB).
    await tester.tap(
      _inModal(find.byKey(const ValueKey("dmCardUseCustomStats"))),
    );
    await tester.pumpAndSettle();
    var wisdomCalculated = find.byKey(
      const ValueKey(
        "dmCardNumber_44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3|167b94e6-d674-43a4-a25b-fca1309a12b0|otherValue",
      ),
    );
    await tester.ensureVisible(wisdomCalculated.last);
    await tester.pumpAndSettle();
    await tester.tap(_inModal(wisdomCalculated));
    await tester.pumpAndSettle();

    await tester.tap(_inModal(find.text("Speichern")));
    await tester.pumpAndSettle();

    var saved = store.entries[_campagneId]!;
    expect(saved.hiddenCharacterUuids, {
      "f6af1852-e928-4a4f-8d07-93ce87b879e8",
    });
    expect(saved.useCustomStats, isTrue);
    expect(saved.barStatUuid, "803f55cb-5d7e-425d-8054-0cb293620481");
    expect(saved.numberStats.length, 5);

    expect(find.text("Lucky"), findsNothing);
    expect(find.text("Weisheit (ber.): -1"), findsOneWidget);
  });
}
