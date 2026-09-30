import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import 'browse_paths.dart';
import 'screens/browse_screen.dart';
import 'screens/listing_detail_screen.dart';

/// The guest's side: the list of stays and a listing's page. It belongs to
/// [AccessArea.guest], so a host never reaches it.
///
/// A listing's page is nested under the list, so it opens on top of it: the
/// list keeps its filter, pages and scroll position underneath.
final browseModule = FeatureModule(
  id: 'browse',
  area: AccessArea.guest,
  basePath: BrowsePaths.base,
  routes: [
    GoRoute(
      path: BrowsePaths.base,
      builder: (context, state) => const BrowseScreen(),
      routes: [
        GoRoute(
          path: BrowsePaths.listingRoute,
          builder: (context, state) =>
              ListingDetailScreen(listingId: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
  tab: NavTab(
    label: (context) => context.l10n.browseTab,
    icon: Icons.travel_explore,
  ),
);
