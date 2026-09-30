import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../access/capabilities.dart';

/// A bottom-navigation entry. The label is a builder because this package has
/// no copy: the feature that owns the tab supplies its localised text.
class NavTab {
  const NavTab({required this.label, required this.icon});

  final String Function(BuildContext context) label;
  final IconData icon;
}

/// Everything a feature offers to the app, in one value. Each feature package
/// exports one; only the shell knows them all, and registers them from the
/// tenant's flags. A feature that is not registered has no route, no tab and
/// no providers at all.
///
/// A module also states who may enter it, so the router's redirect is generic:
/// it asks the module that owns a location, and no path such as `/host` is
/// written into the shell.
class FeatureModule {
  FeatureModule({
    required this.id,
    required this.area,
    required this.basePath,
    required this.routes,
    this.tab,
    this.requires,
    String? initialLocation,
  }) : initialLocation = initialLocation ?? basePath,
       assert(
         basePath.startsWith('/') && basePath.length > 1,
         'basePath must start with "/" and name a section, got "$basePath".',
       ),
       assert(
         _routesUnder(routes, basePath),
         'Every top-level route of module "$id" must live under "$basePath".',
       ),
       assert(
         _isUnder(initialLocation ?? basePath, basePath),
         'The initialLocation of module "$id" must live under "$basePath".',
       );

  /// Unique across the app. Used for tab keys and diagnostics.
  final String id;

  /// The side of the app this module belongs to. [AccessArea.none] means it is
  /// reachable only while signed out (sign-in, registration).
  final AccessArea area;

  /// Every route of this module lives at or under this path.
  final String basePath;

  /// Where a user lands when the app sends them to this module. It defaults to
  /// [basePath]; a module whose base path has no page of its own (`/auth`)
  /// names its front page here.
  final String initialLocation;

  final List<RouteBase> routes;

  /// Null for a module that is reachable but not a tab.
  final NavTab? tab;

  /// An extra condition on top of [area], such as "favourites is enabled".
  final bool Function(Capabilities capabilities)? requires;

  /// True when [capabilities] belong to this module's side of the app and pass
  /// its own condition. The router sends everyone else away before any screen
  /// builds.
  bool isAllowedFor(Capabilities capabilities) =>
      capabilities.area == area && (requires?.call(capabilities) ?? true);

  /// True when [location] is this module's path or a path below it. A location
  /// may carry a query string. `/saved-items` is not under `/saved`.
  bool owns(String location) {
    final path = Uri.parse(location).path;
    return path == basePath ||
        path.startsWith(basePath.endsWith('/') ? basePath : '$basePath/');
  }

  static bool _isUnder(String path, String basePath) =>
      path == basePath || path.startsWith('$basePath/');

  static bool _routesUnder(List<RouteBase> routes, String basePath) {
    for (final route in routes) {
      if (route is! GoRoute) continue;
      if (!_isUnder(route.path, basePath)) return false;
    }
    return true;
  }
}

/// Checks a set of modules before the app uses it. Throws [StateError] on a
/// duplicate id or on two modules whose base paths overlap, because an
/// overlapping location would have two owners and the guard could pick the
/// wrong one.
void validateModules(Iterable<FeatureModule> modules) {
  final list = modules.toList();

  final seenIds = <String>{};
  for (final module in list) {
    if (!seenIds.add(module.id)) {
      throw StateError('Two feature modules share the id "${module.id}".');
    }
  }

  for (var i = 0; i < list.length; i++) {
    for (var j = i + 1; j < list.length; j++) {
      final a = list[i];
      final b = list[j];
      if (a.owns(b.basePath) || b.owns(a.basePath)) {
        throw StateError(
          'Modules "${a.id}" (${a.basePath}) and "${b.id}" (${b.basePath}) '
          'have overlapping paths.',
        );
      }
    }
  }
}
