import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import 'browse_paths.dart';
import 'screens/browse_screen.dart';

/// The guest's side: the list of stays and, later, a listing's page. It belongs
/// to [AccessArea.guest], so a host never reaches it.
final browseModule = FeatureModule(
  id: 'browse',
  area: AccessArea.guest,
  basePath: BrowsePaths.base,
  routes: [
    GoRoute(
      path: BrowsePaths.base,
      builder: (context, state) => const BrowseScreen(),
    ),
  ],
  tab: NavTab(
    label: (context) => context.l10n.browseTab,
    icon: Icons.travel_explore,
  ),
);
