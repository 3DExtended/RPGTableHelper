import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
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

  Future<HRResponse<NoteDocumentDto>> getDocument({
    required NoteDocumentIdentifier notedocumentid,
  });

  /// Creates the block last in the document, or right before
  /// [insertBeforeBlockId] (a block of the same document).
  Future<HRResponse<TextBlock>> createNewTextBlockForDocument({
    required TextBlock textBlockToCreate,
    required NoteDocumentIdentifier notedocumentid,
    NoteBlockModelBaseIdentifier? insertBeforeBlockId,
  });

  /// Creates the block last in the document, or right before
  /// [insertBeforeBlockId] (a block of the same document).
  Future<HRResponse<ImageBlock>> createNewImageBlockForDocument({
    required ImageBlock imageBlockToCreate,
    required NoteDocumentIdentifier notedocumentid,
    NoteBlockModelBaseIdentifier? insertBeforeBlockId,
  });

  /// Moves the block right before [beforeBlockId], or to the end of its
  /// document if that is null. Returns the document in its new order.
  Future<HRResponse<NoteDocumentDto>> moveNoteBlock({
    required NoteBlockModelBaseIdentifier blockId,
    NoteBlockModelBaseIdentifier? beforeBlockId,
  });

  /// Turns a text block into an image block with the same text, position and
  /// visibility. The block gets a new id.
  Future<HRResponse<ImageBlock>> attachImageToTextBlock({
    required NoteBlockModelBaseIdentifier blockId,
    required NoteBlockImageDto image,
  });

  /// Turns an image block back into a text block with the same text,
  /// position and visibility. The block gets a new id.
  Future<HRResponse<TextBlock>> removeImageFromImageBlock({
    required NoteBlockModelBaseIdentifier blockId,
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
        api.notesGetdocumentsCampagneidGet(campagneid: campagneId.value!),
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
      required NoteDocumentIdentifier notedocumentid,
      NoteBlockModelBaseIdentifier? insertBeforeBlockId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<ImageBlock>('Could not load api connector.',
          'bcfd688e-3acb-4971-951b-99f9aa737cb5');
    }

    var createResponse = await HRResponse.fromApiFuture(
        api.notesCreateimageblockNotedocumentidPost(
            notedocumentid: notedocumentid.value,
            insertBeforeBlockId: insertBeforeBlockId?.value,
            body: imageBlockToCreate),
        'Could not create image block in document.',
        '3ef467ea-4bd6-4478-af96-0bdb2d1da038');
    return createResponse;
  }

  @override
  Future<HRResponse<TextBlock>> createNewTextBlockForDocument(
      {required TextBlock textBlockToCreate,
      required NoteDocumentIdentifier notedocumentid,
      NoteBlockModelBaseIdentifier? insertBeforeBlockId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<TextBlock>('Could not load api connector.',
          '7a9db512-bd03-48a8-b0f8-b60de7ecff9b');
    }

    var createResponse = await HRResponse.fromApiFuture(
        api.notesCreatetextblockNotedocumentidPost(
            notedocumentid: notedocumentid.value,
            insertBeforeBlockId: insertBeforeBlockId?.value,
            body: textBlockToCreate),
        'Could not create text block in document.',
        '91956dae-503d-4f58-b8c1-5ebd3d860397');
    return createResponse;
  }

  @override
  Future<HRResponse<NoteDocumentDto>> getDocument(
      {required NoteDocumentIdentifier notedocumentid}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<NoteDocumentDto>(
          'Could not load api connector.', '5020026c-5c92-4678-abfb-93d9d7860e33');
    }

    return await HRResponse.fromApiFuture(
        api.notesGetdocumentNotedocumentidGet(
            notedocumentid: notedocumentid.value),
        'Could not load document.',
        '0bdfc9a9-750a-4b73-8097-60b7bc91bea1');
  }

  @override
  Future<HRResponse<NoteDocumentDto>> moveNoteBlock(
      {required NoteBlockModelBaseIdentifier blockId,
      NoteBlockModelBaseIdentifier? beforeBlockId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<NoteDocumentDto>(
          'Could not load api connector.', '976855ae-e22b-40c0-aef3-9be808316beb');
    }

    return await HRResponse.fromApiFuture(
        api.notesMoveblockBlockidPut(
            blockid: blockId.value, beforeblockid: beforeBlockId?.value),
        'Could not move note block.',
        'cf939771-78b3-4169-8403-e2d53922a9b3');
  }

  @override
  Future<HRResponse<ImageBlock>> attachImageToTextBlock(
      {required NoteBlockModelBaseIdentifier blockId,
      required NoteBlockImageDto image}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<ImageBlock>(
          'Could not load api connector.', 'd71722f5-d4c9-404c-aad5-fa074f5dfd6a');
    }

    return await HRResponse.fromApiFuture(
        api.notesAttachimageBlockidPost(blockid: blockId.value, body: image),
        'Could not add the image to the text block.',
        'f0b374b2-4dbf-4190-aa4c-90ac5e990231');
  }

  @override
  Future<HRResponse<TextBlock>> removeImageFromImageBlock(
      {required NoteBlockModelBaseIdentifier blockId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<TextBlock>(
          'Could not load api connector.', '5bab71d5-582c-45e4-8fd6-f57684066cd4');
    }

    return await HRResponse.fromApiFuture(
        api.notesRemoveimageBlockidPost(blockid: blockId.value),
        'Could not remove the image from the block.',
        'bdfaa00a-46bc-4cef-9272-f864358a875d');
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
        api.notesDeleteblockDelete(value: blockIdToDelete.value),
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

  /// When true (Arcane Ledger golden tests), use manuscript-oriented lore fixtures.
  /// Classic goldens keep the default mock documents unchanged.
  static bool preferArcaneLedgerLoreFixtures = false;

  MockNoteDocumentService({
    required super.apiConnectorService,
    this.getDocumentsForCampagneOverride,
  }) : super(isMock: true);

  @override
  Future<HRResponse<List<NoteDocumentDto>>> getDocumentsForCampagne(
      {required CampagneIdentifier campagneId}) {
    if (getDocumentsForCampagneOverride != null) {
      return Future.value(getDocumentsForCampagneOverride);
    }
    final docs = preferArcaneLedgerLoreFixtures
        ? _arcaneLedgerLoreDocuments(campagneId)
        : _classicLoreDocuments(campagneId);
    return Future.value(HRResponse.fromResult(docs));
  }

  List<NoteDocumentDto> _classicLoreDocuments(CampagneIdentifier campagneId) {
    return [

              NoteDocumentDto(
                groupName: "Götter",
                createdForCampagneId: campagneId,
                title: "Skadi",
                creatingUserId: UserIdentifier(
                  value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    value: "0d866abf-8659-4e86-963d-049ee30bb4ed"),
                isDeleted: false,
                creationDate: DateTime(2024, 12, 09, 11, 34),
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 34),
                    id: NoteBlockModelBaseIdentifier(
                        value: "cea440c4-ea51-41ea-9cf4-b6602f9a5356"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    markdownText:
                        "# Zusammenfassung\n\nSkadi ist der Gott der Erde und verstarb vor kurzem. Seine Anhänger waren gering und er wanderte die letzten Jahre scheinbar ohne Ziel im Kreis durch die Wüste. Nachdem er verstarb traten merkwürdige Phänomene auf. Ob die Party herausfindet, woran es liegt?",
                  ),
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 34),
                    id: NoteBlockModelBaseIdentifier(
                        value: "b585ee5e-0cd9-495b-a76c-d45c44d255b0"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [
                      UserIdentifier(
                          value: "f59df7f4-7189-4435-9759-081c11bd887b")
                    ],
                    markdownText:
                        "# Geheimnisse\n\n- Skadis Verschwinden sorgt überall für kleine Probleme und hat die Welt aus dem Gleichgewicht gestürzt.\n- Skadis Amulett ist die einzige Möglichkeit wieder einen Erdgott zu beschwören.\n",
                  ),
                ],
                imageBlocks: [
                  ImageBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 36),
                    id: NoteBlockModelBaseIdentifier(
                        value: "c0792fc0-d2e4-40e4-bfb7-7745fee5c925"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      value: "103df1ac-f15d-4eac-9591-738963377294",
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
                  value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    value: "653862b7-d16e-491d-a4e9-2a3b5321f3a3"),
                isDeleted: false,
                creationDate: DateTime(2024, 12, 09, 11, 34),
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 34),
                    id: NoteBlockModelBaseIdentifier(
                        value: "87f6b71c-ea8c-4401-81dd-d05c218a731e"),
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
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 36),
                    id: NoteBlockModelBaseIdentifier(
                        value: "56204fda-b632-415c-a458-d8c1f6b77c5f"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      value: "103df1ac-f15d-4eac-9591-738963377294",
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
                  value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    value: "d66468af-6b88-441c-b3ee-71e94aa31d95"),
                isDeleted: false,
                creationDate: DateTime(2024, 12, 09, 11, 34),
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 34),
                    id: NoteBlockModelBaseIdentifier(
                        value: "9d73e7a6-3ad2-48c6-9d07-31966544a238"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    markdownText: "Alles mist...",
                  ),
                ],
                imageBlocks: [
                  ImageBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 36),
                    id: NoteBlockModelBaseIdentifier(
                        value: "8a4f729a-b173-4e91-95a8-1c43664a8ed9"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      value: "103df1ac-f15d-4eac-9591-738963377294",
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
                  value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    value: "8cf96452-bd2e-4385-b18d-50d174e8d5a5"),
                isDeleted: false,
                creationDate: DateTime(2024, 12, 09, 11, 34),
                lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 34),
                    id: NoteBlockModelBaseIdentifier(
                        value: "ac3f1595-3ac4-414e-95f7-ef993eb077f3"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    markdownText: "Alles mist...",
                  ),
                ],
                imageBlocks: [
                  ImageBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 12, 09, 11, 36),
                    id: NoteBlockModelBaseIdentifier(
                        value: "e8f81849-c552-4750-99ba-37a8bdeceec2"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      value: "103df1ac-f15d-4eac-9591-738963377294",
                    ),
                    publicImageUrl:
                        "http://localhost:5012/public/getimage/c2c55b14-3219-4503-92c6-3ab42a805828/UDnlBY0EA9XZxlfm2HdEbwAQM7ym5amQOTTL3Ivl008=",
                  ),
                ],
              ),
    ];
  }

  List<NoteDocumentDto> _arcaneLedgerLoreDocuments(CampagneIdentifier campagneId) {
    return [

              NoteDocumentDto(
                groupName: "Götter",
                createdForCampagneId: campagneId,
                title: "Skadi",
                creatingUserId: UserIdentifier(
                  value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    value: "0d866abf-8659-4e86-963d-049ee30bb4ed"),
                isDeleted: false,
                creationDate: DateTime(2024, 5, 20, 14, 47),
                lastModifiedAt: DateTime(2024, 5, 20, 14, 47),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 5, 20, 14, 47),
                    id: NoteBlockModelBaseIdentifier(
                        value: "cea440c4-ea51-41ea-9cf4-b6602f9a5356"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 5, 20, 14, 47),
                    permittedUsers: [],
                    markdownText:
                        "# Zusammenfassung\n\nSkadi ist die Göttin des Winters und der Jagd. Geboren in den eisigen Weiten Jotunheims, schloss sie nach dem Tod ihres Vaters einen Pakt mit den Asen. Ihre Anhänger sind wenige, doch wer ihren Segen trägt, findet den Weg auch durch die kälteste Nacht.",
                  ),
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 5, 20, 14, 48),
                    id: NoteBlockModelBaseIdentifier(
                        value: "b585ee5e-0cd9-495b-a76c-d45c44d255b0"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 5, 20, 14, 48),
                    permittedUsers: [
                      UserIdentifier(
                          value: "f59df7f4-7189-4435-9759-081c11bd887b")
                    ],
                    markdownText:
                        "# Geheimnisse\n\n- Skadi besitzt einen Bogen aus Eis, der nie taut und jeden Pfeil unfehlbar macht.\n- Sie kennt einen geheimen Pfad durch die Berge, den nur Winterwölfe finden.\n- Ein uralter Riese schwor ihr einst ewige Treue und wartet noch immer auf ihren Ruf.\n- Skadi sammelt die Tränen derer, die im Schnee verloren gingen.\n",
                  ),
                ],
                imageBlocks: [
                  ImageBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 5, 20, 14, 49),
                    id: NoteBlockModelBaseIdentifier(
                        value: "c0792fc0-d2e4-40e4-bfb7-7745fee5c925"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 5, 20, 14, 49),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      value: "103df1ac-f15d-4eac-9591-738963377294",
                    ),
                    publicImageUrl:
                        "http://localhost:5012/public/getimage/c2c55b14-3219-4503-92c6-3ab42a805828/UDnlBY0EA9XZxlfm2HdEbwAQM7ym5amQOTTL3Ivl008=",
                  ),
                ],
              ),
              ..._mockLoreIndexEntries(campagneId),
              NoteDocumentDto(
                groupName: "Session Notes",
                createdForCampagneId: campagneId,
                title: "Session #1",
                creatingUserId: UserIdentifier(
                  value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    value: "653862b7-d16e-491d-a4e9-2a3b5321f3a3"),
                isDeleted: false,
                creationDate: DateTime(2024, 5, 20, 14, 47),
                lastModifiedAt: DateTime(2024, 5, 20, 14, 47),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 5, 20, 14, 47),
                    id: NoteBlockModelBaseIdentifier(
                        value: "87f6b71c-ea8c-4401-81dd-d05c218a731e"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 5, 20, 14, 47),
                    permittedUsers: [],
                    markdownText:
                        "# Zusammenfassung\n\nWir stecken in starken Schwierigkeiten.",
                  ),
                ],
                imageBlocks: [
                  ImageBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 5, 20, 14, 49),
                    id: NoteBlockModelBaseIdentifier(
                        value: "56204fda-b632-415c-a458-d8c1f6b77c5f"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 5, 20, 14, 49),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      value: "103df1ac-f15d-4eac-9591-738963377294",
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
                  value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                ),
                id: NoteDocumentIdentifier(
                    value: "d66468af-6b88-441c-b3ee-71e94aa31d95"),
                isDeleted: false,
                creationDate: DateTime(2024, 5, 20, 14, 47),
                lastModifiedAt: DateTime(2024, 5, 20, 14, 47),
                textBlocks: [
                  TextBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 5, 20, 14, 47),
                    id: NoteBlockModelBaseIdentifier(
                        value: "9d73e7a6-3ad2-48c6-9d07-31966544a238"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 5, 20, 14, 47),
                    permittedUsers: [],
                    markdownText: "Alles mist...",
                  ),
                ],
                imageBlocks: [
                  ImageBlock(
                    creatingUserId: UserIdentifier(
                      value: "42f36572-e7f4-4bd4-aebc-d06c4bba0818",
                    ),
                    creationDate: DateTime(2024, 5, 20, 14, 49),
                    id: NoteBlockModelBaseIdentifier(
                        value: "8a4f729a-b173-4e91-95a8-1c43664a8ed9"),
                    isDeleted: false,
                    lastModifiedAt: DateTime(2024, 5, 20, 14, 49),
                    permittedUsers: [],
                    imageMetaDataId: ImageMetaDataIdentifier(
                      value: "103df1ac-f15d-4eac-9591-738963377294",
                    ),
                    publicImageUrl:
                        "http://localhost:5012/public/getimage/c2c55b14-3219-4503-92c6-3ab42a805828/UDnlBY0EA9XZxlfm2HdEbwAQM7ym5amQOTTL3Ivl008=",
                  ),
                ],
              ),
    ];
  }

  List<NoteDocumentDto> _mockLoreIndexEntries(CampagneIdentifier campagneId) {
    const creator = "42f36572-e7f4-4bd4-aebc-d06c4bba0818";
    NoteDocumentDto entry({
      required String group,
      required String title,
      required String id,
      required String textBlockId,
    }) {
      return NoteDocumentDto(
        groupName: group,
        createdForCampagneId: campagneId,
        title: title,
        creatingUserId: UserIdentifier(value: creator),
        id: NoteDocumentIdentifier(value: id),
        isDeleted: false,
        creationDate: DateTime(2024, 12, 09, 11, 34),
        lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
        textBlocks: [
          TextBlock(
            creatingUserId: UserIdentifier(value: creator),
            creationDate: DateTime(2024, 12, 09, 11, 34),
            id: NoteBlockModelBaseIdentifier(value: textBlockId),
            isDeleted: false,
            lastModifiedAt: DateTime(2024, 12, 09, 13, 34),
            permittedUsers: [],
            markdownText: '# $title\n\n…',
          ),
        ],
        imageBlocks: [],
      );
    }

    return [
      entry(
          group: 'Götter',
          title: 'Thor',
          id: '11111111-1111-4111-8111-111111111111',
          textBlockId: '11111111-aaaa-4111-8111-111111111111'),
      entry(
          group: 'Götter',
          title: 'Odin',
          id: '22222222-2222-4222-8222-222222222222',
          textBlockId: '22222222-aaaa-4222-8222-222222222222'),
      entry(
          group: 'Götter',
          title: 'Freya',
          id: '33333333-3333-4333-8333-333333333333',
          textBlockId: '33333333-aaaa-4333-8333-333333333333'),
      entry(
          group: 'Götter',
          title: 'Loki',
          id: '44444444-4444-4444-8444-444444444444',
          textBlockId: '44444444-aaaa-4444-8444-444444444444'),
      entry(
          group: 'Other',
          title: 'Die Welten',
          id: '55555555-5555-4555-8555-555555555555',
          textBlockId: '55555555-aaaa-4555-8555-555555555555'),
      entry(
          group: 'Other',
          title: 'Das Nornennetz',
          id: '66666666-6666-4666-8666-666666666666',
          textBlockId: '66666666-aaaa-4666-8666-666666666666'),
      entry(
          group: 'Other',
          title: 'Yggdrasil',
          id: '77777777-7777-4777-8777-777777777777',
          textBlockId: '77777777-aaaa-4777-8777-777777777777'),
    ];
  }

  

  @override
  Future<HRResponse<NoteDocumentIdentifier>> createNewDocumentForCampagne({
    required NoteDocumentDto dto,
  }) {
    return Future.value(HRResponse.fromResult(
        NoteDocumentIdentifier(value: UuidV7().generate())));
  }

  @override
  Future<HRResponse<bool>> updateDocumentForCampagne(
      {required NoteDocumentDto dto}) {
    return Future.value(HRResponse.fromResult(true));
  }

  @override
  Future<HRResponse<ImageBlock>> createNewImageBlockForDocument(
      {required ImageBlock imageBlockToCreate,
      required NoteDocumentIdentifier notedocumentid,
      NoteBlockModelBaseIdentifier? insertBeforeBlockId}) {
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<TextBlock>> createNewTextBlockForDocument(
      {required TextBlock textBlockToCreate,
      required NoteDocumentIdentifier notedocumentid,
      NoteBlockModelBaseIdentifier? insertBeforeBlockId}) {
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<NoteDocumentDto>> getDocument(
      {required NoteDocumentIdentifier notedocumentid}) {
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<NoteDocumentDto>> moveNoteBlock(
      {required NoteBlockModelBaseIdentifier blockId,
      NoteBlockModelBaseIdentifier? beforeBlockId}) {
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<ImageBlock>> attachImageToTextBlock(
      {required NoteBlockModelBaseIdentifier blockId,
      required NoteBlockImageDto image}) {
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<TextBlock>> removeImageFromImageBlock(
      {required NoteBlockModelBaseIdentifier blockId}) {
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
