import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_screen_campagne_management.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/getting_started_checklist.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/getting_started_dismissal_store.dart';
import 'package:quest_keeper/services/note_documents_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fakes/modal_test_host.dart';

/// "Erste Schritte" on the game master's campagne page.
void main() {
  final srd = RpgConfigurationTemplates.fantasySrd();

  test('counts the sheet, the players and the notes', () {
    final fresh = GettingStartedProgress.of(
      config: srd,
      playerCount: 0,
      noteCount: 0,
    );
    expect(
      (fresh.sheetReady, fresh.playersJoined, fresh.hasNote),
      (true, false, false),
    );
    expect(fresh.isComplete, isFalse);
    expect(
      GettingStartedProgress.of(
        config: RpgConfigurationModel.getBaseConfiguration().copyWith(
          characterStatTabsDefinition: [],
        ),
        playerCount: 0,
        noteCount: 0,
      ).sheetReady,
      isFalse,
    );
    expect(
      GettingStartedProgress.of(
        config: srd,
        playerCount: 2,
        noteCount: 1,
      ).isComplete,
      isTrue,
    );
  });

  group('the campagne page', () {
    var openedNotes = 0;

    Future<void> pumpPage(
      WidgetTester tester, {
      List<PlayerCharacter> players = const [],
      int notes = 0,
    }) async {
      openedNotes = 0;
      useTabletView(tester);
      await tester.pumpWidget(
        appTestShell(
          providerOverrides: [
            connectionDetailsProvider.overrideWith(
              (ref) => ConnectionDetailsNotifier(
                initState: AsyncValue.data(
                  ConnectionDetails.defaultValue().copyWith(
                    isDm: true,
                    isInSession: true,
                    campagneId: 'campagne-1',
                    sessionConnectionNumberForPlayers: '699-457',
                    connectedPlayers: const [],
                  ),
                ),
                ref: ref,
                runningInTests: true,
              ),
            ),
            rpgConfigurationProvider.overrideWith(
              (ref) => RpgConfigurationNotifier(
                decks: AsyncValue.data(srd),
                ref: ref,
                runningInTests: true,
              ),
            ),
          ],
          mockOverrides: {
            IRpgEntityService: () => MockRpgEntityService(
              apiConnectorService: DependencyProvider.getIt!
                  .get<IApiConnectorService>(),
              getPlayerCharactersForCampagneOverride: HRResponse.fromResult(
                players,
              ),
            ),
            INoteDocumentService: () => MockNoteDocumentService(
              apiConnectorService: DependencyProvider.getIt!
                  .get<IApiConnectorService>(),
              getDocumentsForCampagneOverride: HRResponse.fromResult([
                for (var i = 0; i < notes; i++)
                  NoteDocumentDto(
                    groupName: 'Notizen',
                    title: 'Notiz $i',
                    createdForCampagneId: CampagneIdentifier(
                      value: 'campagne-1',
                    ),
                    imageBlocks: [],
                    textBlocks: [],
                  ),
              ]),
            ),
          },
          home: Scaffold(
            body: DmScreenCampagneManagement(onOpenNotes: () => openedNotes++),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows what is left and leads there', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await pumpPage(tester);

      expect(find.text(S.current.gettingStartedTitle(1, 3)), findsOneWidget);
      expect(find.text(S.current.gettingStartedSheetAction), findsNothing,
          reason: 'the template already set up the sheet');

      await tester.tap(find.text(S.current.gettingStartedNoteAction));
      await tester.pumpAndSettle();
      expect(openedNotes, 1);

      final invite = find.descendant(
        of: find.byKey(GettingStartedChecklist.playersKey),
        matching: find.text(S.current.gettingStartedPlayersAction),
      );
      await tester.tap(invite);
      await tester.pumpAndSettle();
      expect(find.text('699-457'), findsWidgets, reason: 'the invite sheet');
    });

    testWidgets('can be hidden for the campagne', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await pumpPage(tester, notes: 1);
      expect(find.text(S.current.gettingStartedTitle(2, 3)), findsOneWidget);

      await tester.tap(find.byKey(GettingStartedChecklist.dismissKey));
      await tester.pumpAndSettle();
      expect(find.byType(GettingStartedChecklist), findsNothing);
      expect(await isGettingStartedDismissed('campagne-1'), isTrue);

      // And stays hidden.
      await tester.pumpWidget(const SizedBox());
      await pumpPage(tester, notes: 1);
      expect(find.byType(GettingStartedChecklist), findsNothing);
    });

    testWidgets('disappears once everything is done', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await pumpPage(
        tester,
        notes: 1,
        players: [
          PlayerCharacter(
            id: PlayerCharacterIdentifier(value: 'mira-c'),
            characterName: 'Mira',
            rpgCharacterConfiguration: jsonEncode(
              RpgCharacterConfiguration.getBaseConfiguration(
                srd,
              ).copyWith(characterName: 'Mira'),
            ),
          ),
        ],
      );
      expect(find.text('Mira'), findsWidgets);
      expect(find.byType(GettingStartedChecklist), findsNothing);
    });
  });
}
