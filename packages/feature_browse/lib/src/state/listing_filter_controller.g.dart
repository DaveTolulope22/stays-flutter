// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The filter the browse list is showing right now.
///
/// Auto-dispose: it lives exactly as long as the browse screen listens to it.
/// Opening a listing pushes a screen ON TOP of browse, so the screen stays in
/// the navigation stack, is still listening, and the filter survives. Leaving
/// the browse branch for good disposes it and the next visit starts unfiltered.
///
/// The filter sheet edits its own draft and calls [apply] once, so the list
/// reloads on "Show results" and not on every slider tick.

@ProviderFor(ListingFilterController)
final listingFilterControllerProvider = ListingFilterControllerProvider._();

/// The filter the browse list is showing right now.
///
/// Auto-dispose: it lives exactly as long as the browse screen listens to it.
/// Opening a listing pushes a screen ON TOP of browse, so the screen stays in
/// the navigation stack, is still listening, and the filter survives. Leaving
/// the browse branch for good disposes it and the next visit starts unfiltered.
///
/// The filter sheet edits its own draft and calls [apply] once, so the list
/// reloads on "Show results" and not on every slider tick.
final class ListingFilterControllerProvider
    extends $NotifierProvider<ListingFilterController, ListingFilter> {
  /// The filter the browse list is showing right now.
  ///
  /// Auto-dispose: it lives exactly as long as the browse screen listens to it.
  /// Opening a listing pushes a screen ON TOP of browse, so the screen stays in
  /// the navigation stack, is still listening, and the filter survives. Leaving
  /// the browse branch for good disposes it and the next visit starts unfiltered.
  ///
  /// The filter sheet edits its own draft and calls [apply] once, so the list
  /// reloads on "Show results" and not on every slider tick.
  ListingFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listingFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listingFilterControllerHash();

  @$internal
  @override
  ListingFilterController create() => ListingFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListingFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListingFilter>(value),
    );
  }
}

String _$listingFilterControllerHash() =>
    r'824469f529d46053f9171a5759c115ef2bc8cbc0';

/// The filter the browse list is showing right now.
///
/// Auto-dispose: it lives exactly as long as the browse screen listens to it.
/// Opening a listing pushes a screen ON TOP of browse, so the screen stays in
/// the navigation stack, is still listening, and the filter survives. Leaving
/// the browse branch for good disposes it and the next visit starts unfiltered.
///
/// The filter sheet edits its own draft and calls [apply] once, so the list
/// reloads on "Show results" and not on every slider tick.

abstract class _$ListingFilterController extends $Notifier<ListingFilter> {
  ListingFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ListingFilter, ListingFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ListingFilter, ListingFilter>,
              ListingFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
