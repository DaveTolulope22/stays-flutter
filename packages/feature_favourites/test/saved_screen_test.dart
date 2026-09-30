import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_favourites/feature_favourites.dart';
import 'package:feature_favourites/src/data/favourites_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';
import 'package:mocktail/mocktail.dart';

import 'support/favourites_harness.dart';

const _flagsOn = TenantFlags(favourites: true);

void main() {
  late MockFavouritesRepository repository;

  setUp(() {
    repository = MockFavouritesRepository();
    stubWritesSucceed(repository);
  });

  AppLocalizations copy() => lookupAppLocalizations(const Locale('en'));

  Future<void> pumpSaved(WidgetTester tester, {bool settle = true}) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final session = sessionOf('u1');
    final module = favouritesModule(listingLocation: (id) => '/open/$id');
    final router = GoRouter(
      initialLocation: '/saved',
      routes: [
        ...module.routes,
        GoRoute(
          path: '/open/:id',
          builder: (context, state) =>
              Scaffold(body: Text('opened ${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favouritesRepositoryProvider.overrideWithValue(repository),
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(session),
          ),
          capabilitiesProvider.overrideWithValue(
            resolveCapabilities(session, _flagsOn),
          ),
          listingSaveActionProvider.overrideWithValue(saveActionBuilder),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: buildNeutralTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );
    settle ? await tester.pumpAndSettle() : await tester.pump();
  }

  group('states', () {
    testWidgets('loading shows a progress indicator', (tester) async {
      final loading = Completer<Either<AppFailure, List<Listing>>>();
      when(repository.list).thenReturn(TaskEither(() => loading.future));

      await pumpSaved(tester, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      loading.complete(right(const []));
      await tester.pumpAndSettle();
    });

    testWidgets('nothing saved says so, with our copy', (tester) async {
      stubList(repository, []);

      await pumpSaved(tester);

      expect(find.text(copy().savedEmpty), findsOneWidget);
    });

    testWidgets('shows a card per saved listing, in order', (tester) async {
      stubList(repository, ['b', 'a']);

      await pumpSaved(tester);

      expect(find.text('Chalet b'), findsOneWidget);
      expect(find.text('Chalet a'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Chalet b')).dy,
        lessThan(tester.getTopLeft(find.text('Chalet a')).dy),
      );
    });

    testWidgets('a failed load shows our message and Retry fetches again', (
      tester,
    ) async {
      var attempt = 0;
      when(repository.list).thenAnswer(
        (_) => attempt++ == 0
            ? TaskEither.left(const NetworkFailure())
            : TaskEither.right([listingOf('a')]),
      );

      await pumpSaved(tester);
      expect(find.text(copy().errorNetwork), findsOneWidget);

      await tester.tap(find.text(copy().retry));
      await tester.pumpAndSettle();

      expect(find.text('Chalet a'), findsOneWidget);
      verify(repository.list).called(2);
    });
  });

  group('interaction', () {
    testWidgets('unsaving from here removes the card at once', (tester) async {
      stubList(repository, ['a', 'b']);
      await pumpSaved(tester);

      await tester.tap(find.byTooltip(copy().unsaveListing).first);
      await tester.pumpAndSettle();

      expect(find.text('Chalet a'), findsNothing);
      expect(find.text('Chalet b'), findsOneWidget);
      verify(() => repository.remove('a')).called(1);
    });

    testWidgets('a failed unsave brings the card back with our message', (
      tester,
    ) async {
      stubList(repository, ['a']);
      when(() => repository.remove('a'))
          .thenReturn(TaskEither.left(const NetworkFailure()));
      await pumpSaved(tester);

      await tester.tap(find.byTooltip(copy().unsaveListing));
      await tester.pumpAndSettle();

      expect(find.text('Chalet a'), findsOneWidget);
      expect(find.text(copy().errorNetwork), findsOneWidget);
    });

    testWidgets('tapping a card opens the location the shell supplied', (
      tester,
    ) async {
      stubList(repository, ['a']);
      await pumpSaved(tester);

      await tester.tap(find.text('Chalet a'));
      await tester.pumpAndSettle();

      expect(find.text('opened a'), findsOneWidget);
    });
  });

  group('the module', () {
    final module = favouritesModule(listingLocation: (id) => '/x/$id');

    test('is open to a client on a tenant with favourites on', () {
      expect(
        module.isAllowedFor(resolveCapabilities(sessionOf('u1'), _flagsOn)),
        isTrue,
      );
    });

    test('is closed to a host, even with the flag on', () {
      expect(
        module.isAllowedFor(
          resolveCapabilities(sessionOf('h1', role: UserRole.host), _flagsOn),
        ),
        isFalse,
      );
    });

    test('is closed to a client when the flag is off', () {
      expect(
        module.isAllowedFor(
          resolveCapabilities(sessionOf('u1'), const TenantFlags()),
        ),
        isFalse,
      );
    });

    test('is a guest tab that owns /saved', () {
      expect(module.area, AccessArea.guest);
      expect(module.tab, isNotNull);
      expect(module.owns('/saved'), isTrue);
    });
  });
}
