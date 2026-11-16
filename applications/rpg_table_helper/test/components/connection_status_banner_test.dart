import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/connection_status_banner.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

void main() {
  Future<void> pumpBanner(
    WidgetTester tester,
    ValueNotifier<EventsConnectionStatus> status,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('de'),
        home: Stack(
          children: [
            const Placeholder(),
            ConnectionStatusBanner(status: status),
          ],
        ),
      ),
    );
  }

  testWidgets('shows the hint only while the server is unreachable', (
    tester,
  ) async {
    final status = ValueNotifier(EventsConnectionStatus.connected);
    await pumpBanner(tester, status);
    final hint = find.text('Keine Verbindung – verbinde neu\u00a0…');

    expect(hint, findsNothing);

    status.value = EventsConnectionStatus.reconnecting;
    await tester.pump();
    expect(hint, findsNothing, reason: 'short drops stay quiet');

    status.value = EventsConnectionStatus.unreachable;
    await tester.pump();
    expect(hint, findsOneWidget);

    status.value = EventsConnectionStatus.connected;
    await tester.pump();
    expect(hint, findsNothing);
  });

  testWidgets('does not block taps on the screen below', (tester) async {
    var taps = 0;
    final status = ValueNotifier(EventsConnectionStatus.unreachable);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('de'),
        home: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
              ),
            ),
            ConnectionStatusBanner(status: status),
          ],
        ),
      ),
    );

    await tester.tap(
      find.text('Keine Verbindung – verbinde neu\u00a0…'),
      warnIfMissed: false,
    );
    expect(taps, 1);
  });
}
