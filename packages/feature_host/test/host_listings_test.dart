import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_host/feature_host.dart';
import 'package:feature_host/src/state/host_listings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

import 'support/host_harness.dart';

void main() {
  /// A container with the repository swapped for [repository], and the provider
  /// kept alive (an auto-dispose provider nobody listens to would be disposed
  /// between the test's awaits).
  ProviderContainer containerFor(ScriptedHostRepository repository) {
    final container = ProviderContainer(
      overrides: [hostRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(hostListingsProvider, (previous, next) {});
    return container;
  }

  PagedState<Listing> pagedOf(ProviderContainer container) =>
      container.read(hostListingsProvider).requireValue;

  group('first page', () {
    test('loads the items, the total and the next cursor', () async {
      final repo = ScriptedHostRepository(
        (cursor) async => right(pageOf(3, next: 'c1', total: 50)),
      );
      final container = containerFor(repo);

      final paged = await container.read(hostListingsProvider.future);

      expect(paged.items.map((l) => l.id), ['l0', 'l1', 'l2']);
      expect(paged.total, 50);
      expect(paged.nextCursor, 'c1');
      expect(repo.cursors, [null]);
    });

    test('a failure is an AsyncError holding the AppFailure', () async {
      final repo = ScriptedHostRepository(
        (cursor) async => left(const NetworkFailure()),
      );
      final container = containerFor(repo);

      await expectLater(
        container.read(hostListingsProvider.future),
        throwsA(isA<NetworkFailure>()),
      );
      expect(container.read(hostListingsProvider).hasError, isTrue);
    });

    test('a failure is not retried automatically', () async {
      final repo = ScriptedHostRepository(
        (cursor) async => left(const NetworkFailure()),
      );
      final container = containerFor(repo);
      await container
          .read(hostListingsProvider.future)
          .then((_) {}, onError: (Object _) {});

      // Riverpod's default backoff would fire a retry within a second or two.
      await Future<void>.delayed(const Duration(seconds: 3));

      expect(repo.cursors, hasLength(1));
    });
  });

  group('loadMore', () {
    test(
      'appends the next page, asking with the cursor it was given',
      () async {
        final repo = ScriptedHostRepository(
          (cursor) async => right(
            cursor == null
                ? pageOf(2, next: 'c1', total: 4)
                : pageOf(2, start: 2, total: 4),
          ),
        );
        final container = containerFor(repo);
        await container.read(hostListingsProvider.future);

        await container.read(hostListingsProvider.notifier).loadMore();

        final paged = pagedOf(container);
        expect(paged.items.map((l) => l.id), ['l0', 'l1', 'l2', 'l3']);
        expect(repo.cursors.last, 'c1');
        expect(paged.isLoadingMore, isFalse);
      },
    );

    test('concurrent calls send one request and append once', () async {
      final gate = Completer<ListResult>();
      final repo = ScriptedHostRepository(
        (cursor) => cursor == null
            ? Future.value(right(pageOf(2, next: 'c1')))
            : gate.future,
      );
      final container = containerFor(repo);
      await container.read(hostListingsProvider.future);
      final notifier = container.read(hostListingsProvider.notifier);

      final first = notifier.loadMore();
      final second = notifier.loadMore();
      gate.complete(right(pageOf(2, start: 2)));
      await Future.wait([first, second]);

      expect(repo.cursors, [null, 'c1']);
      expect(pagedOf(container).items, hasLength(4));
    });

    test(
      'stops at the end: the "null" cursor never becomes a request',
      () async {
        final repo = ScriptedHostRepository((cursor) async => right(pageOf(2)));
        final container = containerFor(repo);
        await container.read(hostListingsProvider.future);

        await container.read(hostListingsProvider.notifier).loadMore();

        expect(repo.cursors, [null]);
      },
    );

    test('a failing page keeps the items and records the failure', () async {
      final repo = ScriptedHostRepository(
        (cursor) async => cursor == null
            ? right(pageOf(2, next: 'c1'))
            : left(const NetworkFailure()),
      );
      final container = containerFor(repo);
      await container.read(hostListingsProvider.future);

      await container.read(hostListingsProvider.notifier).loadMore();

      final paged = pagedOf(container);
      expect(paged.items, hasLength(2));
      expect(paged.loadMoreError, isA<NetworkFailure>());
      expect(paged.nextCursor, 'c1');
    });
  });

  group('replace', () {
    test('swaps the edited listing in place and keeps the order', () async {
      final repo = ScriptedHostRepository(
        (cursor) async => right(pageOf(3, next: 'c1', total: 9)),
      );
      final container = containerFor(repo);
      await container.read(hostListingsProvider.future);

      container
          .read(hostListingsProvider.notifier)
          .replace(listingOf('l1').copyWith(title: 'Renamed'));

      final paged = pagedOf(container);
      expect(paged.items.map((l) => l.title), [
        'Chalet l0',
        'Renamed',
        'Chalet l2',
      ]);
      expect(paged.nextCursor, 'c1');
      expect(paged.total, 9);
    });

    test('a listing that is not loaded is ignored', () async {
      final repo = ScriptedHostRepository((cursor) async => right(pageOf(2)));
      final container = containerFor(repo);
      await container.read(hostListingsProvider.future);

      container
          .read(hostListingsProvider.notifier)
          .replace(listingOf('elsewhere'));

      expect(pagedOf(container).items.map((l) => l.id), ['l0', 'l1']);
    });
  });
}
