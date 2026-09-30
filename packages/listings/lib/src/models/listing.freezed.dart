// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Listing {

 String get id; String get tenantId; String get hostId; String get title; String get description; String get city; String get country; String get address; double get latitude; double get longitude; String get propertyType; int get maxGuests;/// 0 for a studio.
 int get bedrooms; int get beds; int get bathrooms;/// Whole currency units: 249 means 249.00, not 249 cents.
 num get pricePerNight;/// Charged once per stay, not per night. May be 0.
 num get cleaningFee;/// From the row, never assumed from the tenant.
 String get currency;/// An open set of slugs. Kept as strings so an unknown one cannot fail the
/// decode; the UI degrades it to a humanised label.
 List<String> get amenities;/// 0 means "no reviews yet", not a zero score.
 double get rating; int get reviewsCount;/// At least one URL; the first is the cover.
 List<String> get images; DateTime get createdAt;
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingCopyWith<Listing> get copyWith => _$ListingCopyWithImpl<Listing>(this as Listing, _$identity);

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Listing;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Listing&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.tenantId, _this.tenantId) || other.tenantId == _this.tenantId)&&(identical(other.hostId, _this.hostId) || other.hostId == _this.hostId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.propertyType, _this.propertyType) || other.propertyType == _this.propertyType)&&(identical(other.maxGuests, _this.maxGuests) || other.maxGuests == _this.maxGuests)&&(identical(other.bedrooms, _this.bedrooms) || other.bedrooms == _this.bedrooms)&&(identical(other.beds, _this.beds) || other.beds == _this.beds)&&(identical(other.bathrooms, _this.bathrooms) || other.bathrooms == _this.bathrooms)&&(identical(other.pricePerNight, _this.pricePerNight) || other.pricePerNight == _this.pricePerNight)&&(identical(other.cleaningFee, _this.cleaningFee) || other.cleaningFee == _this.cleaningFee)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&const DeepCollectionEquality().equals(other.amenities, _this.amenities)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.reviewsCount, _this.reviewsCount) || other.reviewsCount == _this.reviewsCount)&&const DeepCollectionEquality().equals(other.images, _this.images)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Listing;
  return Object.hashAll([runtimeType,_this.id,_this.tenantId,_this.hostId,_this.title,_this.description,_this.city,_this.country,_this.address,_this.latitude,_this.longitude,_this.propertyType,_this.maxGuests,_this.bedrooms,_this.beds,_this.bathrooms,_this.pricePerNight,_this.cleaningFee,_this.currency,const DeepCollectionEquality().hash(_this.amenities),_this.rating,_this.reviewsCount,const DeepCollectionEquality().hash(_this.images),_this.createdAt]);
}

@override
String toString() {
  final _this = this as Listing;
  return 'Listing(id: ${_this.id}, tenantId: ${_this.tenantId}, hostId: ${_this.hostId}, title: ${_this.title}, description: ${_this.description}, city: ${_this.city}, country: ${_this.country}, address: ${_this.address}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, propertyType: ${_this.propertyType}, maxGuests: ${_this.maxGuests}, bedrooms: ${_this.bedrooms}, beds: ${_this.beds}, bathrooms: ${_this.bathrooms}, pricePerNight: ${_this.pricePerNight}, cleaningFee: ${_this.cleaningFee}, currency: ${_this.currency}, amenities: ${_this.amenities}, rating: ${_this.rating}, reviewsCount: ${_this.reviewsCount}, images: ${_this.images}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ListingCopyWith<$Res>  {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) _then) = _$ListingCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String hostId, String title, String description, String city, String country, String address, double latitude, double longitude, String propertyType, int maxGuests, int bedrooms, int beds, int bathrooms, num pricePerNight, num cleaningFee, String currency, List<String> amenities, double rating, int reviewsCount, List<String> images, DateTime createdAt
});




}
/// @nodoc
class _$ListingCopyWithImpl<$Res>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._self, this._then);

  final Listing _self;
  final $Res Function(Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? hostId = null,Object? title = null,Object? description = null,Object? city = null,Object? country = null,Object? address = null,Object? latitude = null,Object? longitude = null,Object? propertyType = null,Object? maxGuests = null,Object? bedrooms = null,Object? beds = null,Object? bathrooms = null,Object? pricePerNight = null,Object? cleaningFee = null,Object? currency = null,Object? amenities = null,Object? rating = null,Object? reviewsCount = null,Object? images = null,Object? createdAt = null,}) {
  return _then(Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as String,maxGuests: null == maxGuests ? _self.maxGuests : maxGuests // ignore: cast_nullable_to_non_nullable
as int,bedrooms: null == bedrooms ? _self.bedrooms : bedrooms // ignore: cast_nullable_to_non_nullable
as int,beds: null == beds ? _self.beds : beds // ignore: cast_nullable_to_non_nullable
as int,bathrooms: null == bathrooms ? _self.bathrooms : bathrooms // ignore: cast_nullable_to_non_nullable
as int,pricePerNight: null == pricePerNight ? _self.pricePerNight : pricePerNight // ignore: cast_nullable_to_non_nullable
as num,cleaningFee: null == cleaningFee ? _self.cleaningFee : cleaningFee // ignore: cast_nullable_to_non_nullable
as num,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewsCount: null == reviewsCount ? _self.reviewsCount : reviewsCount // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Listing].
extension ListingPatterns on Listing {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Listing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Listing value)  $default,){
final _that = this;
switch (_that) {
case _Listing():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Listing value)?  $default,){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String hostId,  String title,  String description,  String city,  String country,  String address,  double latitude,  double longitude,  String propertyType,  int maxGuests,  int bedrooms,  int beds,  int bathrooms,  num pricePerNight,  num cleaningFee,  String currency,  List<String> amenities,  double rating,  int reviewsCount,  List<String> images,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.tenantId,_that.hostId,_that.title,_that.description,_that.city,_that.country,_that.address,_that.latitude,_that.longitude,_that.propertyType,_that.maxGuests,_that.bedrooms,_that.beds,_that.bathrooms,_that.pricePerNight,_that.cleaningFee,_that.currency,_that.amenities,_that.rating,_that.reviewsCount,_that.images,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String hostId,  String title,  String description,  String city,  String country,  String address,  double latitude,  double longitude,  String propertyType,  int maxGuests,  int bedrooms,  int beds,  int bathrooms,  num pricePerNight,  num cleaningFee,  String currency,  List<String> amenities,  double rating,  int reviewsCount,  List<String> images,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Listing():
return $default(_that.id,_that.tenantId,_that.hostId,_that.title,_that.description,_that.city,_that.country,_that.address,_that.latitude,_that.longitude,_that.propertyType,_that.maxGuests,_that.bedrooms,_that.beds,_that.bathrooms,_that.pricePerNight,_that.cleaningFee,_that.currency,_that.amenities,_that.rating,_that.reviewsCount,_that.images,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String hostId,  String title,  String description,  String city,  String country,  String address,  double latitude,  double longitude,  String propertyType,  int maxGuests,  int bedrooms,  int beds,  int bathrooms,  num pricePerNight,  num cleaningFee,  String currency,  List<String> amenities,  double rating,  int reviewsCount,  List<String> images,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.tenantId,_that.hostId,_that.title,_that.description,_that.city,_that.country,_that.address,_that.latitude,_that.longitude,_that.propertyType,_that.maxGuests,_that.bedrooms,_that.beds,_that.bathrooms,_that.pricePerNight,_that.cleaningFee,_that.currency,_that.amenities,_that.rating,_that.reviewsCount,_that.images,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Listing extends Listing {
  const _Listing({required this.id, required this.tenantId, required this.hostId, required this.title, required this.description, required this.city, required this.country, required this.address, required this.latitude, required this.longitude, required this.propertyType, required this.maxGuests, required this.bedrooms, required this.beds, required this.bathrooms, required this.pricePerNight, required this.cleaningFee, required this.currency, required  List<String> amenities, required this.rating, required this.reviewsCount, required  List<String> images, required this.createdAt}): _amenities = amenities,_images = images,super._();
  factory _Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String hostId;
@override final  String title;
@override final  String description;
@override final  String city;
@override final  String country;
@override final  String address;
@override final  double latitude;
@override final  double longitude;
@override final  String propertyType;
@override final  int maxGuests;
/// 0 for a studio.
@override final  int bedrooms;
@override final  int beds;
@override final  int bathrooms;
/// Whole currency units: 249 means 249.00, not 249 cents.
@override final  num pricePerNight;
/// Charged once per stay, not per night. May be 0.
@override final  num cleaningFee;
/// From the row, never assumed from the tenant.
@override final  String currency;
/// An open set of slugs. Kept as strings so an unknown one cannot fail the
/// decode; the UI degrades it to a humanised label.
 final  List<String> _amenities;
/// An open set of slugs. Kept as strings so an unknown one cannot fail the
/// decode; the UI degrades it to a humanised label.
@override List<String> get amenities {
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amenities);
}

/// 0 means "no reviews yet", not a zero score.
@override final  double rating;
@override final  int reviewsCount;
/// At least one URL; the first is the cover.
 final  List<String> _images;
/// At least one URL; the first is the cover.
@override List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  DateTime createdAt;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingCopyWith<_Listing> get copyWith => __$ListingCopyWithImpl<_Listing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&(identical(other.maxGuests, maxGuests) || other.maxGuests == maxGuests)&&(identical(other.bedrooms, bedrooms) || other.bedrooms == bedrooms)&&(identical(other.beds, beds) || other.beds == beds)&&(identical(other.bathrooms, bathrooms) || other.bathrooms == bathrooms)&&(identical(other.pricePerNight, pricePerNight) || other.pricePerNight == pricePerNight)&&(identical(other.cleaningFee, cleaningFee) || other.cleaningFee == cleaningFee)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.amenities, _amenities)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewsCount, reviewsCount) || other.reviewsCount == reviewsCount)&&const DeepCollectionEquality().equals(other.images, _images)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,tenantId,hostId,title,description,city,country,address,latitude,longitude,propertyType,maxGuests,bedrooms,beds,bathrooms,pricePerNight,cleaningFee,currency,const DeepCollectionEquality().hash(_amenities),rating,reviewsCount,const DeepCollectionEquality().hash(_images),createdAt]);
}

@override
String toString() {
    return 'Listing(id: $id, tenantId: $tenantId, hostId: $hostId, title: $title, description: $description, city: $city, country: $country, address: $address, latitude: $latitude, longitude: $longitude, propertyType: $propertyType, maxGuests: $maxGuests, bedrooms: $bedrooms, beds: $beds, bathrooms: $bathrooms, pricePerNight: $pricePerNight, cleaningFee: $cleaningFee, currency: $currency, amenities: $amenities, rating: $rating, reviewsCount: $reviewsCount, images: $images, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ListingCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$ListingCopyWith(_Listing value, $Res Function(_Listing) _then) = __$ListingCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String hostId, String title, String description, String city, String country, String address, double latitude, double longitude, String propertyType, int maxGuests, int bedrooms, int beds, int bathrooms, num pricePerNight, num cleaningFee, String currency, List<String> amenities, double rating, int reviewsCount, List<String> images, DateTime createdAt
});




}
/// @nodoc
class __$ListingCopyWithImpl<$Res>
    implements _$ListingCopyWith<$Res> {
  __$ListingCopyWithImpl(this._self, this._then);

  final _Listing _self;
  final $Res Function(_Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? hostId = null,Object? title = null,Object? description = null,Object? city = null,Object? country = null,Object? address = null,Object? latitude = null,Object? longitude = null,Object? propertyType = null,Object? maxGuests = null,Object? bedrooms = null,Object? beds = null,Object? bathrooms = null,Object? pricePerNight = null,Object? cleaningFee = null,Object? currency = null,Object? amenities = null,Object? rating = null,Object? reviewsCount = null,Object? images = null,Object? createdAt = null,}) {
  return _then(_Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as String,maxGuests: null == maxGuests ? _self.maxGuests : maxGuests // ignore: cast_nullable_to_non_nullable
as int,bedrooms: null == bedrooms ? _self.bedrooms : bedrooms // ignore: cast_nullable_to_non_nullable
as int,beds: null == beds ? _self.beds : beds // ignore: cast_nullable_to_non_nullable
as int,bathrooms: null == bathrooms ? _self.bathrooms : bathrooms // ignore: cast_nullable_to_non_nullable
as int,pricePerNight: null == pricePerNight ? _self.pricePerNight : pricePerNight // ignore: cast_nullable_to_non_nullable
as num,cleaningFee: null == cleaningFee ? _self.cleaningFee : cleaningFee // ignore: cast_nullable_to_non_nullable
as num,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewsCount: null == reviewsCount ? _self.reviewsCount : reviewsCount // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
