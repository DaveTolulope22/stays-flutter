// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive: the repository holds only the app-wide Dio.

@ProviderFor(tenantConfigRepository)
final tenantConfigRepositoryProvider = TenantConfigRepositoryProvider._();

/// keepAlive: the repository holds only the app-wide Dio.

final class TenantConfigRepositoryProvider
    extends
        $FunctionalProvider<
          TenantConfigRepository,
          TenantConfigRepository,
          TenantConfigRepository
        >
    with $Provider<TenantConfigRepository> {
  /// keepAlive: the repository holds only the app-wide Dio.
  TenantConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenantConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<TenantConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TenantConfigRepository create(Ref ref) {
    return tenantConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TenantConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TenantConfigRepository>(value),
    );
  }
}

String _$tenantConfigRepositoryHash() =>
    r'fdb5d9284d7ce5b82bdf34a29651c98ffdd52644';

/// keepAlive: the runtime config is loaded once and read by the theme, the
/// locale setup, the router and the capabilities for the life of the process.
/// A failure surfaces as `AsyncError` holding the `AppFailure`; retry with
/// `ref.invalidate(tenantConfigProvider)`. The boot screen has its own Retry,
/// so it fails once (no automatic retry).

@ProviderFor(tenantConfig)
final tenantConfigProvider = TenantConfigProvider._();

/// keepAlive: the runtime config is loaded once and read by the theme, the
/// locale setup, the router and the capabilities for the life of the process.
/// A failure surfaces as `AsyncError` holding the `AppFailure`; retry with
/// `ref.invalidate(tenantConfigProvider)`. The boot screen has its own Retry,
/// so it fails once (no automatic retry).

final class TenantConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<TenantConfig>,
          TenantConfig,
          FutureOr<TenantConfig>
        >
    with $FutureModifier<TenantConfig>, $FutureProvider<TenantConfig> {
  /// keepAlive: the runtime config is loaded once and read by the theme, the
  /// locale setup, the router and the capabilities for the life of the process.
  /// A failure surfaces as `AsyncError` holding the `AppFailure`; retry with
  /// `ref.invalidate(tenantConfigProvider)`. The boot screen has its own Retry,
  /// so it fails once (no automatic retry).
  TenantConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: noAutomaticRetry,
        name: r'tenantConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantConfigHash();

  @$internal
  @override
  $FutureProviderElement<TenantConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TenantConfig> create(Ref ref) {
    return tenantConfig(ref);
  }
}

String _$tenantConfigHash() => r'a8217c5a96d6896a6047d0dcade25336c149607f';
