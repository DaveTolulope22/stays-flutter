import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'host_repository.dart';

part 'host_repository_provider.g.dart';

/// keepAlive: holds only the app-wide Dio and the build's tenant, like the
/// other repositories. It is only read by host notifiers, which the shell never
/// reaches for a client or on a tenant with the host panel off.
@Riverpod(keepAlive: true)
HostRepository hostRepository(Ref ref) => HostRepository(
  dio: ref.watch(dioProvider),
  tenant: ref.watch(tenantEnvironmentProvider).tenant,
);
