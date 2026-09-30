// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListingFilter {

 String? get city;/// Listings whose `maxGuests` is at least this.
 int? get guests; num? get minPrice; num? get maxPrice;/// Check-in is `start` (inclusive), check-out is `end` (exclusive).
 DateRange? get dates; ListingSort get sort;
/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingFilterCopyWith<ListingFilter> get copyWith => _$ListingFilterCopyWithImpl<ListingFilter>(this as ListingFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ListingFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingFilter&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.guests, _this.guests) || other.guests == _this.guests)&&(identical(other.minPrice, _this.minPrice) || other.minPrice == _this.minPrice)&&(identical(other.maxPrice, _this.maxPrice) || other.maxPrice == _this.maxPrice)&&(identical(other.dates, _this.dates) || other.dates == _this.dates)&&(identical(other.sort, _this.sort) || other.sort == _this.sort));
}


@override
int get hashCode {
  final _this = this as ListingFilter;
  return Object.hash(runtimeType,_this.city,_this.guests,_this.minPrice,_this.maxPrice,_this.dates,_this.sort);
}

@override
String toString() {
  final _this = this as ListingFilter;
  return 'ListingFilter(city: ${_this.city}, guests: ${_this.guests}, minPrice: ${_this.minPrice}, maxPrice: ${_this.maxPrice}, dates: ${_this.dates}, sort: ${_this.sort})';
}


}

/// @nodoc
abstract mixin class $ListingFilterCopyWith<$Res>  {
  factory $ListingFilterCopyWith(ListingFilter value, $Res Function(ListingFilter) _then) = _$ListingFilterCopyWithImpl;
@useResult
$Res call({
 String? city, int? guests, num? minPrice, num? maxPrice, DateRange? dates, ListingSort sort
});




}
/// @nodoc
class _$ListingFilterCopyWithImpl<$Res>
    implements $ListingFilterCopyWith<$Res> {
  _$ListingFilterCopyWithImpl(this._self, this._then);

  final ListingFilter _self;
  final $Res Function(ListingFilter) _then;

/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? city = freezed,Object? guests = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? dates = freezed,Object? sort = null,}) {
  return _then(ListingFilter(
city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,guests: freezed == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as int?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as num?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as num?,dates: freezed == dates ? _self.dates : dates // ignore: cast_nullable_to_non_nullable
as DateRange?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ListingSort,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingFilter].
extension ListingFilterPatterns on ListingFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingFilter value)  $default,){
final _that = this;
switch (_that) {
case _ListingFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? city,  int? guests,  num? minPrice,  num? maxPrice,  DateRange? dates,  ListingSort sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
return $default(_that.city,_that.guests,_that.minPrice,_that.maxPrice,_that.dates,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? city,  int? guests,  num? minPrice,  num? maxPrice,  DateRange? dates,  ListingSort sort)  $default,) {final _that = this;
switch (_that) {
case _ListingFilter():
return $default(_that.city,_that.guests,_that.minPrice,_that.maxPrice,_that.dates,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? city,  int? guests,  num? minPrice,  num? maxPrice,  DateRange? dates,  ListingSort sort)?  $default,) {final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
return $default(_that.city,_that.guests,_that.minPrice,_that.maxPrice,_that.dates,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _ListingFilter extends ListingFilter {
  const _ListingFilter({this.city, this.guests, this.minPrice, this.maxPrice, this.dates, this.sort = ListingSort.newest}): super._();
  

@override final  String? city;
/// Listings whose `maxGuests` is at least this.
@override final  int? guests;
@override final  num? minPrice;
@override final  num? maxPrice;
/// Check-in is `start` (inclusive), check-out is `end` (exclusive).
@override final  DateRange? dates;
@override@JsonKey() final  ListingSort sort;

/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingFilterCopyWith<_ListingFilter> get copyWith => __$ListingFilterCopyWithImpl<_ListingFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingFilter&&(identical(other.city, city) || other.city == city)&&(identical(other.guests, guests) || other.guests == guests)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.dates, dates) || other.dates == dates)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode {
    return Object.hash(runtimeType,city,guests,minPrice,maxPrice,dates,sort);
}

@override
String toString() {
    return 'ListingFilter(city: $city, guests: $guests, minPrice: $minPrice, maxPrice: $maxPrice, dates: $dates, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$ListingFilterCopyWith<$Res> implements $ListingFilterCopyWith<$Res> {
  factory _$ListingFilterCopyWith(_ListingFilter value, $Res Function(_ListingFilter) _then) = __$ListingFilterCopyWithImpl;
@override @useResult
$Res call({
 String? city, int? guests, num? minPrice, num? maxPrice, DateRange? dates, ListingSort sort
});




}
/// @nodoc
class __$ListingFilterCopyWithImpl<$Res>
    implements _$ListingFilterCopyWith<$Res> {
  __$ListingFilterCopyWithImpl(this._self, this._then);

  final _ListingFilter _self;
  final $Res Function(_ListingFilter) _then;

/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? city = freezed,Object? guests = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? dates = freezed,Object? sort = null,}) {
  return _then(_ListingFilter(
city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,guests: freezed == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as int?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as num?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as num?,dates: freezed == dates ? _self.dates : dates // ignore: cast_nullable_to_non_nullable
as DateRange?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ListingSort,
  ));
}


}

// dart format on
