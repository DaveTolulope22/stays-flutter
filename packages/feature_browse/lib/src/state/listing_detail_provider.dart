import 'package:core/core.dart';
import 'package:listings/listings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'listing_detail_provider.g.dart';

/// One listing, fetched by id.
///
/// Always fetched, even though the list already had the data: a deep link or a
/// restarted app has no card to take it from, and one code path keeps the data
/// fresh. A family keyed by the id, so each listing has its own state.
///
/// Auto-dispose: freed when the screen goes. It does not retry automatically;
/// the screen shows the error with a Retry button. A 404 (another tenant's
/// listing answers 404 too) arrives as a `NotFoundFailure`.
@Riverpod(retry: noAutomaticRetry)
Future<Listing> listingDetail(Ref ref, String id) async {
  final result = await ref.watch(listingsRepositoryProvider).detail(id).run();
  return result.fold((failure) => throw failure, (listing) => listing);
}
