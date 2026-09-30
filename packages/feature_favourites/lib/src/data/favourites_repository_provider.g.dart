// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourites_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive: holds only the app-wide Dio and the build's tenant, like the
/// other repositories. It is only ever read by the favourites notifier, which
/// the shell never reaches on a tenant with favourites off.

@ProviderFor(favouritesRepository)
final favouritesRepositoryProvider = FavouritesRepositoryProvider._();

/// keepAlive: holds only the app-wide Dio and the build's tenant, like the
/// other repositories. It is only ever read by the favourites notifier, which
/// the shell never reaches on a tenant with favourites off.

final class FavouritesRepositoryProvider
    extends
        $FunctionalProvider<
          FavouritesRepository,
          FavouritesRepository,
          FavouritesRepository
        >
    with $Provider<FavouritesRepository> {
  /// keepAlive: holds only the app-wide Dio and the build's tenant, like the
  /// other repositories. It is only ever read by the favourites notifier, which
  /// the shell never reaches on a tenant with favourites off.
  FavouritesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favouritesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favouritesRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavouritesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavouritesRepository create(Ref ref) {
    return favouritesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavouritesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavouritesRepository>(value),
    );
  }
}

String _$favouritesRepositoryHash() =>
    r'48937ab3493eccab7a7c45cd2f4d58e5b15b3475';
