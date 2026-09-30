import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'availability.freezed.dart';
part 'availability.g.dart';

/// Why a day is taken.
enum UnavailableReason {
  /// A booking that is not cancelled covers it.
  booked,

  /// The host closed it by hand.
  blocked,

  /// A reason this app does not know. The day is still taken.
  unknown,
}

/// `GET /listings/{id}/availability`, for the half-open window `[from, to)`.
/// Free days are absent, so [unavailable] lists only the taken ones.
@freezed
abstract class Availability with _$Availability {
  const Availability._();

  const factory Availability({
    required String listingId,
    @LocalDateConverter() required LocalDate from,
    @LocalDateConverter() required LocalDate to,
    required List<UnavailableDay> unavailable,
  }) = _Availability;

  factory Availability.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityFromJson(json);

  /// The taken days as a set, for constant-time lookups from a calendar cell.
  Set<LocalDate> get takenDates => {for (final day in unavailable) day.date};
}

@freezed
abstract class UnavailableDay with _$UnavailableDay {
  const factory UnavailableDay({
    @LocalDateConverter() required LocalDate date,
    @JsonKey(unknownEnumValue: UnavailableReason.unknown)
    required UnavailableReason reason,
  }) = _UnavailableDay;

  factory UnavailableDay.fromJson(Map<String, dynamic> json) =>
      _$UnavailableDayFromJson(json);
}
