import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_stats/prepared_characters.dart';
import 'package:quest_keeper/helpers/demo_campaign.dart';
import 'package:quest_keeper/helpers/modals/ask_for_new_campagne_name.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_page_screen.dart';
import 'package:quest_keeper/screens/select_game_mode_screen.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/join_requests/pending_join_request_store.dart';
import 'package:quest_keeper/services/note_documents_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_join_rpg_entity_service.dart';
import '../fakes/modal_test_host.dart';

/// Keeps the campagnes it creates, so the screen finds the new one.
class _CreatingRpgEntityService extends FakeJoinRpgEntityService {
  _CreatingRpgEntityService({required super.apiConnectorService})
    : super(campagnes: []);

  final created = <({String name, RpgConfigurationModel config})>[];

  @override
  Future<HRResponse<CampagneIdentifier>> createNewCampagne({
    required String campagneName,
    required RpgConfigurationModel baseConfig,
  }) async {
    created.add((name: campagneName, config: baseConfig));
    final id = CampagneIdentifier(value: 'campagne-demo');
    campagnes!.add(
      Campagne(
        id: id,
        campagneName: campagneName,
        joinCode: '123-456',
        rpgConfiguration: jsonEncode(baseConfig),
      ),
    );
    return HRResponse.fromResult(id);
  }

  @override
  Future<HRResponse<Campagne>> getCampagneById({
    required CampagneIdentifier campagneId,
  }) async => HRResponse.fromResult(
    campagnes!.singleWhere((c) => c.id!.value == campagneId.value),
  );
}

class _RecordingNoteService extends MockNoteDocumentService {
  _RecordingNoteService({required super.apiConnectorService});

  final documents = <NoteDocumentDto>[];
  final blocks = <(String documentId, TextBlock block)>[];

  @override
  Future<HRResponse<NoteDocumentIdentifier>> createNewDocumentForCampagne({
    required NoteDocumentDto dto,
  }) async {
    documents.add(dto);
    return HRResponse.fromResult(NoteDocumentIdentifier(value: 'welcome'));
  }

  @override
  Future<HRResponse<TextBlock>> createNewTextBlockForDocument({
    required TextBlock textBlockToCreate,
    required NoteDocumentIdentifier notedocumentid,
    NoteBlockModelBaseIdentifier? insertBeforeBlockId,
  }) async {
    blocks.add((notedocumentid.value!, textBlockToCreate));
    return HRResponse.fromResult(textBlockToCreate);
  }
}

void main() {
  group('the demo characters', () {
    final config = demoCampaignConfig('Demo-Kampagne');
    final stats = {
      for (final tab in config.characterStatTabsDefinition!)
        for (final stat in tab.statsInTab) stat.statUuid: stat,
    };

    test('sit in the SRD sheet of the demo', () {
      expect(config.rpgName, 'Demo-Kampagne');
      expect(
        RpgConfigurationTemplates.matchingTemplateOf(
          config.copyWith(preparedCharacters: null),
        ),
        RpgConfigurationTemplateId.fantasySrd,
      );
      expect(config.preparedCharacters!.map((c) => c.characterName), [
        'Brom Eisenfaust',
        'Lyra Silbersang',
        'Pip Flinkfuß',
      ]);
    });

    test('have a value of the right shape for fields of the sheet', () {
      for (final character in config.preparedCharacters!) {
        for (final value in character.characterStats) {
          final stat = stats[value.statUuid];
          expect(stat, isNotNull, reason: value.statUuid);
          final json = jsonDecode(value.serializedValue) as Map;
          final additional =
              jsonDecode(stat!.jsonSerializedAdditionalData ?? '{}') as Map;
          switch (stat.valueType) {
            case CharacterStatValueType.multiLineText:
              expect(json['value'], isA<String>());
            case CharacterStatValueType.intWithMaxValue:
              expect(json['value'], json['maxValue']);
            case CharacterStatValueType.multiselect:
              final options = {
                for (final o in additional['options'] as List) o['uuid'],
              };
              expect(
                (json['values'] as List).every(options.contains),
                isTrue,
                reason: '${character.characterName}: ${stat.name}',
              );
            case CharacterStatValueType.listOfIntWithCalculatedValues ||
                CharacterStatValueType.listOfIntsWithIcons ||
                CharacterStatValueType
                    .characterNameWithLevelAndAdditionalDetails:
              final entries = {
                for (final o in additional['values'] as List) o['uuid'],
              };
              expect(
                [for (final v in json['values'] as List) v['uuid']],
                unorderedEquals(entries),
                reason: '${character.characterName}: ${stat.name}',
              );
            default:
              fail('no demo value expected for ${stat.name}');
          }
        }
      }
    });

    test('say who they are in one line', () async {
      final s = await S.load(const Locale('de'));
      expect(
        config.preparedCharacters!.map(
          (c) => preparedCharacterSummary(s, config, c),
        ),
        [
          '${s.level} 1 · Kämpfer · Zwerg',
          '${s.level} 1 · Magierin · Elfe',
          '${s.level} 1 · Schurke · Halbling',
        ],
      );
    });

    test('modifiers follow the attributes', () {
      final brom = config.preparedCharacters!.first;
      final attributes = jsonDecode(
        brom.characterStats
            .singleWhere(
              (v) => v.statUuid == '44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3',
            )
            .serializedValue,
      )['values'] as List;
      expect(
        [for (final a in attributes) (a['value'], a['otherValue'])],
        [(16, 3), (12, 1), (15, 2), (8, -1), (13, 1), (10, 0)],
      );
    });
  });

  testWidgets(
    '"Demo-Kampagne anlegen" creates it with the welcome note and skips the '
    'assistant',
    (tester) async {
      late _CreatingRpgEntityService service;
      late _RecordingNoteService notes;
      final opened = <String>[];
      SharedPreferences.setMockInitialValues({});
      useTabletView(tester);
      await tester.pumpWidget(
        appTestShell(
          providerOverrides: [
            pendingJoinRequestStoreProvider.overrideWithValue(
              InMemoryPendingJoinRequestStore(),
            ),
          ],
          mockOverrides: {
            IRpgEntityService: () => service = _CreatingRpgEntityService(
              apiConnectorService: DependencyProvider.getIt!
                  .get<IApiConnectorService>(),
            ),
            INoteDocumentService: () => notes = _RecordingNoteService(
              apiConnectorService: DependencyProvider.getIt!
                  .get<IApiConnectorService>(),
            ),
          },
          home: const SelectGameModeScreen(),
          // Stand-ins: which pages open is what counts here.
          onGenerateRoute: (settings) {
            opened.add(settings.name!);
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => Scaffold(body: Text('route ${settings.name}')),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(SelectGameModeScreen.runAGamePathKey));
      await tester.pumpAndSettle();
      final demo = find.byKey(AskForNewCampagneNameModalContent.demoButtonKey);
      await tester.ensureVisible(demo.last);
      await tester.pumpAndSettle();
      await tester.tap(demo.last);
      await tester.pumpAndSettle();

      expect(service.created.single.name, 'Demo-Kampagne');
      expect(service.created.single.config.preparedCharacters, hasLength(3));

      expect(notes.documents.single.title, 'Willkommen in der Demo');
      expect(notes.documents.single.groupName, isNotEmpty);
      expect(
        notes.documents.single.createdForCampagneId.value,
        'campagne-demo',
      );
      expect(notes.blocks.single.$1, 'welcome');
      expect(notes.blocks.single.$2.markdownText, contains('Brom, Lyra und Pip'));

      // Set up already: the campaign opens, not the setup assistant.
      expect(opened, [DmPageScreen.route]);
      expect(find.text('route ${DmPageScreen.route}'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    },
  );
}
