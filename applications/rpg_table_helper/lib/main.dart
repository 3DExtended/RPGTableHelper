import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rpg_table_helper/components/tab_handler.dart';
import 'package:rpg_table_helper/helpers/save_rpg_configuration_to_storage_observer.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

void main() {
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
      observers: [SaveRpgConfigurationToStorageObserver()],
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
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Roboto',
          useMaterial3: true,
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 16,
          ),
        ),
        navigatorKey: navigatorKey,
        initialRoute: widget.initialRoute ?? AuthorizedScreenWrapper.route,
        onGenerateRoute: (RouteSettings settings) {
          // add all routes which are accessible without authorization
          switch (settings.name) {
            case AuthorizedScreenWrapper.route:
              return MaterialWithModalsPageRoute(
                builder: (_) => const AuthorizedScreenWrapper(),
                settings: settings,
              );
          }
          return null;
        },
      ),
    );
  }
}
