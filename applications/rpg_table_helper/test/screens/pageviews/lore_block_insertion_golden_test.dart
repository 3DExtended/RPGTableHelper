import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/notes/lore_block_rendering_editable.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
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

import '../../custom_font_loader.dart';

/// The owner's lore page with several blocks: a "+" above every block to
/// insert one right there, and arrows in edit mode to move a block.

const _campagneId = '51f263bc-37cf-44d4-90f3-87d656ae29df';
const _myUserId = '5def694e-8829-4fdd-afc5-342dc28c5ae2';
const _documentId = '01999f0e-0000-7000-8000-00000000d0c1';
const _arrival = '01999f0e-0000-7000-8000-00000000b001';
const _map = '01999f0e-0000-7000-8000-00000000b002';
const _innkeeper = '01999f0e-0000-7000-8000-00000000b003';

const _ipadPro13Landscape = Size(1366, 1024);

TextBlock _text(String id, String text, int sortIndex) => TextBlock(
  creatingUserId: UserIdentifier(value: _myUserId),
  creationDate: DateTime(2026, 11, 14, 20),
  id: NoteBlockModelBaseIdentifier(value: id),
  isDeleted: false,
  lastModifiedAt: DateTime(2026, 11, 14, 20),
  permittedUsers: [],
  markdownText: text,
  sortIndex: sortIndex,
);

NoteDocumentDto _document({
  required List<String> order,
  DateTime? lastModifiedAt,
}) {
  final blocks = {
    _arrival: _text(
      _arrival,
      '## Ankunft\n\nDie Gruppe erreicht Grauhafen im Morgennebel.',
      0,
    ),
    _innkeeper: _text(
      _innkeeper,
      'Der Wirt erzählt von dem Schiff ohne Flagge.',
      0,
    ),
  };
  final image = ImageBlock(
    creatingUserId: UserIdentifier(value: _myUserId),
    creationDate: DateTime(2026, 11, 14, 20),
    id: NoteBlockModelBaseIdentifier(value: _map),
    isDeleted: false,
    lastModifiedAt: DateTime(2026, 11, 14, 20),
    permittedUsers: [],
    imageMetaDataId: ImageMetaDataIdentifier(value: 'm1'),
    publicImageUrl: 'assets/images/charactercard_placeholder.png',
    markdownText: 'Karte des Hafens',
    sortIndex: order.indexOf(_map),
  );
  return NoteDocumentDto(
    groupName: 'Session Notes',
    createdForCampagneId: CampagneIdentifier(value: _campagneId),
    title: 'Grauhafen',
    creatingUserId: UserIdentifier(value: _myUserId),
    id: NoteDocumentIdentifier(value: _documentId),
    isDeleted: false,
    creationDate: DateTime(2026, 11, 14, 20),
    lastModifiedAt: lastModifiedAt ?? DateTime(2026, 11, 14, 20),
    imageBlocks: [image],
    textBlocks: [
      for (final id in [_arrival, _innkeeper])
        blocks[id]!.copyWith(sortIndex: order.indexOf(id)),
    ],
  );
}

/// Records moves and answers them like the server: the document in its new
/// order.
class _NotesWithMoves extends MockNoteDocumentService {
  _NotesWithMoves({DateTime? lastModifiedAt})
    : super(
        apiConnectorService: MockApiConnectorService(),
        getDocumentsForCampagneOverride: HRResponse.fromResult([
          _document(
            order: [_arrival, _map, _innkeeper],
            lastModifiedAt: lastModifiedAt,
          ),
        ]),
      );

  List<String> order = [_arrival, _map, _innkeeper];
  final List<(String, String?)> moves = [];

  @override
  Future<HRResponse<NoteDocumentDto>> moveNoteBlock({
    required NoteBlockModelBaseIdentifier blockId,
    NoteBlockModelBaseIdentifier? beforeBlockId,
  }) async {
    moves.add((blockId.value!, beforeBlockId?.value));
    order.remove(blockId.value);
    final at = beforeBlockId == null
        ? order.length
        : order.indexOf(beforeBlockId.value!);
    order.insert(at, blockId.value!);
    return HRResponse.fromResult(_document(order: order));
  }
}

Future<void> _pumpLorePage(WidgetTester tester, _NotesWithMoves notes) async {
  tester.view.physicalSize = _ipadPro13Landscape;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24);
  addTearDown(tester.view.reset);

  await customLoadAppFonts();

  final config = RpgConfigurationModel.getBaseConfiguration().copyWith(
    defaultSkinId: CharacterSheetSkinIds.classicDark,
  );
  final character =
      RpgCharacterConfiguration.getBaseConfiguration(
        config,
        variant: 0,
      ).copyWith(
        skinId: CharacterSheetSkinIds.classicDark,
        characterName: 'Thamior',
      );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        rpgConfigurationProvider.overrideWith(
          (ref) => RpgConfigurationNotifier(
            decks: AsyncValue.data(config),
            ref: ref,
            runningInTests: true,
          ),
        ),
        rpgCharacterConfigurationProvider.overrideWith(
          (ref) => RpgCharacterConfigurationNotifier(
            decks: AsyncValue.data(character),
            ref: ref,
            runningInTests: true,
          ),
        ),
        connectionDetailsProvider.overrideWith(
          (ref) => ConnectionDetailsNotifier(
            initState: AsyncValue.data(
              ConnectionDetails.defaultValue().copyWith(
                isConnected: true,
                isInSession: true,
                isDm: false,
                campagneId: _campagneId,
              ),
            ),
            ref: ref,
            runningInTests: true,
          ),
        ),
      ],
      child: DependencyProvider.getMockedDependecyProvider(
        mockOverrides: {INoteDocumentService: () => notes},
        child: CustomThemeProvider(
          overrideBrightness: Brightness.dark,
          overrideSkinId: CharacterSheetSkinIds.classicDark,
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
              home: PlayerPageScreen(
                startScreenOverride: 8,
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

Finder _editButtonOfBlock(int index) => find.descendant(
  of: find.byType(LoreBlockRenderingEditable).at(index),
  matching: find.byWidgetPredicate(
    (w) => w is CustomFaIcon && w.icon == FontAwesomeIcons.penToSquare,
  ),
);

List<String> _shownBlockIds(WidgetTester tester) => tester
    .widgetList<LoreBlockRenderingEditable>(
      find.byType(LoreBlockRenderingEditable),
    )
    .map((w) => (w.block.id as NoteBlockModelBaseIdentifier).value!)
    .toList();

void main() {
  testGoldens(
    'lore page: insert points above every block, arrows on the block in edit mode',
    (tester) async {
      final notes = _NotesWithMoves();
      await _pumpLorePage(tester, notes);

      for (final id in [_arrival, _map, _innkeeper]) {
        expect(
          find.byKey(ValueKey('insertNoteBlockBefore-$id')),
          findsOneWidget,
        );
      }

      await tester.tap(_editButtonOfBlock(1));
      await _settle(tester);

      expect(find.text('Bild ersetzen'), findsOneWidget);
      expect(find.text('Bild entfernen'), findsOneWidget);

      await screenMatchesGolden(tester, 'lore_block_insertion/owner_edit_mode');
    },
  );

  testGoldens('lore page: arrows move a block by one in both directions', (
    tester,
  ) async {
    final notes = _NotesWithMoves();
    await _pumpLorePage(tester, notes);
    expect(_shownBlockIds(tester), [_arrival, _map, _innkeeper]);

    // down: the map goes before the block after its next neighbour, i.e. last
    await tester.tap(_editButtonOfBlock(1));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('moveNoteBlockDown')));
    await _settle(tester);

    expect(notes.moves.last, (_map, null));
    expect(_shownBlockIds(tester), [_arrival, _innkeeper, _map]);

    // up twice: the map is first again, still in edit mode
    await tester.tap(find.byKey(const ValueKey('moveNoteBlockUp')));
    await _settle(tester);
    expect(notes.moves.last, (_map, _innkeeper));
    await tester.tap(find.byKey(const ValueKey('moveNoteBlockUp')));
    await _settle(tester);
    expect(notes.moves.last, (_map, _arrival));

    expect(_shownBlockIds(tester), [_map, _arrival, _innkeeper]);
  });

  testWidgets(
    'lore page: a UTC timestamp from the server shows in local time',
    (tester) async {
      // The server sends UTC (with offset), so Dart parses it as a UTC
      // DateTime. The header must show the reader's local time, like the
      // campaign list does.
      final fromServer = DateTime.utc(2026, 11, 14, 20, 25);
      final local = fromServer.toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      final expected =
          '${two(local.hour)}:${two(local.minute)} '
          '${two(local.day)}.${two(local.month)}.${local.year}';

      await _pumpLorePage(tester, _NotesWithMoves(lastModifiedAt: fromServer));

      expect(find.text(expected), findsOneWidget);
    },
  );
}
