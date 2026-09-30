import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_host/feature_host.dart';
import 'package:feature_host/src/state/booked_days.dart';
import 'package:feature_host/src/state/host_blocked_days.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

import 'support/host_harness.dart';

const _id = 'l1';

/// The month every test looks at; `fixedToday` is in it.
final _march = LocalDate(2026, 3, 1);

LocalDate _d(String iso) => LocalDate.parse(iso);

/// Taken in March: a booking (20th), a day the host blocked that availability
/// reports as `blocked` (21st), and one for a reason this app does not know
/// (22nd).
final _taken = [
  takenOn('2026-03-20', UnavailableReason.booked),
  takenOn('2026-03-21', UnavailableReason.blocked),
  takenOn('2026-03-22', UnavailableReason.unknown),
];

void main() {
  /// A container with the repositories swapped out, both providers kept alive
  /// (the calendar screen watches both while it is open) and, unless
  /// [loadBooked] is false, both loaded.
  Future<ProviderContainer> open(
    ScriptedHostRepository repository, {
    ScriptedAvailabilityRepository? listings,
    bool canBlock = true,
    bool loadBooked = true,
  }) async {
    final container = ProviderContainer(
      overrides: [
        hostRepositoryProvider.overrideWithValue(repository),
        listingsRepositoryProvider.overrideWithValue(
          listings ?? ScriptedAvailabilityRepository.taking(_taken),
        ),
        clockProvider.overrideWithValue(() => fixedToday),
        capabilitiesProvider.overrideWithValue(
          Capabilities(
            area: AccessArea.host,
            canUseHostPanel: true,
            canBlockDays: canBlock,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(hostBlockedDaysProvider(_id), (previous, next) {});
    container.listen(bookedDaysProvider(_id, _march), (previous, next) {});
    await container.read(hostBlockedDaysProvider(_id).future);
    if (loadBooked) {
      await container.read(bookedDaysProvider(_id, _march).future);
    }
    return container;
  }

  Set<LocalDate> blockedIn(ProviderContainer container) =>
      container.read(hostBlockedDaysProvider(_id)).requireValue;

  HostBlockedDays notifierOf(ProviderContainer container) =>
      container.read(hostBlockedDaysProvider(_id).notifier);

  ScriptedHostRepository repoWith({
    List<BlockedDay> blocked = const [],
    Future<DayWriteResult> Function(String id, LocalDate date)? onBlock,
    Future<DayWriteResult> Function(String id, LocalDate date)? onUnblock,
  }) => ScriptedHostRepository(
    (_) async => right(pageOf(1)),
    onBlockedDays: (_) async => right(blocked),
    onBlock: onBlock,
    onUnblock: onUnblock,
  );

  group('bookedDays', () {
    test(
      'holds booked and unexplained days, never the host\'s own blocks',
      () async {
        final container = await open(repoWith());

        final booked = container
            .read(bookedDaysProvider(_id, _march))
            .requireValue;

        expect(booked, {_d('2026-03-20'), _d('2026-03-22')});
      },
    );

    test('asks only for the days from today in the current month', () async {
      final listings = ScriptedAvailabilityRepository.taking(_taken);
      await open(repoWith(), listings: listings);

      expect(listings.windows.single, DateRange(fixedToday, _d('2026-04-01')));
    });

    test('a failure is held as the AppFailure', () async {
      final listings = ScriptedAvailabilityRepository(
        (id, window) async => left(const NetworkFailure()),
      );
      final container = await open(
        repoWith(),
        listings: listings,
        loadBooked: false,
      );

      await expectLater(
        container.read(bookedDaysProvider(_id, _march).future),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('loading', () {
    test('holds the days the host blocked', () async {
      final container = await open(
        repoWith(blocked: [blockedOn('2026-03-25'), blockedOn('2026-04-02')]),
      );

      expect(blockedIn(container), {_d('2026-03-25'), _d('2026-04-02')});
    });

    test('a failure is held as the AppFailure and not retried', () async {
      final repo = ScriptedHostRepository(
        (_) async => right(pageOf(1)),
        onBlockedDays: (_) async => left(const NetworkFailure()),
      );
      final container = ProviderContainer(
        overrides: [hostRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen(hostBlockedDaysProvider(_id), (previous, next) {});

      await expectLater(
        container.read(hostBlockedDaysProvider(_id).future),
        throwsA(isA<NetworkFailure>()),
      );
      // Riverpod's default backoff would fire a retry within a second or two.
      await Future<void>.delayed(const Duration(seconds: 3));

      expect(repo.blockedDaysCalls, hasLength(1));
    });
  });

  group('blocking a free day', () {
    test('changes the day at once, then sends the request', () async {
      final gate = Completer<DayWriteResult>();
      final repo = repoWith(onBlock: (id, date) => gate.future);
      final container = await open(repo);

      final pending = notifierOf(container).toggle(_d('2026-03-25'));

      expect(blockedIn(container), {
        _d('2026-03-25'),
      }, reason: 'before the answer');
      expect(repo.blocks.single, (id: _id, date: _d('2026-03-25')));
      gate.complete(right(unit));
      expect((await pending).isNone(), isTrue);
      expect(blockedIn(container), {_d('2026-03-25')});
    });

    test(
      'a failed request puts the day back and returns the failure',
      () async {
        final repo = repoWith(
          onBlock: (id, date) async => left(const NetworkFailure()),
        );
        final container = await open(repo);

        final result = await notifierOf(container).toggle(_d('2026-03-25'));

        expect(result.toNullable(), isA<NetworkFailure>());
        expect(blockedIn(container), isEmpty);
      },
    );

    test('after a rollback the same tap can be tried again', () async {
      var fail = true;
      final repo = repoWith(
        onBlock: (id, date) async =>
            fail ? left(const NetworkFailure()) : right(unit),
      );
      final container = await open(repo);
      await notifierOf(container).toggle(_d('2026-03-25'));

      fail = false;
      final result = await notifierOf(container).toggle(_d('2026-03-25'));

      expect(result.isNone(), isTrue);
      expect(blockedIn(container), {_d('2026-03-25')});
      expect(repo.blocks, hasLength(2));
    });
  });

  group('unblocking a blocked day', () {
    test('opens the day at once and sends an unblock', () async {
      final gate = Completer<DayWriteResult>();
      final repo = repoWith(
        blocked: [blockedOn('2026-03-25')],
        onUnblock: (id, date) => gate.future,
      );
      final container = await open(repo);

      final pending = notifierOf(container).toggle(_d('2026-03-25'));

      expect(blockedIn(container), isEmpty, reason: 'before the answer');
      expect(repo.unblocks.single, (id: _id, date: _d('2026-03-25')));
      expect(repo.blocks, isEmpty);
      gate.complete(right(unit));
      await pending;
    });

    test('a failed request blocks the day again', () async {
      final repo = repoWith(
        blocked: [blockedOn('2026-03-25')],
        onUnblock: (id, date) async => left(const NetworkFailure()),
      );
      final container = await open(repo);

      final result = await notifierOf(container).toggle(_d('2026-03-25'));

      expect(result.toNullable(), isA<NetworkFailure>());
      expect(blockedIn(container), {_d('2026-03-25')});
    });
  });

  group('rolling back touches only the day that failed', () {
    test('a day changed meanwhile stays changed', () async {
      final slowFailure = Completer<DayWriteResult>();
      final repo = repoWith(
        onBlock: (id, date) => date == _d('2026-03-25')
            ? slowFailure.future
            : Future.value(right(unit)),
      );
      final container = await open(repo);
      final notifier = notifierOf(container);

      final first = notifier.toggle(_d('2026-03-25'));
      await notifier.toggle(_d('2026-03-26'));
      slowFailure.complete(left(const NetworkFailure()));
      await first;

      expect(blockedIn(container), {_d('2026-03-26')});
    });
  });

  group('what cannot be blocked', () {
    test('a booked day: nothing changes and no request is made', () async {
      final repo = repoWith();
      final container = await open(repo);

      final result = await notifierOf(container).toggle(_d('2026-03-20'));

      expect(result.isNone(), isTrue);
      expect(blockedIn(container), isEmpty);
      expect(repo.blocks, isEmpty);
      expect(repo.unblocks, isEmpty);
    });

    test('a day taken for a reason we do not know', () async {
      final repo = repoWith();
      final container = await open(repo);

      await notifierOf(container).toggle(_d('2026-03-22'));

      expect(repo.blocks, isEmpty);
    });

    test(
      'a day that is both booked and blocked is booked: no unblock either',
      () async {
        final repo = repoWith(blocked: [blockedOn('2026-03-20')]);
        final container = await open(repo);

        await notifierOf(container).toggle(_d('2026-03-20'));

        expect(repo.unblocks, isEmpty);
        expect(blockedIn(container), {_d('2026-03-20')});
      },
    );

    test('a day before today', () async {
      final repo = repoWith();
      final container = await open(repo);

      await notifierOf(container).toggle(_d('2026-03-14'));

      expect(repo.blocks, isEmpty);
    });

    test('today itself can be blocked', () async {
      final repo = repoWith();
      final container = await open(repo);

      await notifierOf(container).toggle(fixedToday);

      expect(repo.blocks.single.date, fixedToday);
    });

    test('when blocking is switched off: a read-only calendar', () async {
      final repo = repoWith(blocked: [blockedOn('2026-03-25')]);
      final container = await open(repo, canBlock: false);

      await notifierOf(container).toggle(_d('2026-03-26'));
      await notifierOf(container).toggle(_d('2026-03-25'));

      expect(repo.blocks, isEmpty);
      expect(repo.unblocks, isEmpty);
      expect(blockedIn(container), {_d('2026-03-25')});
    });

    test(
      'a day whose month has not loaded yet: we do not know if it is booked',
      () async {
        final never = Completer<AvailabilityResult>();
        final repo = repoWith();
        final container = await open(
          repo,
          listings: ScriptedAvailabilityRepository(
            (id, window) => never.future,
          ),
          loadBooked: false,
        );

        await notifierOf(container).toggle(_d('2026-03-25'));

        expect(repo.blocks, isEmpty);
      },
    );

    test('a second tap on a day whose request is still out', () async {
      final gate = Completer<DayWriteResult>();
      final repo = repoWith(onBlock: (id, date) => gate.future);
      final container = await open(repo);
      final notifier = notifierOf(container);

      final first = notifier.toggle(_d('2026-03-25'));
      final second = await notifier.toggle(_d('2026-03-25'));

      expect(second.isNone(), isTrue);
      expect(repo.blocks, hasLength(1));
      expect(blockedIn(container), {_d('2026-03-25')});
      gate.complete(right(unit));
      await first;
    });
  });
}
