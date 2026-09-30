import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'listings_repository.dart';

part 'listings_repository_provider.g.dart';

/// keepAlive: holds only the app-wide Dio and the build's tenant, like the
/// other repositories, so there is nothing to gain from rebuilding it.
@Riverpod(keepAlive: true)
ListingsRepository listingsRepository(Ref ref) => ListingsRepository(
  dio: ref.watch(dioProvider),
  tenant: ref.watch(tenantEnvironmentProvider).tenant,
);
