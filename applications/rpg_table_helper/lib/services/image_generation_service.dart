import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';

abstract class IImageGenerationService {
  final bool isMock;
  final IApiConnectorService apiConnectorService;

  const IImageGenerationService(
      {required this.isMock, required this.apiConnectorService});

  Future<HRResponse<String>> createNewImageAndGetUrl(
      {required String prompt, required CampagneIdentifier campagneId});
}

class ImageGenerationService extends IImageGenerationService {
  const ImageGenerationService({required super.apiConnectorService})
      : super(isMock: false);

  @override
  Future<HRResponse<String>> createNewImageAndGetUrl(
      {required String prompt, required CampagneIdentifier campagneId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<String>('Could not load api connector.',
          '8e30ee50-f386-441e-8ee4-2ca4604ce729');
    }

    var imageGenerationResult = await HRResponse.fromApiFuture(
        api.imageGenerateimageCampagneidPost(
            campagneid: campagneId.$value!, body: prompt),
        'Could not generate new image.',
        '780630d1-94c6-4016-8a11-fd7645cc26f4');

    return imageGenerationResult;
  }
}

class MockImageGenerationService extends IImageGenerationService {
  final HRResponse<String>? createNewImageAndGetUrlOverride;
  const MockImageGenerationService({
    required super.apiConnectorService,
    this.createNewImageAndGetUrlOverride,
  }) : super(isMock: true);

  @override
  Future<HRResponse<String>> createNewImageAndGetUrl(
      {required String prompt, required CampagneIdentifier campagneId}) {
    return Future.value(
      createNewImageAndGetUrlOverride ?? HRResponse.fromResult("asdf"),
    );
  }
}
