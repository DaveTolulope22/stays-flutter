// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_flags.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TenantFlags _$TenantFlagsFromJson(Map<String, dynamic> json) => _TenantFlags(
  hostPanel: json['hostPanel'] as bool? ?? false,
  favourites: json['favourites'] as bool? ?? false,
  reviews: json['reviews'] as bool? ?? false,
  blockedDays: json['blockedDays'] as bool? ?? false,
);

Map<String, dynamic> _$TenantFlagsToJson(_TenantFlags instance) =>
    <String, dynamic>{
      'hostPanel': instance.hostPanel,
      'favourites': instance.favourites,
      'reviews': instance.reviews,
      'blockedDays': instance.blockedDays,
    };
