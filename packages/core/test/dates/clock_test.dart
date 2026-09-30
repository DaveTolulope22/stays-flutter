import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('by default it is the device date, read at each call', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final before = LocalDate.today();
    final today = container.read(clockProvider)();
    final after = LocalDate.today();

    // Either side of the call, so a test run across midnight cannot flake.
    expect(today, anyOf(before, after));
  });

  test('a test can pin it to a fixed date', () {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => LocalDate(2026, 3, 15)),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(clockProvider)(), LocalDate(2026, 3, 15));
    expect(container.read(clockProvider)(), LocalDate(2026, 3, 15));
  });

  test('it answers a new date when the clock moves (no stale day)', () {
    var now = LocalDate(2026, 3, 31);
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(() => now)],
    );
    addTearDown(container.dispose);
    final read = container.read(clockProvider);

    expect(read(), LocalDate(2026, 3, 31));
    now = now.addDays(1);

    expect(read(), LocalDate(2026, 4, 1));
  });
}
