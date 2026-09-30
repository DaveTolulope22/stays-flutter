import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_favourites/src/data/favourites_repository_provider.dart';
import 'package:feature_favourites/src/widgets/save_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';
import 'package:mocktail/mocktail.dart';

import 'support/favourites_harness.dart';

const _flagsOn = TenantFlags(favourites: true);
const _flagsOff = TenantFlags();

void main() {
  late MockFavouritesRepository repository;

  setUp(() {
    repository = MockFavouritesRepository();
    stubList(repository, []);
    stubWritesSucceed(repository);
  });

  /// Pumps the button for [session] on a tenant with [flags]. The capabilities
  /// are the real resolver's answer, so these tests exercise the actual rule.
  Future<void> pumpButton(
    WidgetTester tester, {
    required Session? session,
    TenantFlags flags = _flagsOn,
    String listingId = 'l1',
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favouritesRepositoryProvider.overrideWithValue(repository),
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(session),
          ),
          capabilitiesProvider.overrideWithValue(
            resolveCapabilities(session, flags),
          ),
        ],
        child: MaterialApp(
          theme: buildNeutralTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: Center(child: SaveButton(listing: listingOf(listingId))),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AppLocalizations copy() => lookupAppLocalizations(const Locale('en'));

  group('who sees it', () {
    testWidgets('a host never sees it, and nothing is requested', (
      tester,
    ) async {
      await pumpButton(tester, session: sessionOf('h1', role: UserRole.host));

      expect(find.byType(IconButton), findsNothing);
      verifyNever(repository.list);
    });

    testWidgets('a client on a tenant with favourites off sees nothing', (
      tester,
    ) async {
      await pumpButton(tester, session: sessionOf('u1'), flags: _flagsOff);

      expect(find.byType(IconButton), findsNothing);
      verifyNever(repository.list);
    });

    testWidgets('signed out sees nothing', (tester) async {
      await pumpButton(tester, session: null);

      expect(find.byType(IconButton), findsNothing);
      verifyNever(repository.list);
    });

    testWidgets('a client on a tenant with favourites on sees the heart', (
      tester,
    ) async {
      await pumpButton(tester, session: sessionOf('u1'));

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byTooltip(copy().saveListing), findsOneWidget);
    });
  });

  group('toggling', () {
    testWidgets('an already saved listing shows a filled heart', (
      tester,
    ) async {
      stubList(repository, ['l1']);

      await pumpButton(tester, session: sessionOf('u1'));

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byTooltip(copy().unsaveListing), findsOneWidget);
    });

    testWidgets('the heart fills at once, before the request answers', (
      tester,
    ) async {
      final answer = Completer<Either<AppFailure, Unit>>();
      when(() => repository.add('l1'))
          .thenReturn(TaskEither(() => answer.future));
      await pumpButton(tester, session: sessionOf('u1'));

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      answer.complete(right(unit));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('a failure rolls the heart back and shows OUR message', (
      tester,
    ) async {
      when(() => repository.add('l1')).thenReturn(
        TaskEither.left(
          const ServerFailure(statusCode: 500, messageCode: 'error.secret'),
        ),
      );
      await pumpButton(tester, session: sessionOf('u1'));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text(copy().errorServer), findsOneWidget);
      expect(find.textContaining('error.secret'), findsNothing);
    });

    testWidgets('a failed unsave puts the filled heart back', (tester) async {
      stubList(repository, ['l1']);
      when(() => repository.remove('l1'))
          .thenReturn(TaskEither.left(const NetworkFailure()));
      await pumpButton(tester, session: sessionOf('u1'));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text(copy().errorNetwork), findsOneWidget);
    });

    testWidgets('it cannot be tapped until the list has loaded', (
      tester,
    ) async {
      final loading = Completer<Either<AppFailure, List<Listing>>>();
      when(repository.list).thenReturn(TaskEither(() => loading.future));

      await pumpButton(tester, session: sessionOf('u1'));

      expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed,
        isNull,
      );
      loading.complete(right(const []));
      await tester.pumpAndSettle();
      expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed,
        isNotNull,
      );
    });
  });
}
