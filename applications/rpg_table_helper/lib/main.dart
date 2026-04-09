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
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/lifecycle_event_handler.dart';
import 'package:quest_keeper/helpers/save_rpg_character_configuration_to_storage_observer.dart';
import 'package:quest_keeper/helpers/save_rpg_configuration_to_storage_observer.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/screens/authorized_screen_wrapper.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_page_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/screens/preauthorized/complete_sso_screen.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/screens/preauthorized/register_screen.dart';
import 'package:quest_keeper/screens/select_game_mode_screen.dart';
import 'package:quest_keeper/screens/settings/user_settings_screen.dart';
import 'package:quest_keeper/screens/settings/api_keys_screen.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/server_communication_service.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:quest_keeper/services/snack_bar_service.dart';
import 'package:signalr_netcore/signalr_client.dart';

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
        return ValueListenableBuilder<Brightness>(
            valueListenable: themeProvider.brightnessNotifier,
            builder: (context, brightness, child) {
              print(brightness);
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
                  initialRoute: widget.initialRoute ?? LoginScreen.route,
                  onGenerateRoute: (RouteSettings settings) {
                    // add all routes which are accessible without authorization
                    switch (settings.name) {
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

  /// DM: consecutive periodic checks where a player's `lastPing` stayed stale (see constants).
  final Map<String, int> _dmConsecutiveStalePingCounts = {};

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _hubDrainTimer;
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
        final connectionDetails =
            ref.read(connectionDetailsProvider).valueOrNull;
        if (connectionDetails?.isInSession != true) {
          return;
        }
        await recoverSignalRSession();
      });

      _hubDrainTimer =
          Timer.periodic(hubInvokeQueueDrainPeriodicInterval, (_) async {
        if (!mounted) {
          return;
        }
        final connectionDetails =
            ref.read(connectionDetailsProvider).valueOrNull;
        if (connectionDetails?.isInSession != true) {
          return;
        }
        final comm =
            DependencyProvider.getIt!.get<IServerCommunicationService>();
        if (comm.pendingHubInvokeCount > 0) {
          await comm.ensureConnectionReadyForSession();
          await comm.drainHubInvokeQueue();
        }
      });
    }

    if (!isInTestEnvironment) {
      // future which runs every 10 seconds
      Timer.periodic(pingInterval, (timer) {
        log("pingInterval");
        if (kDebugMode) {}

        if (!mounted || !context.mounted) {
          log("pingInterval ERROR - not mounted");
          timer.cancel();

          return;
        }

        var connectionDetails = ref.read(connectionDetailsProvider).valueOrNull;
        if (connectionDetails == null ||
            connectionDetails.isInSession == false) {
          return;
        }
        if (connectionDetails.isInSession == false) {
          return;
        }

        if (connectionDetails.isPlayer == true) {
          if (connectionDetails.lastPing == null) {
            // the player cannot initiate a ping message and has to wait for the DM to send one
            return;
          }

          // check when we received the last ping message from DM
          if (connectionDetails.lastPing!.isBefore(DateTime.now()
              .subtract(playerDisconnectedFromDmAfter))) {
            var snackBar = SnackBar(
              showCloseIcon: true,
              duration: Duration(seconds: 60),
              content: Text(
                S.of(context).yourAreDisconnectedBody,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: CustomThemeProvider.of(context).theme.textColor,
                      fontSize: 16,
                    ),
              ),
            );

            DependencyProvider.getIt!.get<ISnackBarService>().showSnackBar(
                  snack: snackBar,
                  uniqueId:
                      "disconnectedFromDm-f3fdf3b4-fdfe-4910-9551-00d751020e17",
                );
          } else {
            DependencyProvider.getIt!.get<ISnackBarService>().hideSnackBar(
                  "disconnectedFromDm-f3fdf3b4-fdfe-4910-9551-00d751020e17",
                );
          }
        } else {
          if (connectionDetails.lastPing != null) {
            final now = DateTime.now();
            final staleBefore = now.subtract(dmPlayerPingStaleThreshold);
            final nextStaleCounts = <String, int>{};
            final userIdsToRemove = <String>[];

            for (final element in connectionDetails.connectedPlayers ?? []) {
              final uid = element.userId.$value!;
              final last = element.lastPing;
              if (last != null && last.isBefore(staleBefore)) {
                final c =
                    (_dmConsecutiveStalePingCounts[uid] ?? 0) + 1;
                nextStaleCounts[uid] = c;
                if (c >= dmConsecutiveStaleChecksBeforeRemove) {
                  userIdsToRemove.add(uid);
                }
              }
            }

            _dmConsecutiveStalePingCounts
              ..clear()
              ..addAll(nextStaleCounts);

            if (userIdsToRemove.isNotEmpty) {
              ref.read(connectionDetailsProvider.notifier).updateConfiguration(
                  ref.read(connectionDetailsProvider).value?.copyWith(
                            connectedPlayers: connectionDetails.connectedPlayers
                                ?.where((e) => !userIdsToRemove
                                    .contains(e.userId.$value))
                                .toList(),
                          ) ??
                      ConnectionDetails.defaultValue());
            }
          }

          // send new ping message to all players
          // mark all players as disconnected if they did not respond since last ping
          var newPingTimestamp = DateTime.now();
          ref.read(connectionDetailsProvider.notifier).updateConfiguration(
              ref.read(connectionDetailsProvider).value?.copyWith(
                        lastPing: newPingTimestamp,
                      ) ??
                  ConnectionDetails.defaultValue());

          var serverMethods =
              DependencyProvider.getIt!.get<IServerMethodsService>();
          serverMethods.sendPingToPlayers(
            campagneId: connectionDetails.campagneId!,
            timestamp: newPingTimestamp,
          );
        }
      });
    }
    WidgetsBinding.instance.addObserver(observer!);
  }

  /// Reconnect SignalR, re-join groups, drain queued critical invokes, refresh UI flags.
  Future<void> recoverSignalRSession() async {
    final serverMethods =
        DependencyProvider.getIt!.get<IServerMethodsService>();
    final comm = DependencyProvider.getIt!.get<IServerCommunicationService>();
    var connectionDetails = ref.read(connectionDetailsProvider).valueOrNull;

    if (connectionDetails == null || connectionDetails.isInSession == false) {
      return;
    }

    await comm.ensureConnectionReadyForSession();
    await serverMethods.readdToSignalRGroups();
    await comm.drainHubInvokeQueue();

    final hubState = comm.hubConnectionState;
    final connected = hubState == HubConnectionState.Connected;
    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
          ref.read(connectionDetailsProvider).value?.copyWith(
                isConnected: connected,
                isConnecting: !connected &&
                    hubState != null &&
                    (hubState == HubConnectionState.Connecting ||
                        hubState == HubConnectionState.Reconnecting),
              ) ??
              ConnectionDetails.defaultValue(),
        );
  }

  LifecycleEventHandler getObserver() {
    return LifecycleEventHandler(
      resumeCallBack: () async {
        log("resumeCallBack", name: "SignalR");
        await recoverSignalRSession();
      },
      suspendingCallBack: () async {
        log(
          "App lifecycle: inactive/paused/hidden — iOS may suspend sockets; "
          "hub left connected (not stopped) to reduce churn.",
          name: "SignalR",
        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _hubDrainTimer?.cancel();
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
