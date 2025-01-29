import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:rpg_table_helper/screens/character_screen.dart';
import 'package:rpg_table_helper/screens/crafting_screen.dart';
import 'package:rpg_table_helper/screens/inventory_screen.dart';
import 'package:rpg_table_helper/screens/search_screen.dart';
import 'package:rpg_table_helper/screens/wizards/all_wizard_configurations.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/navigation_service.dart';
import 'package:rpg_table_helper/services/server_communication_service.dart';

class AuthorizedScreenWrapper extends ConsumerStatefulWidget {
  static const route = '/';

  final TabItem? initTab;

  const AuthorizedScreenWrapper({super.key, this.initTab});

  @override
  ConsumerState<AuthorizedScreenWrapper> createState() =>
      _AuthorizedScreenWrapperState();
}

class _AuthorizedScreenWrapperState
    extends ConsumerState<AuthorizedScreenWrapper> {
  var _currentTab = TabItem.character;

  var characterScreenKey = LabeledGlobalKey("characterScreenKey");

  Map<String, Widget Function(BuildContext)> _routeBuilders(
      BuildContext context) {
    var result = {
      CharacterScreen.route: (context) => CharacterScreen(
            key: characterScreenKey,
          ),
      InventoryScreen.route: (context) => const InventoryScreen(),
      CraftingScreen.route: (context) => const CraftingScreen(),
      SearchScreen.route: (context) => const SearchScreen(),
    };

    for (var config in allWizardConfigurations.entries.toList()) {
      result[config.key] = (context) => WizardRendererForConfiguration(
            configuration: config.value,
          );
    }

    return result;
  }

  bool _doesRouteImplementOwnTabHandler(String route) {
    List<String> ownTabHandledRoutes = [];
    ownTabHandledRoutes.addAll(allWizardConfigurations.keys);

    return (ownTabHandledRoutes.contains(route));
  }

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
    Future.delayed(Duration.zero, () async {
      // this initializes the communication
      if (!mounted) return;
      DependencyProvider.of(context).getService<IServerCommunicationService>();

      if (widget.initTab != null) {
        setState(() {
          _currentTab = widget.initTab!;
        });
      }
    });
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
    return Container(
      color: const Color.fromARGB(35, 29, 22, 22),
      child: Stack(children: <Widget>[
        _buildOffstageNavigator(TabItem.character),
        _buildOffstageNavigator(TabItem.search),
        _buildOffstageNavigator(TabItem.crafting),
        _buildOffstageNavigator(TabItem.inventory),
        _buildOffstageNavigator(TabItem.lore),
      ]),
    );
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    var navigationService =
        DependencyProvider.of(context).getService<INavigationService>();
    var navigatorKeys = navigationService.getNavigationKeys();

    final routeBuilders = _routeBuilders(context);

    var tabDefaultRoute = navigationService.getDefaultRouteForTabItem(tabItem);

    return Offstage(
      offstage: _currentTab != tabItem,
      child: Navigator(
        key: navigatorKeys[tabItem],
        initialRoute: tabDefaultRoute,
        onGenerateRoute: (routeSettings) {
          var routeName = routeSettings.name!;
          if (routeName == '/') {
            return null; //routeName = tabDefaultRoute;
          }
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) {
              var routeChild = routeBuilders[routeSettings.name!]!(context);
              return Container(
                color: const Color.fromARGB(35, 29, 22, 22),
                child: routeChild,
              );

              /*var selectedId = TabItem.values.indexOf(tabItem);

              if (_doesRouteImplementOwnTabHandler(routeSettings.name!)) {
                return routeChild;
              } else {
                var connectionDetails =
                    ref.watch(connectionDetailsProvider).valueOrNull;

                return MainTwoBlockLayout(
                    showIsConnectedButton: true,
                    selectedNavbarButton: selectedId,
                    navbarButtons: [
                      NavbarButton(
                        onPressed: (tabItem) {
                          setState(() {
                            _selectTab(tabItem!);
                          });
                        },
                        icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
                        tabItem: TabItem.search,
                      ),
                      NavbarButton(
                        onPressed: (tabItem) {
                          setState(() {
                            _selectTab(tabItem!);
                          });
                        },
                        icon: connectionDetails?.isDm == true
                            ? const FaIcon(FontAwesomeIcons.users)
                            : const FaIcon(FontAwesomeIcons.user),
                        tabItem: TabItem.character,
                      ),
                      NavbarButton(
                        onPressed: (tabItem) {
                          setState(() {
                            _selectTab(tabItem!);
                          });
                        },
                        icon: connectionDetails?.isDm == true
                            ? const FaIcon(FontAwesomeIcons.handHoldingMedical)
                            : const FaIcon(FontAwesomeIcons.basketShopping),
                        tabItem: TabItem.inventory,
                      ),
                      if (connectionDetails?.isDm != true)
                        NavbarButton(
                          onPressed: (tabItem) {
                            setState(() {
                              _selectTab(tabItem!);
                            });
                          },
                          icon: const FaIcon(FontAwesomeIcons.trowel),
                          tabItem: TabItem.crafting,
                        ),
                      NavbarButton(
                        onPressed: (tabItem) {
                          setState(() {
                            _selectTab(tabItem!);
                          });
                        },
                        icon: const FaIcon(FontAwesomeIcons.bookJournalWhills),
                        tabItem: TabItem.lore,
                      ),
                    ],
                    content: Container(
                      color: const Color.fromARGB(35, 29, 22, 22),
                      child: routeChild,
                    )); */
            },
          );
        },
      ),
    );
  }
}
