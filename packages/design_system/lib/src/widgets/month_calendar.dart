import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';

/// How a day is drawn. The names say how it looks, not what it means: the
/// caller decides that a "marked" day is taken, booked or blocked.
enum CalendarDayStyle {
  /// An ordinary day.
  plain,

  /// A day that is out of play (already gone): muted text.
  muted,

  /// A day that is set apart: a filled cell AND a strike-through on the number.
  /// Colour is never the only cue, so it reads without telling shades apart.
  marked,
}

/// How one day looks: its [style], and whether it carries an outline (a
/// highlight that can sit on top of any style, such as "part of your stay").
@immutable
class CalendarDayAppearance {
  const CalendarDayAppearance({
    this.style = CalendarDayStyle.plain,
    this.outlined = false,
  });

  final CalendarDayStyle style;
  final bool outlined;

  @override
  bool operator ==(Object other) =>
      other is CalendarDayAppearance &&
      other.style == style &&
      other.outlined == outlined;

  @override
  int get hashCode => Object.hash(style, outlined);
}

/// One month as a grid of days. It knows nothing about bookings: the caller says
/// how each day looks ([appearance]) and what a screen reader should say about
/// it ([label]). It holds no copy either: weekday and month names come from the
/// platform's localisation, and every word it shows is passed in.
///
/// The month is not stored here: [onPrevious] and [onNext] ask the caller to
/// change it, and a null one disables its button. While [status] is set (a
/// spinner, an error) it takes the place of the grid, in a box as tall as the
/// tallest month, so the layout does not jump.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    required this.month,
    required this.appearance,
    required this.label,
    required this.previousTooltip,
    required this.nextTooltip,
    this.onPrevious,
    this.onNext,
    this.status,
    super.key,
  });

  /// The most rows any month needs.
  static const maxRows = 6;

  /// Any day of the month to show; only its year and month are used.
  final LocalDate month;
  final CalendarDayAppearance Function(LocalDate date) appearance;
  final String Function(LocalDate date, CalendarDayAppearance appearance) label;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Widget? status;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final firstDay = DateTime(month.year, month.month);
    final status = this.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: previousTooltip,
              icon: Icon(Icons.chevron_left, semanticLabel: previousTooltip),
              onPressed: onPrevious,
            ),
            Expanded(
              child: Semantics(
                header: true,
                liveRegion: true,
                child: Text(
                  material.formatMonthYear(firstDay),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            IconButton(
              tooltip: nextTooltip,
              icon: Icon(Icons.chevron_right, semanticLabel: nextTooltip),
              onPressed: onNext,
            ),
          ],
        ),
        _WeekdayRow(material: material),
        if (status != null)
          SizedBox(height: AppSizes.calendarCell * maxRows, child: status)
        else
          _Grid(
            month: month,
            firstDay: firstDay,
            firstDayOfWeek: material.firstDayOfWeekIndex,
            appearance: appearance,
            label: label,
          ),
      ],
    );
  }
}

/// The weekday initials, starting on the locale's first day of the week. They
/// are decoration for sighted users; each day already says its full date.
class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.material});

  final MaterialLocalizations material;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: context.colors.textMuted);
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < DateTime.daysPerWeek; i++)
            Expanded(
              child: Center(
                child: Text(
                  material.narrowWeekdays[(material.firstDayOfWeekIndex + i) %
                      DateTime.daysPerWeek],
                  style: style,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.month,
    required this.firstDay,
    required this.firstDayOfWeek,
    required this.appearance,
    required this.label,
  });

  final LocalDate month;
  final DateTime firstDay;

  /// 0 is Sunday, as in `MaterialLocalizations.firstDayOfWeekIndex`.
  final int firstDayOfWeek;
  final CalendarDayAppearance Function(LocalDate date) appearance;
  final String Function(LocalDate date, CalendarDayAppearance appearance) label;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // DateTime.weekday is Monday 1 to Sunday 7; % 7 makes Sunday 0.
    final leadingBlanks =
        (firstDay.weekday % DateTime.daysPerWeek -
            firstDayOfWeek +
            DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    final rows = ((leadingBlanks + daysInMonth) / DateTime.daysPerWeek).ceil();

    Widget cell(int index) {
      final day = index - leadingBlanks + 1;
      if (day < 1 || day > daysInMonth) {
        return const SizedBox(height: AppSizes.calendarCell);
      }
      final date = LocalDate(month.year, month.month, day);
      final look = appearance(date);
      return SizedBox(
        height: AppSizes.calendarCell,
        child: Semantics(
          label: label(date, look),
          excludeSemantics: true,
          child: _DayBox(day: day, appearance: look),
        ),
      );
    }

    return Column(
      children: [
        for (var row = 0; row < rows; row++)
          Row(
            children: [
              for (var column = 0; column < DateTime.daysPerWeek; column++)
                Expanded(child: cell(row * DateTime.daysPerWeek + column)),
            ],
          ),
      ],
    );
  }
}

/// One day's number in its box. Shared by the grid and the legend, so a legend
/// sample is drawn exactly like the days it explains.
class _DayBox extends StatelessWidget {
  const _DayBox({required this.day, required this.appearance});

  final int day;
  final CalendarDayAppearance appearance;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = appearance.style;
    final marked = style == CalendarDayStyle.marked;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: marked ? colors.borderPrimary : null,
          borderRadius: AppRadius.mediumAll,
          border: appearance.outlined
              ? Border.all(
                  color: colors.surfaceAction,
                  width: AppSizes.calendarOutline,
                )
              : null,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: style == CalendarDayStyle.muted ? colors.textMuted : null,
              decoration: marked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// A legend entry: a sample day drawn like the days it explains, and its
/// [label]. Because the sample shares the grid's drawing, the strike-through of
/// a marked day shows here too.
class CalendarDayKey extends StatelessWidget {
  const CalendarDayKey({
    required this.appearance,
    required this.label,
    super.key,
  });

  /// Any day number will do; this one is only there to be drawn.
  static const _sampleDay = 12;

  final CalendarDayAppearance appearance;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: SizedBox(
            width: AppSizes.calendarCell,
            height: AppSizes.calendarCell,
            child: _DayBox(day: _sampleDay, appearance: appearance),
          ),
        ),
        Flexible(child: Text(label)),
      ],
    );
  }
}
