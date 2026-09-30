import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/listing.dart';

part 'listing_save_action.g.dart';

/// Builds an action widget for one listing, such as the save button.
typedef ListingActionBuilder = Widget Function(Listing listing);

/// The slot for the save control on a listing card. It is empty by default, so
/// a card knows nothing about favourites. The shell fills it (with the button
/// from the favourites feature) only when the tenant's `favourites` flag is on;
/// otherwise nothing is built and no favourites provider is ever read.
///
/// keepAlive: fixed for the life of the process, overridden once at the shell.
@Riverpod(keepAlive: true)
ListingActionBuilder? listingSaveAction(Ref ref) => null;
