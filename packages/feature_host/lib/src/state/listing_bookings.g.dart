// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_bookings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The pages of bookings on ONE listing, for ONE status filter (null: all).
///
/// A family keyed by the listing and the filter: each distinct filter gets its
/// own notifier with its own pages, so changing the filter starts a fresh list
/// and a slow response for the old filter can never end up in the new one.
///
/// Auto-dispose: pages live only while the bookings screen watches this filter.
/// It does not retry automatically; the screen shows the error with a Retry
/// button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.

@ProviderFor(ListingBookings)
final listingBookingsProvider = ListingBookingsFamily._();

/// The pages of bookings on ONE listing, for ONE status filter (null: all).
///
/// A family keyed by the listing and the filter: each distinct filter gets its
/// own notifier with its own pages, so changing the filter starts a fresh list
/// and a slow response for the old filter can never end up in the new one.
///
/// Auto-dispose: pages live only while the bookings screen watches this filter.
/// It does not retry automatically; the screen shows the error with a Retry
/// button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.
final class ListingBookingsProvider
    extends $AsyncNotifierProvider<ListingBookings, PagedState<Booking>> {
  /// The pages of bookings on ONE listing, for ONE status filter (null: all).
  ///
  /// A family keyed by the listing and the filter: each distinct filter gets its
  /// own notifier with its own pages, so changing the filter starts a fresh list
  /// and a slow response for the old filter can never end up in the new one.
  ///
  /// Auto-dispose: pages live only while the bookings screen watches this filter.
  /// It does not retry automatically; the screen shows the error with a Retry
  /// button.
  ///
  /// The value is `AsyncData(PagedState)`. The first page failing is an
  /// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
  /// and sets `loadMoreError` instead.
  ListingBookingsProvider._({
    required ListingBookingsFamily super.from,
    required (String, BookingStatus?) super.argument,
  }) : super(
         retry: noAutomaticRetry,
         name: r'listingBookingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingBookingsHash();

  @override
  String toString() {
    return r'listingBookingsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ListingBookings create() => ListingBookings();

  @override
  bool operator ==(Object other) {
    return other is ListingBookingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingBookingsHash() => r'd78f3beb5178730b3be620400a630ae6807fea95';

/// The pages of bookings on ONE listing, for ONE status filter (null: all).
///
/// A family keyed by the listing and the filter: each distinct filter gets its
/// own notifier with its own pages, so changing the filter starts a fresh list
/// and a slow response for the old filter can never end up in the new one.
///
/// Auto-dispose: pages live only while the bookings screen watches this filter.
/// It does not retry automatically; the screen shows the error with a Retry
/// button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.

final class ListingBookingsFamily extends $Family
    with
        $ClassFamilyOverride<
          ListingBookings,
          AsyncValue<PagedState<Booking>>,
          PagedState<Booking>,
          FutureOr<PagedState<Booking>>,
          (String, BookingStatus?)
        > {
  ListingBookingsFamily._()
    : super(
        retry: noAutomaticRetry,
        name: r'listingBookingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The pages of bookings on ONE listing, for ONE status filter (null: all).
  ///
  /// A family keyed by the listing and the filter: each distinct filter gets its
  /// own notifier with its own pages, so changing the filter starts a fresh list
  /// and a slow response for the old filter can never end up in the new one.
  ///
  /// Auto-dispose: pages live only while the bookings screen watches this filter.
  /// It does not retry automatically; the screen shows the error with a Retry
  /// button.
  ///
  /// The value is `AsyncData(PagedState)`. The first page failing is an
  /// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
  /// and sets `loadMoreError` instead.

  ListingBookingsProvider call(String listingId, BookingStatus? status) =>
      ListingBookingsProvider._(argument: (listingId, status), from: this);

  @override
  String toString() => r'listingBookingsProvider';
}

/// The pages of bookings on ONE listing, for ONE status filter (null: all).
///
/// A family keyed by the listing and the filter: each distinct filter gets its
/// own notifier with its own pages, so changing the filter starts a fresh list
/// and a slow response for the old filter can never end up in the new one.
///
/// Auto-dispose: pages live only while the bookings screen watches this filter.
/// It does not retry automatically; the screen shows the error with a Retry
/// button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.

abstract class _$ListingBookings extends $AsyncNotifier<PagedState<Booking>> {
  late final _$args = ref.$arg as (String, BookingStatus?);
  String get listingId => _$args.$1;
  BookingStatus? get status => _$args.$2;

  FutureOr<PagedState<Booking>> build(String listingId, BookingStatus? status);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PagedState<Booking>>, PagedState<Booking>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedState<Booking>>, PagedState<Booking>>,
              AsyncValue<PagedState<Booking>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
