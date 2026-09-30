import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_host/feature_host.dart';
import 'package:feature_host/src/state/host_listings.dart';
import 'package:feature_host/src/state/listing_saver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'support/host_harness.dart';

void main() {
  const patch = ListingPatch(title: 'Renamed', pricePerNight: 250);

  /// A container with the host's list loaded (two listings) and the saver kept
  /// alive, the way the edit screen has both while it is open.
  Future<ProviderContainer> containerFor(
    ScriptedHostRepository repository,
  ) async {
    final container = ProviderContainer(
      overrides: [hostRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(hostListingsProvider, (previous, next) {});
    container.listen(listingSaverProvider, (previous, next) {});
    await container.read(hostListingsProvider.future);
    return container;
  }

  ScriptedHostRepository repositoryAnswering(
    Future<UpdateResult> Function(String id, ListingPatch patch) onUpdate,
  ) => ScriptedHostRepository(
    (cursor) async => right(pageOf(2)),
    onUpdate: onUpdate,
  );

  group('a successful save', () {
    test('returns the updated listing and puts it in the list', () async {
      final updated = listingOf('l1').copyWith(title: 'Renamed');
      final repo = repositoryAnswering((id, patch) async => right(updated));
      final container = await containerFor(repo);

      final result = await container
          .read(listingSaverProvider.notifier)
          .save('l1', patch);

      expect(result.toNullable(), updated);
      final items = container.read(hostListingsProvider).requireValue.items;
      expect(items.map((l) => l.title), ['Chalet l0', 'Renamed']);
      expect(container.read(listingSaverProvider).hasError, isFalse);
    });

    test('sends the listing id and exactly the patch it was given', () async {
      final repo = repositoryAnswering(
        (id, patch) async => right(listingOf(id)),
      );
      final container = await containerFor(repo);

      await container.read(listingSaverProvider.notifier).save('l1', patch);

      expect(repo.updates.single.id, 'l1');
      expect(repo.updates.single.patch, patch);
    });
  });

  group('a failed save', () {
    test('holds the failure, returns nothing, and changes no list', () async {
      final repo = repositoryAnswering(
        (id, patch) async => left(const NetworkFailure()),
      );
      final container = await containerFor(repo);

      final result = await container
          .read(listingSaverProvider.notifier)
          .save('l1', patch);

      expect(result.isNone(), isTrue);
      expect(container.read(listingSaverProvider).error, isA<NetworkFailure>());
      final items = container.read(hostListingsProvider).requireValue.items;
      expect(items.map((l) => l.title), ['Chalet l0', 'Chalet l1']);
    });

    test('the next attempt starts clean and can succeed', () async {
      var fail = true;
      final repo = repositoryAnswering(
        (id, patch) async =>
            fail ? left(const NetworkFailure()) : right(listingOf(id)),
      );
      final container = await containerFor(repo);
      final saver = container.read(listingSaverProvider.notifier);
      await saver.save('l1', patch);

      fail = false;
      final result = await saver.save('l1', patch);

      expect(result.isSome(), isTrue);
      expect(container.read(listingSaverProvider).hasError, isFalse);
    });
  });

  group('while a save is on its way', () {
    test('is saving, and a second call sends nothing', () async {
      final gate = Completer<UpdateResult>();
      final repo = repositoryAnswering((id, patch) => gate.future);
      final container = await containerFor(repo);
      final saver = container.read(listingSaverProvider.notifier);

      final first = saver.save('l1', patch);
      final second = await saver.save('l1', patch);

      expect(container.read(listingSaverProvider).isLoading, isTrue);
      expect(second.isNone(), isTrue);
      gate.complete(right(listingOf('l1')));
      await first;
      expect(repo.updates, hasLength(1));
    });
  });
}
