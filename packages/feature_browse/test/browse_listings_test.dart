import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_browse/src/state/browse_listings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

import 'support/browse_harness.dart';

const _davos = ListingFilter(city: 'Davos');
const _zermatt = ListingFilter(city: 'Zermatt');

void main() {
  /// A container with the repository swapped for [repository], and the
  /// provider for [filter] kept alive (an auto-dispose provider nobody listens
  /// to would be disposed between the test's awaits).
  ProviderContainer containerFor(
    ScriptedRepository repository,
    ListingFilter filter,
  ) {
    final container = ProviderContainer(
      overrides: [listingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(browseListingsProvider(filter), (previous, next) {});
    return container;
  }

  PagedState<Listing> pagedOf(ProviderContainer container, ListingFilter f) =>
      container.read(browseListingsProvider(f)).requireValue;

  group('first page', () {
    test('loads the items, the total and the next cursor', () async {
      final repo = ScriptedRepository(
        (filter, cursor) async => right(pageOf(3, next: 'c1', total: 500)),
      );
      final container = containerFor(repo, _davos);

      final paged = await container.read(browseListingsProvider(_davos).future);

      expect(paged.items.map((l) => l.id), ['l0', 'l1', 'l2']);
      expect(paged.total, 500);
      expect(paged.nextCursor, 'c1');
      expect(repo.calls.single, (filter: _davos, cursor: null));
    });

    test('a failure is an AsyncError holding the AppFailure', () async {
      final repo = ScriptedRepository(
        (filter, cursor) async => left(const NetworkFailure()),
      );
      final container = containerFor(repo, _davos);

      await expectLater(
        container.read(browseListingsProvider(_davos).future),
        throwsA(isA<NetworkFailure>()),
      );
      expect(container.read(browseListingsProvider(_davos)).hasError, isTrue);
    });

    test('a failure is not retried automatically', () async {
      final repo = ScriptedRepository(
        (filter, cursor) async => left(const NetworkFailure()),
      );
      final container = containerFor(repo, _davos);
      await container
          .read(browseListingsProvider(_davos).future)
          .then((_) {}, onError: (Object _) {});

      // Riverpod's default backoff would fire a retry within a second or two.
      await Future<void>.delayed(const Duration(seconds: 3));

      expect(repo.calls, hasLength(1));
    });
  });

  group('loadMore', () {
    test(
      'appends the next page, asking with the cursor it was given',
      () async {
        final repo = ScriptedRepository(
          (filter, cursor) async => right(
            cursor == null
                ? pageOf(2, next: 'c1', total: 4)
                : pageOf(2, start: 2, total: 4),
          ),
        );
        final container = containerFor(repo, _davos);
        await container.read(browseListingsProvider(_davos).future);

        await container
            .read(browseListingsProvider(_davos).notifier)
            .loadMore();

        final paged = pagedOf(container, _davos);
        expect(paged.items.map((l) => l.id), ['l0', 'l1', 'l2', 'l3']);
        expect(repo.calls.last, (filter: _davos, cursor: 'c1'));
        expect(paged.isLoadingMore, isFalse);
      },
    );

    test('concurrent calls send one request and append once', () async {
      final gate = Completer<ListResult>();
      final repo = ScriptedRepository(
        (filter, cursor) => cursor == null
            ? Future.value(right(pageOf(2, next: 'c1')))
            : gate.future,
      );
      final container = containerFor(repo, _davos);
      await container.read(browseListingsProvider(_davos).future);
      final notifier = container.read(browseListingsProvider(_davos).notifier);

      final first = notifier.loadMore();
      // The flag is already up, before any await has finished.
      expect(pagedOf(container, _davos).isLoadingMore, isTrue);
      final second = notifier.loadMore();
      final third = notifier.loadMore();
      gate.complete(right(pageOf(2, start: 2)));
      await Future.wait([first, second, third]);

      expect(repo.calls.where((call) => call.cursor == 'c1'), hasLength(1));
      expect(pagedOf(container, _davos).items.map((l) => l.id), [
        'l0',
        'l1',
        'l2',
        'l3',
      ]);
    });

    test('stops at the "null" cursor: no more requests', () async {
      final repo = ScriptedRepository(
        (filter, cursor) async =>
            right(cursor == null ? pageOf(2, next: 'c1') : pageOf(2, start: 2)),
      );
      final container = containerFor(repo, _davos);
      await container.read(browseListingsProvider(_davos).future);
      final notifier = container.read(browseListingsProvider(_davos).notifier);

      await notifier.loadMore();
      expect(pagedOf(container, _davos).hasMore, isFalse);
      await notifier.loadMore();
      await notifier.loadMore();

      expect(repo.calls, hasLength(2));
      expect(pagedOf(container, _davos).items, hasLength(4));
    });

    test('a failed page keeps the items and retries the same cursor', () async {
      var failNext = true;
      final repo = ScriptedRepository((filter, cursor) async {
        if (cursor == null) return right(pageOf(2, next: 'c1'));
        if (failNext) return left(const NetworkFailure());
        return right(pageOf(2, start: 2));
      });
      final container = containerFor(repo, _davos);
      await container.read(browseListingsProvider(_davos).future);
      final notifier = container.read(browseListingsProvider(_davos).notifier);

      await notifier.loadMore();

      var paged = pagedOf(container, _davos);
      expect(paged.items.map((l) => l.id), ['l0', 'l1']);
      expect(paged.loadMoreError, isA<NetworkFailure>());
      expect(paged.isLoadingMore, isFalse);
      expect(paged.nextCursor, 'c1');

      failNext = false;
      await notifier.loadMore();

      paged = pagedOf(container, _davos);
      expect(paged.items.map((l) => l.id), ['l0', 'l1', 'l2', 'l3']);
      expect(paged.loadMoreError, isNull);
      expect(
        repo.calls.where((call) => call.cursor == 'c1'),
        hasLength(2),
        reason: 'the retry asks for the same page, not the one after it',
      );
    });

    test('does nothing while the first page has not loaded', () async {
      final gate = Completer<ListResult>();
      final repo = ScriptedRepository((filter, cursor) => gate.future);
      final container = containerFor(repo, _davos);
      final notifier = container.read(browseListingsProvider(_davos).notifier);

      await notifier.loadMore();

      expect(repo.calls, hasLength(1));
      gate.complete(right(pageOf(1)));
    });

    test(
      'an answer for a list that was refreshed meanwhile is dropped',
      () async {
        final gate = Completer<ListResult>();
        var firstPageRequests = 0;
        final repo = ScriptedRepository((filter, cursor) {
          if (cursor != null) return gate.future;
          firstPageRequests++;
          return Future.value(
            right(
              firstPageRequests == 1
                  ? pageOf(2, next: 'c1')
                  : pageOf(1, prefix: 'fresh'),
            ),
          );
        });
        final container = containerFor(repo, _davos);
        await container.read(browseListingsProvider(_davos).future);
        final loading = container
            .read(browseListingsProvider(_davos).notifier)
            .loadMore();

        await container.refresh(browseListingsProvider(_davos).future);
        gate.complete(right(pageOf(2, start: 2)));
        await loading;

        expect(pagedOf(container, _davos).items.map((l) => l.id), ['fresh0']);
      },
    );
  });

  group('a filter change', () {
    test('starts a fresh list and leaves the old one alone', () async {
      final repo = ScriptedRepository((filter, cursor) async {
        final prefix = filter.city == 'Davos' ? 'd' : 'z';
        return right(
          pageOf(2, prefix: prefix, next: cursor == null ? 'c1' : null),
        );
      });
      final container = containerFor(repo, _davos);
      await container.read(browseListingsProvider(_davos).future);
      await container.read(browseListingsProvider(_davos).notifier).loadMore();

      container.listen(browseListingsProvider(_zermatt), (previous, next) {});
      await container.read(browseListingsProvider(_zermatt).future);

      final zermatt = pagedOf(container, _zermatt);
      expect(zermatt.items.map((l) => l.id), ['z0', 'z1']);
      expect(repo.calls.last, (filter: _zermatt, cursor: null));
      expect(
        pagedOf(container, _davos).items,
        hasLength(4),
        reason: 'the Davos pages were not touched',
      );
    });

    test('an equal filter is the same list, not a new request', () async {
      final repo = ScriptedRepository(
        (filter, cursor) async => right(pageOf(1)),
      );
      final container = containerFor(repo, const ListingFilter(city: 'Davos'));
      await container.read(browseListingsProvider(_davos).future);

      await container.read(
        browseListingsProvider(const ListingFilter(city: 'Davos')).future,
      );

      expect(repo.calls, hasLength(1));
    });
  });
}
