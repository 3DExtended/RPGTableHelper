import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
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
  RpgConfigurationModel? lastUpdatedConfig;

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

  @override
  void updateRpgConfiguration(RpgConfigurationModel config) {
    lastUpdatedConfig = config;
    super.updateRpgConfiguration(config);
  }
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
  testWidgets('sendUpdatedRpgConfig is debounced and de-duplicated', (tester) async {
    late WidgetRef ref;

    await tester.pumpWidget(ProviderScope(
      child: Consumer(builder: (context, r, _) {
        ref = r;
        return const MaterialApp(home: SizedBox.shrink());
      }),
    ));

    final fakeComm = _FakeServerCommunicationService(widgetRef: ref);
    final svc = ServerMethodsService(
      serverCommunicationService: fakeComm,
      navigationService: _FakeNavigationService(),
      widgetRef: ref,
    );

    final cfg = RpgConfigurationModel.getBaseConfiguration();

    // Rapid repeated calls should debounce into <= 2 invokes (cold + hot) once.
    await svc.sendUpdatedRpgConfig(rpgConfig: cfg, campagneId: 'c1');
    await svc.sendUpdatedRpgConfig(rpgConfig: cfg, campagneId: 'c1');

    await tester.pump(const Duration(milliseconds: 900));

    fakeComm.invokes.where((e) => e.functionName.startsWith('SendUpdatedRpgConfig'))
        .length
        .shouldBeGreaterThan(0);

    // Re-sending identical config after flush should not send again.
    final before = fakeComm.invokes.length;
    await svc.sendUpdatedRpgConfig(rpgConfig: cfg, campagneId: 'c1');
    await tester.pump(const Duration(milliseconds: 900));
    fakeComm.invokes.length.shouldBe(before);
  });

  testWidgets('updateRpgConfigCold+Hot merges into provider update', (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(ProviderScope(
      child: Consumer(builder: (context, r, _) {
        ref = r;
        return const MaterialApp(home: SizedBox.shrink());
      }),
    ));

    final fakeComm = _FakeServerCommunicationService(widgetRef: ref);
    final svc = ServerMethodsService(
      serverCommunicationService: fakeComm,
      navigationService: _FakeNavigationService(),
      widgetRef: ref,
    );

    final base = RpgConfigurationModel.getBaseConfiguration();
    ref.read(rpgConfigurationProvider.notifier).updateConfiguration(base);

    const coldKeys = {
      "allItems",
      "placesOfFindings",
      "itemCategories",
      "characterStatTabsDefinition",
      "craftingRecipes",
      "currencyDefinition",
    };

    final full = base.toJson();
    final cold = <String, dynamic>{};
    final hot = <String, dynamic>{};
    for (final e in full.entries) {
      if (coldKeys.contains(e.key)) {
        cold[e.key] = e.value;
      } else {
        hot[e.key] = e.value;
      }
    }
    hot["rpgName"] = "HotName";

    svc.updateRpgConfigCold(jsonEncode(cold));
    svc.updateRpgConfigHot(jsonEncode(hot));

    final updated = ref.read(rpgConfigurationProvider).requireValue;
    updated.rpgName.shouldBe('HotName');
  });

  testWidgets('sendUpdatedRpgCharacterConfig is debounced and de-duplicated',
      (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(ProviderScope(
      child: Consumer(builder: (context, r, _) {
        ref = r;
        return const MaterialApp(home: SizedBox.shrink());
      }),
    ));

    final fakeComm = _FakeServerCommunicationService(widgetRef: ref);
    final svc = ServerMethodsService(
      serverCommunicationService: fakeComm,
      navigationService: _FakeNavigationService(),
      widgetRef: ref,
    );

    final charCfg = RpgCharacterConfiguration.getBaseConfiguration(null);

    await svc.sendUpdatedRpgCharacterConfig(
        charConfig: charCfg, playercharacterid: 'p1');
    await svc.sendUpdatedRpgCharacterConfig(
        charConfig: charCfg, playercharacterid: 'p1');
    await tester.pump(const Duration(milliseconds: 900));

    final calls = fakeComm.invokes
        .where((e) => e.functionName == 'SendUpdatedRpgCharacterConfigToDm')
        .toList();
    calls.length.shouldBe(1);
  });
}

extension _Expect on int {
  void shouldBe(int other) => expect(this, other);
  void shouldBeGreaterThan(int other) => expect(this, greaterThan(other));
}

extension _ExpectStr on String {
  void shouldBe(String other) => expect(this, other);
}

