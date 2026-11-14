import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/notes/lore_block_rendering_editable.dart';
import 'package:quest_keeper/components/notes/note_block_menu.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

final _textBlock = TextBlock(
  id: NoteBlockModelBaseIdentifier(value: "b1"),
  markdownText: "Der Wirt erzählt",
  permittedUsers: [],
);

final _imageBlock = ImageBlock(
  id: NoteBlockModelBaseIdentifier(value: "b2"),
  markdownText: "Karte",
  permittedUsers: [],
  imageMetaDataId: ImageMetaDataIdentifier(value: "m1"),
  publicImageUrl: "assets/images/charactercard_placeholder.png",
);

class _Calls {
  final List<String> log = [];
}

void main() {
  Future<void> pumpBlock(
    WidgetTester tester, {
    required dynamic block,
    required _Calls calls,
    bool canMoveUp = true,
    bool canMoveDown = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: CustomThemeProvider(
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale("de"),
              supportedLocales: AppLocalizations.supportedLocales,
              home: CustomThemeProvider(
                child: DependencyProvider.getMockedDependecyProvider(
                  child: Scaffold(
                    body: LoreBlockRenderingEditable(
                      block: block,
                      usersInCampagne: const [],
                      updatePermittedUsersOnBlock: (_, _) {},
                      isUserAllowedToEdit: true,
                      isShowingPermittedUsers: false,
                      toggleIsVisibleForBarCollapsed: () {},
                      updateTextContent: (text) async {
                        calls.log.add("save:$text");
                        return true;
                      },
                      deleteBlock: () async => true,
                      attachImage: block is TextBlock
                          ? (source) async {
                              calls.log.add("attach:${source.name}");
                              return true;
                            }
                          : null,
                      replaceImage: block is ImageBlock
                          ? (source) async {
                              calls.log.add("replace:${source.name}");
                              return true;
                            }
                          : null,
                      removeImage: block is ImageBlock
                          ? () async {
                              calls.log.add("remove");
                              return true;
                            }
                          : null,
                      moveUp: canMoveUp
                          ? () async => calls.log.add("up")
                          : null,
                      moveDown: canMoveDown
                          ? () async => calls.log.add("down")
                          : null,
                    ),
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

  Future<void> openEditMode(WidgetTester tester) async {
    await tester.tap(find.byWidgetPredicate(
      (w) => w is CustomFaIcon && w.icon == FontAwesomeIcons.penToSquare,
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('arrows only show in edit mode and move the block',
      (tester) async {
    final calls = _Calls();
    await pumpBlock(tester, block: _textBlock, calls: calls);

    expect(find.byKey(const ValueKey('moveNoteBlockUp')), findsNothing);
    await openEditMode(tester);

    await tester.tap(find.byKey(const ValueKey('moveNoteBlockUp')));
    await tester.tap(find.byKey(const ValueKey('moveNoteBlockDown')));
    await tester.pumpAndSettle();

    expect(calls.log, ["up", "down"]);
  });

  testWidgets('the first block cannot move up', (tester) async {
    final calls = _Calls();
    await pumpBlock(tester, block: _textBlock, calls: calls, canMoveUp: false);
    await openEditMode(tester);

    await tester.tap(find.byKey(const ValueKey('moveNoteBlockUp')));
    await tester.pumpAndSettle();

    expect(calls.log, isEmpty);
  });

  testWidgets(
      'a text block offers "Bild hinzufügen", saving unsaved text before the image is added',
      (tester) async {
    final calls = _Calls();
    await pumpBlock(tester, block: _textBlock, calls: calls);
    await openEditMode(tester);

    expect(find.byKey(const ValueKey('replaceNoteBlockImage')), findsNothing);
    expect(find.byKey(const ValueKey('removeNoteBlockImage')), findsNothing);

    await tester.enterText(find.byType(CustomTextField), "neuer Text");
    await tester.tap(find.text("Bild hinzufügen"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Bild generieren"));
    await tester.pumpAndSettle();

    expect(calls.log, ["save:neuer Text", "attach:${NoteImageSource.generate.name}"]);
  });

  testWidgets('an image block offers replacing and removing its image',
      (tester) async {
    final calls = _Calls();
    await pumpBlock(tester, block: _imageBlock, calls: calls);
    await openEditMode(tester);

    expect(find.byKey(const ValueKey('attachImageToNoteBlock')), findsNothing);

    await tester.tap(find.text("Bild ersetzen"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Bild hochladen"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Bild entfernen"));
    await tester.pumpAndSettle();

    expect(calls.log, ["replace:${NoteImageSource.upload.name}", "remove"]);
  });
}
