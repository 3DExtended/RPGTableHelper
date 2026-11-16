import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
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
import 'package:quest_keeper/screens/pageviews/lore_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/note_documents_service.dart';
import 'package:quest_keeper/services/systemclock_service.dart';

import '../../custom_font_loader.dart';

/// The player's notes on a phone (UX test 2026-11-16: B1, B7, B10, B11,
/// SP-7, SP-8): writing, the own group for new documents, the document list
/// as an overlay and the header on a narrow screen.

const _campagneId = '51f263bc-37cf-44d4-90f3-87d656ae29df';

/// "You" in the mocked campaign members.
const _myUserId = '5def694e-8829-4fdd-afc5-342dc28c5ae2';

/// The DM in the mocked campaign members.
const _dmUserId = 'd7c27d97-d973-465d-a2e5-9f605fd1f0c9';

/// A fellow player in the mocked campaign members.
const _kardanUserId = 'f59df7f4-7189-4435-9759-081c11bd887b';

const _iPhone17Pro = Size(402, 874);

/// Index of the notes page for the base configuration (5 stat tabs, money,
/// inventory, crafting, notes).
const _lorePageIndex = 8;

final _loadedAt = DateTime(2026, 11, 16, 14, 7);
final _savedAt = DateTime(2026, 11, 16, 14, 17);

NoteDocumentDto _document({
  required String id,
  required String title,
  required String group,
  required String creator,
  List<TextBlock> textBlocks = const [],
}) {
  return NoteDocumentDto(
    id: NoteDocumentIdentifier(value: id),
    title: title,
    groupName: group,
    createdForCampagneId: CampagneIdentifier(value: _campagneId),
    creatingUserId: UserIdentifier(value: creator),
    creationDate: _loadedAt,
    lastModifiedAt: _loadedAt,
    isDeleted: false,
    textBlocks: [...textBlocks],
    imageBlocks: [],
  );
}

TextBlock _textBlock(String id, String documentId, String text) => TextBlock(
  id: NoteBlockModelBaseIdentifier(value: id),
  noteDocumentId: NoteDocumentIdentifier(value: documentId),
  creatingUserId: UserIdentifier(value: _myUserId),
  creationDate: _loadedAt,
  lastModifiedAt: _loadedAt,
  isDeleted: false,
  permittedUsers: [],
  markdownText: text,
  sortIndex: 0,
);

final _dmDocument = _document(
  id: 'doc-dm',
  title: 'Händler Garvin',
  group: 'NSCs',
  creator: _dmUserId,
);

/// Keeps documents like the server: what is written can be read again.
class _InMemoryNotes extends MockNoteDocumentService {
  _InMemoryNotes(List<NoteDocumentDto> documents)
    : documents = [...documents],
      super(apiConnectorService: MockApiConnectorService());

  final List<NoteDocumentDto> documents;
  final List<NoteDocumentDto> createdDocuments = [];
  int _nextId = 1;

  NoteDocumentDto _copy(NoteDocumentDto d) => d.copyWith(
    textBlocks: [...d.textBlocks],
    imageBlocks: [...d.imageBlocks],
  );

  int _indexOf(String? id) => documents.indexWhere((d) => d.id?.value == id);

  @override
  Future<HRResponse<List<NoteDocumentDto>>> getDocumentsForCampagne({
    required CampagneIdentifier campagneId,
  }) async {
    return HRResponse.fromResult(documents.map(_copy).toList());
  }

  @override
  Future<HRResponse<NoteDocumentDto>> getDocument({
    required NoteDocumentIdentifier notedocumentid,
  }) async {
    return HRResponse.fromResult(
      _copy(documents[_indexOf(notedocumentid.value)]),
    );
  }

  @override
  Future<HRResponse<NoteDocumentIdentifier>> createNewDocumentForCampagne({
    required NoteDocumentDto dto,
  }) async {
    createdDocuments.add(dto);
    final id = NoteDocumentIdentifier(value: 'doc-new-${_nextId++}');
    documents.add(_copy(dto.copyWith(id: id)));
    return HRResponse.fromResult(id);
  }

  @override
  Future<HRResponse<bool>> updateDocumentForCampagne({
    required NoteDocumentDto dto,
  }) async {
    final index = _indexOf(dto.id?.value);
    documents[index] = documents[index].copyWith(
      title: dto.title,
      groupName: dto.groupName,
    );
    return HRResponse.fromResult(true);
  }

  @override
  Future<HRResponse<TextBlock>> createNewTextBlockForDocument({
    required TextBlock textBlockToCreate,
    required NoteDocumentIdentifier notedocumentid,
    NoteBlockModelBaseIdentifier? insertBeforeBlockId,
  }) async {
    final index = _indexOf(notedocumentid.value);
    final block = textBlockToCreate.copyWith(
      id: NoteBlockModelBaseIdentifier(value: 'block-${_nextId++}'),
      sortIndex: documents[index].textBlocks.length,
    );
    documents[index].textBlocks.add(block);
    return HRResponse.fromResult(block);
  }

  @override
  Future<HRResponse<bool>> updateTextBlock({
    required TextBlock textBlockToUpdate,
  }) async {
    for (final document in documents) {
      final index = document.textBlocks.indexWhere(
        (b) => b.id?.value == textBlockToUpdate.id?.value,
      );
      if (index >= 0) {
        document.textBlocks[index] = textBlockToUpdate;
        return HRResponse.fromResult(true);
      }
    }
    return HRResponse.error('unknown block', 'test');
  }
}

Future<void> _pumpPlayerNotes(
  WidgetTester tester,
  _InMemoryNotes notes, {
  DateTime? now,
  String skinId = CharacterSheetSkinIds.classicDark,
}) async {
  tester.view.physicalSize = _iPhone17Pro;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
  addTearDown(tester.view.reset);

  // Real fonts: the test font is much wider and would overflow buttons that
  // fit on a real phone.
  await customLoadAppFonts();

  final config = RpgConfigurationModel.getBaseConfiguration().copyWith(
    defaultSkinId: skinId,
  );
  final character = RpgCharacterConfiguration.getBaseConfiguration(
    config,
    variant: 0,
  ).copyWith(skinId: skinId);

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
        mockOverrides: {
          INoteDocumentService: () => notes,
          ISystemClockService: () =>
              MockSystemClockService(nowOverride: now ?? _savedAt),
        },
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
              home: PlayerPageScreen(
                startScreenOverride: _lorePageIndex,
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
  await tester.pumpAndSettle();
}

Finder get _scrim => find.byKey(const ValueKey('loreDocumentListScrim'));

Finder _inLore(Finder finder) =>
    find.descendant(of: find.byType(LoreScreen), matching: finder);

/// The pencil next to the document title.
Finder get _titlePencil => _inLore(
  find.byWidgetPredicate(
    (w) =>
        w is CustomFaIcon &&
        w.icon == FontAwesomeIcons.penToSquare &&
        w.noPadding == true,
  ),
);

String _hhmmDate(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)} '
      '${two(t.day)}.${two(t.month)}.${t.year}';
}

Future<void> _closeDocumentList(WidgetTester tester) async {
  // The scrim covers the page right of the list (decorated skins clip the
  // outermost pixels to their frame).
  final scrim = tester.getRect(_scrim);
  await tester.tapAt(Offset(scrim.right - 30, scrim.center.dy));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'phone: a player creates a document, titles it, writes a paragraph '
    'and finds it again after reloading',
    (tester) async {
      final notes = _InMemoryNotes([_dmDocument]);
      await _pumpPlayerNotes(tester, notes);

      // The DM's shared document is selected, the list is open.
      expect(_scrim, findsOneWidget);

      await tester.tap(_inLore(find.text('Neu')));
      await tester.pumpAndSettle();

      // B10: not into the group of the DM's document, but into the own one.
      expect(notes.createdDocuments.single.groupName, 'Meine Notizen');
      // The list closes and shows the new document, which can be edited (B1).
      expect(_scrim, findsNothing);
      expect(_titlePencil, findsOneWidget);

      await tester.tap(_titlePencil);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(CustomTextField).first,
          matching: find.byType(EditableText),
        ),
        'Reisetagebuch',
      );
      await tester.tap(find.text('Speichern').hitTestable().first);
      await tester.pumpAndSettle();
      expect(_inLore(find.text('Reisetagebuch')), findsWidgets);

      await tester.tap(_inLore(find.text('Absatz')));
      await tester.pumpAndSettle();
      expect(find.byType(LoreBlockRenderingEditable), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(LoreBlockRenderingEditable),
          matching: find.byWidgetPredicate(
            (w) => w is CustomFaIcon && w.icon == FontAwesomeIcons.penToSquare,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(LoreBlockRenderingEditable),
          matching: find.byType(EditableText),
        ),
        'Der Wirt lügt.',
      );
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(LoreBlockRenderingEditable),
          matching: find.text('Speichern'),
        ),
      );
      await tester.pumpAndSettle();

      final saved = notes.documents
          .firstWhere((d) => d.title == 'Reisetagebuch')
          .textBlocks
          .single;
      expect(saved.markdownText, 'Der Wirt lügt.');

      // Reload: a fresh screen gets the documents from the "server" again.
      await tester.pumpWidget(const SizedBox());
      await _pumpPlayerNotes(tester, notes);

      // "Meine Notizen" sorts before "NSCs", so its document is shown first.
      expect(_inLore(find.text('Meine Notizen')), findsOneWidget);
      await _closeDocumentList(tester);
      expect(_inLore(find.text('Reisetagebuch')), findsOneWidget);
      expect(find.text('Der Wirt lügt.', findRichText: true), findsOneWidget);
    },
  );

  testWidgets(
    'phone: the DM\'s document stays read-only, the own one is editable',
    (tester) async {
      final notes = _InMemoryNotes([
        _dmDocument,
        _document(
          id: 'doc-mine',
          title: 'Reisetagebuch',
          group: 'Meine Notizen',
          creator: _myUserId,
          textBlocks: [_textBlock('b1', 'doc-mine', 'Tag 1')],
        ),
      ]);
      await _pumpPlayerNotes(tester, notes);

      // "Meine Notizen" sorts first, so the own document is selected.
      expect(_titlePencil, findsOneWidget);
      expect(_inLore(find.text('Absatz')), findsOneWidget);

      await tester.tap(_inLore(find.text('Händler Garvin')));
      await tester.pumpAndSettle();

      expect(_titlePencil, findsNothing);
      expect(_inLore(find.text('Absatz')), findsNothing);
    },
  );

  for (final skinId in [
    CharacterSheetSkinIds.classicDark,
    CharacterSheetSkinIds.arcaneLedger,
    CharacterSheetSkinIds.nightCartographer,
  ]) {
    testWidgets(
      '$skinId phone: the open document list lies over the content and '
      'closes on selection; the diamonds of the closed list switch documents',
      (tester) async {
        final notes = _InMemoryNotes([
          _dmDocument,
          _document(
            id: 'doc-mine',
            title: 'Reisetagebuch',
            group: 'Meine Notizen',
            creator: _myUserId,
          ),
        ]);
        await _pumpPlayerNotes(tester, notes, skinId: skinId);

        // B7 / SP-8: the content keeps nearly the full width, even with the
        // list open, and does not overflow (an overflow fails the test).
        expect(_scrim, findsOneWidget);
        if (skinId == CharacterSheetSkinIds.classicDark) {
          final header = tester.getSize(
            find.byKey(const ValueKey('loreDocumentAuthorAndTime')),
          );
          expect(header.width, greaterThan(250));
        }

        await tester.tap(_inLore(find.text('Händler Garvin')));
        await tester.pumpAndSettle();
        expect(_scrim, findsNothing);
        expect(_titlePencil, findsNothing); // the DM's document is shown

        // closed list: tap the diamond of the own document
        await tester.tap(
          find.byKey(const ValueKey('ColoredRotatedSquaredoc-mine')),
        );
        await tester.pumpAndSettle();
        expect(_titlePencil, findsOneWidget);
        expect(_scrim, findsNothing);

        // open again and tap beside the list: it closes without a change
        await tester.tap(
          _inLore(
            find.byWidgetPredicate(
              (w) =>
                  w is CustomFaIcon && w.icon == FontAwesomeIcons.chevronRight,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(_scrim, findsOneWidget);
        await _closeDocumentList(tester);
        expect(_scrim, findsNothing);
        expect(_titlePencil, findsOneWidget);
      },
    );
  }

  testWidgets('the header shows the time of the own last change (B11)', (
    tester,
  ) async {
    final notes = _InMemoryNotes([
      _document(
        id: 'doc-mine',
        title: 'Reisetagebuch',
        group: 'Meine Notizen',
        creator: _myUserId,
        textBlocks: [_textBlock('b1', 'doc-mine', 'Tag 1')],
      ),
    ]);
    await _pumpPlayerNotes(tester, notes, now: _savedAt);
    await _closeDocumentList(tester);

    expect(find.text(_hhmmDate(_loadedAt)), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(LoreBlockRenderingEditable),
        matching: find.byWidgetPredicate(
          (w) => w is CustomFaIcon && w.icon == FontAwesomeIcons.penToSquare,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(LoreBlockRenderingEditable),
        matching: find.byType(EditableText),
      ),
      'Tag 1 und 2',
    );
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(LoreBlockRenderingEditable),
        matching: find.text('Speichern'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_hhmmDate(_loadedAt)), findsNothing);
    expect(find.text(_hhmmDate(_savedAt)), findsOneWidget);
    expect(
      notes.documents.single.textBlocks.single.markdownText,
      'Tag 1 und 2',
    );
  });

  testWidgets('phone: the share list of a paragraph goes below it', (
    tester,
  ) async {
    final notes = _InMemoryNotes([
      _document(
        id: 'doc-mine',
        title: 'Reisetagebuch',
        group: 'Meine Notizen',
        creator: _myUserId,
        textBlocks: [_textBlock('b1', 'doc-mine', 'Tag 1')],
      ),
    ]);
    await _pumpPlayerNotes(tester, notes);
    await _closeDocumentList(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(LoreBlockRenderingEditable),
        matching: find.byWidgetPredicate(
          (w) => w is CustomFaIcon && w.icon == FontAwesomeIcons.users,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final below = find.byKey(const ValueKey('noteBlockPermittedUsersBelow'));
    expect(below, findsOneWidget);
    // the other players of the mocked campaign, each with room for the name
    expect(
      find.descendant(of: below, matching: find.text('Kardan')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(find.descendant(of: below, matching: find.text('Kardan')))
          .width,
      greaterThan(40),
    );

    // sharing the paragraph with Kardan still works on the phone
    await tester.tap(find.descendant(of: below, matching: find.text('Kardan')));
    await tester.pumpAndSettle();
    expect(
      notes.documents.single.textBlocks.single.permittedUsers!.map(
        (u) => u.value,
      ),
      contains(_kardanUserId),
    );
  });
}
