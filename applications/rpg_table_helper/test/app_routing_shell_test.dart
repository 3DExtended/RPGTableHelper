import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/connection_status_banner.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

import 'custom_font_loader.dart';

void main() {
  testWidgets(
    'a skin change keeps the services, so the live stream is not duplicated',
    (tester) async {
      // The login screen's fixed-width buttons overflow with the test font.
      await customLoadAppFonts();
      tester.view.physicalSize = const Size(2048, 2732);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: AppRoutingShell(
            widget: MyApp(initialRoute: LoginScreen.route),
            useMockedServices: true,
          ),
        ),
      );
      await tester.pump();

      final eventsClient = DependencyProvider.getIt!.get<EventsClient>();
      final themeProvider = CustomThemeProvider.of(
        tester.element(find.byType(MaterialApp)),
      );

      // Entering a campaign with another default skin does this.
      themeProvider.setActiveSkinId(CharacterSheetSkinIds.classicLight);
      await tester.pump();

      expect(
        DependencyProvider.getIt!.get<EventsClient>(),
        same(eventsClient),
        reason: 'a second EventsClient would open a second /events stream',
      );
      expect(
        tester
            .widget<ConnectionStatusBanner>(find.byType(ConnectionStatusBanner))
            .status,
        same(eventsClient.status),
        reason: 'the banner must watch the client that is connected',
      );
    },
  );
}
