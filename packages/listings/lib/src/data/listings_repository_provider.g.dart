// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listings_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive: holds only the app-wide Dio and the build's tenant, like the
/// other repositories, so there is nothing to gain from rebuilding it.

@ProviderFor(listingsRepository)
final listingsRepositoryProvider = ListingsRepositoryProvider._();

/// keepAlive: holds only the app-wide Dio and the build's tenant, like the
/// other repositories, so there is nothing to gain from rebuilding it.

final class ListingsRepositoryProvider
    extends
        $FunctionalProvider<
          ListingsRepository,
          ListingsRepository,
          ListingsRepository
        >
    with $Provider<ListingsRepository> {
  /// keepAlive: holds only the app-wide Dio and the build's tenant, like the
  /// other repositories, so there is nothing to gain from rebuilding it.
  ListingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ListingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListingsRepository create(Ref ref) {
    return listingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListingsRepository>(value),
    );
  }
}

String _$listingsRepositoryHash() =>
    r'd43557035cef3acd5c1f18d121c019f7d91dd828';
