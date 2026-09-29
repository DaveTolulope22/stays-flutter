// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TenantTheme _$TenantThemeFromJson(Map<String, dynamic> json) => _TenantTheme(
  light: json['light'] == null ? const {} : _tokensFromJson(json['light']),
  dark: json['dark'] == null ? const {} : _tokensFromJson(json['dark']),
);

Map<String, dynamic> _$TenantThemeToJson(_TenantTheme instance) =>
    <String, dynamic>{'light': instance.light, 'dark': instance.dark};

_TenantConfig _$TenantConfigFromJson(Map<String, dynamic> json) =>
    _TenantConfig(
      slug: json['slug'] as String,
      name: json['name'] as String,
      currency: json['currency'] as String,
      locales: (json['locales'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      defaultLocale: json['defaultLocale'] as String,
      supportEmail: json['supportEmail'] as String,
      termsOfUseUrl: json['termsOfUseUrl'] as String,
      privacyPolicyUrl: json['privacyPolicyUrl'] as String,
      flags: TenantFlags.fromJson(json['permissions'] as Map<String, dynamic>),
      theme: TenantTheme.fromJson(json['theme'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TenantConfigToJson(_TenantConfig instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'currency': instance.currency,
      'locales': instance.locales,
      'defaultLocale': instance.defaultLocale,
      'supportEmail': instance.supportEmail,
      'termsOfUseUrl': instance.termsOfUseUrl,
      'privacyPolicyUrl': instance.privacyPolicyUrl,
      'permissions': instance.flags,
      'theme': instance.theme,
    };
