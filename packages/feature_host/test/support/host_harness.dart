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
typedef BlockedDaysResult = Either<AppFailure, List<BlockedDay>>;
typedef DayWriteResult = Either<AppFailure, Unit>;
typedef BookingsResult = Either<AppFailure, CursorPage<Booking>>;

/// The date every calendar test runs on: a Sunday in the middle of March 2026.
/// Nothing in these tests reads the real date, so they cannot break at a month
/// boundary or at midnight.
final fixedToday = LocalDate(2026, 3, 15);

/// Answers the host's listings, an edit, and the blocked days from callbacks and
/// records what it was asked. No network. Anything not scripted succeeds with an
/// empty or unchanged answer.
class ScriptedHostRepository extends HostRepository {
  ScriptedHostRepository(
    this._onListings, {
    Future<UpdateResult> Function(String id, ListingPatch patch)? onUpdate,
    Future<BlockedDaysResult> Function(String id)? onBlockedDays,
    Future<DayWriteResult> Function(String id, LocalDate date)? onBlock,
    Future<DayWriteResult> Function(String id, LocalDate date)? onUnblock,
    Future<BookingsResult> Function(
      String id,
      BookingStatus? status,
      String? cursor,
    )?
    onBookings,
  }) : _onUpdate = onUpdate ?? ((id, patch) async => right(listingOf(id))),
       _onBlockedDays = onBlockedDays ?? ((id) async => right(const [])),
       _onBlock = onBlock ?? ((id, date) async => right(unit)),
       _onUnblock = onUnblock ?? ((id, date) async => right(unit)),
       _onBookings =
           onBookings ??
           ((id, status, cursor) async => right(const CursorPage(items: []))),
       super(dio: Dio(), tenant: testTenant);

  final Future<ListResult> Function(String? cursor) _onListings;
  final Future<UpdateResult> Function(String id, ListingPatch patch) _onUpdate;
  final Future<BlockedDaysResult> Function(String id) _onBlockedDays;
  final Future<DayWriteResult> Function(String id, LocalDate date) _onBlock;
  final Future<DayWriteResult> Function(String id, LocalDate date) _onUnblock;
  final Future<BookingsResult> Function(
    String id,
    BookingStatus? status,
    String? cursor,
  )
  _onBookings;

  final cursors = <String?>[];
  final updates = <({String id, ListingPatch patch})>[];
  final blockedDaysCalls = <String>[];
  final blocks = <({String id, LocalDate date})>[];
  final unblocks = <({String id, LocalDate date})>[];
  final bookingCalls = <({String id, BookingStatus? status, String? cursor})>[];

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

  @override
  TaskEither<AppFailure, List<BlockedDay>> blockedDays(String listingId) {
    blockedDaysCalls.add(listingId);
    return TaskEither(() => _onBlockedDays(listingId));
  }

  @override
  TaskEither<AppFailure, Unit> block(String listingId, LocalDate date) {
    blocks.add((id: listingId, date: date));
    return TaskEither(() => _onBlock(listingId, date));
  }

  @override
  TaskEither<AppFailure, CursorPage<Booking>> bookings(
    String listingId, {
    BookingStatus? status,
    String? cursor,
    int limit = HostRepository.defaultPageSize,
  }) {
    bookingCalls.add((id: listingId, status: status, cursor: cursor));
    return TaskEither(() => _onBookings(listingId, status, cursor));
  }

  @override
  TaskEither<AppFailure, Unit> unblock(String listingId, LocalDate date) {
    unblocks.add((id: listingId, date: date));
    return TaskEither(() => _onUnblock(listingId, date));
  }
}

BlockedDay blockedOn(String date, {String listingId = 'l1'}) =>
    BlockedDay(listingId: listingId, date: LocalDate.parse(date));

UnavailableDay takenOn(String date, UnavailableReason reason) =>
    UnavailableDay(date: LocalDate.parse(date), reason: reason);

/// A booking with the given parts; anything a test does not vary is ordinary.
Booking bookingOf(
  String id, {
  BookingStatus status = BookingStatus.confirmed,
  String guestName = 'Anna Guest',
  String checkIn = '2026-10-12',
  String checkOut = '2026-10-15',
  int guests = 2,
  num totalPrice = 787.5,
  String currency = 'EUR',
}) => Booking(
  id: id,
  listingId: 'l1',
  tenantId: testTenant,
  guestName: guestName,
  checkIn: LocalDate.parse(checkIn),
  checkOut: LocalDate.parse(checkOut),
  guests: guests,
  status: status,
  totalPrice: totalPrice,
  currency: currency,
  createdAt: DateTime.utc(2026, 9, 1),
);

/// A page of [count] bookings whose ids run on from [start], so two pages never
/// share an id.
CursorPage<Booking> bookingsPageOf(
  int count, {
  int start = 0,
  String? next,
  int? total,
  BookingStatus status = BookingStatus.confirmed,
}) => CursorPage(
  items: [
    for (var i = start; i < start + count; i++)
      bookingOf('b$i', status: status, guestName: 'Guest $i'),
  ],
  total: total,
  nextCursor: next,
);
typedef AvailabilityResult = Either<AppFailure, Availability>;

/// Answers the availability of a window from a callback and records the windows
/// it was asked for. No network.
class ScriptedAvailabilityRepository extends ListingsRepository {
  ScriptedAvailabilityRepository(this._onAvailability)
    : super(dio: Dio(), tenant: testTenant);

  /// Every window taken from [taken], answered as the API does: free days absent.
  factory ScriptedAvailabilityRepository.taking(List<UnavailableDay> taken) =>
      ScriptedAvailabilityRepository(
        (id, window) async => right(
          Availability(
            listingId: id,
            from: window.start,
            to: window.end,
            unavailable: [
              for (final day in taken)
                if (window.contains(day.date)) day,
            ],
          ),
        ),
      );

  final Future<AvailabilityResult> Function(String id, DateRange window)
  _onAvailability;

  final windows = <DateRange>[];

  @override
  TaskEither<AppFailure, Availability> availability(
    String listingId,
    DateRange window,
  ) {
    windows.add(window);
    return TaskEither(() => _onAvailability(listingId, window));
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
