import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:feature_favourites/feature_favourites.dart';
import 'package:go_router/go_router.dart';

import 'session_home_screens.dart';

/// TEMPORARY stand-in, replaced by `hostModule` in Phase 7. It keeps the real
/// path (`/host`), so nothing else changes when the real module arrives.
final hostHomePlaceholder = FeatureModule(
  id: 'host-home',
  area: AccessArea.host,
  basePath: '/host',
  routes: [
    GoRoute(
      path: '/host',
      builder: (context, state) => const SessionHomeScreen(),
    ),
  ],
);

/// Registered INSTEAD of the host area when the tenant's `hostPanel` flag is
/// off. It belongs to the host side, so a host lands here and never falls
/// through to browsing. The shell owns it because it exists only to say that a
/// feature is switched off.
final hostUnavailableModule = FeatureModule(
  id: 'host-unavailable',
  area: AccessArea.host,
  basePath: '/host-unavailable',
  routes: [
    GoRoute(
      path: '/host-unavailable',
      builder: (context, state) => const HostUnavailableScreen(),
    ),
  ],
);

/// The modules this tenant's build offers, decided by its FLAGS ONLY: fixed
/// for the life of the process, never derived from who is signed in. Who may
/// enter each one is the router's redirect, which asks the module.
///
/// Order matters: the first module a user may enter is their home.
List<FeatureModule> modulesFor(TenantFlags flags) {
  final modules = [
    authModule,
    browseModule,
    // Only when the tenant has favourites on. Off, this is never built: no
    // route, no tab, and nothing that reads the favourites provider.
    if (flags.favourites)
      favouritesModule(listingLocation: BrowsePaths.listing),
    if (flags.hostPanel) hostHomePlaceholder else hostUnavailableModule,
  ];
  validateModules(modules);
  return modules;
}
