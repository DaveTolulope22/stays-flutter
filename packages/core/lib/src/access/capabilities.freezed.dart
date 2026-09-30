// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capabilities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Capabilities {

 AccessArea get area; bool get canSaveListings; bool get canSeeReviews; bool get canUseHostPanel; bool get canBlockDays;
/// Create a copy of Capabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapabilitiesCopyWith<Capabilities> get copyWith => _$CapabilitiesCopyWithImpl<Capabilities>(this as Capabilities, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Capabilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Capabilities&&(identical(other.area, _this.area) || other.area == _this.area)&&(identical(other.canSaveListings, _this.canSaveListings) || other.canSaveListings == _this.canSaveListings)&&(identical(other.canSeeReviews, _this.canSeeReviews) || other.canSeeReviews == _this.canSeeReviews)&&(identical(other.canUseHostPanel, _this.canUseHostPanel) || other.canUseHostPanel == _this.canUseHostPanel)&&(identical(other.canBlockDays, _this.canBlockDays) || other.canBlockDays == _this.canBlockDays));
}


@override
int get hashCode {
  final _this = this as Capabilities;
  return Object.hash(runtimeType,_this.area,_this.canSaveListings,_this.canSeeReviews,_this.canUseHostPanel,_this.canBlockDays);
}

@override
String toString() {
  final _this = this as Capabilities;
  return 'Capabilities(area: ${_this.area}, canSaveListings: ${_this.canSaveListings}, canSeeReviews: ${_this.canSeeReviews}, canUseHostPanel: ${_this.canUseHostPanel}, canBlockDays: ${_this.canBlockDays})';
}


}

/// @nodoc
abstract mixin class $CapabilitiesCopyWith<$Res>  {
  factory $CapabilitiesCopyWith(Capabilities value, $Res Function(Capabilities) _then) = _$CapabilitiesCopyWithImpl;
@useResult
$Res call({
 AccessArea area, bool canSaveListings, bool canSeeReviews, bool canUseHostPanel, bool canBlockDays
});




}
/// @nodoc
class _$CapabilitiesCopyWithImpl<$Res>
    implements $CapabilitiesCopyWith<$Res> {
  _$CapabilitiesCopyWithImpl(this._self, this._then);

  final Capabilities _self;
  final $Res Function(Capabilities) _then;

/// Create a copy of Capabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? area = null,Object? canSaveListings = null,Object? canSeeReviews = null,Object? canUseHostPanel = null,Object? canBlockDays = null,}) {
  return _then(Capabilities(
area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as AccessArea,canSaveListings: null == canSaveListings ? _self.canSaveListings : canSaveListings // ignore: cast_nullable_to_non_nullable
as bool,canSeeReviews: null == canSeeReviews ? _self.canSeeReviews : canSeeReviews // ignore: cast_nullable_to_non_nullable
as bool,canUseHostPanel: null == canUseHostPanel ? _self.canUseHostPanel : canUseHostPanel // ignore: cast_nullable_to_non_nullable
as bool,canBlockDays: null == canBlockDays ? _self.canBlockDays : canBlockDays // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Capabilities].
extension CapabilitiesPatterns on Capabilities {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Capabilities value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Capabilities() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Capabilities value)  $default,){
final _that = this;
switch (_that) {
case _Capabilities():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Capabilities value)?  $default,){
final _that = this;
switch (_that) {
case _Capabilities() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccessArea area,  bool canSaveListings,  bool canSeeReviews,  bool canUseHostPanel,  bool canBlockDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Capabilities() when $default != null:
return $default(_that.area,_that.canSaveListings,_that.canSeeReviews,_that.canUseHostPanel,_that.canBlockDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccessArea area,  bool canSaveListings,  bool canSeeReviews,  bool canUseHostPanel,  bool canBlockDays)  $default,) {final _that = this;
switch (_that) {
case _Capabilities():
return $default(_that.area,_that.canSaveListings,_that.canSeeReviews,_that.canUseHostPanel,_that.canBlockDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccessArea area,  bool canSaveListings,  bool canSeeReviews,  bool canUseHostPanel,  bool canBlockDays)?  $default,) {final _that = this;
switch (_that) {
case _Capabilities() when $default != null:
return $default(_that.area,_that.canSaveListings,_that.canSeeReviews,_that.canUseHostPanel,_that.canBlockDays);case _:
  return null;

}
}

}

/// @nodoc


class _Capabilities extends Capabilities {
  const _Capabilities({this.area = AccessArea.none, this.canSaveListings = false, this.canSeeReviews = false, this.canUseHostPanel = false, this.canBlockDays = false}): super._();
  

@override@JsonKey() final  AccessArea area;
@override@JsonKey() final  bool canSaveListings;
@override@JsonKey() final  bool canSeeReviews;
@override@JsonKey() final  bool canUseHostPanel;
@override@JsonKey() final  bool canBlockDays;

/// Create a copy of Capabilities
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapabilitiesCopyWith<_Capabilities> get copyWith => __$CapabilitiesCopyWithImpl<_Capabilities>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Capabilities&&(identical(other.area, area) || other.area == area)&&(identical(other.canSaveListings, canSaveListings) || other.canSaveListings == canSaveListings)&&(identical(other.canSeeReviews, canSeeReviews) || other.canSeeReviews == canSeeReviews)&&(identical(other.canUseHostPanel, canUseHostPanel) || other.canUseHostPanel == canUseHostPanel)&&(identical(other.canBlockDays, canBlockDays) || other.canBlockDays == canBlockDays));
}


@override
int get hashCode {
    return Object.hash(runtimeType,area,canSaveListings,canSeeReviews,canUseHostPanel,canBlockDays);
}

@override
String toString() {
    return 'Capabilities(area: $area, canSaveListings: $canSaveListings, canSeeReviews: $canSeeReviews, canUseHostPanel: $canUseHostPanel, canBlockDays: $canBlockDays)';
}


}

/// @nodoc
abstract mixin class _$CapabilitiesCopyWith<$Res> implements $CapabilitiesCopyWith<$Res> {
  factory _$CapabilitiesCopyWith(_Capabilities value, $Res Function(_Capabilities) _then) = __$CapabilitiesCopyWithImpl;
@override @useResult
$Res call({
 AccessArea area, bool canSaveListings, bool canSeeReviews, bool canUseHostPanel, bool canBlockDays
});




}
/// @nodoc
class __$CapabilitiesCopyWithImpl<$Res>
    implements _$CapabilitiesCopyWith<$Res> {
  __$CapabilitiesCopyWithImpl(this._self, this._then);

  final _Capabilities _self;
  final $Res Function(_Capabilities) _then;

/// Create a copy of Capabilities
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? area = null,Object? canSaveListings = null,Object? canSeeReviews = null,Object? canUseHostPanel = null,Object? canBlockDays = null,}) {
  return _then(_Capabilities(
area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as AccessArea,canSaveListings: null == canSaveListings ? _self.canSaveListings : canSaveListings // ignore: cast_nullable_to_non_nullable
as bool,canSeeReviews: null == canSeeReviews ? _self.canSeeReviews : canSeeReviews // ignore: cast_nullable_to_non_nullable
as bool,canUseHostPanel: null == canUseHostPanel ? _self.canUseHostPanel : canUseHostPanel // ignore: cast_nullable_to_non_nullable
as bool,canBlockDays: null == canBlockDays ? _self.canBlockDays : canBlockDays // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
