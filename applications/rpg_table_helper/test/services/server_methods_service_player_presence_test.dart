import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/navigation_service.dart';
import 'package:quest_keeper/services/server_communication_service.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:signalr_netcore/signalr_client.dart';

class _FakeNavigationService extends INavigationService {
  _FakeNavigationService() : super(isMock: true);

  @override
  TabItem getCurrentTabItem() => TabItem.character;

  @override
  void setCurrentTabItem(TabItem value) {}

  @override
  Map<TabItem, GlobalKey<NavigatorState>> getNavigationKeys() => {
        TabItem.character: const GlobalObjectKey<NavigatorState>('character'),
      };
}

class _RecordedInvoke {
  _RecordedInvoke(this.functionName, this.args);
  final String functionName;
  final List<Object>? args;
}

class _FakeServerCommunicationService extends IServerCommunicationService {
  _FakeServerCommunicationService({required WidgetRef widgetRef})
      : super(isMock: true, apiConnectorService: _FakeApi(), widgetRef: widgetRef);

  final List<_RecordedInvoke> invokes = [];

  @override
  Future startConnection() async {}

  @override
  Future stopConnection() async {}

  @override
  HubConnectionState? get hubConnectionState => null;

  @override
  Future<void> ensureConnectionReadyForSession() async {}

  @override
  void registerCallbackWithoutParameters(
      {required void Function() function, required String functionName}) {}

  @override
  void completeFunctionRegistration() {}

  @override
  void registerCallbackSingleString(
      {required void Function(String parameter) function,
      required String functionName}) {}

  @override
  void registerCallbackTwoStrings(
      {required void Function(String param1, String param2) function,
      required String functionName}) {}

  @override
  void registerCallbackSingleDateTime(
      {required void Function(DateTime parameter) function,
      required String functionName}) {}

  @override
  void registerCallbackSingleDateTimeAndOneString(
      {required void Function(DateTime param1, String param2) function,
      required String functionName}) {}

  @override
  void registerCallbackThreeStrings(
      {required void Function(String param1, String param2, String param3)
              function,
      required String functionName}) {}

  @override
  void registerCallbackFourStrings(
      {required void Function(
              String param1, String param2, String param3, String param4)
          function,
      required String functionName}) {}

  @override
  Future executeServerFunction(String functionName,
      {List<Object>? args, int maxInvokeRetries = 1}) async {}

  @override
  Future<void> executeCriticalServerFunction(String functionName,
      {List<Object>? args, int maxInvokeRetries = 3}) async {
    invokes.add(_RecordedInvoke(functionName, args));
  }

  @override
  Future<void> drainHubInvokeQueue() async {}

  @override
  int get pendingHubInvokeCount => 0;
}

class _FakeApi extends IApiConnectorService {
  _FakeApi() : super(isMock: true);

  @override
  Future<Swagger?> getApiConnector({bool requiresJwt = true}) async => null;

  @override
  Future<String?> getJwt() async => null;

  @override
  Future<bool> setJwt(String jwt) async => true;

  @override
  Future<bool> deleteJwt() async => true;

  @override
  Future<ChopperClient?> getChopperClient({bool requiresJwt = true}) async =>
      null;

  @override
  void clearCache() {}
}

void main() {
  testWidgets('updateRpgCharacterConfigOnDmSide registers connected player',
      (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(ProviderScope(
      child: Consumer(builder: (context, r, _) {
        ref = r;
        return const MaterialApp(home: SizedBox.shrink());
      }),
    ));

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
          ConnectionDetails.defaultValue().copyWith(
            isDm: true,
            isInSession: true,
            campagneId: 'camp-1',
            connectedPlayers: [],
          ),
        );

    final svc = ServerMethodsService(
      serverCommunicationService: _FakeServerCommunicationService(widgetRef: ref),
      navigationService: _FakeNavigationService(),
      widgetRef: ref,
    );

    const playerId = '11111111-1111-1111-1111-111111111111';
    const userId = '22222222-2222-2222-2222-222222222222';
    final cfg = RpgCharacterConfiguration.getBaseConfiguration(null);

    svc.updateRpgCharacterConfigOnDmSide(
      jsonEncode(cfg.toJson()),
      playerId,
      userId,
    );

    final players =
        ref.read(connectionDetailsProvider).requireValue.connectedPlayers!;
    expect(players.length, 1);
    expect(players.single.playerCharacterId.$value, playerId);
    expect(players.single.userId.$value, userId);
    expect(players.single.lastPing, isNotNull);
  });

  testWidgets('updateRpgCharacterConfigOnDmSideV3 full envelope registers player',
      (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(ProviderScope(
      child: Consumer(builder: (context, r, _) {
        ref = r;
        return const MaterialApp(home: SizedBox.shrink());
      }),
    ));

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
          ConnectionDetails.defaultValue().copyWith(
            isDm: true,
            isInSession: true,
            campagneId: 'camp-1',
            connectedPlayers: [],
          ),
        );

    final svc = ServerMethodsService(
      serverCommunicationService: _FakeServerCommunicationService(widgetRef: ref),
      navigationService: _FakeNavigationService(),
      widgetRef: ref,
    );

    const playerId = '33333333-3333-3333-3333-333333333333';
    const userId = '44444444-4444-4444-4444-444444444444';
    final cfg = RpgCharacterConfiguration.getBaseConfiguration(null);

    svc.updateRpgCharacterConfigOnDmSideV3(
      jsonEncode({
        'kind': 'full',
        'slice': 'character',
        'revision': 2,
        'body': cfg.toJson(),
      }),
      playerId,
      userId,
    );

    final players =
        ref.read(connectionDetailsProvider).requireValue.connectedPlayers!;
    expect(players.length, 1);
    expect(players.single.playerCharacterId.$value, playerId);
  });

  testWidgets('pongFromPlayer updates lastPing for known connected player',
      (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(ProviderScope(
      child: Consumer(builder: (context, r, _) {
        ref = r;
        return const MaterialApp(home: SizedBox.shrink());
      }),
    ));

    const userId = '55555555-5555-5555-5555-555555555555';
    final cfg = RpgCharacterConfiguration.getBaseConfiguration(null);
    final stalePing = DateTime(2020, 1, 1);

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
          ConnectionDetails.defaultValue().copyWith(
            isDm: true,
            isInSession: true,
            connectedPlayers: [
              OpenPlayerConnection(
                userId: UserIdentifier($value: userId),
                playerCharacterId: PlayerCharacterIdentifier(
                  $value: '66666666-6666-6666-6666-666666666666',
                ),
                configuration: cfg,
                lastPing: stalePing,
              ),
            ],
          ),
        );

    final svc = ServerMethodsService(
      serverCommunicationService: _FakeServerCommunicationService(widgetRef: ref),
      navigationService: _FakeNavigationService(),
      widgetRef: ref,
    );

    final pongTime = DateTime(2025, 6, 1, 12, 0);
    svc.pongFromPlayer(pongTime, userId);

    final lastPing = ref
        .read(connectionDetailsProvider)
        .requireValue
        .connectedPlayers!
        .single
        .lastPing;
    expect(lastPing, pongTime);
  });

  testWidgets('requestStatusFromPlayers pushes character config upstream',
      (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(ProviderScope(
      child: Consumer(builder: (context, r, _) {
        ref = r;
        return const MaterialApp(home: SizedBox.shrink());
      }),
    ));

    const playerCharacterId = '77777777-7777-7777-7777-777777777777';
    final charCfg = RpgCharacterConfiguration.getBaseConfiguration(null);

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
          ConnectionDetails.defaultValue().copyWith(
            isDm: false,
            isInSession: true,
            campagneId: 'camp-1',
            playerCharacterId: playerCharacterId,
          ),
        );
    ref
        .read(rpgCharacterConfigurationProvider.notifier)
        .updateConfiguration(charCfg);

    final fakeComm = _FakeServerCommunicationService(widgetRef: ref);
    final svc = ServerMethodsService(
      serverCommunicationService: fakeComm,
      navigationService: _FakeNavigationService(),
      widgetRef: ref,
    );

    svc.requestStatusFromPlayers();
    await tester.pump(const Duration(milliseconds: 900));

    final characterSends = fakeComm.invokes.where((e) =>
        e.functionName == 'SendUpdatedRpgCharacterConfigToDm' ||
        e.functionName == 'SendUpdatedRpgCharacterConfigToDmV3');
    expect(characterSends.isNotEmpty, isTrue);
    expect(characterSends.last.args?.first, playerCharacterId);
  });
}
