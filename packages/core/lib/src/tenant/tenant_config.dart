import 'package:freezed_annotation/freezed_annotation.dart';

import 'tenant_flags.dart';

part 'tenant_config.freezed.dart';
part 'tenant_config.g.dart';

/// Colour tokens for one brightness, keyed by role (`surface-primary`, ...)
/// with the raw hex string as the value. `core` only carries them; the single
/// hex parser lives in `design_system`. Entries that are not strings are
/// dropped here, so the theme builder falls back for them instead of the
/// whole config failing to load.
Map<String, String> _tokensFromJson(Object? json) =>
    json is Map<String, dynamic>
    ? {
        for (final entry in json.entries)
          if (entry.value is String) entry.key: entry.value as String,
      }
    : const {};

@freezed
abstract class TenantTheme with _$TenantTheme {
  const factory TenantTheme({
    @JsonKey(fromJson: _tokensFromJson) @Default({}) Map<String, String> light,
    @JsonKey(fromJson: _tokensFromJson) @Default({}) Map<String, String> dark,
  }) = _TenantTheme;

  factory TenantTheme.fromJson(Map<String, dynamic> json) =>
      _$TenantThemeFromJson(json);
}

/// `GET /tenants/{slug}/runtime-config`. Everything the app shows about
/// itself comes from here; the build only knows the slug.
@freezed
abstract class TenantConfig with _$TenantConfig {
  const factory TenantConfig({
    required String slug,

    /// The app's title everywhere, not the slug.
    required String name,

    /// The tenant's default currency. Prices still use the row's own.
    required String currency,
    required List<String> locales,
    required String defaultLocale,
    required String supportEmail,
    required String termsOfUseUrl,
    required String privacyPolicyUrl,
    @JsonKey(name: 'permissions') required TenantFlags flags,
    required TenantTheme theme,
  }) = _TenantConfig;

  factory TenantConfig.fromJson(Map<String, dynamic> json) =>
      _$TenantConfigFromJson(json);
}
