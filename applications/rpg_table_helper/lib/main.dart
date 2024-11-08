import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rpg_table_helper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/save_rpg_character_configuration_to_storage_observer.dart';
import 'package:rpg_table_helper/helpers/save_rpg_configuration_to_storage_observer.dart';
import 'package:rpg_table_helper/screens/authorized_screen_wrapper.dart';
import 'package:rpg_table_helper/screens/pageviews/dm_pageview/dm_page_screen.dart';
import 'package:rpg_table_helper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:rpg_table_helper/screens/preauthorized/complete_sso_screen.dart';
import 'package:rpg_table_helper/screens/preauthorized/login_screen.dart';
import 'package:rpg_table_helper/screens/preauthorized/register_screen.dart';
import 'package:rpg_table_helper/screens/select_game_mode_screen.dart';
import 'package:rpg_table_helper/screens/wizards/all_wizard_configurations.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

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
  // This widget is the root of your application.
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Roboto',
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

class ThemeConfigurationForApp extends StatelessWidget {
  const ThemeConfigurationForApp({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineLarge:
                  TextStyle(color: darkTextColor, fontFamily: "Roboto"),
              headlineMedium: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              headlineSmall: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              titleLarge: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              titleMedium: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              titleSmall: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              bodySmall: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              bodyMedium: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              bodyLarge: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              labelSmall: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              labelMedium: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              labelLarge: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              displaySmall: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              displayMedium: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
              displayLarge: TextStyle(
                color: darkTextColor,
                fontFamily: "Roboto",
              ),
            ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 16,
        ),
      ),
      child: child,
    );
  }
}
