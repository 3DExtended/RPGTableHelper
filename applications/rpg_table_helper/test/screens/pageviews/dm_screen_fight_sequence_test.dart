import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/current_fight_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/fight_state.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_screen_fight_squence.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/backend_capabilities_service.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/fights/fight_api_service.dart';
import 'package:quest_keeper/services/server_methods_service.dart';

class _FakeFightApi extends MockFightApiService {
  _FakeFightApi(this.fight);

  FightState? fight;
  final List<List<FightStartParticipant>> starts = [];
  final List<String> calls = [];

  @override
  Future<HRResponse<FightState?>> getCurrentFight(
          {required String campagneId}) async =>
      HRResponse.fromResult(fight);

  @override
  Future<HRResponse<FightState>> startFight({
    required String campagneId,
    required List<FightStartParticipant> participants,
  }) async {
    starts.add(participants);
    return HRResponse.fromResult(fight!);
  }

  @override
  Future<HRResponse<FightState>> removeParticipant({
    required String fightId,
    required String participantId,
  }) async {
    calls.add('remove $participantId');
    return HRResponse.fromResult(fight!);
  }

  @override
  Future<HRResponse<FightState>> endFight({required String fightId}) async {
    calls.add('end');
    return HRResponse.fromResult(FightState(
      id: fightId,
      campagneId: 'camp-1',
      isOpen: false,
      isDmView: true,
      revision: 9,
      participants: const [],
    ));
  }
}

OpenPlayerConnection _player(String name, String id, {required bool online}) {
  return OpenPlayerConnection(
    lastPing: online ? DateTime(2026, 11, 1, 12) : null,
    userId: UserIdentifier(value: 'user-$id'),
    playerCharacterId: PlayerCharacterIdentifier(value: 'pc-$id'),
    configuration: RpgCharacterConfiguration.getBaseConfiguration(
            RpgConfigurationModel.getBaseConfiguration())
        .copyWith(uuid: id, characterName: name, companionCharacters: []),
  );
}

final _openFight = FightState(
  id: 'fight-1',
  campagneId: 'camp-1',
  isOpen: true,
  isDmView: true,
  revision: 2,
  participants: const [
    FightParticipantState(
      id: 'p-frodo',
      kind: FightParticipantKind.character,
      characterUuid: 'frodo',
      playerCharacterId: 'pc-frodo',
      name: 'Frodo',
      roll: 18,
      position: 0,
      isPending: false,
    ),
    FightParticipantState(
      id: 'p-gandalf',
      kind: FightParticipantKind.character,
      characterUuid: 'gandalf',
      playerCharacterId: 'pc-gandalf',
      name: 'Gandalf',
      roll: null,
      position: null,
      isPending: true,
    ),
  ],
);

Future<_FakeFightApi> _pumpScreen(WidgetTester tester,
    {required bool backendKeepsFights, FightState? fight}) async {
  tester.view.physicalSize = const Size(1600, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final fightApi = _FakeFightApi(fight);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        connectionDetailsProvider.overrideWith((ref) {
          return ConnectionDetailsNotifier(
            initState: AsyncValue.data(ConnectionDetails.defaultValue()
                .copyWith(
                    isDm: true,
                    isInSession: true,
                    campagneId: 'camp-1',
                    connectedPlayers: [
                  _player('Frodo', 'frodo', online: true),
                  _player('Gandalf', 'gandalf', online: false),
                ])),
            ref: ref,
            runningInTests: true,
          );
        }),
      ],
      child: DependencyProvider.getMockedDependecyProvider(
        mockOverrides: {
          IFightApiService: () => fightApi,
          IBackendCapabilitiesService: () => MockBackendCapabilitiesService(
                apiConnectorService:
                    DependencyProvider.getIt!.get<IApiConnectorService>(),
                capabilitiesOverride: {
                  ...kBaselineBackendCapabilities,
                  if (backendKeepsFights) BackendCapability.persistedFights,
                },
              ),
        },
        child: CustomThemeProvider(
          overrideBrightness: Brightness.light,
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale('de'),
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: DmScreenFightSquence()),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return fightApi;
}

Future<void> _loadFight(WidgetTester tester) async {
  await DependencyProvider.getIt!.get<IServerMethodsService>().catchUpOnFight();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('offers players who are away when the backend keeps fights',
      (tester) async {
    final fightApi =
        await _pumpScreen(tester, backendKeepsFights: true, fight: _openFight);

    expect(find.text('Charakter: Frodo'), findsOneWidget);
    expect(find.text('Charakter: Gandalf (nicht am Tisch)'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rollForInitiativeButton')));
    await tester.pumpAndSettle();

    expect(fightApi.starts.single.map((p) => (p.characterUuid, p.name)), [
      ('frodo', 'Frodo'),
      ('gandalf', 'Gandalf'),
    ]);
  });

  testWidgets('offers only players at the table with the old flow',
      (tester) async {
    await _pumpScreen(tester, backendKeepsFights: false);

    expect(find.text('Charakter: Frodo'), findsOneWidget);
    expect(find.textContaining('Gandalf'), findsNothing);
  });

  testWidgets('shows who still has to roll and can stop waiting for them',
      (tester) async {
    final fightApi =
        await _pumpScreen(tester, backendKeepsFights: true, fight: _openFight);
    await _loadFight(tester);

    expect(find.text('Wartet auf Initiative'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    // the pending row; the chip on the right reads "Charakter: Gandalf ..."
    expect(find.text('Gandalf'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('removePending_p-gandalf')));
    await tester.pumpAndSettle();

    expect(fightApi.calls, ['remove p-gandalf']);
  });

  testWidgets('ends the fight after confirming', (tester) async {
    final fightApi =
        await _pumpScreen(tester, backendKeepsFights: true, fight: _openFight);
    await _loadFight(tester);

    await tester.tap(find.byKey(const ValueKey('endFightButton')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kampf wirklich beenden?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('endFightConfirm')));
    await tester.pumpAndSettle();

    expect(fightApi.calls, ['end']);
    expect(find.text('Aktuell kein Kampf gestartet'), findsOneWidget);
    final endButton = tester
        .widget<CustomButton>(find.byKey(const ValueKey('endFightButton')));
    expect(endButton.onPressed, isNull);
  });

  testWidgets('keeps the fight when ending is cancelled', (tester) async {
    final fightApi =
        await _pumpScreen(tester, backendKeepsFights: true, fight: _openFight);
    await _loadFight(tester);

    await tester.tap(find.byKey(const ValueKey('endFightButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(fightApi.calls, isEmpty);
    expect(
        ProviderScope.containerOf(
                tester.element(find.byType(DmScreenFightSquence)))
            .read(currentFightProvider),
        isNotNull);
  });
}
