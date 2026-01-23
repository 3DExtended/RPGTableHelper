import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';

abstract class IApiKeyService {
  Future<HRResponse<List<ApiKeyDto>>> getApiKeys();
  Future<HRResponse<CreateApiKeyResponse>> createApiKey(String name);
  Future<HRResponse<bool>> revokeApiKey(String id);
}

class ApiKeyService implements IApiKeyService {
  final IApiConnectorService _apiConnectorService;

  ApiKeyService(this._apiConnectorService);

  @override
  Future<HRResponse<List<ApiKeyDto>>> getApiKeys() async {
    var api = await _apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<List<ApiKeyDto>>('Could not load api connector.',
          '41ae1ab9-b40b-4a96-94b9-45027d1c4870');
    }

    var apiKeysResult = await HRResponse.fromApiFuture(
        api.apiApiKeysGet(),
        'Could not load apikeys for player.',
        '1cc1b3b3-4bee-45bd-ad95-acfb47321bce');

    return apiKeysResult;
  }

  @override
  Future<HRResponse<CreateApiKeyResponse>> createApiKey(String name) async {
    var api = await _apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<CreateApiKeyResponse>(
          'Could not load api connector.',
          '5bde1201-ee77-44c9-b407-5a7dfee04b50');
    }

    var apiKeysResult = await HRResponse.fromApiFuture(
        api.apiApiKeysPost(
          body: CreateApiKeyRequestDto(name: name),
        ),
        'Could not create apikey for player.',
        '14ff958c-3671-4585-8d80-0966f59a9b61');

    return apiKeysResult;
  }

  @override
  Future<HRResponse<bool>> revokeApiKey(String id) async {
    var api = await _apiConnectorService.getApiConnector(requiresJwt: true);
    if (api == null) {
      return HRResponse.error<bool>('Could not load api connector.',
          '0333be12-d570-4b40-ae78-69f8d1e130a2');
    }

    var apiKeysResult = await HRResponse.fromApiFuture(
        api.apiApiKeysIdDelete(
          id: id,
        ),
        'Could not create apikey for player.',
        '7ef0bafb-b2c5-4715-89ac-b8090f650392');

    if (apiKeysResult.isSuccessful) {
      return HRResponse.fromResult(true);
    } else {
      return apiKeysResult.asT();
    }
  }
}

class MockApiKeyService implements IApiKeyService {
  MockApiKeyService();

  @override
  Future<HRResponse<CreateApiKeyResponse>> createApiKey(String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return HRResponse.fromResult(CreateApiKeyResponse(
        apiKey: ApiKeyDto(
            id: "mock-id",
            name: name,
            prefix: "sk-mock",
            createdAt: DateTime.now()),
        plainKey: "sk-mock-123456789"));
  }

  @override
  Future<HRResponse<List<ApiKeyDto>>> getApiKeys() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return HRResponse.fromResult([
      ApiKeyDto(
          id: "1",
          name: "Test Key 1",
          prefix: "sk-test",
          createdAt: DateTime.now()),
      ApiKeyDto(
          id: "2",
          name: "Revoked Key",
          prefix: "sk-revo",
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          revokedAt: DateTime.now()),
    ]);
  }

  @override
  Future<HRResponse<bool>> revokeApiKey(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return HRResponse.fromResult(true);
  }
}
