import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/modals/ask_for_campagne_join_code.dart';
import 'package:quest_keeper/screens/select_game_mode_screen.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/join_link.dart';
import 'package:quest_keeper/services/join_requests/pending_join_request_store.dart';
import 'package:quest_keeper/services/onboarding_intent_store.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_join_rpg_entity_service.dart';
import '../fakes/modal_test_host.dart';

/// "Spieler einladen" puts a join link into the QR code; scanned with the
/// camera it opens the app's join dialog with the code filled in.
void main() {
  tearDown(() => pendingJoinLinkCode.value = null);

  group('the link', () {
    test('carries the code', () {
      expect(joinLinkFor('699-457'), 'questkeeper://join?code=699-457');
      expect(joinCodeFromLink(joinLinkFor('699-457')), '699-457');
    });

    test('is read leniently, anything else is no join link', () {
      expect(joinCodeFromLink('questkeeper://join?code=699457'), '699-457');
      expect(joinCodeFromLink('/join?code=699-457'), '699-457',
          reason: 'when a platform passes only path and query');
      expect(joinCodeFromLink('questkeeper://join?code=699-45'), isNull);
      expect(joinCodeFromLink('questkeeper://join'), isNull);
      expect(joinCodeFromLink('questkeeper://other?code=699-457'), isNull);
      expect(joinCodeFromLink('https://example.com/join?code=699-457'), isNull);
      expect(joinCodeFromLink('/'), isNull);
      expect(joinCodeFromLink(SelectGameModeScreen.route), isNull);
    });

    test('an Android cold start brings it as the initial route', () {
      final observer = listenForJoinLinks(
        initialRoute: 'questkeeper://join?code=699-457',
      );
      addTearDown(() => WidgetsBinding.instance.removeObserver(observer));
      expect(pendingJoinLinkCode.value, '699-457');
    });

    test('other routes are left to the navigator', () async {
      final observer = JoinLinkObserver();
      expect(
        await observer.didPushRouteInformation(
          RouteInformation(uri: Uri.parse('/something')),
        ),
        isFalse,
      );
      expect(pendingJoinLinkCode.value, isNull);
    });
  });

  group('the home screen', () {
    late FakeJoinRpgEntityService service;

    Future<void> pumpHome(WidgetTester tester) async {
      useTabletView(tester);
      await tester.pumpWidget(
        appTestShell(
          providerOverrides: [
            pendingJoinRequestStoreProvider.overrideWithValue(
              InMemoryPendingJoinRequestStore(),
            ),
          ],
          mockOverrides: {
            IRpgEntityService: () => service = FakeJoinRpgEntityService(
              apiConnectorService: DependencyProvider.getIt!
                  .get<IApiConnectorService>(),
              campagnes: [],
              characters: [],
            ),
          },
          home: const SelectGameModeScreen(),
        ),
      );
      await tester.pumpAndSettle();
    }

    String codeInDialog(WidgetTester tester) => tester
        .widget<TextField>(
          find.descendant(
            of: find.byKey(AskForCampagneJoinCodeModalContent.codeFieldKey),
            matching: find.byType(TextField),
          ),
        )
        .controller!
        .text;

    /// The join flow polls for the DM's answer; unmount so it ends.
    Future<void> unmount(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    }

    testWidgets('opens the join dialog with the code of the link that '
        'started the app, instead of the welcome choice', (tester) async {
      SharedPreferences.setMockInitialValues({
        onboardingIntentPrefsKey: OnboardingIntent.lead.name,
      });
      pendingJoinLinkCode.value = '699-457';

      await pumpHome(tester);

      expect(find.byType(AskForCampagneJoinCodeModalContent), findsOneWidget);
      expect(codeInDialog(tester), '699-457');
      expect(pendingJoinLinkCode.value, isNull);
      expect(await readOnboardingIntent(), isNull);

      // Only the name is left to type.
      await tester.enterText(
        find.descendant(
          of: find.byKey(AskForCampagneJoinCodeModalContent.nameFieldKey),
          matching: find.byType(TextField),
        ),
        'Mira',
      );
      await tester.tap(
        find.byKey(AskForCampagneJoinCodeModalContent.submitButtonKey),
      );
      await tester.pumpAndSettle();
      expect(service.createdCharacterNames, ['Mira']);
      expect(service.joinRequests.single.joinCode, '699-457');

      await unmount(tester);
    });

    testWidgets('takes a link while it is open, as the platform sends it', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      // As in main: before the app, so the navigator never sees the link.
      final observer = listenForJoinLinks(
        binding: tester.binding,
        initialRoute: '/',
      );
      addTearDown(() => tester.binding.removeObserver(observer));
      await pumpHome(tester);
      expect(find.byType(AskForCampagneJoinCodeModalContent), findsNothing);

      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        SystemChannels.navigation.name,
        SystemChannels.navigation.codec.encodeMethodCall(
          const MethodCall('pushRouteInformation', {
            'location': 'questkeeper://join?code=123-456',
          }),
        ),
        (_) {},
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AskForCampagneJoinCodeModalContent), findsOneWidget);
      expect(codeInDialog(tester), '123-456');

      await unmount(tester);
    });
  });
}
