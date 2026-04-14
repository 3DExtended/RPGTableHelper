import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/hub_invoke_queue.dart';
import 'package:quest_keeper/services/hub_invoke_retry.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/msgpack_hub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

abstract class IServerCommunicationService {
  final bool isMock;
  final WidgetRef widgetRef;
  final IApiConnectorService apiConnectorService;
  const IServerCommunicationService({
    required this.isMock,
    required this.apiConnectorService,
    required this.widgetRef,
  });

  Future startConnection();
  Future stopConnection();

  void updateRpgConfiguration(RpgConfigurationModel config) {
    widgetRef
        .read(rpgConfigurationProvider.notifier)
        .updateConfiguration(config);
  }

  void registerCallbackWithoutParameters(
      {required void Function() function, required String functionName});

  void completeFunctionRegistration();

  void registerCallbackSingleString({
    required void Function(String parameter) function,
    required String functionName,
  });

  void registerCallbackTwoStrings({
    required void Function(String param1, String param2) function,
    required String functionName,
  });

  void registerCallbackSingleDateTime({
    required void Function(DateTime parameter) function,
    required String functionName,
  });

  void registerCallbackSingleDateTimeAndOneString({
    required void Function(DateTime param1, String param2) function,
    required String functionName,
  });

  void registerCallbackThreeStrings(
      {required void Function(String param1, String param2, String param3)
          function,
      required String functionName});

  void registerCallbackFourStrings(
      {required void Function(
              String param1, String param2, String param3, String param4)
          function,
      required String functionName});

  /// [maxInvokeRetries] is the number of invoke attempts (minimum 1).
  Future executeServerFunction(String functionName,
      {List<Object>? args, int maxInvokeRetries = 1});

  /// Current hub state for diagnostics and resume handling; null in mocks.
  HubConnectionState? get hubConnectionState;

  /// Ensures the hub is started when disconnected; safe to call on app resume.
  Future<void> ensureConnectionReadyForSession();

  /// Like [executeServerFunction], but on total failure the invoke is stored in an in-memory queue for later [drainHubInvokeQueue].
  Future<void> executeCriticalServerFunction(String functionName,
      {List<Object>? args, int maxInvokeRetries = 3});

  /// Retries queued critical invokes; safe to call after reconnect or resume.
  Future<void> drainHubInvokeQueue();

  int get pendingHubInvokeCount;
}

class ServerCommunicationService extends IServerCommunicationService {
  HubConnection? hubConnection; // initalized within buildHubConnection()

  final HubInvokeQueue _hubInvokeQueue = HubInvokeQueue();

  @override
  int get pendingHubInvokeCount => _hubInvokeQueue.length;

  bool get connectionIsOpen =>
      hubConnection != null &&
      (hubConnection!.state == HubConnectionState.Connected);

  @override
  HubConnectionState? get hubConnectionState => hubConnection?.state;

  @override
  Future<void> ensureConnectionReadyForSession() async {
    if (hubConnection == null ||
        hubConnection!.state == HubConnectionState.Disconnected ||
        hubConnection!.state == HubConnectionState.Disconnecting) {
      await tryOpenConnection();
    }
  }

  ServerCommunicationService({
    required super.widgetRef,
    required super.apiConnectorService,
  }) : super(isMock: false);

  void buildHubConnection() {
    // NOTE: Headers are not working in this current signal r version...
    final defaultHeaders = MessageHeaders();
    // defaultHeaders.setHeaderValue("HEADER_MOCK_1", "HEADER_VALUE_1");
    // defaultHeaders.setHeaderValue("HEADER_MOCK_2", "HEADER_VALUE_2");

    // transport left unset (null): negotiate and try server-listed transports in order
    // (typically WebSockets, then Server-Sent Events, then long polling). See signalr_netcore HttpConnection._createTransport.
    final httpConnectionOptions = HttpConnectionOptions(
      httpClient: WebSupportingHttpClient(null,
          httpClientCreateCallback: httpClientCreateCallback),
      accessTokenFactory: () async {
        var apiConnectorService = this.apiConnectorService;
        var jwt = await apiConnectorService.getJwt();
        return Future.value(jwt ?? "JWT");
      },
      logMessageContent: true,
      headers: defaultHeaders,
    );

    // Creates the connection by using the HubConnectionBuilder.
    hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: httpConnectionOptions)
        .withHubProtocol(MessagePackHubProtocol())
        .withAutomaticReconnect(retryDelays: [
      2000,
      5000,
      10000,
      ...List.generate(5000, (i) => 20000)
    ]).build();

    log(
      "SignalR: HttpConnectionOptions.transport unset — negotiate and try "
      "WebSockets, then SSE, then long polling (server order).",
      name: "SignalR",
    );

    // When the connection is closed, print out a message to the console.
    hubConnection!.onclose(
      ({error}) {
        final state = hubConnection?.state;
        log(
          "SignalR onclose: state=$state error=$error",
          name: "SignalR",
        );
        widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
            widgetRef.read(connectionDetailsProvider).value?.copyWith(
                      isConnected: false,
                      isConnecting: false,
                    ) ??
                ConnectionDetails.defaultValue());
      },
    );

    hubConnection!.onreconnecting(({error}) {
      final state = hubConnection?.state;
      log(
        "SignalR onreconnecting: state=$state error=$error",
        name: "SignalR",
      );
      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: false,
                    isConnecting: true,
                  ) ??
              ConnectionDetails.defaultValue());
    });

    hubConnection!.onreconnected(({connectionId}) async {
      final state = hubConnection?.state;
      log(
        "SignalR onreconnected: state=$state connectionId=$connectionId",
        name: "SignalR",
      );

      // users cannot be assigned to signalR groups (see here: https://github.com/dotnet/aspnetcore/issues/26133)
      // hence, everytime a user is reconnected, we must ensure we add them to the appropiate groups
      // hence, we read the connectionDetailsProvider to get both campagneId and playerCharacterId
      // and call readdToSignalRGroups() on the server.
      // TODO this is an ugly hack to obtain the instance of IServerMethodsService...
      var serverMethods =
          DependencyProvider.getIt!.get<IServerMethodsService>();
      await serverMethods.readdToSignalRGroups();
      // Re-declare client capabilities on every reconnect.
      await executeServerFunction("RegisterClientProtocol",
          args: [signalRProtocolVersion], maxInvokeRetries: 1);
      await drainHubInvokeQueue();

      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: true,
                    isConnecting: false,
                  ) ??
              ConnectionDetails.defaultValue());
    });
  }

  @override
  Future startConnection() async {
    if (hubConnection == null) {
      buildHubConnection();
    }

    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        widgetRef.read(connectionDetailsProvider).value?.copyWith(
                  isConnected: false,
                  isConnecting: true,
                ) ??
            ConnectionDetails.defaultValue());

    final opened = await tryOpenConnection();
    if (!opened) {
      return;
    }

    var serverMethods = DependencyProvider.getIt!.get<IServerMethodsService>();
    // Declare supported SignalR protocol features for this connection.
    await executeServerFunction("RegisterClientProtocol",
        args: [signalRProtocolVersion], maxInvokeRetries: 1);
    await serverMethods.readdToSignalRGroups();
    await drainHubInvokeQueue();
  }

  @override
  Future stopConnection() async {
    await hubConnection?.stop();
  }

  void httpClientCreateCallback(Client httpClient) {
    // TODO check if we need this only on dev or also on prod
    HttpOverrides.global = HttpOverrideCertificateVerificationInDev();
  }

  List<void Function()> registrationMethods = [];

  @override
  void registerCallbackWithoutParameters(
      {required void Function() function, required String functionName}) {
    registrationMethods.add(() {
      hubConnection!.on(functionName, (List<Object?>? parameters) {
        function();
      });
    });
  }

  @override
  void registerCallbackSingleDateTime(
      {required void Function(DateTime parameter) function,
      required String functionName}) {
    registrationMethods.add(() {
      hubConnection!.on(functionName, (List<Object?>? parameters) {
        if (parameters == null || parameters.isEmpty) return;

        final String? param =
            parameters[0] != null ? parameters[0] as String : null;

        if (param == null) return;
        var parsedDatetime = DateTime.parse(param);
        function(parsedDatetime);
      });
    });
  }

  @override
  void registerCallbackSingleDateTimeAndOneString(
      {required void Function(DateTime parameter1, String parameter2) function,
      required String functionName}) {
    registrationMethods.add(() {
      hubConnection!.on(functionName, (List<Object?>? parameters) {
        if (parameters == null || parameters.isEmpty) return;

        final String? param1 =
            parameters[0] != null ? parameters[0] as String : null;

        if (param1 == null) return;
        final String? param2 =
            parameters[1] != null ? parameters[1] as String : null;

        if (param2 == null) return;
        var parsedDatetime = DateTime.parse(param1);
        function(parsedDatetime, param2);
      });
    });
  }

  @override
  void registerCallbackSingleString({
    required void Function(String parameter) function,
    required String functionName,
  }) {
    registrationMethods.add(() {
      hubConnection!.on(functionName, (List<Object?>? parameters) {
        if (parameters == null || parameters.isEmpty) return;

        final String? param =
            parameters[0] != null ? parameters[0] as String : null;

        if (param == null) return;

        function(param);
      });
    });
  }

  @override
  void registerCallbackTwoStrings({
    required void Function(String param1, String param2) function,
    required String functionName,
  }) {
    registrationMethods.add(() {
      hubConnection!.on(functionName, (List<Object?>? parameters) {
        if (parameters == null || parameters.isEmpty) {
          return;
        }
        final String? param1 =
            parameters[0] != null ? parameters[0] as String : null;
        final String? param2 =
            parameters.length > 1 && parameters[1] != null
                ? parameters[1] as String
                : null;
        if (param1 == null || param2 == null) {
          return;
        }
        function(param1, param2);
      });
    });
  }

  @override
  void registerCallbackThreeStrings(
      {required void Function(String param1, String param2, String param3)
          function,
      required String functionName}) {
    registrationMethods.add(() {
      hubConnection!.on(functionName, (List<Object?>? parameters) {
        if (parameters == null || parameters.isEmpty) return;

        final String? param1 =
            parameters[0] != null ? parameters[0] as String : null;
        final String? param2 =
            parameters[1] != null ? parameters[1] as String : null;
        final String? param3 =
            parameters[2] != null ? parameters[2] as String : null;

        if (param1 == null || param2 == null || param3 == null) return;

        function(param1, param2, param3);
      });
    });
  }

  @override
  void registerCallbackFourStrings(
      {required void Function(
              String param1, String param2, String param3, String param4)
          function,
      required String functionName}) {
    registrationMethods.add(() {
      hubConnection!.on(functionName, (List<Object?>? parameters) {
        if (parameters == null || parameters.isEmpty) return;

        final String? param1 =
            parameters[0] != null ? parameters[0] as String : null;
        final String? param2 =
            parameters[1] != null ? parameters[1] as String : null;
        final String? param3 =
            parameters[2] != null ? parameters[2] as String : null;
        final String? param4 =
            parameters[3] != null ? parameters[3] as String : null;

        if (param1 == null ||
            param2 == null ||
            param3 == null ||
            param4 == null) {
          return;
        }

        function(param1, param2, param3, param4);
      });
    });
  }

  @override
  Future executeServerFunction(String functionName,
      {List<Object>? args, int maxInvokeRetries = 1}) async {
    await _invokeWithRetries(functionName, args: args, maxInvokeRetries: maxInvokeRetries);
  }

  @override
  Future<void> executeCriticalServerFunction(String functionName,
      {List<Object>? args, int maxInvokeRetries = 3}) async {
    final ok = await _invokeWithRetries(functionName,
        args: args, maxInvokeRetries: maxInvokeRetries);
    if (!ok) {
      _hubInvokeQueue.enqueue(functionName, args);
      log(
        "SignalR: enqueued critical invoke $functionName (queue length ${_hubInvokeQueue.length})",
        name: "SignalR",
      );
    }
  }

  @override
  Future<void> drainHubInvokeQueue() async {
    if (!connectionIsOpen) {
      return;
    }
    var guard = 0;
    while (connectionIsOpen &&
        _hubInvokeQueue.length > 0 &&
        guard < hubInvokeQueueMaxItems * 2) {
      guard++;
      final next = _hubInvokeQueue.dequeue();
      if (next == null) {
        break;
      }
      final ok = await _invokeWithRetries(next.functionName,
          args: next.args, maxInvokeRetries: 1);
      if (!ok) {
        _hubInvokeQueue.unshift(next);
        log(
          "SignalR: drain paused on failure for ${next.functionName}",
          name: "SignalR",
        );
        break;
      }
    }
  }

  /// Returns true if at least one invoke attempt succeeded.
  Future<bool> _invokeWithRetries(String functionName,
      {List<Object>? args, int maxInvokeRetries = 1}) async {
    if (!connectionIsOpen) {
      await tryOpenConnection();
    }

    return runHubInvokeWithRetries(
      hubMissing: hubConnection == null,
      hubState: () => hubConnection?.state,
      invoke: (name, {args}) => hubConnection!.invoke(name, args: args),
      tryOpenConnection: tryOpenConnection,
      functionName: functionName,
      args: args,
      maxInvokeRetries: maxInvokeRetries,
      logSkippedNoHub: (m) => log(m, name: "SignalR"),
      logNotConnected: (m) => log(m, name: "SignalR"),
      logInvokeOk: (m) => log(m, name: "SignalR"),
      logInvokeFailed: (m, e, st) =>
          log(m, name: "SignalR", error: e, stackTrace: st),
      logGaveUp: (m, e, st) {
        if (e != null) {
          log(m, name: "SignalR", error: e, stackTrace: st);
        }
      },
    );
  }

  Future<bool> tryOpenConnection() async {
    if (hubConnection == null ||
        hubConnection?.state == HubConnectionState.Disconnected ||
        hubConnection?.state == HubConnectionState.Disconnecting) {
      completeFunctionRegistration();
    }

    try {
      await hubConnection!.start();

      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: true,
                    isConnecting: false,
                  ) ??
              ConnectionDetails.defaultValue());
      log(
        "SignalR tryOpenConnection: connected state=${hubConnection?.state}",
        name: "SignalR",
      );
      return true;
    } catch (e, st) {
      log(
        "SignalR tryOpenConnection failed: $e",
        name: "SignalR",
        error: e,
        stackTrace: st,
      );
      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: false,
                    isConnecting: false,
                  ) ??
              ConnectionDetails.defaultValue());
      return false;
    }
  }

  @override
  void completeFunctionRegistration() {
    buildHubConnection();

    // ensure methods were registered
    var _ = DependencyProvider.getIt!.get<IServerMethodsService>();

    for (var i = 0; i < registrationMethods.length; i++) {
      registrationMethods[i]();
    }
  }
}

class MockServerCommunicationService extends IServerCommunicationService {
  final DateTime? nowOverride;
  const MockServerCommunicationService({
    required super.widgetRef,
    required super.apiConnectorService,
    this.nowOverride,
  }) : super(isMock: true);

  @override
  void registerCallbackSingleString({
    required void Function(String parameter) function,
    required String functionName,
  }) {}

  @override
  void registerCallbackTwoStrings({
    required void Function(String param1, String param2) function,
    required String functionName,
  }) {}

  @override
  HubConnectionState? get hubConnectionState => null;

  @override
  Future<void> ensureConnectionReadyForSession() async {}

  @override
  int get pendingHubInvokeCount => 0;

  @override
  Future<void> drainHubInvokeQueue() async {}

  @override
  Future<void> executeCriticalServerFunction(String functionName,
      {List<Object>? args, int maxInvokeRetries = 3}) {
    throw UnimplementedError();
  }

  @override
  Future executeServerFunction(String functionName,
      {List<Object>? args, int maxInvokeRetries = 1}) {
    throw UnimplementedError();
  }

  @override
  void registerCallbackThreeStrings(
      {required void Function(String param1, String param2, String param3)
          function,
      required String functionName}) {}

  @override
  void registerCallbackWithoutParameters(
      {required void Function() function, required String functionName}) {}

  @override
  Future startConnection() {
    return Future.value();
  }

  @override
  Future stopConnection() {
    return Future.value();
  }

  @override
  void registerCallbackFourStrings(
      {required void Function(
              String param1, String param2, String param3, String param4)
          function,
      required String functionName}) {}

  @override
  void completeFunctionRegistration() {}

  @override
  void registerCallbackSingleDateTime(
      {required void Function(DateTime parameter) function,
      required String functionName}) {}

  @override
  void registerCallbackSingleDateTimeAndOneString(
      {required void Function(DateTime param1, String param2) function,
      required String functionName}) {}
}

class HttpOverrideCertificateVerificationInDev extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
