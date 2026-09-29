// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant_flags.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TenantFlags {

 bool get hostPanel; bool get favourites; bool get reviews; bool get blockedDays;
/// Create a copy of TenantFlags
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantFlagsCopyWith<TenantFlags> get copyWith => _$TenantFlagsCopyWithImpl<TenantFlags>(this as TenantFlags, _$identity);

  /// Serializes this TenantFlags to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TenantFlags;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantFlags&&(identical(other.hostPanel, _this.hostPanel) || other.hostPanel == _this.hostPanel)&&(identical(other.favourites, _this.favourites) || other.favourites == _this.favourites)&&(identical(other.reviews, _this.reviews) || other.reviews == _this.reviews)&&(identical(other.blockedDays, _this.blockedDays) || other.blockedDays == _this.blockedDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TenantFlags;
  return Object.hash(runtimeType,_this.hostPanel,_this.favourites,_this.reviews,_this.blockedDays);
}

@override
String toString() {
  final _this = this as TenantFlags;
  return 'TenantFlags(hostPanel: ${_this.hostPanel}, favourites: ${_this.favourites}, reviews: ${_this.reviews}, blockedDays: ${_this.blockedDays})';
}


}

/// @nodoc
abstract mixin class $TenantFlagsCopyWith<$Res>  {
  factory $TenantFlagsCopyWith(TenantFlags value, $Res Function(TenantFlags) _then) = _$TenantFlagsCopyWithImpl;
@useResult
$Res call({
 bool hostPanel, bool favourites, bool reviews, bool blockedDays
});




}
/// @nodoc
class _$TenantFlagsCopyWithImpl<$Res>
    implements $TenantFlagsCopyWith<$Res> {
  _$TenantFlagsCopyWithImpl(this._self, this._then);

  final TenantFlags _self;
  final $Res Function(TenantFlags) _then;

/// Create a copy of TenantFlags
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hostPanel = null,Object? favourites = null,Object? reviews = null,Object? blockedDays = null,}) {
  return _then(TenantFlags(
hostPanel: null == hostPanel ? _self.hostPanel : hostPanel // ignore: cast_nullable_to_non_nullable
as bool,favourites: null == favourites ? _self.favourites : favourites // ignore: cast_nullable_to_non_nullable
as bool,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as bool,blockedDays: null == blockedDays ? _self.blockedDays : blockedDays // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TenantFlags].
extension TenantFlagsPatterns on TenantFlags {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantFlags value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantFlags() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantFlags value)  $default,){
final _that = this;
switch (_that) {
case _TenantFlags():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantFlags value)?  $default,){
final _that = this;
switch (_that) {
case _TenantFlags() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hostPanel,  bool favourites,  bool reviews,  bool blockedDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantFlags() when $default != null:
return $default(_that.hostPanel,_that.favourites,_that.reviews,_that.blockedDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hostPanel,  bool favourites,  bool reviews,  bool blockedDays)  $default,) {final _that = this;
switch (_that) {
case _TenantFlags():
return $default(_that.hostPanel,_that.favourites,_that.reviews,_that.blockedDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hostPanel,  bool favourites,  bool reviews,  bool blockedDays)?  $default,) {final _that = this;
switch (_that) {
case _TenantFlags() when $default != null:
return $default(_that.hostPanel,_that.favourites,_that.reviews,_that.blockedDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TenantFlags implements TenantFlags {
  const _TenantFlags({this.hostPanel = false, this.favourites = false, this.reviews = false, this.blockedDays = false});
  factory _TenantFlags.fromJson(Map<String, dynamic> json) => _$TenantFlagsFromJson(json);

@override@JsonKey() final  bool hostPanel;
@override@JsonKey() final  bool favourites;
@override@JsonKey() final  bool reviews;
@override@JsonKey() final  bool blockedDays;

/// Create a copy of TenantFlags
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantFlagsCopyWith<_TenantFlags> get copyWith => __$TenantFlagsCopyWithImpl<_TenantFlags>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantFlagsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantFlags&&(identical(other.hostPanel, hostPanel) || other.hostPanel == hostPanel)&&(identical(other.favourites, favourites) || other.favourites == favourites)&&(identical(other.reviews, reviews) || other.reviews == reviews)&&(identical(other.blockedDays, blockedDays) || other.blockedDays == blockedDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,hostPanel,favourites,reviews,blockedDays);
}

@override
String toString() {
    return 'TenantFlags(hostPanel: $hostPanel, favourites: $favourites, reviews: $reviews, blockedDays: $blockedDays)';
}


}

/// @nodoc
abstract mixin class _$TenantFlagsCopyWith<$Res> implements $TenantFlagsCopyWith<$Res> {
  factory _$TenantFlagsCopyWith(_TenantFlags value, $Res Function(_TenantFlags) _then) = __$TenantFlagsCopyWithImpl;
@override @useResult
$Res call({
 bool hostPanel, bool favourites, bool reviews, bool blockedDays
});




}
/// @nodoc
class __$TenantFlagsCopyWithImpl<$Res>
    implements _$TenantFlagsCopyWith<$Res> {
  __$TenantFlagsCopyWithImpl(this._self, this._then);

  final _TenantFlags _self;
  final $Res Function(_TenantFlags) _then;

/// Create a copy of TenantFlags
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hostPanel = null,Object? favourites = null,Object? reviews = null,Object? blockedDays = null,}) {
  return _then(_TenantFlags(
hostPanel: null == hostPanel ? _self.hostPanel : hostPanel // ignore: cast_nullable_to_non_nullable
as bool,favourites: null == favourites ? _self.favourites : favourites // ignore: cast_nullable_to_non_nullable
as bool,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as bool,blockedDays: null == blockedDays ? _self.blockedDays : blockedDays // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
