// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_saver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Saves the edit form: one PATCH, and what happened to it.
///
/// Auto-dispose: it is the state of one open edit screen, and a failure from
/// one visit must not greet the next. The value is idle or saving, or an
/// `AsyncError` holding the `AppFailure` of the last attempt, which the screen
/// shows as one banner (the API is all or nothing, so there is no per-field
/// error to show).

@ProviderFor(ListingSaver)
final listingSaverProvider = ListingSaverProvider._();

/// Saves the edit form: one PATCH, and what happened to it.
///
/// Auto-dispose: it is the state of one open edit screen, and a failure from
/// one visit must not greet the next. The value is idle or saving, or an
/// `AsyncError` holding the `AppFailure` of the last attempt, which the screen
/// shows as one banner (the API is all or nothing, so there is no per-field
/// error to show).
final class ListingSaverProvider
    extends $NotifierProvider<ListingSaver, AsyncValue<void>> {
  /// Saves the edit form: one PATCH, and what happened to it.
  ///
  /// Auto-dispose: it is the state of one open edit screen, and a failure from
  /// one visit must not greet the next. The value is idle or saving, or an
  /// `AsyncError` holding the `AppFailure` of the last attempt, which the screen
  /// shows as one banner (the API is all or nothing, so there is no per-field
  /// error to show).
  ListingSaverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listingSaverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listingSaverHash();

  @$internal
  @override
  ListingSaver create() => ListingSaver();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$listingSaverHash() => r'272aadf700af309c0baf7de8b72f60e6f637f430';

/// Saves the edit form: one PATCH, and what happened to it.
///
/// Auto-dispose: it is the state of one open edit screen, and a failure from
/// one visit must not greet the next. The value is idle or saving, or an
/// `AsyncError` holding the `AppFailure` of the last attempt, which the screen
/// shows as one banner (the API is all or nothing, so there is no per-field
/// error to show).

abstract class _$ListingSaver extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
