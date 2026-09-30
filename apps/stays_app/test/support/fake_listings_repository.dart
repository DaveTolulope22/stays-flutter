import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

/// The one listing the shell tests see on the browse screen.
final shellListing = Listing(
  id: 'l1',
  tenantId: 'acme',
  hostId: 'h1',
  title: 'Test chalet',
  description: 'Quiet.',
  city: 'Davos',
  country: 'CH',
  address: 'Bergstrasse 1',
  latitude: 46.8,
  longitude: 9.8,
  propertyType: 'chalet',
  maxGuests: 4,
  bedrooms: 2,
  beds: 3,
  bathrooms: 1,
  pricePerNight: 249,
  cleaningFee: 40,
  currency: 'EUR',
  amenities: ['wifi'],
  rating: 4.5,
  reviewsCount: 3,
  images: ['https://picsum.photos/1'],
  createdAt: DateTime.utc(2026, 1, 15),
);

/// Answers every list request with [shellListing]. No network in tests.
class FakeListingsRepository extends ListingsRepository {
  FakeListingsRepository() : super(dio: Dio(), tenant: 'acme');

  @override
  TaskEither<AppFailure, CursorPage<Listing>> list(
    ListingFilter filter, {
    String? cursor,
    int limit = ListingsRepository.defaultPageSize,
  }) => TaskEither.right(CursorPage(items: [shellListing], total: 1));
}
