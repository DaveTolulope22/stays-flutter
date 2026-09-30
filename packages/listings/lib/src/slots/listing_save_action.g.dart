// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_save_action.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The slot for the save control on a listing card. It is empty by default, so
/// a card knows nothing about favourites. The shell fills it (with the button
/// from the favourites feature) only when the tenant's `favourites` flag is on;
/// otherwise nothing is built and no favourites provider is ever read.
///
/// keepAlive: fixed for the life of the process, overridden once at the shell.

@ProviderFor(listingSaveAction)
final listingSaveActionProvider = ListingSaveActionProvider._();

/// The slot for the save control on a listing card. It is empty by default, so
/// a card knows nothing about favourites. The shell fills it (with the button
/// from the favourites feature) only when the tenant's `favourites` flag is on;
/// otherwise nothing is built and no favourites provider is ever read.
///
/// keepAlive: fixed for the life of the process, overridden once at the shell.

final class ListingSaveActionProvider
    extends
        $FunctionalProvider<
          ListingActionBuilder?,
          ListingActionBuilder?,
          ListingActionBuilder?
        >
    with $Provider<ListingActionBuilder?> {
  /// The slot for the save control on a listing card. It is empty by default, so
  /// a card knows nothing about favourites. The shell fills it (with the button
  /// from the favourites feature) only when the tenant's `favourites` flag is on;
  /// otherwise nothing is built and no favourites provider is ever read.
  ///
  /// keepAlive: fixed for the life of the process, overridden once at the shell.
  ListingSaveActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listingSaveActionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listingSaveActionHash();

  @$internal
  @override
  $ProviderElement<ListingActionBuilder?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListingActionBuilder? create(Ref ref) {
    return listingSaveAction(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListingActionBuilder? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListingActionBuilder?>(value),
    );
  }
}

String _$listingSaveActionHash() => r'843942c0b6a5cc7a2b3519a50b139fd03a2181b6';
