import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/backend_capabilities_service.dart';

/// Builds a [Swagger] client whose HTTP layer is faked by [handler], so we can
/// drive the real [BackendCapabilitiesService] against canned backend
/// responses.
Swagger _swaggerReturning(MockClientHandler handler) {
  return Swagger.create(
    httpClient: MockClient(handler),
    baseUrl: Uri.parse('http://localhost/'),
  );
}

void main() {
  test('baseline set includes the character image upload capability', () {
    // The whole "old backend still works" guarantee rests on this: the upload
    // endpoint predates the capabilities endpoint, so it must be in baseline.
    expect(kBaselineBackendCapabilities,
        contains(BackendCapability.characterImageUpload));
  });

  test('merges advertised capabilities with the baseline', () async {
    final service = BackendCapabilitiesService(
      apiConnectorService: MockApiConnectorService(
        connectorOverride: _swaggerReturning((request) async {
          expect(request.url.path, '/Public/capabilities');
          return http.Response(
            jsonEncode({
              'capabilities': ['some-future-flag'],
              'apiVersion': '0.9.4',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      ),
    );

    final caps = await service.ensureCapabilitiesLoaded();

    // Advertised flag is present...
    expect(caps, contains('some-future-flag'));
    // ...and the baseline is still merged in.
    expect(caps, contains(BackendCapability.characterImageUpload));
    expect(service.hasCapability('some-future-flag'), isTrue);
    expect(service.hasCapability(BackendCapability.characterImageUpload), isTrue);
  });

  test('falls back to baseline when the endpoint is missing (old backend / 404)',
      () async {
    final service = BackendCapabilitiesService(
      apiConnectorService: MockApiConnectorService(
        connectorOverride: _swaggerReturning(
          (request) async => http.Response('Not Found', 404),
        ),
      ),
    );

    final caps = await service.ensureCapabilitiesLoaded();

    // Upload still works against an old backend that never heard of
    // /Public/capabilities, because it is in the baseline.
    expect(caps, equals(kBaselineBackendCapabilities));
    expect(service.hasCapability(BackendCapability.characterImageUpload), isTrue);
    // A genuinely new flag that is NOT in baseline stays hidden.
    expect(service.hasCapability('some-future-flag'), isFalse);
  });

  test('falls back to baseline when no api connector is available', () async {
    final service = BackendCapabilitiesService(
      apiConnectorService: MockApiConnectorService(connectorOverride: null),
    );

    final caps = await service.ensureCapabilitiesLoaded();
    expect(caps, equals(kBaselineBackendCapabilities));
  });

  test('caches the resolved capability set (only calls the backend once)',
      () async {
    var callCount = 0;
    final service = BackendCapabilitiesService(
      apiConnectorService: MockApiConnectorService(
        connectorOverride: _swaggerReturning((request) async {
          callCount++;
          return http.Response(
            jsonEncode({'capabilities': <String>[], 'apiVersion': '0.9.4'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      ),
    );

    await service.ensureCapabilitiesLoaded();
    await service.ensureCapabilitiesLoaded();
    expect(callCount, 1);
  });

  test('hasCapability reflects the baseline before the async load completes',
      () {
    final service = BackendCapabilitiesService(
      apiConnectorService: MockApiConnectorService(connectorOverride: null),
    );

    // No load yet: baseline features report available, unknown ones do not.
    expect(service.hasCapability(BackendCapability.characterImageUpload), isTrue);
    expect(service.hasCapability('some-future-flag'), isFalse);
  });

  test('mock service can disable a capability for gating tests', () async {
    final enabled = MockBackendCapabilitiesService(
      apiConnectorService: MockApiConnectorService(connectorOverride: null),
    );
    expect(enabled.hasCapability(BackendCapability.characterImageUpload), isTrue);

    final disabled = MockBackendCapabilitiesService(
      apiConnectorService: MockApiConnectorService(connectorOverride: null),
      capabilitiesOverride: const <String>{},
    );
    expect(
        disabled.hasCapability(BackendCapability.characterImageUpload), isFalse);
  });
}
