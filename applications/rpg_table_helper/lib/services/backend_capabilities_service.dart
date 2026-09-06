import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';

/// Stable capability identifiers the frontend knows how to gate features on.
/// These MUST match the strings advertised by the backend
/// (`PublicController.SupportedCapabilities`).
class BackendCapability {
  const BackendCapability._();

  /// Uploading a device image for a character portrait / singleImage stat.
  /// Backed by `POST /Image/streamimageupload`.
  static const String characterImageUpload = 'character-image-upload';
}

/// Capabilities guaranteed by the OLDEST backend we still support — i.e. those
/// whose endpoints predate `GET /Public/capabilities`. When the capabilities
/// endpoint is missing (older backend) or the call fails, we fall back to this
/// baseline so those features keep working. A genuinely new feature whose
/// endpoint does NOT predate the capabilities endpoint must be left OUT of this
/// set, so it correctly stays hidden against backends that do not advertise it.
const Set<String> kBaselineBackendCapabilities = {
  // `/Image/streamimageupload` shipped long before the capabilities endpoint;
  // the lore image upload already relies on it in production.
  BackendCapability.characterImageUpload,
};

abstract class IBackendCapabilitiesService {
  final bool isMock;
  final IApiConnectorService apiConnectorService;

  const IBackendCapabilitiesService(
      {required this.isMock, required this.apiConnectorService});

  /// Resolves the effective capability set: the backend-advertised set when the
  /// endpoint is reachable, otherwise [kBaselineBackendCapabilities]. The result
  /// is cached for the lifetime of the service; subsequent calls are cheap.
  Future<Set<String>> ensureCapabilitiesLoaded();

  /// Synchronous best-effort check for use during widget builds. Before the
  /// async load has completed (or if it failed) this reflects the baseline, so
  /// baseline features render immediately and new features stay hidden until
  /// confirmed.
  bool hasCapability(String capability);
}

class BackendCapabilitiesService extends IBackendCapabilitiesService {
  BackendCapabilitiesService({required super.apiConnectorService})
      : super(isMock: false);

  Set<String>? _cache;

  @override
  Future<Set<String>> ensureCapabilitiesLoaded() async {
    if (_cache != null) return _cache!;

    // Public endpoint: no JWT required.
    var api = await apiConnectorService.getApiConnector(requiresJwt: false);
    if (api == null) {
      // Could not even build a connector — assume baseline rather than
      // blocking baseline features.
      return _cache = {...kBaselineBackendCapabilities};
    }

    var response = await HRResponse.fromApiFuture(
      api.publicCapabilitiesGet(),
      'Could not load backend capabilities.',
      '2f1d9d0a-3c8e-4e2b-9a4e-1d6f6c9b7a10',
    );

    if (response.isSuccessful && response.result != null) {
      final advertised = response.result!.capabilities ?? const <String>[];
      // Merge with baseline: a backend that advertises capabilities still
      // supports everything in the baseline (its endpoints predate the flag).
      return _cache = {...kBaselineBackendCapabilities, ...advertised};
    }

    // Old backend (404) or a transient failure: fall back to baseline.
    return _cache = {...kBaselineBackendCapabilities};
  }

  @override
  bool hasCapability(String capability) {
    return (_cache ?? kBaselineBackendCapabilities).contains(capability);
  }
}

class MockBackendCapabilitiesService extends IBackendCapabilitiesService {
  /// Overrides the capability set the mock resolves to. Defaults to the
  /// baseline (so upload-style baseline features are enabled in tests).
  final Set<String>? capabilitiesOverride;

  MockBackendCapabilitiesService({
    required super.apiConnectorService,
    this.capabilitiesOverride,
  }) : super(isMock: true);

  Set<String> get _effective =>
      capabilitiesOverride ?? kBaselineBackendCapabilities;

  @override
  Future<Set<String>> ensureCapabilitiesLoaded() async => _effective;

  @override
  bool hasCapability(String capability) => _effective.contains(capability);
}
