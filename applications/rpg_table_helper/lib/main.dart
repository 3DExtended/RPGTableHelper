import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rpg_table_helper/components/main_two_block_layout.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/components/tab_handler.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/navigation_service.dart';

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

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DependencyProvider(
      isMocked: false,
      child: Builder(builder: (context) {
        var navigatorService = DependencyProvider.of(context)
            .getService<INavigationService>()
            .getNavigationKeys();

        return MaterialApp(
          title: 'Flutter Demo',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: navigatorService[TabItem.base],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            fontFamily: 'Roboto',
            useMaterial3: true,
            iconTheme: const IconThemeData(
              color: Colors.white,
              size: 24,
            ),
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
          initialRoute: "/",
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
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MainTwoBlockLayout(
        navbarButtons: [
          NavbarButton(
            onPressed: () {
              setState(() {});
            },
            icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
            tabItem: TabItem.search,
          ),
          NavbarButton(
            onPressed: () {
              setState(() {});
            },
            icon: const FaIcon(FontAwesomeIcons.user),
            tabItem: TabItem.character,
          ),
          NavbarButton(
            onPressed: () {
              setState(() {});
            },
            icon: const FaIcon(FontAwesomeIcons.basketShopping),
            tabItem: TabItem.inventory,
          ),
          NavbarButton(
            onPressed: () {
              setState(() {});
            },
            icon: const FaIcon(FontAwesomeIcons.trowel),
            tabItem: TabItem.crafting,
          ),
          NavbarButton(
            onPressed: () {
              setState(() {});
            },
            icon: const FaIcon(FontAwesomeIcons.bookJournalWhills),
            tabItem: TabItem.lore,
          ),
        ],
        content: Container(
          color: const Color.fromARGB(35, 29, 22, 22),
        ));
  }
}
