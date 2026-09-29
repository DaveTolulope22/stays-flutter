// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_environment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive: the tenant is fixed for the life of the process. It throws
/// [TenantEnvironmentError] on a bad launch, which the bootstrap shows as a
/// developer error. Tests override it with a fake tenant.

@ProviderFor(tenantEnvironment)
final tenantEnvironmentProvider = TenantEnvironmentProvider._();

/// keepAlive: the tenant is fixed for the life of the process. It throws
/// [TenantEnvironmentError] on a bad launch, which the bootstrap shows as a
/// developer error. Tests override it with a fake tenant.

final class TenantEnvironmentProvider
    extends
        $FunctionalProvider<
          TenantEnvironment,
          TenantEnvironment,
          TenantEnvironment
        >
    with $Provider<TenantEnvironment> {
  /// keepAlive: the tenant is fixed for the life of the process. It throws
  /// [TenantEnvironmentError] on a bad launch, which the bootstrap shows as a
  /// developer error. Tests override it with a fake tenant.
  TenantEnvironmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenantEnvironmentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantEnvironmentHash();

  @$internal
  @override
  $ProviderElement<TenantEnvironment> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TenantEnvironment create(Ref ref) {
    return tenantEnvironment(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TenantEnvironment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TenantEnvironment>(value),
    );
  }
}

String _$tenantEnvironmentHash() => r'fcbf6efc803a875ae9b456a9eab1ff0e9233639c';
