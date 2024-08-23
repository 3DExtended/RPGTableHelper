import 'package:flutter/widgets.dart';

enum TabItem {
  base,
  search,
  character,
  inventory,
  crafting,
  lore,
}

abstract class INavigationService {
  final bool isMock;
  const INavigationService({required this.isMock});

  TabItem getCurrentTabItem();
  void setCurrentTabItem(TabItem value);

  Map<TabItem, GlobalKey<NavigatorState>> getNavigationKeys();

  GlobalKey<NavigatorState> getCurrentNavigationKey() =>
      getNavigationKeys()[getCurrentTabItem()]!;

  String getDefaultRouteForTabItem(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.search:
        return "/"; //SearchScreen.route; // TODO make me
      case TabItem.character:
        return "/"; //SearchScreen.route; // TODO make me
      case TabItem.crafting:
        return "/"; //SearchScreen.route; // TODO make me
      case TabItem.inventory:
        return "/"; //SearchScreen.route; // TODO make me
      case TabItem.lore:
        return "/"; //SearchScreen.route; // TODO make me
      case TabItem.base:
      default:
        throw Exception(
            'tried opeing the signinflow from the wrong navigation key');
    }
  }
}

class NavigationService extends INavigationService {
  TabItem _currentTabItem = TabItem.character;
  final _navigatorKeys = {
    TabItem.character: const GlobalObjectKey<NavigatorState>('character'),
    TabItem.lore: const GlobalObjectKey<NavigatorState>('lore'),
    TabItem.search: const GlobalObjectKey<NavigatorState>('search'),
    TabItem.crafting: const GlobalObjectKey<NavigatorState>('crafting'),
    TabItem.inventory: const GlobalObjectKey<NavigatorState>('inventory'),
    TabItem.base: const GlobalObjectKey<NavigatorState>('base'),
  };

  @override
  Map<TabItem, GlobalObjectKey<NavigatorState>> getNavigationKeys() =>
      _navigatorKeys;

  @override
  TabItem getCurrentTabItem() {
    return _currentTabItem;
  }

  @override
  void setCurrentTabItem(TabItem value) {
    _currentTabItem = value;
  }

  NavigationService() : super(isMock: false);
}
