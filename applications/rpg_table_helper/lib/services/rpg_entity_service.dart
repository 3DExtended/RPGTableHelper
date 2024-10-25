import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/models/humanreadable_response.dart';
import 'package:rpg_table_helper/services/auth/api_connector_service.dart';

abstract class IRpgEntityService {
  final bool isMock;

  final IApiConnectorService apiConnectorService;

  const IRpgEntityService({
    required this.isMock,
    required this.apiConnectorService,
  });

  Future<HRResponse<List<Campagne>>> getCampagnesWithPlayerAsDm();
  Future<HRResponse<CampagneIdentifier>> saveCampagneAsNewCampagne(
      {required String campagneName, String? rpgConfig});
  Future<HRResponse<List<PlayerCharacter>>> getPlayerCharacetersForPlayer();
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
}

class MockRpgEntityService extends IRpgEntityService {
  final HRResponse<List<Campagne>>? getCampagnesWithPlayerAsDmOverride;
  final HRResponse<CampagneIdentifier>? saveCampagneAsNewCampagneOverride;
  final HRResponse<List<PlayerCharacter>>?
      getPlayerCharacetersForPlayerOverride;

  MockRpgEntityService({
    this.getCampagnesWithPlayerAsDmOverride,
    this.saveCampagneAsNewCampagneOverride,
    this.getPlayerCharacetersForPlayerOverride,
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
}
