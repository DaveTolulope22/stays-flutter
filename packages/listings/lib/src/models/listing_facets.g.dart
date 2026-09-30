// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_facets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingFacets _$ListingFacetsFromJson(Map<String, dynamic> json) =>
    _ListingFacets(
      cities: (json['cities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      propertyTypes: (json['propertyTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      amenities: (json['amenities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      priceMin: json['priceMin'] as num,
      priceMax: json['priceMax'] as num,
      maxGuests: (json['maxGuests'] as num).toInt(),
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$ListingFacetsToJson(_ListingFacets instance) =>
    <String, dynamic>{
      'cities': instance.cities,
      'propertyTypes': instance.propertyTypes,
      'amenities': instance.amenities,
      'priceMin': instance.priceMin,
      'priceMax': instance.priceMax,
      'maxGuests': instance.maxGuests,
      'currency': instance.currency,
    };
