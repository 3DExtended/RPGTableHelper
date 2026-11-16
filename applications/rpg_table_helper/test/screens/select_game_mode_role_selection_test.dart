import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/modals/ask_for_campagne_join_code.dart';
import 'package:quest_keeper/screens/select_game_mode_screen.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/join_requests/pending_join_request_store.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';

import '../fakes/fake_join_rpg_entity_service.dart';
import '../fakes/modal_test_host.dart';

final _varn = Campagne(
  id: CampagneIdentifier(value: 'campagne-varn'),
  campagneName: 'Die Klingen von Varn',
  joinCode: '699-457',
  lastModifiedAt: DateTime(2026, 11, 16, 14, 15),
);

final _kardan = PlayerCharacter(
  id: PlayerCharacterIdentifier(value: 'kardan'),
  characterName: 'Kardan',
  campagneId: CampagneIdentifier(value: 'campagne-other'),
  lastModifiedAt: DateTime(2026, 11, 15, 20, 5),
);

final _mira = PlayerCharacter(
  id: PlayerCharacterIdentifier(value: 'mira'),
  characterName: 'Mira Dornwald',
);

PendingJoinRequest _pendingFor(String characterId) => PendingJoinRequest(
  playerCharacterId: characterId,
  campagneJoinRequestId: 'request-$characterId',
  joinCode: '699-457',
  requestedAt: DateTime(2026, 11, 16, 14, 20),
);

void main() {
  late FakeJoinRpgEntityService service;
  late InMemoryPendingJoinRequestStore store;

  Future<void> pumpScreen(
    WidgetTester tester, {
    List<Campagne> campagnes = const [],
    List<PlayerCharacter> characters = const [],
    Map<String, int> openJoinRequests = const {},
    Map<String, PendingJoinRequest>? pending,
  }) async {
    store = InMemoryPendingJoinRequestStore(pending);
    useTabletView(tester);
    await tester.pumpWidget(
      appTestShell(
        providerOverrides: [
          pendingJoinRequestStoreProvider.overrideWithValue(store),
        ],
        mockOverrides: {
          IRpgEntityService: () => service = FakeJoinRpgEntityService(
            apiConnectorService: DependencyProvider.getIt!
                .get<IApiConnectorService>(),
            campagnes: [...campagnes],
            characters: [...characters],
            openJoinRequestsByCampagne: openJoinRequests,
          ),
        },
        home: const SelectGameModeScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The join flow polls for the DM's answer; unmount so it ends.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  }

  testWidgets('starts with the two ways in and German counts', (tester) async {
    await pumpScreen(tester, campagnes: [_varn], characters: [_kardan, _mira]);

    expect(find.text('Willkommen bei QuestKeeper'), findsOneWidget);
    expect(find.byKey(SelectGameModeScreen.runAGamePathKey), findsOneWidget);
    expect(find.byKey(SelectGameModeScreen.joinAGamePathKey), findsOneWidget);
    expect(find.text('Ich leite eine Runde'), findsOneWidget);
    expect(find.text('Ich trete einer Runde bei'), findsOneWidget);

    expect(find.text('Du leitest 1 Kampagne.'), findsOneWidget);
    expect(find.text('Du hast 2 Charaktere.'), findsOneWidget);
    expect(find.text('Als Spielleitung'), findsOneWidget);

    expect(find.text('Beitrittscode: 699-457'), findsOneWidget);
    expect(
      find.text('Einstellungen geändert: 16.11.2026, 14:15'),
      findsOneWidget,
    );
    expect(find.text('Zuletzt bearbeitet: 15.11.2026, 20:05'), findsOneWidget);
    expect(
      find.text(
        'Noch in keiner Kampagne. Tippe, um mit einem Code beizutreten.',
      ),
      findsOneWidget,
    );

    // debug and English leftovers are gone
    expect(find.textContaining('Config Length'), findsNothing);
    expect(find.textContaining('Assigned to'), findsNothing);
    expect(find.textContaining('DM'), findsNothing);

    await unmount(tester);
  });

  testWidgets('empty lists offer a labelled way forward', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Du leitest noch keine Kampagne.'), findsOneWidget);
    expect(find.text('Du hast noch keinen Charakter.'), findsOneWidget);
    expect(find.byKey(SelectGameModeScreen.noCampagnesCtaKey), findsOneWidget);
    expect(find.byKey(SelectGameModeScreen.noCharactersCtaKey), findsOneWidget);
    expect(find.text('Kampagne anlegen'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('the DM card shows how many join requests are open', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      campagnes: [_varn],
      openJoinRequests: {'campagne-varn': 2},
    );

    expect(
      find.byKey(const ValueKey('openJoinRequestsBadge-campagne-varn')),
      findsOneWidget,
    );
    expect(find.text('2 offene Anfragen'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets(
    'a pending character shows the waiting badge; tapping it explains '
    'the wait instead of opening the join dialog',
    (tester) async {
      await pumpScreen(
        tester,
        characters: [_mira],
        pending: {'mira': _pendingFor('mira')},
      );

      final badge = find.byKey(const ValueKey('pendingJoinBadge-mira'));
      expect(badge, findsOneWidget);
      expect(
        find.text('Warte auf Freigabe durch die Spielleitung'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Mira Dornwald'));
      await tester.tap(find.text('Mira Dornwald'));
      await tester.pumpAndSettle();

      expect(find.text('Warte auf Freigabe'), findsOneWidget);
      expect(find.byType(AskForCampagneJoinCodeModalContent), findsNothing);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Warte auf Freigabe'), findsNothing);

      // "Code neu eingeben" is the way out after a decline the app missed
      await tester.tap(find.text('Mira Dornwald'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Code neu eingeben'));
      await tester.pumpAndSettle();
      expect(find.byType(AskForCampagneJoinCodeModalContent), findsOneWidget);
      expect(
        find.byKey(AskForCampagneJoinCodeModalContent.nameFieldKey),
        findsNothing,
      );

      await unmount(tester);
    },
  );

  testWidgets('a character that joined clears its pending entry', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      characters: [_kardan],
      pending: {'kardan': _pendingFor('kardan')},
    );

    expect(find.byKey(const ValueKey('pendingJoinBadge-kardan')), findsNothing);
    expect(store.entries, isEmpty);

    await unmount(tester);
  });

  testWidgets(
    'joining: code and name create the character and leave it waiting',
    (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(SelectGameModeScreen.joinAGamePathKey));
      await tester.pumpAndSettle();
      expect(find.byType(AskForCampagneJoinCodeModalContent), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byKey(AskForCampagneJoinCodeModalContent.codeFieldKey),
          matching: find.byType(TextField),
        ),
        '699457',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(AskForCampagneJoinCodeModalContent.nameFieldKey),
          matching: find.byType(TextField),
        ),
        'Mira Dornwald',
      );
      await tester.tap(
        find.byKey(AskForCampagneJoinCodeModalContent.submitButtonKey),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AskForCampagneJoinCodeModalContent), findsNothing);
      expect(service.createdCharacterNames, ['Mira Dornwald']);
      expect(service.joinRequests.single.joinCode, '699-457');

      expect(
        find.text(
          'Anfrage gesendet. Sobald deine Spielleitung zustimmt, kannst du mitspielen.',
        ),
        findsOneWidget,
      );
      expect(find.text('Join Request sent'), findsNothing);

      const id = FakeJoinRpgEntityService.createdCharacterId;
      expect(
        find.byKey(const ValueKey('pendingJoinBadge-$id')),
        findsOneWidget,
      );
      expect(store.entries[id]?.campagneJoinRequestId, 'request-1');
      expect(find.text('Du hast 1 Charakter.'), findsOneWidget);

      await unmount(tester);
    },
  );
}
