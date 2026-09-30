import 'package:core/core.dart';
import 'package:listings/listings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'listing_facets_provider.g.dart';

/// What the filter sheet builds itself from: cities, guest maximum and price
/// bounds with their currency. Nothing about them is hardcoded.
///
/// Auto-dispose, but the browse screen listens to it, so it is fetched once when
/// browsing starts (the sheet opens instantly) and freed with the screen. A
/// failure surfaces in the sheet with Retry; it does not retry automatically.
@Riverpod(retry: noAutomaticRetry)
Future<ListingFacets> listingFacets(Ref ref) async {
  final result = await ref.watch(listingsRepositoryProvider).facets().run();
  return result.fold((failure) => throw failure, (facets) => facets);
}
