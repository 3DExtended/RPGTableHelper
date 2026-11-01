import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/api_key_scopes.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/screens/settings/api_keys_screen.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/api_key_service.dart';
import 'package:quest_keeper/services/backend_capabilities_service.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

class _RecordedCreate {
  final String name;
  final List<String> scopes;
  final DateTime? expiresAt;

  _RecordedCreate(this.name, this.scopes, this.expiresAt);
}

class _RecordingApiKeyService implements IApiKeyService {
  final List<ApiKeyDto> keys;
  final List<_RecordedCreate> creates = [];

  _RecordingApiKeyService(this.keys);

  @override
  Future<HRResponse<CreateApiKeyResponse>> createApiKey(
    String name, {
    required List<String> scopes,
    DateTime? expiresAt,
  }) async {
    creates.add(_RecordedCreate(name, scopes, expiresAt));
    return HRResponse.fromResult(CreateApiKeyResponse(
      apiKey: ApiKeyDto(id: 'new', name: name, prefix: 'sk-new1'),
      plainKey: 'sk-new1-secret',
    ));
  }

  @override
  Future<HRResponse<List<ApiKeyDto>>> getApiKeys() async =>
      HRResponse.fromResult(keys);

  @override
  Future<HRResponse<bool>> revokeApiKey(String id) async =>
      HRResponse.fromResult(true);
}

Future<void> _pumpScreen(WidgetTester tester, _RecordingApiKeyService service,
    {bool serverHasScopedKeys = true}) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: DependencyProvider.getMockedDependecyProvider(
        mockOverrides: {
          IApiKeyService: () => service,
          IBackendCapabilitiesService: () => MockBackendCapabilitiesService(
                apiConnectorService:
                    DependencyProvider.getIt!.get<IApiConnectorService>(),
                capabilitiesOverride: {
                  ...kBaselineBackendCapabilities,
                  if (serverHasScopedKeys) BackendCapability.scopedApiKeys,
                },
              ),
        },
        child: CustomThemeProvider(
          overrideBrightness: Brightness.light,
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale('de'),
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ApiKeysScreen(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final now = DateTime.now();

  testWidgets('key cards show permissions, last use and expiry',
      (tester) async {
    final service = _RecordingApiKeyService([
      ApiKeyDto(
        id: '1',
        name: 'Carstens App',
        prefix: 'sk-abc1',
        createdAt: now,
        scopes: ApiKeyScopes.companionApp,
        lastUsedAt: now.subtract(const Duration(minutes: 3)),
        expiresAt: now.add(const Duration(days: 30)),
      ),
      ApiKeyDto(
        id: '2',
        name: 'Notizen-Export',
        prefix: 'sk-def2',
        createdAt: now,
        scopes: [ApiKeyScopes.notesRead],
      ),
      ApiKeyDto(
        id: '3',
        name: 'Alt',
        prefix: 'sk-ghi3',
        createdAt: now,
        scopes: ApiKeyScopes.readOnly,
        expiresAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    await _pumpScreen(tester, service);

    expect(find.text('Carstens App'), findsOneWidget);
    expect(find.text('Rechte: Begleit-App für Spieler'), findsOneWidget);
    expect(find.textContaining('Zuletzt benutzt: '), findsOneWidget);
    expect(find.textContaining('Läuft ab: '), findsNWidgets(2));

    // A key that matches no preset lists its permissions one by one.
    expect(find.text('Rechte: '), findsOneWidget);
    expect(
        find.text('• Die Notizen lesen, die du sehen darfst'), findsOneWidget);
    expect(find.text('Noch nie benutzt'), findsNWidgets(2));
    expect(find.text('Läuft nie ab'), findsOneWidget);

    expect(find.text('Abgelaufen'), findsOneWidget);
  });

  testWidgets('creating a companion key sends all scopes and the expiry',
      (tester) async {
    final service = _RecordingApiKeyService([]);
    await _pumpScreen(tester, service);

    await tester.tap(find.text('Neuen API-Schlüssel erstellen'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const ValueKey('apiKeyNameField')), '  Carstens App ');
    await tester.tap(find.byKey(const ValueKey('apiKeyPreset_companionApp')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('apiKeyLifetime')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('90 Tage').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('apiKeyCreateConfirm')));
    await tester.pumpAndSettle();

    expect(service.creates, hasLength(1));
    final create = service.creates.single;
    expect(create.name, 'Carstens App');
    expect(create.scopes, ApiKeyScopes.all);
    expect(create.expiresAt, isNotNull);
    expect(
      create.expiresAt!.difference(DateTime.now()).inDays,
      inInclusiveRange(89, 90),
    );

    // The plain key is shown exactly once, right after creation.
    expect(find.text('API-Schlüssel erstellt'), findsOneWidget);
    expect(find.text('sk-new1-secret'), findsOneWidget);
  });

  testWidgets('a new key is read-only and never expires by default',
      (tester) async {
    final service = _RecordingApiKeyService([]);
    await _pumpScreen(tester, service);

    await tester.tap(find.text('Neuen API-Schlüssel erstellen'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('apiKeyNameField')), 'Export');
    await tester.tap(find.byKey(const ValueKey('apiKeyCreateConfirm')));
    await tester.pumpAndSettle();

    expect(service.creates.single.scopes, ApiKeyScopes.readOnly);
    expect(service.creates.single.expiresAt, isNull);
  });

  testWidgets('ticking single permissions switches to the custom preset',
      (tester) async {
    final service = _RecordingApiKeyService([]);
    await _pumpScreen(tester, service);

    await tester.tap(find.text('Neuen API-Schlüssel erstellen'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('apiKeyNameField')), 'Nur Notizen');

    await tester.tap(
        find.byKey(const ValueKey('apiKeyScope_${ApiKeyScopes.notesWrite}')));
    await tester.pumpAndSettle();

    final customChip = tester
        .widget<ChoiceChip>(find.byKey(const ValueKey('apiKeyPreset_custom')));
    expect(customChip.selected, isTrue);

    await tester.tap(find.byKey(const ValueKey('apiKeyCreateConfirm')));
    await tester.pumpAndSettle();

    expect(service.creates.single.scopes, [
      ApiKeyScopes.campaignsRead,
      ApiKeyScopes.charactersRead,
      ApiKeyScopes.notesRead,
      ApiKeyScopes.notesWrite,
    ]);
  });

  testWidgets('the dialog refuses an empty name or no permissions',
      (tester) async {
    final service = _RecordingApiKeyService([]);
    await _pumpScreen(tester, service);

    await tester.tap(find.text('Neuen API-Schlüssel erstellen'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('apiKeyCreateConfirm')));
    await tester.pumpAndSettle();
    expect(find.text('Gib einen Namen ein.'), findsOneWidget);

    await tester.enterText(
        find.byKey(const ValueKey('apiKeyNameField')), 'Leer');
    for (final scope in ApiKeyScopes.readOnly) {
      await tester.tap(find.byKey(ValueKey('apiKeyScope_$scope')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('apiKeyCreateConfirm')));
    await tester.pumpAndSettle();
    expect(find.text('Wähle mindestens ein Recht aus.'), findsOneWidget);

    expect(service.creates, isEmpty);
  });

  testWidgets(
      'on a server without scoped keys the dialog only asks for a name and '
      'says the key can read', (tester) async {
    final service = _RecordingApiKeyService([]);
    await _pumpScreen(tester, service, serverHasScopedKeys: false);

    await tester.tap(find.text('Neuen API-Schlüssel erstellen'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('apiKeyPermissionsNeedServerUpdate')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('apiKeyPreset_companionApp')), findsNothing);
    expect(find.byKey(const ValueKey('apiKeyScope_${ApiKeyScopes.notesWrite}')),
        findsNothing);
    expect(find.byKey(const ValueKey('apiKeyLifetime')), findsNothing);

    await tester.enterText(
        find.byKey(const ValueKey('apiKeyNameField')), 'Export');
    await tester.tap(find.byKey(const ValueKey('apiKeyCreateConfirm')));
    await tester.pumpAndSettle();

    expect(service.creates.single.scopes, ApiKeyScopes.readOnly);
    expect(service.creates.single.expiresAt, isNull);
  });

  testWidgets('a key from a server without scopes shows read access',
      (tester) async {
    final service = _RecordingApiKeyService([
      ApiKeyDto(id: '1', name: 'Alt', prefix: 'sk-old1', createdAt: now),
    ]);

    await _pumpScreen(tester, service, serverHasScopedKeys: false);

    expect(find.text('Rechte: Nur lesen'), findsOneWidget);
    expect(find.text('Läuft nie ab'), findsOneWidget);
  });

  testWidgets('a key as a server without scopes sends it shows read access',
      (tester) async {
    // The generated model turns the missing scopes into an empty list.
    final service = _RecordingApiKeyService([
      ApiKeyDto.fromJson({'id': '1', 'name': 'Alt', 'prefix': 'sk-old1'}),
    ]);

    await _pumpScreen(tester, service, serverHasScopedKeys: false);

    expect(find.text('Rechte: Nur lesen'), findsOneWidget);
  });
}
