import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../filter/listing_filter.dart';
import '../models/availability.dart';
import '../models/listing.dart';
import '../models/listing_facets.dart';

/// The public listing endpoints. It only talks to the API; what to show, and
/// when to ask again, belongs to the notifiers.
///
/// Every listing that comes back is checked against the build's tenant. A row
/// of another tenant becomes a [TenantMismatchFailure] and is never handed on.
class ListingsRepository {
  const ListingsRepository({required this.dio, required this.tenant});

  static const defaultPageSize = 20;

  /// The API answers 400 `error.rangeTooLong` beyond this many days.
  static const maxAvailabilityDays = 366;

  final Dio dio;
  final String tenant;

  /// One page. [cursor] is exactly what the previous page returned, or null for
  /// the first page; it is never built or decoded here.
  TaskEither<AppFailure, CursorPage<Listing>> list(
    ListingFilter filter, {
    String? cursor,
    int limit = defaultPageSize,
  }) => apiCall(() async {
    final response = await dio.get<List<dynamic>>(
      '/listings',
      queryParameters: {
        ...filter.toQueryParameters(),
        'limit': limit,
        'nextCursor': ?cursor,
      },
    );
    return CursorPage.fromResponse(response, Listing.fromJson);
  }).flatMap(_ownTenantPage);

  TaskEither<AppFailure, Listing> detail(String id) => apiCall(() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/listings/${Uri.encodeComponent(id)}',
    );
    return Listing.fromJson(response.data!);
  }).flatMap(_ownTenant);

  TaskEither<AppFailure, ListingFacets> facets() => apiCall(() async {
    final response = await dio.get<Map<String, dynamic>>('/listings/facets');
    return ListingFacets.fromJson(response.data!);
  });

  /// The taken days inside [window], which is half-open like every date range
  /// here: the last night is the day before `window.end`.
  TaskEither<AppFailure, Availability> availability(
    String listingId,
    DateRange window,
  ) {
    assert(
      window.nights > 0 && window.nights <= maxAvailabilityDays,
      'The availability window must be 1 to $maxAvailabilityDays nights, '
      'got ${window.nights}.',
    );
    return apiCall(() async {
      final response = await dio.get<Map<String, dynamic>>(
        '/listings/${Uri.encodeComponent(listingId)}/availability',
        queryParameters: {
          'from': window.start.toIso(),
          'to': window.end.toIso(),
        },
      );
      return Availability.fromJson(response.data!);
    });
  }

  TaskEither<AppFailure, Listing> _ownTenant(Listing listing) =>
      listing.tenantId == tenant
      ? TaskEither.right(listing)
      : TaskEither.left(const TenantMismatchFailure());

  TaskEither<AppFailure, CursorPage<Listing>> _ownTenantPage(
    CursorPage<Listing> page,
  ) => page.items.every((listing) => listing.tenantId == tenant)
      ? TaskEither.right(page)
      : TaskEither.left(const TenantMismatchFailure());
}
