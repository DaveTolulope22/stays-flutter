// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One listing, fetched by id.
///
/// Always fetched, even though the list already had the data: a deep link or a
/// restarted app has no card to take it from, and one code path keeps the data
/// fresh. A family keyed by the id, so each listing has its own state.
///
/// Auto-dispose: freed when the screen goes. It does not retry automatically;
/// the screen shows the error with a Retry button. A 404 (another tenant's
/// listing answers 404 too) arrives as a `NotFoundFailure`.

@ProviderFor(listingDetail)
final listingDetailProvider = ListingDetailFamily._();

/// One listing, fetched by id.
///
/// Always fetched, even though the list already had the data: a deep link or a
/// restarted app has no card to take it from, and one code path keeps the data
/// fresh. A family keyed by the id, so each listing has its own state.
///
/// Auto-dispose: freed when the screen goes. It does not retry automatically;
/// the screen shows the error with a Retry button. A 404 (another tenant's
/// listing answers 404 too) arrives as a `NotFoundFailure`.

final class ListingDetailProvider
    extends $FunctionalProvider<AsyncValue<Listing>, Listing, FutureOr<Listing>>
    with $FutureModifier<Listing>, $FutureProvider<Listing> {
  /// One listing, fetched by id.
  ///
  /// Always fetched, even though the list already had the data: a deep link or a
  /// restarted app has no card to take it from, and one code path keeps the data
  /// fresh. A family keyed by the id, so each listing has its own state.
  ///
  /// Auto-dispose: freed when the screen goes. It does not retry automatically;
  /// the screen shows the error with a Retry button. A 404 (another tenant's
  /// listing answers 404 too) arrives as a `NotFoundFailure`.
  ListingDetailProvider._({
    required ListingDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: noAutomaticRetry,
         name: r'listingDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingDetailHash();

  @override
  String toString() {
    return r'listingDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Listing> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Listing> create(Ref ref) {
    final argument = this.argument as String;
    return listingDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingDetailHash() => r'0d4cdf0b09b75d98ee421922e8fef3478269da55';

/// One listing, fetched by id.
///
/// Always fetched, even though the list already had the data: a deep link or a
/// restarted app has no card to take it from, and one code path keeps the data
/// fresh. A family keyed by the id, so each listing has its own state.
///
/// Auto-dispose: freed when the screen goes. It does not retry automatically;
/// the screen shows the error with a Retry button. A 404 (another tenant's
/// listing answers 404 too) arrives as a `NotFoundFailure`.

final class ListingDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Listing>, String> {
  ListingDetailFamily._()
    : super(
        retry: noAutomaticRetry,
        name: r'listingDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One listing, fetched by id.
  ///
  /// Always fetched, even though the list already had the data: a deep link or a
  /// restarted app has no card to take it from, and one code path keeps the data
  /// fresh. A family keyed by the id, so each listing has its own state.
  ///
  /// Auto-dispose: freed when the screen goes. It does not retry automatically;
  /// the screen shows the error with a Retry button. A 404 (another tenant's
  /// listing answers 404 too) arrives as a `NotFoundFailure`.

  ListingDetailProvider call(String id) =>
      ListingDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'listingDetailProvider';
}
