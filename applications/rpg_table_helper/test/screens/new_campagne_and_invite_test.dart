import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quest_keeper/helpers/modals/ask_for_new_campagne_name.dart';
import 'package:quest_keeper/helpers/modals/show_invite_players_sheet.dart';

import '../fakes/modal_test_host.dart';

final _nameField = find.descendant(
  of: find.byKey(AskForNewCampagneNameModalContent.nameFieldKey),
  matching: find.byType(TextField),
);
final _create = find.byKey(AskForNewCampagneNameModalContent.submitButtonKey);

void main() {
  group('Neue Kampagne', () {
    NewCampagneChoice? result;
    var closed = false;

    Future<void> open(WidgetTester tester) async {
      result = null;
      closed = false;
      await pumpModalHost(
        tester,
        open: (context) async {
          result = await askForNewCampagneName(context);
          closed = true;
        },
      );
      await tester.tap(find.byKey(openModalButtonKey));
      await tester.pumpAndSettle();
    }

    testWidgets('has the German title and does not accept an empty name', (
      tester,
    ) async {
      await open(tester);

      expect(find.text('Neue Kampagne'), findsOneWidget);

      await tester.tap(_create);
      await tester.pumpAndSettle();
      expect(find.text('Bitte gib einen Namen ein'), findsOneWidget);
      expect(closed, isFalse);

      await tester.enterText(_nameField, '   ');
      await tester.tap(_create);
      await tester.pumpAndSettle();
      expect(find.text('Bitte gib einen Namen ein'), findsOneWidget);
      expect(closed, isFalse);
    });

    testWidgets('returns the trimmed name', (tester) async {
      await open(tester);

      await tester.enterText(_nameField, '  Die Klingen von Varn ');
      await tester.tap(_create);
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect((result as NamedNewCampagne).name, 'Die Klingen von Varn');
    });

    testWidgets('offers the demo campaign instead of a name', (tester) async {
      await open(tester);

      expect(find.text('Erst mal ausprobieren?'), findsOneWidget);
      final demo = find.byKey(AskForNewCampagneNameModalContent.demoButtonKey);
      await tester.ensureVisible(demo);
      await tester.pumpAndSettle();
      await tester.tap(demo);
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(result, isA<DemoCampagne>());
    });

    testWidgets('Abbrechen returns nothing', (tester) async {
      await open(tester);

      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(result, isNull);
    });
  });

  group('Spieler einladen', () {
    final shared = <({String text, String subject, Rect? origin})>[];

    Future<void> pumpSheet(WidgetTester tester) async {
      shared.clear();
      useTabletView(tester);
      await tester.pumpWidget(
        appTestShell(
          home: InvitePlayersSheetContent(
            joinCode: '699-457',
            campagneName: 'Die Klingen von Varn',
            onShare: ({required text, required subject, origin}) async =>
                shared.add((text: text, subject: subject, origin: origin)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the code, a QR code with the join link and the how-to', (
      tester,
    ) async {
      await pumpSheet(tester);

      expect(find.text('Spieler einladen'), findsOneWidget);
      expect(find.text('Die Klingen von Varn'), findsOneWidget);
      expect(
        tester
            .widget<SelectableText>(
              find.byKey(InvitePlayersSheetContent.codeTextKey),
            )
            .data,
        '699-457',
      );
      expect(
        find.text(
          'In QuestKeeper auf „Kampagne beitreten“ tippen und diesen Code eingeben.',
        ),
        findsOneWidget,
      );
      expect(find.byType(QrImageView), findsOneWidget);
      expect(
        find.byKey(const ValueKey('questkeeper://join?code=699-457')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Mit der Handykamera scannen: QuestKeeper öffnet direkt das '
          'Beitreten mit diesem Code.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('share sends the code, the how-to and an iPad anchor', (
      tester,
    ) async {
      await pumpSheet(tester);

      await tester.tap(find.byKey(InvitePlayersSheetContent.shareButtonKey));
      await tester.pumpAndSettle();

      expect(shared, hasLength(1));
      expect(shared.single.text, contains('699-457'));
      expect(shared.single.text, contains('Kampagne beitreten'));
      expect(shared.single.subject, 'Einladung zu „Die Klingen von Varn“');
      expect(shared.single.origin, isNotNull);
      expect(shared.single.origin!.isEmpty, isFalse);
    });

    testWidgets('copy puts the code on the clipboard and confirms it', (
      tester,
    ) async {
      String? clipboard;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pumpSheet(tester);

      await tester.tap(find.byKey(InvitePlayersSheetContent.copyButtonKey));
      await tester.pump();

      expect(clipboard, '699-457');
      expect(find.text('Kopiert'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Code kopieren'), findsOneWidget);
    });
  });
}
