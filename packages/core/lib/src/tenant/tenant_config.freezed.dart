// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TenantTheme {

@JsonKey(fromJson: _tokensFromJson) Map<String, String> get light;@JsonKey(fromJson: _tokensFromJson) Map<String, String> get dark;
/// Create a copy of TenantTheme
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantThemeCopyWith<TenantTheme> get copyWith => _$TenantThemeCopyWithImpl<TenantTheme>(this as TenantTheme, _$identity);

  /// Serializes this TenantTheme to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TenantTheme;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantTheme&&const DeepCollectionEquality().equals(other.light, _this.light)&&const DeepCollectionEquality().equals(other.dark, _this.dark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TenantTheme;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.light),const DeepCollectionEquality().hash(_this.dark));
}

@override
String toString() {
  final _this = this as TenantTheme;
  return 'TenantTheme(light: ${_this.light}, dark: ${_this.dark})';
}


}

/// @nodoc
abstract mixin class $TenantThemeCopyWith<$Res>  {
  factory $TenantThemeCopyWith(TenantTheme value, $Res Function(TenantTheme) _then) = _$TenantThemeCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _tokensFromJson) Map<String, String> light,@JsonKey(fromJson: _tokensFromJson) Map<String, String> dark
});




}
/// @nodoc
class _$TenantThemeCopyWithImpl<$Res>
    implements $TenantThemeCopyWith<$Res> {
  _$TenantThemeCopyWithImpl(this._self, this._then);

  final TenantTheme _self;
  final $Res Function(TenantTheme) _then;

/// Create a copy of TenantTheme
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? light = null,Object? dark = null,}) {
  return _then(TenantTheme(
light: null == light ? _self.light : light // ignore: cast_nullable_to_non_nullable
as Map<String, String>,dark: null == dark ? _self.dark : dark // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TenantTheme].
extension TenantThemePatterns on TenantTheme {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantTheme value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantTheme() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantTheme value)  $default,){
final _that = this;
switch (_that) {
case _TenantTheme():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantTheme value)?  $default,){
final _that = this;
switch (_that) {
case _TenantTheme() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _tokensFromJson)  Map<String, String> light, @JsonKey(fromJson: _tokensFromJson)  Map<String, String> dark)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantTheme() when $default != null:
return $default(_that.light,_that.dark);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _tokensFromJson)  Map<String, String> light, @JsonKey(fromJson: _tokensFromJson)  Map<String, String> dark)  $default,) {final _that = this;
switch (_that) {
case _TenantTheme():
return $default(_that.light,_that.dark);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _tokensFromJson)  Map<String, String> light, @JsonKey(fromJson: _tokensFromJson)  Map<String, String> dark)?  $default,) {final _that = this;
switch (_that) {
case _TenantTheme() when $default != null:
return $default(_that.light,_that.dark);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TenantTheme implements TenantTheme {
  const _TenantTheme({@JsonKey(fromJson: _tokensFromJson)  Map<String, String> light = const {}, @JsonKey(fromJson: _tokensFromJson)  Map<String, String> dark = const {}}): _light = light,_dark = dark;
  factory _TenantTheme.fromJson(Map<String, dynamic> json) => _$TenantThemeFromJson(json);

 final  Map<String, String> _light;
@override@JsonKey(fromJson: _tokensFromJson) Map<String, String> get light {
  if (_light is EqualUnmodifiableMapView) return _light;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_light);
}

 final  Map<String, String> _dark;
@override@JsonKey(fromJson: _tokensFromJson) Map<String, String> get dark {
  if (_dark is EqualUnmodifiableMapView) return _dark;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dark);
}


/// Create a copy of TenantTheme
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantThemeCopyWith<_TenantTheme> get copyWith => __$TenantThemeCopyWithImpl<_TenantTheme>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantThemeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantTheme&&const DeepCollectionEquality().equals(other.light, _light)&&const DeepCollectionEquality().equals(other.dark, _dark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_light),const DeepCollectionEquality().hash(_dark));
}

@override
String toString() {
    return 'TenantTheme(light: $light, dark: $dark)';
}


}

/// @nodoc
abstract mixin class _$TenantThemeCopyWith<$Res> implements $TenantThemeCopyWith<$Res> {
  factory _$TenantThemeCopyWith(_TenantTheme value, $Res Function(_TenantTheme) _then) = __$TenantThemeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _tokensFromJson) Map<String, String> light,@JsonKey(fromJson: _tokensFromJson) Map<String, String> dark
});




}
/// @nodoc
class __$TenantThemeCopyWithImpl<$Res>
    implements _$TenantThemeCopyWith<$Res> {
  __$TenantThemeCopyWithImpl(this._self, this._then);

  final _TenantTheme _self;
  final $Res Function(_TenantTheme) _then;

/// Create a copy of TenantTheme
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? light = null,Object? dark = null,}) {
  return _then(_TenantTheme(
light: null == light ? _self._light : light // ignore: cast_nullable_to_non_nullable
as Map<String, String>,dark: null == dark ? _self._dark : dark // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}


/// @nodoc
mixin _$TenantConfig {

 String get slug;/// The app's title everywhere, not the slug.
 String get name;/// The tenant's default currency. Prices still use the row's own.
 String get currency; List<String> get locales; String get defaultLocale; String get supportEmail; String get termsOfUseUrl; String get privacyPolicyUrl;@JsonKey(name: 'permissions') TenantFlags get flags; TenantTheme get theme;
/// Create a copy of TenantConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantConfigCopyWith<TenantConfig> get copyWith => _$TenantConfigCopyWithImpl<TenantConfig>(this as TenantConfig, _$identity);

  /// Serializes this TenantConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TenantConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantConfig&&(identical(other.slug, _this.slug) || other.slug == _this.slug)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&const DeepCollectionEquality().equals(other.locales, _this.locales)&&(identical(other.defaultLocale, _this.defaultLocale) || other.defaultLocale == _this.defaultLocale)&&(identical(other.supportEmail, _this.supportEmail) || other.supportEmail == _this.supportEmail)&&(identical(other.termsOfUseUrl, _this.termsOfUseUrl) || other.termsOfUseUrl == _this.termsOfUseUrl)&&(identical(other.privacyPolicyUrl, _this.privacyPolicyUrl) || other.privacyPolicyUrl == _this.privacyPolicyUrl)&&(identical(other.flags, _this.flags) || other.flags == _this.flags)&&(identical(other.theme, _this.theme) || other.theme == _this.theme));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TenantConfig;
  return Object.hash(runtimeType,_this.slug,_this.name,_this.currency,const DeepCollectionEquality().hash(_this.locales),_this.defaultLocale,_this.supportEmail,_this.termsOfUseUrl,_this.privacyPolicyUrl,_this.flags,_this.theme);
}

@override
String toString() {
  final _this = this as TenantConfig;
  return 'TenantConfig(slug: ${_this.slug}, name: ${_this.name}, currency: ${_this.currency}, locales: ${_this.locales}, defaultLocale: ${_this.defaultLocale}, supportEmail: ${_this.supportEmail}, termsOfUseUrl: ${_this.termsOfUseUrl}, privacyPolicyUrl: ${_this.privacyPolicyUrl}, flags: ${_this.flags}, theme: ${_this.theme})';
}


}

/// @nodoc
abstract mixin class $TenantConfigCopyWith<$Res>  {
  factory $TenantConfigCopyWith(TenantConfig value, $Res Function(TenantConfig) _then) = _$TenantConfigCopyWithImpl;
@useResult
$Res call({
 String slug, String name, String currency, List<String> locales, String defaultLocale, String supportEmail, String termsOfUseUrl, String privacyPolicyUrl,@JsonKey(name: 'permissions') TenantFlags flags, TenantTheme theme
});


$TenantFlagsCopyWith<$Res> get flags;$TenantThemeCopyWith<$Res> get theme;

}
/// @nodoc
class _$TenantConfigCopyWithImpl<$Res>
    implements $TenantConfigCopyWith<$Res> {
  _$TenantConfigCopyWithImpl(this._self, this._then);

  final TenantConfig _self;
  final $Res Function(TenantConfig) _then;

/// Create a copy of TenantConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,Object? currency = null,Object? locales = null,Object? defaultLocale = null,Object? supportEmail = null,Object? termsOfUseUrl = null,Object? privacyPolicyUrl = null,Object? flags = null,Object? theme = null,}) {
  return _then(TenantConfig(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,locales: null == locales ? _self.locales : locales // ignore: cast_nullable_to_non_nullable
as List<String>,defaultLocale: null == defaultLocale ? _self.defaultLocale : defaultLocale // ignore: cast_nullable_to_non_nullable
as String,supportEmail: null == supportEmail ? _self.supportEmail : supportEmail // ignore: cast_nullable_to_non_nullable
as String,termsOfUseUrl: null == termsOfUseUrl ? _self.termsOfUseUrl : termsOfUseUrl // ignore: cast_nullable_to_non_nullable
as String,privacyPolicyUrl: null == privacyPolicyUrl ? _self.privacyPolicyUrl : privacyPolicyUrl // ignore: cast_nullable_to_non_nullable
as String,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as TenantFlags,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as TenantTheme,
  ));
}
/// Create a copy of TenantConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantFlagsCopyWith<$Res> get flags {
  
  return $TenantFlagsCopyWith<$Res>(_self.flags, (value) {
    return _then(_self.copyWith(flags: value));
  });
}/// Create a copy of TenantConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantThemeCopyWith<$Res> get theme {
  
  return $TenantThemeCopyWith<$Res>(_self.theme, (value) {
    return _then(_self.copyWith(theme: value));
  });
}
}


/// Adds pattern-matching-related methods to [TenantConfig].
extension TenantConfigPatterns on TenantConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantConfig value)  $default,){
final _that = this;
switch (_that) {
case _TenantConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantConfig value)?  $default,){
final _that = this;
switch (_that) {
case _TenantConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String slug,  String name,  String currency,  List<String> locales,  String defaultLocale,  String supportEmail,  String termsOfUseUrl,  String privacyPolicyUrl, @JsonKey(name: 'permissions')  TenantFlags flags,  TenantTheme theme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantConfig() when $default != null:
return $default(_that.slug,_that.name,_that.currency,_that.locales,_that.defaultLocale,_that.supportEmail,_that.termsOfUseUrl,_that.privacyPolicyUrl,_that.flags,_that.theme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String slug,  String name,  String currency,  List<String> locales,  String defaultLocale,  String supportEmail,  String termsOfUseUrl,  String privacyPolicyUrl, @JsonKey(name: 'permissions')  TenantFlags flags,  TenantTheme theme)  $default,) {final _that = this;
switch (_that) {
case _TenantConfig():
return $default(_that.slug,_that.name,_that.currency,_that.locales,_that.defaultLocale,_that.supportEmail,_that.termsOfUseUrl,_that.privacyPolicyUrl,_that.flags,_that.theme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String slug,  String name,  String currency,  List<String> locales,  String defaultLocale,  String supportEmail,  String termsOfUseUrl,  String privacyPolicyUrl, @JsonKey(name: 'permissions')  TenantFlags flags,  TenantTheme theme)?  $default,) {final _that = this;
switch (_that) {
case _TenantConfig() when $default != null:
return $default(_that.slug,_that.name,_that.currency,_that.locales,_that.defaultLocale,_that.supportEmail,_that.termsOfUseUrl,_that.privacyPolicyUrl,_that.flags,_that.theme);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TenantConfig implements TenantConfig {
  const _TenantConfig({required this.slug, required this.name, required this.currency, required  List<String> locales, required this.defaultLocale, required this.supportEmail, required this.termsOfUseUrl, required this.privacyPolicyUrl, @JsonKey(name: 'permissions') required this.flags, required this.theme}): _locales = locales;
  factory _TenantConfig.fromJson(Map<String, dynamic> json) => _$TenantConfigFromJson(json);

@override final  String slug;
/// The app's title everywhere, not the slug.
@override final  String name;
/// The tenant's default currency. Prices still use the row's own.
@override final  String currency;
 final  List<String> _locales;
@override List<String> get locales {
  if (_locales is EqualUnmodifiableListView) return _locales;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locales);
}

@override final  String defaultLocale;
@override final  String supportEmail;
@override final  String termsOfUseUrl;
@override final  String privacyPolicyUrl;
@override@JsonKey(name: 'permissions') final  TenantFlags flags;
@override final  TenantTheme theme;

/// Create a copy of TenantConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantConfigCopyWith<_TenantConfig> get copyWith => __$TenantConfigCopyWithImpl<_TenantConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantConfig&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.locales, _locales)&&(identical(other.defaultLocale, defaultLocale) || other.defaultLocale == defaultLocale)&&(identical(other.supportEmail, supportEmail) || other.supportEmail == supportEmail)&&(identical(other.termsOfUseUrl, termsOfUseUrl) || other.termsOfUseUrl == termsOfUseUrl)&&(identical(other.privacyPolicyUrl, privacyPolicyUrl) || other.privacyPolicyUrl == privacyPolicyUrl)&&(identical(other.flags, flags) || other.flags == flags)&&(identical(other.theme, theme) || other.theme == theme));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,slug,name,currency,const DeepCollectionEquality().hash(_locales),defaultLocale,supportEmail,termsOfUseUrl,privacyPolicyUrl,flags,theme);
}

@override
String toString() {
    return 'TenantConfig(slug: $slug, name: $name, currency: $currency, locales: $locales, defaultLocale: $defaultLocale, supportEmail: $supportEmail, termsOfUseUrl: $termsOfUseUrl, privacyPolicyUrl: $privacyPolicyUrl, flags: $flags, theme: $theme)';
}


}

/// @nodoc
abstract mixin class _$TenantConfigCopyWith<$Res> implements $TenantConfigCopyWith<$Res> {
  factory _$TenantConfigCopyWith(_TenantConfig value, $Res Function(_TenantConfig) _then) = __$TenantConfigCopyWithImpl;
@override @useResult
$Res call({
 String slug, String name, String currency, List<String> locales, String defaultLocale, String supportEmail, String termsOfUseUrl, String privacyPolicyUrl,@JsonKey(name: 'permissions') TenantFlags flags, TenantTheme theme
});


@override $TenantFlagsCopyWith<$Res> get flags;@override $TenantThemeCopyWith<$Res> get theme;

}
/// @nodoc
class __$TenantConfigCopyWithImpl<$Res>
    implements _$TenantConfigCopyWith<$Res> {
  __$TenantConfigCopyWithImpl(this._self, this._then);

  final _TenantConfig _self;
  final $Res Function(_TenantConfig) _then;

/// Create a copy of TenantConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,Object? currency = null,Object? locales = null,Object? defaultLocale = null,Object? supportEmail = null,Object? termsOfUseUrl = null,Object? privacyPolicyUrl = null,Object? flags = null,Object? theme = null,}) {
  return _then(_TenantConfig(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,locales: null == locales ? _self._locales : locales // ignore: cast_nullable_to_non_nullable
as List<String>,defaultLocale: null == defaultLocale ? _self.defaultLocale : defaultLocale // ignore: cast_nullable_to_non_nullable
as String,supportEmail: null == supportEmail ? _self.supportEmail : supportEmail // ignore: cast_nullable_to_non_nullable
as String,termsOfUseUrl: null == termsOfUseUrl ? _self.termsOfUseUrl : termsOfUseUrl // ignore: cast_nullable_to_non_nullable
as String,privacyPolicyUrl: null == privacyPolicyUrl ? _self.privacyPolicyUrl : privacyPolicyUrl // ignore: cast_nullable_to_non_nullable
as String,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as TenantFlags,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as TenantTheme,
  ));
}

/// Create a copy of TenantConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantFlagsCopyWith<$Res> get flags {
  
  return $TenantFlagsCopyWith<$Res>(_self.flags, (value) {
    return _then(_self.copyWith(flags: value));
  });
}/// Create a copy of TenantConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantThemeCopyWith<$Res> get theme {
  
  return $TenantThemeCopyWith<$Res>(_self.theme, (value) {
    return _then(_self.copyWith(theme: value));
  });
}
}

// dart format on
