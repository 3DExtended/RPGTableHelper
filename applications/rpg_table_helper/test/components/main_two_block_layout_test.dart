import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/main_two_block_layout.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/navigation_service.dart';

import '../test_configuration.dart';

void main() {
  var connectionDetailList = [
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "d21ea4c7-d58c-48fc-a1a9-ca93b0d125d4", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: false,
      isConnected: false,
      isConnecting: false,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "d659d4fe-1476-47bb-8e25-f6676cb7fe43", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: false,
      isConnected: true,
      isConnecting: false,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "6f399997-41ad-4900-b99a-4bfad53ce15b", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: false,
      isConnected: true,
      isConnecting: true,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "6aaba573-9779-4afc-bf97-ea2024189024", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: false,
      isConnected: false,
      isConnecting: true,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "9c167b31-3fb0-40ea-9657-b361bc85df53", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: false,
      isConnected: false,
      isConnecting: false,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "b05951ba-7e51-4cfd-8009-b4884c22e4cd", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: false,
      isConnected: true,
      isConnecting: false,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "6a3bc897-f8a2-465e-bf45-4c15338fc859", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: false,
      isConnected: true,
      isConnecting: true,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "dd793d88-de38-4985-9bf3-4b447f096d41", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: false,
      isConnected: false,
      isConnecting: true,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "2acb27e8-6cb3-4a9b-8944-37a913c961e5", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: true,
      isConnected: false,
      isConnecting: false,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "a3768411-2e0d-432c-950c-35112abd923a", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: true,
      isConnected: true,
      isConnecting: false,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "10323611-6a44-4a42-9cd9-b587c49c24a7", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: true,
      isConnected: true,
      isConnecting: true,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "4ccc44f6-b1a5-4de5-81eb-b4b0a9e58075", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: true,
      isConnected: false,
      isConnecting: true,
      isDm: true,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "eb466b58-b7df-4d67-8239-9c0dd2cd8483", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: true,
      isConnected: false,
      isConnecting: false,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "c3d18854-88fa-414a-921c-e17245f0fb25", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: true,
      isConnected: true,
      isConnecting: false,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "ce54780f-ced1-410f-9c29-c1e6a891eb1b", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: true,
      isConnected: true,
      isConnecting: true,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
    ConnectionDetails(
      fightSequence: FightSequence(
          fightUuid: "cb7b2892-57e2-4d7d-a983-456b8085da4c", sequence: []),
      lastGrantedItems: null,
      connectedPlayers: [],
      openPlayerRequests: [],
      isInSession: true,
      isConnected: false,
      isConnecting: true,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
      campagneId: null,
      playerCharacterId: null,
    ),
  ];

  group('MainTwoBlockLayout rendering', () {
    for (int i = 0; i < connectionDetailList.length; i++) {
      var connectionDetails = connectionDetailList[i];
      testConfigurations(
        disableLocals: true,
        widgetName: 'MainTwoBlockLayout${i + 1}',
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => ProviderScope(
          overrides: [
            connectionDetailsProvider.overrideWith((ref) {
              return ConnectionDetailsNotifier(
                initState: AsyncValue.data(connectionDetails),
                ref: ref,
                runningInTests: true,
              );
            }),
          ],
          child: MainTwoBlockLayout(
            showIsConnectedButton: true,
            selectedNavbarButton: 1,
            content: Container(color: const Color.fromARGB(102, 0, 0, 0)),
            navbarButtons: [
              NavbarButton(
                tabItem: TabItem.search,
                onPressed: (_) {},
                icon: Container(
                  width: 20,
                  height: 20,
                  color: Colors.green,
                ),
              ),
              NavbarButton(
                tabItem: TabItem.character,
                onPressed: (_) {},
                icon: Container(
                  width: 20,
                  height: 20,
                  color: const Color.fromARGB(255, 76, 84, 175),
                ),
              ),
              NavbarButton(
                tabItem: TabItem.inventory,
                onPressed: (_) {},
                icon: Container(
                  width: 20,
                  height: 20,
                  color: const Color.fromARGB(255, 175, 76, 165),
                ),
              ),
              NavbarButton(
                tabItem: TabItem.crafting,
                onPressed: (_) {},
                icon: Container(
                  width: 20,
                  height: 20,
                  color: const Color.fromARGB(255, 175, 76, 76),
                ),
              ),
              NavbarButton(
                tabItem: TabItem.lore,
                onPressed: (_) {},
                icon: Container(
                  width: 20,
                  height: 20,
                  color: const Color.fromARGB(255, 175, 165, 76),
                ),
              )
            ],
          ),
        ),
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: Center(
                child: widgetToTest,
              ),
            ),
          ),
        ]),
      );
    }
  });
}
