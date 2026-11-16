import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/auth/access_token_expiry_store.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/auth/authentication_service.dart';
import 'package:quest_keeper/services/auth/encryption_service.dart';
import 'package:quest_keeper/services/auth/secure_refresh_token_storage.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/systemclock_service.dart';

import '../../custom_font_loader.dart';

/// A [MockAuthenticationService] with all its dependencies mocked.
MockAuthenticationService buildMockAuthenticationService({
  HRResponse<bool>? loginResult,
  HRResponse<SignInResult>? registerResult,
  HRResponse<bool>? requestPasswordResetResult,
  HRResponse<bool>? resetPasswordResult,
}) {
  return MockAuthenticationService(
    apiConnectorService: MockApiConnectorService(),
    encryptionService: MockEncryptionService(),
    secureRefreshTokenStorage: MockSecureRefreshTokenStorage(),
    accessTokenExpiryStore: MockAccessTokenExpiryStore(),
    systemClockService: MockSystemClockService(),
    loginResultOverride: loginResult,
    registerResultOverride: registerResult,
    requestPasswordResetResultOverride: requestPasswordResetResult,
    resetPasswordResultOverride: resetPasswordResult,
  );
}

/// Pumps [home] inside the mocked services, the default (dark) skin and the
/// German localizations, on a phone-sized screen with the real fonts.
///
/// Named routes in [stubRoutes] are answered with the given builders; every
/// named route that is pushed is recorded in [pushedRoutes].
Future<void> pumpAuthScreen(
  WidgetTester tester, {
  required Widget home,
  IAuthenticationService? authenticationService,
  Map<String, WidgetBuilder> stubRoutes = const {},
  List<RouteSettings>? pushedRoutes,
}) async {
  await customLoadAppFonts();
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: CustomThemeProvider(
        child: DependencyProvider.getMockedDependecyProvider(
          mockOverrides: {
            if (authenticationService != null)
              IAuthenticationService: () => authenticationService,
          },
          child: MaterialApp(
            locale: const Locale('de'),
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: home,
            onGenerateRoute: (settings) {
              pushedRoutes?.add(settings);
              final builder = stubRoutes[settings.name];
              if (builder == null) return null;
              return MaterialPageRoute(builder: builder, settings: settings);
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The [TextField] whose label is [label].
Finder textFieldLabelled(String label) => find.widgetWithText(TextField, label);

/// Scrolls [finder] into view and taps it.
Future<void> scrollToAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
