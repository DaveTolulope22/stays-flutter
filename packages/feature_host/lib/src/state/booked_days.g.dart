// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booked_days.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(bookedDays)
final bookedDaysProvider = BookedDaysFamily._();

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

final class BookedDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<LocalDate>>,
          Set<LocalDate>,
          FutureOr<Set<LocalDate>>
        >
    with $FutureModifier<Set<LocalDate>>, $FutureProvider<Set<LocalDate>> {
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
  BookedDaysProvider._({
    required BookedDaysFamily super.from,
    required (String, LocalDate) super.argument,
  }) : super(
         retry: noAutomaticRetry,
         name: r'bookedDaysProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookedDaysHash();

  @override
  String toString() {
    return r'bookedDaysProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Set<LocalDate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<LocalDate>> create(Ref ref) {
    final argument = this.argument as (String, LocalDate);
    return bookedDays(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is BookedDaysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookedDaysHash() => r'45f6dc15f69b20b83ba5641a1c37023932c9f18a';

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

final class BookedDaysFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Set<LocalDate>>,
          (String, LocalDate)
        > {
  BookedDaysFamily._()
    : super(
        retry: noAutomaticRetry,
        name: r'bookedDaysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  BookedDaysProvider call(String listingId, LocalDate month) =>
      BookedDaysProvider._(argument: (listingId, month), from: this);

  @override
  String toString() => r'bookedDaysProvider';
}
