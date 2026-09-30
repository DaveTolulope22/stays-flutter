import 'package:feature_host/src/data/host_repository.dart';
import 'package:listings/listings.dart';
import 'package:mocktail/mocktail.dart';

const testTenant = 'acme';

/// A listing row as the API sends it; only what the tests vary is a parameter.
Map<String, dynamic> listingRow(String id, {String tenantId = testTenant}) => {
  'id': id,
  'tenantId': tenantId,
  'hostId': 'h1',
  'title': 'Chalet $id',
  'description': 'Quiet.',
  'city': 'Davos',
  'country': 'CH',
  'address': 'Bergstrasse 1',
  'latitude': 46.8,
  'longitude': 9.8,
  'propertyType': 'chalet',
  'maxGuests': 4,
  'bedrooms': 2,
  'beds': 3,
  'bathrooms': 1,
  'pricePerNight': 249,
  'cleaningFee': 40.5,
  'currency': 'EUR',
  'amenities': ['wifi'],
  'rating': 4.5,
  'reviewsCount': 12,
  'images': ['https://picsum.photos/1'],
  'createdAt': '2026-01-15T10:30:00.000Z',
};

Listing listingOf(String id) => Listing.fromJson(listingRow(id));

/// A booking row as the API sends it.
Map<String, dynamic> bookingRow(
  String id, {
  String status = 'confirmed',
  String tenantId = testTenant,
}) => {
  'id': id,
  'listingId': 'l1',
  'tenantId': tenantId,
  'guestName': 'Anna Guest',
  'checkIn': '2026-10-12',
  'checkOut': '2026-10-15',
  'guests': 2,
  'status': status,
  'totalPrice': 787.5,
  'currency': 'EUR',
  'createdAt': '2026-09-01T08:00:00.000Z',
};

class MockHostRepository extends Mock implements HostRepository {}
