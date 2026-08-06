import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:quest_keeper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/lifecycle_event_handler.dart';
import 'package:quest_keeper/helpers/save_rpg_character_configuration_to_storage_observer.dart';
import 'package:quest_keeper/helpers/save_rpg_configuration_to_storage_observer.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/screens/authorized_screen_wrapper.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_page_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/screens/preauthorized/complete_sso_screen.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/screens/preauthorized/register_screen.dart';
import 'package:quest_keeper/screens/preauthorized/session_restorer_screen.dart';
import 'package:quest_keeper/screens/select_game_mode_screen.dart';
import 'package:quest_keeper/screens/settings/user_settings_screen.dart';
import 'package:quest_keeper/screens/settings/agent_debug_log_screen.dart';
import 'package:quest_keeper/screens/settings/api_keys_screen.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/services/auth/session_refresh_coordinator.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  final String? initialRoute;
  const MyApp({
    super.key,
    this.initialRoute,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      observers: [
        SaveRpgConfigurationToStorageObserver(),
        SaveRpgCharacterConfigurationToStorageObserver()
      ],
      child: AppRoutingShell(widget: widget),
    );
  }
}

final globalThemeWrapperKey = GlobalKey(debugLabel: "themeWrapper");

class AppRoutingShell extends ConsumerWidget {
  const AppRoutingShell({
    super.key,
    required this.widget,
  });

  final MyApp widget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomThemeProvider(
      child: Builder(builder: (context) {
        final themeProvider = CustomThemeProvider.of(context);
        return ListenableBuilder(
            listenable: Listenable.merge([
              themeProvider.skinIdNotifier,
              themeProvider.brightnessNotifier,
            ]),
            builder: (context, child) {
              return DependencyProvider(
                widgetRef: ref,
                isMocked: false,
                child: MaterialApp(
                  title: 'Flutter Demo',
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: [
                    ...AppLocalizations.localizationsDelegates,
                    S.delegate
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: ThemeData(
                    colorScheme:
                        ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                    fontFamily: 'Ruwudu',
                    useMaterial3: true,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    iconTheme: IconThemeData(
                      color: CustomThemeProvider.of(context).theme.textColor,
                      size: 16,
                    ),
                  ),
                  builder: (context, child) {
                    return ThemeConfigurationForApp(
                        key: globalThemeWrapperKey, child: child!);
                  },
                  navigatorKey: navigatorKey,
                  initialRoute:
                      widget.initialRoute ?? SessionRestorerScreen.route,
                  onGenerateRoute: (RouteSettings settings) {
                    // add all routes which are accessible without authorization
                    switch (settings.name) {
                      case SessionRestorerScreen.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => const SessionRestorerScreen(),
                          settings: settings,
                        );
                      case AuthorizedScreenWrapper.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => AuthorizedScreenWrapper(),
                          settings: settings,
                        );
                      case DmPageScreen.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => DmPageScreen(),
                          settings: settings,
                        );
                      case PlayerPageScreen.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => PlayerPageScreen(),
                          settings: settings,
                        );
                      case LoginScreen.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => LoginScreen(),
                          settings: settings,
                        );
                      case RegisterScreen.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => RegisterScreen(),
                          settings: settings,
                        );
                      case CompleteSsoScreen.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => CompleteSsoScreen(),
                          settings: settings,
                        );
                      case SelectGameModeScreen.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => SelectGameModeScreen(),
                          settings: settings,
                        );
                      case UserSettingsScreen.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => const UserSettingsScreen(),
                          settings: settings,
                        );
                      case ApiKeysScreen.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => const ApiKeysScreen(),
                          settings: settings,
                        );
                      case AgentDebugLogScreen.route:
                        return MaterialWithModalsPageRoute(
                          builder: (_) => const AgentDebugLogScreen(),
                          settings: settings,
                        );
                    }

                    for (var config
                        in allWizardConfigurations.entries.toList()) {
                      if (settings.name == config.key) {
                        return MaterialWithModalsPageRoute(
                          builder: (_) => WizardRendererForConfiguration(
                            configuration: config.value,
                          ),
                          settings: settings,
                        );
                      }
                    }

                    return null;
                  },
                ),
              );
            });
      }),
    );
  }
}

class ThemeConfigurationForApp extends ConsumerStatefulWidget {
  const ThemeConfigurationForApp({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<ThemeConfigurationForApp> createState() =>
      _ThemeConfigurationForAppState();
}

class _ThemeConfigurationForAppState
    extends ConsumerState<ThemeConfigurationForApp> {
  LifecycleEventHandler? observer;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  List<ConnectivityResult> _lastConnectivity = const [ConnectivityResult.none];

  // This widget is the root of your application.
  @override
  void initState() {
    log("initState ThemeConfigurationForApp");
    super.initState();
    observer = getObserver();

    if (!isInTestEnvironment) {
      Connectivity().checkConnectivity().then((r) {
        if (mounted) {
          setState(() => _lastConnectivity = r);
        }
      });
      _connectivitySub =
          Connectivity().onConnectivityChanged.listen((results) async {
        final hadNone = _lastConnectivity.contains(ConnectivityResult.none);
        _lastConnectivity = results;
        final hasNetwork = !results.contains(ConnectivityResult.none);
        if (!hadNone || !hasNetwork || !mounted) {
          return;
        }
        await _recoverSseSession();
      });
    }
    WidgetsBinding.instance.addObserver(observer!);
  }

  /// Presence and live updates now ride the SSE `/events` stream (sse-03/04),
  /// so recovery just re-establishes that stream; the reconnecting client then
  /// catches up on config via `*ConfigChanged` notifies.
  Future<void> _recoverSseSession() async {
    final eventsClient = DependencyProvider.getIt!.get<EventsClient>();
    await eventsClient.ensureConnected();
  }

  /// auth-04: on resume, refresh the access token if it's already expired
  /// or within the proactive lead window (e.g. the app was backgrounded for
  /// a while), so REST calls right after resume don't have to rely on a
  /// 401 round trip first. No-ops if there's no active session.
  Future<void> _refreshSessionIfNeeded() async {
    final getIt = DependencyProvider.getIt;
    if (getIt == null || !getIt.isRegistered<ISessionRefreshCoordinator>()) {
      return;
    }
    await getIt.get<ISessionRefreshCoordinator>().onAppResume();
  }

  LifecycleEventHandler getObserver() {
    return LifecycleEventHandler(
      resumeCallBack: () async {
        log("resumeCallBack: re-ensuring SSE stream", name: "SSE");
        await _refreshSessionIfNeeded();
        await _recoverSseSession();
      },
      suspendingCallBack: () async {
        log(
          "App lifecycle: inactive/paused/hidden — SSE stream left as-is.",
          name: "SSE",
        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    if (observer != null) WidgetsBinding.instance.removeObserver(observer!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Apply the status bar style for light text on dark background
    SystemChrome.setSystemUIOverlayStyle(
      CustomThemeProvider.of(context).theme.statusBarStyle,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineLarge: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              headlineMedium: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              headlineSmall: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              titleLarge: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              titleMedium: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              titleSmall: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              bodySmall: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              bodyMedium: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              bodyLarge: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              labelSmall: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              labelMedium: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              labelLarge: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              displaySmall: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              displayMedium: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
              displayLarge: TextStyle(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontFamily: "Ruwudu",
              ),
            ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 16,
        ),
      ),
      child: widget.child,
    );
  }
}
