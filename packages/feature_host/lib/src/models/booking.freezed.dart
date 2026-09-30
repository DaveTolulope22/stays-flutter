// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {

 String get id; String get listingId; String get tenantId; String get guestName;/// Inclusive. A date without a time, so a [LocalDate], never a `DateTime`.
@LocalDateConverter() LocalDate get checkIn;/// Exclusive: the guest leaves this morning, so back-to-back stays do not
/// clash.
@LocalDateConverter() LocalDate get checkOut; int get guests;@JsonKey(unknownEnumValue: BookingStatus.unknown) BookingStatus get status;/// As at booking time. A later price edit does not restate it. A `num`
/// because the API may send `480` or `480.5`.
 num get totalPrice; String get currency; DateTime get createdAt;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Booking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&(identical(other.tenantId, _this.tenantId) || other.tenantId == _this.tenantId)&&(identical(other.guestName, _this.guestName) || other.guestName == _this.guestName)&&(identical(other.checkIn, _this.checkIn) || other.checkIn == _this.checkIn)&&(identical(other.checkOut, _this.checkOut) || other.checkOut == _this.checkOut)&&(identical(other.guests, _this.guests) || other.guests == _this.guests)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.totalPrice, _this.totalPrice) || other.totalPrice == _this.totalPrice)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Booking;
  return Object.hash(runtimeType,_this.id,_this.listingId,_this.tenantId,_this.guestName,_this.checkIn,_this.checkOut,_this.guests,_this.status,_this.totalPrice,_this.currency,_this.createdAt);
}

@override
String toString() {
  final _this = this as Booking;
  return 'Booking(id: ${_this.id}, listingId: ${_this.listingId}, tenantId: ${_this.tenantId}, guestName: ${_this.guestName}, checkIn: ${_this.checkIn}, checkOut: ${_this.checkOut}, guests: ${_this.guests}, status: ${_this.status}, totalPrice: ${_this.totalPrice}, currency: ${_this.currency}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id, String listingId, String tenantId, String guestName,@LocalDateConverter() LocalDate checkIn,@LocalDateConverter() LocalDate checkOut, int guests,@JsonKey(unknownEnumValue: BookingStatus.unknown) BookingStatus status, num totalPrice, String currency, DateTime createdAt
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? listingId = null,Object? tenantId = null,Object? guestName = null,Object? checkIn = null,Object? checkOut = null,Object? guests = null,Object? status = null,Object? totalPrice = null,Object? currency = null,Object? createdAt = null,}) {
  return _then(Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,guestName: null == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String,checkIn: null == checkIn ? _self.checkIn : checkIn // ignore: cast_nullable_to_non_nullable
as LocalDate,checkOut: null == checkOut ? _self.checkOut : checkOut // ignore: cast_nullable_to_non_nullable
as LocalDate,guests: null == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as num,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String listingId,  String tenantId,  String guestName, @LocalDateConverter()  LocalDate checkIn, @LocalDateConverter()  LocalDate checkOut,  int guests, @JsonKey(unknownEnumValue: BookingStatus.unknown)  BookingStatus status,  num totalPrice,  String currency,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.listingId,_that.tenantId,_that.guestName,_that.checkIn,_that.checkOut,_that.guests,_that.status,_that.totalPrice,_that.currency,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String listingId,  String tenantId,  String guestName, @LocalDateConverter()  LocalDate checkIn, @LocalDateConverter()  LocalDate checkOut,  int guests, @JsonKey(unknownEnumValue: BookingStatus.unknown)  BookingStatus status,  num totalPrice,  String currency,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.listingId,_that.tenantId,_that.guestName,_that.checkIn,_that.checkOut,_that.guests,_that.status,_that.totalPrice,_that.currency,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String listingId,  String tenantId,  String guestName, @LocalDateConverter()  LocalDate checkIn, @LocalDateConverter()  LocalDate checkOut,  int guests, @JsonKey(unknownEnumValue: BookingStatus.unknown)  BookingStatus status,  num totalPrice,  String currency,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.listingId,_that.tenantId,_that.guestName,_that.checkIn,_that.checkOut,_that.guests,_that.status,_that.totalPrice,_that.currency,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking implements Booking {
  const _Booking({required this.id, required this.listingId, required this.tenantId, required this.guestName, @LocalDateConverter() required this.checkIn, @LocalDateConverter() required this.checkOut, required this.guests, @JsonKey(unknownEnumValue: BookingStatus.unknown) required this.status, required this.totalPrice, required this.currency, required this.createdAt});
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override final  String listingId;
@override final  String tenantId;
@override final  String guestName;
/// Inclusive. A date without a time, so a [LocalDate], never a `DateTime`.
@override@LocalDateConverter() final  LocalDate checkIn;
/// Exclusive: the guest leaves this morning, so back-to-back stays do not
/// clash.
@override@LocalDateConverter() final  LocalDate checkOut;
@override final  int guests;
@override@JsonKey(unknownEnumValue: BookingStatus.unknown) final  BookingStatus status;
/// As at booking time. A later price edit does not restate it. A `num`
/// because the API may send `480` or `480.5`.
@override final  num totalPrice;
@override final  String currency;
@override final  DateTime createdAt;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.checkIn, checkIn) || other.checkIn == checkIn)&&(identical(other.checkOut, checkOut) || other.checkOut == checkOut)&&(identical(other.guests, guests) || other.guests == guests)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,listingId,tenantId,guestName,checkIn,checkOut,guests,status,totalPrice,currency,createdAt);
}

@override
String toString() {
    return 'Booking(id: $id, listingId: $listingId, tenantId: $tenantId, guestName: $guestName, checkIn: $checkIn, checkOut: $checkOut, guests: $guests, status: $status, totalPrice: $totalPrice, currency: $currency, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String listingId, String tenantId, String guestName,@LocalDateConverter() LocalDate checkIn,@LocalDateConverter() LocalDate checkOut, int guests,@JsonKey(unknownEnumValue: BookingStatus.unknown) BookingStatus status, num totalPrice, String currency, DateTime createdAt
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? listingId = null,Object? tenantId = null,Object? guestName = null,Object? checkIn = null,Object? checkOut = null,Object? guests = null,Object? status = null,Object? totalPrice = null,Object? currency = null,Object? createdAt = null,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,guestName: null == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String,checkIn: null == checkIn ? _self.checkIn : checkIn // ignore: cast_nullable_to_non_nullable
as LocalDate,checkOut: null == checkOut ? _self.checkOut : checkOut // ignore: cast_nullable_to_non_nullable
as LocalDate,guests: null == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as num,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
