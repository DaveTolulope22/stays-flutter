import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'blocked_day.freezed.dart';
part 'blocked_day.g.dart';

/// A night the host closed by hand. One row per day: blocking a week is seven
/// calls.
@freezed
abstract class BlockedDay with _$BlockedDay {
  const factory BlockedDay({
    required String listingId,
    @LocalDateConverter() required LocalDate date,
  }) = _BlockedDay;

  factory BlockedDay.fromJson(Map<String, dynamic> json) =>
      _$BlockedDayFromJson(json);
}
