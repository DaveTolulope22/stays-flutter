import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:feature_browse/src/screens/browse_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

/// The date every test runs on: a Sunday in the middle of March 2026. Nothing in
/// these tests reads the real date, so they cannot break at a month boundary or
/// at midnight.
final fixedToday = LocalDate(2026, 3, 15);

typedef ListResult = Either<AppFailure, CursorPage<Listing>>;
typedef ListCall = ({ListingFilter filter, String? cursor});

Listing listingFixture(
  String id, {
  String? title,
  String country = 'CH',
  int bedrooms = 2,
  num cleaningFee = 40,
  double rating = 4.5,
  int reviewsCount = 3,
  List<String> amenities = const ['wifi'],
  List<String> images = const ['https://picsum.photos/1'],
}) => Listing(
  id: id,
  tenantId: 'acme',
  hostId: 'h1',
  title: title ?? 'Stay $id',
  description: 'Quiet chalet near the lift.',
  city: 'Davos',
  country: country,
  address: 'Bergstrasse 1',
  latitude: 46.8,
  longitude: 9.8,
  propertyType: 'chalet',
  maxGuests: 4,
  bedrooms: bedrooms,
  beds: 3,
  bathrooms: 1,
  pricePerNight: 249,
  cleaningFee: cleaningFee,
  currency: 'CHF',
  amenities: amenities,
  rating: rating,
  reviewsCount: reviewsCount,
  images: images,
  createdAt: DateTime.utc(2026, 1, 15),
);

/// A page of [count] listings whose ids run on from [start], so two pages never
/// share an id and a test can tell them apart.
CursorPage<Listing> pageOf(
  int count, {
  int start = 0,
  String? next,
  int? total,
  String prefix = 'l',
}) => CursorPage(
  items: [
    for (var i = start; i < start + count; i++) listingFixture('$prefix$i'),
  ],
  total: total,
  nextCursor: next,
);

/// What the filter sheet is built from in tests: the bounds are the ones the
/// alpine tenant really has (51 to 694 CHF).
ListingFacets facetsFixture() => const ListingFacets(
  cities: ['Davos', 'Grindelwald', 'Zermatt'],
  propertyTypes: ['chalet'],
  amenities: ['wifi'],
  priceMin: 51,
  priceMax: 694,
  maxGuests: 16,
  currency: 'CHF',
);

/// Answers list and facets requests from callbacks and records them. No network.
class ScriptedRepository extends ListingsRepository {
  ScriptedRepository(
    this._onList, {
    Future<Either<AppFailure, ListingFacets>> Function()? onFacets,
    Future<Either<AppFailure, Listing>> Function(String id)? onDetail,
    Future<Either<AppFailure, Availability>> Function(
      String id,
      DateRange window,
    )?
    onAvailability,
  }) : _onFacets = onFacets ?? (() async => right(facetsFixture())),
       _onDetail = onDetail ?? ((id) async => right(listingFixture(id))),
       _onAvailability =
           onAvailability ??
           ((id, window) async => right(
             Availability(
               listingId: id,
               from: window.start,
               to: window.end,
               unavailable: const [],
             ),
           )),
       super(dio: Dio(), tenant: 'acme');

  final Future<ListResult> Function(ListingFilter filter, String? cursor)
  _onList;
  final Future<Either<AppFailure, ListingFacets>> Function() _onFacets;
  final Future<Either<AppFailure, Listing>> Function(String id) _onDetail;
  final Future<Either<AppFailure, Availability>> Function(
    String id,
    DateRange window,
  )
  _onAvailability;

  final calls = <ListCall>[];
  int facetsCalls = 0;
  final detailCalls = <String>[];
  final availabilityCalls = <({String id, DateRange window})>[];

  @override
  TaskEither<AppFailure, Availability> availability(
    String listingId,
    DateRange window,
  ) {
    availabilityCalls.add((id: listingId, window: window));
    return TaskEither(() => _onAvailability(listingId, window));
  }

  @override
  TaskEither<AppFailure, Listing> detail(String id) {
    detailCalls.add(id);
    return TaskEither(() => _onDetail(id));
  }

  @override
  TaskEither<AppFailure, ListingFacets> facets() {
    facetsCalls++;
    return TaskEither(_onFacets);
  }

  @override
  TaskEither<AppFailure, CursorPage<Listing>> list(
    ListingFilter filter, {
    String? cursor,
    int limit = ListingsRepository.defaultPageSize,
  }) {
    calls.add((filter: filter, cursor: cursor));
    return TaskEither(() => _onList(filter, cursor));
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

TenantConfig testConfig() => TenantConfig(
  slug: 'acme',
  name: 'Acme Stays',
  currency: 'CHF',
  locales: const ['en', 'de'],
  defaultLocale: 'en',
  supportEmail: 'support@acme.example',
  termsOfUseUrl: 'https://acme.example/terms',
  privacyPolicyUrl: 'https://acme.example/privacy',
  flags: const TenantFlags(),
  theme: const TenantTheme(),
);

/// The browse screen inside a real router, so opening a page on top of it and
/// coming back behaves as it does in the app.
class BrowseHarness {
  BrowseHarness(this.repository, {this.canSeeReviews = true, this.saveAction});

  final ScriptedRepository repository;
  final bool canSeeReviews;
  final ListingActionBuilder? saveAction;
  final signOuts = SignOutCounter();
  late final GoRouter router;

  ProviderContainer container(WidgetTester tester) => ProviderScope.containerOf(
    tester.element(find.byType(BrowseScreen, skipOffstage: false)),
  );

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Size size = const Size(400, 900),

    /// Where the app starts, to open a listing as a deep link would.
    String location = BrowsePaths.base,

    /// False while something animates forever (a spinner), which would make
    /// `pumpAndSettle` wait until it times out.
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    router = GoRouter(
      initialLocation: location,
      routes: [
        ...browseModule.routes,
        GoRoute(
          path: '/detail',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Detail page'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => fixedToday),
          listingsRepositoryProvider.overrideWithValue(repository),
          if (saveAction != null)
            listingSaveActionProvider.overrideWithValue(saveAction!),
          capabilitiesProvider.overrideWithValue(
            Capabilities(area: AccessArea.guest, canSeeReviews: canSeeReviews),
          ),
          tenantConfigProvider.overrideWith((ref) => testConfig()),
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
