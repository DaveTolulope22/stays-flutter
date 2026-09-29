import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/dio_provider.dart';
import 'tenant_config.dart';
import 'tenant_config_repository.dart';
import 'tenant_environment_provider.dart';

part 'tenant_config_provider.g.dart';

/// Riverpod 3 retries a failed provider forever by default. The boot screen
/// has its own Retry button, so this one must fail once and show the error.
Duration? _noAutomaticRetry(int retryCount, Object error) => null;

/// keepAlive: the repository holds only the app-wide Dio.
@Riverpod(keepAlive: true)
TenantConfigRepository tenantConfigRepository(Ref ref) =>
    TenantConfigRepository(ref.watch(dioProvider));

/// keepAlive: the runtime config is loaded once and read by the theme, the
/// locale setup, the router and the capabilities for the life of the process.
/// A failure surfaces as `AsyncError` holding the `AppFailure`; retry with
/// `ref.invalidate(tenantConfigProvider)`.
@Riverpod(keepAlive: true, retry: _noAutomaticRetry)
Future<TenantConfig> tenantConfig(Ref ref) async {
  final tenant = ref.watch(tenantEnvironmentProvider).tenant;
  final result = await ref
      .watch(tenantConfigRepositoryProvider)
      .fetch(tenant)
      .run();
  return result.fold((failure) => throw failure, (config) => config);
}
