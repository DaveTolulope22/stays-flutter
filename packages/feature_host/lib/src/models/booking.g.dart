// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  listingId: json['listingId'] as String,
  tenantId: json['tenantId'] as String,
  guestName: json['guestName'] as String,
  checkIn: const LocalDateConverter().fromJson(json['checkIn'] as String),
  checkOut: const LocalDateConverter().fromJson(json['checkOut'] as String),
  guests: (json['guests'] as num).toInt(),
  status: $enumDecode(
    _$BookingStatusEnumMap,
    json['status'],
    unknownValue: BookingStatus.unknown,
  ),
  totalPrice: json['totalPrice'] as num,
  currency: json['currency'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'listingId': instance.listingId,
  'tenantId': instance.tenantId,
  'guestName': instance.guestName,
  'checkIn': const LocalDateConverter().toJson(instance.checkIn),
  'checkOut': const LocalDateConverter().toJson(instance.checkOut),
  'guests': instance.guests,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'totalPrice': instance.totalPrice,
  'currency': instance.currency,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$BookingStatusEnumMap = {
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.pending: 'pending',
  BookingStatus.completed: 'completed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.unknown: 'unknown',
};
