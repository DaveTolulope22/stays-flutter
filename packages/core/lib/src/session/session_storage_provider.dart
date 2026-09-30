import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../tenant/tenant_environment_provider.dart';
import 'session_storage.dart';

part 'session_storage_provider.g.dart';

/// keepAlive: the platform channel wrapper is stateless and app-wide. Tests
/// replace it with an in-memory fake.
@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage();

/// keepAlive: one storage for the process, bound to this build's tenant.
@Riverpod(keepAlive: true)
SessionStorage sessionStorage(Ref ref) => SessionStorage(
  storage: ref.watch(secureStorageProvider),
  tenant: ref.watch(tenantEnvironmentProvider).tenant,
);
