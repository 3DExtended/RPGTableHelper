import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
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

const _coldKeys = {
  "allItems",
  "placesOfFindings",
  "itemCategories",
  "characterStatTabsDefinition",
  "craftingRecipes",
  "currencyDefinition",
};

({Map<String, dynamic> cold, Map<String, dynamic> hot}) _splitColdHot(
  RpgConfigurationModel cfg,
) {
  final full = cfg.toJson();
  final cold = <String, dynamic>{};
  final hot = <String, dynamic>{};
  for (final entry in full.entries) {
    if (_coldKeys.contains(entry.key)) {
      cold[entry.key] = entry.value;
    } else {
      hot[entry.key] = entry.value;
    }
  }
  return (cold: cold, hot: hot);
}

CharacterStatDefinition _dmAddedStat({
  required String statUuid,
  required String name,
}) {
  return CharacterStatDefinition(
    statUuid: statUuid,
    name: name,
    groupId: null,
    helperText: '',
    valueType: CharacterStatValueType.int,
    editType: CharacterStatEditType.static,
    isOptionalForAlternateForms: false,
    isOptionalForCompanionCharacters: false,
  );
}

RpgConfigurationModel _cfgWithStatOnFirstTab(
  RpgConfigurationModel cfg, {
  required CharacterStatDefinition stat,
}) {
  final tabs = cfg.characterStatTabsDefinition!.toList();
  return cfg.copyWith(
    characterStatTabsDefinition: [
      tabs.first.copyWith(
        statsInTab: [...tabs.first.statsInTab, stat],
      ),
      ...tabs.skip(1),
    ],
  );
}

Future<
    ({
      WidgetRef ref,
      _FakeServerCommunicationService fakeComm,
      ServerMethodsService svc,
    })> _setupDmConfigSyncHarness(WidgetTester tester) async {
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

  ref.read(connectionDetailsProvider.notifier).updateConfiguration(
        ref.read(connectionDetailsProvider).requireValue.copyWith(
              isDm: true,
              isConnected: true,
              isInSession: true,
              campagneId: 'c1',
            ),
      );

  return (ref: ref, fakeComm: fakeComm, svc: svc);
}

void _seedV3Slices(
  ServerMethodsService svc,
  RpgConfigurationModel cfg, {
  int coldRevision = 3,
  int hotRevision = 1,
}) {
  final slices = _splitColdHot(cfg);
  svc.updateRpgConfigColdV3(jsonEncode({
    'kind': 'full',
    'revision': coldRevision,
    'body': slices.cold,
  }));
  svc.updateRpgConfigHotV3(jsonEncode({
    'kind': 'full',
    'revision': hotRevision,
    'body': slices.hot,
  }));
}

List<int> _coldV3PatchFromRevisions(_FakeServerCommunicationService fakeComm) {
  return fakeComm.invokes
      .where((e) => e.functionName == 'SendUpdatedRpgConfigColdV3')
      .map((e) {
        final env =
            jsonDecode(e.args![1] as String) as Map<String, dynamic>;
        if (env['kind'] != 'patch') {
          return null;
        }
        return env['fromRevision'] as int;
      })
      .whereType<int>()
      .toList();
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

  testWidgets(
      'v3 cold upstream advances revision when DM adds character stats',
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

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
          ref.read(connectionDetailsProvider).requireValue.copyWith(
                isDm: true,
                isConnected: true,
                isInSession: true,
                campagneId: 'c1',
              ),
        );

    final cfg = RpgConfigurationModel.getBaseConfiguration();
    final coldBaseline = <String, dynamic>{};
    final hotBaseline = <String, dynamic>{};
    for (final entry in cfg.toJson().entries) {
      if (entry.key == 'rpgName') {
        hotBaseline[entry.key] = entry.value;
      } else {
        coldBaseline[entry.key] = entry.value;
      }
    }

    svc.updateRpgConfigColdV3(jsonEncode({
      'kind': 'full',
      'revision': 3,
      'body': coldBaseline,
    }));
    svc.updateRpgConfigHotV3(jsonEncode({
      'kind': 'full',
      'revision': 1,
      'body': hotBaseline,
    }));

    final tabs = cfg.characterStatTabsDefinition!.toList();
    final firstTab = tabs.first;
    final cfgWithNewSkill = cfg.copyWith(
      characterStatTabsDefinition: [
        firstTab.copyWith(
          statsInTab: [
            ...firstTab.statsInTab,
            CharacterStatDefinition(
              statUuid: '01999999-9999-7999-8999-999999999999',
              name: 'Neue Fertigkeit',
              groupId: null,
              helperText: 'DM-added skill',
              valueType: CharacterStatValueType.int,
              editType: CharacterStatEditType.static,
              isOptionalForAlternateForms: false,
              isOptionalForCompanionCharacters: false,
            ),
          ],
        ),
        ...tabs.skip(1),
      ],
    );

    await svc.sendUpdatedRpgConfig(rpgConfig: cfgWithNewSkill, campagneId: 'c1');
    await tester.pump(const Duration(milliseconds: 900));

    final cfgWithSecondSkill = cfgWithNewSkill.copyWith(
      characterStatTabsDefinition: [
        cfgWithNewSkill.characterStatTabsDefinition!.first.copyWith(
          statsInTab: [
            ...cfgWithNewSkill.characterStatTabsDefinition!.first.statsInTab,
            CharacterStatDefinition(
              statUuid: '01999999-9999-7999-8999-999999999998',
              name: 'Zweite Fertigkeit',
              groupId: null,
              helperText: 'second skill',
              valueType: CharacterStatValueType.int,
              editType: CharacterStatEditType.static,
              isOptionalForAlternateForms: false,
              isOptionalForCompanionCharacters: false,
            ),
          ],
        ),
        ...cfgWithNewSkill.characterStatTabsDefinition!.skip(1),
      ],
    );

    await svc.sendUpdatedRpgConfig(
        rpgConfig: cfgWithSecondSkill, campagneId: 'c1');
    await tester.pump(const Duration(milliseconds: 900));

    final coldV3Calls = fakeComm.invokes
        .where((e) => e.functionName == 'SendUpdatedRpgConfigColdV3')
        .toList();
    expect(coldV3Calls.length, 2);

    final firstEnv =
        jsonDecode(coldV3Calls[0].args![1] as String) as Map<String, dynamic>;
    final secondEnv =
        jsonDecode(coldV3Calls[1].args![1] as String) as Map<String, dynamic>;
    expect(firstEnv['kind'], 'patch');
    expect(firstEnv['fromRevision'], 3);
    expect(secondEnv['kind'], 'patch');
    expect(secondEnv['fromRevision'], 4);
  });

  testWidgets(
    'v3 cold upstream advances revision across three consecutive DM stat adds',
    (tester) async {
      final harness = await _setupDmConfigSyncHarness(tester);
      final cfg = RpgConfigurationModel.getBaseConfiguration();
      _seedV3Slices(harness.svc, cfg);

      var current = cfg;
      for (var i = 0; i < 3; i++) {
        current = _cfgWithStatOnFirstTab(
          current,
          stat: _dmAddedStat(
            statUuid: '01999999-9999-7999-8999-99999999999$i',
            name: 'DM stat $i',
          ),
        );
        await harness.svc.sendUpdatedRpgConfig(
          rpgConfig: current,
          campagneId: 'c1',
        );
        await tester.pump(const Duration(milliseconds: 900));
      }

      final fromRevisions = _coldV3PatchFromRevisions(harness.fakeComm);
      expect(fromRevisions, [3, 4, 5]);
    },
  );

  testWidgets(
    'v3 cold upstream after legacy updateRpgConfig supports second DM stat add',
    (tester) async {
      final harness = await _setupDmConfigSyncHarness(tester);
      final cfg = RpgConfigurationModel.getBaseConfiguration();

      // REST / legacy full config: slice JSON cached, revisions cleared (DM gets no echo).
      harness.svc.updateRpgConfig(jsonEncode(cfg.toJson()));

      final withFirst = _cfgWithStatOnFirstTab(
        cfg,
        stat: _dmAddedStat(
          statUuid: '01999999-9999-7999-8999-999999999991',
          name: 'First after REST',
        ),
      );
      await harness.svc.sendUpdatedRpgConfig(
        rpgConfig: withFirst,
        campagneId: 'c1',
      );
      await tester.pump(const Duration(milliseconds: 900));

      final withSecond = _cfgWithStatOnFirstTab(
        withFirst,
        stat: _dmAddedStat(
          statUuid: '01999999-9999-7999-8999-999999999992',
          name: 'Second after REST',
        ),
      );
      await harness.svc.sendUpdatedRpgConfig(
        rpgConfig: withSecond,
        campagneId: 'c1',
      );
      await tester.pump(const Duration(milliseconds: 900));

      final coldV3Calls = harness.fakeComm.invokes
          .where((e) => e.functionName == 'SendUpdatedRpgConfigColdV3')
          .toList();
      expect(coldV3Calls.length, greaterThanOrEqualTo(2));

      final patchRevisions = _coldV3PatchFromRevisions(harness.fakeComm);
      expect(patchRevisions.length, greaterThanOrEqualTo(1));
      expect(patchRevisions.last, greaterThanOrEqualTo(1));
    },
  );

  testWidgets('inbound config slices are ignored during outbound debounce',
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

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
          ref.read(connectionDetailsProvider).requireValue.copyWith(
                isDm: true,
                isConnected: true,
                isInSession: true,
                campagneId: 'c1',
              ),
        );

    final cfg = RpgConfigurationModel.getBaseConfiguration();
    ref.read(rpgConfigurationProvider.notifier).updateConfiguration(cfg);
    final statsBefore =
        cfg.characterStatTabsDefinition!.first.statsInTab.length;

    final coldBaseline = <String, dynamic>{};
    final hotBaseline = <String, dynamic>{};
    for (final entry in cfg.toJson().entries) {
      if (entry.key == 'rpgName') {
        hotBaseline[entry.key] = entry.value;
      } else {
        coldBaseline[entry.key] = entry.value;
      }
    }

    svc.updateRpgConfigColdV3(jsonEncode({
      'kind': 'full',
      'revision': 2,
      'body': coldBaseline,
    }));
    svc.updateRpgConfigHotV3(jsonEncode({
      'kind': 'full',
      'revision': 1,
      'body': hotBaseline,
    }));

    final tabs = cfg.characterStatTabsDefinition!.toList();
    final cfgWithNewSkill = cfg.copyWith(
      characterStatTabsDefinition: [
        tabs.first.copyWith(
          statsInTab: [
            ...tabs.first.statsInTab,
            CharacterStatDefinition(
              statUuid: '01999999-9999-7999-8999-999999999997',
              name: 'Inbound block test skill',
              groupId: null,
              helperText: '',
              valueType: CharacterStatValueType.int,
              editType: CharacterStatEditType.static,
              isOptionalForAlternateForms: false,
              isOptionalForCompanionCharacters: false,
            ),
          ],
        ),
        ...tabs.skip(1),
      ],
    );
    ref
        .read(rpgConfigurationProvider.notifier)
        .updateConfiguration(cfgWithNewSkill);

    await svc.sendUpdatedRpgConfig(
        rpgConfig: cfgWithNewSkill, campagneId: 'c1');

    final staleCold = Map<String, dynamic>.from(coldBaseline);
    staleCold['characterStatTabsDefinition'] = [];
    svc.updateRpgConfigColdV3(jsonEncode({
      'kind': 'full',
      'revision': 99,
      'body': staleCold,
    }));

    final duringDebounce =
        ref.read(rpgConfigurationProvider).requireValue;
    expect(
      duringDebounce.characterStatTabsDefinition!.first.statsInTab.length,
      statsBefore + 1,
    );

    await tester.pump(const Duration(milliseconds: 900));
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

