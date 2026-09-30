import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import 'favourites_paths.dart';
import 'screens/saved_screen.dart';

/// The guest's saved listings: a route and a tab. The shell registers it ONLY
/// when the tenant's `favourites` flag is on; when it is off this value is never
/// built, so there is no `/saved` route, no tab and no provider behind them.
///
/// [listingLocation] says where a listing opens. The shell passes browse's
/// location, because this package must not depend on the browse feature.
///
/// `requires` repeats the flag as a capability, so a host, who belongs to the
/// other area anyway, and anyone else without `canSaveListings` is turned away
/// by the router before the screen builds.
FeatureModule favouritesModule({
  required String Function(String listingId) listingLocation,
}) => FeatureModule(
  id: 'favourites',
  area: AccessArea.guest,
  basePath: FavouritesPaths.base,
  requires: (capabilities) => capabilities.canSaveListings,
  routes: [
    GoRoute(
      path: FavouritesPaths.base,
      builder: (context, state) =>
          SavedScreen(listingLocation: listingLocation),
    ),
  ],
  tab: NavTab(
    label: (context) => context.l10n.savedTab,
    icon: Icons.favorite_border,
  ),
);
