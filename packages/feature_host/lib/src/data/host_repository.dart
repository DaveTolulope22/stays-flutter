import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

import '../models/blocked_day.dart';
import '../models/booking.dart';
import '../models/listing_patch.dart';

/// The `/host` endpoints. It only talks to the API. A client never reaches it:
/// the router keeps clients out of the host area, decided from the session
/// role, so this never waits for a 403 to find out.
///
/// Blocking a day twice and unblocking a free day are both fine for the API, so
/// a repeat after a rolled-back toggle is safe.
class HostRepository {
  const HostRepository({required this.dio, required this.tenant});

  static const defaultPageSize = 20;

  final Dio dio;
  final String tenant;

  /// One page of the signed-in host's own listings. [cursor] is exactly what the
  /// previous page returned, or null for the first page.
  TaskEither<AppFailure, CursorPage<Listing>> listings({
    String? cursor,
    int limit = defaultPageSize,
  }) => apiCall(() async {
    final response = await dio.get<List<dynamic>>(
      '/host/listings',
      queryParameters: {'limit': limit, 'nextCursor': ?cursor},
    );
    return CursorPage.fromResponse(response, Listing.fromJson);
  }).flatMap(_ownTenantListings);

  /// One page of bookings on [listingId], newest check-in first. A null
  /// [status] means all of them: the parameter is left out, not sent empty.
  TaskEither<AppFailure, CursorPage<Booking>> bookings(
    String listingId, {
    BookingStatus? status,
    String? cursor,
    int limit = defaultPageSize,
  }) {
    assert(
      status != BookingStatus.unknown,
      'unknown is a decoding fallback, not a filter',
    );
    return apiCall(() async {
      final response = await dio.get<List<dynamic>>(
        '/host/listings/${Uri.encodeComponent(listingId)}/bookings',
        queryParameters: {
          'status': ?status?.name,
          'limit': limit,
          'nextCursor': ?cursor,
        },
      );
      return CursorPage.fromResponse(response, Booking.fromJson);
    }).flatMap(
      (page) => page.items.every((booking) => booking.tenantId == tenant)
          ? TaskEither.right(page)
          : TaskEither.left(const TenantMismatchFailure()),
    );
  }

  /// Every day the host closed on [listingId]. Not paginated.
  TaskEither<AppFailure, List<BlockedDay>> blockedDays(String listingId) =>
      apiCall(() async {
        final response = await dio.get<List<dynamic>>(
          '/host/listings/${Uri.encodeComponent(listingId)}/blocked-days',
        );
        return [
          for (final row in response.data!)
            BlockedDay.fromJson(row as Map<String, dynamic>),
        ];
      });

  TaskEither<AppFailure, Unit> block(String listingId, LocalDate date) =>
      apiCall(() async {
        await dio.post<void>(
          '/host/listings/${Uri.encodeComponent(listingId)}/blocked-days',
          data: {'date': date.toIso()},
        );
        return unit;
      });

  TaskEither<AppFailure, Unit> unblock(String listingId, LocalDate date) =>
      apiCall(() async {
        await dio.delete<void>(
          '/host/listings/${Uri.encodeComponent(listingId)}'
          '/blocked-days/${date.toIso()}',
        );
        return unit;
      });

  /// Sends only what [patch] holds and returns the listing as the API now has
  /// it. All or nothing: if any field is rejected, none is applied.
  TaskEither<AppFailure, Listing> update(String listingId, ListingPatch patch) =>
      apiCall(() async {
        final response = await dio.patch<Map<String, dynamic>>(
          '/host/listings/${Uri.encodeComponent(listingId)}',
          data: patch.toJson(),
        );
        return Listing.fromJson(response.data!);
      }).flatMap(
        (listing) => listing.tenantId == tenant
            ? TaskEither.right(listing)
            : TaskEither.left(const TenantMismatchFailure()),
      );

  TaskEither<AppFailure, CursorPage<Listing>> _ownTenantListings(
    CursorPage<Listing> page,
  ) => page.items.every((listing) => listing.tenantId == tenant)
      ? TaskEither.right(page)
      : TaskEither.left(const TenantMismatchFailure());
}
