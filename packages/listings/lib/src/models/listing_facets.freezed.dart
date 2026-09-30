// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_facets.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingFacets {

 List<String> get cities; List<String> get propertyTypes; List<String> get amenities; num get priceMin; num get priceMax; int get maxGuests;/// The currency [priceMin] and [priceMax] are in.
 String get currency;
/// Create a copy of ListingFacets
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingFacetsCopyWith<ListingFacets> get copyWith => _$ListingFacetsCopyWithImpl<ListingFacets>(this as ListingFacets, _$identity);

  /// Serializes this ListingFacets to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingFacets;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingFacets&&const DeepCollectionEquality().equals(other.cities, _this.cities)&&const DeepCollectionEquality().equals(other.propertyTypes, _this.propertyTypes)&&const DeepCollectionEquality().equals(other.amenities, _this.amenities)&&(identical(other.priceMin, _this.priceMin) || other.priceMin == _this.priceMin)&&(identical(other.priceMax, _this.priceMax) || other.priceMax == _this.priceMax)&&(identical(other.maxGuests, _this.maxGuests) || other.maxGuests == _this.maxGuests)&&(identical(other.currency, _this.currency) || other.currency == _this.currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingFacets;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.cities),const DeepCollectionEquality().hash(_this.propertyTypes),const DeepCollectionEquality().hash(_this.amenities),_this.priceMin,_this.priceMax,_this.maxGuests,_this.currency);
}

@override
String toString() {
  final _this = this as ListingFacets;
  return 'ListingFacets(cities: ${_this.cities}, propertyTypes: ${_this.propertyTypes}, amenities: ${_this.amenities}, priceMin: ${_this.priceMin}, priceMax: ${_this.priceMax}, maxGuests: ${_this.maxGuests}, currency: ${_this.currency})';
}


}

/// @nodoc
abstract mixin class $ListingFacetsCopyWith<$Res>  {
  factory $ListingFacetsCopyWith(ListingFacets value, $Res Function(ListingFacets) _then) = _$ListingFacetsCopyWithImpl;
@useResult
$Res call({
 List<String> cities, List<String> propertyTypes, List<String> amenities, num priceMin, num priceMax, int maxGuests, String currency
});




}
/// @nodoc
class _$ListingFacetsCopyWithImpl<$Res>
    implements $ListingFacetsCopyWith<$Res> {
  _$ListingFacetsCopyWithImpl(this._self, this._then);

  final ListingFacets _self;
  final $Res Function(ListingFacets) _then;

/// Create a copy of ListingFacets
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cities = null,Object? propertyTypes = null,Object? amenities = null,Object? priceMin = null,Object? priceMax = null,Object? maxGuests = null,Object? currency = null,}) {
  return _then(ListingFacets(
cities: null == cities ? _self.cities : cities // ignore: cast_nullable_to_non_nullable
as List<String>,propertyTypes: null == propertyTypes ? _self.propertyTypes : propertyTypes // ignore: cast_nullable_to_non_nullable
as List<String>,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,priceMin: null == priceMin ? _self.priceMin : priceMin // ignore: cast_nullable_to_non_nullable
as num,priceMax: null == priceMax ? _self.priceMax : priceMax // ignore: cast_nullable_to_non_nullable
as num,maxGuests: null == maxGuests ? _self.maxGuests : maxGuests // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingFacets].
extension ListingFacetsPatterns on ListingFacets {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingFacets value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingFacets() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingFacets value)  $default,){
final _that = this;
switch (_that) {
case _ListingFacets():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingFacets value)?  $default,){
final _that = this;
switch (_that) {
case _ListingFacets() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> cities,  List<String> propertyTypes,  List<String> amenities,  num priceMin,  num priceMax,  int maxGuests,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingFacets() when $default != null:
return $default(_that.cities,_that.propertyTypes,_that.amenities,_that.priceMin,_that.priceMax,_that.maxGuests,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> cities,  List<String> propertyTypes,  List<String> amenities,  num priceMin,  num priceMax,  int maxGuests,  String currency)  $default,) {final _that = this;
switch (_that) {
case _ListingFacets():
return $default(_that.cities,_that.propertyTypes,_that.amenities,_that.priceMin,_that.priceMax,_that.maxGuests,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> cities,  List<String> propertyTypes,  List<String> amenities,  num priceMin,  num priceMax,  int maxGuests,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _ListingFacets() when $default != null:
return $default(_that.cities,_that.propertyTypes,_that.amenities,_that.priceMin,_that.priceMax,_that.maxGuests,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingFacets implements ListingFacets {
  const _ListingFacets({required  List<String> cities, required  List<String> propertyTypes, required  List<String> amenities, required this.priceMin, required this.priceMax, required this.maxGuests, required this.currency}): _cities = cities,_propertyTypes = propertyTypes,_amenities = amenities;
  factory _ListingFacets.fromJson(Map<String, dynamic> json) => _$ListingFacetsFromJson(json);

 final  List<String> _cities;
@override List<String> get cities {
  if (_cities is EqualUnmodifiableListView) return _cities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cities);
}

 final  List<String> _propertyTypes;
@override List<String> get propertyTypes {
  if (_propertyTypes is EqualUnmodifiableListView) return _propertyTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_propertyTypes);
}

 final  List<String> _amenities;
@override List<String> get amenities {
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amenities);
}

@override final  num priceMin;
@override final  num priceMax;
@override final  int maxGuests;
/// The currency [priceMin] and [priceMax] are in.
@override final  String currency;

/// Create a copy of ListingFacets
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingFacetsCopyWith<_ListingFacets> get copyWith => __$ListingFacetsCopyWithImpl<_ListingFacets>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingFacetsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingFacets&&const DeepCollectionEquality().equals(other.cities, _cities)&&const DeepCollectionEquality().equals(other.propertyTypes, _propertyTypes)&&const DeepCollectionEquality().equals(other.amenities, _amenities)&&(identical(other.priceMin, priceMin) || other.priceMin == priceMin)&&(identical(other.priceMax, priceMax) || other.priceMax == priceMax)&&(identical(other.maxGuests, maxGuests) || other.maxGuests == maxGuests)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_cities),const DeepCollectionEquality().hash(_propertyTypes),const DeepCollectionEquality().hash(_amenities),priceMin,priceMax,maxGuests,currency);
}

@override
String toString() {
    return 'ListingFacets(cities: $cities, propertyTypes: $propertyTypes, amenities: $amenities, priceMin: $priceMin, priceMax: $priceMax, maxGuests: $maxGuests, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$ListingFacetsCopyWith<$Res> implements $ListingFacetsCopyWith<$Res> {
  factory _$ListingFacetsCopyWith(_ListingFacets value, $Res Function(_ListingFacets) _then) = __$ListingFacetsCopyWithImpl;
@override @useResult
$Res call({
 List<String> cities, List<String> propertyTypes, List<String> amenities, num priceMin, num priceMax, int maxGuests, String currency
});




}
/// @nodoc
class __$ListingFacetsCopyWithImpl<$Res>
    implements _$ListingFacetsCopyWith<$Res> {
  __$ListingFacetsCopyWithImpl(this._self, this._then);

  final _ListingFacets _self;
  final $Res Function(_ListingFacets) _then;

/// Create a copy of ListingFacets
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cities = null,Object? propertyTypes = null,Object? amenities = null,Object? priceMin = null,Object? priceMax = null,Object? maxGuests = null,Object? currency = null,}) {
  return _then(_ListingFacets(
cities: null == cities ? _self._cities : cities // ignore: cast_nullable_to_non_nullable
as List<String>,propertyTypes: null == propertyTypes ? _self._propertyTypes : propertyTypes // ignore: cast_nullable_to_non_nullable
as List<String>,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,priceMin: null == priceMin ? _self.priceMin : priceMin // ignore: cast_nullable_to_non_nullable
as num,priceMax: null == priceMax ? _self.priceMax : priceMax // ignore: cast_nullable_to_non_nullable
as num,maxGuests: null == maxGuests ? _self.maxGuests : maxGuests // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
