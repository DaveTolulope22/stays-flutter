// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_availability_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The taken days of ONE month of a listing. A family keyed by the listing and
/// the month (the first day of it), so each month the calendar visits is its own
/// small request, far below the API's 366-day limit.
///
/// Auto-dispose: a month is freed when the calendar leaves it, so going back to
/// it asks again. It does not retry automatically; the calendar shows the error
/// with a Retry button. "Today" comes from the clock provider, not the device.

@ProviderFor(listingAvailability)
final listingAvailabilityProvider = ListingAvailabilityFamily._();

/// The taken days of ONE month of a listing. A family keyed by the listing and
/// the month (the first day of it), so each month the calendar visits is its own
/// small request, far below the API's 366-day limit.
///
/// Auto-dispose: a month is freed when the calendar leaves it, so going back to
/// it asks again. It does not retry automatically; the calendar shows the error
/// with a Retry button. "Today" comes from the clock provider, not the device.

final class ListingAvailabilityProvider
    extends
        $FunctionalProvider<
          AsyncValue<Availability>,
          Availability,
          FutureOr<Availability>
        >
    with $FutureModifier<Availability>, $FutureProvider<Availability> {
  /// The taken days of ONE month of a listing. A family keyed by the listing and
  /// the month (the first day of it), so each month the calendar visits is its own
  /// small request, far below the API's 366-day limit.
  ///
  /// Auto-dispose: a month is freed when the calendar leaves it, so going back to
  /// it asks again. It does not retry automatically; the calendar shows the error
  /// with a Retry button. "Today" comes from the clock provider, not the device.
  ListingAvailabilityProvider._({
    required ListingAvailabilityFamily super.from,
    required (String, LocalDate) super.argument,
  }) : super(
         retry: noAutomaticRetry,
         name: r'listingAvailabilityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingAvailabilityHash();

  @override
  String toString() {
    return r'listingAvailabilityProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Availability> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Availability> create(Ref ref) {
    final argument = this.argument as (String, LocalDate);
    return listingAvailability(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingAvailabilityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingAvailabilityHash() =>
    r'045e6b52ea4f17fc4e000d6a60b92bb21e94f4a1';

/// The taken days of ONE month of a listing. A family keyed by the listing and
/// the month (the first day of it), so each month the calendar visits is its own
/// small request, far below the API's 366-day limit.
///
/// Auto-dispose: a month is freed when the calendar leaves it, so going back to
/// it asks again. It does not retry automatically; the calendar shows the error
/// with a Retry button. "Today" comes from the clock provider, not the device.

final class ListingAvailabilityFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<Availability>, (String, LocalDate)> {
  ListingAvailabilityFamily._()
    : super(
        retry: noAutomaticRetry,
        name: r'listingAvailabilityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The taken days of ONE month of a listing. A family keyed by the listing and
  /// the month (the first day of it), so each month the calendar visits is its own
  /// small request, far below the API's 366-day limit.
  ///
  /// Auto-dispose: a month is freed when the calendar leaves it, so going back to
  /// it asks again. It does not retry automatically; the calendar shows the error
  /// with a Retry button. "Today" comes from the clock provider, not the device.

  ListingAvailabilityProvider call(String listingId, LocalDate month) =>
      ListingAvailabilityProvider._(argument: (listingId, month), from: this);

  @override
  String toString() => r'listingAvailabilityProvider';
}
