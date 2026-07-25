import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/authentication_service.dart';
import 'package:quest_keeper/services/auth/encryption_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/auth/token_refresher.dart';
import 'package:quest_keeper/services/image_generation_service.dart';
import 'package:quest_keeper/services/navigation_service.dart';
import 'package:quest_keeper/services/note_documents_service.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:quest_keeper/services/snack_bar_service.dart';
import 'package:quest_keeper/services/sse/events_client.dart';
import 'package:quest_keeper/services/systemclock_service.dart';
import 'package:quest_keeper/services/api_key_service.dart';

class DependencyProvider extends InheritedWidget {
  static DependencyProvider of(BuildContext context) {
    var dependOnInheritedWidgetOfExactType =
        context.dependOnInheritedWidgetOfExactType<DependencyProvider>();

    if (dependOnInheritedWidgetOfExactType == null) {
      throw MissingPluginException(
          'Custom error: Could not find DependencyProvider in dependOnInheritedWidgetOfExactType');
    }

    return dependOnInheritedWidgetOfExactType;
  }

  static MockedRiverpodDependencyProviderWrapper getMockedDependecyProvider({
    required Widget child,
    Map<Type, dynamic Function()>? mockOverrides,
  }) =>
      MockedRiverpodDependencyProviderWrapper(
          mockOverrides: mockOverrides, child: child);

  static GetIt? getIt;
  final bool isMocked;
  final Map<Type, dynamic Function()>? mockOverrides;
  final WidgetRef widgetRef;

  T getService<T extends Object>() {
    var result = getIt!.get<T>();
    return result;
  }

  DependencyProvider({
    super.key,
    required this.isMocked,
    required super.child,
    required this.widgetRef,
    this.mockOverrides,
  }) {
    getIt = GetIt.asNewInstance();

    // TODO add all services here
    _registerService<ISystemClockService>(
        () => SystemClockService(), () => MockSystemClockService());
    _registerService<IEncryptionService>(
        () => EncryptionService(), () => MockEncryptionService());

    _registerService<IApiConnectorService>(
        () => ApiConnectorService(), () => MockApiConnectorService());

    _registerService<ISecureRefreshTokenStorage>(() => SecureRefreshTokenStorage(),
        () => MockSecureRefreshTokenStorage());

    _registerService<ITokenRefresher>(() {
      var apiConnectorService = getService<IApiConnectorService>();
      var secureRefreshTokenStorage = getService<ISecureRefreshTokenStorage>();
      return TokenRefresher(
          apiConnectorService: apiConnectorService,
          secureRefreshTokenStorage: secureRefreshTokenStorage);
    }, () => MockTokenRefresher());

    _registerService<ISnackBarService>(
        () => SnackBarService(), () => SnackBarService());

    _registerService<IAuthenticationService>(() {
      var encryptionService = getService<IEncryptionService>();
      var apiConnectorService = getService<IApiConnectorService>();
      var secureRefreshTokenStorage = getService<ISecureRefreshTokenStorage>();
      return AuthenticationService(
          apiConnectorService: apiConnectorService,
          encryptionService: encryptionService,
          secureRefreshTokenStorage: secureRefreshTokenStorage);
    }, () {
      var encryptionService = getService<IEncryptionService>();
      var apiConnectorService = getService<IApiConnectorService>();
      var secureRefreshTokenStorage = getService<ISecureRefreshTokenStorage>();

      return MockAuthenticationService(
          apiConnectorService: apiConnectorService,
          encryptionService: encryptionService,
          secureRefreshTokenStorage: secureRefreshTokenStorage);
    });

    _registerService<IRpgEntityService>(() {
      var apiConnectorService = getService<IApiConnectorService>();
      return RpgEntityService(
        apiConnectorService: apiConnectorService,
      );
    }, () {
      var apiConnectorService = getService<IApiConnectorService>();

      return MockRpgEntityService(
        apiConnectorService: apiConnectorService,
      );
    });
    _registerService<INoteDocumentService>(() {
      var apiConnectorService = getService<IApiConnectorService>();
      return NoteDocumentService(
        apiConnectorService: apiConnectorService,
      );
    }, () {
      var apiConnectorService = getService<IApiConnectorService>();

      return MockNoteDocumentService(
        apiConnectorService: apiConnectorService,
      );
    });

    _registerService<IImageGenerationService>(() {
      var apiConnectorService = getService<IApiConnectorService>();
      return ImageGenerationService(
        apiConnectorService: apiConnectorService,
      );
    }, () {
      var apiConnectorService = getService<IApiConnectorService>();

      return MockImageGenerationService(
        apiConnectorService: apiConnectorService,
      );
    });

    _registerService<IApiKeyService>(() {
      var apiConnectorService = getService<IApiConnectorService>();
      return ApiKeyService(apiConnectorService);
    }, () {
      return MockApiKeyService();
    });

    _registerService<INavigationService>(
        () => NavigationService(), () => NavigationService());

    _registerService<EventsClient>(() {
      final api = getService<IApiConnectorService>();
      return EventsClient(getJwt: api.getJwt);
    }, () {
      final api = getService<IApiConnectorService>();
      return EventsClient(
        getJwt: api.getJwt,
        openStream: ({required uri, required jwt}) async {
          return http.ByteStream(const Stream.empty());
        },
        sleep: (_) async {},
      );
    });

    _registerService<IServerMethodsService>(() {
      var navService = getService<INavigationService>();
      return ServerMethodsService(
          navigationService: navService, widgetRef: widgetRef);
    }, () {
      var navService = getService<INavigationService>();

      return ServerMethodsService(
          navigationService: navService, widgetRef: widgetRef);
    });
  }

  void _registerService<T extends Object>(T Function() realServiceFactoryFunc,
      T Function() mockServiceFactoryFunc) {
    if (mockOverrides != null && mockOverrides!.keys.any((t) => T == t)) {
      getIt!.registerSingleton<T>(mockOverrides![T]!());
    } else {
      if (isMocked) {
        getIt!.registerSingleton<T>(mockServiceFactoryFunc());
      } else {
        getIt!.registerSingleton<T>(realServiceFactoryFunc());
      }
    }
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class MockedRiverpodDependencyProviderWrapper extends ConsumerWidget {
  final Widget child;
  final Map<Type, dynamic Function()>? mockOverrides;

  const MockedRiverpodDependencyProviderWrapper({
    super.key,
    required this.child,
    this.mockOverrides,
  }) : super();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DependencyProvider(
      widgetRef: ref,
      isMocked: true,
      mockOverrides: mockOverrides,
      child: child,
    );
  }
}
