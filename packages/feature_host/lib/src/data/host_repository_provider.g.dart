// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive: holds only the app-wide Dio and the build's tenant, like the
/// other repositories. It is only read by host notifiers, which the shell never
/// reaches for a client or on a tenant with the host panel off.

@ProviderFor(hostRepository)
final hostRepositoryProvider = HostRepositoryProvider._();

/// keepAlive: holds only the app-wide Dio and the build's tenant, like the
/// other repositories. It is only read by host notifiers, which the shell never
/// reaches for a client or on a tenant with the host panel off.

final class HostRepositoryProvider
    extends $FunctionalProvider<HostRepository, HostRepository, HostRepository>
    with $Provider<HostRepository> {
  /// keepAlive: holds only the app-wide Dio and the build's tenant, like the
  /// other repositories. It is only read by host notifiers, which the shell never
  /// reaches for a client or on a tenant with the host panel off.
  HostRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostRepositoryHash();

  @$internal
  @override
  $ProviderElement<HostRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HostRepository create(Ref ref) {
    return hostRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HostRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HostRepository>(value),
    );
  }
}

String _$hostRepositoryHash() => r'466ac1055f9d78763231b74e6c0a3eeb6cf7fa63';
