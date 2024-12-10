import 'dart:convert';

import 'package:http/http.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.enums.swagger.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/models/humanreadable_response.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/auth/api_connector_service.dart';
import 'package:rpg_table_helper/services/internals/internal_image_upload_service.dart';

abstract class IRpgEntityService {
  final bool isMock;

  final IApiConnectorService apiConnectorService;

  const IRpgEntityService({
    required this.isMock,
    required this.apiConnectorService,
  });

  Future<HRResponse<bool>> handleJoinRequest(
      {required String campagneJoinRequestId,
      required HandleJoinRequestType typeOfHandle});
  Future<HRResponse<List<Campagne>>> getCampagnesWithPlayerAsDm();
  Future<HRResponse<CampagneIdentifier>> saveCampagneAsNewCampagne(
      {required String campagneName, String? rpgConfig});
  Future<HRResponse<List<PlayerCharacter>>> getPlayerCharacetersForPlayer();
  Future<HRResponse<Campagne>> getCampagneById(
      {required CampagneIdentifier campagneId});
  Future<HRResponse<List<PlayerCharacter>>> getPlayerCharactersForCampagne(
      {required CampagneIdentifier campagneId});
  Future<HRResponse<List<NoteDocumentPlayerDescriptorDto>>>
      getUserDetailsForCampagne({required CampagneIdentifier campagneId});

  Future<HRResponse<String>> uploadImageToCampagneStorage({
    required CampagneIdentifier campagneId,
    required MultipartFile image,
  });

  Future<HRResponse<CampagneJoinRequestIdentifier>>
      createNewCampagneJoinRequest(
          {required String joinCode,
          required PlayerCharacterIdentifier playerCharacterId});

  Future<HRResponse<CampagneIdentifier>> createNewCampagne(
      {required String campagneName,
      required RpgConfigurationModel baseConfig});

  Future<HRResponse<List<JoinRequestForCampagneDto>>>
      getOpenJoinRequestsForCampagne({required CampagneIdentifier campagneId});

  Future<HRResponse<PlayerCharacterIdentifier>>
      savePlayerCharacterAsNewCharacter(
          {required String characterName, String? characterConfigJson});
}

class RpgEntityService extends IRpgEntityService {
  RpgEntityService({required super.apiConnectorService}) : super(isMock: false);

  @override
  Future<HRResponse<List<Campagne>>> getCampagnesWithPlayerAsDm() async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<List<Campagne>>('Could not load api connector.',
          'd42cee20-3938-4a8b-b0f8-0a0720ca3c84');
    }

    var campagnesForUser = await HRResponse.fromApiFuture(
        api.campagneGetcampagnesGet(),
        'Could not load campagnes for player.',
        '6361a867-df95-4da2-a21d-c1276369c4d8');

    return campagnesForUser;
  }

  @override
  Future<HRResponse<List<PlayerCharacter>>>
      getPlayerCharacetersForPlayer() async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error('Could not load api connector.',
          '4b44bce7-b6db-42c7-a888-9e6cec76a73e');
    }

    var campagnesForUser = await HRResponse.fromApiFuture(
        api.playerCharacterGetplayercharactersGet(),
        'Could not load player characters for user.',
        'aa4d3c34-e1e9-4fa1-b9c8-249f9f76e5bb');

    return campagnesForUser;
  }

  @override
  Future<HRResponse<CampagneIdentifier>> saveCampagneAsNewCampagne(
      {required String campagneName, String? rpgConfig}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error('Could not load api connector.',
          '874ba02f-93e4-4dcc-99a7-8f95b0f86212');
    }

    var createCampagneResult = await HRResponse.fromApiFuture(
        api.campagneCreatecampagnePost(
          body: CampagneCreateDto(
            campagneName: campagneName,
            rpgConfiguration: rpgConfig,
          ),
        ),
        'Could not create new campagne.',
        '1b73d809-c524-445d-9832-02a1040b63fb');

    return createCampagneResult;
  }

  @override
  Future<HRResponse<bool>> handleJoinRequest(
      {required String campagneJoinRequestId,
      required HandleJoinRequestType typeOfHandle}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error('Could not load api connector.',
          '6fe2d1d8-302a-49d6-a7f4-2bcbe1f3deac');
    }

    var handleCampagneJoinRequestResult = await HRResponse.fromApiFuture(
        api.campagneJoinRequestHandlejoinrequestPost(
          body: HandleJoinRequestDto(
            campagneJoinRequestId: campagneJoinRequestId,
            type: typeOfHandle,
          ),
        ),
        'Could not handle campagne join request.',
        'c3100c78-81a2-4a01-bb55-e5cad110fd4b');

    if (!handleCampagneJoinRequestResult.isSuccessful) {
      return handleCampagneJoinRequestResult.asT();
    }

    return HRResponse.fromResult(true,
        statusCode: handleCampagneJoinRequestResult.statusCode);
  }

  @override
  Future<HRResponse<CampagneJoinRequestIdentifier>>
      createNewCampagneJoinRequest(
          {required String joinCode,
          required PlayerCharacterIdentifier playerCharacterId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error('Could not load api connector.',
          '9141f93d-b76e-4fd4-aef6-240203c69a00');
    }

    var handleCampagneJoinRequestResult = await HRResponse.fromApiFuture(
        api.campagneJoinRequestCreatecampagneJoinRequestPost(
          body: CampagneJoinRequestCreateDto(
            campagneJoinCode: joinCode,
            playerCharacterId: playerCharacterId.$value!,
          ),
        ),
        'Could not create new campagne join request.',
        'bc5a7091-86d6-489e-879c-1f50522ae589');

    return handleCampagneJoinRequestResult;
  }

  @override
  Future<HRResponse<List<JoinRequestForCampagneDto>>>
      getOpenJoinRequestsForCampagne(
          {required CampagneIdentifier campagneId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);

    if (api == null) {
      return HRResponse.error<List<JoinRequestForCampagneDto>>(
          'Could not load api connector.',
          '7ad11d84-2b05-4e06-95a3-d223409c1366');
    }

    var joinRequestsForCampagne = await HRResponse.fromApiFuture(
        api.campagneJoinRequestGetcampagneJoinRequestsCampagneIdGet(
          campagneId: campagneId.$value!,
        ),
        'Could not load campagnes for player.',
        '02675072-f59f-4e0a-bcfe-058335f63950');

    return joinRequestsForCampagne;
  }

  @override
  Future<HRResponse<PlayerCharacterIdentifier>>
      savePlayerCharacterAsNewCharacter(
          {required String characterName, String? characterConfigJson}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error('Could not load api connector.',
          '8153c7f9-010c-468a-a967-369491776bcd');
    }

    var createPlayerCharacterResult = await HRResponse.fromApiFuture(
        api.playerCharacterCreatecharacterPost(
          body: PlayerCharacterCreateDto(
            characterName: characterName,
            rpgCharacterConfiguration: characterConfigJson,
          ),
        ),
        'Could not create new player character.',
        '6b72682c-538a-42b1-9390-b682a4b582dd');

    return createPlayerCharacterResult;
  }

  @override
  Future<HRResponse<List<PlayerCharacter>>> getPlayerCharactersForCampagne(
      {required CampagneIdentifier campagneId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error('Could not load api connector.',
          'a9ac7bc7-6556-48d0-a18c-c27399065977');
    }

    var playerCharactersForCampagne = await HRResponse.fromApiFuture(
        api.playerCharacterGetplayercharactersincampagneGet(
            $Value: campagneId.$value),
        'Could not load player characters for campagne.',
        '7bf67791-1a1b-46b0-9327-297d362eed56');

    return playerCharactersForCampagne;
  }

  @override
  Future<HRResponse<Campagne>> getCampagneById(
      {required CampagneIdentifier campagneId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error('Could not load api connector.',
          'a2cebb9d-02e5-4731-8b60-0a7747daffeb');
    }

    var loadedCampagne = await HRResponse.fromApiFuture(
        api.campagneGetcampagneCampagneidGet(campagneid: campagneId.$value),
        'Could not load campagne by id.',
        '2e44ba90-8d1b-4644-b8d6-3a66719109a4');

    return loadedCampagne;
  }

  @override
  Future<HRResponse<String>> uploadImageToCampagneStorage({
    required CampagneIdentifier campagneId,
    required MultipartFile image,
  }) async {
    var chopperClient =
        await apiConnectorService.getChopperClient(requiresJwt: true);
    if (chopperClient == null) {
      return HRResponse.error('Could not load chopper client.',
          '648167cd-9318-47df-b81b-a6cd87791860');
    }

    var internalImageUploadService =
        InternalImageUploadService.create(chopperClient);

    var result = await HRResponse.fromApiFuture(
        internalImageUploadService.uploadImage(campagneId.$value!, image),
        'Could not upload image.',
        '286c7e84-0875-4c2c-9b56-a42af6cdcaf9');

    return result;
  }

  @override
  Future<HRResponse<CampagneIdentifier>> createNewCampagne(
      {required String campagneName,
      required RpgConfigurationModel baseConfig}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error('Could not load api connector.',
          '707c0772-f7cb-41e3-a205-f5b453e6787b');
    }

    var createCampagneResult = await HRResponse.fromApiFuture(
        api.campagneCreatecampagnePost(
            body: CampagneCreateDto(
                campagneName: campagneName,
                rpgConfiguration: jsonEncode(baseConfig))),
        'Could not create new campagne.',
        'e933abe6-0651-466c-8f5d-6f411c653e88');

    return createCampagneResult;
  }

  @override
  Future<HRResponse<List<NoteDocumentPlayerDescriptorDto>>>
      getUserDetailsForCampagne(
          {required CampagneIdentifier campagneId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error('Could not load api connector.',
          '38f56f2d-8e02-4d47-bdd5-712a2c934194');
    }

    var userDescriptors = await HRResponse.fromApiFuture(
        api.playerCharacterGetnoteDocumentPlayerDescriptorDtosincampagneGet(
            $Value: campagneId.$value),
        'Could not load user details for campagne.',
        '7fccfd88-3027-4cf2-a577-2531dbf82e24');

    return userDescriptors;
  }
}

class MockRpgEntityService extends IRpgEntityService {
  final HRResponse<List<Campagne>>? getCampagnesWithPlayerAsDmOverride;
  final HRResponse<CampagneIdentifier>? saveCampagneAsNewCampagneOverride;
  final HRResponse<List<PlayerCharacter>>?
      getPlayerCharacetersForPlayerOverride;

  final HRResponse<List<PlayerCharacter>>?
      getPlayerCharactersForCampagneOverride;

  final HRResponse<bool>? handleJoinRequestOverride;

  MockRpgEntityService({
    this.getCampagnesWithPlayerAsDmOverride,
    this.getPlayerCharactersForCampagneOverride,
    this.saveCampagneAsNewCampagneOverride,
    this.getPlayerCharacetersForPlayerOverride,
    this.handleJoinRequestOverride,
    required super.apiConnectorService,
  }) : super(isMock: true);

  @override
  Future<HRResponse<List<Campagne>>> getCampagnesWithPlayerAsDm() {
    return Future.value(getCampagnesWithPlayerAsDmOverride ??
        HRResponse.fromResult([
          Campagne(
            campagneName: "Maries Liebes Geschichte",
            dmUserId:
                UserIdentifier($value: "f158d366-6373-4f20-996e-79e25b4daec0"),
            creationDate: DateTime(2024, 10, 24, 10, 10, 10),
            id: CampagneIdentifier(
                $value: "0229f244-e89f-499b-b7ba-cabfc37313fd"),
            joinCode: "345-123",
            lastModifiedAt: DateTime(2024, 10, 24, 10, 10, 10),
            rpgConfiguration: null,
          )
        ]));
  }

  @override
  Future<HRResponse<List<PlayerCharacter>>> getPlayerCharacetersForPlayer() {
    return Future.value(getPlayerCharacetersForPlayerOverride ??
        HRResponse.fromResult([
          PlayerCharacter(
            characterName: "Kardan",
            playerUserId:
                UserIdentifier($value: "f158d366-6373-4f20-996e-79e25b4daec0"),
            creationDate: DateTime(2024, 10, 24, 10, 10, 10),
            id: PlayerCharacterIdentifier(
                $value: "0229f244-e89f-499b-b7ba-cabfc37313fd"),
            lastModifiedAt: DateTime(2024, 10, 24, 10, 10, 10),
            rpgCharacterConfiguration: null,
          )
        ]));
  }

  @override
  Future<HRResponse<CampagneIdentifier>> saveCampagneAsNewCampagne(
      {required String campagneName, String? rpgConfig}) {
    return Future.value(saveCampagneAsNewCampagneOverride ??
        HRResponse.fromResult(CampagneIdentifier(
          $value: "74f73cf2-83e2-4c03-9ea1-9de7bef4d68e",
        )));
  }

  @override
  Future<HRResponse<bool>> handleJoinRequest(
      {required String campagneJoinRequestId,
      required HandleJoinRequestType typeOfHandle}) {
    return Future.value(
        handleJoinRequestOverride ?? HRResponse.fromResult(true));
  }

  @override
  Future<HRResponse<CampagneJoinRequestIdentifier>>
      createNewCampagneJoinRequest(
          {required String joinCode,
          required PlayerCharacterIdentifier playerCharacterId}) {
    // TODO: implement createNewCampagneJoinRequest
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<List<JoinRequestForCampagneDto>>>
      getOpenJoinRequestsForCampagne({required CampagneIdentifier campagneId}) {
    // TODO: implement getOpenJoinRequestsForCampagne
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<PlayerCharacterIdentifier>>
      savePlayerCharacterAsNewCharacter(
          {required String characterName, String? characterConfigJson}) {
    // TODO: implement savePlayerCharacterAsNewCharacter
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<List<PlayerCharacter>>> getPlayerCharactersForCampagne(
      {required CampagneIdentifier campagneId}) {
    return Future.value(getPlayerCharactersForCampagneOverride ??
        HRResponse.fromResult([
          PlayerCharacter(
            campagneId: campagneId,
            characterName: "Frodo",
            creationDate: DateTime(2024, 11, 7, 11, 11, 11),
            lastModifiedAt: DateTime(2024, 11, 7, 11, 11, 11),
            id: PlayerCharacterIdentifier(
                $value: "52716f7e-9532-4ed1-a7b0-b4cc86a3f425"),
            playerUserId:
                UserIdentifier($value: "b6a03252-8dde-4fe7-8c65-7d1b90599ef8"),
            rpgCharacterConfiguration: jsonEncode(
                RpgCharacterConfiguration.getBaseConfiguration(
                        RpgConfigurationModel.getBaseConfiguration())
                    .copyWith(characterName: "Frodo")),
          ),
          PlayerCharacter(
            campagneId: campagneId,
            characterName: "Gandalf",
            creationDate: DateTime(2024, 11, 7, 11, 11, 11),
            lastModifiedAt: DateTime(2024, 11, 7, 11, 11, 11),
            id: PlayerCharacterIdentifier(
                $value: "575fb9d9-c2a0-47df-bec4-5de1b3d5ca4d"),
            playerUserId:
                UserIdentifier($value: "9a709402-5620-479c-85b7-718ae01e0a83"),
            rpgCharacterConfiguration: jsonEncode(
              RpgCharacterConfiguration.getBaseConfiguration(
                      RpgConfigurationModel.getBaseConfiguration())
                  .copyWith(characterName: "Gandalf"),
            ),
          )
        ]));
  }

  @override
  Future<HRResponse<Campagne>> getCampagneById(
      {required CampagneIdentifier campagneId}) {
    // TODO: implement getCampagneById
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<String>> uploadImageToCampagneStorage({
    required CampagneIdentifier campagneId,
    required MultipartFile image,
  }) {
    // TODO: implement uploadImageToCampagneStorage
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<CampagneIdentifier>> createNewCampagne(
      {required String campagneName,
      required RpgConfigurationModel baseConfig}) {
    // TODO: implement createNewCampagne
    throw UnimplementedError();
  }

  @override
  Future<HRResponse<List<NoteDocumentPlayerDescriptorDto>>>
      getUserDetailsForCampagne({required CampagneIdentifier campagneId}) {
    return Future.value(HRResponse.fromResult([
      NoteDocumentPlayerDescriptorDto(
        isDm: true,
        userId: UserIdentifier($value: "d7c27d97-d973-465d-a2e5-9f605fd1f0c9"),
        isYou: false,
        playerCharacterName: null,
      ),
      NoteDocumentPlayerDescriptorDto(
        isDm: false,
        userId: UserIdentifier($value: "5def694e-8829-4fdd-afc5-342dc28c5ae2"),
        isYou: true,
        playerCharacterName: "MYSELF SHOULD NOT SHOW",
      ),
      NoteDocumentPlayerDescriptorDto(
        isDm: false,
        userId: UserIdentifier($value: "f59df7f4-7189-4435-9759-081c11bd887b"),
        isYou: false,
        playerCharacterName: "Kardan",
      ),
      NoteDocumentPlayerDescriptorDto(
        isDm: false,
        userId: UserIdentifier($value: "f918277a-db5b-4ca1-a60c-0e495f870dc1"),
        isYou: false,
        playerCharacterName: "Hayze",
      ),
    ]));
  }
}
