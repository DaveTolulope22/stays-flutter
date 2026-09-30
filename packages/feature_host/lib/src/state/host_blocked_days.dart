import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/host_repository_provider.dart';
import 'booked_days.dart';

part 'host_blocked_days.g.dart';

/// Every day the host has closed on ONE listing, and the one way to change that.
///
/// A family keyed by the listing. The API lists blocked days for the whole
/// listing in one call (they are not paginated and there are few), so this loads
/// once and the calendar only reads from it as the month changes.
///
/// Auto-dispose: it lives while that listing's calendar is open. It does not
/// retry automatically; the calendar shows the error with a Retry button.
@Riverpod(retry: noAutomaticRetry)
class HostBlockedDays extends _$HostBlockedDays {
  /// Days with a request on their way. A second tap on the same day is ignored
  /// until the first is answered, so two requests for one day can never race.
  final _pending = <LocalDate>{};

  @override
  Future<Set<LocalDate>> build(String listingId) async {
    final result = await ref
        .watch(hostRepositoryProvider)
        .blockedDays(listingId)
        .run();
    return result.fold(
      (failure) => throw failure,
      (days) => {for (final day in days) day.date},
    );
  }

  /// Blocks [date] if it is free, unblocks it if it is blocked. The change shows
  /// at once; if the request fails it is undone for that one day and the failure
  /// is returned, so the screen can say so in our own words.
  ///
  /// It does nothing, and sends nothing, when:
  /// - blocking is switched off for this tenant or this user,
  /// - the day is before today,
  /// - the day is booked (the API would allow blocking it, but a guest's stay
  ///   cannot be closed over) or we do not know yet whether it is,
  /// - the days are not loaded, or a request for this day is still out.
  ///
  /// Both calls are idempotent on the API side, so repeating one after a
  /// rollback is safe.
  Future<Option<AppFailure>> toggle(LocalDate date) async {
    final current = state.value;
    if (current == null) return const None();
    if (!ref.read(capabilitiesProvider).canBlockDays) return const None();
    if (date < ref.read(clockProvider)()) return const None();
    if (_pending.contains(date)) return const None();
    final booked = ref
        .read(bookedDaysProvider(listingId, firstOfMonth(date)))
        .value;
    if (booked == null || booked.contains(date)) return const None();

    final wasBlocked = current.contains(date);
    _pending.add(date);
    state = AsyncData(_with(current, date, blocked: !wasBlocked));

    final repository = ref.read(hostRepositoryProvider);
    final result =
        await (wasBlocked
                ? repository.unblock(listingId, date)
                : repository.block(listingId, date))
            .run();
    _pending.remove(date);

    // The calendar closed while the request was out: nobody to tell.
    if (!ref.mounted) return const None();
    return result.fold((failure) {
      _undo(date, wasBlocked: wasBlocked);
      return Some(failure);
    }, (_) => const None());
  }

  /// Puts back only [date], as it was before the tap. Never a snapshot of the
  /// whole set: another day may have changed meanwhile and must stay changed.
  void _undo(LocalDate date, {required bool wasBlocked}) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(_with(current, date, blocked: wasBlocked));
  }

  /// A copy of [days] with [date] in it or out of it. Always a new set, so the
  /// state visibly changes.
  Set<LocalDate> _with(
    Set<LocalDate> days,
    LocalDate date, {
    required bool blocked,
  }) {
    final copy = {...days};
    if (blocked) {
      copy.add(date);
    } else {
      copy.remove(date);
    }
    return copy;
  }
}
