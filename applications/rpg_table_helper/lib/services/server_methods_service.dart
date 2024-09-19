import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/services/server_communication_service.dart';

abstract class IServerMethodsService {
  final bool isMock;
  final WidgetRef widgetRef;

  final IServerCommunicationService serverCommunicationService;
  IServerMethodsService({
    required this.isMock,
    required this.widgetRef,
    required this.serverCommunicationService,
  }) {
    serverCommunicationService.registerCallbackSingleString(
        registerGameResponse: registerGameResponse,
        functionName: "registerGameResponse");
  }

  // this should contain every method that is callable by the server
  void registerGameResponse({required String parameter});

  // this should contain every method that calls the server
  Future registerGame({required String campagneName});
}

class ServerMethodsService extends IServerMethodsService {
  ServerMethodsService(
      {required super.serverCommunicationService, required super.widgetRef})
      : super(isMock: false);

  @override
  Future registerGame({required String campagneName}) async {
    await serverCommunicationService
        .executeServerFunction("RegisterGame", args: [campagneName]);
  }

  @override
  void registerGameResponse({required String parameter}) {
    print("Gamecode: $parameter");
    // as we have loaded the session here, we now can update the riverpod state to reflect that
    widgetRef.read(connectionDetailsProvider.notifier).updateConfiguration(
        widgetRef.read(connectionDetailsProvider).value?.copyWith(
                isConnected: true,
                isConnecting: false,
                isDm: true,
                isInSession: true,
                sessionConnectionNumberForPlayers: parameter) ??
            ConnectionDetails.defaultValue());
  }
}
