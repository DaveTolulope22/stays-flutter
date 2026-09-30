// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one place the app reads the device's date. Everything that needs "today"
/// (the date picker's first day, the availability calendar) asks this provider
/// instead of calling `DateTime.now()`, so a test overrides it with a fixed date
/// and never depends on the day it runs.
///
/// keepAlive: it holds no state, only the function.

@ProviderFor(clock)
final clockProvider = ClockProvider._();

/// The one place the app reads the device's date. Everything that needs "today"
/// (the date picker's first day, the availability calendar) asks this provider
/// instead of calling `DateTime.now()`, so a test overrides it with a fixed date
/// and never depends on the day it runs.
///
/// keepAlive: it holds no state, only the function.

final class ClockProvider
    extends $FunctionalProvider<DateClock, DateClock, DateClock>
    with $Provider<DateClock> {
  /// The one place the app reads the device's date. Everything that needs "today"
  /// (the date picker's first day, the availability calendar) asks this provider
  /// instead of calling `DateTime.now()`, so a test overrides it with a fixed date
  /// and never depends on the day it runs.
  ///
  /// keepAlive: it holds no state, only the function.
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<DateClock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateClock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateClock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateClock>(value),
    );
  }
}

String _$clockHash() => r'e15357948d1739719fa72b6ecc8470baa06e64d2';
