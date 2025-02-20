import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:quest_keeper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/lifecycle_event_handler.dart';
import 'package:quest_keeper/helpers/save_rpg_character_configuration_to_storage_observer.dart';
import 'package:quest_keeper/helpers/save_rpg_configuration_to_storage_observer.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/screens/authorized_screen_wrapper.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_page_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/screens/preauthorized/complete_sso_screen.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/screens/preauthorized/register_screen.dart';
import 'package:quest_keeper/screens/select_game_mode_screen.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/server_methods_service.dart';

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

class AppRoutingShell extends ConsumerWidget {
  const AppRoutingShell({
    super.key,
    required this.widget,
  });

  final MyApp widget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Ruwudu',
          useMaterial3: true,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 16,
          ),
        ),
        navigatorKey: navigatorKey,
        initialRoute: widget.initialRoute ?? LoginScreen.route,
        onGenerateRoute: (RouteSettings settings) {
          // add all routes which are accessible without authorization
          switch (settings.name) {
            case AuthorizedScreenWrapper.route:
              return MaterialWithModalsPageRoute(
                builder: (_) =>
                    ThemeConfigurationForApp(child: AuthorizedScreenWrapper()),
                settings: settings,
              );
            case DmPageScreen.route:
              return MaterialWithModalsPageRoute(
                builder: (_) => ThemeConfigurationForApp(child: DmPageScreen()),
                settings: settings,
              );
            case PlayerPageScreen.route:
              return MaterialWithModalsPageRoute(
                builder: (_) =>
                    ThemeConfigurationForApp(child: PlayerPageScreen()),
                settings: settings,
              );
            case LoginScreen.route:
              return MaterialWithModalsPageRoute(
                builder: (_) => ThemeConfigurationForApp(child: LoginScreen()),
                settings: settings,
              );
            case RegisterScreen.route:
              return MaterialWithModalsPageRoute(
                builder: (_) =>
                    ThemeConfigurationForApp(child: RegisterScreen()),
                settings: settings,
              );
            case CompleteSsoScreen.route:
              return MaterialWithModalsPageRoute(
                builder: (_) =>
                    ThemeConfigurationForApp(child: CompleteSsoScreen()),
                settings: settings,
              );
            case SelectGameModeScreen.route:
              return MaterialWithModalsPageRoute(
                builder: (_) =>
                    ThemeConfigurationForApp(child: SelectGameModeScreen()),
                settings: settings,
              );
          }

          for (var config in allWizardConfigurations.entries.toList()) {
            if (settings.name == config.key) {
              return MaterialWithModalsPageRoute(
                builder: (_) => ThemeConfigurationForApp(
                  child: WizardRendererForConfiguration(
                    configuration: config.value,
                  ),
                ),
                settings: settings,
              );
            }
          }

          return null;
        },
      ),
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

  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    observer = getObserver();
    WidgetsBinding.instance.addObserver(observer!);
  }

  LifecycleEventHandler getObserver() {
    return LifecycleEventHandler(resumeCallBack: () async {
      var serverMethods =
          DependencyProvider.getIt!.get<IServerMethodsService>();
      var connectionDetails = ref.read(connectionDetailsProvider).valueOrNull;

      // should return early in the case the use is not in the session.
      if (connectionDetails == null || connectionDetails.isInSession == false) {
        return;
      }

      // readd to groups if the connection had to be reastablished
      await serverMethods.readdToSignalRGroups();

      ref.read(connectionDetailsProvider.notifier).updateConfiguration(
          ref.read(connectionDetailsProvider).value?.copyWith(
                    isConnected: true,
                    isConnecting: false,
                  ) ??
              ConnectionDetails.defaultValue());
    });
  }

  @override
  void dispose() {
    if (observer != null) WidgetsBinding.instance.removeObserver(observer!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineLarge: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              headlineMedium: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              headlineSmall: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              titleLarge: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              titleMedium: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              titleSmall: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              bodySmall: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              bodyMedium: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              bodyLarge: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              labelSmall: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              labelMedium: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              labelLarge: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              displaySmall: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              displayMedium: TextStyle(
                color: darkTextColor,
                fontFamily: "Ruwudu",
              ),
              displayLarge: TextStyle(
                color: darkTextColor,
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
