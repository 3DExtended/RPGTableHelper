import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/src/client.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/msgpack_hub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

abstract class IServerCommunicationService {
  final bool isMock;
  final WidgetRef widgetRef;
  const IServerCommunicationService({
    required this.isMock,
    required this.widgetRef,
  });

  void updateRpgConfiguration(RpgConfigurationModel config) {
    widgetRef
        .read(rpgConfigurationProvider.notifier)
        .updateConfiguration(config);
  }

  void registerCallbackWithoutParameters(
      {required void Function() function, required String functionName});

  void registerCallbackSingleString({
    required void Function(String parameter) function,
    required String functionName,
  });

  void registerCallbackThreeStrings(
      {required void Function(String param1, String param2, String param3)
          function,
      required String functionName});

  Future executeServerFunction(String functionName, {List<Object>? args});
}

////
////
//// WILO: I need to write a riverpod provider for keeping track of the connection details of this service and use this service somewhere to run the constructor...
////
////
class ServerCommunicationService extends IServerCommunicationService {
  bool connectionIsOpen = false;
  late HubConnection? hubConnection;
  ServerCommunicationService({
    required super.widgetRef,
  }) : super(isMock: false) {
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        widgetRef.read(connectionDetailsProvider).value?.copyWith(
                  isConnected: false,
                  isConnecting: true,
                ) ??
            ConnectionDetails.defaultValue());

    final defaultHeaders = MessageHeaders();
    defaultHeaders.setHeaderValue("HEADER_MOCK_1", "HEADER_VALUE_1");
    defaultHeaders.setHeaderValue("HEADER_MOCK_2", "HEADER_VALUE_2");

    final httpConnectionOptions = HttpConnectionOptions(
      httpClient: WebSupportingHttpClient(null,
          httpClientCreateCallback: httpClientCreateCallback),
      accessTokenFactory: () => Future.value('JWT_TOKEN'), // TODO handle JWT...
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
        print("Connection Closed");
        widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
            widgetRef.read(connectionDetailsProvider).value?.copyWith(
                      isConnected: false,
                      isConnecting: false,
                    ) ??
                ConnectionDetails.defaultValue());
      },
    );

    hubConnection!.onreconnecting(({error}) {
      print("onreconnecting called");
      connectionIsOpen = false;
      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: false,
                    isConnecting: true,
                  ) ??
              ConnectionDetails.defaultValue());
    });

    hubConnection!.onreconnected(({connectionId}) {
      print("onreconnected called");
      connectionIsOpen = true;
      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: true,
                    isConnecting: false,
                  ) ??
              ConnectionDetails.defaultValue());
    });

    hubConnection!
        .on("aClientProvidedFunction", _handleAClientProvidedFunction);
    Future.delayed(Duration.zero, () async {
      await tryOpenConnection();
    });
  }

  void _handleAClientProvidedFunction(List<Object?>? parameters) {
    print("Server invoked the method");
  }

  void httpClientCreateCallback(Client httpClient) {
    // TODO check if we need this only on dev or also on prod
    HttpOverrides.global = HttpOverrideCertificateVerificationInDev();
  }

  @override
  void registerCallbackWithoutParameters(
      {required void Function() function, required String functionName}) {
    hubConnection!.on(functionName, (List<Object?>? parameters) {
      function();
    });
  }

  @override
  void registerCallbackSingleString({
    required void Function(String parameter) function,
    required String functionName,
  }) {
    hubConnection!.on(functionName, (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      final String? param =
          parameters[0] != null ? parameters[0] as String : null;

      if (param == null) return;

      function(param);
    });
  }

  @override
  void registerCallbackThreeStrings(
      {required void Function(String param1, String param2, String param3)
          function,
      required String functionName}) {
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
  }

  @override
  Future executeServerFunction(String methodName, {List<Object>? args}) async {
    if (!connectionIsOpen) {
      await tryOpenConnection();
    }

    await hubConnection!.invoke(methodName, args: args);
  }

  Future tryOpenConnection() async {
    try {
      await hubConnection!.start();
      connectionIsOpen = true;

      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: true,
                    isConnecting: false,
                  ) ??
              ConnectionDetails.defaultValue());
    } catch (e) {}
  }
}

class MockServerCommunicationService extends IServerCommunicationService {
  final DateTime? nowOverride;
  const MockServerCommunicationService({
    required super.widgetRef,
    this.nowOverride,
  }) : super(isMock: true);

  @override
  void registerCallbackSingleString({
    required void Function(String parameter) function,
    required String functionName,
  }) {
    // TODO: implement registerCallbackSingleString
  }

  @override
  Future executeServerFunction(String s, {List<Object>? args}) {
    // TODO: implement executeServerFunction
    throw UnimplementedError();
  }

  @override
  void registerCallbackThreeStrings(
      {required void Function(String param1, String param2, String param3)
          function,
      required String functionName}) {
    // TODO: implement registerCallbackThreeStrings
  }

  @override
  void registerCallbackWithoutParameters(
      {required void Function() function, required String functionName}) {
    // TODO: implement registerCallbackWithoutParameters
  }
}

class HttpOverrideCertificateVerificationInDev extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
