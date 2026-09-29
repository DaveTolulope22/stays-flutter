import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'tenant_environment.dart';

part 'tenant_environment_provider.g.dart';

/// keepAlive: the tenant is fixed for the life of the process. It throws
/// [TenantEnvironmentError] on a bad launch, which the bootstrap shows as a
/// developer error. Tests override it with a fake tenant.
@Riverpod(keepAlive: true)
TenantEnvironment tenantEnvironment(Ref ref) => TenantEnvironment.fromBuild();
