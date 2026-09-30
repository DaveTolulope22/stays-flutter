import 'package:core/core.dart';
import 'package:listings/listings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'booked_days.g.dart';

/// The days of ONE month that are booked on a listing: the ones a host can never
/// block. A family keyed by the listing and the month (the first day of it), so
/// each month the calendar visits is its own small request, far below the API's
/// 366-day limit.
///
/// Anything taken for a reason other than "blocked" counts, including a reason
/// this app does not know: a day we cannot explain is not one we offer to
/// change. The host's own blocks come from `HostBlockedDays`, not from here,
/// because the API reports a day that is both booked and blocked as `booked`.
///
/// Auto-dispose: a month is freed when the calendar leaves it. It does not retry
/// automatically; the calendar shows the error with a Retry button. "Today"
/// comes from the clock provider, not the device.
@Riverpod(retry: noAutomaticRetry)
Future<Set<LocalDate>> bookedDays(
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
    (availability) => {
      for (final day in availability.unavailable)
        if (day.reason != UnavailableReason.blocked) day.date,
    },
  );
}
