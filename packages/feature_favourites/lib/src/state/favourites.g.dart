// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourites.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The listings the signed-in user saved. The save buttons and the Saved screen
/// all read this one list, so they always agree.
///
/// keepAlive, but tied to the user: it watches the signed-in user's id, so
/// signing out or in as someone else rebuilds it from scratch and one account
/// never sees another's list. It lives as long as a session, not as long as a
/// screen, so a toggle in flight survives its card scrolling away. It does not
/// retry automatically; the Saved screen shows the error with a Retry button.
///
/// It is created only when something reads it. On a tenant with favourites off,
/// and for a host, nothing does.

@ProviderFor(Favourites)
final favouritesProvider = FavouritesProvider._();

/// The listings the signed-in user saved. The save buttons and the Saved screen
/// all read this one list, so they always agree.
///
/// keepAlive, but tied to the user: it watches the signed-in user's id, so
/// signing out or in as someone else rebuilds it from scratch and one account
/// never sees another's list. It lives as long as a session, not as long as a
/// screen, so a toggle in flight survives its card scrolling away. It does not
/// retry automatically; the Saved screen shows the error with a Retry button.
///
/// It is created only when something reads it. On a tenant with favourites off,
/// and for a host, nothing does.
final class FavouritesProvider
    extends $AsyncNotifierProvider<Favourites, List<Listing>> {
  /// The listings the signed-in user saved. The save buttons and the Saved screen
  /// all read this one list, so they always agree.
  ///
  /// keepAlive, but tied to the user: it watches the signed-in user's id, so
  /// signing out or in as someone else rebuilds it from scratch and one account
  /// never sees another's list. It lives as long as a session, not as long as a
  /// screen, so a toggle in flight survives its card scrolling away. It does not
  /// retry automatically; the Saved screen shows the error with a Retry button.
  ///
  /// It is created only when something reads it. On a tenant with favourites off,
  /// and for a host, nothing does.
  FavouritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: noAutomaticRetry,
        name: r'favouritesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favouritesHash();

  @$internal
  @override
  Favourites create() => Favourites();
}

String _$favouritesHash() => r'7fbd6c973c469c9313d2d1bdb78e776cc08b94a5';

/// The listings the signed-in user saved. The save buttons and the Saved screen
/// all read this one list, so they always agree.
///
/// keepAlive, but tied to the user: it watches the signed-in user's id, so
/// signing out or in as someone else rebuilds it from scratch and one account
/// never sees another's list. It lives as long as a session, not as long as a
/// screen, so a toggle in flight survives its card scrolling away. It does not
/// retry automatically; the Saved screen shows the error with a Retry button.
///
/// It is created only when something reads it. On a tenant with favourites off,
/// and for a host, nothing does.

abstract class _$Favourites extends $AsyncNotifier<List<Listing>> {
  FutureOr<List<Listing>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Listing>>, List<Listing>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Listing>>, List<Listing>>,
              AsyncValue<List<Listing>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
