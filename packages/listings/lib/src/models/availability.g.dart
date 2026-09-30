// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Availability _$AvailabilityFromJson(Map<String, dynamic> json) =>
    _Availability(
      listingId: json['listingId'] as String,
      from: const LocalDateConverter().fromJson(json['from'] as String),
      to: const LocalDateConverter().fromJson(json['to'] as String),
      unavailable: (json['unavailable'] as List<dynamic>)
          .map((e) => UnavailableDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AvailabilityToJson(_Availability instance) =>
    <String, dynamic>{
      'listingId': instance.listingId,
      'from': const LocalDateConverter().toJson(instance.from),
      'to': const LocalDateConverter().toJson(instance.to),
      'unavailable': instance.unavailable,
    };

_UnavailableDay _$UnavailableDayFromJson(Map<String, dynamic> json) =>
    _UnavailableDay(
      date: const LocalDateConverter().fromJson(json['date'] as String),
      reason: $enumDecode(
        _$UnavailableReasonEnumMap,
        json['reason'],
        unknownValue: UnavailableReason.unknown,
      ),
    );

Map<String, dynamic> _$UnavailableDayToJson(_UnavailableDay instance) =>
    <String, dynamic>{
      'date': const LocalDateConverter().toJson(instance.date),
      'reason': _$UnavailableReasonEnumMap[instance.reason]!,
    };

const _$UnavailableReasonEnumMap = {
  UnavailableReason.booked: 'booked',
  UnavailableReason.blocked: 'blocked',
  UnavailableReason.unknown: 'unknown',
};
