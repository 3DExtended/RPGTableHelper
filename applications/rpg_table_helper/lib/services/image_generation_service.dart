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

  Future<HRResponse<List<ImageMetaData>>> getImagesForCampagne(
      {required CampagneIdentifier campagneId});
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

  @override
  Future<HRResponse<List<ImageMetaData>>> getImagesForCampagne(
      {required CampagneIdentifier campagneId}) async {
    var api = await apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<List<ImageMetaData>>(
          'Could not load api connector.',
          '798be692-130c-4f1d-ba19-57cb32f2677a');
    }

    var imagesResult = await HRResponse.fromApiFuture(
        api.imageGetimagesCampagneIdGet(campagneId: campagneId.$value!),
        'Could not load images.',
        'cbdd8cdc-16cd-4a92-aa65-42976752d372');

    return imagesResult;
  }
}

class MockImageGenerationService extends IImageGenerationService {
  final HRResponse<String>? createNewImageAndGetUrlOverride;
  final HRResponse<List<ImageMetaData>>? getImagesForCampagneOverride;
  const MockImageGenerationService({
    required super.apiConnectorService,
    this.createNewImageAndGetUrlOverride,
    this.getImagesForCampagneOverride,
  }) : super(isMock: true);

  @override
  Future<HRResponse<String>> createNewImageAndGetUrl(
      {required String prompt, required CampagneIdentifier campagneId}) {
    return Future.value(
      createNewImageAndGetUrlOverride ?? HRResponse.fromResult("asdf"),
    );
  }

  @override
  Future<HRResponse<List<ImageMetaData>>> getImagesForCampagne(
      {required CampagneIdentifier campagneId}) {
    return Future.value(
      getImagesForCampagneOverride ?? HRResponse.fromResult([]),
    );
  }
}
