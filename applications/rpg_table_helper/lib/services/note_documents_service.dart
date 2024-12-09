import 'package:rpg_table_helper/generated/swaggen/swagger.swagger.dart';
import 'package:rpg_table_helper/models/humanreadable_response.dart';
import 'package:rpg_table_helper/services/auth/api_connector_service.dart';

abstract class INoteDocumentService {
  final bool isMock;

  final IApiConnectorService apiConnectorService;

  const INoteDocumentService({
    required this.isMock,
    required this.apiConnectorService,
  });

  Future<HRResponse<List<NoteDocumentDto>>> getDocumentsForCampagne(
      {required CampagneIdentifier campagneId});
}

class NoteDocumentService extends INoteDocumentService {
  NoteDocumentService({required super.apiConnectorService})
      : super(isMock: false);

  @override
  Future<HRResponse<List<NoteDocumentDto>>> getDocumentsForCampagne(
      {required CampagneIdentifier campagneId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<List<NoteDocumentDto>>(
          'Could not load api connector.',
          '7f283777-4518-44dd-b08b-a9923f9561f5');
    }

    var documentsForUser = await HRResponse.fromApiFuture(
        api.notesGetdocumentsCampagneidGet(campagneid: campagneId.$value!),
        'Could not load documents for campagne and player.',
        '70de032a-ace9-4ac3-8189-698fd5afffe6');

    return documentsForUser;
  }
}

class MockNoteDocumentService extends INoteDocumentService {
  HRResponse<List<NoteDocumentDto>>? getDocumentsForCampagneOverride;

  MockNoteDocumentService({
    required super.apiConnectorService,
    this.getDocumentsForCampagneOverride,
  }) : super(isMock: true);

  @override
  Future<HRResponse<List<NoteDocumentDto>>> getDocumentsForCampagne(
      {required CampagneIdentifier campagneId}) {
    return Future.value(getDocumentsForCampagneOverride ??
        HRResponse.fromResult([
          NoteDocumentDto(
            groupName: "Götter",
            createdForCampagneId: campagneId,
            title: "Skardi",
            creatingUserId: UserIdentifier(
              $value: "a5837386-886e-4d13-8855-30c181238de5",
            ),
            id: NoteDocumentIdentifier(
                $value: "0d866abf-8659-4e86-963d-049ee30bb4ed"),
            isDeleted: false,
            creationDate: DateTime(2024, 12, 09, 11, 34),
            lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
            textBlocks: [
              TextBlock(
                creatingUserId: UserIdentifier(
                  $value: "a5837386-886e-4d13-8855-30c181238de5",
                ),
                creationDate: DateTime(2024, 12, 09, 11, 34),
                id: NoteBlockModelBaseIdentifier(
                    $value: "52854806-336c-456b-aedd-9ae914e3faab"),
                isDeleted: false,
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                visibility: NotesBlockVisibility.visibleforcampagne,
                permittedUsers: [],
                markdownText:
                    "# Zusammenfassung\n\nSkardi ist der Gott der Erde und verstarb vor kurzem. Seine Anhänger waren gering und er wanderte die letzten Jahre scheinbar ohne Ziel im Kreis durch die Wüste. Nachdem er verstarb traten merkwürdige Phänomene auf. Ob die Party herausfindet, woran es liegt?",
              ),
              TextBlock(
                creatingUserId: UserIdentifier(
                  $value: "a5837386-886e-4d13-8855-30c181238de5",
                ),
                creationDate: DateTime(2024, 12, 09, 11, 34),
                id: NoteBlockModelBaseIdentifier(
                    $value: "52854806-336c-456b-aedd-9ae914e3faab"),
                isDeleted: false,
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                visibility: NotesBlockVisibility.hiddenforallexceptauthor,
                permittedUsers: [],
                markdownText:
                    "# Geheimnisse\n\n- Skardis Verschwinden sorgt überall für kleine Probleme und hat die Welt aus dem Gleichgewicht gestürzt.\n- Skardis Armulett ist die einzige Möglichkeit wieder einen Erdgott zu beschwören.\n",
              ),
            ],
            imageBlocks: [],
          ),
          NoteDocumentDto(
            groupName: "Session Notes",
            createdForCampagneId: campagneId,
            title: "Session #1",
            creatingUserId: UserIdentifier(
              $value: "a5837386-886e-4d13-8855-30c181238de5",
            ),
            id: NoteDocumentIdentifier(
                $value: "653862b7-d16e-491d-a4e9-2a3b5321f3a3"),
            isDeleted: false,
            creationDate: DateTime(2024, 12, 09, 11, 34),
            lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
            textBlocks: [
              TextBlock(
                creatingUserId: UserIdentifier(
                  $value: "a5837386-886e-4d13-8855-30c181238de5",
                ),
                creationDate: DateTime(2024, 12, 09, 11, 34),
                id: NoteBlockModelBaseIdentifier(
                    $value: "52854806-336c-456b-aedd-9ae914e3faab"),
                isDeleted: false,
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                visibility: NotesBlockVisibility.visibleforcampagne,
                permittedUsers: [],
                markdownText:
                    "# Zusammenfassung\n\nWir stecken in starken Schwierigkeiten.",
              ),
            ],
            imageBlocks: [],
          ),
          NoteDocumentDto(
            groupName: "Session Notes",
            createdForCampagneId: campagneId,
            title: "Session #2",
            creatingUserId: UserIdentifier(
              $value: "a5837386-886e-4d13-8855-30c181238de5",
            ),
            id: NoteDocumentIdentifier(
                $value: "d66468af-6b88-441c-b3ee-71e94aa31d95"),
            isDeleted: false,
            creationDate: DateTime(2024, 12, 09, 11, 34),
            lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
            textBlocks: [
              TextBlock(
                creatingUserId: UserIdentifier(
                  $value: "a5837386-886e-4d13-8855-30c181238de5",
                ),
                creationDate: DateTime(2024, 12, 09, 11, 34),
                id: NoteBlockModelBaseIdentifier(
                    $value: "52854806-336c-456b-aedd-9ae914e3faab"),
                isDeleted: false,
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                visibility: NotesBlockVisibility.visibleforcampagne,
                permittedUsers: [],
                markdownText: "Alles mist...",
              ),
            ],
            imageBlocks: [],
          ),
          NoteDocumentDto(
            groupName: "Session Notes",
            createdForCampagneId: campagneId,
            title: "Session #3 - Was ein crazy ride, junge junge junge",
            creatingUserId: UserIdentifier(
              $value: "a5837386-886e-4d13-8855-30c181238de5",
            ),
            id: NoteDocumentIdentifier(
                $value: "8cf96452-bd2e-4385-b18d-50d174e8d5a5"),
            isDeleted: false,
            creationDate: DateTime(2024, 12, 09, 11, 34),
            lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
            textBlocks: [
              TextBlock(
                creatingUserId: UserIdentifier(
                  $value: "a5837386-886e-4d13-8855-30c181238de5",
                ),
                creationDate: DateTime(2024, 12, 09, 11, 34),
                id: NoteBlockModelBaseIdentifier(
                    $value: "52854806-336c-456b-aedd-9ae914e3faab"),
                isDeleted: false,
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                visibility: NotesBlockVisibility.visibleforcampagne,
                permittedUsers: [],
                markdownText: "Alles mist...",
              ),
            ],
            imageBlocks: [],
          ),
        ]));
  }
}
