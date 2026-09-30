// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingPatch _$ListingPatchFromJson(Map<String, dynamic> json) =>
    _ListingPatch(
      title: json['title'] as String?,
      description: json['description'] as String?,
      pricePerNight: json['pricePerNight'] as num?,
      cleaningFee: json['cleaningFee'] as num?,
      maxGuests: (json['maxGuests'] as num?)?.toInt(),
      bedrooms: (json['bedrooms'] as num?)?.toInt(),
      beds: (json['beds'] as num?)?.toInt(),
      bathrooms: (json['bathrooms'] as num?)?.toInt(),
      propertyType: json['propertyType'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ListingPatchToJson(_ListingPatch instance) =>
    <String, dynamic>{
      'title': ?instance.title,
      'description': ?instance.description,
      'pricePerNight': ?instance.pricePerNight,
      'cleaningFee': ?instance.cleaningFee,
      'maxGuests': ?instance.maxGuests,
      'bedrooms': ?instance.bedrooms,
      'beds': ?instance.beds,
      'bathrooms': ?instance.bathrooms,
      'propertyType': ?instance.propertyType,
      'amenities': ?instance.amenities,
    };
