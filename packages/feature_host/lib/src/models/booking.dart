import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

/// Where a booking stands. The API sends it as a plain string.
enum BookingStatus {
  /// Upcoming and paid for.
  confirmed,

  /// Upcoming, not yet confirmed.
  pending,

  /// The stay is in the past.
  completed,

  /// Called off. The only status that frees the calendar.
  cancelled,

  /// A status this app does not know. It still shows, with a generic label.
  unknown,
}

/// One booking on a host's listing. Nobody books through the app: the host only
/// reads these.
@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String listingId,
    required String tenantId,
    required String guestName,

    /// Inclusive. A date without a time, so a [LocalDate], never a `DateTime`.
    @LocalDateConverter() required LocalDate checkIn,

    /// Exclusive: the guest leaves this morning, so back-to-back stays do not
    /// clash.
    @LocalDateConverter() required LocalDate checkOut,
    required int guests,
    @JsonKey(unknownEnumValue: BookingStatus.unknown)
    required BookingStatus status,

    /// As at booking time. A later price edit does not restate it. A `num`
    /// because the API may send `480` or `480.5`.
    required num totalPrice,
    required String currency,
    required DateTime createdAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
