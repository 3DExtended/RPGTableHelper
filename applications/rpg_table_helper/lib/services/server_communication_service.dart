import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/auth/api_connector_service.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/server_methods_service.dart';
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

  void registerCallbackThreeStrings(
      {required void Function(String param1, String param2, String param3)
          function,
      required String functionName});

  void registerCallbackFourStrings(
      {required void Function(
              String param1, String param2, String param3, String param4)
          function,
      required String functionName});

  Future executeServerFunction(String functionName, {List<Object>? args});
}

class ServerCommunicationService extends IServerCommunicationService {
  HubConnection? hubConnection; // initalized within buildHubConnection()

  bool get connectionIsOpen =>
      hubConnection != null &&
      (hubConnection!.state == HubConnectionState.Connected);

  ServerCommunicationService({
    required super.widgetRef,
    required super.apiConnectorService,
  }) : super(isMock: false) {
    print("New ServerCommunicationService created");
  }

  void buildHubConnection() {
    // NOTE: Headers are not working in this current signal r version...
    final defaultHeaders = MessageHeaders();
    // defaultHeaders.setHeaderValue("HEADER_MOCK_1", "HEADER_VALUE_1");
    // defaultHeaders.setHeaderValue("HEADER_MOCK_2", "HEADER_VALUE_2");

    final httpConnectionOptions = HttpConnectionOptions(
      httpClient: WebSupportingHttpClient(null,
          httpClientCreateCallback: httpClientCreateCallback),
      // transport: HttpTransportType.ServerSentEvents,
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

    // When the connection is closed, print out a message to the console.
    hubConnection!.onclose(
      ({error}) {
        log("Connection Closed");
        widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
            widgetRef.read(connectionDetailsProvider).value?.copyWith(
                      isConnected: false,
                      isConnecting: false,
                    ) ??
                ConnectionDetails.defaultValue());
      },
    );

    hubConnection!.onreconnecting(({error}) {
      log("onreconnecting called");
      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: false,
                    isConnecting: true,
                  ) ??
              ConnectionDetails.defaultValue());
    });

    hubConnection!.onreconnected(({connectionId}) async {
      log("onreconnected called");

      // users cannot be assigned to signalR groups (see here: https://github.com/dotnet/aspnetcore/issues/26133)
      // hence, everytime a user is reconnected, we must ensure we add them to the appropiate groups
      // hence, we read the connectionDetailsProvider to get both campagneId and playerCharacterId
      // and call readdToSignalRGroups() on the server.
      // TODO this is an ugly hack to obtain the instance of IServerMethodsService...
      var serverMethods =
          DependencyProvider.getIt!.get<IServerMethodsService>();
      await serverMethods.readdToSignalRGroups();

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

    await tryOpenConnection();

    var serverMethods = DependencyProvider.getIt!.get<IServerMethodsService>();
    await serverMethods.readdToSignalRGroups();
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
      {List<Object>? args}) async {
    if (!connectionIsOpen) {
      await tryOpenConnection();
    }

    if (hubConnection == null) {
      print("DID NOT SEND TO SERVER: $functionName");

      // dont send something if not connected
      return;
    }

    var retryCounter = 0;
    final maxRetries = 5;
    while (retryCounter < maxRetries &&
        hubConnection?.state == HubConnectionState.Connecting) {
      retryCounter++;
      await Future.delayed(Duration(seconds: retryCounter + 1));
    }

    await hubConnection!.invoke(functionName, args: args);
  }

  Future tryOpenConnection() async {
    if (hubConnection == null ||
        hubConnection?.state == HubConnectionState.Disconnected ||
        hubConnection?.state == HubConnectionState.Disconnecting) {
      // restart connection here!
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
    } catch (e) {
      log(e.toString());
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
  Future executeServerFunction(String functionName, {List<Object>? args}) {
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
}

class HttpOverrideCertificateVerificationInDev extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
