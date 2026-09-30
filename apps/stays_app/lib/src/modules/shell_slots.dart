import 'package:core/core.dart';
import 'package:feature_favourites/feature_favourites.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:listings/listings.dart';

/// Fills the listing card's save slot. Like `modulesFor`, it is decided by the
/// tenant's FLAGS only: with `favourites` off the slot stays empty, so a card
/// has no save control and no favourites provider is ever read. With it on, the
/// slot holds the button, which still checks the role itself (a host shares the
/// tenant and must not see it).
///
/// The shell does this because it is the only place that knows both `listings`
/// (the slot) and `feature_favourites` (the button).
final shellSlotOverrides = <Override>[
  listingSaveActionProvider.overrideWith((ref) {
    final favouritesOn =
        ref.watch(tenantConfigProvider).value?.flags.favourites ?? false;
    return favouritesOn ? saveActionBuilder : null;
  }),
];
