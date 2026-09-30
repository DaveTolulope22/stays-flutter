import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:go_router/go_router.dart';

import 'session_home_screens.dart';

/// TEMPORARY stand-ins, replaced by `browseModule` in Phase 5 and `hostModule`
/// in Phase 7. They keep the real paths (`/browse`, `/host`), so nothing
/// else changes when the real modules arrive.
final guestHomePlaceholder = FeatureModule(
  id: 'guest-home',
  area: AccessArea.guest,
  basePath: '/browse',
  routes: [
    GoRoute(
      path: '/browse',
      builder: (context, state) => const SessionHomeScreen(),
    ),
  ],
);

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
    guestHomePlaceholder,
    if (flags.hostPanel) hostHomePlaceholder else hostUnavailableModule,
  ];
  validateModules(modules);
  return modules;
}
