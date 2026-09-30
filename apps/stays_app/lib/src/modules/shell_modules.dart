import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:feature_favourites/feature_favourites.dart';
import 'package:feature_host/feature_host.dart';
import 'package:go_router/go_router.dart';

import 'host_unavailable_screen.dart';

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
    // The host area, or the screen that says it is off. Never both, and with
    // the panel off no host route or provider exists.
    if (flags.hostPanel) hostModule else hostUnavailableModule,
  ];
  validateModules(modules);
  return modules;
}
