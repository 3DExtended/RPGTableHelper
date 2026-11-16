import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';

import '../fakes/modal_test_host.dart';

HRResponse<String> _serverError() => HRResponse.error<String>(
  'Could not load campagnes.',
  'a1b2c3d4-0000-4000-8000-000000000042',
  errorFromServer: 'NullReferenceException in CampagneQueryHandler',
  statusCode: 500,
);

void main() {
  Future<void> openWith(
    WidgetTester tester,
    HRResponseBase response, {
    List<int>? allowedStatusCodes,
  }) async {
    await pumpModalHost(
      tester,
      open: (context) => response.possiblyHandleError(
        context,
        allowedStatusCodes: allowedStatusCodes,
      ),
    );
    await tester.tap(find.byKey(openModalButtonKey));
    await tester.pumpAndSettle();
  }

  testWidgets('shows a German message with the details folded away', (
    tester,
  ) async {
    await openWith(tester, _serverError());

    expect(find.byType(GenericErrorDialog), findsOneWidget);
    expect(find.text('Das hat nicht geklappt'), findsOneWidget);
    expect(
      find.text(
        'Auf dem Server ist ein Fehler aufgetreten. Versuche es später noch einmal.',
      ),
      findsOneWidget,
    );
    expect(find.text('Technische Details'), findsOneWidget);
    // the technical text is not on screen until the details are opened
    expect(
      find.textContaining('NullReferenceException', findRichText: true),
      findsNothing,
    );
  });

  testWidgets('the details expand and show code, status and server text', (
    tester,
  ) async {
    await openWith(tester, _serverError());

    await tester.tap(find.text('Technische Details'));
    await tester.pumpAndSettle();

    final details = find.byType(SelectableText);
    expect(details, findsOneWidget);
    final text = tester.widget<SelectableText>(details).textSpan!.toPlainText();
    expect(
      text,
      contains(
        'Server-Antwort: NullReferenceException in CampagneQueryHandler',
      ),
    );
    expect(text, contains('Fehlercode: a1b2c3d4-0000-4000-8000-000000000042'));
    expect(text, contains('HTTP-Status: 500'));
    expect(text, contains('Beschreibung: Could not load campagnes.'));
  });

  testWidgets('OK closes the dialog', (tester) async {
    await openWith(tester, _serverError());

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(GenericErrorDialog), findsNothing);
  });

  testWidgets('no status code means no connection', (tester) async {
    await openWith(
      tester,
      HRResponse.error<String>('Timeout', 'code-without-status'),
    );

    expect(
      find.text(
        'Die Verbindung zum Server hat nicht geklappt. Prüfe deine Internetverbindung und versuche es noch einmal.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('allowed status codes still show nothing', (tester) async {
    await openWith(
      tester,
      HRResponse.error<String>('Not found', 'x', statusCode: 404),
      allowedStatusCodes: [404],
    );

    expect(find.byType(GenericErrorDialog), findsNothing);
  });

  test('messages by status', () async {
    final german = await S.load(const Locale('de'));
    String messageFor(int? status) => genericErrorMessageFor(
      HRResponse.error<String>('x', 'y', statusCode: status),
      german,
    );

    expect(messageFor(401), contains('Berechtigung'));
    expect(messageFor(403), contains('Berechtigung'));
    expect(messageFor(404), contains('gibt es nicht'));
    expect(messageFor(409), contains('an anderer Stelle geändert'));
    expect(messageFor(400), contains('Eingabe'));
    expect(messageFor(503), contains('Server'));
  });
}
