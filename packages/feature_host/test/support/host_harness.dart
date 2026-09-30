import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:feature_host/feature_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

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

/// A page of [count] listings whose ids run on from [start], so two pages never
/// share an id and a test can tell them apart.
CursorPage<Listing> pageOf(
  int count, {
  int start = 0,
  String? next,
  int? total,
}) => CursorPage(
  items: [for (var i = start; i < start + count; i++) listingOf('l$i')],
  total: total,
  nextCursor: next,
);

typedef ListResult = Either<AppFailure, CursorPage<Listing>>;

typedef UpdateResult = Either<AppFailure, Listing>;

/// Answers the host's listings (and an edit) from callbacks and records what it
/// was asked. No network.
class ScriptedHostRepository extends HostRepository {
  ScriptedHostRepository(
    this._onListings, {
    Future<UpdateResult> Function(String id, ListingPatch patch)? onUpdate,
  }) : _onUpdate = onUpdate ?? ((id, patch) async => right(listingOf(id))),
       super(dio: Dio(), tenant: testTenant);

  final Future<ListResult> Function(String? cursor) _onListings;
  final Future<UpdateResult> Function(String id, ListingPatch patch) _onUpdate;

  final cursors = <String?>[];
  final updates = <({String id, ListingPatch patch})>[];

  @override
  TaskEither<AppFailure, CursorPage<Listing>> listings({
    String? cursor,
    int limit = HostRepository.defaultPageSize,
  }) {
    cursors.add(cursor);
    return TaskEither(() => _onListings(cursor));
  }

  @override
  TaskEither<AppFailure, Listing> update(String listingId, ListingPatch patch) {
    updates.add((id: listingId, patch: patch));
    return TaskEither(() => _onUpdate(listingId, patch));
  }
}

/// Counts sign-outs. A plain object because a Riverpod notifier must not expose
/// public fields.
class SignOutCounter {
  int count = 0;
}

class FakeSessionController extends SessionController {
  FakeSessionController(this._signOuts);

  final SignOutCounter _signOuts;

  @override
  Future<Session?> build() async => null;

  @override
  Future<void> signOut() async => _signOuts.count++;
}

/// The host module inside a real router, so opening a listing's screen on top of
/// the list and coming back behaves as it does in the app.
class HostHarness {
  HostHarness(this.repository);

  final ScriptedHostRepository repository;
  final signOuts = SignOutCounter();
  late final GoRouter router;

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Size size = const Size(400, 900),

    /// False while something animates forever (a spinner), which would make
    /// `pumpAndSettle` wait until it times out.
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    router = GoRouter(
      initialLocation: HostPaths.base,
      routes: hostModule.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hostRepositoryProvider.overrideWithValue(repository),
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(signOuts),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: buildNeutralTheme(Brightness.light),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    settle ? await tester.pumpAndSettle() : await tester.pump();
  }
}

AppLocalizations copyFor(String language) =>
    lookupAppLocalizations(Locale(language));
