import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/main_two_block_layout.dart';
import 'package:rpg_table_helper/components/navbar_block.dart';
import 'package:rpg_table_helper/screens/character_screen.dart';
import 'package:rpg_table_helper/screens/crafting_screen.dart';
import 'package:rpg_table_helper/screens/inventory_screen.dart';
import 'package:rpg_table_helper/screens/lore_screen.dart';
import 'package:rpg_table_helper/screens/search_screen.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/navigation_service.dart';

class AuthorizedScreenWrapper extends StatefulWidget {
  static const route = '/';

  const AuthorizedScreenWrapper({super.key});

  @override
  State<AuthorizedScreenWrapper> createState() =>
      _AuthorizedScreenWrapperState();
}

class _AuthorizedScreenWrapperState extends State<AuthorizedScreenWrapper> {
  var _currentTab = TabItem.character;

  _reloadRouteIfPossible(BuildContext context, TabItem tabItem) {
    var navigatorKeys = DependencyProvider.of(context)
        .getService<INavigationService>()
        .getNavigationKeys();

    var currentState = navigatorKeys[tabItem]!.currentState;
    if (currentState == null) return;
    var currentRoute = currentState.widget.initialRoute;

    if (!_reloadableRoutes(currentRoute!)) return;

    // Push a new instance of the same route
    currentState.pushReplacementNamed(currentRoute);
  }

  bool _reloadableRoutes(String route) {
    var reloadableRoute = [];

    return (reloadableRoute.contains(route));
  }

  void _selectTab(TabItem tabItem) {
    var navservice =
        DependencyProvider.of(context).getService<INavigationService>();
    if (tabItem == _currentTab) {
      // pop to first route
      var navigatorKeys = navservice.getNavigationKeys();

      var tabDefaultRoute = navservice.getDefaultRouteForTabItem(tabItem);

      navigatorKeys[tabItem]!.currentState!.popUntil(
          (route) => route.isFirst || route.settings.name == tabDefaultRoute);

      _reloadRouteIfPossible(context, tabItem);
    } else {
      setState(() {
        _currentTab = tabItem;
        navservice.setCurrentTabItem(tabItem);
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var navigatorKeys = DependencyProvider.of(context)
        .getService<INavigationService>()
        .getNavigationKeys();

    // ignored as the newer PopScope doesnt allow for async prevention of onWillPop
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await navigatorKeys[_currentTab]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (_currentTab != TabItem.character) {
            // select 'main' tab
            _selectTab(TabItem.character);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: _buildBody(),
        extendBody: true,
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Widget _buildBody() {
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
          child: Stack(children: <Widget>[
            _buildOffstageNavigator(TabItem.character),
            _buildOffstageNavigator(TabItem.search),
            _buildOffstageNavigator(TabItem.crafting),
            _buildOffstageNavigator(TabItem.inventory),
            _buildOffstageNavigator(TabItem.lore),
          ]),
        ));
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    var navigatorKeys = DependencyProvider.of(context)
        .getService<INavigationService>()
        .getNavigationKeys();

    print(
        'Building navigator for $tabItem with key: ${navigatorKeys[tabItem].toString()}');

    return Offstage(
      offstage: _currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}

class TabNavigator extends StatelessWidget {
  const TabNavigator(
      {super.key, required this.navigatorKey, required this.tabItem});

  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;

  @override
  Widget build(BuildContext context) {
    print(
        "rebuilding TabNavigator with key: $navigatorKey and tabitem: ${tabItem.name}");
    final routeBuilders = _routeBuilders(context);

    var tabDefaultRoute = DependencyProvider.of(context)
        .getService<INavigationService>()
        .getDefaultRouteForTabItem(tabItem);

    return Navigator(
      key: navigatorKey,
      initialRoute: tabDefaultRoute,
      onGenerateRoute: (routeSettings) {
        var routeName = routeSettings.name!;
        if (routeName == '/') {
          return null; //routeName = tabDefaultRoute;
        }
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => routeBuilders[routeSettings.name!]!(context),
        );
      },
    );
  }

  _routeBuilders(BuildContext context) {
    return {
      LoreScreen.route: (context) => const LoreScreen(),
      CharacterScreen.route: (context) => const CharacterScreen(),
      InventoryScreen.route: (context) => const InventoryScreen(),
      CraftingScreen.route: (context) => const CraftingScreen(),
      SearchScreen.route: (context) => const SearchScreen(),
    };
  }
}
