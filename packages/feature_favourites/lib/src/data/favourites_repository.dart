import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

/// The favourites endpoints. It only talks to the API; the flag that decides
/// whether favourites exist is applied by the shell, so this is never built on
/// a tenant that has them off.
///
/// Adding twice and removing something that is not there are both fine for the
/// API, so a repeat after a rolled-back toggle is safe.
class FavouritesRepository {
  const FavouritesRepository({required this.dio, required this.tenant});

  final Dio dio;
  final String tenant;

  /// Everything the signed-in user saved. Not paginated. A row of another
  /// tenant becomes a [TenantMismatchFailure] and nothing is handed on.
  TaskEither<AppFailure, List<Listing>> list() => apiCall(() async {
    final response = await dio.get<List<dynamic>>('/favourites');
    return [
      for (final row in response.data!)
        Listing.fromJson(row as Map<String, dynamic>),
    ];
  }).flatMap(
    (listings) => listings.every((listing) => listing.tenantId == tenant)
        ? TaskEither.right(listings)
        : TaskEither.left(const TenantMismatchFailure()),
  );

  TaskEither<AppFailure, Unit> add(String listingId) => apiCall(() async {
    await dio.post<void>('/favourites', data: {'listingId': listingId});
    return unit;
  });

  TaskEither<AppFailure, Unit> remove(String listingId) => apiCall(() async {
    await dio.delete<void>('/favourites/${Uri.encodeComponent(listingId)}');
    return unit;
  });
}
