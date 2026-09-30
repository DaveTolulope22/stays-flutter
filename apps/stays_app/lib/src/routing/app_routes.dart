import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Builds the route table from the registered modules.
///
/// A module without a tab contributes its routes as they are. Tab modules are
/// grouped by area, and each area gets ONE shell (its own bottom navigation)
/// with a branch per tab, so a guest's tabs and a host's tabs never share a
/// bar, and a tab keeps its own navigation stack.
List<RouteBase> routesFor(List<FeatureModule> modules) {
  final routes = <RouteBase>[];
  final tabModulesByArea = <AccessArea, List<FeatureModule>>{};

  for (final module in modules) {
    if (module.tab == null) {
      routes.addAll(module.routes);
    } else {
      (tabModulesByArea[module.area] ??= []).add(module);
    }
  }

  for (final tabModules in tabModulesByArea.values) {
    routes.add(
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AreaShell(
          tabs: [for (final module in tabModules) module.tab!],
          shell: shell,
        ),
        branches: [
          for (final module in tabModules)
            StatefulShellBranch(routes: module.routes),
        ],
      ),
    );
  }
  return routes;
}

/// The page around an area's tabs. The bar appears only when there are at
/// least two tabs: one destination is not navigation (and Material requires
/// two), which is exactly the case for a guest on a tenant with favourites
/// switched off.
class AreaShell extends StatelessWidget {
  const AreaShell({required this.tabs, required this.shell, super.key});

  final List<NavTab> tabs;
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: tabs.length < 2
          ? null
          : NavigationBar(
              selectedIndex: shell.currentIndex,
              // Tapping the current tab returns to its first page.
              onDestinationSelected: (index) => shell.goBranch(
                index,
                initialLocation: index == shell.currentIndex,
              ),
              destinations: [
                for (final tab in tabs)
                  NavigationDestination(
                    icon: Icon(tab.icon),
                    label: tab.label(context),
                  ),
              ],
            ),
    );
  }
}
