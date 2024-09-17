import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/src/client.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
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

  void updateRpgCharacterConfiguration(RpgCharacterConfiguration config) {
    widgetRef
        .read(rpgCharacterConfigurationProvider.notifier)
        .updateConfiguration(config);
  }
}

////
////
//// WILO: I need to write a riverpod provider for keeping track of the connection details of this service and use this service somewhere to run the constructor...
////
////
class ServerCommunicationService extends IServerCommunicationService {
  bool connectionIsOpen = false;

  ServerCommunicationService({
    required super.widgetRef,
  }) : super(isMock: false) {
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        widgetRef.read(connectionDetailsProvider).value?.copyWith(
                  isConnected: false,
                  isConnecting: true,
                ) ??
            ConnectionDetails.defaultValue());

    // The location of the SignalR Server.
    const serverUrl = "http://localhost:5012/Chat"; // TODO move me to constants

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
    final hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: httpConnectionOptions)
        .withHubProtocol(MessagePackHubProtocol())
        .withAutomaticReconnect(retryDelays: [
      2000,
      5000,
      10000,
      ...List.generate(5000, (i) => 20000)
    ]).build();

    // When the connection is closed, print out a message to the console.
    hubConnection.onclose(
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

    hubConnection.onreconnecting(({error}) {
      print("onreconnecting called");
      connectionIsOpen = false;
      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: false,
                    isConnecting: true,
                  ) ??
              ConnectionDetails.defaultValue());
    });

    hubConnection.onreconnected(({connectionId}) {
      print("onreconnected called");
      connectionIsOpen = true;
      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: true,
                    isConnecting: false,
                  ) ??
              ConnectionDetails.defaultValue());
    });

    hubConnection.on("aClientProvidedFunction", _handleAClientProvidedFunction);

    Future.delayed(Duration.zero, () async {
      widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
          widgetRef.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: true,
                    isConnecting: false,
                  ) ??
              ConnectionDetails.defaultValue());

      await hubConnection.start();
    });
  }

  void _handleAClientProvidedFunction(List<Object?>? parameters) {
    print("Server invoked the method");
  }

  void httpClientCreateCallback(Client httpClient) {
    // TODO check if we need this only on dev or also on prod
    HttpOverrides.global = HttpOverrideCertificateVerificationInDev();
  }
}

class MockServerCommunicationService extends IServerCommunicationService {
  final DateTime? nowOverride;
  const MockServerCommunicationService({
    required super.widgetRef,
    this.nowOverride,
  }) : super(isMock: true);
}

class HttpOverrideCertificateVerificationInDev extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
