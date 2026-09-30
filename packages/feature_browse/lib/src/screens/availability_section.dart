import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../state/listing_availability_provider.dart';
import '../state/listing_filter_controller.dart';

/// Which days of a listing are taken, one month at a time.
///
/// It opens on the month of the check-in the guest searched for (or the current
/// month), and draws the searched nights with an outline so the guest can see at
/// a glance whether their stay is free. A guest is not told why a day is taken:
/// booked and blocked days look the same.
class AvailabilitySection extends ConsumerStatefulWidget {
  const AvailabilitySection({required this.listingId, super.key});

  final String listingId;

  @override
  ConsumerState<AvailabilitySection> createState() =>
      _AvailabilitySectionState();
}

class _AvailabilitySectionState extends ConsumerState<AvailabilitySection> {
  /// The first day of the month on show.
  late LocalDate _month = _initialMonth();

  LocalDate _initialMonth() {
    final today = ref.read(clockProvider)();
    // Read once: the month follows the guest's navigation from here on.
    final stay = ref.read(listingFilterControllerProvider).dates;
    return clampShownMonth(firstOfMonth(stay?.start ?? today), today);
  }

  CalendarDayAppearance _appearance(
    LocalDate date, {
    required LocalDate today,
    required Set<LocalDate> taken,
    required DateRange? stay,
  }) {
    final inStay = stay?.contains(date) ?? false;
    if (date < today) {
      return CalendarDayAppearance(
        style: CalendarDayStyle.muted,
        outlined: inStay,
      );
    }
    return CalendarDayAppearance(
      style: taken.contains(date)
          ? CalendarDayStyle.marked
          : CalendarDayStyle.plain,
      outlined: inStay,
    );
  }

  String _label(
    BuildContext context,
    LocalDate date,
    CalendarDayAppearance look,
  ) {
    final l10n = context.l10n;
    final day = MaterialLocalizations.of(context)
        .formatFullDate(DateTime(date.year, date.month, date.day));
    final base = switch (look.style) {
      CalendarDayStyle.muted => l10n.availabilityDayPast(day),
      // A guest's calendar only draws `marked` (see `_appearance`), but the
      // switch must cover every style: a day set apart at all is taken.
      CalendarDayStyle.marked ||
      CalendarDayStyle.struck => l10n.availabilityDayTaken(day),
      CalendarDayStyle.plain => l10n.availabilityDayAvailable(day),
    };
    return look.outlined ? l10n.availabilityDayInStay(base) : base;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = ref.read(clockProvider)();
    final stay = ref.watch(
      listingFilterControllerProvider.select((filter) => filter.dates),
    );
    final availability = ref.watch(
      listingAvailabilityProvider(widget.listingId, _month),
    );
    final taken = availability.value?.takenDates ?? const <LocalDate>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonthCalendar(
          month: _month,
          appearance: (date) =>
              _appearance(date, today: today, taken: taken, stay: stay),
          label: (date, look) => _label(context, date, look),
          previousTooltip: l10n.availabilityPrevious,
          nextTooltip: l10n.availabilityNext,
          onPrevious: _month > firstShownMonth(today)
              ? () => setState(() => _month = addMonths(_month, -1))
              : null,
          onNext: _month < lastShownMonth(today)
              ? () => setState(() => _month = addMonths(_month, 1))
              : null,
          status: availability.when<Widget?>(
            loading: () => LoadingView(semanticsLabel: l10n.loading),
            error: (error, _) => ErrorView(
              message: error is AppFailure
                  ? failureMessage(error, l10n)
                  : l10n.errorGeneric,
              action: ViewAction(
                label: l10n.retry,
                onPressed: () => ref.invalidate(
                  listingAvailabilityProvider(widget.listingId, _month),
                ),
              ),
            ),
            data: (_) => null,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Wrap(
          spacing: AppSpacing.m,
          children: [
            CalendarDayKey(
              appearance: const CalendarDayAppearance(),
              label: l10n.availabilityLegendAvailable,
            ),
            CalendarDayKey(
              appearance: const CalendarDayAppearance(
                style: CalendarDayStyle.marked,
              ),
              label: l10n.availabilityLegendTaken,
            ),
            if (stay != null)
              CalendarDayKey(
                appearance: const CalendarDayAppearance(outlined: true),
                label: l10n.availabilityLegendYourDates,
              ),
          ],
        ),
      ],
    );
  }
}
