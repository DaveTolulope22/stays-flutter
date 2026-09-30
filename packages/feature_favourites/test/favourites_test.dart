import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_favourites/src/data/favourites_repository_provider.dart';
import 'package:feature_favourites/src/state/favourites.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';
import 'package:mocktail/mocktail.dart';

import 'support/favourites_harness.dart';

void main() {
  late MockFavouritesRepository repository;
  late FakeSessionController session;
  late ProviderContainer container;

  setUp(() {
    repository = MockFavouritesRepository();
    session = FakeSessionController(sessionOf('u1'));
    container = ProviderContainer(
      overrides: [
        favouritesRepositoryProvider.overrideWithValue(repository),
        sessionControllerProvider.overrideWith(() => session),
      ],
    );
    addTearDown(container.dispose);
  });

  Favourites notifier() => container.read(favouritesProvider.notifier);

  List<String> savedIds() => [
    for (final l in container.read(favouritesProvider).requireValue) l.id,
  ];

  /// Loads the list and keeps it alive, the way a mounted button would.
  Future<void> load(List<String> ids) async {
    stubList(repository, ids);
    container.listen(favouritesProvider, (_, _) {});
    await container.read(favouritesProvider.future);
  }

  group('loading', () {
    test('holds what the API returned, in order', () async {
      await load(['b', 'a']);

      expect(savedIds(), ['b', 'a']);
    });

    test('a failure is an error state, and is not retried by itself', () async {
      when(repository.list).thenReturn(TaskEither.left(const NetworkFailure()));
      container.listen(favouritesProvider, (_, _) {});

      await expectLater(
        container.read(favouritesProvider.future),
        throwsA(isA<NetworkFailure>()),
      );
      await Future<void>.delayed(const Duration(seconds: 3));

      verify(repository.list).called(1);
    });

    test('signed out: empty, and the API is never asked', () async {
      final signedOut = ProviderContainer(
        overrides: [
          favouritesRepositoryProvider.overrideWithValue(repository),
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(null),
          ),
        ],
      );
      addTearDown(signedOut.dispose);

      expect(await signedOut.read(favouritesProvider.future), isEmpty);
      verifyNever(repository.list);
    });

    test('another account gets its own list, fetched again', () async {
      await load(['a']);
      when(repository.list).thenReturn(TaskEither.right([listingOf('z')]));

      session.switchTo(sessionOf('u2'));
      await container.read(favouritesProvider.future);

      expect(savedIds(), ['z']);
      verify(repository.list).called(2);
    });
  });

  group('toggle', () {
    test('saving shows at once, before the request answers', () async {
      await load(['a']);
      final answer = Completer<Either<AppFailure, Unit>>();
      when(() => repository.add('b'))
          .thenReturn(TaskEither(() => answer.future));

      final done = notifier().toggle(listingOf('b'));

      expect(savedIds(), ['b', 'a']);

      answer.complete(right(unit));
      expect(await done, const None());
      expect(savedIds(), ['b', 'a']);
    });

    test('unsaving removes it and calls DELETE', () async {
      await load(['a', 'b']);
      stubWritesSucceed(repository);

      await notifier().toggle(listingOf('a'));

      expect(savedIds(), ['b']);
      verify(() => repository.remove('a')).called(1);
    });

    test('a failed save is rolled back and the failure is returned', () async {
      await load(['a']);
      when(() => repository.add('b'))
          .thenReturn(TaskEither.left(const NetworkFailure()));

      final result = await notifier().toggle(listingOf('b'));

      expect(savedIds(), ['a']);
      expect(result.toNullable(), isA<NetworkFailure>());
    });

    test('a failed unsave is put back in the same place', () async {
      await load(['a', 'b', 'c']);
      when(() => repository.remove('b'))
          .thenReturn(TaskEither.left(const ServerFailure(statusCode: 500)));

      final result = await notifier().toggle(listingOf('b'));

      expect(savedIds(), ['a', 'b', 'c']);
      expect(result.toNullable(), isA<ServerFailure>());
    });

    test('a rollback does not undo a change made meanwhile', () async {
      await load(['a']);
      final slowFailure = Completer<Either<AppFailure, Unit>>();
      when(() => repository.add('b'))
          .thenReturn(TaskEither(() => slowFailure.future));
      when(() => repository.add('c')).thenReturn(TaskEither.right(unit));

      final first = notifier().toggle(listingOf('b'));
      await notifier().toggle(listingOf('c'));
      expect(savedIds(), ['c', 'b', 'a']);

      slowFailure.complete(left(const NetworkFailure()));
      await first;

      expect(savedIds(), ['c', 'a']);
    });

    test(
      'a second tap on the same listing while it is pending is ignored',
      () async {
        await load(['a']);
        final answer = Completer<Either<AppFailure, Unit>>();
        when(() => repository.add('b'))
            .thenReturn(TaskEither(() => answer.future));

        final first = notifier().toggle(listingOf('b'));
        final second = await notifier().toggle(listingOf('b'));
        answer.complete(right(unit));
        await first;

        expect(second, const None());
        verify(() => repository.add('b')).called(1);
        verifyNever(() => repository.remove(any()));
        expect(savedIds(), ['b', 'a']);
      },
    );

    test('does nothing until the list has loaded', () async {
      final loading = Completer<Either<AppFailure, List<Listing>>>();
      when(repository.list).thenReturn(TaskEither(() => loading.future));
      container.listen(favouritesProvider, (_, _) {});

      final result = await notifier().toggle(listingOf('b'));

      expect(result, const None());
      verifyNever(() => repository.add(any()));
      loading.complete(right([listingOf('a')]));
    });
  });
}
