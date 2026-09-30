import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../state/booked_days.dart';
import '../state/host_blocked_days.dart';

/// One listing's calendar, for the host: which days a guest has booked (fixed),
/// which the host closed (tap to open again) and which are free (tap to close).
///
/// A tap changes the day at once and is undone, with a message, if the request
/// fails. Booked days and days before today are not tappable. With blocking
/// switched off for the tenant the same calendar is view only: nothing is
/// tappable and a note says why.
///
/// It opens on the current month and goes up to a year ahead, like the guest's
/// calendar.
class HostCalendarScreen extends ConsumerStatefulWidget {
  const HostCalendarScreen({required this.listingId, super.key});

  final String listingId;

  @override
  ConsumerState<HostCalendarScreen> createState() => _HostCalendarScreenState();
}

class _HostCalendarScreenState extends ConsumerState<HostCalendarScreen> {
  /// The first day of the month on show.
  late LocalDate _month = firstShownMonth(ref.read(clockProvider)());

  CalendarDayAppearance _appearance(
    LocalDate date, {
    required LocalDate today,
    required Set<LocalDate> booked,
    required Set<LocalDate> blocked,
    required bool canBlock,
  }) {
    if (date < today) {
      return const CalendarDayAppearance(style: CalendarDayStyle.muted);
    }
    // Booked wins over blocked, as it does in the API: a day that is both is
    // booked, and a guest's stay is not the host's to change.
    if (booked.contains(date)) {
      return const CalendarDayAppearance(style: CalendarDayStyle.marked);
    }
    return CalendarDayAppearance(
      style: blocked.contains(date)
          ? CalendarDayStyle.struck
          : CalendarDayStyle.plain,
      tappable: canBlock,
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
    return switch (look.style) {
      CalendarDayStyle.muted => l10n.availabilityDayPast(day),
      CalendarDayStyle.marked => l10n.hostCalendarDayBooked(day),
      CalendarDayStyle.struck =>
        look.tappable
            ? l10n.hostCalendarDayBlockedTap(day)
            : l10n.hostCalendarDayBlocked(day),
      CalendarDayStyle.plain =>
        look.tappable
            ? l10n.hostCalendarDayFreeTap(day)
            : l10n.availabilityDayAvailable(day),
    };
  }

  Future<void> _toggle(LocalDate date) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final failure = await ref
        .read(hostBlockedDaysProvider(widget.listingId).notifier)
        .toggle(date);
    // The day has already gone back; say why, in our own words.
    failure.match(
      () {},
      (failure) => messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(failure, l10n))),
      ),
    );
  }

  void _retry() {
    ref.invalidate(hostBlockedDaysProvider(widget.listingId));
    ref.invalidate(bookedDaysProvider(widget.listingId, _month));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = ref.read(clockProvider)();
    final canBlock = ref.watch(
      capabilitiesProvider.select((capabilities) => capabilities.canBlockDays),
    );
    final blockedAsync = ref.watch(hostBlockedDaysProvider(widget.listingId));
    final bookedAsync = ref.watch(bookedDaysProvider(widget.listingId, _month));
    final blocked = blockedAsync.value ?? const <LocalDate>{};
    final booked = bookedAsync.value ?? const <LocalDate>{};

    final error = blockedAsync.error ?? bookedAsync.error;
    final Widget? status = error != null
        ? ErrorView(
            message: error is AppFailure
                ? failureMessage(error, l10n)
                : l10n.errorGeneric,
            action: ViewAction(label: l10n.retry, onPressed: _retry),
          )
        : !blockedAsync.hasValue || !bookedAsync.hasValue
        ? LoadingView(semanticsLabel: l10n.loading)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hostActionCalendar)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Note(
                  icon: canBlock
                      ? Icons.touch_app_outlined
                      : Icons.info_outline,
                  text: canBlock
                      ? l10n.hostCalendarHint
                      : l10n.hostCalendarReadOnly,
                ),
                const SizedBox(height: AppSpacing.m),
                MonthCalendar(
                  month: _month,
                  appearance: (date) => _appearance(
                    date,
                    today: today,
                    booked: booked,
                    blocked: blocked,
                    canBlock: canBlock,
                  ),
                  label: (date, look) => _label(context, date, look),
                  previousTooltip: l10n.availabilityPrevious,
                  nextTooltip: l10n.availabilityNext,
                  onPrevious: _month > firstShownMonth(today)
                      ? () => setState(() => _month = addMonths(_month, -1))
                      : null,
                  onNext: _month < lastShownMonth(today)
                      ? () => setState(() => _month = addMonths(_month, 1))
                      : null,
                  onDayTap: canBlock ? _toggle : null,
                  status: status,
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
                      label: l10n.hostCalendarLegendBooked,
                    ),
                    CalendarDayKey(
                      appearance: const CalendarDayAppearance(
                        style: CalendarDayStyle.struck,
                      ),
                      label: l10n.hostCalendarLegendBlocked,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A line of guidance above the calendar: what a tap does, or why it does
/// nothing. An icon AND words.
class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconM),
        const SizedBox(width: AppSpacing.s),
        Expanded(child: Text(text)),
      ],
    );
  }
}
