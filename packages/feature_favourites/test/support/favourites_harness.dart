import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feature_favourites/src/data/favourites_repository.dart';
import 'package:fpdart/fpdart.dart';
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

class MockFavouritesRepository extends Mock implements FavouritesRepository {}

/// A session that is whatever the test says, with no storage or network.
class FakeSessionController extends SessionController {
  FakeSessionController(this._session);

  final Session? _session;

  @override
  Future<Session?> build() async => _session;

  /// Simulates signing in as someone else (or out).
  void switchTo(Session? session) => state = AsyncData(session);
}

Session sessionOf(String userId, {UserRole role = UserRole.client}) => Session(
  accessToken: 'token-$userId',
  user: User(
    id: userId,
    tenantId: testTenant,
    role: role,
    email: '$userId@acme.example',
    firstName: 'Gia',
    lastName: 'Guest',
  ),
);

/// The repository answers for one test: what the list holds, and whether the
/// writes succeed.
void stubList(MockFavouritesRepository repository, List<String> ids) => when(
  repository.list,
).thenReturn(TaskEither.right([for (final id in ids) listingOf(id)]));

void stubWritesSucceed(MockFavouritesRepository repository) {
  when(() => repository.add(any())).thenReturn(TaskEither.right(unit));
  when(() => repository.remove(any())).thenReturn(TaskEither.right(unit));
}
