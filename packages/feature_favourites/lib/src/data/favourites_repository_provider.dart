import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'favourites_repository.dart';

part 'favourites_repository_provider.g.dart';

/// keepAlive: holds only the app-wide Dio and the build's tenant, like the
/// other repositories. It is only ever read by the favourites notifier, which
/// the shell never reaches on a tenant with favourites off.
@Riverpod(keepAlive: true)
FavouritesRepository favouritesRepository(Ref ref) => FavouritesRepository(
  dio: ref.watch(dioProvider),
  tenant: ref.watch(tenantEnvironmentProvider).tenant,
);
