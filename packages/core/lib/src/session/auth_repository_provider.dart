import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/dio_provider.dart';
import '../tenant/tenant_environment_provider.dart';
import 'auth_repository.dart';

part 'auth_repository_provider.g.dart';

/// keepAlive: holds only the app-wide Dio and the build's tenant.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(
  dio: ref.watch(dioProvider),
  tenant: ref.watch(tenantEnvironmentProvider).tenant,
);
