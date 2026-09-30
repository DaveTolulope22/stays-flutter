// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blocked_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BlockedDay {

 String get listingId;@LocalDateConverter() LocalDate get date;
/// Create a copy of BlockedDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockedDayCopyWith<BlockedDay> get copyWith => _$BlockedDayCopyWithImpl<BlockedDay>(this as BlockedDay, _$identity);

  /// Serializes this BlockedDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BlockedDay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockedDay&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&(identical(other.date, _this.date) || other.date == _this.date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BlockedDay;
  return Object.hash(runtimeType,_this.listingId,_this.date);
}

@override
String toString() {
  final _this = this as BlockedDay;
  return 'BlockedDay(listingId: ${_this.listingId}, date: ${_this.date})';
}


}

/// @nodoc
abstract mixin class $BlockedDayCopyWith<$Res>  {
  factory $BlockedDayCopyWith(BlockedDay value, $Res Function(BlockedDay) _then) = _$BlockedDayCopyWithImpl;
@useResult
$Res call({
 String listingId,@LocalDateConverter() LocalDate date
});




}
/// @nodoc
class _$BlockedDayCopyWithImpl<$Res>
    implements $BlockedDayCopyWith<$Res> {
  _$BlockedDayCopyWithImpl(this._self, this._then);

  final BlockedDay _self;
  final $Res Function(BlockedDay) _then;

/// Create a copy of BlockedDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listingId = null,Object? date = null,}) {
  return _then(BlockedDay(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockedDay].
extension BlockedDayPatterns on BlockedDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockedDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockedDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockedDay value)  $default,){
final _that = this;
switch (_that) {
case _BlockedDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockedDay value)?  $default,){
final _that = this;
switch (_that) {
case _BlockedDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listingId, @LocalDateConverter()  LocalDate date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockedDay() when $default != null:
return $default(_that.listingId,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listingId, @LocalDateConverter()  LocalDate date)  $default,) {final _that = this;
switch (_that) {
case _BlockedDay():
return $default(_that.listingId,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listingId, @LocalDateConverter()  LocalDate date)?  $default,) {final _that = this;
switch (_that) {
case _BlockedDay() when $default != null:
return $default(_that.listingId,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BlockedDay implements BlockedDay {
  const _BlockedDay({required this.listingId, @LocalDateConverter() required this.date});
  factory _BlockedDay.fromJson(Map<String, dynamic> json) => _$BlockedDayFromJson(json);

@override final  String listingId;
@override@LocalDateConverter() final  LocalDate date;

/// Create a copy of BlockedDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockedDayCopyWith<_BlockedDay> get copyWith => __$BlockedDayCopyWithImpl<_BlockedDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockedDayToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockedDay&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listingId,date);
}

@override
String toString() {
    return 'BlockedDay(listingId: $listingId, date: $date)';
}


}

/// @nodoc
abstract mixin class _$BlockedDayCopyWith<$Res> implements $BlockedDayCopyWith<$Res> {
  factory _$BlockedDayCopyWith(_BlockedDay value, $Res Function(_BlockedDay) _then) = __$BlockedDayCopyWithImpl;
@override @useResult
$Res call({
 String listingId,@LocalDateConverter() LocalDate date
});




}
/// @nodoc
class __$BlockedDayCopyWithImpl<$Res>
    implements _$BlockedDayCopyWith<$Res> {
  __$BlockedDayCopyWithImpl(this._self, this._then);

  final _BlockedDay _self;
  final $Res Function(_BlockedDay) _then;

/// Create a copy of BlockedDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listingId = null,Object? date = null,}) {
  return _then(_BlockedDay(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}


}

// dart format on
