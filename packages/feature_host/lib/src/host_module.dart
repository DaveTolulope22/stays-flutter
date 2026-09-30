import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import 'host_paths.dart';
import 'screens/edit_listing_screen.dart';
import 'screens/host_placeholder_screen.dart';
import 'screens/my_listings_screen.dart';

/// The host's side: their listings, and for each one its edit form, calendar and
/// bookings. It belongs to [AccessArea.host], so a client never reaches it, and
/// the router decides that from the session role on the device.
///
/// The shell registers it only when the tenant's `hostPanel` flag is on. With
/// the flag off it registers the "not available" screen instead, so none of
/// these routes exist and none of these providers is ever read.
///
/// Every listing screen is nested under the list, so it opens on top of it.
final hostModule = FeatureModule(
  id: 'host',
  area: AccessArea.host,
  basePath: HostPaths.base,
  requires: (capabilities) => capabilities.canUseHostPanel,
  routes: [
    GoRoute(
      path: HostPaths.base,
      builder: (context, state) => const MyListingsScreen(),
      routes: [
        GoRoute(
          path: HostPaths.editRoute,
          builder: (context, state) =>
              EditListingScreen(listingId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: HostPaths.calendarRoute,
          builder: (context, state) =>
              HostPlaceholderScreen(title: context.l10n.hostActionCalendar),
        ),
        GoRoute(
          path: HostPaths.bookingsRoute,
          builder: (context, state) =>
              HostPlaceholderScreen(title: context.l10n.hostActionBookings),
        ),
      ],
    ),
  ],
  tab: NavTab(
    label: (context) => context.l10n.hostListingsTab,
    icon: Icons.home_work_outlined,
  ),
);
