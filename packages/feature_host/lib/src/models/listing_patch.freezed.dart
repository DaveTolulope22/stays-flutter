// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_patch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingPatch {

 String? get title; String? get description; num? get pricePerNight; num? get cleaningFee; int? get maxGuests; int? get bedrooms; int? get beds; int? get bathrooms; String? get propertyType; List<String>? get amenities;
/// Create a copy of ListingPatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingPatchCopyWith<ListingPatch> get copyWith => _$ListingPatchCopyWithImpl<ListingPatch>(this as ListingPatch, _$identity);

  /// Serializes this ListingPatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingPatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingPatch&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.pricePerNight, _this.pricePerNight) || other.pricePerNight == _this.pricePerNight)&&(identical(other.cleaningFee, _this.cleaningFee) || other.cleaningFee == _this.cleaningFee)&&(identical(other.maxGuests, _this.maxGuests) || other.maxGuests == _this.maxGuests)&&(identical(other.bedrooms, _this.bedrooms) || other.bedrooms == _this.bedrooms)&&(identical(other.beds, _this.beds) || other.beds == _this.beds)&&(identical(other.bathrooms, _this.bathrooms) || other.bathrooms == _this.bathrooms)&&(identical(other.propertyType, _this.propertyType) || other.propertyType == _this.propertyType)&&const DeepCollectionEquality().equals(other.amenities, _this.amenities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingPatch;
  return Object.hash(runtimeType,_this.title,_this.description,_this.pricePerNight,_this.cleaningFee,_this.maxGuests,_this.bedrooms,_this.beds,_this.bathrooms,_this.propertyType,const DeepCollectionEquality().hash(_this.amenities));
}

@override
String toString() {
  final _this = this as ListingPatch;
  return 'ListingPatch(title: ${_this.title}, description: ${_this.description}, pricePerNight: ${_this.pricePerNight}, cleaningFee: ${_this.cleaningFee}, maxGuests: ${_this.maxGuests}, bedrooms: ${_this.bedrooms}, beds: ${_this.beds}, bathrooms: ${_this.bathrooms}, propertyType: ${_this.propertyType}, amenities: ${_this.amenities})';
}


}

/// @nodoc
abstract mixin class $ListingPatchCopyWith<$Res>  {
  factory $ListingPatchCopyWith(ListingPatch value, $Res Function(ListingPatch) _then) = _$ListingPatchCopyWithImpl;
@useResult
$Res call({
 String? title, String? description, num? pricePerNight, num? cleaningFee, int? maxGuests, int? bedrooms, int? beds, int? bathrooms, String? propertyType, List<String>? amenities
});




}
/// @nodoc
class _$ListingPatchCopyWithImpl<$Res>
    implements $ListingPatchCopyWith<$Res> {
  _$ListingPatchCopyWithImpl(this._self, this._then);

  final ListingPatch _self;
  final $Res Function(ListingPatch) _then;

/// Create a copy of ListingPatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? description = freezed,Object? pricePerNight = freezed,Object? cleaningFee = freezed,Object? maxGuests = freezed,Object? bedrooms = freezed,Object? beds = freezed,Object? bathrooms = freezed,Object? propertyType = freezed,Object? amenities = freezed,}) {
  return _then(ListingPatch(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,pricePerNight: freezed == pricePerNight ? _self.pricePerNight : pricePerNight // ignore: cast_nullable_to_non_nullable
as num?,cleaningFee: freezed == cleaningFee ? _self.cleaningFee : cleaningFee // ignore: cast_nullable_to_non_nullable
as num?,maxGuests: freezed == maxGuests ? _self.maxGuests : maxGuests // ignore: cast_nullable_to_non_nullable
as int?,bedrooms: freezed == bedrooms ? _self.bedrooms : bedrooms // ignore: cast_nullable_to_non_nullable
as int?,beds: freezed == beds ? _self.beds : beds // ignore: cast_nullable_to_non_nullable
as int?,bathrooms: freezed == bathrooms ? _self.bathrooms : bathrooms // ignore: cast_nullable_to_non_nullable
as int?,propertyType: freezed == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as String?,amenities: freezed == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingPatch].
extension ListingPatchPatterns on ListingPatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingPatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingPatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingPatch value)  $default,){
final _that = this;
switch (_that) {
case _ListingPatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingPatch value)?  $default,){
final _that = this;
switch (_that) {
case _ListingPatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? description,  num? pricePerNight,  num? cleaningFee,  int? maxGuests,  int? bedrooms,  int? beds,  int? bathrooms,  String? propertyType,  List<String>? amenities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingPatch() when $default != null:
return $default(_that.title,_that.description,_that.pricePerNight,_that.cleaningFee,_that.maxGuests,_that.bedrooms,_that.beds,_that.bathrooms,_that.propertyType,_that.amenities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? description,  num? pricePerNight,  num? cleaningFee,  int? maxGuests,  int? bedrooms,  int? beds,  int? bathrooms,  String? propertyType,  List<String>? amenities)  $default,) {final _that = this;
switch (_that) {
case _ListingPatch():
return $default(_that.title,_that.description,_that.pricePerNight,_that.cleaningFee,_that.maxGuests,_that.bedrooms,_that.beds,_that.bathrooms,_that.propertyType,_that.amenities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? description,  num? pricePerNight,  num? cleaningFee,  int? maxGuests,  int? bedrooms,  int? beds,  int? bathrooms,  String? propertyType,  List<String>? amenities)?  $default,) {final _that = this;
switch (_that) {
case _ListingPatch() when $default != null:
return $default(_that.title,_that.description,_that.pricePerNight,_that.cleaningFee,_that.maxGuests,_that.bedrooms,_that.beds,_that.bathrooms,_that.propertyType,_that.amenities);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _ListingPatch extends ListingPatch {
  const _ListingPatch({this.title, this.description, this.pricePerNight, this.cleaningFee, this.maxGuests, this.bedrooms, this.beds, this.bathrooms, this.propertyType,  List<String>? amenities}): _amenities = amenities,super._();
  factory _ListingPatch.fromJson(Map<String, dynamic> json) => _$ListingPatchFromJson(json);

@override final  String? title;
@override final  String? description;
@override final  num? pricePerNight;
@override final  num? cleaningFee;
@override final  int? maxGuests;
@override final  int? bedrooms;
@override final  int? beds;
@override final  int? bathrooms;
@override final  String? propertyType;
 final  List<String>? _amenities;
@override List<String>? get amenities {
  final value = _amenities;
  if (value == null) return null;
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ListingPatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingPatchCopyWith<_ListingPatch> get copyWith => __$ListingPatchCopyWithImpl<_ListingPatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingPatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingPatch&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.pricePerNight, pricePerNight) || other.pricePerNight == pricePerNight)&&(identical(other.cleaningFee, cleaningFee) || other.cleaningFee == cleaningFee)&&(identical(other.maxGuests, maxGuests) || other.maxGuests == maxGuests)&&(identical(other.bedrooms, bedrooms) || other.bedrooms == bedrooms)&&(identical(other.beds, beds) || other.beds == beds)&&(identical(other.bathrooms, bathrooms) || other.bathrooms == bathrooms)&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&const DeepCollectionEquality().equals(other.amenities, _amenities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,description,pricePerNight,cleaningFee,maxGuests,bedrooms,beds,bathrooms,propertyType,const DeepCollectionEquality().hash(_amenities));
}

@override
String toString() {
    return 'ListingPatch(title: $title, description: $description, pricePerNight: $pricePerNight, cleaningFee: $cleaningFee, maxGuests: $maxGuests, bedrooms: $bedrooms, beds: $beds, bathrooms: $bathrooms, propertyType: $propertyType, amenities: $amenities)';
}


}

/// @nodoc
abstract mixin class _$ListingPatchCopyWith<$Res> implements $ListingPatchCopyWith<$Res> {
  factory _$ListingPatchCopyWith(_ListingPatch value, $Res Function(_ListingPatch) _then) = __$ListingPatchCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? description, num? pricePerNight, num? cleaningFee, int? maxGuests, int? bedrooms, int? beds, int? bathrooms, String? propertyType, List<String>? amenities
});




}
/// @nodoc
class __$ListingPatchCopyWithImpl<$Res>
    implements _$ListingPatchCopyWith<$Res> {
  __$ListingPatchCopyWithImpl(this._self, this._then);

  final _ListingPatch _self;
  final $Res Function(_ListingPatch) _then;

/// Create a copy of ListingPatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? description = freezed,Object? pricePerNight = freezed,Object? cleaningFee = freezed,Object? maxGuests = freezed,Object? bedrooms = freezed,Object? beds = freezed,Object? bathrooms = freezed,Object? propertyType = freezed,Object? amenities = freezed,}) {
  return _then(_ListingPatch(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,pricePerNight: freezed == pricePerNight ? _self.pricePerNight : pricePerNight // ignore: cast_nullable_to_non_nullable
as num?,cleaningFee: freezed == cleaningFee ? _self.cleaningFee : cleaningFee // ignore: cast_nullable_to_non_nullable
as num?,maxGuests: freezed == maxGuests ? _self.maxGuests : maxGuests // ignore: cast_nullable_to_non_nullable
as int?,bedrooms: freezed == bedrooms ? _self.bedrooms : bedrooms // ignore: cast_nullable_to_non_nullable
as int?,beds: freezed == beds ? _self.beds : beds // ignore: cast_nullable_to_non_nullable
as int?,bathrooms: freezed == bathrooms ? _self.bathrooms : bathrooms // ignore: cast_nullable_to_non_nullable
as int?,propertyType: freezed == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as String?,amenities: freezed == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
