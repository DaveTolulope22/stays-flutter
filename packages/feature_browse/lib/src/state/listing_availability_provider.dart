import 'package:core/core.dart';
import 'package:listings/listings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'listing_availability_provider.g.dart';

/// The taken days of ONE month of a listing. A family keyed by the listing and
/// the month (the first day of it), so each month the calendar visits is its own
/// small request, far below the API's 366-day limit.
///
/// Auto-dispose: a month is freed when the calendar leaves it, so going back to
/// it asks again. It does not retry automatically; the calendar shows the error
/// with a Retry button. "Today" comes from the clock provider, not the device.
@Riverpod(retry: noAutomaticRetry)
Future<Availability> listingAvailability(
  Ref ref,
  String listingId,
  LocalDate month,
) async {
  final today = ref.read(clockProvider)();
  final result = await ref
      .watch(listingsRepositoryProvider)
      .availability(listingId, availabilityWindow(month, today))
      .run();
  return result.fold(
    (failure) => throw failure,
    (availability) => availability,
  );
}
