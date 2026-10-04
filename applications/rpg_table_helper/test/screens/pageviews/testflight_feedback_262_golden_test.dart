import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:http/http.dart' as http;
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/components/notes/lore_block_rendering_editable.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/note_documents_service.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

import '../../custom_font_loader.dart';

/// Scenarios reported via TestFlight feedback on build 0.9.3+262. Each one
/// renders the reported screen in the tester's skin so the fix can be checked
/// visually (and stays fixed).

const _campagneId = '51f263bc-37cf-44d4-90f3-87d656ae29df';
const _myUserId = '5def694e-8829-4fdd-afc5-342dc28c5ae2';
const _dmUserId = 'd7c27d97-d973-465d-a2e5-9f605fd1f0c9';

/// Server-side (database) id of the player's character. Deliberately differs
/// from the client-generated `RpgCharacterConfiguration.uuid`.
const _playerCharacterDbId = '0198f5b6-3a43-7c11-9e2f-6a1c3e5d7b90';

const _ipadPro11Landscape = Size(1194, 834);
const _ipadPro13Landscape = Size(1366, 1024);

/// Keyboard height of the German iPad Pro 11" landscape keyboard incl. the
/// predictive bar (measured from the TestFlight screenshot).
const _ipadPro11KeyboardHeight = 428.0;

NoteDocumentDto _ownNotesDocument() {
  final created = DateTime(2026, 10, 2, 22, 12);
  return NoteDocumentDto(
    groupName: 'Session Notes',
    createdForCampagneId: CampagneIdentifier($value: _campagneId),
    title: 'Notizen und Dokumente von Ettrian Ravaren',
    creatingUserId: UserIdentifier($value: _myUserId),
    id: NoteDocumentIdentifier($value: '01999f0e-0000-7000-8000-00000000d0c1'),
    isDeleted: false,
    creationDate: created,
    lastModifiedAt: created,
    imageBlocks: [],
    textBlocks: [
      TextBlock(
        creatingUserId: UserIdentifier($value: _myUserId),
        creationDate: created,
        id: NoteBlockModelBaseIdentifier(
            $value: '01999f0e-0000-7000-8000-00000000b001'),
        isDeleted: false,
        lastModifiedAt: created,
        permittedUsers: [],
        markdownText:
            '## Preparations\n\nIch glaube ich will Counterspell lernen!\n\n## Notes\n\nStart-Ort: Wolkenmeer',
      ),
    ],
  );
}

NoteDocumentDto _dmSharedDocument() {
  final created = DateTime(2026, 10, 3, 10, 50);
  return NoteDocumentDto(
    groupName: 'Abenteuer',
    createdForCampagneId: CampagneIdentifier($value: _campagneId),
    title: 'Brief des Hafenmeisters',
    creatingUserId: UserIdentifier($value: _dmUserId),
    id: NoteDocumentIdentifier($value: '01999f0e-0000-7000-8000-00000000d0c2'),
    isDeleted: false,
    creationDate: created,
    lastModifiedAt: created,
    imageBlocks: [],
    textBlocks: [
      TextBlock(
        creatingUserId: UserIdentifier($value: _dmUserId),
        creationDate: created,
        id: NoteBlockModelBaseIdentifier(
            $value: '01999f0e-0000-7000-8000-00000000b002'),
        isDeleted: false,
        lastModifiedAt: created,
        permittedUsers: [UserIdentifier($value: _myUserId)],
        markdownText: 'Die Rabenkrone darf am Pier 3 anlegen.',
      ),
    ],
  );
}

/// [EventsClient] whose `/events` stream is fed by the test.
class _ControllableEvents {
  final _bytes = StreamController<List<int>>.broadcast();
  late final EventsClient client = EventsClient(
    getJwt: () async => 'jwt',
    openStream: ({required uri, required jwt}) async =>
        http.ByteStream(_bytes.stream),
    sleep: (_) async {},
  );

  void push(String type, Map<String, dynamic> data) {
    _bytes.add(utf8.encode('event: $type\ndata: ${jsonEncode(data)}\n\n'));
  }
}

const _companionStatUuid = '0199a1c0-0000-7000-8000-0000000c0001';
const _vehicleStatUuid = '0199a1c0-0000-7000-8000-0000000c0002';

RpgConfigurationModel _configWithCompanionStats(String skinId) {
  final base = RpgConfigurationModel.getBaseConfiguration();
  final tabs = base.characterStatTabsDefinition!;
  final firstTab = tabs.first;
  return base.copyWith(
    defaultSkinId: skinId,
    characterStatTabsDefinition: [
      firstTab.copyWith(statsInTab: [
        ...firstTab.statsInTab,
        CharacterStatDefinition(
          statUuid: _companionStatUuid,
          name: 'Begleiter',
          helperText: '',
          groupId: null,
          valueType: CharacterStatValueType.companionSelector,
          editType: CharacterStatEditType.static,
          isOptionalForAlternateForms: false,
          isOptionalForCompanionCharacters: false,
        ),
        CharacterStatDefinition(
          statUuid: _vehicleStatUuid,
          name: 'Fahrzeug',
          helperText: '',
          groupId: null,
          valueType: CharacterStatValueType.companionSelector,
          editType: CharacterStatEditType.static,
          isOptionalForAlternateForms: false,
          isOptionalForCompanionCharacters: false,
          jsonSerializedAdditionalData: jsonEncode({'iconName': 'sailboat'}),
        ),
      ]),
      ...tabs.skip(1),
    ],
  );
}

RpgCharacterConfiguration _characterFor(
  RpgConfigurationModel config,
  String skinId, {
  bool withCompanions = false,
}) {
  final base = RpgCharacterConfiguration.getBaseConfiguration(
    config,
    variant: 0,
  ).copyWith(skinId: skinId, characterName: 'Thamior');
  if (!withCompanions) return base;

  RpgAlternateCharacterConfiguration companion(String uuid, String name) =>
      RpgAlternateCharacterConfiguration(
        uuid: uuid,
        characterName: name,
        characterStats: [],
        transformationComponents: null,
        alternateForm: null,
        isAlternateFormActive: false,
      );

  return base.copyWith(
    companionCharacters: [
      companion('0199a1c0-0000-7000-8000-00000000a001', 'Aurora'),
      companion('0199a1c0-0000-7000-8000-00000000a002', 'Bruce'),
      companion('0199a1c0-0000-7000-8000-00000000a003', 'Rabenkrone'),
    ],
    characterStats: [
      ...base.characterStats,
      RpgCharacterStatValue(
        statUuid: _companionStatUuid,
        serializedValue: jsonEncode({
          'values': [
            {'uuid': '0199a1c0-0000-7000-8000-00000000a001'},
            {'uuid': '0199a1c0-0000-7000-8000-00000000a002'},
          ],
        }),
        hideFromCharacterScreen: false,
        hideLabelOfStat: false,
        variant: 0,
      ),
      RpgCharacterStatValue(
        statUuid: _vehicleStatUuid,
        serializedValue: jsonEncode({
          'values': [
            {'uuid': '0199a1c0-0000-7000-8000-00000000a003'},
          ],
        }),
        hideFromCharacterScreen: false,
        hideLabelOfStat: false,
        variant: 0,
      ),
    ],
  );
}

ConnectionDetails _playerConnectionDetails() {
  return ConnectionDetails.defaultValue().copyWith(
    isConnected: true,
    isInSession: true,
    isDm: false,
    campagneId: _campagneId,
    playerCharacterId: _playerCharacterDbId,
  );
}

/// Pumps the player page like the real app does (top-level route, no outer
/// Scaffold) and paints a placeholder where the software keyboard would be.
Future<void> _pumpPlayerPage(
  WidgetTester tester, {
  required Size surface,
  required String skinId,
  required RpgConfigurationModel config,
  required RpgCharacterConfiguration character,
  required int startScreen,
  Map<Type, dynamic Function()>? mockOverrides,
}) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24);
  addTearDown(tester.view.reset);

  await customLoadAppFonts();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        rpgConfigurationProvider.overrideWith((ref) => RpgConfigurationNotifier(
              decks: AsyncValue.data(config),
              ref: ref,
              runningInTests: true,
            )),
        rpgCharacterConfigurationProvider
            .overrideWith((ref) => RpgCharacterConfigurationNotifier(
                  decks: AsyncValue.data(character),
                  ref: ref,
                  runningInTests: true,
                )),
        connectionDetailsProvider
            .overrideWith((ref) => ConnectionDetailsNotifier(
                  initState: AsyncValue.data(_playerConnectionDetails()),
                  ref: ref,
                  runningInTests: true,
                )),
      ],
      child: DependencyProvider.getMockedDependecyProvider(
        mockOverrides: mockOverrides,
        child: CustomThemeProvider(
          overrideBrightness: Brightness.dark,
          overrideSkinId: skinId,
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale('de'),
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData.dark(useMaterial3: true),
              builder: (context, child) {
                final keyboard = MediaQuery.viewInsetsOf(context).bottom;
                return Stack(children: [
                  child!,
                  if (keyboard > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: keyboard,
                      child: const _KeyboardPlaceholder(),
                    ),
                ]);
              },
              home: PlayerPageScreen(
                startScreenOverride: startScreen,
                routeSettings: PlayerPageScreenRouteSettings(
                  characterConfigurationOverride: null,
                  showInventory: true,
                  showRecipes: true,
                  showMoney: true,
                  showLore: true,
                  disableEdit: false,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await customLoadAppFonts();
  await tester.pumpAndSettle();
}

Finder _editButtonOfFirstLoreBlock() => find.descendant(
      of: find.byType(LoreBlockRenderingEditable).first,
      matching: find.byWidgetPredicate(
        (w) => w is CustomFaIcon && w.icon == FontAwesomeIcons.penToSquare,
      ),
    );

class _KeyboardPlaceholder extends StatelessWidget {
  const _KeyboardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFD1D3D9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Bildschirmtastatur',
        style: TextStyle(
          color: Color(0xFF6B6E76),
          fontFamily: 'Ruwudu',
          fontSize: 28,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

void main() {
  testGoldens(
      'feedback 262 - lore editor with open keyboard (Night Cartographer, iPad Pro 11)',
      (tester) async {
    final config = RpgConfigurationModel.getBaseConfiguration()
        .copyWith(defaultSkinId: CharacterSheetSkinIds.nightCartographer);
    final notes = MockNoteDocumentService(
      apiConnectorService: MockApiConnectorService(),
      getDocumentsForCampagneOverride:
          HRResponse.fromResult([_ownNotesDocument()]),
    );

    await _pumpPlayerPage(
      tester,
      surface: _ipadPro11Landscape,
      skinId: CharacterSheetSkinIds.nightCartographer,
      config: config,
      character:
          _characterFor(config, CharacterSheetSkinIds.nightCartographer),
      startScreen: 8,
      mockOverrides: {INoteDocumentService: () => notes},
    );

    await tester.tap(_editButtonOfFirstLoreBlock());
    await _settle(tester);
    await tester.tap(find.byType(TextField).first);
    expect(tester.getSize(find.byType(Navbar)).height, greaterThan(60));
    tester.view.viewInsets =
        const FakeViewPadding(bottom: _ipadPro11KeyboardHeight);
    await _settle(tester);

    // The top bar collapses to the status bar strip to free up writing space.
    expect(tester.getSize(find.byType(Navbar)).height, 24);

    // The editor must still be open and visible above the keyboard.
    final editor = find.byType(TextField);
    expect(editor, findsOneWidget);
    expect(
      tester.getRect(editor).top,
      lessThan(_ipadPro11Landscape.height - _ipadPro11KeyboardHeight - 40),
    );

    await screenMatchesGolden(
        tester, 'testflight_262/lore_editor_with_keyboard_night_cartographer');
  });

  testGoldens(
      'feedback 262 - unsaved lore edit when the DM shares a new section (classic dark)',
      (tester) async {
    final config = RpgConfigurationModel.getBaseConfiguration()
        .copyWith(defaultSkinId: CharacterSheetSkinIds.classicDark);
    final notes = MockNoteDocumentService(
      apiConnectorService: MockApiConnectorService(),
      getDocumentsForCampagneOverride:
          HRResponse.fromResult([_ownNotesDocument()]),
    );
    final events = _ControllableEvents();

    await _pumpPlayerPage(
      tester,
      surface: _ipadPro13Landscape,
      skinId: CharacterSheetSkinIds.classicDark,
      config: config,
      character: _characterFor(config, CharacterSheetSkinIds.classicDark),
      startScreen: 8,
      mockOverrides: {
        INoteDocumentService: () => notes,
        EventsClient: () => events.client,
      },
    );

    await tester.tap(_editButtonOfFirstLoreBlock());
    await _settle(tester);
    await tester.enterText(
      find.byType(TextField).first,
      '## Preparations\n\nIch glaube ich will Counterspell lernen!\n\n'
      '## Notes\n\nStart-Ort: Wolkenmeer\n\n'
      'Der Hafenmeister wirkte nervös, als wir nach der Rabenkrone gefragt haben. '
      'Wir sollten heute Nacht noch einmal zum Pier zurück und ...',
    );
    await _settle(tester);

    // DM shares a new section with this player while they are typing.
    notes.getDocumentsForCampagneOverride = HRResponse.fromResult(
        [_ownNotesDocument(), _dmSharedDocument()]);
    events.push('noteAccessChanged', {
      'campagneId': _campagneId,
      'documentId': _dmSharedDocument().id!.$value,
      'blockId': _dmSharedDocument().textBlocks.first.id!.$value,
      'changeKind': 'granted',
    });
    await _settle(tester);

    // Still in edit mode on the same document, with the typed text intact,
    // and the newly shared document shows up in the sidebar.
    expect(find.textContaining('Hafenmeister wirkte nervös'), findsOneWidget);
    expect(find.text('Brief des Hafenmeisters'), findsOneWidget);

    await screenMatchesGolden(
        tester, 'testflight_262/lore_edit_after_dm_shares_section_classic_dark');
  });

  testGoldens(
      'feedback 262 - player receives items granted by the DM (classic dark)',
      (tester) async {
    final config = RpgConfigurationModel.getBaseConfiguration()
        .copyWith(defaultSkinId: CharacterSheetSkinIds.classicDark);

    await _pumpPlayerPage(
      tester,
      surface: _ipadPro13Landscape,
      skinId: CharacterSheetSkinIds.classicDark,
      config: config,
      character: _characterFor(config, CharacterSheetSkinIds.classicDark),
      startScreen: 6,
    );

    final container = ProviderScope.containerOf(
        tester.element(find.byType(PlayerPageScreen)));
    final inventoryBefore =
        container.read(rpgCharacterConfigurationProvider).requireValue.inventory;

    // What the itemsGranted SSE notify hands to the player: the grant is
    // addressed to the character's server id.
    DependencyProvider.getIt!.get<IServerMethodsService>().grantPlayerItems(
          jsonEncode([
            GrantedItemsForPlayer(
              characterName: 'Thamior',
              playerId: _playerCharacterDbId,
              grantedItems: [
                RpgCharacterOwnedItemPair(
                    itemUuid: config.allItems[0].uuid, amount: 2),
                RpgCharacterOwnedItemPair(
                    itemUuid: config.allItems[2].uuid, amount: 5),
              ],
            ),
          ]),
        );
    await _settle(tester);

    expect(find.textContaining('neue Items erhalten'), findsWidgets);
    // The server already merged the grant into the character config (it
    // arrives via ConfigSync), so the client must not add the items again.
    expect(
      jsonEncode(container
          .read(rpgCharacterConfigurationProvider)
          .requireValue
          .inventory),
      jsonEncode(inventoryBefore),
    );

    await screenMatchesGolden(
        tester, 'testflight_262/player_receives_granted_items_classic_dark');
  });

  testGoldens(
      'feedback 262 - companion selector icons (Night Cartographer, iPad Pro 13)',
      (tester) async {
    final config =
        _configWithCompanionStats(CharacterSheetSkinIds.nightCartographer);

    await _pumpPlayerPage(
      tester,
      surface: _ipadPro13Landscape,
      skinId: CharacterSheetSkinIds.nightCartographer,
      config: config,
      character: _characterFor(
        config,
        CharacterSheetSkinIds.nightCartographer,
        withCompanions: true,
      ),
      startScreen: 0,
    );

    await tester.scrollUntilVisible(find.text('Rabenkrone'), 200,
        scrollable: find.byType(Scrollable).first);
    await _settle(tester);

    await screenMatchesGolden(
        tester, 'testflight_262/companion_icons_night_cartographer');
  });

  testGoldens('feedback 262 - DM configures a companion selector stat',
      (tester) async {
    final config =
        _configWithCompanionStats(CharacterSheetSkinIds.nightCartographer);
    final vehicleStat = config.characterStatTabsDefinition!.first.statsInTab
        .singleWhere((s) => s.statUuid == _vehicleStatUuid);

    tester.view.physicalSize = _ipadPro13Landscape;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await customLoadAppFonts();
    CharacterStatDefinition? savedStat;

    await tester.pumpWidget(
      ProviderScope(
        child: DependencyProvider.getMockedDependecyProvider(
          child: CustomThemeProvider(
            overrideBrightness: Brightness.dark,
            overrideSkinId: CharacterSheetSkinIds.nightCartographer,
            child: ThemeConfigurationForApp(
              child: MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [
                  ...AppLocalizations.localizationsDelegates,
                  S.delegate,
                ],
                locale: const Locale('de'),
                supportedLocales: AppLocalizations.supportedLocales,
                theme: ThemeData.dark(useMaterial3: true),
                home: Scaffold(
                  body: Builder(builder: (context) {
                    return ElevatedButton(
                      onPressed: () async {
                        savedStat = await showGetDmConfigurationModal(
                          context: context,
                          predefinedConfiguration: vehicleStat,
                          overrideNavigatorKey: navigatorKey,
                        );
                      },
                      child: const Text('open'),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await _settle(tester);

    await screenMatchesGolden(
        tester, 'testflight_262/dm_config_companion_selector_night_cartographer');

    await tester.tap(find.text('Speichern').last);
    await _settle(tester);
    expect(jsonDecode(savedStat!.jsonSerializedAdditionalData!),
        {'iconName': 'sailboat'});
  });
}
