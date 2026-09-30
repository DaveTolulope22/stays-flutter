// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'availability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Availability {

 String get listingId;@LocalDateConverter() LocalDate get from;@LocalDateConverter() LocalDate get to; List<UnavailableDay> get unavailable;
/// Create a copy of Availability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityCopyWith<Availability> get copyWith => _$AvailabilityCopyWithImpl<Availability>(this as Availability, _$identity);

  /// Serializes this Availability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Availability;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Availability&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&const DeepCollectionEquality().equals(other.unavailable, _this.unavailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Availability;
  return Object.hash(runtimeType,_this.listingId,_this.from,_this.to,const DeepCollectionEquality().hash(_this.unavailable));
}

@override
String toString() {
  final _this = this as Availability;
  return 'Availability(listingId: ${_this.listingId}, from: ${_this.from}, to: ${_this.to}, unavailable: ${_this.unavailable})';
}


}

/// @nodoc
abstract mixin class $AvailabilityCopyWith<$Res>  {
  factory $AvailabilityCopyWith(Availability value, $Res Function(Availability) _then) = _$AvailabilityCopyWithImpl;
@useResult
$Res call({
 String listingId,@LocalDateConverter() LocalDate from,@LocalDateConverter() LocalDate to, List<UnavailableDay> unavailable
});




}
/// @nodoc
class _$AvailabilityCopyWithImpl<$Res>
    implements $AvailabilityCopyWith<$Res> {
  _$AvailabilityCopyWithImpl(this._self, this._then);

  final Availability _self;
  final $Res Function(Availability) _then;

/// Create a copy of Availability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listingId = null,Object? from = null,Object? to = null,Object? unavailable = null,}) {
  return _then(Availability(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as LocalDate,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as LocalDate,unavailable: null == unavailable ? _self.unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as List<UnavailableDay>,
  ));
}

}


/// Adds pattern-matching-related methods to [Availability].
extension AvailabilityPatterns on Availability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Availability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Availability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Availability value)  $default,){
final _that = this;
switch (_that) {
case _Availability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Availability value)?  $default,){
final _that = this;
switch (_that) {
case _Availability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listingId, @LocalDateConverter()  LocalDate from, @LocalDateConverter()  LocalDate to,  List<UnavailableDay> unavailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Availability() when $default != null:
return $default(_that.listingId,_that.from,_that.to,_that.unavailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listingId, @LocalDateConverter()  LocalDate from, @LocalDateConverter()  LocalDate to,  List<UnavailableDay> unavailable)  $default,) {final _that = this;
switch (_that) {
case _Availability():
return $default(_that.listingId,_that.from,_that.to,_that.unavailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listingId, @LocalDateConverter()  LocalDate from, @LocalDateConverter()  LocalDate to,  List<UnavailableDay> unavailable)?  $default,) {final _that = this;
switch (_that) {
case _Availability() when $default != null:
return $default(_that.listingId,_that.from,_that.to,_that.unavailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Availability extends Availability {
  const _Availability({required this.listingId, @LocalDateConverter() required this.from, @LocalDateConverter() required this.to, required  List<UnavailableDay> unavailable}): _unavailable = unavailable,super._();
  factory _Availability.fromJson(Map<String, dynamic> json) => _$AvailabilityFromJson(json);

@override final  String listingId;
@override@LocalDateConverter() final  LocalDate from;
@override@LocalDateConverter() final  LocalDate to;
 final  List<UnavailableDay> _unavailable;
@override List<UnavailableDay> get unavailable {
  if (_unavailable is EqualUnmodifiableListView) return _unavailable;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unavailable);
}


/// Create a copy of Availability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityCopyWith<_Availability> get copyWith => __$AvailabilityCopyWithImpl<_Availability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Availability&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&const DeepCollectionEquality().equals(other.unavailable, _unavailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listingId,from,to,const DeepCollectionEquality().hash(_unavailable));
}

@override
String toString() {
    return 'Availability(listingId: $listingId, from: $from, to: $to, unavailable: $unavailable)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityCopyWith<$Res> implements $AvailabilityCopyWith<$Res> {
  factory _$AvailabilityCopyWith(_Availability value, $Res Function(_Availability) _then) = __$AvailabilityCopyWithImpl;
@override @useResult
$Res call({
 String listingId,@LocalDateConverter() LocalDate from,@LocalDateConverter() LocalDate to, List<UnavailableDay> unavailable
});




}
/// @nodoc
class __$AvailabilityCopyWithImpl<$Res>
    implements _$AvailabilityCopyWith<$Res> {
  __$AvailabilityCopyWithImpl(this._self, this._then);

  final _Availability _self;
  final $Res Function(_Availability) _then;

/// Create a copy of Availability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listingId = null,Object? from = null,Object? to = null,Object? unavailable = null,}) {
  return _then(_Availability(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as LocalDate,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as LocalDate,unavailable: null == unavailable ? _self._unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as List<UnavailableDay>,
  ));
}


}


/// @nodoc
mixin _$UnavailableDay {

@LocalDateConverter() LocalDate get date;@JsonKey(unknownEnumValue: UnavailableReason.unknown) UnavailableReason get reason;
/// Create a copy of UnavailableDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnavailableDayCopyWith<UnavailableDay> get copyWith => _$UnavailableDayCopyWithImpl<UnavailableDay>(this as UnavailableDay, _$identity);

  /// Serializes this UnavailableDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UnavailableDay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnavailableDay&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UnavailableDay;
  return Object.hash(runtimeType,_this.date,_this.reason);
}

@override
String toString() {
  final _this = this as UnavailableDay;
  return 'UnavailableDay(date: ${_this.date}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $UnavailableDayCopyWith<$Res>  {
  factory $UnavailableDayCopyWith(UnavailableDay value, $Res Function(UnavailableDay) _then) = _$UnavailableDayCopyWithImpl;
@useResult
$Res call({
@LocalDateConverter() LocalDate date,@JsonKey(unknownEnumValue: UnavailableReason.unknown) UnavailableReason reason
});




}
/// @nodoc
class _$UnavailableDayCopyWithImpl<$Res>
    implements $UnavailableDayCopyWith<$Res> {
  _$UnavailableDayCopyWithImpl(this._self, this._then);

  final UnavailableDay _self;
  final $Res Function(UnavailableDay) _then;

/// Create a copy of UnavailableDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? reason = null,}) {
  return _then(UnavailableDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as UnavailableReason,
  ));
}

}


/// Adds pattern-matching-related methods to [UnavailableDay].
extension UnavailableDayPatterns on UnavailableDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnavailableDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnavailableDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnavailableDay value)  $default,){
final _that = this;
switch (_that) {
case _UnavailableDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnavailableDay value)?  $default,){
final _that = this;
switch (_that) {
case _UnavailableDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LocalDateConverter()  LocalDate date, @JsonKey(unknownEnumValue: UnavailableReason.unknown)  UnavailableReason reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnavailableDay() when $default != null:
return $default(_that.date,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LocalDateConverter()  LocalDate date, @JsonKey(unknownEnumValue: UnavailableReason.unknown)  UnavailableReason reason)  $default,) {final _that = this;
switch (_that) {
case _UnavailableDay():
return $default(_that.date,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LocalDateConverter()  LocalDate date, @JsonKey(unknownEnumValue: UnavailableReason.unknown)  UnavailableReason reason)?  $default,) {final _that = this;
switch (_that) {
case _UnavailableDay() when $default != null:
return $default(_that.date,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnavailableDay implements UnavailableDay {
  const _UnavailableDay({@LocalDateConverter() required this.date, @JsonKey(unknownEnumValue: UnavailableReason.unknown) required this.reason});
  factory _UnavailableDay.fromJson(Map<String, dynamic> json) => _$UnavailableDayFromJson(json);

@override@LocalDateConverter() final  LocalDate date;
@override@JsonKey(unknownEnumValue: UnavailableReason.unknown) final  UnavailableReason reason;

/// Create a copy of UnavailableDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnavailableDayCopyWith<_UnavailableDay> get copyWith => __$UnavailableDayCopyWithImpl<_UnavailableDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnavailableDayToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnavailableDay&&(identical(other.date, date) || other.date == date)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,reason);
}

@override
String toString() {
    return 'UnavailableDay(date: $date, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$UnavailableDayCopyWith<$Res> implements $UnavailableDayCopyWith<$Res> {
  factory _$UnavailableDayCopyWith(_UnavailableDay value, $Res Function(_UnavailableDay) _then) = __$UnavailableDayCopyWithImpl;
@override @useResult
$Res call({
@LocalDateConverter() LocalDate date,@JsonKey(unknownEnumValue: UnavailableReason.unknown) UnavailableReason reason
});




}
/// @nodoc
class __$UnavailableDayCopyWithImpl<$Res>
    implements _$UnavailableDayCopyWith<$Res> {
  __$UnavailableDayCopyWithImpl(this._self, this._then);

  final _UnavailableDay _self;
  final $Res Function(_UnavailableDay) _then;

/// Create a copy of UnavailableDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? reason = null,}) {
  return _then(_UnavailableDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as UnavailableReason,
  ));
}


}

// dart format on
