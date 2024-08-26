import 'package:flutter/widgets.dart';
import 'package:rpg_table_helper/screens/character_screen.dart';
import 'package:rpg_table_helper/screens/crafting_screen.dart';
import 'package:rpg_table_helper/screens/inventory_screen.dart';
import 'package:rpg_table_helper/screens/lore_screen.dart';
import 'package:rpg_table_helper/screens/search_screen.dart';

enum TabItem {
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
        return SearchScreen.route; // TODO make me
      case TabItem.character:
        return CharacterScreen.route; // TODO make me
      case TabItem.inventory:
        return InventoryScreen.route; // TODO make me
      case TabItem.crafting:
        return CraftingScreen.route; // TODO make me
      case TabItem.lore:
        return LoreScreen.route; // TODO make me
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
