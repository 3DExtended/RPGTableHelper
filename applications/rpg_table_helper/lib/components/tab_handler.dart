import 'package:flutter/material.dart';
import 'package:rpg_table_helper/screens/login_screen.dart';
import 'package:rpg_table_helper/screens/search_screen.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/navigation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthorizedScreenWrapper extends StatefulWidget {
  static const route = '/';

  const AuthorizedScreenWrapper({super.key});

  @override
  State<AuthorizedScreenWrapper> createState() =>
      _AuthorizedScreenWrapperState();
}

class _AuthorizedScreenWrapperState extends State<AuthorizedScreenWrapper> {
  var _currentTab = TabItem.character;

  final Set<TabItem> _listOfOpendTabs = {TabItem.character};

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
        _listOfOpendTabs.add(tabItem);
        _currentTab = tabItem;
        navservice.setCurrentTabItem(tabItem);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 10), () async {
      if (DependencyProvider.of(context).isMocked) {
        return;
      }

      var navigateBack = false;

      var hasSomeJwtStored = await getHasSomeJwtStored();
      if (!hasSomeJwtStored) navigateBack = true;

      if (!navigateBack && mounted) {
        if (!await LoginScreen.checkIfAppVersionFits(context)) {
          navigateBack = true;
        }
      }

      if (navigateBack == true) {
        if (!mounted) return;

        var navigatorService =
            DependencyProvider.of(context).getService<INavigationService>();
        navigatorService.setCurrentTabItem(TabItem.base);
        navigatorService
            .getNavigationKeys()[TabItem.base]!
            .currentState!
            .pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
      }
    });
  }

  Future<bool> getHasSomeJwtStored() async {
    if (!DependencyProvider.of(context).isMocked) {
      var prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('jwt');
    }

    return false;
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
        // bottomNavigationBar: BottomNavigation(
        //   currentTab: _currentTab,
        //   onSelectTab: _selectTab,
        // ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(children: <Widget>[
      if (_listOfOpendTabs.contains(TabItem.character))
        _buildOffstageNavigator(TabItem.character),
      if (_listOfOpendTabs.contains(TabItem.search))
        _buildOffstageNavigator(TabItem.search),
      if (_listOfOpendTabs.contains(TabItem.crafting))
        _buildOffstageNavigator(TabItem.crafting),
      if (_listOfOpendTabs.contains(TabItem.inventory))
        _buildOffstageNavigator(TabItem.inventory),
      if (_listOfOpendTabs.contains(TabItem.lore))
        _buildOffstageNavigator(TabItem.lore),
      if (_listOfOpendTabs.contains(TabItem.search))
        _buildOffstageNavigator(TabItem.search),
    ]);
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    var navigatorKeys = DependencyProvider.of(context)
        .getService<INavigationService>()
        .getNavigationKeys();

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
      SearchScreen.route: (context) => const SearchScreen(),
    };
  }
}
