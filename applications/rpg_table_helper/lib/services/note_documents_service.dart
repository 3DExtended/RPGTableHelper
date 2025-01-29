import 'package:rpg_table_helper/generated/swaggen/swagger.swagger.dart';
import 'package:rpg_table_helper/models/humanreadable_response.dart';
import 'package:rpg_table_helper/services/auth/api_connector_service.dart';
import 'package:uuid/v7.dart';

abstract class INoteDocumentService {
  final bool isMock;

  final IApiConnectorService apiConnectorService;

  const INoteDocumentService({
    required this.isMock,
    required this.apiConnectorService,
  });

  Future<HRResponse<List<NoteDocumentDto>>> getDocumentsForCampagne(
      {required CampagneIdentifier campagneId});

  Future<HRResponse<NoteDocumentIdentifier>> createNewDocumentForCampagne({
    required NoteDocumentDto dto,
  });

  Future<HRResponse<bool>> updateDocumentForCampagne({
    required NoteDocumentDto dto,
  });

  Future<HRResponse<TextBlock>> createNewTextBlockForDocument({
    required TextBlock textBlockToCreate,
    required NoteDocumentIdentifier notedocumentid,
  });

  Future<HRResponse<ImageBlock>> createNewImageBlockForDocument({
    required ImageBlock imageBlockToCreate,
    required NoteDocumentIdentifier notedocumentid,
  });

  Future<HRResponse<bool>> updateTextBlock({
    required TextBlock textBlockToUpdate,
  });

  Future<HRResponse<bool>> updateImageBlock({
    required ImageBlock imageBlockToUpdate,
  });

  Future<HRResponse<bool>> deleteNoteBlock({
    required NoteBlockModelBaseIdentifier blockIdToDelete,
  });
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

  @override
  Future<HRResponse<NoteDocumentIdentifier>> createNewDocumentForCampagne({
    required NoteDocumentDto dto,
  }) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<NoteDocumentIdentifier>(
          'Could not load api connector.',
          '5fc80da3-53df-422b-bd67-3b7591d54f8c');
    }

    var documentCreateResponse = await HRResponse.fromApiFuture(
        api.notesCreatedocumentPost(body: dto),
        'Could not create new document for campagne.',
        '82b9e2b6-27bb-4a10-8dbe-988abed7a4c4');

    return documentCreateResponse;
  }

  @override
  Future<HRResponse<bool>> updateDocumentForCampagne(
      {required NoteDocumentDto dto}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<bool>('Could not load api connector.',
          'c7d22948-f849-4f24-8a1f-e71a036cc594');
    }

    var updateResponse = await HRResponse.fromApiFuture(
        api.notesUpdatenotePut(body: dto),
        'Could not update document for campagne.',
        '1dc9e1d5-a5ab-42da-b706-dd55b1626cae');

    if (updateResponse.isSuccessful) {
      return HRResponse.fromResult(true);
    } else {
      return HRResponse.error<bool>('Could not update document for campagne.',
          '1dc9e1d5-a5ab-42da-b706-dd55b1626cae',
          statusCode: updateResponse.statusCode);
    }
  }

  @override
  Future<HRResponse<ImageBlock>> createNewImageBlockForDocument(
      {required ImageBlock imageBlockToCreate,
      required NoteDocumentIdentifier notedocumentid}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<ImageBlock>('Could not load api connector.',
          'bcfd688e-3acb-4971-951b-99f9aa737cb5');
    }

    var createResponse = await HRResponse.fromApiFuture(
        api.notesCreateimageblockNotedocumentidPost(
            notedocumentid: notedocumentid.$value, body: imageBlockToCreate),
        'Could not create image block in document.',
        '3ef467ea-4bd6-4478-af96-0bdb2d1da038');
    return createResponse;
  }

  @override
  Future<HRResponse<TextBlock>> createNewTextBlockForDocument(
      {required TextBlock textBlockToCreate,
      required NoteDocumentIdentifier notedocumentid}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<TextBlock>('Could not load api connector.',
          '7a9db512-bd03-48a8-b0f8-b60de7ecff9b');
    }

    var createResponse = await HRResponse.fromApiFuture(
        api.notesCreatetextblockNotedocumentidPost(
            notedocumentid: notedocumentid.$value, body: textBlockToCreate),
        'Could not create text block in document.',
        '91956dae-503d-4f58-b8c1-5ebd3d860397');
    return createResponse;
  }

  @override
  Future<HRResponse<bool>> deleteNoteBlock(
      {required NoteBlockModelBaseIdentifier blockIdToDelete}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<bool>('Could not load api connector.',
          '444b293f-bae6-4fe3-9d2b-63474cccaaaa');
    }

    var deleteResponse = await HRResponse.fromApiFuture(
        api.notesDeleteblockDelete($Value: blockIdToDelete.$value),
        'Could not delete note block in document.',
        'e1ba988c-d38a-4427-a995-da915b3f4155');

    if (deleteResponse.isSuccessful) {
      return HRResponse.fromResult(true);
    } else {
      return HRResponse.error<bool>('Could not delete note block in document.',
          'c13378d5-717f-496c-b8c0-f8b8eb40ac34',
          statusCode: deleteResponse.statusCode);
    }
  }

  @override
  Future<HRResponse<bool>> updateImageBlock(
      {required ImageBlock imageBlockToUpdate}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<bool>('Could not load api connector.',
          '4f004de6-1e86-41b1-8319-45084079dcbb');
    }

    var deleteResponse = await HRResponse.fromApiFuture(
        api.notesUpdateimageblockPut(body: imageBlockToUpdate),
        'Could not update image block in document.',
        'b43fc09f-b3ba-48d6-a692-7af65d90275f');

    if (deleteResponse.isSuccessful) {
      return HRResponse.fromResult(true);
    } else {
      return HRResponse.error<bool>('Could not update image block in document.',
          '0a6fcb54-3cfb-4d27-8a8e-7660dafcfcd1',
          statusCode: deleteResponse.statusCode);
    }
  }

  @override
  Future<HRResponse<bool>> updateTextBlock(
      {required TextBlock textBlockToUpdate}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<bool>('Could not load api connector.',
          'c69ac7d9-3a15-4f8b-b71e-a62a7fcf1546');
    }

    var deleteResponse = await HRResponse.fromApiFuture(
        api.notesUpdatetextblockPut(body: textBlockToUpdate),
        'Could not update text block in document.',
        '71d394d8-aa74-4c45-9193-e49d7995d666');

    if (deleteResponse.isSuccessful) {
      return HRResponse.fromResult(true);
    } else {
      return HRResponse.error<bool>('Could not update text block in document.',
          '4247f7c5-3076-4699-bf8f-a70c02f24d82',
          statusCode: deleteResponse.statusCode);
    }
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
    return Future.value(
      getDocumentsForCampagneOverride ??
          HRResponse.fromResult(
            [
              NoteDocumentDto(
                groupName: "Götter",
                createdForCampagneId: campagneId,
                title: "Skadi",
                creatingUserId: UserIdentifier(
                  $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    $value: "0d866abf-8659-4e86-963d-049ee30bb4ed"),
                isDeleted: false,
                creationDate: DateTime(2024, 12, 09, 11, 34),
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 34),
                    id: NoteBlockModelBaseIdentifier(
                        $value: "cea440c4-ea51-41ea-9cf4-b6602f9a5356"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    markdownText:
                        "# Zusammenfassung\n\nSkadi ist der Gott der Erde und verstarb vor kurzem. Seine Anhänger waren gering und er wanderte die letzten Jahre scheinbar ohne Ziel im Kreis durch die Wüste. Nachdem er verstarb traten merkwürdige Phänomene auf. Ob die Party herausfindet, woran es liegt?",
                  ),
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 34),
                    id: NoteBlockModelBaseIdentifier(
                        $value: "b585ee5e-0cd9-495b-a76c-d45c44d255b0"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [
                      UserIdentifier(
                          $value: "f59df7f4-7189-4435-9759-081c11bd887b")
                    ],
                    markdownText:
                        "# Geheimnisse\n\n- Skadis Verschwinden sorgt überall für kleine Probleme und hat die Welt aus dem Gleichgewicht gestürzt.\n- Skadis Amulett ist die einzige Möglichkeit wieder einen Erdgott zu beschwören.\n",
                  ),
                ],
                imageBlocks: [
                  ImageBlock(
                    creatingUserId: UserIdentifier(
                      $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 36),
                    id: NoteBlockModelBaseIdentifier(
                        $value: "c0792fc0-d2e4-40e4-bfb7-7745fee5c925"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      $value: "103df1ac-f15d-4eac-9591-738963377294",
                    ),
                    publicImageUrl:
                        "http://localhost:5012/public/getimage/c2c55b14-3219-4503-92c6-3ab42a805828/UDnlBY0EA9XZxlfm2HdEbwAQM7ym5amQOTTL3Ivl008=",
                  ),
                ],
              ),
              NoteDocumentDto(
                groupName: "Session Notes",
                createdForCampagneId: campagneId,
                title: "Session #1",
                creatingUserId: UserIdentifier(
                  $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    $value: "653862b7-d16e-491d-a4e9-2a3b5321f3a3"),
                isDeleted: false,
                creationDate: DateTime(2024, 12, 09, 11, 34),
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 34),
                    id: NoteBlockModelBaseIdentifier(
                        $value: "87f6b71c-ea8c-4401-81dd-d05c218a731e"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    markdownText:
                        "# Zusammenfassung\n\nWir stecken in starken Schwierigkeiten.",
                  ),
                ],
                imageBlocks: [
                  ImageBlock(
                    creatingUserId: UserIdentifier(
                      $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 36),
                    id: NoteBlockModelBaseIdentifier(
                        $value: "56204fda-b632-415c-a458-d8c1f6b77c5f"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      $value: "103df1ac-f15d-4eac-9591-738963377294",
                    ),
                    publicImageUrl:
                        "http://localhost:5012/public/getimage/c2c55b14-3219-4503-92c6-3ab42a805828/UDnlBY0EA9XZxlfm2HdEbwAQM7ym5amQOTTL3Ivl008=",
                  ),
                ],
              ),
              NoteDocumentDto(
                groupName: "Session Notes",
                createdForCampagneId: campagneId,
                title: "Session #2",
                creatingUserId: UserIdentifier(
                  $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    $value: "d66468af-6b88-441c-b3ee-71e94aa31d95"),
                isDeleted: false,
                creationDate: DateTime(2024, 12, 09, 11, 34),
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 34),
                    id: NoteBlockModelBaseIdentifier(
                        $value: "9d73e7a6-3ad2-48c6-9d07-31966544a238"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    markdownText: "Alles mist...",
                  ),
                ],
                imageBlocks: [
                  ImageBlock(
                    creatingUserId: UserIdentifier(
                      $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 36),
                    id: NoteBlockModelBaseIdentifier(
                        $value: "8a4f729a-b173-4e91-95a8-1c43664a8ed9"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      $value: "103df1ac-f15d-4eac-9591-738963377294",
                    ),
                    publicImageUrl:
                        "http://localhost:5012/public/getimage/c2c55b14-3219-4503-92c6-3ab42a805828/UDnlBY0EA9XZxlfm2HdEbwAQM7ym5amQOTTL3Ivl008=",
                  ),
                ],
              ),
              NoteDocumentDto(
                groupName: "Session Notes",
                createdForCampagneId: campagneId,
                title: "Session #3 - Was ein crazy ride, junge junge junge",
                creatingUserId: UserIdentifier(
                  $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    $value: "8cf96452-bd2e-4385-b18d-50d174e8d5a5"),
                isDeleted: false,
                creationDate: DateTime(2024, 12, 09, 11, 34),
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 34),
                    id: NoteBlockModelBaseIdentifier(
                        $value: "ac3f1595-3ac4-414e-95f7-ef993eb077f3"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    markdownText: "Alles mist...",
                  ),
                ],
                imageBlocks: [
                  ImageBlock(
                    creatingUserId: UserIdentifier(
                      $value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 36),
                    id: NoteBlockModelBaseIdentifier(
                        $value: "e8f81849-c552-4750-99ba-37a8bdeceec2"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      $value: "103df1ac-f15d-4eac-9591-738963377294",
                    ),
                    publicImageUrl:
                        "http://localhost:5012/public/getimage/c2c55b14-3219-4503-92c6-3ab42a805828/UDnlBY0EA9XZxlfm2HdEbwAQM7ym5amQOTTL3Ivl008=",
                  ),
                ],
              ),
            ],
          ),
    );
  }

  @override
  Future<HRResponse<NoteDocumentIdentifier>> createNewDocumentForCampagne({
    required NoteDocumentDto dto,
  }) {
    return Future.value(HRResponse.fromResult(
        NoteDocumentIdentifier($value: UuidV7().generate())));
  }

  @override
  Future<HRResponse<bool>> updateDocumentForCampagne(
      {required NoteDocumentDto dto}) {
    return Future.value(HRResponse.fromResult(true));
  }

  @override
  Future<HRResponse<ImageBlock>> createNewImageBlockForDocument(
      {required ImageBlock imageBlockToCreate,
      required NoteDocumentIdentifier notedocumentid}) {
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<TextBlock>> createNewTextBlockForDocument(
      {required TextBlock textBlockToCreate,
      required NoteDocumentIdentifier notedocumentid}) {
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<bool>> deleteNoteBlock(
      {required NoteBlockModelBaseIdentifier blockIdToDelete}) {
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<bool>> updateImageBlock(
      {required ImageBlock imageBlockToUpdate}) {
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<bool>> updateTextBlock(
      {required TextBlock textBlockToUpdate}) {
    throw UnimplementedError();
  }
}
