// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Listing _$ListingFromJson(Map<String, dynamic> json) => _Listing(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  hostId: json['hostId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  city: json['city'] as String,
  country: json['country'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  propertyType: json['propertyType'] as String,
  maxGuests: (json['maxGuests'] as num).toInt(),
  bedrooms: (json['bedrooms'] as num).toInt(),
  beds: (json['beds'] as num).toInt(),
  bathrooms: (json['bathrooms'] as num).toInt(),
  pricePerNight: json['pricePerNight'] as num,
  cleaningFee: json['cleaningFee'] as num,
  currency: json['currency'] as String,
  amenities: (json['amenities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  rating: (json['rating'] as num).toDouble(),
  reviewsCount: (json['reviewsCount'] as num).toInt(),
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ListingToJson(_Listing instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'hostId': instance.hostId,
  'title': instance.title,
  'description': instance.description,
  'city': instance.city,
  'country': instance.country,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'propertyType': instance.propertyType,
  'maxGuests': instance.maxGuests,
  'bedrooms': instance.bedrooms,
  'beds': instance.beds,
  'bathrooms': instance.bathrooms,
  'pricePerNight': instance.pricePerNight,
  'cleaningFee': instance.cleaningFee,
  'currency': instance.currency,
  'amenities': instance.amenities,
  'rating': instance.rating,
  'reviewsCount': instance.reviewsCount,
  'images': instance.images,
  'createdAt': instance.createdAt.toIso8601String(),
};
